
/**
 * Copyright 1993-2012 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 */
#include <cuda.h>
#include <thrust/device_vector.h>
#include <thrust/sort.h>
#include <thrust/fill.h>
#include <thrust/device_allocator.h>
#include <thrust/iterator/counting_iterator.h>

#include "labels.h"
#include <fstream>
using namespace std;

__device__ double myatomicAdd(double* address, double val)
{
    unsigned long long int* address_as_ull =
                             (unsigned long long int*)address;
    unsigned long long int old = *address_as_ull, assumed;
    do {
        assumed = old;
        old = atomicCAS(address_as_ull, assumed,
                        __double_as_longlong(val +
                                             __longlong_as_double(assumed)));
    } while (assumed != old);
    return __longlong_as_double(old);
}


namespace kmeans {
namespace detail {

__device__ __forceinline__ void update_centroid(int label, int dimension,int d,double accumulator, double* centroids,
                                                int count, int* counts) {
    int index = label * d + dimension;
    double* target = centroids + index;
    myatomicAdd(target, accumulator);
    if (dimension == 0) {
        myatomicAdd((double*)counts + label, count);
    }
}

__global__ void calculate_count(int* ordered_labels,int* counts){
	int dataindex = threadIdx.x + blockIdx.x * blockDim.x;
	int thislabel = ordered_labels[dataindex];
	atomicAdd(counts + thislabel,1);
}

__global__ void calculate_centroids(int n, int d, int k,
                                    double* data,
                                    int* ordered_labels,
                                    int* ordered_indices,
                                    double* centroids){
	int global_id_x = threadIdx.x;
	int global_id_y = threadIdx.y + blockIdx.y * blockDim.y;

	if((global_id_x < d) && (global_id_y < n)){
		int label = ordered_labels[global_id_y];
		int indice = ordered_indices[global_id_y];
		double ademisiondata = data[indice*d + global_id_x];
		double *target = centroids + label * d+global_id_x;
		myatomicAdd(target,ademisiondata);
	}
}
__global__ void scale_centroids(int d, int k, int* counts, double* centroids) {
    int global_id_x = threadIdx.x ;
    int global_id_y = threadIdx.y + blockIdx.y * blockDim.y;
    if ((global_id_x < d) && (global_id_y < k)) {
        int count = counts[global_id_y];
        //To avoid introducing divide by zero errors
        //If a centroid has no weight, we'll do no normalization
        //This will keep its coordinates defined.
        if (count < 1) {
            count = 1;
        }
        double scale = 1.0/double(count);
        centroids[global_id_x + d * global_id_y] *= scale;
    }
}
void Read_Center(int k,int d,thrust::device_vector<double>& centroids){
	thrust::host_vector<double> host_centroids(k*d);
    ifstream infile;
    std::string filename = "/data/006zzy/files/tempcenter.txt";
    infile.open(filename);
    for(int i = 0;i < k;i++){
        for(int j = 0;j < d;j++){
           infile >> host_centroids[i * d + j];
        }
    }
    centroids = host_centroids;
    infile.close();
    std::cout << "slave read tempcenter.txt is ok..." << std::endl;
    /*
    for(int i = 0;i < k;i++)
    	for(int j = 0;j < d;j++){
    		std::cout << centroids[i*d + j] << " ";
    }
    std::cout <<std::endl;
    */

}
void Save_Center(int k,int d,thrust::host_vector<double>& centroids,int index){
	/*
	std::cout <<"h_centroids :"<<std::endl;
	for(int i = 0;i < k;i++){
		for(int j = 0;j < d;j++){
			std::cout << centroids[i*d + j] << " ";
		}
	}
	std::cout<<std::endl;*/
    std::string filename = "/data/006zzy/files/tempdata_";
    std::string number = std::to_string(index);
    filename += number;
    filename += ".txt";
    ofstream outfile;
    outfile.open(filename);
    for(int i = 0;i < k;i++){
        for(int j = 0;j < d;j++){
            outfile << centroids[i * d + j ];
            outfile << " ";
        }
    }
    outfile.close();
}
void find_centroids(int n, int d, int k,
                    thrust::device_vector<double>& data,
                    thrust::device_vector<int>& labels,
                    thrust::device_vector<double>& centroids,
                    thrust::device_vector<int>& range,
                    thrust::device_vector<int>& indices,
                    thrust::device_vector<int>& counts) {
    int dev_num;
    cudaGetDevice(&dev_num);
    detail::mymemcpy(indices,range);
    //Bring all labels with the same value together

#if 1
    thrust::sort_by_key(labels.begin(),
                        labels.end(),
                        indices.begin());
#else
    mycub::sort_by_key_int(labels, indices);//wrong!
#endif

    //Initialize centroids to all zeros
    detail::mymemzero(centroids);

    //Initialize counts to all zeros
    detail::mymemzero(counts);

    //Calculate centroids
    int n_threads_x = n;//old:64
    int n_threads_y = 1;//old:16
    //XXX Number of blocks here is hard coded at 30
    //This should be taken care of more thoughtfully.
    //dim3(1,1),old:Dim3(1,30)
    detail::calculate_count<<<dim3(1, 1), dim3(n_threads_x, n_threads_y),
                                  0, cuda_stream[dev_num]>>>
        (thrust::raw_pointer_cast(labels.data()),
         thrust::raw_pointer_cast(counts.data()));

    n_threads_x = 512;//old:64
    n_threads_y = 2;//old:16
    //contain 2*128 = 256 points

    detail::calculate_centroids<<<dim3(1, 128), dim3(n_threads_x, n_threads_y),
                                      0, cuda_stream[dev_num]>>>
            (n, d, k,
             thrust::raw_pointer_cast(data.data()),
             thrust::raw_pointer_cast(labels.data()),
             thrust::raw_pointer_cast(indices.data()),
             thrust::raw_pointer_cast(centroids.data()));

    //Scale centroids
    n_threads_x = 512;
    n_threads_y = 2;
    //y:k x:d
    detail::scale_centroids<<<dim3(1,128), dim3(n_threads_x, n_threads_y),
                              0, cuda_stream[dev_num]>>>
        (d, k,
         thrust::raw_pointer_cast(counts.data()),
         thrust::raw_pointer_cast(centroids.data()));


    /*
    //print counts
    for(int i = 0;i <k;i++){
    	std::cout << counts[i] <<" ";
    }
    std::cout << std::endl;
    //print &new center
    std::cout <<"centroids in find centroids end:"<<std::endl;
    for(int i = 0;i < n;i++){
    	for(int j = 0;j < d;j++){
        	std::cout << centroids[i*d + j] << " ";
        }
    }
    std::cout << std::endl;*/


}

}
}




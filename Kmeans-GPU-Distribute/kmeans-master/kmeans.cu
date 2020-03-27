#include "kmeans.h"
#include "util.h"
#include <thrust/reduce.h>

namespace kmeans {

int kmeans(int iterations,
           int n, int d, int k,
           thrust::device_vector<double>** data,
           thrust::device_vector<int>** labels,
           thrust::device_vector<double>** centroids,
           thrust::device_vector<double>** distances,
           int n_gpu,
           int index;//该slave下标
           bool init_from_labels, //默认有无初始分类号的label
           double threshold) {
    thrust::device_vector<double> *data_dots[16];
    thrust::device_vector<double> *centroid_dots[16];
    thrust::device_vector<double> *pairwise_distances[16];
    thrust::device_vector<int> *labels_copy[16];
    thrust::device_vector<int> *range[16];
    thrust::device_vector<int> *indices[16];
    thrust::device_vector<int> *counts[16];
    
    thrust::host_vector<double> h_centroids( k * d );
    thrust::host_vector<double> h_centroids_tmp( k * d );
    int h_changes[16], *d_changes[16];
    double h_distance_sum[16], *d_distance_sum[16];


    for (int q = 0; q < n_gpu; q++) {

        cudaSetDevice(q);
        cudaMalloc(&d_changes[q], sizeof(int));
        cudaMalloc(&d_distance_sum[q], sizeof(double));
        detail::labels_init();
        data_dots[q] = new thrust::device_vector <double>(n/n_gpu);
        centroid_dots[q] = new thrust::device_vector<double>(n/n_gpu);
        pairwise_distances[q] = new thrust::device_vector<double>(n/n_gpu * k);
        labels_copy[q] = new thrust::device_vector<int>(n/n_gpu * d);
        range[q] = new thrust::device_vector<int>(n/n_gpu);
        counts[q] = new thrust::device_vector<int>(k);
        indices[q] = new thrust::device_vector<int>(n/n_gpu);
        //Create and save "range" for initializing labels
        thrust::copy(thrust::counting_iterator<int>(0),
                     thrust::counting_iterator<int>(n/n_gpu), 
                     (*range[q]).begin());

        detail::make_self_dots(n/n_gpu, d, *data[q], *data_dots[q]);
        if (!init_from_labels) {
            //无默认label情况读取中心值(默认情况)
            detail::ReadCenter(k,d,*centroids[q]);
        }else{
            //有默认label情况下计算中心值
            detail::find_centroids(n/n_gpu,d,k,*data[q],*labels[q],*centroids[q],*range[q],*indices[q],*counts[q]);
        }
    }
    double prior_distance_sum = 0;
    int i=0;
    for(; i < iterations; i++) {
        for (int q = 0; q < n_gpu; q++) {
            //TODO compute total distance
            cudaSetDevice(q);
            detail::calculate_distances(n/n_gpu, d, k,*data[q], *centroids[q], *data_dots[q],*centroid_dots[q], *pairwise_distances[q]);
            detail::relabel(n/n_gpu, k, *pairwise_distances[q], *labels[q], *distances[q], d_changes[q]);
            //TODO remove one memcpy
            detail::memcpy(*labels_copy[q], *labels[q]);
            detail::find_centroids(n/n_gpu, d, k, *data[q], *labels[q], *centroids[q], *range[q], *indices[q], *counts[q]);
            detail::memcpy(*labels[q], *labels_copy[q]);
            //double d_distance_sum[q] = thrust::reduce(distances[q].begin(), distances[q].end())
            //mycub::sum_reduce(*distances[q], d_distance_sum[q]);
//Average the centroids from each device
        }
        if (n_gpu >= 1) {
            for (int p = 0; p < k * d; p++) h_centroids[p] = 0.0;
            for (int q = 0; q < n_gpu; q++) {
                cudaSetDevice(q);
                detail::memcpy(h_centroids_tmp, *centroids[q]);
                detail::streamsync(q);
                for (int p = 0; p < k * d; p++) h_centroids[p] += h_centroids_tmp[p];
            }
            for (int p = 0; p < k * d; p++) h_centroids[p] /= n_gpu;
            detail::Save_center(k,d,h_centroids,index);
        }
    }
    for (int q = 0; q < n_gpu; q++) {
       cudaSetDevice(q);
       cudaFree(d_changes[q]);
       detail::labels_close();
       delete(pairwise_distances[q]);
       delete(data_dots[q]);
       delete(centroid_dots[q]);
    }
    return i;


}


}


/**
 * Copyright 1993-2012 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 */
#include <stdio.h>
#include <stdlib.h>

#include <cuda.h>

#include <thrust/device_vector.h>

#include "kmeans.h"
#include "timer.h"


#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <fstream>
#include <algorithm>
#include <math.h>
#include <string.h>
#include <fstream>
#include <unistd.h>

using namespace std;

const int MAXD = 1000;//维度
const int MAXN = 1000;//点数
const int MAXC = 50;//Cluster类别

//产生随机标签
void random_labels(thrust::device_vector<int>& labels, int n, int k) {
    thrust::host_vector<int> host_labels(n);
    for(int i = 0; i < n; i++) {
        host_labels[i] = rand() % k;
    }
    labels = host_labels;
}
bool ReadData(thrust::device_vector<double>& data,int m,int d,int index)
{
	thrust::host_vector<double> host_data(m*d);
    std::string filename = "/data/006zzy/files/splitdata_";
    std::string number = std::to_string(index);
    filename += number;
    filename += ".txt";
    ifstream infile;
    infile.open(filename);
    if(!infile) {
    	std::cout <<"read splitdata fail..."<<std::endl;
    	return true;
    }
    for(int i = 0;i < m;i++){
        for(int j = 0;j < d;j++){
            infile >> host_data[i*d + j];
        }
    }
    infile.close();
    data = host_data;
    std::cout << "slave" << index << ": read " <<filename<<" is ok..."<<std::endl;
    //get any 3 points to check read
    /*
    for(int i = 15 ;i < 18;i++){
        	for(int j = 0;j < 20;j++){
        		std::cout <<host_data[i*d + j] << " " ;
        	}
    }
    std::cout << std::endl;
    for(int i = 15 ;i < 18;i++){
    	for(int j = 0;j < 20;j++){
    		std::cout <<data[i*d + j] << " " ;
    	}
    }
    std::cout << std::endl;
    */
    return true;
}
int main(int argc,char* argv[])
{
    //打印参数
	/*
    for(int i = 0;i < argc;i++){
        std::cout << "param " << i << " = "<< argv[i] <<std::endl;
    }*/
    int Cluster_Num = atoi(argv[1]);
    int Point_Num = atoi(argv[2]);
    int Point_Dimension = atoi(argv[3]);
    int Slave_Num = atoi(argv[4]);
    int Slave_Index = atoi(argv[5]);
    int n_gpu = 1;//只使用一个GPU
    int iterations = 1;//只循环1ci
    std::cout << "Use "<< n_gpu << " gpus" << std::endl;

    int Slave_Point_Num = 0;
    double n = (double)Point_Num;
    int every_points = ceil(n/Slave_Num);
    if(!(Point_Num % Slave_Num) || Slave_Index != (Slave_Num - 1)){
        Slave_Point_Num = every_points;
    }
    else if((Point_Num % Slave_Num )&&(Slave_Index == (Slave_Num -1))){
        Slave_Point_Num = Point_Num - (Slave_Index * every_points);
    }
    std::cout <<"This slave has "<<Slave_Point_Num<< "Points..."<<std::endl;

    thrust::device_vector<double> *data[16];
    //这里设置最大是16个GPU，相当于一???6行的指针，每个指针指向一个一维数组，整体相当于一个指向data[16][]的指???分了16组data
    thrust::device_vector<int> *labels[16];//同上
    thrust::device_vector<double> *centroids[16];//同上
    thrust::device_vector<double> *distances[16];//同上
    for (int q = 0; q < n_gpu; q++) {
        cudaSetDevice(q);
        data[q] = new thrust::device_vector<double>(Slave_Point_Num/n_gpu*Point_Dimension);//一个GPU管一片数据
        labels[q] = new thrust::device_vector<int>(Slave_Point_Num/n_gpu*Point_Dimension);//一片数据属于哪个类的下标集合
        centroids[q] = new thrust::device_vector<double>(Cluster_Num * Point_Dimension);//存储本片数据得出来的中心???
        distances[q] = new thrust::device_vector<double>(Slave_Point_Num);//不懂为什么创建Point_Num而不是Point_Num/n_gpu
    }
    for (int q = 0; q < n_gpu; q++) {
        ReadData(*data[q],Slave_Point_Num,Point_Dimension,Slave_Index);
        //std::cout <<"ReadData end..."<<std::endl;
        random_labels(*labels[q], Slave_Point_Num, Cluster_Num);//array[n/n_gpu] 但是让他们属于k个标签中的一???    }
        //std::cout <<"random labels end..."<<std::endl;
    }

    kmeans::timer t;
    t.start();
    std::cout <<"start kmeans..."<<std::endl;
    kmeans::kmeans(iterations, Slave_Point_Num, Point_Dimension, Cluster_Num, data, labels, centroids, distances, n_gpu,Slave_Index,false);//执行kmeans,拿到的是所有数
    std::cout <<"end kmeans..."<<std::endl;
    float time = t.stop();
    std::cout << "  Time: " << time/1000.0 << " s" << std::endl;

    for (int q = 0; q < n_gpu; q++) {
       delete(data[q]);
       delete(labels[q]);
       delete(centroids[q]);
    }
}

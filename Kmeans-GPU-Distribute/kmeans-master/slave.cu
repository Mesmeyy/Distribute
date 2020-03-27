#include <thrust/device_vector.h>

#include "kmeans.h"
#include "timer.h"
#include "util.h"
#include "cuda.h"

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
bool ReadData(thrust::device_vector<int>& data,int m,int d,int index)
{
    std::string filename = "splitdata_";
    std::string number = std::to_string(index);
    filename += number;
    filename += ".txt";
    ifstream infile;
    infile.open(filename);
    if(!infile) return false;
    for(int i = 0;i < m;i++){
        for(int j = 0;j < d;j++){
            infile >> data[i * d + j];
        }
    }
    infile.close();
    std::cout << "slave" << index << ": read " <<filename<<" is ok..."<<std::endl;
    return true;
}
int main(int argc,char* argv[]) 
{
    //打印参数
    for(int i = 0;i < argc,i++){
        std::cout << "param " << i << " = "<< argv[i] <<std::endl;
    }
    int Cluster_Num = atoi(argv[1]);
    int Point_Num = atoi(argv[2]);
    int Point_Dimension = atoi(argv[3]);
    int Slave_Num = atoi(argv[4]);
    int Slave_Index = atoi(argv[5]);
    int n_gpu = 1;//只使用一个GPU
    int iterations = 1;//只循环一???    
    std::cout << "Use "<< n_gpu << " gpus" << std::endl;

    thrust::device_vector<double> *data[16];
    //这里设置最大是16个GPU，相当于一???6行的指针，每个指针指向一个一维数组，整体相当于一个指向data[16][]的指???分了16组data
    thrust::device_vector<int> *labels[16];//同上
    thrust::device_vector<double> *centroids[16];//同上
    thrust::device_vector<double> *distances[16];//同上
    for (int q = 0; q < n_gpu; q++) {
        cudaSetDevice(q);
        data[q] = new thrust::device_vector<double>(Point_Num/n_gpu*Point_Dimension);//一个GPU管一片数据
        labels[q] = new thrust::device_vector<int>(Point_Num/n_gpu*Point_Dimension);//一片数据属于哪个类的下标集合
        centroids[q] = new thrust::device_vector<double>(Cluster_Num * Point_Dimension);//存储本片数据得出来的中心???
        distances[q] = new thrust::device_vector<double>(Point_Num);//不懂为什么创建Point_Num而不是Point_Num/n_gpu
    }
    for (int q = 0; q < n_gpu; q++) {
        ReadData(*data[q],Point_Num/n_gpu,Point_Dimension,Slave_Index);
        random_labels(*labels[q], Point_Num/n_gpu, Cluster_Num);//array[n/n_gpu] 但是让他们属于k个标签中的一???    }
    kmeans::timer t;
    t.start();
    kmeans::kmeans(iterations, Point_Num, Point_Dimension, Cluster_Num, data, labels, centroids, distances, n_gpu);//执行kmeans,拿到的是所有数
    float time = t.stop();
    std::cout << "  Time: " << time/1000.0 << " s" << std::endl;

    for (int q = 0; q < n_gpu; q++) {
       delete(data[q]);
       delete(labels[q]);
       delete(centroids[q]);
    }
}

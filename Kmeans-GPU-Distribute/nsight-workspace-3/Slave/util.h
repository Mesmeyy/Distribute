/*
 * util.h
 *
 *  Created on: Mar 30, 2020
 *      Author: root
 */

#ifndef UTIL_H_
#define UTIL_H_
void PrintCenter(int k,int d,thrust::device_vector<double>& centroids);
void PrintData(int n,int d,thrust::device_vector<double>& data);
void PrintCenter(int k,int d,thrust::device_vector<double>& centroids){
	for(int i = 0;i < k;i++){
		for(int j = 0;j < d;j++){
			std::cout << centroids[i*d + j] << " ";
		}
	}
	std::cout << std::endl;
}
void PrintData(int n,int d,thrust::device_vector<double>& data){
	for(int i = 0;i < n;i++){
		for(int j = 0;j < d;j++){
			std::cout << data[i*d + j] << " ";
		}
	}
	std::cout << std::endl;
}



#endif /* UTIL_H_ */

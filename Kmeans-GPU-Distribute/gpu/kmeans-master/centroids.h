#include <thrust/device_vector.h>

namespace kmeans {
namespace detail {
void Read_Center(int k,int d,thrust::device_vector<double>& centroids);
void Save_Center(d,k,thrust::host_vertor<double>&centroids,int index);
void find_centroids(int n, int d, int k,
                    thrust::device_vector<double>& data,
                    thrust::device_vector<int>& labels,
                    thrust::device_vector<double>& centroids,
                    thrust::device_vector<int>& range,
                    thrust::device_vector<int>& indices,
                    thrust::device_vector<int>& counts);


}
}

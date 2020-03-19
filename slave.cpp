/*************************************************************************
	> File Name: slave.cpp
	> Author: 
	> Mail: 
	> Created Time: Fri 28 Feb 2020 07:45:11 PM CST
 ************************************************************************/

#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <algorithm>
#include <math.h>
#include <string.h>
#include <fstream>
#include <unistd.h>

using namespace std;

const double INF= 1e20;//精细度
const int MAXD = 1000;//维度
const int MAXN = 1000;//点数目
const int MAXC = 50;//Cluster类别数

struct aCluster
{
    double Center[MAXD];//类的中心
    int Number = 0;//类中包含的样本point数目
    int Member[MAXN];//类中包含的样本point的index
    //double Err;//我想同意使用一个err
};
class S_Kmeans{
    private:
    double Point[MAXN][MAXD];//slave必须要保存所有它拥有的点的所有数值
    struct aCluster All_Cluster[MAXN];//中心集合
    int Belong[MAXN];//该点属于的类的下标
    double PointDistance[MAXN];//该点到所有类的最小距离

    public:
    int Cluster_Num;//类的个数
    int Point_Num;//样本数
    int Point_Dimension;//样本属性维度
    int Slave_Num;//分片数目
    int Slave_Index;//该分片序号
    int Slave_Point_Num;//该分片拥有的点数目
    bool Init();
    bool ReadData();//读取全部的样本点
    int Mapper();//进行分片计算
    double Distance(int index,int j);//根据样本下标计算该样本距离j类中心的距离
    int Combiner();//汇总该中心的各个维度总距离
    int Reducer();//求该类各个维度的中心值
};
bool S_Kmeans::Init()
{
    double n = (double)Point_Num;
    int every_points = ceil(n/Slave_Num);
    if(!(Point_Num % Slave_Num)){
        Slave_Point_Num = every_points;
    }
    if((Point_Num % Slave_Num )&&(Slave_Index == (Slave_Num -1))){
        Slave_Point_Num = Point_Num - (Slave_Index * every_points);
    }
    memset(Belong,0,sizeof(int)*MAXN);
    memset(PointDistance,0,sizeof(double)*MAXN);
    return true;
}
bool S_Kmeans::ReadData()
{
    //读取本split数据
    std::string filename = "splitdata_";
    std::string number = std::to_string(Slave_Index);
    filename += number;
    filename += ".txt";
    ifstream infile;
    infile.open(filename);
    for(int i = 0;i < Slave_Point_Num;i++){
        for(int j = 0;j < Point_Dimension;j++){
            infile >> Point[i][j];
        }
    }
    infile.close();
    std::cout << "slave"<<Slave_Index <<": read "<< filename <<" is ok..."<<std::endl;
    //读取tempcenter所有中心值
    filename = "tempcenter.txt";
    infile.open(filename);
    for(int i = 0;i < Cluster_Num;i++){
        for(int j = 0;j < Point_Dimension;j++){
            infile >> All_Cluster[i].Center[j];
        }
    }
    infile.close();
    return true;
}

int S_Kmeans::Mapper()
{   //计算本split数据到所有中心的最小距离及属于哪一类
    for(int i = 0;i < Point_Num;i++){
        int index = 0;
        double dis = INF;//这里有问题，不应该每次都是INF,应该记录每个point的最小值
        for(int j = 0;j < Cluster_Num;j++){
            if(Distance(i,j) < dis){
                dis = Distance(i,j);
                index = j;
            }
        }
        if(index == Cluster_Index){
            Slave_Acluster.Member[Slave_Acluster.Number++] = i;
            std::cout << "Point " << i << " belong to " << Cluster_Index << " ... " << std::endl;
        }
    }
    return 0;
}

double S_Kmeans::Distance(int p,int c)
{
    double dis = 0.0;
    for(int j = 0;j < Point_Dimension;j++){
        dis += (Point[p][j]-All_Cluster[c].Center[j])*(Point[p][j]-All_Cluster[c].Center[j]);
    }
    return sqrt(dis);
}

int S_Kmeans::Combiner()
{
    memset(Tempcenter,0,sizeof(Tempcenter));
    for(int k = 0;k < Point_Dimension;k++){
        for(int j = 0 ;j < Slave_Acluster.Number;j++){
            Tempcenter[k] += Point[j][k];
        }
    }
    return 0;
}

int S_Kmeans::Reducer()
{
    for(int i = 0;i < Point_Dimension;i++){
        Tempcenter[i] /= Slave_Acluster.Number;
    }
    std::string filename = "tempdata_";
    std::string number = std::to_string(Cluster_Index);
    filename += number;
    filename += ".txt";
    ofstream outfile;
    outfile.open(filename);
    for(int i = 0;i < Point_Dimension;i++){
        outfile << Tempcenter[i];
        outfile << " ";
    }
    return 0;
}

int main(int argc,char* argv[])
{
    for(int i = 0;i < argc;i++){
        std::cout << "param "<< i << " = "<<argv[i] << std::endl;
    }
    S_Kmeans *kmeans = new S_Kmeans();
    kmeans->Cluster_Num = atoi(argv[1]);
    kmeans->Point_Num = atoi(argv[2]);
    kmeans->Point_Dimension = atoi(argv[3]);
    kmeans->Slave_Num = atoi(argv[4]);
    kmeans->Slave_Index = atoi(argv[5]);
    std::cout << "Slave Cluster_Num = " << kmeans->Cluster_Num << std::endl;
    std::cout << "Slave Point_Num = " << kmeans->Point_Num << std::endl;
    std::cout << "Slave Point_Dimension = " << kmeans->Point_Dimension << std::endl;
    std::cout << "Slave Slave_Num = " << kmeans->Slave_Num << std::endl;
    std::cout << "Slave Slave_Index = " << kmeans->Slave_Index << std::endl;
    kmeans -> Init();
    kmeans -> ReadData();
    kmeans -> Mapper();
    kmeans -> Combiner();
    kmeans -> Reducer();
    return 0;
}

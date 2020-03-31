
/**
 * Copyright 1993-2012 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 */

#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <algorithm>
#include <string.h>
#include <fstream>
#include <unistd.h>
#include <math.h>
using namespace std;

const double INF=1e20;
const int MAXD = 1000;//最高维度数
const int MAXN = 1000;//最大样本点数
const int MAXC = 50;//类的最大个数


struct aCluster//类
{
    double Center[MAXD];//类的中心
    int Number;//类中包含的样本point数目
    int Member[MAXN];//类中包含的样本point的index
    //double Err; 分布式再启用此变量,想着所有类公用一个Err
};

class D_K_Means
{
    private:
    //注意：数组较大时，尽量使用new，否则会出现Segmentation fault (core dumped)错误。
    double Point[MAXN][MAXD];//第i个样本点的第j个属性
    aCluster Cluster[MAXC];//所有类
    aCluster TempCluster[MAXC];//临时存放类的中心

    public:
    int Cluster_Num;//类的个数
    int Point_Num;//点的个数
    int Point_Dimension;//样本属性维度
    int Slave_Num;//确定分片数目
    bool ReadData();//读取初始数据
    bool SplitData();//点数据分片存储
    int Init();//初始化K类的中心
    bool TempWrite();//将一轮迭代结束后的结果写入临时文件
    int Write_Result();//输出结果

};
bool D_K_Means::SplitData(){
    //确定每个分片的点数
    std:cout << "This is SplitData ..." << std::endl;
    double n = (double)Point_Num;
    std::cout << "Always n = " << n << "; Slave_Num = " << Slave_Num << std::endl;
    int every_points = ceil(n/Slave_Num);//除最后一片，每片拿走every_points个数
    std::cout << "There are "<< every_points <<" points in one split..."<<std::endl;
    int count = 0;
    for(int i = 0;i < Slave_Num;i++){
        std::string number = std::to_string(i);
        std::string filename = "/data/006zzy/files/splitdata_";
        filename += number;
        filename += ".txt";
        ofstream outfile;
        outfile.open(filename);
        std::cout << "In split there is creating filename = " << filename << std::endl;
        int changes_number= 0;
        while(1){
            for(int j = 0;j < Point_Dimension;j++) {
                outfile << Point[count][j];
                outfile << " ";
            }
            changes_number ++;
            count ++;
            if(!(count % every_points)) break;//满足一个完整的split的数据个数
            if(count == Point_Num) break;//所有点都划分完毕
        }
        std::cout << filename << " has " << changes_number << "numbers ..." << std::endl;
    }
    std::cout << "SplitData over ..." << std::endl;
    return true;

}
bool D_K_Means::ReadData()//读取数据
{
    ifstream infile;
    infile.open("/data/006zzy/files/data.txt");
    infile >>Point_Num;
    infile >>Point_Dimension;
    infile >>Cluster_Num;

    for(int i = 0;i < Point_Num;i++)
    {
        for(int j = 0;j < Point_Dimension;j++)
        {
            infile >> Point[i][j];//读取第i个样本点的第j个属性
        }
    }
    infile.close();
    std::cout << "read data.txt is ok..."<<std::endl;
    Init();//初始化K个类的中心
    return TempWrite();//将所有类的中心作为第一轮迭代前的数据写入临时文件
}

int D_K_Means::Init()//初始化K个类的中心
{
    srand(time(NULL));//抛随机种子
    for(int i = 0;i < Cluster_Num;i++)
    {
        int r = rand() % Point_Num;//随机选择所有样本点中的一个作为第i类的中心
        //Cluster[i].Member[0]=r;
        for(int j = 0;j < Point_Dimension;j++)
        {
            Cluster[i].Center[j] = Point[r][j];
        }
    }
    std::cout <<"tempcenter rand choice is ok..."<<std::endl;
    return 0;
}


//该函数只能在master上进行，用于计算误差，以便得到新的聚类中心，同时确定是否需要继续迭代,这块在master里面将来需要改动
bool D_K_Means::TempWrite()//将所有类的中心写入临时文件
{
    std::cout << "This is TempWrite ..." << std::endl;
    double ERR = 0.0;
    for(int i = 0;i < Cluster_Num;i++){
        memset(TempCluster[i].Center,0,sizeof(TempCluster[i].Center));
    }
    //tempdata,存放各个slave计算出来的中心值文件要么不存在，要么已经由各个slave计算并保存于文件，因此，这里使用读文件方式读取tempdata里面已经计算出来的最新的中心值
    for(int i = 0 ; i < Slave_Num;i++){
        std::string filename = "/data/006zzy/files/tempdata_";
        std::string number = std::to_string(i);
        filename += number;
        filename += ".txt";
        ifstream infile;
        infile.open(filename);
        if(!infile){
            //在Init中执行TempWrit函数,Slave还没启动
            std::cout << filename <<" is not exist ..." << std::endl;
            for(int i = 0;i < Cluster_Num;i++){
                for(int j = 0; j < Point_Dimension;j++){
                    TempCluster[i].Center[j] = 0;
                }
            }
            goto Writenewcenter;
        }else{
            double tempdata;
            std::cout << "Master gets file = "<< filename << std::endl;
            for(int i = 0;i < Cluster_Num;i++){
                for(int j = 0;j < Point_Dimension;j++){
                    infile >> tempdata;
                    TempCluster[i].Center[j] += tempdata;
                }
            }
        }
        infile.close();
    }
    //汇聚各个Slave后求平均中心值就是TempClustermZ,第一次TempCluster都是0
    for(int i = 0;i < Cluster_Num;i++){
        for(int j = 0;j < Point_Dimension;j++){
            TempCluster[i].Center[j] /= Slave_Num;
        }
    }
    //输出TempCluster的临时值
    //临时值在第二次就应该是一样的了。因为每次slave迭代都是当前点的平均值
    //这个暂时有问题，问一下老师
    for(int i = 0;i < Cluster_Num;i++)//更新Cluster[i].Center同时计算与上一次迭代的变化（取2范数的平方）
    {
        for(int j = 0;j<Point_Dimension;j++)
        {
            double temperr = TempCluster[i].Center[j]-Cluster[i].Center[j];
            //if(temperr == 0) std::cout << "tempcenter = center " << std::endl;
            ERR += (temperr * temperr);
            Cluster[i].Center[j] = TempCluster[i].Center[j];
        }
    }
Writenewcenter:
    std::string filename = "/data/006zzy/files/tempcenter.txt";//把新得到的center放入文件供slave读
    ofstream outfile;
    outfile.open(filename);
    for(int i = 0;i < Cluster_Num;i++){
        for(int j = 0;j < Point_Dimension;j++){
            outfile << Cluster[i].Center[j];
            outfile << " ";
        }
        outfile << std::endl;
    }
    outfile.close();
    std::cout << "ERR = " << ERR << std::endl;
    std::cout << "TempWrite over ..." << std::endl;
    if(ERR < 0.1) return true;//精细度是0.1
    else return false;
}

int  D_K_Means::Write_Result()//输出结果
{
    //std::cout << "This is Write_Result ..." << std::endl;
    ofstream outfile;
    outfile.open("/data/006zzy/files/Result.txt");
    for(int i = 0;i < Cluster_Num;i++){
        for(int j = 0;j < Point_Dimension;j++){
            outfile << Cluster[i].Center[j];
            if(j == Point_Dimension -1) break;
            else outfile << " " ;
        }
        std::cout << std::endl;
    }
    outfile.close();
    std::cout <<"Write_Result over ..." << std::endl;
    return  0;
}

int FrameWork(D_K_Means *km)
{
    bool converged = false;
    int times = 1;
    km->Slave_Num = 4;//slave分为4片，即数据分为4片
    km->ReadData();
    km->SplitData();
    std::cout << "master has cluster number = "<< km->Cluster_Num<<std::endl;
    int count = 0;
    while(converged == false){
    	//if(count == 2) break;
        std::cout << "**********************************************************************"<<std::endl;
        std::cout << "the " << count++ << " start slaves"<<std::endl;
        std::cout << "**********************************************************************"<<std::endl;
        for(int index = 0; index < km->Slave_Num;index++){
            std::string command_2 = "/data/006zzy/nsight-workspace/Slave/Debug/Slave ";
            std::string number = std::to_string(km->Cluster_Num);
            command_2 += " ";command_2 += number;//CLuster_Num
            number = std::to_string(km->Point_Num);
            command_2 += " ";command_2 += number;//Point_Num
            number = std::to_string(km->Point_Dimension);
            command_2 += " ";command_2 += number;//Point_Dimension
            number = std::to_string(km->Slave_Num);
            command_2 += " ";command_2 += number;//Slave_Num
            number = std::to_string(index);
            command_2 += " ";command_2 += number;//index
            std::cout << index << " slave start success..."<<std::endl;
            system(command_2.c_str());
        }
        sleep(2);
        converged = km -> TempWrite();
    }
    km->Write_Result();//把结果写入文件
    return 0;
}


int main() {
    std::cout << "GPU distribute Kmeans " << std::endl;
    D_K_Means *km = new D_K_Means();
    FrameWork(km);
    return 0;
}

#include <thrust/device_vector.h>

#include "kmeans.h"
#include "timer.h"
#include "util.h"
#include "cuda.h"

#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <algorithm>
#include <string.h>
#include <fstream>
#include <unistd.h>
using namespace std;

const double INF=1e20;
const int MAXD = 1000;//���ά����
const int MAXN = 1000;//�����������
const int MAXC = 50;//���������


struct aCluster//��
{
    double Center[MAXD];//�������
    int Number;//���а���������point��Ŀ
    int Member[MAXN];//���а���������point��index
    //double Err; �ֲ�ʽ�����ô˱���,���������๫��һ��Err
};

class D_K_Means
{
    private:
    //ע�⣺����ϴ�ʱ������ʹ��new����������Segmentation fault (core dumped)����
    double Point[MAXN][MAXD];//��i��������ĵ�j������
    aCluster Cluster[MAXC];//������
    aCluster TempCluster[MAXC];//��ʱ����������

    public:
    int Cluster_Num;//��ĸ���
    int Point_Num;//��ĸ���
    int Point_Dimension;//��������ά��
    int Slave_Num;//ȷ����Ƭ��Ŀ
    bool ReadData();//��ȡ��ʼ����
    bool SplitData();//�����ݷ�Ƭ�洢
    int Init();//��ʼ��K�������
    bool TempWrite();//��һ�ֵ���������Ľ��д����ʱ�ļ�
    int Write_Result();//������

};
bool D_K_Means::SplitData(){
    //ȷ��ÿ����Ƭ�ĵ���
    std:cout << "This is SplitData ..." << std::endl;
    double n = (double)Point_Num;
    std::cout << "Always n = " << n << "; Slave_Num = " << Slave_Num << std::endl;
    int every_points = ceil(n/Slave_Num);//�����һƬ��ÿƬ����every_points����
    std::cout << "There are "<< every_points <<" points in one split..."<<std::endl;
    int count = 0;
    for(int i = 0;i < Slave_Num;i++){
        std::string number = std::to_string(i);
        std::string filename = "splitdata_";
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
            if(!(count % every_points)) break;//����һ��������split�����ݸ���
            if(count == Point_Num) break;//���е㶼�������
        }
        std::cout << filename << " has " << changes_number << "numbers ..." << std::endl;
    }
    std::cout << "SplitData over ..." << std::endl;
    return true;

}
bool D_K_Means::ReadData()//��ȡ����
{
    ifstream infile;
    infile.open("data.txt");
    infile >>Point_Num;
    infile >>Point_Dimension;
    infile >>Cluster_Num;

    for(int i = 0;i < Point_Num;i++)
    {
        for(int j = 0;j < Point_Dimension;j++)
        {
            infile >> Point[i][j];//��ȡ��i��������ĵ�j������
        }
    }
    infile.close();
    std::cout << "read data.txt is ok..."<<std::endl;
    Init();//��ʼ��K���������
    TempWrite();//���������������Ϊ��һ�ֵ���ǰ������д����ʱ�ļ�
}

int D_K_Means::Init()//��ʼ��K���������
{
    srand(time(NULL));//���������
    for(int i = 0;i < Cluster_Num;i++)
    {
        int r = rand() % Point_Num;//���ѡ�������������е�һ����Ϊ��i�������
        //Cluster[i].Member[0]=r;
        for(int j = 0;j < Point_Dimension;j++)
        {
            Cluster[i].Center[j] = Point[r][j];
        }
    }
    std::cout <<"tempcenter rand choice is ok..."<<std::endl;
    return 0;
}


//�ú���ֻ����master�Ͻ��У����ڼ������Ա�õ��µľ������ģ�ͬʱȷ���Ƿ���Ҫ��������,�����master���潫����Ҫ�Ķ�
bool D_K_Means::TempWrite()//�������������д����ʱ�ļ�
{
    std::cout << "This is TempWrite ..." << std::endl;
    double ERR = 0.0;
    for(int i = 0;i < Cluster_Num;i++){
        memset(TempCluster[i].Center,0,sizeof(TempCluster[i].Center));
    }
    //tempdata,��Ÿ���slave�������������ֵ�ļ�Ҫô�����ڣ�Ҫô�Ѿ��ɸ���slave���㲢�������ļ�����ˣ�����ʹ�ö��ļ���ʽ��ȡtempdata�����Ѿ�������������µ�����ֵ
    for(int i = 0 ; i < Slave_Num;i++){
        std::string filename = "tempdata_";
        std::string number = std::to_string(i);
        filename += number;
        filename += ".txt";
        ifstream infile;
        infile.open(filename);
        if(!infile){
            //��Init��ִ��TempWrit����,Slave��û����
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
    //��۸���Slave����ƽ������ֵ����TempClustermZ,��һ��TempCluster����0
    for(int i = 0;i < Cluster_Num;i++){
        for(int j = 0;j < Point_Dimension;j++){
            TempCluster[i].Center[j] /= Slave_Num;
        }
    }
    //���TempCluster����ʱֵ
    //��ʱֵ�ڵڶ��ξ�Ӧ����һ�����ˡ���Ϊÿ��slave�������ǵ�ǰ���ƽ��ֵ
    //�����ʱ�����⣬��һ����ʦ
    for(int i = 0;i < Cluster_Num;i++)//����Cluster[i].Centerͬʱ��������һ�ε����ı仯��ȡ2������ƽ����
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
    std::string filename = "tempcenter.txt";//���µõ���center�����ļ���slave��
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
    if(ERR < 0.1) return true;//��ϸ����0.1
    else return false;
}

int  D_K_Means::Write_Result()//������
{
    std::cout << "This is Write_Result ..." << std::endl;
    ofstream outfile;
    outfile.open("Result.txt");
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
    km->Slave_Num = 4;//slave��Ϊ4Ƭ�������ݷ�Ϊ4Ƭ
    km->ReadData();
    km->SplitData();
    std::cout << "master has cluster number = "<< kmeans->Cluster_Num<<std::endl;
    int count = 0;
    while(converged == false){
        std::cout << "**********************************************************************"<<std::endl;
        std::cout << "the " << count++ << std::endl;
        std::cout << "**********************************************************************"<<std::endl;
        for(int index = 0; index < kmeans->Slave_Num;index++){
            std::string command = "./slave ";
            std::string number = std::to_string(kmeans->Cluster_Num);
            command += " ";command += number;//CLuster_Num
            number = std::to_string(kmeans->Point_Num);
            command += " ";command += number;//Point_Num
            number = std::to_string(kmeans->Point_Dimension);
            command += " ";command += number;//Point_Dimension
            number = std::to_string(kmeans->Slave_Num);
            command += " ";command += number;//Slave_Num
            number = std::to_string(index);
            command += " ";command += number;//index
            std::cout << index << " slave start success..."<<std::endl;
            system(command.c_str());
        }
        sleep(2);
        converged = km -> TempWrite();
    }
    km->Write_Result();//�ѽ��д���ļ�
    return 0;
}


int main() {
    std::cout << "GPU distribute Kmeans " << std::endl;
    kmeans::timer t;
    t.start();
    D_K_Means *km = new D_K_Means();
    FrameWork(km);
    float time = t.stop();
    std::cout << "use time: " << time/1000.0 << " s" << std::endl;
    return 0;
}

################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../centroids.cu \
../kmeans.cu \
../labels.cu \
../slavemain.cu \
../timer.cu 

OBJS += \
./centroids.o \
./kmeans.o \
./labels.o \
./slavemain.o \
./timer.o 

CU_DEPS += \
./centroids.d \
./kmeans.d \
./labels.d \
./slavemain.d \
./timer.d 


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/cub-1.8.0 -G -g -O0 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_75,code=sm_75  -odir "." -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/cub-1.8.0 -G -g -O0 --compile --relocatable-device-code=false -gencode arch=compute_35,code=compute_35 -gencode arch=compute_75,code=compute_75 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_75,code=sm_75  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



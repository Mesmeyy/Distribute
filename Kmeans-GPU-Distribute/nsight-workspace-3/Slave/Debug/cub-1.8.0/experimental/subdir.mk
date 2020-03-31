################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../cub-1.8.0/experimental/histogram_compare.cu \
../cub-1.8.0/experimental/spmv_compare.cu 

OBJS += \
./cub-1.8.0/experimental/histogram_compare.o \
./cub-1.8.0/experimental/spmv_compare.o 

CU_DEPS += \
./cub-1.8.0/experimental/histogram_compare.d \
./cub-1.8.0/experimental/spmv_compare.d 


# Each subdirectory must supply rules for building sources it contributes
cub-1.8.0/experimental/%.o: ../cub-1.8.0/experimental/%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/Slave/cub-1.8.0 -G -g -O0 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_75,code=sm_75  -odir "cub-1.8.0/experimental" -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/Slave/cub-1.8.0 -G -g -O0 --compile --relocatable-device-code=false -gencode arch=compute_35,code=compute_35 -gencode arch=compute_75,code=compute_75 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_75,code=sm_75  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



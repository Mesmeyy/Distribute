################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../cub-1.8.0/examples/block/example_block_radix_sort.cu \
../cub-1.8.0/examples/block/example_block_reduce.cu \
../cub-1.8.0/examples/block/example_block_scan.cu \
../cub-1.8.0/examples/block/reduce_by_key.cu 

OBJS += \
./cub-1.8.0/examples/block/example_block_radix_sort.o \
./cub-1.8.0/examples/block/example_block_reduce.o \
./cub-1.8.0/examples/block/example_block_scan.o \
./cub-1.8.0/examples/block/reduce_by_key.o 

CU_DEPS += \
./cub-1.8.0/examples/block/example_block_radix_sort.d \
./cub-1.8.0/examples/block/example_block_reduce.d \
./cub-1.8.0/examples/block/example_block_scan.d \
./cub-1.8.0/examples/block/reduce_by_key.d 


# Each subdirectory must supply rules for building sources it contributes
cub-1.8.0/examples/block/%.o: ../cub-1.8.0/examples/block/%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/Slave/cub-1.8.0 -G -g -O0 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_75,code=sm_75  -odir "cub-1.8.0/examples/block" -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/Slave/cub-1.8.0 -G -g -O0 --compile --relocatable-device-code=false -gencode arch=compute_35,code=compute_35 -gencode arch=compute_75,code=compute_75 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_75,code=sm_75  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



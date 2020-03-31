################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../cub-1.8.0/test/link_a.cu \
../cub-1.8.0/test/link_b.cu \
../cub-1.8.0/test/test_allocator.cu \
../cub-1.8.0/test/test_block_histogram.cu \
../cub-1.8.0/test/test_block_load_store.cu \
../cub-1.8.0/test/test_block_radix_sort.cu \
../cub-1.8.0/test/test_block_reduce.cu \
../cub-1.8.0/test/test_block_scan.cu \
../cub-1.8.0/test/test_device_histogram.cu \
../cub-1.8.0/test/test_device_radix_sort.cu \
../cub-1.8.0/test/test_device_reduce.cu \
../cub-1.8.0/test/test_device_reduce_by_key.cu \
../cub-1.8.0/test/test_device_run_length_encode.cu \
../cub-1.8.0/test/test_device_scan.cu \
../cub-1.8.0/test/test_device_select_if.cu \
../cub-1.8.0/test/test_device_select_unique.cu \
../cub-1.8.0/test/test_grid_barrier.cu \
../cub-1.8.0/test/test_iterator.cu \
../cub-1.8.0/test/test_warp_reduce.cu \
../cub-1.8.0/test/test_warp_scan.cu 

CPP_SRCS += \
../cub-1.8.0/test/link_main.cpp 

OBJS += \
./cub-1.8.0/test/link_a.o \
./cub-1.8.0/test/link_b.o \
./cub-1.8.0/test/link_main.o \
./cub-1.8.0/test/test_allocator.o \
./cub-1.8.0/test/test_block_histogram.o \
./cub-1.8.0/test/test_block_load_store.o \
./cub-1.8.0/test/test_block_radix_sort.o \
./cub-1.8.0/test/test_block_reduce.o \
./cub-1.8.0/test/test_block_scan.o \
./cub-1.8.0/test/test_device_histogram.o \
./cub-1.8.0/test/test_device_radix_sort.o \
./cub-1.8.0/test/test_device_reduce.o \
./cub-1.8.0/test/test_device_reduce_by_key.o \
./cub-1.8.0/test/test_device_run_length_encode.o \
./cub-1.8.0/test/test_device_scan.o \
./cub-1.8.0/test/test_device_select_if.o \
./cub-1.8.0/test/test_device_select_unique.o \
./cub-1.8.0/test/test_grid_barrier.o \
./cub-1.8.0/test/test_iterator.o \
./cub-1.8.0/test/test_warp_reduce.o \
./cub-1.8.0/test/test_warp_scan.o 

CU_DEPS += \
./cub-1.8.0/test/link_a.d \
./cub-1.8.0/test/link_b.d \
./cub-1.8.0/test/test_allocator.d \
./cub-1.8.0/test/test_block_histogram.d \
./cub-1.8.0/test/test_block_load_store.d \
./cub-1.8.0/test/test_block_radix_sort.d \
./cub-1.8.0/test/test_block_reduce.d \
./cub-1.8.0/test/test_block_scan.d \
./cub-1.8.0/test/test_device_histogram.d \
./cub-1.8.0/test/test_device_radix_sort.d \
./cub-1.8.0/test/test_device_reduce.d \
./cub-1.8.0/test/test_device_reduce_by_key.d \
./cub-1.8.0/test/test_device_run_length_encode.d \
./cub-1.8.0/test/test_device_scan.d \
./cub-1.8.0/test/test_device_select_if.d \
./cub-1.8.0/test/test_device_select_unique.d \
./cub-1.8.0/test/test_grid_barrier.d \
./cub-1.8.0/test/test_iterator.d \
./cub-1.8.0/test/test_warp_reduce.d \
./cub-1.8.0/test/test_warp_scan.d 

CPP_DEPS += \
./cub-1.8.0/test/link_main.d 


# Each subdirectory must supply rules for building sources it contributes
cub-1.8.0/test/%.o: ../cub-1.8.0/test/%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/Slave/cub-1.8.0 -G -g -O0 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_75,code=sm_75  -odir "cub-1.8.0/test" -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/Slave/cub-1.8.0 -G -g -O0 --compile --relocatable-device-code=false -gencode arch=compute_35,code=compute_35 -gencode arch=compute_75,code=compute_75 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_75,code=sm_75  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

cub-1.8.0/test/%.o: ../cub-1.8.0/test/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/Slave/cub-1.8.0 -G -g -O0 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_75,code=sm_75  -odir "cub-1.8.0/test" -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/Slave/cub-1.8.0 -G -g -O0 --compile  -x c++ -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



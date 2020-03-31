################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../cub-1.8.0/examples/device/example_device_partition_flagged.cu \
../cub-1.8.0/examples/device/example_device_partition_if.cu \
../cub-1.8.0/examples/device/example_device_radix_sort.cu \
../cub-1.8.0/examples/device/example_device_reduce.cu \
../cub-1.8.0/examples/device/example_device_scan.cu \
../cub-1.8.0/examples/device/example_device_select_flagged.cu \
../cub-1.8.0/examples/device/example_device_select_if.cu \
../cub-1.8.0/examples/device/example_device_select_unique.cu \
../cub-1.8.0/examples/device/example_device_sort_find_non_trivial_runs.cu 

OBJS += \
./cub-1.8.0/examples/device/example_device_partition_flagged.o \
./cub-1.8.0/examples/device/example_device_partition_if.o \
./cub-1.8.0/examples/device/example_device_radix_sort.o \
./cub-1.8.0/examples/device/example_device_reduce.o \
./cub-1.8.0/examples/device/example_device_scan.o \
./cub-1.8.0/examples/device/example_device_select_flagged.o \
./cub-1.8.0/examples/device/example_device_select_if.o \
./cub-1.8.0/examples/device/example_device_select_unique.o \
./cub-1.8.0/examples/device/example_device_sort_find_non_trivial_runs.o 

CU_DEPS += \
./cub-1.8.0/examples/device/example_device_partition_flagged.d \
./cub-1.8.0/examples/device/example_device_partition_if.d \
./cub-1.8.0/examples/device/example_device_radix_sort.d \
./cub-1.8.0/examples/device/example_device_reduce.d \
./cub-1.8.0/examples/device/example_device_scan.d \
./cub-1.8.0/examples/device/example_device_select_flagged.d \
./cub-1.8.0/examples/device/example_device_select_if.d \
./cub-1.8.0/examples/device/example_device_select_unique.d \
./cub-1.8.0/examples/device/example_device_sort_find_non_trivial_runs.d 


# Each subdirectory must supply rules for building sources it contributes
cub-1.8.0/examples/device/%.o: ../cub-1.8.0/examples/device/%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/Slave/cub-1.8.0 -G -g -O0 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_75,code=sm_75  -odir "cub-1.8.0/examples/device" -M -o "$(@:%.o=%.d)" "$<"
	/usr/local/cuda-10.1/bin/nvcc -I/data/006zzy/nsight-workspace/Slave/cub-1.8.0 -G -g -O0 --compile --relocatable-device-code=false -gencode arch=compute_35,code=compute_35 -gencode arch=compute_75,code=compute_75 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_75,code=sm_75  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



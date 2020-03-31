
/**
 * Copyright 1993-2012 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 */
#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include "timer.h"

namespace kmeans {

timer::timer() {
    cudaEventCreate(&m_start);
    cudaEventCreate(&m_stop);
}

timer::~timer() {
    cudaEventDestroy(m_start);
    cudaEventDestroy(m_stop);
}

void timer::start() {
    cudaEventRecord(m_start, 0);
}

float timer::stop() {
    float time;
    cudaEventRecord(m_stop, 0);
    cudaEventSynchronize(m_stop);
    cudaEventElapsedTime(&time, m_start, m_stop);
    return time;
}

}

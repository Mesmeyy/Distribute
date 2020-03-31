/*
 * timer.h
 *
 *  Created on: Mar 28, 2020
 *      Author: root
 */

#ifndef TIMER_H_
#define TIMER_H_
#include "timer.h"
#include <cuda.h>


#pragma once
namespace kmeans {

struct timer {
    timer();
    ~timer();
    void start();
    float stop();
private:
    cudaEvent_t m_start, m_stop;
};


}


#endif /* TIMER_H_ */

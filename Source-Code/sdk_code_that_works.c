/******************************************************************************
*
Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
*
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
*
Use of the Software is limited solely to applications:
(a) running on a Xilinx device, or
(b) that interact with a Xilinx device through a bus or interconnect.
*
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*
Except as contained in this notice, the name of the Xilinx shall not be used
in advertising or otherwise to promote the sale, use or other dealings in
t
his Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

//For these addresses, only writes to RSTN_ADDR LSB controls reset, Read processor_done LSB
#define RSTN_ADDR ((volatile unsigned int*) XPAR_SINGLE_CYCLE_0_S00_AXI_BASEADDR)

#define PROCESSOR_DONE_ADDR ((volatile unsigned int*)(XPAR_SINGLE_CYCLE_0_S00_AXI_BASEADDR + 4))

#define INSTRUCTION_MEM_ADDR ((volatile unsigned int*) XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR)

#define REG_FILE_ADDR ((volatile unsigned int*) XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR)

volatile unsigned int* rst_n = RSTN_ADDR;

volatile unsigned int* processor_done = PROCESSOR_DONE_ADDR;

volatile unsigned int* program_counter = PROCESSOR_DONE_ADDR;

volatile unsigned int* instr_mem = INSTRUCTION_MEM_ADDR;

volatile unsigned int* reg_file = REG_FILE_ADDR;

unsigned int instructions[] = {0x00000013, 0x7ff00093, 0x00400113, 0x004091b3, 0x0040d233, 0x80000293, 0x00000000};

int main()
{
    init_platform();

    print("Hello World\n\r");

    //First, put the system in reset (assert rst_n[0] = 0)

    rst_n[0] = 0;
    xil_printf("rst_n during reset =: %d\r\n", rst_n[0]);

    //Read the processor_done status (should be 0)
    xil_printf("processor_done status before instructions: %d\r\n", processor_done[0]);
    //Load the instruction memory with the code
    int i;
    xil_printf("Processor done address: %p\r\n", processor_done);
    for(i = 0; i < 1024; i++){
        instr_mem[i] = 0x00000013;
    }
    i = 0;

    for(i = 0; i < sizeof(instructions)/sizeof(int); i++){
    	instr_mem[i] = instructions[i];
    	xil_printf("instr_mem[%d] = 0x%x\r\n", i, instr_mem[i]);
    }
    print("\r\n");
//    instr_mem[2] = 0x00000013;
//    instr_mem[2] = 0x00000000;

//    xil_printf("first Instruction: 0x%x\r\n", instr_mem[0]);
//    xil_printf("second Instruction: 0x%x\r\n", instr_mem[1]);
//    xil_printf("third Instruction: 0x%x\r\n", instr_mem[2]);
//    xil_printf("fourth Instruction: 0x%x\r\n", instr_mem[3]);
//    xil_printf("fifth Instruction: 0x%x\r\n", instr_mem[4]);
//    instr_mem[2] = 0x00000000;
    rst_n[0] = 1;
    while((processor_done[0] & 0x1) != 1){
        xil_printf("Processor_done = %d\r\n", processor_done[0]);
        print("instr_mem != 0");
        xil_printf("i = %d\r\n", i);
        i = (i + 1) % 1024;
    }
//    xil_printf("Processor_done = 0x%x\r\n", processor_done[0]);
//    xil_printf("i = %d\r\n\n", i);
//
//    //De-assert the reset
//
//    xil_printf("rst_n after reset =: %d\r\n", rst_n[0]);
//
    i = 0;
    while(instr_mem[i] != 0){
    	xil_printf("instr_mem[%d] = 0x%x\r\n", i, instr_mem[i]);
    	i++;
    }
//    print("\r\n");
//
    xil_printf("instr_mem[%d] = 0x%x\r\n", i, instr_mem[i]);
    i = 0;
    for(i = 1; i <= 5; i++){
    	xil_printf("reg_file[%d] = 0x%x\r\n", i, reg_file[i]);
    }
//    //Wait until processor_done status == 1
////    while(processor_done[0] != 1){
////        xil_printf("Program counter: 0x%x\r\n", (*processor_done & 0x1E) >> 1);
////    }
//
//    print("Processor done == 1!!!!!!\r\n");
//    xil_printf("Program counter: 0x%x\r\n", (*processor_done & 0x1E) >> 1);

    while(1){
//        xil_printf("Program counter: 0x%x\r\n", (*processor_done & 0x1E) >> 1);
//        print("We done!!!\r\n");
    }
    //If that's the case, read register file

    cleanup_platform();
    return 0;
}

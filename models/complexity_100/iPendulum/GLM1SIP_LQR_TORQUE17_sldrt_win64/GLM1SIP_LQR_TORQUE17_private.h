/*
 * GLM1SIP_LQR_TORQUE17_private.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "GLM1SIP_LQR_TORQUE17".
 *
 * Model version              : 1.524
 * Simulink Coder version : 8.8 (R2015a) 09-Feb-2015
 * C source code generated on : Wed Apr 19 21:50:22 2017
 *
 * Target selection: rtwin.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef RTW_HEADER_GLM1SIP_LQR_TORQUE17_private_h_
#define RTW_HEADER_GLM1SIP_LQR_TORQUE17_private_h_
#include "rtwtypes.h"
#include "multiword_types.h"
#include "zero_crossing_types.h"
#define SET_PRFL_VEL                   0x4
#define CLR_STATUS                     0x6
#define AXIS_ON                        0x9
#define AXIS_OFF                       0xa
#define OPEN_LOOP                      0xc
#define LMTS_ON                        0xd
#define LMTS_OFF                       0xe
#define ABRUPT_STOP                    0x12
#define RESET                          0x13
#define ZERO_POS                       0x15
#define UPDATE                         0x16
#define SET_EX_OUTPUT                  0x28
#define SET_LMT_SENSE                  0x2c
#define SET_ENCODER_SENSE              0x2d
#define SET_1                          0x30
#define SET_2                          0x31
#define SET_3                          0x32
#define SET_4                          0x33
#define GET_EX_INPUT                   0x35
#define GET_STATUS                     0x36
#define SET_POS                        0x41
#define SET_VEL                        0x42
#define SET_ACC                        0x43
#define SET_MTR_CMD                    0x49
#define SET_KP                         0x4c
#define SET_KI                         0x4d
#define SET_KD                         0x4e
#define GET_ACTL_POS                   0xc2
#define GET_ENC_POS                    0xc6
#define GET_EX_OPT                     0xce
#define GET_ADC_DATA                   0xb6
#define CHECK_NUM                      0x475410b5
#define DATA_PORT0                     0x0
#define COMMAND_PORT                   0x4
#define STATUS_PORT                    0x4
#define READY_BUSY_BIT_MASK            0x8000
#define PI                             3.1415927

uint_T baseaddress, icount, findcard_tag, positive_limit[4], negative_limit[4];
long positive_limit_value[4], negative_limit_value[4];

#define DELAY_TIME                     icount=0; while((!( _inpd(baseaddress+STATUS_PORT)&READY_BUSY_BIT_MASK))&&(icount<6000)) icount++;
#define WritePort(command, data)       DELAY_TIME; _outpd(baseaddress+DATA_PORT0,data); _outpw(baseaddress+COMMAND_PORT,command); DELAY_TIME;
#define ReadPort(command, data)        DELAY_TIME; _outpw(baseaddress+COMMAND_PORT,command); DELAY_TIME; data= _inpd(baseaddress+DATA_PORT0);
#define ReadData(data)                 DELAY_TIME; data= _inpd(baseaddress + DATA_PORT0);

/* private model entry point functions */
extern void GLM1SIP_LQR_TORQUE17_derivatives(void);

#endif                                 /* RTW_HEADER_GLM1SIP_LQR_TORQUE17_private_h_ */

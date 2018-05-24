/*
 * PD2_data.c
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "PD2".
 *
 * Model version              : 1.563
 * Simulink Coder version : 8.8 (R2015a) 09-Feb-2015
 * C source code generated on : Fri Apr 21 12:49:51 2017
 *
 * Target selection: rtwin.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "PD2.h"
#include "PD2_private.h"

/* Block parameters (auto storage) */
P_PD2_T PD2_P = {
  2.0,                                 /* Mask Parameter: GetAxisPosition1_axis
                                        * Referenced by: '<S3>/Get Axis' Position1'
                                        */
  1.0,                                 /* Mask Parameter: GetAxisPosition_axis
                                        * Referenced by: '<S3>/Get Axis' Position'
                                        */
  1.0,                                 /* Mask Parameter: SetVoltage_back_cmd
                                        * Referenced by: '<S3>/Set Voltage'
                                        */
  20000.0,                             /* Mask Parameter: SetVoltage_back_pos
                                        * Referenced by: '<S3>/Set Voltage'
                                        */
  1.0,                                 /* Mask Parameter: GT400SVInitialization_openloop
                                        * Referenced by: '<Root>/GT400-SV Initialization'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S5>/Out1'
                                        */
  1.0,                                 /* Expression: 1
                                        * Referenced by: '<S5>/Constant'
                                        */
  3.1415926535897931,                  /* Expression: pi
                                        * Referenced by: '<S1>/Angle Ref.'
                                        */
  -0.0026179938779914941,              /* Expression: -(pi * 2.0 / 2400)
                                        * Referenced by: '<S3>/Angle Encoder'
                                        */
  -1.0,                                /* Expression: -1
                                        * Referenced by: '<S1>/Negative Feedback1'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S1>/Pos Ref.'
                                        */
  4.8E-6,                              /* Expression: 0.048/10000
                                        * Referenced by: '<S3>/Pos Encoder'
                                        */
  -1.0,                                /* Expression: -1
                                        * Referenced by: '<S1>/Negative Feedback'
                                        */
  -30.0,                               /* Expression: -30
                                        * Referenced by: '<Root>/Kxp'
                                        */
  -15.0,                               /* Expression: -15
                                        * Referenced by: '<Root>/Kxd'
                                        */
  65.0,                                /* Expression: 65
                                        * Referenced by: '<Root>/KtP'
                                        */
  10.0,                                /* Expression: 10
                                        * Referenced by: '<Root>/KtPd'
                                        */
  -1.0,                                /* Expression: -1
                                        * Referenced by: '<Root>/Negative Feedback'
                                        */
  3.1415926535897931,                  /* Expression: pi
                                        * Referenced by: '<S4>/Constant1'
                                        */
  0.17453292519943295,                 /* Expression: 10*pi/180
                                        * Referenced by: '<S4>/EntryAngle'
                                        */
  -60.0,                               /* Computed Parameter: Filter1_A
                                        * Referenced by: '<S3>/Filter1'
                                        */
  60.0,                                /* Computed Parameter: Filter1_C
                                        * Referenced by: '<S3>/Filter1'
                                        */
  1.0,                                 /* Expression: axis
                                        * Referenced by: '<S3>/Set Voltage'
                                        */
  0.19607843137254904,                 /* Expression: 1/5.1
                                        * Referenced by: '<S3>/Kxp1'
                                        */
  0.3490658503988659                   /* Expression: 20*pi/180
                                        * Referenced by: '<S4>/StopAngle'
                                        */
};

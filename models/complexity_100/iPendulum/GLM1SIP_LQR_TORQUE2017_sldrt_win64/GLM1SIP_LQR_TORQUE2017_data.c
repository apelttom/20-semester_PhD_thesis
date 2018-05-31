/*
 * GLM1SIP_LQR_TORQUE2017_data.c
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "GLM1SIP_LQR_TORQUE2017".
 *
 * Model version              : 1.522
 * Simulink Coder version : 8.8 (R2015a) 09-Feb-2015
 * C source code generated on : Thu Mar 23 19:47:55 2017
 *
 * Target selection: rtwin.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "GLM1SIP_LQR_TORQUE2017.h"
#include "GLM1SIP_LQR_TORQUE2017_private.h"

/* Block parameters (auto storage) */
P_GLM1SIP_LQR_TORQUE2017_T GLM1SIP_LQR_TORQUE2017_P = {
  2.0,                                 /* Mask Parameter: GetAxisPosition1_axis
                                        * Referenced by: '<S4>/Get Axis' Position1'
                                        */
  1.0,                                 /* Mask Parameter: GetAxisPosition_axis
                                        * Referenced by: '<S4>/Get Axis' Position'
                                        */
  1.0,                                 /* Mask Parameter: SetVoltage_back_cmd
                                        * Referenced by: '<S4>/Set Voltage'
                                        */
  20000.0,                             /* Mask Parameter: SetVoltage_back_pos
                                        * Referenced by: '<S4>/Set Voltage'
                                        */
  1.0,                                 /* Mask Parameter: GT400SVInitialization_openloop
                                        * Referenced by: '<Root>/GT400-SV Initialization'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S6>/Out1'
                                        */
  1.0,                                 /* Expression: 1
                                        * Referenced by: '<S6>/Constant'
                                        */
  3.1415926535897931,                  /* Expression: pi
                                        * Referenced by: '<Root>/Angle Ref.'
                                        */
  -0.0026179938779914941,              /* Expression: -(pi * 2.0 / 2400)
                                        * Referenced by: '<S4>/Angle Encoder'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S2>/Angle Ref.1'
                                        */
  0.05,                                /* Expression: 0.05
                                        * Referenced by: '<Root>/Sine Wave'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<Root>/Sine Wave'
                                        */
  1.0,                                 /* Expression: 1
                                        * Referenced by: '<Root>/Sine Wave'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<Root>/Sine Wave'
                                        */
  -0.0,                                /* Expression: -0.00
                                        * Referenced by: '<Root>/Pos Ref.'
                                        */
  4.8E-6,                              /* Expression: 0.048/10000
                                        * Referenced by: '<S4>/Pos Encoder'
                                        */

  /*  Expression: [x,xdot,angle,angledot]
   * Referenced by: '<S1>/LQR'
   */
  { -20.0, -13.6349, 38.7336, 6.1233 },
  3.1415926535897931,                  /* Expression: pi
                                        * Referenced by: '<S5>/Constant1'
                                        */
  0.17453292519943295,                 /* Expression: 10*pi/180
                                        * Referenced by: '<S5>/EntryAngle'
                                        */
  -60.0,                               /* Computed Parameter: Filter_A
                                        * Referenced by: '<S4>/Filter'
                                        */
  60.0,                                /* Computed Parameter: Filter_C
                                        * Referenced by: '<S4>/Filter'
                                        */
  1.0,                                 /* Expression: axis
                                        * Referenced by: '<S4>/Set Voltage'
                                        */
  0.3490658503988659                   /* Expression: 20*pi/180
                                        * Referenced by: '<S5>/StopAngle'
                                        */
};

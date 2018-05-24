/*
 * pidcontroller2013_data.c
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "pidcontroller2013".
 *
 * Model version              : 1.87
 * Simulink Coder version : 8.8 (R2015a) 09-Feb-2015
 * C source code generated on : Thu Mar 23 19:56:46 2017
 *
 * Target selection: rtwin.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "pidcontroller2013.h"
#include "pidcontroller2013_private.h"

/* Block parameters (auto storage) */
P_pidcontroller2013_T pidcontroller2013_P = {
  0.0,                                 /* Mask Parameter: PIDController_D
                                        * Referenced by: '<S3>/Derivative Gain'
                                        */
  0.0,                                 /* Mask Parameter: AnalogOutput_FinalValue
                                        * Referenced by: '<S2>/Analog Output'
                                        */
  0.0,                                 /* Mask Parameter: PIDController_I
                                        * Referenced by: '<S3>/Integral Gain'
                                        */
  0.0,                                 /* Mask Parameter: AnalogOutput_InitialValue
                                        * Referenced by: '<S2>/Analog Output'
                                        */
  10.0,                                /* Mask Parameter: AnalogInput_MaxMissedTicks
                                        * Referenced by: '<S1>/Analog Input'
                                        */
  10.0,                                /* Mask Parameter: AnalogOutput_MaxMissedTicks
                                        * Referenced by: '<S2>/Analog Output'
                                        */
  3.0,                                 /* Mask Parameter: PIDController_P
                                        * Referenced by: '<S3>/Proportional Gain'
                                        */
  0.0,                                 /* Mask Parameter: AnalogInput_YieldWhenWaiting
                                        * Referenced by: '<S1>/Analog Input'
                                        */
  0.0,                                 /* Mask Parameter: AnalogOutput_YieldWhenWaiting
                                        * Referenced by: '<S2>/Analog Output'
                                        */
  0,                                   /* Mask Parameter: AnalogInput_Channels
                                        * Referenced by: '<S1>/Analog Input'
                                        */
  0,                                   /* Mask Parameter: AnalogOutput_Channels
                                        * Referenced by: '<S2>/Analog Output'
                                        */
  0,                                   /* Mask Parameter: AnalogInput_RangeMode
                                        * Referenced by: '<S1>/Analog Input'
                                        */
  0,                                   /* Mask Parameter: AnalogOutput_RangeMode
                                        * Referenced by: '<S2>/Analog Output'
                                        */
  0,                                   /* Mask Parameter: AnalogInput_VoltRange
                                        * Referenced by: '<S1>/Analog Input'
                                        */
  0,                                   /* Mask Parameter: AnalogOutput_VoltRange
                                        * Referenced by: '<S2>/Analog Output'
                                        */
  5.0,                                 /* Expression: 5
                                        * Referenced by: '<Root>/Pulse Generator'
                                        */
  500.0,                               /* Computed Parameter: PulseGenerator_Period
                                        * Referenced by: '<Root>/Pulse Generator'
                                        */
  250.0,                               /* Computed Parameter: PulseGenerator_Duty
                                        * Referenced by: '<Root>/Pulse Generator'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<Root>/Pulse Generator'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S3>/Integrator'
                                        */
  15.0,                                /* Expression: 15
                                        * Referenced by: '<Root>/Saturation'
                                        */
  -15.0,                               /* Expression: -15
                                        * Referenced by: '<Root>/Saturation'
                                        */
  0.0,                                 /* Expression: 0
                                        * Referenced by: '<S2>/Constant'
                                        */
  0.5                                  /* Expression: 0.5
                                        * Referenced by: '<S2>/Gain'
                                        */
};

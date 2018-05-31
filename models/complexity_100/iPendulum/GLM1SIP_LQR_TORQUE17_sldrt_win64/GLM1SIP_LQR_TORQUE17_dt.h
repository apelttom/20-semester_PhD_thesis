/*
 * GLM1SIP_LQR_TORQUE17_dt.h
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

#include "ext_types.h"

/* data type size table */
static uint_T rtDataTypeSizes[] = {
  sizeof(real_T),
  sizeof(real32_T),
  sizeof(int8_T),
  sizeof(uint8_T),
  sizeof(int16_T),
  sizeof(uint16_T),
  sizeof(int32_T),
  sizeof(uint32_T),
  sizeof(boolean_T),
  sizeof(fcn_call_T),
  sizeof(int_T),
  sizeof(pointer_T),
  sizeof(action_T),
  2*sizeof(uint32_T)
};

/* data type name table */
static const char_T * rtDataTypeNames[] = {
  "real_T",
  "real32_T",
  "int8_T",
  "uint8_T",
  "int16_T",
  "uint16_T",
  "int32_T",
  "uint32_T",
  "boolean_T",
  "fcn_call_T",
  "int_T",
  "pointer_T",
  "action_T",
  "timer_uint32_pair_T"
};

/* data type transitions for block I/O structure */
static DataTypeTransition rtBTransitions[] = {
  { (char_T *)(&GLM1SIP_LQR_TORQUE17_B.GetAxisPosition1), 0, 0, 14 },

  { (char_T *)(&GLM1SIP_LQR_TORQUE17_B.RelationalOperator1), 8, 0, 2 }
  ,

  { (char_T *)(&GLM1SIP_LQR_TORQUE17_DW.TimeStampA), 0, 0, 8 },

  { (char_T *)(&GLM1SIP_LQR_TORQUE17_DW.Angle_PWORK.LoggedData), 11, 0, 7 },

  { (char_T *)(&GLM1SIP_LQR_TORQUE17_DW.TriggeredSubsystem_SubsysRanBC), 2, 0, 2
  },

  { (char_T *)(&GLM1SIP_LQR_TORQUE17_DW.EnabledSubsystem_MODE), 8, 0, 1 }
};

/* data type transition table for block I/O structure */
static DataTypeTransitionTable rtBTransTable = {
  6U,
  rtBTransitions
};

/* data type transitions for Parameters structure */
static DataTypeTransition rtPTransitions[] = {
  { (char_T *)(&GLM1SIP_LQR_TORQUE17_P.GetAxisPosition1_axis), 0, 0, 26 }
};

/* data type transition table for Parameters structure */
static DataTypeTransitionTable rtPTransTable = {
  1U,
  rtPTransitions
};

/* [EOF] GLM1SIP_LQR_TORQUE17_dt.h */

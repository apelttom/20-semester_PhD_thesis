/*
 * pidcontroller2013.c
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
#include "pidcontroller2013_dt.h"

/* list of Simulink Desktop Real-Time timers */
const int RTWinTimerCount = 1;
const double RTWinTimers[2] = {
  0.01, 0.0,
};

/* list of Simulink Desktop Real-Time boards */
const int RTWinBoardCount = 1;
RTWINBOARD RTWinBoards[1] = {
  { "Sensoray/Model_626", 4294967295U, 0, NULL },
};

/* Block signals (auto storage) */
B_pidcontroller2013_T pidcontroller2013_B;

/* Continuous states */
X_pidcontroller2013_T pidcontroller2013_X;

/* Block states (auto storage) */
DW_pidcontroller2013_T pidcontroller2013_DW;

/* Real-time model */
RT_MODEL_pidcontroller2013_T pidcontroller2013_M_;
RT_MODEL_pidcontroller2013_T *const pidcontroller2013_M = &pidcontroller2013_M_;

/*
 * This function updates continuous states using the ODE5 fixed-step
 * solver algorithm
 */
static void rt_ertODEUpdateContinuousStates(RTWSolverInfo *si )
{
  /* Solver Matrices */
  static const real_T rt_ODE5_A[6] = {
    1.0/5.0, 3.0/10.0, 4.0/5.0, 8.0/9.0, 1.0, 1.0
  };

  static const real_T rt_ODE5_B[6][6] = {
    { 1.0/5.0, 0.0, 0.0, 0.0, 0.0, 0.0 },

    { 3.0/40.0, 9.0/40.0, 0.0, 0.0, 0.0, 0.0 },

    { 44.0/45.0, -56.0/15.0, 32.0/9.0, 0.0, 0.0, 0.0 },

    { 19372.0/6561.0, -25360.0/2187.0, 64448.0/6561.0, -212.0/729.0, 0.0, 0.0 },

    { 9017.0/3168.0, -355.0/33.0, 46732.0/5247.0, 49.0/176.0, -5103.0/18656.0,
      0.0 },

    { 35.0/384.0, 0.0, 500.0/1113.0, 125.0/192.0, -2187.0/6784.0, 11.0/84.0 }
  };

  time_T t = rtsiGetT(si);
  time_T tnew = rtsiGetSolverStopTime(si);
  time_T h = rtsiGetStepSize(si);
  real_T *x = rtsiGetContStates(si);
  ODE5_IntgData *id = (ODE5_IntgData *)rtsiGetSolverData(si);
  real_T *y = id->y;
  real_T *f0 = id->f[0];
  real_T *f1 = id->f[1];
  real_T *f2 = id->f[2];
  real_T *f3 = id->f[3];
  real_T *f4 = id->f[4];
  real_T *f5 = id->f[5];
  real_T hB[6];
  int_T i;
  int_T nXc = 1;
  rtsiSetSimTimeStep(si,MINOR_TIME_STEP);

  /* Save the state values at time t in y, we'll use x as ynew. */
  (void) memcpy(y, x,
                (uint_T)nXc*sizeof(real_T));

  /* Assumes that rtsiSetT and ModelOutputs are up-to-date */
  /* f0 = f(t,y) */
  rtsiSetdX(si, f0);
  pidcontroller2013_derivatives();

  /* f(:,2) = feval(odefile, t + hA(1), y + f*hB(:,1), args(:)(*)); */
  hB[0] = h * rt_ODE5_B[0][0];
  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0]);
  }

  rtsiSetT(si, t + h*rt_ODE5_A[0]);
  rtsiSetdX(si, f1);
  pidcontroller2013_output();
  pidcontroller2013_derivatives();

  /* f(:,3) = feval(odefile, t + hA(2), y + f*hB(:,2), args(:)(*)); */
  for (i = 0; i <= 1; i++) {
    hB[i] = h * rt_ODE5_B[1][i];
  }

  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1]);
  }

  rtsiSetT(si, t + h*rt_ODE5_A[1]);
  rtsiSetdX(si, f2);
  pidcontroller2013_output();
  pidcontroller2013_derivatives();

  /* f(:,4) = feval(odefile, t + hA(3), y + f*hB(:,3), args(:)(*)); */
  for (i = 0; i <= 2; i++) {
    hB[i] = h * rt_ODE5_B[2][i];
  }

  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2]);
  }

  rtsiSetT(si, t + h*rt_ODE5_A[2]);
  rtsiSetdX(si, f3);
  pidcontroller2013_output();
  pidcontroller2013_derivatives();

  /* f(:,5) = feval(odefile, t + hA(4), y + f*hB(:,4), args(:)(*)); */
  for (i = 0; i <= 3; i++) {
    hB[i] = h * rt_ODE5_B[3][i];
  }

  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2] +
                   f3[i]*hB[3]);
  }

  rtsiSetT(si, t + h*rt_ODE5_A[3]);
  rtsiSetdX(si, f4);
  pidcontroller2013_output();
  pidcontroller2013_derivatives();

  /* f(:,6) = feval(odefile, t + hA(5), y + f*hB(:,5), args(:)(*)); */
  for (i = 0; i <= 4; i++) {
    hB[i] = h * rt_ODE5_B[4][i];
  }

  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2] +
                   f3[i]*hB[3] + f4[i]*hB[4]);
  }

  rtsiSetT(si, tnew);
  rtsiSetdX(si, f5);
  pidcontroller2013_output();
  pidcontroller2013_derivatives();

  /* tnew = t + hA(6);
     ynew = y + f*hB(:,6); */
  for (i = 0; i <= 5; i++) {
    hB[i] = h * rt_ODE5_B[5][i];
  }

  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2] +
                   f3[i]*hB[3] + f4[i]*hB[4] + f5[i]*hB[5]);
  }

  rtsiSetSimTimeStep(si,MAJOR_TIME_STEP);
}

/* Model output function */
void pidcontroller2013_output(void)
{
  real_T *lastU;
  real_T rtb_Sum1;
  real_T rtb_IdealDerivative;
  if (rtmIsMajorTimeStep(pidcontroller2013_M)) {
    /* set solver stop time */
    if (!(pidcontroller2013_M->Timing.clockTick0+1)) {
      rtsiSetSolverStopTime(&pidcontroller2013_M->solverInfo,
                            ((pidcontroller2013_M->Timing.clockTickH0 + 1) *
        pidcontroller2013_M->Timing.stepSize0 * 4294967296.0));
    } else {
      rtsiSetSolverStopTime(&pidcontroller2013_M->solverInfo,
                            ((pidcontroller2013_M->Timing.clockTick0 + 1) *
        pidcontroller2013_M->Timing.stepSize0 +
        pidcontroller2013_M->Timing.clockTickH0 *
        pidcontroller2013_M->Timing.stepSize0 * 4294967296.0));
    }
  }                                    /* end MajorTimeStep */

  /* Update absolute time of base rate at minor time step */
  if (rtmIsMinorTimeStep(pidcontroller2013_M)) {
    pidcontroller2013_M->Timing.t[0] = rtsiGetT(&pidcontroller2013_M->solverInfo);
  }

  if (rtmIsMajorTimeStep(pidcontroller2013_M)) {
    /* DiscretePulseGenerator: '<Root>/Pulse Generator' */
    pidcontroller2013_B.PulseGenerator = (pidcontroller2013_DW.clockTickCounter <
      pidcontroller2013_P.PulseGenerator_Duty) &&
      (pidcontroller2013_DW.clockTickCounter >= 0) ?
      pidcontroller2013_P.PulseGenerator_Amp : 0.0;
    if (pidcontroller2013_DW.clockTickCounter >=
        pidcontroller2013_P.PulseGenerator_Period - 1.0) {
      pidcontroller2013_DW.clockTickCounter = 0;
    } else {
      pidcontroller2013_DW.clockTickCounter++;
    }

    /* End of DiscretePulseGenerator: '<Root>/Pulse Generator' */
    /* S-Function Block: <S1>/Analog Input */
    {
      ANALOGIOPARM parm;
      parm.mode = (RANGEMODE) pidcontroller2013_P.AnalogInput_RangeMode;
      parm.rangeidx = pidcontroller2013_P.AnalogInput_VoltRange;
      RTBIO_DriverIO(0, ANALOGINPUT, IOREAD, 1,
                     &pidcontroller2013_P.AnalogInput_Channels,
                     &pidcontroller2013_B.AnalogInput, &parm);
    }

    /* Sum: '<Root>/Sum1' */
    rtb_Sum1 = pidcontroller2013_B.PulseGenerator -
      pidcontroller2013_B.AnalogInput;

    /* Gain: '<S3>/Proportional Gain' */
    pidcontroller2013_B.ProportionalGain = pidcontroller2013_P.PIDController_P *
      rtb_Sum1;

    /* Gain: '<S3>/Derivative Gain' */
    pidcontroller2013_B.DerivativeGain = pidcontroller2013_P.PIDController_D *
      rtb_Sum1;
  }

  /* Derivative: '<S3>/Ideal Derivative' */
  if ((pidcontroller2013_DW.TimeStampA >= pidcontroller2013_M->Timing.t[0]) &&
      (pidcontroller2013_DW.TimeStampB >= pidcontroller2013_M->Timing.t[0])) {
    rtb_IdealDerivative = 0.0;
  } else {
    rtb_IdealDerivative = pidcontroller2013_DW.TimeStampA;
    lastU = &pidcontroller2013_DW.LastUAtTimeA;
    if (pidcontroller2013_DW.TimeStampA < pidcontroller2013_DW.TimeStampB) {
      if (pidcontroller2013_DW.TimeStampB < pidcontroller2013_M->Timing.t[0]) {
        rtb_IdealDerivative = pidcontroller2013_DW.TimeStampB;
        lastU = &pidcontroller2013_DW.LastUAtTimeB;
      }
    } else {
      if (pidcontroller2013_DW.TimeStampA >= pidcontroller2013_M->Timing.t[0]) {
        rtb_IdealDerivative = pidcontroller2013_DW.TimeStampB;
        lastU = &pidcontroller2013_DW.LastUAtTimeB;
      }
    }

    rtb_IdealDerivative = (pidcontroller2013_B.DerivativeGain - *lastU) /
      (pidcontroller2013_M->Timing.t[0] - rtb_IdealDerivative);
  }

  /* End of Derivative: '<S3>/Ideal Derivative' */

  /* Sum: '<S3>/Sum' incorporates:
   *  Integrator: '<S3>/Integrator'
   */
  rtb_IdealDerivative += pidcontroller2013_B.ProportionalGain +
    pidcontroller2013_X.Integrator_CSTATE;

  /* Saturate: '<Root>/Saturation' */
  if (rtb_IdealDerivative > pidcontroller2013_P.Saturation_UpperSat) {
    pidcontroller2013_B.Saturation = pidcontroller2013_P.Saturation_UpperSat;
  } else if (rtb_IdealDerivative < pidcontroller2013_P.Saturation_LowerSat) {
    pidcontroller2013_B.Saturation = pidcontroller2013_P.Saturation_LowerSat;
  } else {
    pidcontroller2013_B.Saturation = rtb_IdealDerivative;
  }

  /* End of Saturate: '<Root>/Saturation' */

  /* Gain: '<S2>/Gain' incorporates:
   *  Constant: '<S2>/Constant'
   *  Sum: '<S2>/Sum'
   */
  pidcontroller2013_B.Gain = (pidcontroller2013_B.Saturation +
    pidcontroller2013_P.Constant_Value) * pidcontroller2013_P.Gain_Gain;
  if (rtmIsMajorTimeStep(pidcontroller2013_M)) {
    /* S-Function Block: <S2>/Analog Output */
    {
      {
        ANALOGIOPARM parm;
        parm.mode = (RANGEMODE) pidcontroller2013_P.AnalogOutput_RangeMode;
        parm.rangeidx = pidcontroller2013_P.AnalogOutput_VoltRange;
        RTBIO_DriverIO(0, ANALOGOUTPUT, IOWRITE, 1,
                       &pidcontroller2013_P.AnalogOutput_Channels,
                       &pidcontroller2013_B.Gain, &parm);
      }
    }

    /* Gain: '<S3>/Integral Gain' */
    pidcontroller2013_B.IntegralGain = pidcontroller2013_P.PIDController_I *
      rtb_Sum1;
  }
}

/* Model update function */
void pidcontroller2013_update(void)
{
  real_T *lastU;

  /* Update for Derivative: '<S3>/Ideal Derivative' */
  if (pidcontroller2013_DW.TimeStampA == (rtInf)) {
    pidcontroller2013_DW.TimeStampA = pidcontroller2013_M->Timing.t[0];
    lastU = &pidcontroller2013_DW.LastUAtTimeA;
  } else if (pidcontroller2013_DW.TimeStampB == (rtInf)) {
    pidcontroller2013_DW.TimeStampB = pidcontroller2013_M->Timing.t[0];
    lastU = &pidcontroller2013_DW.LastUAtTimeB;
  } else if (pidcontroller2013_DW.TimeStampA < pidcontroller2013_DW.TimeStampB)
  {
    pidcontroller2013_DW.TimeStampA = pidcontroller2013_M->Timing.t[0];
    lastU = &pidcontroller2013_DW.LastUAtTimeA;
  } else {
    pidcontroller2013_DW.TimeStampB = pidcontroller2013_M->Timing.t[0];
    lastU = &pidcontroller2013_DW.LastUAtTimeB;
  }

  *lastU = pidcontroller2013_B.DerivativeGain;

  /* End of Update for Derivative: '<S3>/Ideal Derivative' */
  if (rtmIsMajorTimeStep(pidcontroller2013_M)) {
    rt_ertODEUpdateContinuousStates(&pidcontroller2013_M->solverInfo);
  }

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   * Timer of this task consists of two 32 bit unsigned integers.
   * The two integers represent the low bits Timing.clockTick0 and the high bits
   * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
   */
  if (!(++pidcontroller2013_M->Timing.clockTick0)) {
    ++pidcontroller2013_M->Timing.clockTickH0;
  }

  pidcontroller2013_M->Timing.t[0] = rtsiGetSolverStopTime
    (&pidcontroller2013_M->solverInfo);

  {
    /* Update absolute timer for sample time: [0.01s, 0.0s] */
    /* The "clockTick1" counts the number of times the code of this task has
     * been executed. The absolute time is the multiplication of "clockTick1"
     * and "Timing.stepSize1". Size of "clockTick1" ensures timer will not
     * overflow during the application lifespan selected.
     * Timer of this task consists of two 32 bit unsigned integers.
     * The two integers represent the low bits Timing.clockTick1 and the high bits
     * Timing.clockTickH1. When the low bit overflows to 0, the high bits increment.
     */
    if (!(++pidcontroller2013_M->Timing.clockTick1)) {
      ++pidcontroller2013_M->Timing.clockTickH1;
    }

    pidcontroller2013_M->Timing.t[1] = pidcontroller2013_M->Timing.clockTick1 *
      pidcontroller2013_M->Timing.stepSize1 +
      pidcontroller2013_M->Timing.clockTickH1 *
      pidcontroller2013_M->Timing.stepSize1 * 4294967296.0;
  }
}

/* Derivatives for root system: '<Root>' */
void pidcontroller2013_derivatives(void)
{
  XDot_pidcontroller2013_T *_rtXdot;
  _rtXdot = ((XDot_pidcontroller2013_T *) pidcontroller2013_M->ModelData.derivs);

  /* Derivatives for Integrator: '<S3>/Integrator' */
  _rtXdot->Integrator_CSTATE = pidcontroller2013_B.IntegralGain;
}

/* Model initialize function */
void pidcontroller2013_initialize(void)
{
  /* Start for DiscretePulseGenerator: '<Root>/Pulse Generator' */
  pidcontroller2013_DW.clockTickCounter = 0;

  /* S-Function Block: <S2>/Analog Output */
  {
    {
      ANALOGIOPARM parm;
      parm.mode = (RANGEMODE) pidcontroller2013_P.AnalogOutput_RangeMode;
      parm.rangeidx = pidcontroller2013_P.AnalogOutput_VoltRange;
      RTBIO_DriverIO(0, ANALOGOUTPUT, IOWRITE, 1,
                     &pidcontroller2013_P.AnalogOutput_Channels,
                     &pidcontroller2013_P.AnalogOutput_InitialValue, &parm);
    }
  }

  /* InitializeConditions for Integrator: '<S3>/Integrator' */
  pidcontroller2013_X.Integrator_CSTATE = pidcontroller2013_P.Integrator_IC;

  /* InitializeConditions for Derivative: '<S3>/Ideal Derivative' */
  pidcontroller2013_DW.TimeStampA = (rtInf);
  pidcontroller2013_DW.TimeStampB = (rtInf);
}

/* Model terminate function */
void pidcontroller2013_terminate(void)
{
  /* S-Function Block: <S2>/Analog Output */
  {
    {
      ANALOGIOPARM parm;
      parm.mode = (RANGEMODE) pidcontroller2013_P.AnalogOutput_RangeMode;
      parm.rangeidx = pidcontroller2013_P.AnalogOutput_VoltRange;
      RTBIO_DriverIO(0, ANALOGOUTPUT, IOWRITE, 1,
                     &pidcontroller2013_P.AnalogOutput_Channels,
                     &pidcontroller2013_P.AnalogOutput_FinalValue, &parm);
    }
  }
}

/*========================================================================*
 * Start of Classic call interface                                        *
 *========================================================================*/

/* Solver interface called by GRT_Main */
#ifndef USE_GENERATED_SOLVER

void rt_ODECreateIntegrationData(RTWSolverInfo *si)
{
  UNUSED_PARAMETER(si);
  return;
}                                      /* do nothing */

void rt_ODEDestroyIntegrationData(RTWSolverInfo *si)
{
  UNUSED_PARAMETER(si);
  return;
}                                      /* do nothing */

void rt_ODEUpdateContinuousStates(RTWSolverInfo *si)
{
  UNUSED_PARAMETER(si);
  return;
}                                      /* do nothing */

#endif

void MdlOutputs(int_T tid)
{
  pidcontroller2013_output();
  UNUSED_PARAMETER(tid);
}

void MdlUpdate(int_T tid)
{
  pidcontroller2013_update();
  UNUSED_PARAMETER(tid);
}

void MdlInitializeSizes(void)
{
}

void MdlInitializeSampleTimes(void)
{
}

void MdlInitialize(void)
{
}

void MdlStart(void)
{
  pidcontroller2013_initialize();
}

void MdlTerminate(void)
{
  pidcontroller2013_terminate();
}

/* Registration function */
RT_MODEL_pidcontroller2013_T *pidcontroller2013(void)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  /* initialize real-time model */
  (void) memset((void *)pidcontroller2013_M, 0,
                sizeof(RT_MODEL_pidcontroller2013_T));

  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&pidcontroller2013_M->solverInfo,
                          &pidcontroller2013_M->Timing.simTimeStep);
    rtsiSetTPtr(&pidcontroller2013_M->solverInfo, &rtmGetTPtr
                (pidcontroller2013_M));
    rtsiSetStepSizePtr(&pidcontroller2013_M->solverInfo,
                       &pidcontroller2013_M->Timing.stepSize0);
    rtsiSetdXPtr(&pidcontroller2013_M->solverInfo,
                 &pidcontroller2013_M->ModelData.derivs);
    rtsiSetContStatesPtr(&pidcontroller2013_M->solverInfo, (real_T **)
                         &pidcontroller2013_M->ModelData.contStates);
    rtsiSetNumContStatesPtr(&pidcontroller2013_M->solverInfo,
      &pidcontroller2013_M->Sizes.numContStates);
    rtsiSetErrorStatusPtr(&pidcontroller2013_M->solverInfo, (&rtmGetErrorStatus
      (pidcontroller2013_M)));
    rtsiSetRTModelPtr(&pidcontroller2013_M->solverInfo, pidcontroller2013_M);
  }

  rtsiSetSimTimeStep(&pidcontroller2013_M->solverInfo, MAJOR_TIME_STEP);
  pidcontroller2013_M->ModelData.intgData.y =
    pidcontroller2013_M->ModelData.odeY;
  pidcontroller2013_M->ModelData.intgData.f[0] =
    pidcontroller2013_M->ModelData.odeF[0];
  pidcontroller2013_M->ModelData.intgData.f[1] =
    pidcontroller2013_M->ModelData.odeF[1];
  pidcontroller2013_M->ModelData.intgData.f[2] =
    pidcontroller2013_M->ModelData.odeF[2];
  pidcontroller2013_M->ModelData.intgData.f[3] =
    pidcontroller2013_M->ModelData.odeF[3];
  pidcontroller2013_M->ModelData.intgData.f[4] =
    pidcontroller2013_M->ModelData.odeF[4];
  pidcontroller2013_M->ModelData.intgData.f[5] =
    pidcontroller2013_M->ModelData.odeF[5];
  pidcontroller2013_M->ModelData.contStates = ((real_T *) &pidcontroller2013_X);
  rtsiSetSolverData(&pidcontroller2013_M->solverInfo, (void *)
                    &pidcontroller2013_M->ModelData.intgData);
  rtsiSetSolverName(&pidcontroller2013_M->solverInfo,"ode5");

  /* Initialize timing info */
  {
    int_T *mdlTsMap = pidcontroller2013_M->Timing.sampleTimeTaskIDArray;
    mdlTsMap[0] = 0;
    mdlTsMap[1] = 1;
    pidcontroller2013_M->Timing.sampleTimeTaskIDPtr = (&mdlTsMap[0]);
    pidcontroller2013_M->Timing.sampleTimes =
      (&pidcontroller2013_M->Timing.sampleTimesArray[0]);
    pidcontroller2013_M->Timing.offsetTimes =
      (&pidcontroller2013_M->Timing.offsetTimesArray[0]);

    /* task periods */
    pidcontroller2013_M->Timing.sampleTimes[0] = (0.0);
    pidcontroller2013_M->Timing.sampleTimes[1] = (0.01);

    /* task offsets */
    pidcontroller2013_M->Timing.offsetTimes[0] = (0.0);
    pidcontroller2013_M->Timing.offsetTimes[1] = (0.0);
  }

  rtmSetTPtr(pidcontroller2013_M, &pidcontroller2013_M->Timing.tArray[0]);

  {
    int_T *mdlSampleHits = pidcontroller2013_M->Timing.sampleHitArray;
    mdlSampleHits[0] = 1;
    mdlSampleHits[1] = 1;
    pidcontroller2013_M->Timing.sampleHits = (&mdlSampleHits[0]);
  }

  rtmSetTFinal(pidcontroller2013_M, -1);
  pidcontroller2013_M->Timing.stepSize0 = 0.01;
  pidcontroller2013_M->Timing.stepSize1 = 0.01;

  /* External mode info */
  pidcontroller2013_M->Sizes.checksums[0] = (1485934999U);
  pidcontroller2013_M->Sizes.checksums[1] = (3836693040U);
  pidcontroller2013_M->Sizes.checksums[2] = (2625116907U);
  pidcontroller2013_M->Sizes.checksums[3] = (3781860931U);

  {
    static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE;
    static RTWExtModeInfo rt_ExtModeInfo;
    static const sysRanDType *systemRan[1];
    pidcontroller2013_M->extModeInfo = (&rt_ExtModeInfo);
    rteiSetSubSystemActiveVectorAddresses(&rt_ExtModeInfo, systemRan);
    systemRan[0] = &rtAlwaysEnabled;
    rteiSetModelMappingInfoPtr(pidcontroller2013_M->extModeInfo,
      &pidcontroller2013_M->SpecialInfo.mappingInfo);
    rteiSetChecksumsPtr(pidcontroller2013_M->extModeInfo,
                        pidcontroller2013_M->Sizes.checksums);
    rteiSetTPtr(pidcontroller2013_M->extModeInfo, rtmGetTPtr(pidcontroller2013_M));
  }

  pidcontroller2013_M->solverInfoPtr = (&pidcontroller2013_M->solverInfo);
  pidcontroller2013_M->Timing.stepSize = (0.01);
  rtsiSetFixedStepSize(&pidcontroller2013_M->solverInfo, 0.01);
  rtsiSetSolverMode(&pidcontroller2013_M->solverInfo, SOLVER_MODE_SINGLETASKING);

  /* block I/O */
  pidcontroller2013_M->ModelData.blockIO = ((void *) &pidcontroller2013_B);
  (void) memset(((void *) &pidcontroller2013_B), 0,
                sizeof(B_pidcontroller2013_T));

  /* parameters */
  pidcontroller2013_M->ModelData.defaultParam = ((real_T *)&pidcontroller2013_P);

  /* states (continuous) */
  {
    real_T *x = (real_T *) &pidcontroller2013_X;
    pidcontroller2013_M->ModelData.contStates = (x);
    (void) memset((void *)&pidcontroller2013_X, 0,
                  sizeof(X_pidcontroller2013_T));
  }

  /* states (dwork) */
  pidcontroller2013_M->ModelData.dwork = ((void *) &pidcontroller2013_DW);
  (void) memset((void *)&pidcontroller2013_DW, 0,
                sizeof(DW_pidcontroller2013_T));

  /* data type transition information */
  {
    static DataTypeTransInfo dtInfo;
    (void) memset((char_T *) &dtInfo, 0,
                  sizeof(dtInfo));
    pidcontroller2013_M->SpecialInfo.mappingInfo = (&dtInfo);
    dtInfo.numDataTypes = 14;
    dtInfo.dataTypeSizes = &rtDataTypeSizes[0];
    dtInfo.dataTypeNames = &rtDataTypeNames[0];

    /* Block I/O transition table */
    dtInfo.B = &rtBTransTable;

    /* Parameters transition table */
    dtInfo.P = &rtPTransTable;
  }

  /* Initialize Sizes */
  pidcontroller2013_M->Sizes.numContStates = (1);/* Number of continuous states */
  pidcontroller2013_M->Sizes.numPeriodicContStates = (0);/* Number of periodic continuous states */
  pidcontroller2013_M->Sizes.numY = (0);/* Number of model outputs */
  pidcontroller2013_M->Sizes.numU = (0);/* Number of model inputs */
  pidcontroller2013_M->Sizes.sysDirFeedThru = (0);/* The model is not direct feedthrough */
  pidcontroller2013_M->Sizes.numSampTimes = (2);/* Number of sample times */
  pidcontroller2013_M->Sizes.numBlocks = (17);/* Number of blocks */
  pidcontroller2013_M->Sizes.numBlockIO = (7);/* Number of block outputs */
  pidcontroller2013_M->Sizes.numBlockPrms = (24);/* Sum of parameter "widths" */
  return pidcontroller2013_M;
}

/*========================================================================*
 * End of Classic call interface                                          *
 *========================================================================*/

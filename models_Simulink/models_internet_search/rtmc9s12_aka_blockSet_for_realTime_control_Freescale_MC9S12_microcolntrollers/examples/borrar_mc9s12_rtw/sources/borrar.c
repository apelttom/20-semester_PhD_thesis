/*
 * File: borrar.c
 *
 * Real-Time Workshop code generated for Simulink model borrar.
 *
 * Model version                        : 1.434
 * Real-Time Workshop file version      : 7.4  (R2009b)  29-Jun-2009
 * Real-Time Workshop file generated on : Sat Sep 04 14:43:55 2010
 * TLC version                          : 7.4 (Jul 14 2009)
 * C/C++ source code generated on       : Sat Sep 04 14:43:56 2010
 *
 * Target selection: mc9s12.tlc
 * Embedded hardware selection: Motorola HC12
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "borrar.h"
#include "borrar_private.h"
#include <stdio.h>
#include "borrar_dt.h"

/* Block signals (auto storage) */
BlockIO_borrar borrar_B;

/* Block states (auto storage) */
D_Work_borrar borrar_DWork;

/* Real-time model */
RT_MODEL_borrar borrar_M_;
RT_MODEL_borrar *borrar_M = &borrar_M_;
static void rate_scheduler(void);

/*
 * This function updates active task flag for each subrate.
 * The function must be called at model base rate, hence the
 * generated code self-manages all its subrates.
 */
static void rate_scheduler(void)
{
  /* Compute which subrates run during the next base time step.  Subrates
   * are an integer multiple of the base rate counter.  Therefore, the subtask
   * counter is reset when it reaches its limit (zero means run).
   */
  if (++(borrar_M->Timing.TaskCounters.TID[1]) > 3) {/* Sample time: [0.02s, 0.0s] */
    borrar_M->Timing.TaskCounters.TID[1] = 0;
  }

  borrar_M->Timing.sampleHits[1] = (borrar_M->Timing.TaskCounters.TID[1] == 0);
}

/* Model output function */
void borrar_output(int_T tid)
{
  /* Sin: '<Root>/Sine Wave' */
  if (borrar_DWork.systemEnable == 1L) {
    borrar_DWork.lastSin = sin(borrar_P.SineWave_Freq * borrar_M->Timing.t[0]);
    borrar_DWork.lastCos = cos(borrar_P.SineWave_Freq * borrar_M->Timing.t[0]);
    borrar_DWork.systemEnable = 0L;
  }

  /* Gain: '<Root>/Gain' */
  borrar_B.Gain = (((borrar_DWork.lastSin * borrar_P.SineWave_PCos +
                     borrar_DWork.lastCos * borrar_P.SineWave_PSin) *
                    borrar_P.SineWave_HCos + (borrar_DWork.lastCos *
    borrar_P.SineWave_PCos - borrar_DWork.lastSin * borrar_P.SineWave_PSin) *
                    borrar_P.SineWave_Hsin) * borrar_P.SineWave_Amp +
                   borrar_P.SineWave_Bias) * borrar_P.Gain_Gain;
  if (borrar_M->Timing.TaskCounters.TID[1] == 0) {
    /* ZeroOrderHold: '<Root>/Zero-Order Hold' */
    borrar_B.ZeroOrderHold = borrar_B.Gain;
  }

  /* tid is required for a uniform function interface.
   * Argument tid is not used in the function. */
  UNUSED_PARAMETER(tid);
}

/* Model update function */
void borrar_update(int_T tid)
{
  {
    real_T HoldSine;

    /* Update for Sin: '<Root>/Sine Wave' */
    HoldSine = borrar_DWork.lastSin;
    borrar_DWork.lastSin = borrar_DWork.lastSin * borrar_P.SineWave_HCos +
      borrar_DWork.lastCos * borrar_P.SineWave_Hsin;
    borrar_DWork.lastCos = borrar_DWork.lastCos * borrar_P.SineWave_HCos -
      HoldSine * borrar_P.SineWave_Hsin;
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
  if (!(++borrar_M->Timing.clockTick0))
    ++borrar_M->Timing.clockTickH0;
  borrar_M->Timing.t[0] = borrar_M->Timing.clockTick0 *
    borrar_M->Timing.stepSize0 + borrar_M->Timing.clockTickH0 *
    borrar_M->Timing.stepSize0 * 4294967296.0;
  if (borrar_M->Timing.TaskCounters.TID[1] == 0) {
    /* Update absolute timer for sample time: [0.02s, 0.0s] */
    /* The "clockTick1" counts the number of times the code of this task has
     * been executed. The absolute time is the multiplication of "clockTick1"
     * and "Timing.stepSize1". Size of "clockTick1" ensures timer will not
     * overflow during the application lifespan selected.
     * Timer of this task consists of two 32 bit unsigned integers.
     * The two integers represent the low bits Timing.clockTick1 and the high bits
     * Timing.clockTickH1. When the low bit overflows to 0, the high bits increment.
     */
    if (!(++borrar_M->Timing.clockTick1))
      ++borrar_M->Timing.clockTickH1;
    borrar_M->Timing.t[1] = borrar_M->Timing.clockTick1 *
      borrar_M->Timing.stepSize1 + borrar_M->Timing.clockTickH1 *
      borrar_M->Timing.stepSize1 * 4294967296.0;
  }

  rate_scheduler();

  /* tid is required for a uniform function interface.
   * Argument tid is not used in the function. */
  UNUSED_PARAMETER(tid);
}

/* Model initialize function */
void borrar_initialize(boolean_T firstTime)
{
  (void)firstTime;

  /* Registration code */

  /* initialize real-time model */
  (void) memset((void *)borrar_M,0,
                sizeof(RT_MODEL_borrar));

  /* Initialize timing info */
  {
    int_T *mdlTsMap = borrar_M->Timing.sampleTimeTaskIDArray;
    mdlTsMap[0] = 0;
    mdlTsMap[1] = 1;
    borrar_M->Timing.sampleTimeTaskIDPtr = (&mdlTsMap[0]);
    borrar_M->Timing.sampleTimes = (&borrar_M->Timing.sampleTimesArray[0]);
    borrar_M->Timing.offsetTimes = (&borrar_M->Timing.offsetTimesArray[0]);

    /* task periods */
    borrar_M->Timing.sampleTimes[0] = (0.005);
    borrar_M->Timing.sampleTimes[1] = (0.02);

    /* task offsets */
    borrar_M->Timing.offsetTimes[0] = (0.0);
    borrar_M->Timing.offsetTimes[1] = (0.0);
  }

  rtmSetTPtr(borrar_M, &borrar_M->Timing.tArray[0]);

  {
    int_T *mdlSampleHits = borrar_M->Timing.sampleHitArray;
    mdlSampleHits[0] = 1;
    mdlSampleHits[1] = 1;
    borrar_M->Timing.sampleHits = (&mdlSampleHits[0]);
  }

  rtmSetTFinal(borrar_M, -1);
  borrar_M->Timing.stepSize0 = 0.005;
  borrar_M->Timing.stepSize1 = 0.02;

  /* external mode info */
  borrar_M->Sizes.checksums[0] = (3855028670U);
  borrar_M->Sizes.checksums[1] = (3128608077U);
  borrar_M->Sizes.checksums[2] = (212739995U);
  borrar_M->Sizes.checksums[3] = (126149998U);

  {
    static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE;
    static RTWExtModeInfo rt_ExtModeInfo;
    static const sysRanDType *systemRan[1];
    borrar_M->extModeInfo = (&rt_ExtModeInfo);
    rteiSetSubSystemActiveVectorAddresses(&rt_ExtModeInfo, systemRan);
    systemRan[0] = &rtAlwaysEnabled;
    rteiSetModelMappingInfoPtr(borrar_M->extModeInfo,
      &borrar_M->SpecialInfo.mappingInfo);
    rteiSetChecksumsPtr(borrar_M->extModeInfo, borrar_M->Sizes.checksums);
    rteiSetTPtr(borrar_M->extModeInfo, rtmGetTPtr(borrar_M));
  }

  borrar_M->solverInfoPtr = (&borrar_M->solverInfo);
  borrar_M->Timing.stepSize = (0.005);
  rtsiSetFixedStepSize(&borrar_M->solverInfo, 0.005);
  rtsiSetSolverMode(&borrar_M->solverInfo, SOLVER_MODE_SINGLETASKING);

  /* block I/O */
  borrar_M->ModelData.blockIO = ((void *) &borrar_B);

  {
    borrar_B.Gain = 0.0;
    borrar_B.ZeroOrderHold = 0.0;
  }

  /* parameters */
  borrar_M->ModelData.defaultParam = ((real_T *) &borrar_P);

  /* states (dwork) */
  borrar_M->Work.dwork = ((void *) &borrar_DWork);
  (void) memset((void *)&borrar_DWork, 0,
                sizeof(D_Work_borrar));
  borrar_DWork.lastSin = 0.0;
  borrar_DWork.lastCos = 0.0;

  /* data type transition information */
  {
    static DataTypeTransInfo dtInfo;
    (void) memset((char_T *) &dtInfo,0,
                  sizeof(dtInfo));
    borrar_M->SpecialInfo.mappingInfo = (&dtInfo);
    dtInfo.numDataTypes = 14;
    dtInfo.dataTypeSizes = &rtDataTypeSizes[0];
    dtInfo.dataTypeNames = &rtDataTypeNames[0];

    /* Block I/O transition table */
    dtInfo.B = &rtBTransTable;

    /* Parameters transition table */
    dtInfo.P = &rtPTransTable;
  }
}

/*========================================================================*
 * Start of GRT compatible call interface                                 *
 *========================================================================*/
void MdlOutputs(int_T tid)
{
  borrar_output(tid);
}

void MdlUpdate(int_T tid)
{
  borrar_update(tid);
}

void MdlInitializeSizes(void)
{
  borrar_M->Sizes.numContStates = (0); /* Number of continuous states */
  borrar_M->Sizes.numY = (0);          /* Number of model outputs */
  borrar_M->Sizes.numU = (0);          /* Number of model inputs */
  borrar_M->Sizes.sysDirFeedThru = (0);/* The model is not direct feedthrough */
  borrar_M->Sizes.numSampTimes = (2);  /* Number of sample times */
  borrar_M->Sizes.numBlocks = (4);     /* Number of blocks */
  borrar_M->Sizes.numBlockIO = (2);    /* Number of block outputs */
  borrar_M->Sizes.numBlockPrms = (8);  /* Sum of parameter "widths" */
}

void MdlInitializeSampleTimes(void)
{
}

void MdlInitialize(void)
{
}

void MdlStart(void)
{
  MdlInitialize();

  /* Enable for Sin: '<Root>/Sine Wave' */
  borrar_DWork.systemEnable = 1L;
}

void MdlTerminate(void)
{
}

RT_MODEL_borrar *borrar(void)
{
  borrar_initialize(1);
  return borrar_M;
}

/*========================================================================*
 * End of GRT compatible call interface                                   *
 *========================================================================*/

/*
 * File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */

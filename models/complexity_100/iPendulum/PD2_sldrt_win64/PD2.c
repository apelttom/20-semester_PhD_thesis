/*
 * PD2.c
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
#include "PD2_dt.h"

/* list of Simulink Desktop Real-Time timers */
const int RTWinTimerCount = 1;
const double RTWinTimers[2] = {
  0.005, 0.0,
};

/* Block signals (auto storage) */
B_PD2_T PD2_B;

/* Continuous states */
X_PD2_T PD2_X;

/* Block states (auto storage) */
DW_PD2_T PD2_DW;

/* Previous zero-crossings (trigger) states */
PrevZCX_PD2_T PD2_PrevZCX;

/* Real-time model */
RT_MODEL_PD2_T PD2_M_;
RT_MODEL_PD2_T *const PD2_M = &PD2_M_;

/*
 * This function updates continuous states using the ODE1 fixed-step
 * solver algorithm
 */
static void rt_ertODEUpdateContinuousStates(RTWSolverInfo *si )
{
  time_T tnew = rtsiGetSolverStopTime(si);
  time_T h = rtsiGetStepSize(si);
  real_T *x = rtsiGetContStates(si);
  ODE1_IntgData *id = (ODE1_IntgData *)rtsiGetSolverData(si);
  real_T *f0 = id->f[0];
  int_T i;
  int_T nXc = 1;
  rtsiSetSimTimeStep(si,MINOR_TIME_STEP);
  rtsiSetdX(si, f0);
  PD2_derivatives();
  rtsiSetT(si, tnew);
  for (i = 0; i < nXc; i++) {
    *x += h * f0[i];
    x++;
  }

  rtsiSetSimTimeStep(si,MAJOR_TIME_STEP);
}

/* Model output function */
void PD2_output(void)
{
  real_T *lastU;
  real_T rtb_AngleEncoder;
  real_T rtb_Abs4;
  real_T rtb_Kxd;
  if (rtmIsMajorTimeStep(PD2_M)) {
    /* set solver stop time */
    if (!(PD2_M->Timing.clockTick0+1)) {
      rtsiSetSolverStopTime(&PD2_M->solverInfo, ((PD2_M->Timing.clockTickH0 + 1)
        * PD2_M->Timing.stepSize0 * 4294967296.0));
    } else {
      rtsiSetSolverStopTime(&PD2_M->solverInfo, ((PD2_M->Timing.clockTick0 + 1) *
        PD2_M->Timing.stepSize0 + PD2_M->Timing.clockTickH0 *
        PD2_M->Timing.stepSize0 * 4294967296.0));
    }
  }                                    /* end MajorTimeStep */

  /* Update absolute time of base rate at minor time step */
  if (rtmIsMinorTimeStep(PD2_M)) {
    PD2_M->Timing.t[0] = rtsiGetT(&PD2_M->solverInfo);
  }

  /* Reset subsysRan breadcrumbs */
  srClearBC(PD2_DW.EnabledSubsystem_SubsysRanBC);

  /* Reset subsysRan breadcrumbs */
  srClearBC(PD2_DW.TriggeredSubsystem_SubsysRanBC);

  /* S-Function Block: <Root>/GT400-SV Initialization (gt_initialize) */
  {
  }

  /* S-Function Block: <S3>/Get Axis' Position1 (gt_getpos) */
  {
    long value;
    if (findcard_tag) {
      if ((PD2_P.GetAxisPosition1_axis) <= 4) {
        WritePort((short)(SET_1 + PD2_P.GetAxisPosition1_axis - 1),0);
        ReadPort(GET_ACTL_POS, value);
      } else {
        WritePort(GET_ENC_POS,(short)( PD2_P.GetAxisPosition1_axis - 5));
        ReadData(value);
      }
    }

    PD2_B.GetAxisPosition1 = value;
  }

  /* Gain: '<S3>/Angle Encoder' */
  rtb_AngleEncoder = PD2_P.AngleEncoder_Gain * PD2_B.GetAxisPosition1;

  /* Sum: '<S1>/Sum' incorporates:
   *  Constant: '<S1>/Angle Ref.'
   */
  PD2_B.Sum = PD2_P.AngleRef_Value - rtb_AngleEncoder;

  /* S-Function Block: <S1>/ -pi~pi (gt_change) */
  {
    double temp;
    temp = PD2_B.Sum;
    while (temp > PI) {
      temp -= 2 * PI;
    }

    while (temp <= -PI) {
      temp += 2 * PI;
    }

    PD2_B.pipi = temp;
  }

  /* Gain: '<S1>/Negative Feedback1' */
  PD2_B.NegativeFeedback1 = PD2_P.NegativeFeedback1_Gain * PD2_B.pipi;
  if (rtmIsMajorTimeStep(PD2_M)) {
  }

  /* S-Function Block: <S3>/Get Axis' Position (gt_getpos) */
  {
    long value;
    if (findcard_tag) {
      if ((PD2_P.GetAxisPosition_axis) <= 4) {
        WritePort((short)(SET_1 + PD2_P.GetAxisPosition_axis - 1),0);
        ReadPort(GET_ACTL_POS, value);
      } else {
        WritePort(GET_ENC_POS,(short)( PD2_P.GetAxisPosition_axis - 5));
        ReadData(value);
      }
    }

    PD2_B.GetAxisPosition = value;
  }

  /* Gain: '<S1>/Negative Feedback' incorporates:
   *  Constant: '<S1>/Pos Ref.'
   *  Gain: '<S3>/Pos Encoder'
   *  Sum: '<S1>/Sum1'
   */
  PD2_B.NegativeFeedback = (PD2_P.PosRef_Value - PD2_P.PosEncoder_Gain *
    PD2_B.GetAxisPosition) * PD2_P.NegativeFeedback_Gain;

  /* Derivative: '<Root>/Derivative1' */
  if ((PD2_DW.TimeStampA >= PD2_M->Timing.t[0]) && (PD2_DW.TimeStampB >=
       PD2_M->Timing.t[0])) {
    rtb_Abs4 = 0.0;
  } else {
    rtb_Abs4 = PD2_DW.TimeStampA;
    lastU = &PD2_DW.LastUAtTimeA;
    if (PD2_DW.TimeStampA < PD2_DW.TimeStampB) {
      if (PD2_DW.TimeStampB < PD2_M->Timing.t[0]) {
        rtb_Abs4 = PD2_DW.TimeStampB;
        lastU = &PD2_DW.LastUAtTimeB;
      }
    } else {
      if (PD2_DW.TimeStampA >= PD2_M->Timing.t[0]) {
        rtb_Abs4 = PD2_DW.TimeStampB;
        lastU = &PD2_DW.LastUAtTimeB;
      }
    }

    rtb_Abs4 = (PD2_B.NegativeFeedback - *lastU) / (PD2_M->Timing.t[0] -
      rtb_Abs4);
  }

  /* End of Derivative: '<Root>/Derivative1' */

  /* Gain: '<Root>/Kxd' */
  rtb_Kxd = PD2_P.Kxd_Gain * rtb_Abs4;

  /* Derivative: '<Root>/Derivative2' */
  if ((PD2_DW.TimeStampA_e >= PD2_M->Timing.t[0]) && (PD2_DW.TimeStampB_i >=
       PD2_M->Timing.t[0])) {
    rtb_Abs4 = 0.0;
  } else {
    rtb_Abs4 = PD2_DW.TimeStampA_e;
    lastU = &PD2_DW.LastUAtTimeA_b;
    if (PD2_DW.TimeStampA_e < PD2_DW.TimeStampB_i) {
      if (PD2_DW.TimeStampB_i < PD2_M->Timing.t[0]) {
        rtb_Abs4 = PD2_DW.TimeStampB_i;
        lastU = &PD2_DW.LastUAtTimeB_c;
      }
    } else {
      if (PD2_DW.TimeStampA_e >= PD2_M->Timing.t[0]) {
        rtb_Abs4 = PD2_DW.TimeStampB_i;
        lastU = &PD2_DW.LastUAtTimeB_c;
      }
    }

    rtb_Abs4 = (PD2_B.NegativeFeedback1 - *lastU) / (PD2_M->Timing.t[0] -
      rtb_Abs4);
  }

  /* End of Derivative: '<Root>/Derivative2' */

  /* Gain: '<Root>/Negative Feedback' incorporates:
   *  Gain: '<Root>/KtP'
   *  Gain: '<Root>/KtPd'
   *  Gain: '<Root>/Kxp'
   *  Sum: '<Root>/Sum2'
   */
  PD2_B.NegativeFeedback_n = (((PD2_P.Kxp_Gain * PD2_B.NegativeFeedback +
    rtb_Kxd) + PD2_P.KtP_Gain * PD2_B.NegativeFeedback1) + PD2_P.KtPd_Gain *
    rtb_Abs4) * PD2_P.NegativeFeedback_Gain_c;
  if (rtmIsMajorTimeStep(PD2_M)) {
  }

  /* Sum: '<S4>/Sum1' incorporates:
   *  Constant: '<S4>/Constant1'
   */
  PD2_B.Sum1 = PD2_P.Constant1_Value - rtb_AngleEncoder;

  /* S-Function Block: <S4>/ -pi~pi (gt_change) */
  {
    double temp;
    temp = PD2_B.Sum1;
    while (temp > PI) {
      temp -= 2 * PI;
    }

    while (temp <= -PI) {
      temp += 2 * PI;
    }

    PD2_B.pipi_p = temp;
  }

  /* RelationalOperator: '<S4>/Relational Operator1' incorporates:
   *  Abs: '<S4>/Abs'
   *  Constant: '<S4>/EntryAngle'
   */
  PD2_B.RelationalOperator1 = (fabs(PD2_B.pipi_p) <= PD2_P.EntryAngle_Value);
  if (rtmIsMajorTimeStep(PD2_M)) {
    /* Outputs for Triggered SubSystem: '<S4>/Triggered Subsystem' incorporates:
     *  TriggerPort: '<S5>/Trigger'
     */
    if (rtmIsMajorTimeStep(PD2_M)) {
      if (PD2_B.RelationalOperator1 && (PD2_PrevZCX.TriggeredSubsystem_Trig_ZCE
           != POS_ZCSIG)) {
        /* Constant: '<S5>/Constant' */
        PD2_B.Constant = PD2_P.Constant_Value;
        PD2_DW.TriggeredSubsystem_SubsysRanBC = 4;
      }

      PD2_PrevZCX.TriggeredSubsystem_Trig_ZCE = PD2_B.RelationalOperator1;
    }

    /* End of Outputs for SubSystem: '<S4>/Triggered Subsystem' */

    /* Outputs for Enabled SubSystem: '<S1>/Enabled Subsystem' incorporates:
     *  EnablePort: '<S2>/Enable'
     */
    if (rtmIsMajorTimeStep(PD2_M)) {
      if (PD2_B.Constant > 0.0) {
        if (!PD2_DW.EnabledSubsystem_MODE) {
          PD2_DW.EnabledSubsystem_MODE = true;
        }
      } else {
        if (PD2_DW.EnabledSubsystem_MODE) {
          PD2_DW.EnabledSubsystem_MODE = false;
        }
      }
    }

    /* End of Outputs for SubSystem: '<S1>/Enabled Subsystem' */
  }

  /* Outputs for Enabled SubSystem: '<S1>/Enabled Subsystem' incorporates:
   *  EnablePort: '<S2>/Enable'
   */
  if (PD2_DW.EnabledSubsystem_MODE) {
    /* Inport: '<S2>/In1' */
    PD2_B.In1 = PD2_B.NegativeFeedback_n;
    if (rtmIsMajorTimeStep(PD2_M)) {
      srUpdateBC(PD2_DW.EnabledSubsystem_SubsysRanBC);
    }
  }

  /* End of Outputs for SubSystem: '<S1>/Enabled Subsystem' */

  /* TransferFcn: '<S3>/Filter1' */
  PD2_B.Filter1 = 0.0;
  PD2_B.Filter1 += PD2_P.Filter1_C * PD2_X.Filter1_CSTATE;

  /* S-Function Block: <S3>/Set Voltage (gt_setmtrcmd) */
  {
    long cmd;
    uint_T status,i;
    long value;
    i = (short)((PD2_P.SetVoltage_P1) - 1);
    if (findcard_tag) {
      cmd = (long)(32767 / 10 * PD2_B.Filter1);
      WritePort((short)(SET_1 + (PD2_P.SetVoltage_P1) - 1),0);
      ReadPort(GET_ACTL_POS,value);
      ReadPort(GET_STATUS, status);
      if ((status & 0x20) == 0x20) {   //positive limit
        positive_limit[i] = 1;
        positive_limit_value[i] = value;
      } else if ((status & 0x40) == 0x40 ) {//negative limit
        negative_limit[i] = 1;
        negative_limit_value[i] = value;
      }

      if (positive_limit[i] == 1) {
        cmd = (long)(-32768 / 10 * PD2_P.SetVoltage_back_cmd);
        if (value < (positive_limit_value[i] - PD2_P.SetVoltage_back_pos)) {
          positive_limit[i] = 0;
          WritePort(SET_1, 0);
          WritePort(AXIS_OFF, 0);
          WritePort(SET_2, 0);
          WritePort(AXIS_OFF, 0);
          WritePort(SET_3, 0);
          WritePort(AXIS_OFF, 0);
          WritePort(SET_4, 0);
          WritePort(AXIS_OFF, 0);
          printf("Attention!!! Axis Off...RESTART AGAIN...\n");
        }
      } else if (negative_limit[i] == 1) {
        cmd = (long)(32767 / 10 * PD2_P.SetVoltage_back_cmd);
        if (value > (negative_limit_value[i] + PD2_P.SetVoltage_back_pos)) {
          negative_limit[i] = 0;
          WritePort(SET_1, 0);
          WritePort(AXIS_OFF, 0);
          WritePort(SET_2, 0);
          WritePort(AXIS_OFF, 0);
          WritePort(SET_3, 0);
          WritePort(AXIS_OFF, 0);
          WritePort(SET_4, 0);
          WritePort(AXIS_OFF, 0);
          printf("Attention!!! Axis Off...RESTART AGAIN...\n");
        }
      }

      WritePort(SET_MTR_CMD, cmd);
      WritePort(CLR_STATUS, 0);
      WritePort(UPDATE, 0);
    }
  }

  /* Gain: '<S3>/Kxp1' */
  PD2_B.Kxp1 = PD2_P.Kxp1_Gain * PD2_B.In1;
  if (rtmIsMajorTimeStep(PD2_M)) {
  }

  /* Logic: '<S4>/Logical Operator3' incorporates:
   *  Abs: '<S4>/Abs4'
   *  Constant: '<S4>/StopAngle'
   *  RelationalOperator: '<S4>/Relational Operator4'
   */
  PD2_B.LogicalOperator3 = ((fabs(PD2_B.pipi_p) >= PD2_P.StopAngle_Value) &&
    (PD2_B.Constant != 0.0));

  /* Stop: '<S4>/Stop Simulation' */
  if (rtmIsMajorTimeStep(PD2_M) && PD2_B.LogicalOperator3) {
    rtmSetStopRequested(PD2_M, 1);
  }

  /* End of Stop: '<S4>/Stop Simulation' */
}

/* Model update function */
void PD2_update(void)
{
  real_T *lastU;

  /* Update for Derivative: '<Root>/Derivative1' */
  if (PD2_DW.TimeStampA == (rtInf)) {
    PD2_DW.TimeStampA = PD2_M->Timing.t[0];
    lastU = &PD2_DW.LastUAtTimeA;
  } else if (PD2_DW.TimeStampB == (rtInf)) {
    PD2_DW.TimeStampB = PD2_M->Timing.t[0];
    lastU = &PD2_DW.LastUAtTimeB;
  } else if (PD2_DW.TimeStampA < PD2_DW.TimeStampB) {
    PD2_DW.TimeStampA = PD2_M->Timing.t[0];
    lastU = &PD2_DW.LastUAtTimeA;
  } else {
    PD2_DW.TimeStampB = PD2_M->Timing.t[0];
    lastU = &PD2_DW.LastUAtTimeB;
  }

  *lastU = PD2_B.NegativeFeedback;

  /* End of Update for Derivative: '<Root>/Derivative1' */

  /* Update for Derivative: '<Root>/Derivative2' */
  if (PD2_DW.TimeStampA_e == (rtInf)) {
    PD2_DW.TimeStampA_e = PD2_M->Timing.t[0];
    lastU = &PD2_DW.LastUAtTimeA_b;
  } else if (PD2_DW.TimeStampB_i == (rtInf)) {
    PD2_DW.TimeStampB_i = PD2_M->Timing.t[0];
    lastU = &PD2_DW.LastUAtTimeB_c;
  } else if (PD2_DW.TimeStampA_e < PD2_DW.TimeStampB_i) {
    PD2_DW.TimeStampA_e = PD2_M->Timing.t[0];
    lastU = &PD2_DW.LastUAtTimeA_b;
  } else {
    PD2_DW.TimeStampB_i = PD2_M->Timing.t[0];
    lastU = &PD2_DW.LastUAtTimeB_c;
  }

  *lastU = PD2_B.NegativeFeedback1;

  /* End of Update for Derivative: '<Root>/Derivative2' */
  if (rtmIsMajorTimeStep(PD2_M)) {
    rt_ertODEUpdateContinuousStates(&PD2_M->solverInfo);
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
  if (!(++PD2_M->Timing.clockTick0)) {
    ++PD2_M->Timing.clockTickH0;
  }

  PD2_M->Timing.t[0] = rtsiGetSolverStopTime(&PD2_M->solverInfo);

  {
    /* Update absolute timer for sample time: [0.005s, 0.0s] */
    /* The "clockTick1" counts the number of times the code of this task has
     * been executed. The absolute time is the multiplication of "clockTick1"
     * and "Timing.stepSize1". Size of "clockTick1" ensures timer will not
     * overflow during the application lifespan selected.
     * Timer of this task consists of two 32 bit unsigned integers.
     * The two integers represent the low bits Timing.clockTick1 and the high bits
     * Timing.clockTickH1. When the low bit overflows to 0, the high bits increment.
     */
    if (!(++PD2_M->Timing.clockTick1)) {
      ++PD2_M->Timing.clockTickH1;
    }

    PD2_M->Timing.t[1] = PD2_M->Timing.clockTick1 * PD2_M->Timing.stepSize1 +
      PD2_M->Timing.clockTickH1 * PD2_M->Timing.stepSize1 * 4294967296.0;
  }
}

/* Derivatives for root system: '<Root>' */
void PD2_derivatives(void)
{
  XDot_PD2_T *_rtXdot;
  _rtXdot = ((XDot_PD2_T *) PD2_M->ModelData.derivs);

  /* Derivatives for TransferFcn: '<S3>/Filter1' */
  _rtXdot->Filter1_CSTATE = 0.0;
  _rtXdot->Filter1_CSTATE += PD2_P.Filter1_A * PD2_X.Filter1_CSTATE;
  _rtXdot->Filter1_CSTATE += PD2_B.Kxp1;
}

/* Model initialize function */
void PD2_initialize(void)
{
  /* S-Function Block: <Root>/GT400-SV Initialization (gt_initialize) */
  {
    uint_T DeviceVendor = 0;
    uint_T io_cf8 = 0x80000000;
    while (1) {
      _outpd( 0xcf8, io_cf8);
      for (icount = 0; icount < 100; icount++) {
        ;
      }

      DeviceVendor = _inpd( 0xcfc);
      if (DeviceVendor == CHECK_NUM) {
        _outpd( 0xcf8, io_cf8 + 4 * 7);
        for (icount = 0; icount < 100; icount++) {
          ;
        }

        baseaddress = ( _inpd( 0xcfc) ) & 0xfffe;
        findcard_tag = 1;
        break;
      } else {
        io_cf8 += 0x800;
        if (io_cf8 >= 0x80ffff00) {
          findcard_tag = 0;
          break;
        }
      }
    }

    if (findcard_tag) {
      WritePort(RESET, 0);
      WritePort(SET_1, 0);
      WritePort(CLR_STATUS, 0);
      WritePort(SET_ENCODER_SENSE, 0);
      WritePort(SET_LMT_SENSE, 255);
      WritePort(LMTS_ON, 0);
      if (PD2_P.GT400SVInitialization_openloop == 0) {
        WritePort(SET_KP, 1);
        WritePort(SET_KI, 1);
        WritePort(SET_KD, 20);
        WritePort(SET_PRFL_VEL, 0);
      } else if (PD2_P.GT400SVInitialization_openloop >= 1) {
        WritePort(OPEN_LOOP, 0);
      }

      WritePort(UPDATE, 0);
      if (PD2_P.GT400SVInitialization_openloop <= 1) {
        WritePort(AXIS_ON, 0);
      }

      WritePort(SET_2, 0);
      WritePort(CLR_STATUS, 0);
      WritePort(SET_ENCODER_SENSE, 0);
      WritePort(SET_LMT_SENSE, 255);
      WritePort(LMTS_ON, 0);
      if (PD2_P.GT400SVInitialization_openloop == 0) {
        WritePort(SET_KP, 3);
        WritePort(SET_KI, 0);
        WritePort(SET_KD, 10);
        WritePort(SET_PRFL_VEL, 0);
      } else if (PD2_P.GT400SVInitialization_openloop == 1) {
        WritePort(OPEN_LOOP, 0);
      }

      WritePort(UPDATE, 0);
      if (PD2_P.GT400SVInitialization_openloop <= 1) {
        WritePort(AXIS_ON, 0);
      }

      WritePort(SET_3, 0);
      WritePort(CLR_STATUS, 0);
      WritePort(SET_ENCODER_SENSE, 0);
      WritePort(SET_LMT_SENSE, 255);
      WritePort(LMTS_ON, 0);
      if (PD2_P.GT400SVInitialization_openloop == 0) {
        WritePort(SET_KP, 3);
        WritePort(SET_KI, 0);
        WritePort(SET_KD, 10);
        WritePort(SET_PRFL_VEL, 0);
      } else if (PD2_P.GT400SVInitialization_openloop == 1) {
        WritePort(OPEN_LOOP, 0);
      }

      WritePort(UPDATE, 0);
      if (PD2_P.GT400SVInitialization_openloop <= 1) {
        WritePort(AXIS_ON, 0);
      }

      WritePort(SET_4, 0);
      WritePort(CLR_STATUS, 0);
      WritePort(SET_ENCODER_SENSE, 0);
      WritePort(SET_LMT_SENSE, 255);
      WritePort(LMTS_ON, 0);
      if (PD2_P.GT400SVInitialization_openloop == 0) {
        WritePort(SET_KP, 3);
        WritePort(SET_KI, 0);
        WritePort(SET_KD, 10);
        WritePort(SET_PRFL_VEL, 0);
      } else if (PD2_P.GT400SVInitialization_openloop == 1) {
        WritePort(OPEN_LOOP, 0);
      }

      WritePort(UPDATE, 0);
      if (PD2_P.GT400SVInitialization_openloop <= 1) {
        WritePort(AXIS_ON, 0);
      }
    }
  }

  /* S-Function Block: <S3>/Get Axis' Position1 (gt_getpos) */
  {
  }

  /* S-Function Block: <S1>/ -pi~pi (gt_change) */
  {
  }

  /* S-Function Block: <S3>/Get Axis' Position (gt_getpos) */
  {
  }

  /* S-Function Block: <S4>/ -pi~pi (gt_change) */
  {
  }

  /* Start for Triggered SubSystem: '<S4>/Triggered Subsystem' */
  /* VirtualOutportStart for Outport: '<S5>/Out1' */
  PD2_B.Constant = PD2_P.Out1_Y0;

  /* End of Start for SubSystem: '<S4>/Triggered Subsystem' */

  /* Start for Enabled SubSystem: '<S1>/Enabled Subsystem' */
  PD2_DW.EnabledSubsystem_MODE = false;

  /* End of Start for SubSystem: '<S1>/Enabled Subsystem' */

  /* S-Function Block: <S3>/Set Voltage (gt_setmtrcmd) */
  {
  }

  PD2_PrevZCX.TriggeredSubsystem_Trig_ZCE = POS_ZCSIG;

  /* InitializeConditions for Derivative: '<Root>/Derivative1' */
  PD2_DW.TimeStampA = (rtInf);
  PD2_DW.TimeStampB = (rtInf);

  /* InitializeConditions for Derivative: '<Root>/Derivative2' */
  PD2_DW.TimeStampA_e = (rtInf);
  PD2_DW.TimeStampB_i = (rtInf);

  /* InitializeConditions for TransferFcn: '<S3>/Filter1' */
  PD2_X.Filter1_CSTATE = 0.0;
}

/* Model terminate function */
void PD2_terminate(void)
{
  /* S-Function Block: <Root>/GT400-SV Initialization (gt_initialize) */
  {
    if (findcard_tag) {
      WritePort(SET_1, 0);
      WritePort(AXIS_OFF, 0);
      WritePort(SET_2, 0);
      WritePort(AXIS_OFF, 0);
      WritePort(SET_3, 0);
      WritePort(AXIS_OFF, 0);
      WritePort(SET_4, 0);
      WritePort(AXIS_OFF, 0);
    }
  }

  /* S-Function Block: <S3>/Get Axis' Position1 (gt_getpos) */
  {
  }

  /* S-Function Block: <S1>/ -pi~pi (gt_change) */
  {
  }

  /* S-Function Block: <S3>/Get Axis' Position (gt_getpos) */
  {
  }

  /* S-Function Block: <S4>/ -pi~pi (gt_change) */
  {
  }

  /* S-Function Block: <S3>/Set Voltage (gt_setmtrcmd) */
  {
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
  PD2_output();
  UNUSED_PARAMETER(tid);
}

void MdlUpdate(int_T tid)
{
  PD2_update();
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
  PD2_initialize();
}

void MdlTerminate(void)
{
  PD2_terminate();
}

/* Registration function */
RT_MODEL_PD2_T *PD2(void)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  /* initialize real-time model */
  (void) memset((void *)PD2_M, 0,
                sizeof(RT_MODEL_PD2_T));

  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&PD2_M->solverInfo, &PD2_M->Timing.simTimeStep);
    rtsiSetTPtr(&PD2_M->solverInfo, &rtmGetTPtr(PD2_M));
    rtsiSetStepSizePtr(&PD2_M->solverInfo, &PD2_M->Timing.stepSize0);
    rtsiSetdXPtr(&PD2_M->solverInfo, &PD2_M->ModelData.derivs);
    rtsiSetContStatesPtr(&PD2_M->solverInfo, (real_T **)
                         &PD2_M->ModelData.contStates);
    rtsiSetNumContStatesPtr(&PD2_M->solverInfo, &PD2_M->Sizes.numContStates);
    rtsiSetErrorStatusPtr(&PD2_M->solverInfo, (&rtmGetErrorStatus(PD2_M)));
    rtsiSetRTModelPtr(&PD2_M->solverInfo, PD2_M);
  }

  rtsiSetSimTimeStep(&PD2_M->solverInfo, MAJOR_TIME_STEP);
  PD2_M->ModelData.intgData.f[0] = PD2_M->ModelData.odeF[0];
  PD2_M->ModelData.contStates = ((real_T *) &PD2_X);
  rtsiSetSolverData(&PD2_M->solverInfo, (void *)&PD2_M->ModelData.intgData);
  rtsiSetSolverName(&PD2_M->solverInfo,"ode1");

  /* Initialize timing info */
  {
    int_T *mdlTsMap = PD2_M->Timing.sampleTimeTaskIDArray;
    mdlTsMap[0] = 0;
    mdlTsMap[1] = 1;
    PD2_M->Timing.sampleTimeTaskIDPtr = (&mdlTsMap[0]);
    PD2_M->Timing.sampleTimes = (&PD2_M->Timing.sampleTimesArray[0]);
    PD2_M->Timing.offsetTimes = (&PD2_M->Timing.offsetTimesArray[0]);

    /* task periods */
    PD2_M->Timing.sampleTimes[0] = (0.0);
    PD2_M->Timing.sampleTimes[1] = (0.005);

    /* task offsets */
    PD2_M->Timing.offsetTimes[0] = (0.0);
    PD2_M->Timing.offsetTimes[1] = (0.0);
  }

  rtmSetTPtr(PD2_M, &PD2_M->Timing.tArray[0]);

  {
    int_T *mdlSampleHits = PD2_M->Timing.sampleHitArray;
    mdlSampleHits[0] = 1;
    mdlSampleHits[1] = 1;
    PD2_M->Timing.sampleHits = (&mdlSampleHits[0]);
  }

  rtmSetTFinal(PD2_M, -1);
  PD2_M->Timing.stepSize0 = 0.005;
  PD2_M->Timing.stepSize1 = 0.005;

  /* External mode info */
  PD2_M->Sizes.checksums[0] = (3046466859U);
  PD2_M->Sizes.checksums[1] = (2952903075U);
  PD2_M->Sizes.checksums[2] = (2703953734U);
  PD2_M->Sizes.checksums[3] = (3757043561U);

  {
    static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE;
    static RTWExtModeInfo rt_ExtModeInfo;
    static const sysRanDType *systemRan[3];
    PD2_M->extModeInfo = (&rt_ExtModeInfo);
    rteiSetSubSystemActiveVectorAddresses(&rt_ExtModeInfo, systemRan);
    systemRan[0] = &rtAlwaysEnabled;
    systemRan[1] = (sysRanDType *)&PD2_DW.EnabledSubsystem_SubsysRanBC;
    systemRan[2] = (sysRanDType *)&PD2_DW.TriggeredSubsystem_SubsysRanBC;
    rteiSetModelMappingInfoPtr(PD2_M->extModeInfo,
      &PD2_M->SpecialInfo.mappingInfo);
    rteiSetChecksumsPtr(PD2_M->extModeInfo, PD2_M->Sizes.checksums);
    rteiSetTPtr(PD2_M->extModeInfo, rtmGetTPtr(PD2_M));
  }

  PD2_M->solverInfoPtr = (&PD2_M->solverInfo);
  PD2_M->Timing.stepSize = (0.005);
  rtsiSetFixedStepSize(&PD2_M->solverInfo, 0.005);
  rtsiSetSolverMode(&PD2_M->solverInfo, SOLVER_MODE_SINGLETASKING);

  /* block I/O */
  PD2_M->ModelData.blockIO = ((void *) &PD2_B);
  (void) memset(((void *) &PD2_B), 0,
                sizeof(B_PD2_T));

  {
    PD2_B.GetAxisPosition1 = 0.0;
    PD2_B.Sum = 0.0;
    PD2_B.pipi = 0.0;
    PD2_B.NegativeFeedback1 = 0.0;
    PD2_B.GetAxisPosition = 0.0;
    PD2_B.NegativeFeedback = 0.0;
    PD2_B.NegativeFeedback_n = 0.0;
    PD2_B.Sum1 = 0.0;
    PD2_B.pipi_p = 0.0;
    PD2_B.Filter1 = 0.0;
    PD2_B.Kxp1 = 0.0;
    PD2_B.Constant = 0.0;
    PD2_B.In1 = 0.0;
  }

  /* parameters */
  PD2_M->ModelData.defaultParam = ((real_T *)&PD2_P);

  /* states (continuous) */
  {
    real_T *x = (real_T *) &PD2_X;
    PD2_M->ModelData.contStates = (x);
    (void) memset((void *)&PD2_X, 0,
                  sizeof(X_PD2_T));
  }

  /* states (dwork) */
  PD2_M->ModelData.dwork = ((void *) &PD2_DW);
  (void) memset((void *)&PD2_DW, 0,
                sizeof(DW_PD2_T));
  PD2_DW.TimeStampA = 0.0;
  PD2_DW.LastUAtTimeA = 0.0;
  PD2_DW.TimeStampB = 0.0;
  PD2_DW.LastUAtTimeB = 0.0;
  PD2_DW.TimeStampA_e = 0.0;
  PD2_DW.LastUAtTimeA_b = 0.0;
  PD2_DW.TimeStampB_i = 0.0;
  PD2_DW.LastUAtTimeB_c = 0.0;

  /* data type transition information */
  {
    static DataTypeTransInfo dtInfo;
    (void) memset((char_T *) &dtInfo, 0,
                  sizeof(dtInfo));
    PD2_M->SpecialInfo.mappingInfo = (&dtInfo);
    dtInfo.numDataTypes = 14;
    dtInfo.dataTypeSizes = &rtDataTypeSizes[0];
    dtInfo.dataTypeNames = &rtDataTypeNames[0];

    /* Block I/O transition table */
    dtInfo.B = &rtBTransTable;

    /* Parameters transition table */
    dtInfo.P = &rtPTransTable;
  }

  /* Initialize Sizes */
  PD2_M->Sizes.numContStates = (1);    /* Number of continuous states */
  PD2_M->Sizes.numPeriodicContStates = (0);/* Number of periodic continuous states */
  PD2_M->Sizes.numY = (0);             /* Number of model outputs */
  PD2_M->Sizes.numU = (0);             /* Number of model inputs */
  PD2_M->Sizes.sysDirFeedThru = (0);   /* The model is not direct feedthrough */
  PD2_M->Sizes.numSampTimes = (2);     /* Number of sample times */
  PD2_M->Sizes.numBlocks = (44);       /* Number of blocks */
  PD2_M->Sizes.numBlockIO = (15);      /* Number of block outputs */
  PD2_M->Sizes.numBlockPrms = (25);    /* Sum of parameter "widths" */
  return PD2_M;
}

/*========================================================================*
 * End of Classic call interface                                          *
 *========================================================================*/

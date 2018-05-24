/*
 * GLM1SIP_LQR_TORQUE2017.c
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
#include "GLM1SIP_LQR_TORQUE2017_dt.h"

/* list of Simulink Desktop Real-Time timers */
const int RTWinTimerCount = 1;
const double RTWinTimers[2] = {
  0.005, 0.0,
};

/* Block signals (auto storage) */
B_GLM1SIP_LQR_TORQUE2017_T GLM1SIP_LQR_TORQUE2017_B;

/* Continuous states */
X_GLM1SIP_LQR_TORQUE2017_T GLM1SIP_LQR_TORQUE2017_X;

/* Block states (auto storage) */
DW_GLM1SIP_LQR_TORQUE2017_T GLM1SIP_LQR_TORQUE2017_DW;

/* Previous zero-crossings (trigger) states */
PrevZCX_GLM1SIP_LQR_TORQUE201_T GLM1SIP_LQR_TORQUE2017_PrevZCX;

/* Real-time model */
RT_MODEL_GLM1SIP_LQR_TORQUE20_T GLM1SIP_LQR_TORQUE2017_M_;
RT_MODEL_GLM1SIP_LQR_TORQUE20_T *const GLM1SIP_LQR_TORQUE2017_M =
  &GLM1SIP_LQR_TORQUE2017_M_;

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
  GLM1SIP_LQR_TORQUE2017_derivatives();
  rtsiSetT(si, tnew);
  for (i = 0; i < nXc; i++) {
    *x += h * f0[i];
    x++;
  }

  rtsiSetSimTimeStep(si,MAJOR_TIME_STEP);
}

/* Model output function */
void GLM1SIP_LQR_TORQUE2017_output(void)
{
  real_T *lastU;
  real_T rtb_Abs4;
  real_T rtb_Derivative1;
  if (rtmIsMajorTimeStep(GLM1SIP_LQR_TORQUE2017_M)) {
    /* set solver stop time */
    if (!(GLM1SIP_LQR_TORQUE2017_M->Timing.clockTick0+1)) {
      rtsiSetSolverStopTime(&GLM1SIP_LQR_TORQUE2017_M->solverInfo,
                            ((GLM1SIP_LQR_TORQUE2017_M->Timing.clockTickH0 + 1) *
        GLM1SIP_LQR_TORQUE2017_M->Timing.stepSize0 * 4294967296.0));
    } else {
      rtsiSetSolverStopTime(&GLM1SIP_LQR_TORQUE2017_M->solverInfo,
                            ((GLM1SIP_LQR_TORQUE2017_M->Timing.clockTick0 + 1) *
        GLM1SIP_LQR_TORQUE2017_M->Timing.stepSize0 +
        GLM1SIP_LQR_TORQUE2017_M->Timing.clockTickH0 *
        GLM1SIP_LQR_TORQUE2017_M->Timing.stepSize0 * 4294967296.0));
    }
  }                                    /* end MajorTimeStep */

  /* Update absolute time of base rate at minor time step */
  if (rtmIsMinorTimeStep(GLM1SIP_LQR_TORQUE2017_M)) {
    GLM1SIP_LQR_TORQUE2017_M->Timing.t[0] = rtsiGetT
      (&GLM1SIP_LQR_TORQUE2017_M->solverInfo);
  }

  /* Reset subsysRan breadcrumbs */
  srClearBC(GLM1SIP_LQR_TORQUE2017_DW.EnabledSubsystem_SubsysRanBC);

  /* Reset subsysRan breadcrumbs */
  srClearBC(GLM1SIP_LQR_TORQUE2017_DW.TriggeredSubsystem_SubsysRanBC);

  /* S-Function Block: <Root>/GT400-SV Initialization (gt_initialize) */
  {
  }

  /* S-Function Block: <S4>/Get Axis' Position1 (gt_getpos) */
  {
    long value;
    if (findcard_tag) {
      if ((GLM1SIP_LQR_TORQUE2017_P.GetAxisPosition1_axis) <= 4) {
        WritePort((short)(SET_1 + GLM1SIP_LQR_TORQUE2017_P.GetAxisPosition1_axis
                          - 1),0);
        ReadPort(GET_ACTL_POS, value);
      } else {
        WritePort(GET_ENC_POS,(short)
                  ( GLM1SIP_LQR_TORQUE2017_P.GetAxisPosition1_axis - 5));
        ReadData(value);
      }
    }

    GLM1SIP_LQR_TORQUE2017_B.GetAxisPosition1 = value;
  }

  /* Sum: '<S2>/Sum' incorporates:
   *  Constant: '<S2>/Angle Ref.1'
   *  Gain: '<S4>/Angle Encoder'
   */
  GLM1SIP_LQR_TORQUE2017_B.Sum = GLM1SIP_LQR_TORQUE2017_P.AngleEncoder_Gain *
    GLM1SIP_LQR_TORQUE2017_B.GetAxisPosition1 +
    GLM1SIP_LQR_TORQUE2017_P.AngleRef1_Value;

  /* Sum: '<Root>/Sum' incorporates:
   *  Constant: '<Root>/Angle Ref.'
   */
  GLM1SIP_LQR_TORQUE2017_B.Sum_h = GLM1SIP_LQR_TORQUE2017_P.AngleRef_Value -
    GLM1SIP_LQR_TORQUE2017_B.Sum;

  /* S-Function Block: <Root>/ -pi~pi (gt_change) */
  {
    double temp;
    temp = GLM1SIP_LQR_TORQUE2017_B.Sum_h;
    while (temp > PI) {
      temp -= 2 * PI;
    }

    while (temp <= -PI) {
      temp += 2 * PI;
    }

    GLM1SIP_LQR_TORQUE2017_B.pipi = temp;
  }

  if (rtmIsMajorTimeStep(GLM1SIP_LQR_TORQUE2017_M)) {
  }

  /* Sin: '<Root>/Sine Wave' */
  GLM1SIP_LQR_TORQUE2017_B.SineWave = sin(GLM1SIP_LQR_TORQUE2017_P.SineWave_Freq
    * GLM1SIP_LQR_TORQUE2017_M->Timing.t[0] +
    GLM1SIP_LQR_TORQUE2017_P.SineWave_Phase) *
    GLM1SIP_LQR_TORQUE2017_P.SineWave_Amp +
    GLM1SIP_LQR_TORQUE2017_P.SineWave_Bias;

  /* S-Function Block: <S4>/Get Axis' Position (gt_getpos) */
  {
    long value;
    if (findcard_tag) {
      if ((GLM1SIP_LQR_TORQUE2017_P.GetAxisPosition_axis) <= 4) {
        WritePort((short)(SET_1 + GLM1SIP_LQR_TORQUE2017_P.GetAxisPosition_axis
                          - 1),0);
        ReadPort(GET_ACTL_POS, value);
      } else {
        WritePort(GET_ENC_POS,(short)
                  ( GLM1SIP_LQR_TORQUE2017_P.GetAxisPosition_axis - 5));
        ReadData(value);
      }
    }

    GLM1SIP_LQR_TORQUE2017_B.GetAxisPosition = value;
  }

  /* Gain: '<S4>/Pos Encoder' */
  GLM1SIP_LQR_TORQUE2017_B.PosEncoder = GLM1SIP_LQR_TORQUE2017_P.PosEncoder_Gain
    * GLM1SIP_LQR_TORQUE2017_B.GetAxisPosition;

  /* Sum: '<Root>/Sum1' incorporates:
   *  Constant: '<Root>/Pos Ref.'
   */
  GLM1SIP_LQR_TORQUE2017_B.Sum1 = (GLM1SIP_LQR_TORQUE2017_B.SineWave +
    GLM1SIP_LQR_TORQUE2017_P.PosRef_Value) - GLM1SIP_LQR_TORQUE2017_B.PosEncoder;

  /* Derivative: '<Root>/Derivative1' */
  if ((GLM1SIP_LQR_TORQUE2017_DW.TimeStampA >=
       GLM1SIP_LQR_TORQUE2017_M->Timing.t[0]) &&
      (GLM1SIP_LQR_TORQUE2017_DW.TimeStampB >=
       GLM1SIP_LQR_TORQUE2017_M->Timing.t[0])) {
    rtb_Derivative1 = 0.0;
  } else {
    rtb_Abs4 = GLM1SIP_LQR_TORQUE2017_DW.TimeStampA;
    lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeA;
    if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampA <
        GLM1SIP_LQR_TORQUE2017_DW.TimeStampB) {
      if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampB <
          GLM1SIP_LQR_TORQUE2017_M->Timing.t[0]) {
        rtb_Abs4 = GLM1SIP_LQR_TORQUE2017_DW.TimeStampB;
        lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeB;
      }
    } else {
      if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampA >=
          GLM1SIP_LQR_TORQUE2017_M->Timing.t[0]) {
        rtb_Abs4 = GLM1SIP_LQR_TORQUE2017_DW.TimeStampB;
        lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeB;
      }
    }

    rtb_Derivative1 = (GLM1SIP_LQR_TORQUE2017_B.Sum1 - *lastU) /
      (GLM1SIP_LQR_TORQUE2017_M->Timing.t[0] - rtb_Abs4);
  }

  /* End of Derivative: '<Root>/Derivative1' */

  /* Derivative: '<Root>/Derivative' */
  if ((GLM1SIP_LQR_TORQUE2017_DW.TimeStampA_i >=
       GLM1SIP_LQR_TORQUE2017_M->Timing.t[0]) &&
      (GLM1SIP_LQR_TORQUE2017_DW.TimeStampB_c >=
       GLM1SIP_LQR_TORQUE2017_M->Timing.t[0])) {
    rtb_Abs4 = 0.0;
  } else {
    rtb_Abs4 = GLM1SIP_LQR_TORQUE2017_DW.TimeStampA_i;
    lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeA_c;
    if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampA_i <
        GLM1SIP_LQR_TORQUE2017_DW.TimeStampB_c) {
      if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampB_c <
          GLM1SIP_LQR_TORQUE2017_M->Timing.t[0]) {
        rtb_Abs4 = GLM1SIP_LQR_TORQUE2017_DW.TimeStampB_c;
        lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeB_b;
      }
    } else {
      if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampA_i >=
          GLM1SIP_LQR_TORQUE2017_M->Timing.t[0]) {
        rtb_Abs4 = GLM1SIP_LQR_TORQUE2017_DW.TimeStampB_c;
        lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeB_b;
      }
    }

    rtb_Abs4 = (GLM1SIP_LQR_TORQUE2017_B.Sum_h - *lastU) /
      (GLM1SIP_LQR_TORQUE2017_M->Timing.t[0] - rtb_Abs4);
  }

  /* End of Derivative: '<Root>/Derivative' */

  /* Gain: '<S1>/LQR' incorporates:
   *  SignalConversion: '<S1>/TmpSignal ConversionAtLQRInport1'
   */
  GLM1SIP_LQR_TORQUE2017_B.LQR = ((GLM1SIP_LQR_TORQUE2017_P.LQR_Gain[0] *
    GLM1SIP_LQR_TORQUE2017_B.Sum1 + GLM1SIP_LQR_TORQUE2017_P.LQR_Gain[1] *
    rtb_Derivative1) + GLM1SIP_LQR_TORQUE2017_P.LQR_Gain[2] *
    GLM1SIP_LQR_TORQUE2017_B.pipi) + GLM1SIP_LQR_TORQUE2017_P.LQR_Gain[3] *
    rtb_Abs4;
  if (rtmIsMajorTimeStep(GLM1SIP_LQR_TORQUE2017_M)) {
  }

  /* Sum: '<S5>/Sum1' incorporates:
   *  Constant: '<S5>/Constant1'
   */
  GLM1SIP_LQR_TORQUE2017_B.Sum1_p = GLM1SIP_LQR_TORQUE2017_P.Constant1_Value -
    GLM1SIP_LQR_TORQUE2017_B.Sum;

  /* S-Function Block: <S5>/ -pi~pi (gt_change) */
  {
    double temp;
    temp = GLM1SIP_LQR_TORQUE2017_B.Sum1_p;
    while (temp > PI) {
      temp -= 2 * PI;
    }

    while (temp <= -PI) {
      temp += 2 * PI;
    }

    GLM1SIP_LQR_TORQUE2017_B.pipi_p = temp;
  }

  /* RelationalOperator: '<S5>/Relational Operator1' incorporates:
   *  Abs: '<S5>/Abs'
   *  Constant: '<S5>/EntryAngle'
   */
  GLM1SIP_LQR_TORQUE2017_B.RelationalOperator1 = (fabs
    (GLM1SIP_LQR_TORQUE2017_B.pipi_p) <=
    GLM1SIP_LQR_TORQUE2017_P.EntryAngle_Value);
  if (rtmIsMajorTimeStep(GLM1SIP_LQR_TORQUE2017_M)) {
    /* Outputs for Triggered SubSystem: '<S5>/Triggered Subsystem' incorporates:
     *  TriggerPort: '<S6>/Trigger'
     */
    if (rtmIsMajorTimeStep(GLM1SIP_LQR_TORQUE2017_M)) {
      if (GLM1SIP_LQR_TORQUE2017_B.RelationalOperator1 &&
          (GLM1SIP_LQR_TORQUE2017_PrevZCX.TriggeredSubsystem_Trig_ZCE !=
           POS_ZCSIG)) {
        /* Constant: '<S6>/Constant' */
        GLM1SIP_LQR_TORQUE2017_B.Constant =
          GLM1SIP_LQR_TORQUE2017_P.Constant_Value;
        GLM1SIP_LQR_TORQUE2017_DW.TriggeredSubsystem_SubsysRanBC = 4;
      }

      GLM1SIP_LQR_TORQUE2017_PrevZCX.TriggeredSubsystem_Trig_ZCE =
        GLM1SIP_LQR_TORQUE2017_B.RelationalOperator1;
    }

    /* End of Outputs for SubSystem: '<S5>/Triggered Subsystem' */

    /* Outputs for Enabled SubSystem: '<S2>/Enabled Subsystem' incorporates:
     *  EnablePort: '<S3>/Enable'
     */
    if (rtmIsMajorTimeStep(GLM1SIP_LQR_TORQUE2017_M)) {
      if (GLM1SIP_LQR_TORQUE2017_B.Constant > 0.0) {
        if (!GLM1SIP_LQR_TORQUE2017_DW.EnabledSubsystem_MODE) {
          GLM1SIP_LQR_TORQUE2017_DW.EnabledSubsystem_MODE = true;
        }
      } else {
        if (GLM1SIP_LQR_TORQUE2017_DW.EnabledSubsystem_MODE) {
          GLM1SIP_LQR_TORQUE2017_DW.EnabledSubsystem_MODE = false;
        }
      }
    }

    /* End of Outputs for SubSystem: '<S2>/Enabled Subsystem' */
  }

  /* Outputs for Enabled SubSystem: '<S2>/Enabled Subsystem' incorporates:
   *  EnablePort: '<S3>/Enable'
   */
  if (GLM1SIP_LQR_TORQUE2017_DW.EnabledSubsystem_MODE) {
    /* Inport: '<S3>/In1' */
    GLM1SIP_LQR_TORQUE2017_B.In1 = GLM1SIP_LQR_TORQUE2017_B.LQR;
    if (rtmIsMajorTimeStep(GLM1SIP_LQR_TORQUE2017_M)) {
      srUpdateBC(GLM1SIP_LQR_TORQUE2017_DW.EnabledSubsystem_SubsysRanBC);
    }
  }

  /* End of Outputs for SubSystem: '<S2>/Enabled Subsystem' */

  /* TransferFcn: '<S4>/Filter' */
  GLM1SIP_LQR_TORQUE2017_B.Filter = 0.0;
  GLM1SIP_LQR_TORQUE2017_B.Filter += GLM1SIP_LQR_TORQUE2017_P.Filter_C *
    GLM1SIP_LQR_TORQUE2017_X.Filter_CSTATE;

  /* S-Function Block: <S4>/Set Voltage (gt_setmtrcmd) */
  {
    long cmd;
    uint_T status,i;
    long value;
    i = (short)((GLM1SIP_LQR_TORQUE2017_P.SetVoltage_P1) - 1);
    if (findcard_tag) {
      cmd = (long)(32767 / 10 * GLM1SIP_LQR_TORQUE2017_B.Filter);
      WritePort((short)(SET_1 + (GLM1SIP_LQR_TORQUE2017_P.SetVoltage_P1) - 1),0);
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
        cmd = (long)(-32768 / 10 * GLM1SIP_LQR_TORQUE2017_P.SetVoltage_back_cmd);
        if (value < (positive_limit_value[i] -
                     GLM1SIP_LQR_TORQUE2017_P.SetVoltage_back_pos)) {
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
        cmd = (long)(32767 / 10 * GLM1SIP_LQR_TORQUE2017_P.SetVoltage_back_cmd);
        if (value > (negative_limit_value[i] +
                     GLM1SIP_LQR_TORQUE2017_P.SetVoltage_back_pos)) {
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

  if (rtmIsMajorTimeStep(GLM1SIP_LQR_TORQUE2017_M)) {
  }

  /* Logic: '<S5>/Logical Operator3' incorporates:
   *  Abs: '<S5>/Abs4'
   *  Constant: '<S5>/StopAngle'
   *  RelationalOperator: '<S5>/Relational Operator4'
   */
  GLM1SIP_LQR_TORQUE2017_B.LogicalOperator3 = ((fabs
    (GLM1SIP_LQR_TORQUE2017_B.pipi_p) >=
    GLM1SIP_LQR_TORQUE2017_P.StopAngle_Value) &&
    (GLM1SIP_LQR_TORQUE2017_B.Constant != 0.0));

  /* Stop: '<S5>/Stop Simulation' */
  if (rtmIsMajorTimeStep(GLM1SIP_LQR_TORQUE2017_M) &&
      GLM1SIP_LQR_TORQUE2017_B.LogicalOperator3) {
    rtmSetStopRequested(GLM1SIP_LQR_TORQUE2017_M, 1);
  }

  /* End of Stop: '<S5>/Stop Simulation' */
}

/* Model update function */
void GLM1SIP_LQR_TORQUE2017_update(void)
{
  real_T *lastU;

  /* Update for Derivative: '<Root>/Derivative1' */
  if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampA == (rtInf)) {
    GLM1SIP_LQR_TORQUE2017_DW.TimeStampA = GLM1SIP_LQR_TORQUE2017_M->Timing.t[0];
    lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeA;
  } else if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampB == (rtInf)) {
    GLM1SIP_LQR_TORQUE2017_DW.TimeStampB = GLM1SIP_LQR_TORQUE2017_M->Timing.t[0];
    lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeB;
  } else if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampA <
             GLM1SIP_LQR_TORQUE2017_DW.TimeStampB) {
    GLM1SIP_LQR_TORQUE2017_DW.TimeStampA = GLM1SIP_LQR_TORQUE2017_M->Timing.t[0];
    lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeA;
  } else {
    GLM1SIP_LQR_TORQUE2017_DW.TimeStampB = GLM1SIP_LQR_TORQUE2017_M->Timing.t[0];
    lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeB;
  }

  *lastU = GLM1SIP_LQR_TORQUE2017_B.Sum1;

  /* End of Update for Derivative: '<Root>/Derivative1' */

  /* Update for Derivative: '<Root>/Derivative' */
  if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampA_i == (rtInf)) {
    GLM1SIP_LQR_TORQUE2017_DW.TimeStampA_i = GLM1SIP_LQR_TORQUE2017_M->Timing.t
      [0];
    lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeA_c;
  } else if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampB_c == (rtInf)) {
    GLM1SIP_LQR_TORQUE2017_DW.TimeStampB_c = GLM1SIP_LQR_TORQUE2017_M->Timing.t
      [0];
    lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeB_b;
  } else if (GLM1SIP_LQR_TORQUE2017_DW.TimeStampA_i <
             GLM1SIP_LQR_TORQUE2017_DW.TimeStampB_c) {
    GLM1SIP_LQR_TORQUE2017_DW.TimeStampA_i = GLM1SIP_LQR_TORQUE2017_M->Timing.t
      [0];
    lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeA_c;
  } else {
    GLM1SIP_LQR_TORQUE2017_DW.TimeStampB_c = GLM1SIP_LQR_TORQUE2017_M->Timing.t
      [0];
    lastU = &GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeB_b;
  }

  *lastU = GLM1SIP_LQR_TORQUE2017_B.Sum_h;

  /* End of Update for Derivative: '<Root>/Derivative' */
  if (rtmIsMajorTimeStep(GLM1SIP_LQR_TORQUE2017_M)) {
    rt_ertODEUpdateContinuousStates(&GLM1SIP_LQR_TORQUE2017_M->solverInfo);
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
  if (!(++GLM1SIP_LQR_TORQUE2017_M->Timing.clockTick0)) {
    ++GLM1SIP_LQR_TORQUE2017_M->Timing.clockTickH0;
  }

  GLM1SIP_LQR_TORQUE2017_M->Timing.t[0] = rtsiGetSolverStopTime
    (&GLM1SIP_LQR_TORQUE2017_M->solverInfo);

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
    if (!(++GLM1SIP_LQR_TORQUE2017_M->Timing.clockTick1)) {
      ++GLM1SIP_LQR_TORQUE2017_M->Timing.clockTickH1;
    }

    GLM1SIP_LQR_TORQUE2017_M->Timing.t[1] =
      GLM1SIP_LQR_TORQUE2017_M->Timing.clockTick1 *
      GLM1SIP_LQR_TORQUE2017_M->Timing.stepSize1 +
      GLM1SIP_LQR_TORQUE2017_M->Timing.clockTickH1 *
      GLM1SIP_LQR_TORQUE2017_M->Timing.stepSize1 * 4294967296.0;
  }
}

/* Derivatives for root system: '<Root>' */
void GLM1SIP_LQR_TORQUE2017_derivatives(void)
{
  XDot_GLM1SIP_LQR_TORQUE2017_T *_rtXdot;
  _rtXdot = ((XDot_GLM1SIP_LQR_TORQUE2017_T *)
             GLM1SIP_LQR_TORQUE2017_M->ModelData.derivs);

  /* Derivatives for TransferFcn: '<S4>/Filter' */
  _rtXdot->Filter_CSTATE = 0.0;
  _rtXdot->Filter_CSTATE += GLM1SIP_LQR_TORQUE2017_P.Filter_A *
    GLM1SIP_LQR_TORQUE2017_X.Filter_CSTATE;
  _rtXdot->Filter_CSTATE += GLM1SIP_LQR_TORQUE2017_B.In1;
}

/* Model initialize function */
void GLM1SIP_LQR_TORQUE2017_initialize(void)
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
      if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop == 0) {
        WritePort(SET_KP, 1);
        WritePort(SET_KI, 1);
        WritePort(SET_KD, 20);
        WritePort(SET_PRFL_VEL, 0);
      } else if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop >= 1) {
        WritePort(OPEN_LOOP, 0);
      }

      WritePort(UPDATE, 0);
      if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop <= 1) {
        WritePort(AXIS_ON, 0);
      }

      WritePort(SET_2, 0);
      WritePort(CLR_STATUS, 0);
      WritePort(SET_ENCODER_SENSE, 0);
      WritePort(SET_LMT_SENSE, 255);
      WritePort(LMTS_ON, 0);
      if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop == 0) {
        WritePort(SET_KP, 3);
        WritePort(SET_KI, 0);
        WritePort(SET_KD, 10);
        WritePort(SET_PRFL_VEL, 0);
      } else if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop == 1) {
        WritePort(OPEN_LOOP, 0);
      }

      WritePort(UPDATE, 0);
      if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop <= 1) {
        WritePort(AXIS_ON, 0);
      }

      WritePort(SET_3, 0);
      WritePort(CLR_STATUS, 0);
      WritePort(SET_ENCODER_SENSE, 0);
      WritePort(SET_LMT_SENSE, 255);
      WritePort(LMTS_ON, 0);
      if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop == 0) {
        WritePort(SET_KP, 3);
        WritePort(SET_KI, 0);
        WritePort(SET_KD, 10);
        WritePort(SET_PRFL_VEL, 0);
      } else if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop == 1) {
        WritePort(OPEN_LOOP, 0);
      }

      WritePort(UPDATE, 0);
      if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop <= 1) {
        WritePort(AXIS_ON, 0);
      }

      WritePort(SET_4, 0);
      WritePort(CLR_STATUS, 0);
      WritePort(SET_ENCODER_SENSE, 0);
      WritePort(SET_LMT_SENSE, 255);
      WritePort(LMTS_ON, 0);
      if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop == 0) {
        WritePort(SET_KP, 3);
        WritePort(SET_KI, 0);
        WritePort(SET_KD, 10);
        WritePort(SET_PRFL_VEL, 0);
      } else if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop == 1) {
        WritePort(OPEN_LOOP, 0);
      }

      WritePort(UPDATE, 0);
      if (GLM1SIP_LQR_TORQUE2017_P.GT400SVInitialization_openloop <= 1) {
        WritePort(AXIS_ON, 0);
      }
    }
  }

  /* S-Function Block: <S4>/Get Axis' Position1 (gt_getpos) */
  {
  }

  /* S-Function Block: <Root>/ -pi~pi (gt_change) */
  {
  }

  /* S-Function Block: <S4>/Get Axis' Position (gt_getpos) */
  {
  }

  /* S-Function Block: <S5>/ -pi~pi (gt_change) */
  {
  }

  /* Start for Triggered SubSystem: '<S5>/Triggered Subsystem' */
  /* VirtualOutportStart for Outport: '<S6>/Out1' */
  GLM1SIP_LQR_TORQUE2017_B.Constant = GLM1SIP_LQR_TORQUE2017_P.Out1_Y0;

  /* End of Start for SubSystem: '<S5>/Triggered Subsystem' */

  /* Start for Enabled SubSystem: '<S2>/Enabled Subsystem' */
  GLM1SIP_LQR_TORQUE2017_DW.EnabledSubsystem_MODE = false;

  /* End of Start for SubSystem: '<S2>/Enabled Subsystem' */

  /* S-Function Block: <S4>/Set Voltage (gt_setmtrcmd) */
  {
  }

  GLM1SIP_LQR_TORQUE2017_PrevZCX.TriggeredSubsystem_Trig_ZCE = POS_ZCSIG;

  /* InitializeConditions for Derivative: '<Root>/Derivative1' */
  GLM1SIP_LQR_TORQUE2017_DW.TimeStampA = (rtInf);
  GLM1SIP_LQR_TORQUE2017_DW.TimeStampB = (rtInf);

  /* InitializeConditions for Derivative: '<Root>/Derivative' */
  GLM1SIP_LQR_TORQUE2017_DW.TimeStampA_i = (rtInf);
  GLM1SIP_LQR_TORQUE2017_DW.TimeStampB_c = (rtInf);

  /* InitializeConditions for TransferFcn: '<S4>/Filter' */
  GLM1SIP_LQR_TORQUE2017_X.Filter_CSTATE = 0.0;
}

/* Model terminate function */
void GLM1SIP_LQR_TORQUE2017_terminate(void)
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

  /* S-Function Block: <S4>/Get Axis' Position1 (gt_getpos) */
  {
  }

  /* S-Function Block: <Root>/ -pi~pi (gt_change) */
  {
  }

  /* S-Function Block: <S4>/Get Axis' Position (gt_getpos) */
  {
  }

  /* S-Function Block: <S5>/ -pi~pi (gt_change) */
  {
  }

  /* S-Function Block: <S4>/Set Voltage (gt_setmtrcmd) */
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
  GLM1SIP_LQR_TORQUE2017_output();
  UNUSED_PARAMETER(tid);
}

void MdlUpdate(int_T tid)
{
  GLM1SIP_LQR_TORQUE2017_update();
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
  GLM1SIP_LQR_TORQUE2017_initialize();
}

void MdlTerminate(void)
{
  GLM1SIP_LQR_TORQUE2017_terminate();
}

/* Registration function */
RT_MODEL_GLM1SIP_LQR_TORQUE20_T *GLM1SIP_LQR_TORQUE2017(void)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  /* initialize real-time model */
  (void) memset((void *)GLM1SIP_LQR_TORQUE2017_M, 0,
                sizeof(RT_MODEL_GLM1SIP_LQR_TORQUE20_T));

  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&GLM1SIP_LQR_TORQUE2017_M->solverInfo,
                          &GLM1SIP_LQR_TORQUE2017_M->Timing.simTimeStep);
    rtsiSetTPtr(&GLM1SIP_LQR_TORQUE2017_M->solverInfo, &rtmGetTPtr
                (GLM1SIP_LQR_TORQUE2017_M));
    rtsiSetStepSizePtr(&GLM1SIP_LQR_TORQUE2017_M->solverInfo,
                       &GLM1SIP_LQR_TORQUE2017_M->Timing.stepSize0);
    rtsiSetdXPtr(&GLM1SIP_LQR_TORQUE2017_M->solverInfo,
                 &GLM1SIP_LQR_TORQUE2017_M->ModelData.derivs);
    rtsiSetContStatesPtr(&GLM1SIP_LQR_TORQUE2017_M->solverInfo, (real_T **)
                         &GLM1SIP_LQR_TORQUE2017_M->ModelData.contStates);
    rtsiSetNumContStatesPtr(&GLM1SIP_LQR_TORQUE2017_M->solverInfo,
      &GLM1SIP_LQR_TORQUE2017_M->Sizes.numContStates);
    rtsiSetErrorStatusPtr(&GLM1SIP_LQR_TORQUE2017_M->solverInfo,
                          (&rtmGetErrorStatus(GLM1SIP_LQR_TORQUE2017_M)));
    rtsiSetRTModelPtr(&GLM1SIP_LQR_TORQUE2017_M->solverInfo,
                      GLM1SIP_LQR_TORQUE2017_M);
  }

  rtsiSetSimTimeStep(&GLM1SIP_LQR_TORQUE2017_M->solverInfo, MAJOR_TIME_STEP);
  GLM1SIP_LQR_TORQUE2017_M->ModelData.intgData.f[0] =
    GLM1SIP_LQR_TORQUE2017_M->ModelData.odeF[0];
  GLM1SIP_LQR_TORQUE2017_M->ModelData.contStates = ((real_T *)
    &GLM1SIP_LQR_TORQUE2017_X);
  rtsiSetSolverData(&GLM1SIP_LQR_TORQUE2017_M->solverInfo, (void *)
                    &GLM1SIP_LQR_TORQUE2017_M->ModelData.intgData);
  rtsiSetSolverName(&GLM1SIP_LQR_TORQUE2017_M->solverInfo,"ode1");

  /* Initialize timing info */
  {
    int_T *mdlTsMap = GLM1SIP_LQR_TORQUE2017_M->Timing.sampleTimeTaskIDArray;
    mdlTsMap[0] = 0;
    mdlTsMap[1] = 1;
    GLM1SIP_LQR_TORQUE2017_M->Timing.sampleTimeTaskIDPtr = (&mdlTsMap[0]);
    GLM1SIP_LQR_TORQUE2017_M->Timing.sampleTimes =
      (&GLM1SIP_LQR_TORQUE2017_M->Timing.sampleTimesArray[0]);
    GLM1SIP_LQR_TORQUE2017_M->Timing.offsetTimes =
      (&GLM1SIP_LQR_TORQUE2017_M->Timing.offsetTimesArray[0]);

    /* task periods */
    GLM1SIP_LQR_TORQUE2017_M->Timing.sampleTimes[0] = (0.0);
    GLM1SIP_LQR_TORQUE2017_M->Timing.sampleTimes[1] = (0.005);

    /* task offsets */
    GLM1SIP_LQR_TORQUE2017_M->Timing.offsetTimes[0] = (0.0);
    GLM1SIP_LQR_TORQUE2017_M->Timing.offsetTimes[1] = (0.0);
  }

  rtmSetTPtr(GLM1SIP_LQR_TORQUE2017_M, &GLM1SIP_LQR_TORQUE2017_M->Timing.tArray
             [0]);

  {
    int_T *mdlSampleHits = GLM1SIP_LQR_TORQUE2017_M->Timing.sampleHitArray;
    mdlSampleHits[0] = 1;
    mdlSampleHits[1] = 1;
    GLM1SIP_LQR_TORQUE2017_M->Timing.sampleHits = (&mdlSampleHits[0]);
  }

  rtmSetTFinal(GLM1SIP_LQR_TORQUE2017_M, -1);
  GLM1SIP_LQR_TORQUE2017_M->Timing.stepSize0 = 0.005;
  GLM1SIP_LQR_TORQUE2017_M->Timing.stepSize1 = 0.005;

  /* External mode info */
  GLM1SIP_LQR_TORQUE2017_M->Sizes.checksums[0] = (3149454345U);
  GLM1SIP_LQR_TORQUE2017_M->Sizes.checksums[1] = (1620804596U);
  GLM1SIP_LQR_TORQUE2017_M->Sizes.checksums[2] = (620839525U);
  GLM1SIP_LQR_TORQUE2017_M->Sizes.checksums[3] = (1122805681U);

  {
    static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE;
    static RTWExtModeInfo rt_ExtModeInfo;
    static const sysRanDType *systemRan[3];
    GLM1SIP_LQR_TORQUE2017_M->extModeInfo = (&rt_ExtModeInfo);
    rteiSetSubSystemActiveVectorAddresses(&rt_ExtModeInfo, systemRan);
    systemRan[0] = &rtAlwaysEnabled;
    systemRan[1] = (sysRanDType *)
      &GLM1SIP_LQR_TORQUE2017_DW.EnabledSubsystem_SubsysRanBC;
    systemRan[2] = (sysRanDType *)
      &GLM1SIP_LQR_TORQUE2017_DW.TriggeredSubsystem_SubsysRanBC;
    rteiSetModelMappingInfoPtr(GLM1SIP_LQR_TORQUE2017_M->extModeInfo,
      &GLM1SIP_LQR_TORQUE2017_M->SpecialInfo.mappingInfo);
    rteiSetChecksumsPtr(GLM1SIP_LQR_TORQUE2017_M->extModeInfo,
                        GLM1SIP_LQR_TORQUE2017_M->Sizes.checksums);
    rteiSetTPtr(GLM1SIP_LQR_TORQUE2017_M->extModeInfo, rtmGetTPtr
                (GLM1SIP_LQR_TORQUE2017_M));
  }

  GLM1SIP_LQR_TORQUE2017_M->solverInfoPtr =
    (&GLM1SIP_LQR_TORQUE2017_M->solverInfo);
  GLM1SIP_LQR_TORQUE2017_M->Timing.stepSize = (0.005);
  rtsiSetFixedStepSize(&GLM1SIP_LQR_TORQUE2017_M->solverInfo, 0.005);
  rtsiSetSolverMode(&GLM1SIP_LQR_TORQUE2017_M->solverInfo,
                    SOLVER_MODE_SINGLETASKING);

  /* block I/O */
  GLM1SIP_LQR_TORQUE2017_M->ModelData.blockIO = ((void *)
    &GLM1SIP_LQR_TORQUE2017_B);
  (void) memset(((void *) &GLM1SIP_LQR_TORQUE2017_B), 0,
                sizeof(B_GLM1SIP_LQR_TORQUE2017_T));

  {
    GLM1SIP_LQR_TORQUE2017_B.GetAxisPosition1 = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.Sum = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.Sum_h = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.pipi = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.SineWave = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.GetAxisPosition = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.PosEncoder = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.Sum1 = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.LQR = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.Sum1_p = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.pipi_p = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.Filter = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.Constant = 0.0;
    GLM1SIP_LQR_TORQUE2017_B.In1 = 0.0;
  }

  /* parameters */
  GLM1SIP_LQR_TORQUE2017_M->ModelData.defaultParam = ((real_T *)
    &GLM1SIP_LQR_TORQUE2017_P);

  /* states (continuous) */
  {
    real_T *x = (real_T *) &GLM1SIP_LQR_TORQUE2017_X;
    GLM1SIP_LQR_TORQUE2017_M->ModelData.contStates = (x);
    (void) memset((void *)&GLM1SIP_LQR_TORQUE2017_X, 0,
                  sizeof(X_GLM1SIP_LQR_TORQUE2017_T));
  }

  /* states (dwork) */
  GLM1SIP_LQR_TORQUE2017_M->ModelData.dwork = ((void *)
    &GLM1SIP_LQR_TORQUE2017_DW);
  (void) memset((void *)&GLM1SIP_LQR_TORQUE2017_DW, 0,
                sizeof(DW_GLM1SIP_LQR_TORQUE2017_T));
  GLM1SIP_LQR_TORQUE2017_DW.TimeStampA = 0.0;
  GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeA = 0.0;
  GLM1SIP_LQR_TORQUE2017_DW.TimeStampB = 0.0;
  GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeB = 0.0;
  GLM1SIP_LQR_TORQUE2017_DW.TimeStampA_i = 0.0;
  GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeA_c = 0.0;
  GLM1SIP_LQR_TORQUE2017_DW.TimeStampB_c = 0.0;
  GLM1SIP_LQR_TORQUE2017_DW.LastUAtTimeB_b = 0.0;

  /* data type transition information */
  {
    static DataTypeTransInfo dtInfo;
    (void) memset((char_T *) &dtInfo, 0,
                  sizeof(dtInfo));
    GLM1SIP_LQR_TORQUE2017_M->SpecialInfo.mappingInfo = (&dtInfo);
    dtInfo.numDataTypes = 14;
    dtInfo.dataTypeSizes = &rtDataTypeSizes[0];
    dtInfo.dataTypeNames = &rtDataTypeNames[0];

    /* Block I/O transition table */
    dtInfo.B = &rtBTransTable;

    /* Parameters transition table */
    dtInfo.P = &rtPTransTable;
  }

  /* Initialize Sizes */
  GLM1SIP_LQR_TORQUE2017_M->Sizes.numContStates = (1);/* Number of continuous states */
  GLM1SIP_LQR_TORQUE2017_M->Sizes.numPeriodicContStates = (0);/* Number of periodic continuous states */
  GLM1SIP_LQR_TORQUE2017_M->Sizes.numY = (0);/* Number of model outputs */
  GLM1SIP_LQR_TORQUE2017_M->Sizes.numU = (0);/* Number of model inputs */
  GLM1SIP_LQR_TORQUE2017_M->Sizes.sysDirFeedThru = (0);/* The model is not direct feedthrough */
  GLM1SIP_LQR_TORQUE2017_M->Sizes.numSampTimes = (2);/* Number of sample times */
  GLM1SIP_LQR_TORQUE2017_M->Sizes.numBlocks = (42);/* Number of blocks */
  GLM1SIP_LQR_TORQUE2017_M->Sizes.numBlockIO = (16);/* Number of block outputs */
  GLM1SIP_LQR_TORQUE2017_M->Sizes.numBlockPrms = (26);/* Sum of parameter "widths" */
  return GLM1SIP_LQR_TORQUE2017_M;
}

/*========================================================================*
 * End of Classic call interface                                          *
 *========================================================================*/

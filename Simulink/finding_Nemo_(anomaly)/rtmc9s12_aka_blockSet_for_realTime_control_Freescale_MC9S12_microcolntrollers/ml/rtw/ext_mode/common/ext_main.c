/*
 * Copyright 1994-2008 The MathWorks, Inc.
 *
 * File: ext_main.c     $Revision: 1.1.6.5 $
 *
 * Abstract:
 * MEX glue for the mechanism to communicate with an externally running, RTW-
 * generated program.  Mechanisms are provided to:
 *  
 *  o download block parameters to the external program
 *  o upload data from the external program to Simulink
 *  o control the target program
 *
 * 
 * Adapted for rtmc9s12 - Target, fw-04-10
 */


#include "extsim.h"           /* ext_mode data struct */


// debug: simulate sequence of events... ---------------------------------------------
//#define SIMSEQUENCEOFACTIONS

#ifdef SIMSEQUENCEOFACTIONS


#define numActions   3

#define esSetAction(ESim, zeAction)  ((ESim)->action = zeAction)

static  unsigned int myActions[numActions]= {
    EXT_CONNECT,
    EXT_SETPARAM,
    EXT_GETPARAMS
};


#endif  /* SIMSEQUENCEOFACTIONS ------------------------------------------------------ */


/*
 * Debugging print statement.
 */
#define EXT_MAIN_DEBUG (0)

#if EXT_MAIN_DEBUG

#define PRINTD(args) mexPrintf args

#else

#define PRINTD(args) /* do nothing */      

#endif


/* Function: ExtCommMain =======================================================
 * Abstract:
 *    Main entry point for external communications processing.
 */
PRIVATE void ExtCommMain(
    int             nlhs, 
    mxArray         *plhs[], 
    int             nrhs, 
    const   mxArray *prhs[]) {
    
    ExternalSim *ES;

    #ifdef SIMSEQUENCEOFACTIONS
    // debug ... 
    int         ii;
    #endif  /*SIMSEQUENCEOFACTIONS */

    // local function name... debugging only
    DEFINE_DEBUG_FNAME("ExtCommMain")

    //PRINT_DEBUG_MSG_LVL1("IN\n");

    /*
     * Simulink directly passes a pointer to the ExternalSim data structure
     * in the plhs array.
     */

    if (nlhs == -1) {

        ES = (ExternalSim*)plhs[0];
        if (((int*)ES)[0] != EXTSIM_VERSION) {
        
            esSetError(ES,
                "\nThe version of the 'ExternalSim' structure passed by "
                "Simulink and the version of the structure used by ext_main.c "
                "are not consistent.  The mex file is either out of date or "
                "built with structure alignment not equal to 8.  Ensure that "
                "the external mode mex file was built using the include file: "
                "<matlabroot>/rtw/ext_mode/common/extsim.h\n.");
                
            goto EXIT_POINT;

        }

        /*
         * Provide Simulink with a direct pointer to this function so that
         * subsequent calls can be made more efficiently.  Do not set this
         * if your version of ext_comm is not "exception free" as described
         * in the documentation for Simulink S-functions.
         * See <matlabroot>/simulink/src/sfuntmpl_doc.c.
         */
        esSetMexFuncGateWayFcn(ES, ExtCommMain);

    } else {

        mexPrintf("This external mex file is used by Simulink in external "
              "mode\nfor communicating with Real-Time Workshop targets "
              "using interprocess communications.\n");
              
        goto EXIT_POINT;

    }


    #ifdef SIMSEQUENCEOFACTIONS
    // debug stage... prenvent code from exiting back to Simulink
    ii = 0;
    do {

        // debug... manually set next action to be performed
        esSetAction(ES, myActions[ii]);
    #endif  /*SIMSEQUENCEOFACTIONS */

        /*
         * Dispatch the packet to appropriate routine in ext_comm.c.
         */
        switch(esGetAction(ES)) {

            case EXT_CONNECT:
            
                /* Connect to target. */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_CONNECT\n");

                HostStatus = HOST_STATUS_CONNECTING;
                PRINT_DEBUG_MSG_LVL1("HOST_STATUS_CONNECTING\n");

                ExtConnect(ES, nrhs, prhs);

                break;

            case EXT_DISCONNECT_REQUEST:

                /* Request to terminate communication has been made - notify target. */
                if (HostStatus != HOST_STATUS_CONNECTING) {

                    PRINT_DEBUG_MSG_NL1;
                    PRINT_DEBUG_MSG_NL1;
                    PRINT_DEBUG_MSG_LVL1("EXT_DISCONNECT_REQUEST\n");

                    ExtDisconnectRequest(ES, nrhs, prhs);
                }

                break;

            case EXT_DISCONNECT_REQUEST_NO_FINAL_UPLOAD:

                /* Request to terminate communication has been made - notify target. */
                if (HostStatus != HOST_STATUS_CONNECTING) {

                    PRINT_DEBUG_MSG_LVL1("EXT_DISCONNECT_REQUEST_NO_FINAL_UPLOAD\n");

                    #ifdef ERASE
                        /* during development: not calling 'ExtDisconnectRequestNoFinalUpload' seems to avoid a crash of the host   --  fw - 07 - 07 */
                        /* during development: not calling 'ExtDisconnectRequestNoFinalUpload' seems to avoid a crash of the host   --  fw - 07 - 07 */
                        /* during development: not calling 'ExtDisconnectRequestNoFinalUpload' seems to avoid a crash of the host   --  fw - 07 - 07 */
                        PRINT_DEBUG_MSG_NL1;
                        PRINT_DEBUG_MSG_LVL1("Ext_main: Not calling ExtDisconnectRequestNoFinalUpload(...)\n");
                        PRINT_DEBUG_MSG_LVL1("Ext_main: Exiting...\n");
                        //        ExtDisconnectRequestNoFinalUpload(ES, nrhs, prhs);
                    #endif

                    ExtDisconnectRequestNoFinalUpload(ES, nrhs, prhs);
                }

                break;

            case EXT_DISCONNECT_CONFIRMED:

                /* Terminate communication with target. */
                PRINT_DEBUG_MSG_LVL1("EXT_DISCONNECT_CONFIRMED\n");

                ExtDisconnectConfirmed(ES, nrhs, prhs);
            
                HostStatus = HOST_STATUS_NOT_CONNECTED;
                PRINT_DEBUG_MSG_LVL1("HOST_STATUS_NOT_CONNECTED\n");

                /* wait half a second... to prevent comms errors when trying to reconnect too quickly */
                //sleep(500);
                //PRINT_DEBUG_MSG_LVL1("after sleep in EXT_DISCONNECT_CONFIRMED\n");
                break;

            case EXT_SETPARAM:

                /* Download parameters to be set on target. */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_SETPARAM\n");
                
                ExtSendGenericPkt(ES, nrhs, prhs);

                break;

            case EXT_GETPARAMS:

                /* Upload interfaceable variables from target. */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_GETPARAM\n");

                ExtGetParams(ES, nrhs, prhs);

                break;

            case EXT_SELECT_SIGNALS:

                /* Select signals for data uploading. */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_SELECT_SIGNALS\n");

                ExtSendGenericPkt(ES, nrhs, prhs);

                break;

            case EXT_SELECT_TRIGGER:

                /* Select signals for data uploading. */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_SELECT_TRIGGER\n");

                ExtSendGenericPkt(ES, nrhs, prhs);

                break;

            case EXT_ARM_TRIGGER:

                /* Select signals for data uploading. */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_ARM_TRIGGER\n");

                ExtSendGenericPkt(ES, nrhs, prhs);

                HostStatus = HOST_STATUS_ARMED;
                PRINT_DEBUG_MSG_LVL1("HOST_STATUS_ARMED\n");

                break;

            case EXT_CANCEL_LOGGING:

                /* Send packet to target to cancel the current data loggin session. */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_CANCEL_LOGGING\n");

                ExtSendGenericPkt(ES, nrhs, prhs);

                HostStatus = HOST_STATUS_NOT_ARMED;
                PRINT_DEBUG_MSG_LVL1("HOST_STATUS_NOT_ARMED\n");

                break;

            case EXT_MODEL_START:

                /* Start the external simulation. */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_MODEL_START\n");

                ExtSendGenericPkt(ES, nrhs, prhs);

                HostStatus = HOST_STATUS_RUNNING;
                PRINT_DEBUG_MSG_LVL1("HOST_STATUS_RUNNING\n");

                break;

            case EXT_MODEL_STOP:

                /* Stop the external simulation and kill target program. */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_MODEL_STOP\n");

                HostStatus = HOST_STATUS_STOPPING;
                PRINT_DEBUG_MSG_LVL1("HOST_STATUS_STOPPING\n");

                ExtSendGenericPkt(ES, nrhs, prhs);

                break;

            case EXT_MODEL_PAUSE:

                /* Pause the target (The MathWorks internal testing only). */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_MODEL_PAUSE\n");

                ExtSendGenericPkt(ES, nrhs, prhs);

                break;

            case EXT_MODEL_STEP:

                /* Run the model for 1 step - if paused (The MathWorks internal
                   testing only). */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_MODEL_STEP\n");

                ExtSendGenericPkt(ES, nrhs, prhs);

                break;

            case EXT_MODEL_CONTINUE:

                /* Run the model for 1 step - if paused (The MathWorks internal
                   testing only). */
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_NL1;
                PRINT_DEBUG_MSG_LVL1("EXT_MODEL_CONTINUE\n");

                ExtSendGenericPkt(ES, nrhs, prhs);

                break;

            case EXT_GET_TIME:

                /*
                 * Request the sim time from the target.
                 *
                 * NOTE:
                 *  Skip verbosity.  There are too many of these packets when
                 *  autoupdating Simulink's status bar clock.
                 */
                #if SEND_GET_TIME_PKTS == 1

                    SWITCH_DYNAMIC_DBG_LVL(4);

                    PRINT_DEBUG_MSG_NL1;
                    PRINT_DEBUG_MSG_NL1;
                    PRINT_DEBUG_MSG_LVL1("EXT_GET_TIME\n");

                    ExtSendGenericPkt(ES, nrhs, prhs);
            
                #endif

                /* do not define DEADLOCK_EMERGENCY !!!  --  fw-07-07 */
                #ifdef DEADLOCK_EMERGENCY

                    /* seems to improve startup... (breaks potential initial deadlock)   --  fw - 07 - 07 */
                    SendBreakDeadlockPktToTarget(ES);

                #endif

                #ifdef ERASE
            
                    PRINT_DEBUG_MSG_LVL1("Ext_main: aborted by the user\n");
                    PRINT_DEBUG_MSG_NL1;
                    esSetError(ES, "Ext_main: aborted by the user\n");
            
                #endif

                break;

            default:

                esSetError(ES, "\nUnrecognized external communication action.");

                goto EXIT_POINT;

        }  /* end switch */

    #ifdef SIMSEQUENCEOFACTIONS

        PRINT_DEBUG_MSG_NL1;
        PRINT_DEBUG_MSG_NL1;
        PRINT_DEBUG_MSG_LVL1("Simulate sequence of events, next message. ======================\n");

    } while (++ii < numActions);

    PRINT_DEBUG_MSG_LVL1("Done simulated sequence of actions -> exiting to Simulink. ======================\n");

    #endif  /*SIMSEQUENCEOFACTIONS */


EXIT_POINT:
   
    //PRINT_DEBUG_MSG_LVL1("OUT\n");
    return;

}  /* end ExtCommMain */


/* Function: mexFunction =======================================================
 * Abstract:
 *    Gateway from Matlab.
 */
void mexFunction(
    int nlhs,
    mxArray *plhs[],
    int nrhs,
    const mxArray *prhs[]) {

    // reset dynamic debug messaging (off)
    SWITCH_DYNAMIC_DBG_LVL(0);
    
    ExtCommMain(nlhs, plhs, nrhs, prhs);

}  /* end mexFunction */


/* [EOF] ext_main.c */

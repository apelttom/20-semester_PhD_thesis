% write file 'mc_defines.h'
%
% Example:
%
% /* automatically generated defines      */
% /* 01-Feb-2009 13:00:02                 */
%
% #ifndef _MC_DEFINES_H_
% #define _MC_DEFINES_H_
%
% /*
%  * hardware selection and debugging
%  *
%  * #define                TARGET_BOARD   BSP_DRAGON12PLUS
%  * #define           TARGET_OSCILLATOR   8
%  * #define                  TARGET_CPU   BSP_MC9S12DP256B
%  * #define           TARGET_CPU_FAMILY   BSP_MC9S12
%  * #define               DEBUG_MSG_LVL   0
%  * #define              DEBUG_MSG_MNGL   0
%  */
% #include "mc_hardware.h"
%
% /* general defines */
% #define                          MODEL   borrar
% #define                            ERT   1
% #define                          NUMST   2
% #define                        TID01EQ   0
% #define                             MT   0
% #define                   MULTITASKING   0
% #define                       MAT_FILE   0
% #define                       NCSTATES   0
% #define                   INTEGER_CODE   0
% #define            MULTI_INSTANCE_CODE   0
% #define                      HAVESTDIO   0
% #define                    USE_RTMODEL   1
% #define                             RT   1
% #define                       EXT_MODE   1
%
% /* model dependent defines */
% #define            USE_TARGET_TIMEOUTS   1
% #define                RUN_IMMEDIATELY   0
% #define                    CIRCBUFSIZE   2000
% #define              DISP_CIRCBUF_FREE   1
% #define                    FIFOBUFSIZE   400
% #define                     FIFOBUFNUM   2
% #define               COMMSTATE_ON_PTT   0
% #define                 EXTMODE_STATIC   1
% #define            EXTMODE_STATIC_SIZE   6500
% #define                       RBUFSIZE   1000
% #define                       BAUDRATE   BAUD_115200
% #define                           idle   0
% #define                           MCOM   1
% #define                           frPT   2
% #define                     SCI0_COMMS   idle
% #define                     SCI1_COMMS   MCOM
% #define         SCI0_FREEPORT_CHANNELS   0
% #define         SCI1_FREEPORT_CHANNELS   0
% #define                  LCDUSE4ERRORS   1
% #define                       MODELSTR   "borrar"
% #define                    RTOSSUPPORT   0
% #define                       CORE_RTI   1
% #define                     CORE_T7ISR   2
% #define                     CORE_TIMER   CORE_RTI
% #define               TIMER_BASEPERIOD   0
% #define                TIMER_PRESCALER   0
% #define           TIMER_PRESCALER_MASK   0
% #define                HAS_TIMERBLOCKS   0x00000000
% #define                     TIMINGSIGS   0
% #define              setCycTiPinOutput   DDRH |=  (0x01<<5) | (0x01<<6)
% #define                    setCycTiPin   PTH  |=  (0x01<<5)
% #define                    clrCycTiPin   PTH  &= ~(0x01<<5)
% #define                    setSerTiPin   PTH  |=  (0x01<<6)
% #define                    clrSerTiPin   PTH  &= ~(0x01<<6)
% #define                        T0_MODE   (HAS_TIMERBLOCKS&0x0000000F)/0x00000001
% #define                        T1_MODE   (HAS_TIMERBLOCKS&0x000000F0)/0x00000010
% #define                        T2_MODE   (HAS_TIMERBLOCKS&0x00000F00)/0x00000100
% #define                        T3_MODE   (HAS_TIMERBLOCKS&0x0000F000)/0x00001000
% #define                        T4_MODE   (HAS_TIMERBLOCKS&0x000F0000)/0x00010000
% #define                        T5_MODE   (HAS_TIMERBLOCKS&0x00F00000)/0x00100000
% #define                        T6_MODE   (HAS_TIMERBLOCKS&0x0F000000)/0x01000000
% #define                        T7_MODE   (HAS_TIMERBLOCKS&0xF0000000)/0x10000000
% #define                    HAS_RFCOMMS   0
% #define                   CLIENT_COUNT   0
% #define                        HAS_SPI   0
%
% /* eliminate preprocessor warnings */
% #define                   __BORLANDC__   0
% #define                    __WATCOMC__   0
%
% /*
%  * central include file for system definitions such as the
%  * - useful global macros (hidef.h)
%  * - configuration of the board support package (bsp_cfg.h)
%  * - taget specific data types (bsp_dtypes.h)
%  * - special function registers for the chosen micro (e.g. mc9s12dp256.h)
%  */
% #include "bsp_includes.h"
%
% #endif /* _MC_DEFINES_H_ */


function mc_gen_mc_defines_h

global mcBuildPars;


% define HW dependent defines as cell array
hwDefs = { ...
    '/* hardware selection and debugging */', ''; ...
    'TARGET_BOARD', mc_interpreteUserOption(mcBuildPars.resources.TargetBoard); ...
    'TARGET_OSCILLATOR', mc_interpreteUserOption(mcBuildPars.resources.Oscillator); ...
    'TARGET_CPU', mc_interpreteUserOption(mcBuildPars.resources.mcType); ...
    'TARGET_CPU_FAMILY', mc_interpreteUserOption(mcBuildPars.resources.mcType, 'cpuFamily'); ...
    'DEBUG_MSG_LVL', mc_interpreteUserOption(mcBuildPars.resources.DEBUG_MSG_LVL); ...
    'DEBUG_MSG_MNGL', mc_interpreteUserOption(mcBuildPars.resources.DEBUG_MSG_MNGL)
    };

% define (HW &) model dependent defines as cell array
mdlDefs = { ...
    '/* general defines */', ''; ...
    'MODEL', mcBuildPars.modelName; ...
    'ERT', '1'; ...
    'NUMST', mc_interpreteUserOption(mcBuildPars.codeGenerator.buildOpts.numst); ...
    'TID01EQ', mc_interpreteUserOption(mcBuildPars.codeGenerator.buildOpts.tid01eq); ...
    'MT', num2str(strcmp(mcBuildPars.codeGenerator.buildOpts.solverMode, 'MultiTasking')); ...
    'MULTITASKING', num2str(strcmp(mcBuildPars.codeGenerator.buildOpts.solverMode, 'MultiTasking')); ...
    'MAT_FILE', '0'; ...
    'NCSTATES', mc_interpreteUserOption(mcBuildPars.codeGenerator.buildOpts.ncstates); ...
    'INTEGER_CODE', '0'; ...
    'MULTI_INSTANCE_CODE', '0'; ...
    'HAVESTDIO', '0'; ...
    'USE_RTMODEL', '1'; ...
    'RT', '1'; ...
    'EXT_MODE', mc_interpreteUserOption(mcBuildPars.resources.ExtMode); ...
    '', ''; ...
    '/* model dependent defines */', ''; ...
    'USE_TARGET_TIMEOUTS', '1'; ...
    'RUN_IMMEDIATELY', mc_interpreteUserOption(mcBuildPars.resources.RunImmediately); ...
    'CIRCBUFSIZE', mc_interpreteUserOption(mcBuildPars.resources.ExtModeTxBufSize); ...
    'DISP_CIRCBUF_FREE', mc_interpreteUserOption(mcBuildPars.resources.ExtModeBufSizeDisp); ...
    'FIFOBUFSIZE', mc_interpreteUserOption(mcBuildPars.resources.ExtModeFifoBufSize); ...
    'FIFOBUFNUM', mc_interpreteUserOption(mcBuildPars.resources.ExtModeFifoBufNum); ...
    'COMMSTATE_ON_PTT', mc_interpreteUserOption(mcBuildPars.resources.ExtModeDispCommStatePTT); ...
    'EXTMODE_STATIC', mc_interpreteUserOption(mcBuildPars.resources.ExtModeStatMemAlloc); ...
    'EXTMODE_STATIC_SIZE', mc_interpreteUserOption(mcBuildPars.resources.ExtModeStatMemSize); ...
    'RBUFSIZE', mc_interpreteUserOption(mcBuildPars.resources.ExtModeRxBufSize); ...
    'BAUDRATE', ['BAUD_' mc_interpreteUserOption(mcBuildPars.resources.ExtModeBaudrate)]; ...
    'idle', '0'; ...
    'MCOM', '1'; ...
    'frPT', '2'; ...
    'SCI0_COMMS', mc_interpreteUserOption(mcBuildPars.resources.SCI0); ...
    'SCI1_COMMS', mc_interpreteUserOption(mcBuildPars.resources.SCI1); ...
    'SCI0_FREEPORT_CHANNELS', mc_interpreteUserOption(mcBuildPars.resources.NumFreePortSCI0); ...
    'SCI1_FREEPORT_CHANNELS', mc_interpreteUserOption(mcBuildPars.resources.NumFreePortSCI0); ...
    'LCDUSE4ERRORS', mc_interpreteUserOption(mcBuildPars.resources.LCDMsgs); ...
    'MODELSTR', ['"' mcBuildPars.modelName '"']; ...
    'RTOSSUPPORT', mc_interpreteUserOption(mcBuildPars.resources.RTOSsupport); ...
    'CORE_RTI', '1'; ...
    'CORE_T7ISR', '2'; ...
    'CORE_TIMER', mc_interpreteUserOption(mcBuildPars.resources.CoreTimer); ...
    'TIMER_BASEPERIOD', mc_interpreteUserOption(mcBuildPars.resources.TimerBasePeriod); ...
    'TIMER_PRESCALER', mc_interpreteUserOption(mcBuildPars.resources.TimerPrescaler); ...
    'TIMER_PRESCALER_MASK', mc_interpreteUserOption(mcBuildPars.resources.TimerPrescalerMask); ...
    'HAS_TIMERBLOCKS', mc_interpreteUserOption(mcBuildPars.resources.HasTimers); ...
    'TIMINGSIGS', mc_interpreteUserOption(mcBuildPars.resources.TimingSigs); ...
    'setCycTiPinOutput', [regexprep(mcBuildPars.resources.TimingSigsPort, '\w+(\w)', 'DDR$1') ...
    ' |=  (0x01<<' num2str(mcBuildPars.resources.CycleTimePin) ')' ' | ' ...
    '(0x01<<' num2str(mcBuildPars.resources.SerialRxPin) ')' ]; ...
    'setCycTiPin', [mcBuildPars.resources.TimingSigsPort '  |=  (0x01<<' num2str(mcBuildPars.resources.CycleTimePin) ')']; ...
    'clrCycTiPin', [mcBuildPars.resources.TimingSigsPort '  &= ~(0x01<<' num2str(mcBuildPars.resources.CycleTimePin) ')']; ...
    'setSerTiPin', [mcBuildPars.resources.TimingSigsPort '  |=  (0x01<<' num2str(mcBuildPars.resources.SerialRxPin) ')']; ...
    'clrSerTiPin', [mcBuildPars.resources.TimingSigsPort '  &= ~(0x01<<' num2str(mcBuildPars.resources.SerialRxPin) ')']; ...
    'T0_MODE', '(HAS_TIMERBLOCKS&0x0000000F)/0x00000001'; ...
    'T1_MODE', '(HAS_TIMERBLOCKS&0x000000F0)/0x00000010'; ...
    'T2_MODE', '(HAS_TIMERBLOCKS&0x00000F00)/0x00000100'; ...
    'T3_MODE', '(HAS_TIMERBLOCKS&0x0000F000)/0x00001000'; ...
    'T4_MODE', '(HAS_TIMERBLOCKS&0x000F0000)/0x00010000'; ...
    'T5_MODE', '(HAS_TIMERBLOCKS&0x00F00000)/0x00100000'; ...
    'T6_MODE', '(HAS_TIMERBLOCKS&0x0F000000)/0x01000000'; ...
    'T7_MODE', '(HAS_TIMERBLOCKS&0xF0000000)/0x10000000'; ...
    'HAS_RFCOMMS', mc_interpreteUserOption(mcBuildPars.resources.HasRFComms); ...
    'CLIENT_COUNT', mc_interpreteUserOption(mcBuildPars.resources.RFCommsServerChannels); ...
    'HAS_SPI', num2str(any(str2double(mc_interpreteUserOption(mcBuildPars.resources.HasRFComms))) ...
    | any(str2double(mc_interpreteUserOption(mcBuildPars.resources.HasOnBoardDAC)))); ...
    '', ''; ...
    '/* eliminate preprocessor warnings */', ''; ...
    '__BORLANDC__', '0'; ...
    '__WATCOMC__', '0' ...
    };



%% write options to 'mc_hw_defines.h'
disp('### Writing hardware dependent / debugging options to file ''mc_hw_defines.h''.')

% open file 'mc_hw_defines.h'
fid = fopen(fullfile(pwd, 'mc_hw_defines.h'), 'w');


% --------------------------------------------------------------------
% /* automatically generated defines */
% #ifndef _MC_HW_DEFINES_H_
% #define _MC_HW_DEFINES_H_
%
k1 = '/* automatically generated defines';
k2 = '*/';
k3 = ['/* ' datestr(now)];
k4 = '*/';
k5 = '#ifndef _MC_HW_DEFINES_H_';
k6 = '#define _MC_HW_DEFINES_H_';
kk = sprintf('%-40s%s\n%-40s%s\n\n%s\n%s\n\n', k1, k2, k3, k4, k5, k6);
fwrite(fid, kk);
% --------------------------------------------------------------------


% --------------------------------------------------------------------
% loop over all HW defines
for ii = 1:size(hwDefs, 1)
    
    % fetch next define
    currDef = hwDefs{ii, 1};
    
    % fetch next value
    currVal = hwDefs{ii, 2};
    
    % comment or empty line?
    if isempty(currDef) || ~isempty(findstr(currDef, '/*'))
        
        % yes -> just output contents of 'currDef'
        outLine = sprintf('%s\n', currDef);
        
    else
        
        % no -> #define...
        %outLine = sprintf('#define %-30s   %s\n', currDef, currVal);
        outLine = sprintf('#define %30s   %s\n', currDef, currVal);
        
    end
    
    % write line
    fwrite(fid, outLine);
    
end  % hwDefs
% --------------------------------------------------------------------


% --------------------------------------------------------------------
%
% #endif /* _MC_DEFINES_H_ */

kk  = sprintf('\n\n%s\n', '#endif /* _MC_HW_DEFINES_H_ */');
fwrite(fid, kk);
% --------------------------------------------------------------------


% close file 'mc_hw_defines.h'
fclose(fid);


%% write options to 'mc_defines.h'
disp('### Writing model/hardware dependent options to file ''mc_defines.h''.')


% open file 'mc_defines.h'
fid = fopen(fullfile(pwd, 'mc_defines.h'), 'w');


% --------------------------------------------------------------------
% /* automatically generated defines */
% #ifndef _MC_DEFINES_H_
% #define _MC_DEFINES_H_
%
k1 = '/* automatically generated defines';
k2 = '*/';
k3 = ['/* ' datestr(now)];
k4 = '*/';
k5 = '#ifndef _MC_DEFINES_H_';
k6 = '#define _MC_DEFINES_H_';
kk = sprintf('%-40s%s\n%-40s%s\n\n%s\n%s\n\n', k1, k2, k3, k4, k5, k6);
fwrite(fid, kk);
% --------------------------------------------------------------------


% --------------------------------------------------------------------
% /*
%  * hardware selection and debugging
%  *
%  * #define                   TARGET_BOARD ...',
%  * #define              TARGET_OSCILLATOR ...',
%  * #define                     TARGET_CPU ...',
%  * #define              TARGET_CPU_FAMILY ...',
%  * #define                  DEBUG_MSG_LVL ...',
%  * #define                 DEBUG_MSG_MNGL ...',
%  */'
% #include "mc_hw_defines.h"
%
k1  =         '/* ';
k2  =         ' * hardware selection and debugging';
k3  =         ' * ';
k4  = sprintf('%s%30s  %s', ' * #define', 'TARGET_BOARD',      mc_interpreteUserOption(mcBuildPars.resources.TargetBoard));
k5  = sprintf('%s%30s  %s', ' * #define', 'TARGET_OSCILLATOR', mc_interpreteUserOption(mcBuildPars.resources.Oscillator));
k6  = sprintf('%s%30s  %s', ' * #define', 'TARGET_CPU',        mc_interpreteUserOption(mcBuildPars.resources.mcType));
k7  = sprintf('%s%30s  %s', ' * #define', 'TARGET_CPU_FAMILY', mc_interpreteUserOption(mcBuildPars.resources.mcType, 'cpuFamily'));
k8  = sprintf('%s%30s  %s', ' * #define', 'DEBUG_MSG_LVL',     mc_interpreteUserOption(mcBuildPars.resources.DEBUG_MSG_LVL));
k9  = sprintf('%s%30s  %s', ' * #define', 'DEBUG_MSG_LVL',     mc_interpreteUserOption(mcBuildPars.resources.DEBUG_MSG_MNGL));
k10 =         ' */';
k11 =         '#include "mc_hw_defines.h"';
kk = sprintf(...
    '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n\n', ...
    k1, k2, k3, k4, k5, k6, k7, k8, k9, k10, k11);
fwrite(fid, kk);
% --------------------------------------------------------------------


% --------------------------------------------------------------------
% loop over all defines
for ii = 1:size(mdlDefs, 1)
    
    % fetch next define
    currDef = mdlDefs{ii, 1};
    
    % fetch next value
    currVal = mdlDefs{ii, 2};
    
    % comment or empty line?
    if isempty(currDef) || ~isempty(findstr(currDef, '/*'))
        
        % yes -> just output contents of 'currDef'
        outLine = sprintf('%s\n', currDef);
        
    else
        
        % no -> #define...
        %outLine = sprintf('#define %-30s   %s\n', currDef, currVal);
        outLine = sprintf('#define %30s   %s\n', currDef, currVal);
        
    end
    
    % write line
    fwrite(fid, outLine);
    
end  % mdlDefs
% --------------------------------------------------------------------


% --------------------------------------------------------------------
% /*
%  * central include file for system definitions such as the
%  * - useful global macros (hidef.h)
%  * - configuration of the board support package (bsp_cfg.h)
%  * - taget specific data types (bsp_dtypes.h)
%  * - special function registers for the chosen micro (e.g. mc9s12dp256.h)
%  */
% #include "includes.h"
%
% #endif /* _MC_DEFINES_H_ */

k1  = '';
k2  = '/*';
k3  = ' * central include file for system definitions such as the ';
k4  = ' * - useful global macros (hidef.h) ';
k5  = ' * - configuration of the board support package (bsp_cfg.h) ';
k6  = ' * - taget specific data types (bsp_dtypes.h)';
k7  = ' * - special function registers for the chosen micro (e.g. mc9s12dp256.h)';
k8  = ' */';
k9  = '#include "bsp_includes.h"';
k10 = '#endif /* _MC_DEFINES_H_ */';
kk  = sprintf('\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n\n%s\n', k1, k2, k3, k4, k5, k6, k7, k8, k9, k10);
fwrite(fid, kk);
% --------------------------------------------------------------------


% close file 'mc_defines.h'
fclose(fid);

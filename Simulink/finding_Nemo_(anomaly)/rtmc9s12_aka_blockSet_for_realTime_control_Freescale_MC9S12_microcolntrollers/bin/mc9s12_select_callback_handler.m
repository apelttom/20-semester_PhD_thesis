% mc9s12_SELECT_CALLBACK_HANDLER callback handler for 9S12 real-time options
%
% To display all options properties enter
% slConfigUIGetVal(hDlg, hSrc, 'ObjectParameters')
%
% fw-04-10

function mc9s12_select_callback_handler(hDlg, hSrc)

% this section is only ever run once - in theory this should perform
% the necessary conversion from a older model to an R2009b model...
kk = getActiveConfigSet(gcs);

if ~strcmp(kk.Description, 'rtmc9s12target_R2009b')

    % ERT only... not needed in GRT mode  -  fw-06-07
    %
    %     slConfigUISetVal(hDlg, hSrc, 'myExtMode', 'on');
    %     slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtMode', 0);
    %     slConfigUISetEnabled(hDlg, hSrc, 'ExtModeTransport', 0);

    % get original setting of 'ExtMode'
    % ExtMode = slConfigUIGetVal(hDlg, hSrc, 'ExtMode');

    % always activate 'mc9s12_ExtMode'
    % slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtMode', 'on');
    
    % lock/unlock debug message mangling option
    dbgLvl = str2double(slConfigUIGetVal(hDlg, hSrc, 'mc9s12_DEBUG_MSG_LVL'));
    
    % debug messaging?
    if dbgLvl > 0
        
        % yes -> unlock mangling option
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_DEBUG_MSG_MNGL', 1);
        
    else
        
        % nope -> lock mangling option
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_DEBUG_MSG_MNGL', 0);
        
    end
    
    
    % RTOS support (currently) implies the use of RTI
    rtosSupportEnabled  = strcmp(slConfigUIGetVal(hDlg, hSrc, 'mc9s12_RTOSsupport'), 'on');
    usingRTIasCoreTimer = strcmp(slConfigUIGetVal(hDlg, hSrc, 'mc9s12_CoreTimer'), 'RTI');
    
    % RTOS support requested while using TC7 as core timer?
    if rtosSupportEnabled && ~usingRTIasCoreTimer
        
        % yep -> set core timer to RTI
        disp('Enabling RTOS support implies the use of RTI as core timer - setting CoreTimer to RTI.')
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_CoreTimer', 'RTI');
        
    end
        
    
    % debug messaging?
    if dbgLvl > 0
        
        % yes -> unlock mangling option
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_DEBUG_MSG_MNGL', 1);
        
    else
        
        % nope -> lock mangling option
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_DEBUG_MSG_MNGL', 0);
        
    end
    
    
    % activate 'mc9s12_ExtModeBaudrate' selection and 'host/target port'
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeRxBufSize', 1);
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize', 1);
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeBufSizeDisp', 1);
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize', 1);
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufNum', 1);
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_MemModel', 1);
    
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeDispCommStatePTT', 1);
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeBaudrate', 1);
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 1);
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 1);
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemAlloc', 1);
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', 1);
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatusBarClk', 1);


    % the following settings are target dependent...
    target = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_TargetBoard');

    if strcmp(target, 'Dragon12Plus')

        % --  Dragon12Plus  --

        % select oscillator frequency (fixed)
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_Oscillator', '8 MHz');
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_Oscillator', 0);

        % select SCI1 as MATLAB_SCI_PORT
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI1');

        % select default serial port on the host : COM2
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 'COM2');
        disp('Setting host sided communication port to COM2 (default for Dragon12)')

        % enable LCD error messages (default for Dragon12)
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_LCDMsgs', 'on');

        % Setup memory management variables
        % NOTE: the following buffers are allocated... the sum of all
        %       buffer sizes needs to be less than 'mc9s12_ExtModeStatMemSize':
        %       Target reception buffer (RB): 1k
        %       Target transmission buffer (circBuf): 2k
        %       Reception FIFOs ((mc9s12_ExtModeFifoBufNum + 2) * mc9s12_ExtModeFifoBufSize): 7 * 0.4k = 2.8k
        %
        % i_setupMemoryManagement(hDlg, hSrc, statMemSize, rxBufSize, txBufSize, fifoBufSize, fifoBufBatchSize)
        i_setupMemoryManagement(hDlg, hSrc, 6500, 1000, 2000, 300, 2)
    
    end

    if strcmp(target, 'Dragon12')

        % --  Dragon12  --

        % select oscillator frequency (fixed)
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_Oscillator', '4 MHz');
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_Oscillator', 0);

        % select SCI1 as MATLAB_SCI_PORT
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI1');

        % select default serial port on the host : COM2
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 'COM2');
        disp('Setting host sided communication port to COM2 (default for Dragon12)')

        % enable LCD error messages (default for Dragon12)
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_LCDMsgs', 'on');

        % Setup memory management variables
        % NOTE: the following buffers are allocated... the sum of all
        %       buffer sizes needs to be less than 'mc9s12_ExtModeStatMemSize':
        %       Target reception buffer (RB): 1k
        %       Target transmission buffer (circBuf): 2k
        %       Reception FIFOs ((mc9s12_ExtModeFifoBufNum + 2) * mc9s12_ExtModeFifoBufSize): 7 * 0.4k = 2.8k
        %
        % i_setupMemoryManagement(hDlg, hSrc, statMemSize, rxBufSize, txBufSize, fifoBufSize, fifoBufBatchSize)
        i_setupMemoryManagement(hDlg, hSrc, 6500, 1000, 2000, 300, 2)
    
    end

    if strcmp(target, 'MiniDragonPlus')

        % --  MiniDragonPlus  --

        % select oscillator frequency (fixed)
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_Oscillator', '16 MHz');
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_Oscillator', 0);

        % switch off debugging through SCI0 (if required)
        dbgmsgSCI0 = str2double(slConfigUIGetVal(hDlg, hSrc, 'mc9s12_DEBUG_MSG_LVL'));
        if(dbgmsgSCI0 > 0)
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_DEBUG_MSG_LVL', 0);
            disp('Warning: Disabling debug messages through SCI0 (not used on the MiniDragonPlus)')
        end

        % switch off error messages on the LCD
        errmsgLCD = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_LCDMsgs');
        if(strcmp(errmsgLCD, 'on'))
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_LCDMsgs', 'off');
            disp('Warning: Disabling LCD display based error messages (not supported on the MiniDragonPlus)')
        end

        % select SCI0 as MATLAB_SCI_PORT
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI0');

        % select default serial port on the host : COM1
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 'COM1');
        disp('Setting host sided communication port to COM1 (default for MiniDragonPlus)')

        % Setup memory management variables
        % NOTE: the following buffers are allocated... the sum of all
        %       buffer sizes needs to be less than 'mc9s12_ExtModeStatMemSize':
        %       Target reception buffer (RB): 1k
        %       Target transmission buffer (circBuf): 2k
        %       Reception FIFOs ((mc9s12_ExtModeFifoBufNum + 2) * mc9s12_ExtModeFifoBufSize): 7 * 0.4k = 2.8k
        %
        % i_setupMemoryManagement(hDlg, hSrc, statMemSize, rxBufSize, txBufSize, fifoBufSize, fifoBufBatchSize)
        i_setupMemoryManagement(hDlg, hSrc, 6500, 1000, 2000, 300, 2)
    
    end

    if strcmp(target, 'MiniDragonPlus-RevE')

        % --  University of Adelaide, mobile robot (MiniDragonPlus Rev.E based, download via SCI0, communication w/h MATLAB through SCI1) --

        % select oscillator frequency (fixed)
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_Oscillator', '16 MHz');
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_Oscillator', 0);

        % switch off debugging through SCI0 (if required)
        dbgmsgSCI0 = str2double(slConfigUIGetVal(hDlg, hSrc, 'mc9s12_DEBUG_MSG_LVL'));
        if(dbgmsgSCI0 > 0)
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_DEBUG_MSG_LVL', 0);
            disp('Warning: Disabling debug messages through SCI0 (not used on the MiniDragonPlus)')
        end

        % switch off error messages on the LCD
        errmsgLCD = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_LCDMsgs');
        if(strcmp(errmsgLCD, 'on'))
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_LCDMsgs', 'off');
            disp('Warning: Disabling LCD display based error messages (not supported on the MiniDragonPlus)')
        end

        % select SCI1 as MATLAB_SCI_PORT
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI1');

        % select default serial port on the host : COM2
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 'COM2');
        disp('Setting host sided communication port to COM2 (default for UofA mobile robot)')

        % Setup memory management variables
        % NOTE: the following buffers are allocated... the sum of all
        %       buffer sizes needs to be less than 'mc9s12_ExtModeStatMemSize':
        %       Target reception buffer (RB): 1k
        %       Target transmission buffer (circBuf): 2k
        %       Reception FIFOs ((mc9s12_ExtModeFifoBufNum + 2) * mc9s12_ExtModeFifoBufSize): 7 * 0.4k = 2.8k
        %
        % i_setupMemoryManagement(hDlg, hSrc, statMemSize, rxBufSize, txBufSize, fifoBufSize, fifoBufBatchSize)
        i_setupMemoryManagement(hDlg, hSrc, 6500, 1000, 2000, 300, 2)

    end

    if(strcmp(target, 'DragonFly12-C128'))

        % --  C128 based targets  --

        % select oscillator frequency (fixed)
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_Oscillator', '8 MHz');
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_Oscillator', 0);

        % switch off debugging through SCI0 (if required)
        dbgmsgSCI0 = str2double(slConfigUIGetVal(hDlg, hSrc, 'mc9s12_DEBUG_MSG_LVL'));
        if(dbgmsgSCI0 > 0)
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_DEBUG_MSG_LVL', 0);
            disp('Warning: Disabling debug messages through SCI0 (not used on C128 based targets)')
        end

        % switch off error messages on the LCD
        errmsgLCD = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_LCDMsgs');
        if(strcmp(errmsgLCD, 'on'))
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_LCDMsgs', 'off');
            disp('Warning: Disabling LCD display based error messages (default on C128 based targets)')
        end

        % select SCI0 as MATLAB_SCI_PORT
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI0');

        % select default serial port on the host : COM1
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 'COM1');
        disp('Setting host sided communication port to COM2 (default for C128 based targets)')

        % memory model: flash_flat
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_MemModel', 'Flash_flat');
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_MemModel', 0);
        disp('Setting memory model to Flash_flat (banked memory model currently not supported on C128 based targets)')

        % no display of comms state on PTT
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeDispCommStatePTT', 'off');
        disp('Deselecting the display of the communication variable state on port PTT')

        % Setup memory management variables
        % NOTE: the following buffers are allocated... the sum of all
        %       buffer sizes needs to be less than 'mc9s12_ExtModeStatMemSize': 2000
        %       Target reception buffer (RB): 300
        %       Target transmission buffer (circBuf): 500
        %       Reception FIFOs ((mc9s12_ExtModeFifoBufNum + 2) * mc9s12_ExtModeFifoBufSize): 5 * 200 = 1k
        %
        % i_setupMemoryManagement(hDlg, hSrc, statMemSize, rxBufSize, txBufSize, fifoBufSize, fifoBufBatchSize)
        i_setupMemoryManagement(hDlg, hSrc, 2000, 300, 500, 200, 2)
        
    end
    
    if strcmp(target, 'DragonFly12-C32')

        % --  C32 based targets  --

        % select oscillator frequency (fixed)
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_Oscillator', '8 MHz');
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_Oscillator', 0);

        % switch off debugging through SCI0 (if required)
        dbgmsgSCI0 = str2double(slConfigUIGetVal(hDlg, hSrc, 'mc9s12_DEBUG_MSG_LVL'));
        if(dbgmsgSCI0 > 0)
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_DEBUG_MSG_LVL', 0);
            disp('Warning: Disabling debug messages through SCI0 (not supported on C32 based targets)')
        end

        % switch off error messages on the LCD
        errmsgLCD = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_LCDMsgs');
        if(strcmp(errmsgLCD, 'on'))
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_LCDMsgs', 'off');
            disp('Warning: Disabling LCD display based error messages (not supported on C32 based targets)')
        end

        % select SCI0 as MATLAB_SCI_PORT
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI0');
        disp('Setting target sided communication port to SCI0 (only one serial port on C32 based targets)')

        % select default serial port on the host : COM1
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 'COM1');
        disp('Setting host sided communication port to COM2 (default for C32 based targets)')

        % memory model: flash_flat
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_MemModel', 'Flash_flat');
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_MemModel', 0);
        disp('Setting memory model to Flash_flat')

        % no display of comms state on PTT
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeDispCommStatePTT', 'off');
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeDispCommStatePTT', 0);
        disp('Deselecting the display of the communication variable state on port PTT')

        % Setup memory management variables
        % NOTE: the following buffers are allocated... the sum of all
        %       buffer sizes needs to be less than 'mc9s12_ExtModeStatMemSize': 1500
        %       Target reception buffer (RB): 300
        %       Target transmission buffer (circBuf): 300
        %       Reception FIFOs ((mc9s12_ExtModeFifoBufNum + 2) * mc9s12_ExtModeFifoBufSize): 4 * 180 = 720
        %
        % i_setupMemoryManagement(hDlg, hSrc, statMemSize, rxBufSize, txBufSize, fifoBufSize, fifoBufBatchSize)
        i_setupMemoryManagement(hDlg, hSrc, 1500, 300, 300, 180, 2)

    end

    if strcmp(target, 'Generic-DG128')
        
        % --  Generic boards with MC9S12DG128 uControllers --

        % select oscillator frequency (can be modified)
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_Oscillator', '16 MHz');

        % select SCI1 as MATLAB_SCI_PORT
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI1');

        % select default serial port on the host : COM2
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 'COM2');
        disp(['Setting host sided communication port to COM2 (default for ' target ')'])

        % disable LCD error messages (not necessarily present on a generic board)
        slConfigUISetVal(hDlg, hSrc, 'mc9s12_LCDMsgs', 'off');

        % Setup memory management variables
        % NOTE: the following buffers are allocated... the sum of all
        %       buffer sizes needs to be less than 'mc9s12_ExtModeStatMemSize':
        %       Target reception buffer (RB): 1k
        %       Target transmission buffer (circBuf): 2k
        %       Reception FIFOs ((mc9s12_ExtModeFifoBufNum + 2) * mc9s12_ExtModeFifoBufSize): 7 * 0.4k = 2.8k
        %
        % i_setupMemoryManagement(hDlg, hSrc, statMemSize, rxBufSize, txBufSize, fifoBufSize, fifoBufBatchSize)
        i_setupMemoryManagement(hDlg, hSrc, 4500, 1000, 1500, 300, 2)

    end

    % select SCI0 as MATLAB_SCI_PORT
    myStaticAlloc = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeStatMemAlloc');
    if(strcmp(myStaticAlloc, 'off'))
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', 0);
    end


%     % get current setting of 'ExtMode'
%     ExtMode = slConfigUIGetVal(hDlg, hSrc, 'ExtMode');
% 
%     % disable ExtMode... if it was off in the original model
%     if(strcmp(ExtMode, 'off'))
% 
%         % ... switch to 'normal' mode
%         set_param(gcs,'SimulationMode', 'normal');
% 
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeRxBufSize', 0);
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize', 0);
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeBufSizeDisp', 0);
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize', 0);
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufNum', 0);
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeDispCommStatePTT', 0);
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeBaudrate', 0);
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 0);
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 0);
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemAlloc', 0);
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', 0);
%         slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatusBarClk', 0);
% 
%     end

    % correct '9999..' stop time
    stopTime = str2double(get_param(gcs, 'StopTime'));
    if ~isinf(stopTime) && stopTime > 999
        
        % 'super large' stop time --> probably meant to be 'inf'
        disp(['Current stop time is ' num2str(stopTime) ' seconds. Correcting value to ''inf''.'])
        set_param(gcs, 'StopTime', 'inf');
        
    end

    % first time done... set marker
    kk.Description = 'rtmc9s12target_R2009b';

end  % if(kk.Description == 'rtmc9s12target_R2009b')


% disable oscillator frequency option (unless it's a generic target)
currTarget = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_TargetBoard');
if isempty(strfind(lower(currTarget), 'generic'))
    
    % not a generic target -> disable oscillator frequency option
    slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_Oscillator', 0);
    
end

% reset 'Generate Code Only' option
try
    kk.Components(end).GenCodeOnly = 'off';
catch ME %#ok<NASGU>
end


% set default values of parameters that shouldn't be modified
slConfigUISetVal(hDlg, hSrc, 'ProdHWDeviceType','Motorola HC12');
slConfigUISetEnabled(hDlg, hSrc, 'ProdHWDeviceType',0);
slConfigUISetVal(hDlg, hSrc, 'ProdEqTarget','on');
slConfigUISetEnabled(hDlg, hSrc, 'ProdEqTarget',0);
slConfigUISetVal(hDlg, hSrc, 'GenerateSampleERTMain', 'off');
slConfigUISetEnabled(hDlg, hSrc, 'GenerateSampleERTMain',0);
slConfigUISetVal(hDlg, hSrc, 'SuppressErrorStatus', 'off');
slConfigUISetEnabled(hDlg, hSrc, 'SuppressErrorStatus',0);
slConfigUISetVal(hDlg, hSrc, 'GenerateErtSFunction','off');
slConfigUISetEnabled(hDlg, hSrc, 'GenerateErtSFunction',0);
slConfigUISetVal(hDlg, hSrc, 'MatFileLogging','off');
slConfigUISetEnabled(hDlg, hSrc, 'MatFileLogging',0);
slConfigUISetVal(hDlg, hSrc, 'GRTInterface','on');
slConfigUISetEnabled(hDlg, hSrc, 'GRTInterface',0);
slConfigUISetVal(hDlg, hSrc, 'ERTCustomFileTemplate','mc9s12_file_process.tlc');
slConfigUISetEnabled(hDlg, hSrc, 'ERTCustomFileTemplate',0);
slConfigUISetVal(hDlg, hSrc, 'CombineOutputUpdateFcns', 'off');
slConfigUISetEnabled(hDlg, hSrc, 'CombineOutputUpdateFcns', 'off');
slConfigUISetVal(hDlg, hSrc, 'IncludeMdlTerminateFcn', 'off');
slConfigUISetEnabled(hDlg, hSrc, 'IncludeMdlTerminateFcn', 'off');
slConfigUISetVal(hDlg, hSrc, 'SupportNonFinite', 'on');
slConfigUISetEnabled(hDlg, hSrc, 'SupportNonFinite', 'off');
slConfigUISetVal(hDlg, hSrc, 'MultiInstanceERTCode', 'off');
slConfigUISetEnabled(hDlg, hSrc, 'MultiInstanceERTCode', 'off');
slConfigUISetVal(hDlg, hSrc, 'UtilityFuncGeneration','Auto');
slConfigUISetEnabled(hDlg, hSrc, 'UtilityFuncGeneration',0);
slConfigUISetVal(hDlg, hSrc, 'GenerateMakefile', 'off');
slConfigUISetEnabled(hDlg, hSrc, 'GenerateMakefile', 0);
slConfigUISetVal(hDlg, hSrc, 'MakeCommand', 'make_rtw');
slConfigUISetEnabled(hDlg, hSrc, 'MakeCommand', 0);
slConfigUISetVal(hDlg, hSrc, 'ExtModeStaticAlloc', 'off');
slConfigUISetEnabled(hDlg, hSrc, 'ExtModeStaticAlloc', 0);
slConfigUISetVal(hDlg, hSrc, 'SupportNonInlinedSFcns','off');
slConfigUISetEnabled(hDlg, hSrc, 'SupportNonInlinedSFcns', 0);
slConfigUISetVal(hDlg, hSrc, 'SupportContinuousTime','on');
slConfigUISetEnabled(hDlg, hSrc, 'SupportContinuousTime', 0);
slConfigUISetVal(hDlg, hSrc, 'ExtModeMexFile', 'ext_serial_mc9s12_comm')
slConfigUISetEnabled(hDlg, hSrc, 'ExtModeMexFile', 0);
slConfigUISetVal(hDlg, hSrc, 'InlineParams', 'off');



% ensure consistent host port settings

% determine current port settings
port = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort');
port = port(4);

% determine current mc9s12_ExtModeBaudrate settings
mc9s12_ExtModeBaudrate = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeBaudrate');

% determine current verbosity settings
verb = get_param(gcs, 'RTWVerbose');
verb = num2str(strcmp(verb, 'on'));

% set parameter 'ExtModeMexArgs'
ext_comm_str = [verb ',' port ',' mc9s12_ExtModeBaudrate];
kk = get_param(gcs, 'ExtModeMexArgs');
if ~strcmp(deblank(kk), deblank(ext_comm_str))
    set_param(gcs, 'ExtModeMexArgs', ext_comm_str);
end





%% local functions



%% configure memory management
function i_setupMemoryManagement(hDlg, hSrc, statMemSize, rxBufSize, txBufSize, fifoBufSize, fifoBufBatchSize)

slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', statMemSize);
disp(['Reserving ' num2str(statMemSize) ' bytes for External Mode interface (if used)'])
slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeRxBufSize', rxBufSize);
disp(['Reserving ' num2str(rxBufSize) ' bytes for the target based reception buffer (serviced by the SCI ISR)'])
slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize', txBufSize);
disp(['Reserving ' num2str(txBufSize) ' bytes for the target based transmission buffer (filled with data points to be uploaded)'])
slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize', fifoBufSize);
disp(['Setting the FIFO buffer size to ' num2str(fifoBufSize) ' bytes (maximum packet size)'])
slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeFifoBufNum', fifoBufBatchSize);
disp(['FIFO buffers are allocated in batches of ' num2str(fifoBufBatchSize) ' buffers a time.'])

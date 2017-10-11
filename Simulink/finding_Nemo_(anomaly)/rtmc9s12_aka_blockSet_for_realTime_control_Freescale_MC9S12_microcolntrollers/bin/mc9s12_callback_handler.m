% mc9s12_CALLBACK_HANDLER - RTW GUI callback handler
%
% fw-01-09

function mc9s12_callback_handler(hDlg, hSrc, paramName)

switch paramName

    case 'mc9s12_BuildStyle'

        % disp(paramName)
        buildStyle = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_BuildStyle');
        
        if strcmp(buildStyle, 'Make')
            
            disp('Build style ''Make'' currently under development... might not work.');
            % disp('Build style ''Make'' currently not supported - switching to ''ActiveX''');
            % slConfigUISetVal(hDlg, hSrc, 'mc9s12_BuildStyle', 'ActiveX');
            
        end

    case 'mc9s12_TargetBoard'

        % disp(paramName)
        target = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_TargetBoard');

        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeRxBufSize', 1);
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize', 1);
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeBufSizeDisp', 1);
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize', 1);
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufNum', 1);
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_MemModel', 1);
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeDispCommStatePTT', 1);
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 1);
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 1);
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemAlloc', 1);
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', 1);
        slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatusBarClk', 1);

        if strcmp(target, 'Dragon12')

            % --  Dragon12 --

            % select oscillator frequency (fixed)
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_Oscillator', '4 MHz');
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_Oscillator', 0);

            % select SCI1 as MATLAB_SCI_PORT
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI1');

            % select default serial port on the host : COM2
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 'COM2');
            disp(['Setting host sided communication port to COM2 (default for ' target ')'])

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

        if strcmp(target, 'Dragon12Plus')

            % --  Dragon12Plus --

            % select oscillator frequency (fixed)
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_Oscillator', '8 MHz');
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_Oscillator', 0);

            % select SCI1 as MATLAB_SCI_PORT
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI1');

            % select default serial port on the host : COM2
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 'COM2');
            disp(['Setting host sided communication port to COM2 (default for ' target ')'])

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
            
            % --  University of Adelaide, mobile robot (MiniDragonPlus-RevE based, download via SCI0, communication w/h MATLAB through SCI1) --
            
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

        if strcmp(target, 'DragonFly12-C128')
            
            % --  C128 based targets (DragonFly12-C128)  --
            
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
            
            % --  C32 based targets (DragonFly12-C32)  --
            
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
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_Oscillator', 1);

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


        % get current setting of 'ExtMode'
        ExtMode = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtMode');

        % disable ExtMode... if it was off in the original model
        if(strcmp(ExtMode, 'off'))

            % ... switch to 'normal' mode
            set_param(gcs,'SimulationMode', 'normal');

            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeRxBufSize', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeBufSizeDisp', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufNum', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeDispCommStatePTT', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeBaudrate', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemAlloc', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatusBarClk', 0);

        end
        
        % save model...
        save_system;
        
        
    case 'mc9s12_ExtMode'

        % disp(paramName)
        ExtMode = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtMode');

        if strcmp(ExtMode, 'on')

            % activate 'mc9s12_ExtModeBaudrate' selection, 'host/target port' and 'static memory allocation'
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeRxBufSize', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeBufSizeDisp', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufNum', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeDispCommStatePTT', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeBaudrate', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemAlloc', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatusBarClk', 1);

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
            if(~strcmp(deblank(kk), deblank(ext_comm_str)))
                set_param(gcs, 'ExtModeMexArgs', ext_comm_str);
            end

            % ERT only... not needed in GRT mode  -  fw-06-07
            %
            %             % External Mode selected -> update tlcvariable 'ExtMode' (ERT)
            %             slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtMode', 'on');
            %             slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtMode', 0);
            %             slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTransport', 0);
            %             slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeStaticAlloc', 'off');
            %             slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStaticAlloc', 'off');

            % select SCI0 as MATLAB_SCI_PORT
            myStaticAlloc = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeStatMemAlloc');
            if(strcmp(myStaticAlloc, 'off'))
                slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', 0);
            end

            % ... switch Simulink to 'external' mode
            set_param(bdroot, 'SimulationMode', 'external');
            set_param(bdroot, 'ExtMode', 'on');

        else

            % ERT only... not needed in GRT mode  -  fw-06-07
            %
            %             % no External Mode selected -> update tlcvariable 'ExtMode' (ERT)
            %             slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtMode', 'off');
            %             slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtMode', 0);

            % deactivate 'mc9s12_ExtModeBaudrate' selection and 'host/target port'
            % (they're all freePorts now)
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeRxBufSize', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeBufSizeDisp', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeFifoBufNum', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeDispCommStatePTT', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeBaudrate', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemAlloc', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatusBarClk', 0);

            % ... switch to 'normal' mode
            set_param(bdroot, 'SimulationMode', 'normal');
            set_param(bdroot, 'ExtMode', 'off');

        end

    case 'mc9s12_ExtModeBaudrate'

        % user changed communication port (COMx), mc9s12_ExtModeBaudrate settings or verbosity level
        % disp(paramName)

        % determine current mc9s12_ExtModeBaudrate settings
        mc9s12_ExtModeBaudrate = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeBaudrate');

        % determine current port settings
        port = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort');
        port = port(4);

        % determine current verbosity settings
        verb = get_param(gcs, 'RTWVerbose');
        verb = num2str(strcmp(verb, 'on'));

        % set parameter 'ExtModeMexArgs'
        ext_comm_str = [verb ',' port ',' mc9s12_ExtModeBaudrate];
        kk = get_param(gcs, 'ExtModeMexArgs');
        if(~strcmp(deblank(kk), deblank(ext_comm_str)))
            set_param(gcs, 'ExtModeMexArgs', ext_comm_str);
        end

        % ... switch Simulink to 'external' mode
        set_param(gcs,'SimulationMode', 'external');

    case 'mc9s12_ExtModeRxBufSize'

        % user changed size of reception ring buffer
        % disp(paramName)

        % determine current mc9s12_ExtModeRxBufSize settings
        mc9s12_ExtModeRxBufSize = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeRxBufSize');

        if(mc9s12_ExtModeRxBufSize < 200)
            mc9s12_ExtModeRxBufSize = 200;
            disp(['Reception ring buffer size too small, resetting value to ' mc9s12_ExtModeRxBufSize]);
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeRxBufSize', num2str(mc9s12_ExtModeRxBufSize));
        elseif(mc9s12_ExtModeRxBufSize > 2000)
            mc9s12_ExtModeRxBufSize = 2000;
            disp(['Reception ring buffer size too large, resetting value to ' mc9s12_ExtModeRxBufSize]);
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeRxBufSize', num2str(mc9s12_ExtModeRxBufSize));
        end


    case 'mc9s12_ExtModeTxBufSize'

        % user changed size of circular buffer
        % disp(paramName)

        % determine current mc9s12_ExtModeTxBufSize settings
        mc9s12_ExtModeTxBufSize = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize');
        
        if(mc9s12_ExtModeTxBufSize < 300)
            mc9s12_ExtModeTxBufSize = 300;      % assumed minimum size
            disp(['Data buffer size too small, resetting value to ' mc9s12_ExtModeTxBufSize]);
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize', num2str(mc9s12_ExtModeTxBufSize));
        elseif(mc9s12_ExtModeTxBufSize > 6000)
            mc9s12_ExtModeTxBufSize = 6000;
            disp(['Data buffer size too large, resetting value to ' mc9s12_ExtModeTxBufSize]);
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize', num2str(mc9s12_ExtModeTxBufSize));
        end
        
        % recompile host comms module to use a matching CIRCBUFSIZE and FIFOBUFSIZE
        mc9s12_ExtModeStatusBarClk = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeStatusBarClk');
        mc9s12_ExtModeFifoBufSize = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize');
        
        if(strcmp(mc9s12_ExtModeStatusBarClk, 'on'))
            remex(0, ['-DSEND_GET_TIME_PKTS=1 -DCIRCBUFSIZE=' num2str(mc9s12_ExtModeTxBufSize) ' -DFIFOBUFSIZE=' num2str(mc9s12_ExtModeFifoBufSize)]);
        else
            remex(0, ['-DSEND_GET_TIME_PKTS=0 -DCIRCBUFSIZE=' num2str(mc9s12_ExtModeTxBufSize) ' -DFIFOBUFSIZE=' num2str(mc9s12_ExtModeFifoBufSize)]);
        end

    case 'mc9s12_ExtModeFifoBufSize'

        % user changed size of FIFO buffer
        % disp(paramName)

        % determine current mc9s12_ExtModeFifoBufSize settings
        mc9s12_ExtModeFifoBufSize = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize');

        if(mc9s12_ExtModeFifoBufSize < 175)
            mc9s12_ExtModeFifoBufSize = 175;      % assumed minimum size
            disp(['FIFO buffer size too small, resetting value to ' mc9s12_ExtModeFifoBufSize]);
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize', num2str(mc9s12_ExtModeFifoBufSize));
        elseif(mc9s12_ExtModeFifoBufSize > 1000)
            mc9s12_ExtModeFifoBufSize = 1000;
            disp(['FIFO buffer size too large, resetting value to ' mc9s12_ExtModeFifoBufSize]);
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize', num2str(mc9s12_ExtModeFifoBufSize));
        end

        % recompile host comms module to use a matching CIRCBUFSIZE and FIFOBUFSIZE
        mc9s12_ExtModeStatusBarClk = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeStatusBarClk');
        mc9s12_ExtModeTxBufSize = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize');
        
        if(strcmp(mc9s12_ExtModeStatusBarClk, 'on'))
            remex(0, ['-DSEND_GET_TIME_PKTS=1 -DCIRCBUFSIZE=' num2str(mc9s12_ExtModeTxBufSize) ' -DFIFOBUFSIZE=' num2str(mc9s12_ExtModeFifoBufSize)]);
        else
            remex(0, ['-DSEND_GET_TIME_PKTS=0 -DCIRCBUFSIZE=' num2str(mc9s12_ExtModeTxBufSize) ' -DFIFOBUFSIZE=' num2str(mc9s12_ExtModeFifoBufSize)]);
        end

        
    case 'mc9s12_ExtModeFifoBufNum'

        % user changed batch size of FIFO buffer allocation
        % disp(paramName)

        % determine current mc9s12_ExtModeFifoBufNum settings
        mc9s12_ExtModeFifoBufNum = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeFifoBufNum');

        if(mc9s12_ExtModeFifoBufNum < 1)
            mc9s12_ExtModeFifoBufNum = 1;      % minimum batch size
            disp(['FIFO buffer batch allocation size too small, resetting value to ' mc9s12_ExtModeFifoBufNum]);
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeFifoBufNum', num2str(mc9s12_ExtModeFifoBufNum));
        elseif(mc9s12_ExtModeFifoBufNum > 10)
            mc9s12_ExtModeFifoBufNum = 10;
            disp(['FIFO buffer batch allocation size too large, resetting value to ' mc9s12_ExtModeFifoBufNum]);
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeFifoBufNum', num2str(mc9s12_ExtModeFifoBufNum));
        end


    case 'mc9s12_ExtModeHostPort'

        % user changed host sided communication port (COMx), mc9s12_ExtModeBaudrate settings or verbosity level
        % disp(paramName)

        % determine current mc9s12_ExtModeBaudrate settings
        mc9s12_ExtModeBaudrate = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeBaudrate');

        % determine current port settings
        port = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort');
        port = port(4);

        % determine current verbosity settings
        verb = get_param(gcs, 'RTWVerbose');
        verb = num2str(strcmp(verb, 'on'));

        % set parameter 'ExtModeMexArgs'
        ext_comm_str = [verb ',' port ',' mc9s12_ExtModeBaudrate];
        kk = get_param(gcs, 'ExtModeMexArgs');
        if(~strcmp(deblank(kk), deblank(ext_comm_str)))
            set_param(gcs, 'ExtModeMexArgs', ext_comm_str);
        end

        % ... switch Simulink to 'external' mode
        set_param(gcs,'SimulationMode', 'external');


    case 'mc9s12_ExtModeTargetPort'

        % user changed target sided comms port (SCI0/SCI1) -> check if valid
        % disp(paramName)

        target = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_TargetBoard');

        if(strcmp(target, 'Dragon12Plus') || strcmp(target, 'Dragon12'))

            % --  Dragon12Plus and Dragon12 --
            % do nothing...

        end

        if strcmp(target, 'MiniDragonPlus')

            % --  MiniDragonPlus  --
            % always select SCI0 as target sided External Mode communications port
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI0');
            disp('Warning: Resetting target sided communication port to SCI0 (default on MiniDragonPlus)')

        end

        if strcmp(target, 'MiniDragonPlus-RevE')

            % --  MiniDragonPlus-RevE  --
            % select SCI1 as target sided External Mode communications port
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI1');
            disp('Warning: Resetting target sided communication port to SCI1 (default on the mobile robots)')
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 'COM2');
            disp('Warning: Resetting host sided communication port to COM2 (default with the mobile robots)')

        end
        
        if strcmp(target, 'DragonFly12-C128') || strcmp(target, 'DragonFly12-C32')

            % --  DragonFly12-C128 targets, DragonFly12-C32 targets --
            % select SCI0 as target sided External Mode communications port
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeTargetPort', 'SCI0');
            disp('Warning: Resetting target sided communication port to SCI0')
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeHostPort', 'COM1');
            disp('Warning: Resetting host sided communication port to COM1')

        end

    case 'mc9s12_ExtModeStatMemAlloc'

        % user selected/deselected static memory allocation in ExtMode
        % disp(paramName)
        mc9s12_ExtModeStatMemAlloc = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeStatMemAlloc');

        if(strcmp(mc9s12_ExtModeStatMemAlloc, 'on'))

            % activate 'mc9s12_ExtModeStatMemSize' edit box
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', 1);

        else

            % de-activate 'mc9s12_ExtModeStatMemSize' edit box
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', 0);
            
        end


    case 'mc9s12_ExtModeStatMemSize'

        % user changed size of the static memory buffer (ExtMode)
        % disp(paramName)
        mc9s12_ExtModeStatMemSize = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize');
        if(mc9s12_ExtModeStatMemSize < 1000)
            mc9s12_ExtModeStatMemSize = 1000;
            disp(['Static memory management buffer size too small, resetting value to ' mc9s12_ExtModeStatMemSize]);
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', num2str(mc9s12_ExtModeStatMemSize));
        elseif(mc9s12_ExtModeStatMemSize > 6500)
            mc9s12_ExtModeStatMemSize = 6500;
            disp(['Static memory management buffer size too large, resetting value to ' mc9s12_ExtModeStatMemSize]);
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_ExtModeStatMemSize', num2str(mc9s12_ExtModeStatMemSize));
        end


    case 'mc9s12_ExtModeStatusBarClk'

        % user changed the setting of the status bar clock option 
        % disp(paramName)
        mc9s12_ExtModeStatusBarClk = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeStatusBarClk');
        mc9s12_ExtModeFifoBufSize = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeFifoBufSize');
        mc9s12_ExtModeTxBufSize = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_ExtModeTxBufSize');
        
        if(strcmp(mc9s12_ExtModeStatusBarClk, 'on'))
            remex(0, ['-DSEND_GET_TIME_PKTS=1 -DCIRCBUFSIZE=' num2str(mc9s12_ExtModeTxBufSize) ' -DFIFOBUFSIZE=' num2str(mc9s12_ExtModeFifoBufSize)]);
        else
            remex(0, ['-DSEND_GET_TIME_PKTS=0 -DCIRCBUFSIZE=' num2str(mc9s12_ExtModeTxBufSize) ' -DFIFOBUFSIZE=' num2str(mc9s12_ExtModeFifoBufSize)]);
        end


    case 'mc9s12_LCDMsgs'

        % ensure this is not switched on when working on the MiniDragonPlus
        % disp(paramName)

        target = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_TargetBoard');
        
        if strcmp(target, 'Dragon12Plus') || strcmp(target, 'Dragon12')

            % --  Dragon12Plus and Dragon12  --
            % do nothing...

        end

        if strcmp(target, 'MiniDragonPlus') || ...
           strcmp(target, 'MiniDragonPlus-RevE') || ...
           strcmp(target, 'DragonFly12-C128') || ...
           strcmp(target, 'DragonFly12-C32')

            % --  MiniDragonPlus, MiniDragonPlus-RevE, etc.  --
            % no LCD display...
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_LCDMsgs', 'off');
            disp('Warning: There is no LCD display on the chosen target')

        end


    case 'mc9s12_RTOSsupport'

        % RTOS support (currently) implies the use of RTI
        rtosSupportEnabled  = strcmp(slConfigUIGetVal(hDlg, hSrc, 'mc9s12_RTOSsupport'), 'on');
        usingRTIasCoreTimer = strcmp(slConfigUIGetVal(hDlg, hSrc, 'mc9s12_CoreTimer'), 'RTI');
        
        % RTOS support requested while using TC7 as core timer?
        if rtosSupportEnabled && ~usingRTIasCoreTimer
            
            % yep -> set core timer to RTI
            disp('Enabling RTOS support implies the use of RTI as core timer - setting CoreTimer to RTI.')
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_CoreTimer', 'RTI');

        end


    case 'mc9s12_CoreTimer'

        % The use of TC7 as core timer (currently) rules out RTOS support
        rtosSupportEnabled  = strcmp(slConfigUIGetVal(hDlg, hSrc, 'mc9s12_RTOSsupport'), 'on');
        usingTC7asCoreTimer = strcmp(slConfigUIGetVal(hDlg, hSrc, 'mc9s12_CoreTimer'), 'T7I');
        
        % requesting TC7 as core timer while RTOS support is enabled?
        if usingTC7asCoreTimer && rtosSupportEnabled
            
            % yep -> switch back to RTI
            disp('RTOS support currently enabled -> switching back to RTI as core timer.')
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_CoreTimer', 'RTI');
            
        end


    case 'mc9s12_DEBUG_MSG_LVL'

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


    case 'mc9s12_TimingSigs'

        % timing signals - enable / disable related options
        % disp(paramName)

        timSG = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_TimingSigs');

        if (strcmp(timSG, 'off'))
            % If timSG has just been switched off -> also switch off cycTI, serTI and timPT
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_TimingSigsPort', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_SerialRxPin', 0);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_CycleTimePin', 0);
        else
            % Else, extMD has just been activated... -> activate cycTI, serTI and timPT
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_TimingSigsPort', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_SerialRxPin', 1);
            slConfigUISetEnabled(hDlg, hSrc, 'mc9s12_CycleTimePin', 1);
        end


    case 'mc9s12_CycleTimePin'

        % ensure that we're using the correct pin format and that there is no conflict...
        % disp(paramName)

        cycTIstr = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_CycleTimePin');
        serTIstr = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_SerialRxPin');

        if(isequal(cycTIstr, serTIstr))
            % pin conflict
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_CycleTimePin', -1);
            beep
            disp('Pin conflict: Use separate pins to monitor the cycle time and serial communication interrupts.')
        end

    case 'mc9s12_SerialRxPin'

        % ensure that we're using the correct pin format and that there is no conflict...
        % disp(paramName)

        cycTIstr = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_CycleTimePin');
        serTIstr = slConfigUIGetVal(hDlg, hSrc, 'mc9s12_SerialRxPin');

        if(isequal(cycTIstr, serTIstr))
            % pin conflict
            slConfigUISetVal(hDlg, hSrc, 'mc9s12_SerialRxPin', -1);
            beep
            disp('Pin conflict: Use separate pins to monitor the cycle time and serial communication interrupts.')
        end

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

% test program

global accel1 accel2 pulses run;

% set sample rate
Ts = 0.1;

% start GUI
test2;

% get handle to display area
set(0, 'ShowHiddenHandles', 'on');      % '0' is reference to MATLAB root handle
GUI_main = get(0, 'Children');
handles = get(GUI_main, 'Children');    % uicontrol handles (slider, text box, etc.)

% find handles
for(i = 1:length(handles))
    
    if(iscell(handles))
        kk = handles{i};
    else
        kk = handles(i);
    end
    
    for(j = 1:length(kk))
        
        myTag = get(kk(j), 'Tag');
        
        if(strcmp(myTag, 'axes1'))
            myAxes1 = kk(j);           % found it -> store handle in 'myAxes1'
        end
        if(strcmp(myTag, 'axes2'))
            myAxes2 = kk(j);           % found it -> store handle in 'myAxes2'
        end
        if(strcmp(myTag, 'axes3'))
            myAxes3 = kk(j);           % found it -> store handle in 'myAxes3'
        end
        if(strcmp(myTag, 'text7'))
            text7 = kk(j);            % found it -> store handle in 'pushbutton1'
        end
        
    end
    
end


% open target model (if required)
if(isempty(gcs))
    open_system('Shaker_Driver_sysID2.mdl')
end


% enter data acquisition loop
while(1)
    
    % this 'try'-'catch' bracket ensures that the program exits
    % gracefully upon closing the figure window...
    try
        
        if(get_param(gcs, 'SimulationTime') > 0)
            
            % model running
            set(text7, 'Visible', 'on');
            pause(2);
            
        end
        
        % keep this outside the 'if' statement to force abort 
        % when the user closes the GUI window
        set(text7, 'Visible', 'off');
        pause(2);
        
    catch
        % user closed GUI figure window -> exit without error message
        break;
    end
    
end

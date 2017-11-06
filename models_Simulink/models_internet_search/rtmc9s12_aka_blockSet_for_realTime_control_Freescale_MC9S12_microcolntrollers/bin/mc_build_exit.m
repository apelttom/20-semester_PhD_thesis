function mc_build_exit

global mcBuildPars;


% collect all parameters in object 'mcBuildPars.ressources' and perform 
% model consistency checks. The name prefix 'mc9s12_' of the individual 
% options is dropped, i.e. option 'mc9s12_ExtModeStatusBarClk' becomes 
% 'mcBuildPars.resources.ExtModStatusBarClk', etc.
mc_resourceCheck('mc9s12_');


% generate central microcontroller header file 'mc_defines.h'. The defines 
% in this header file characterize both model dependent as well as HW 
% dependent options
mc_gen_mc_defines_h;


% check if the host files need recompiled (eg. when the size of the comms 
% buffers is changed, etc.) -> compare current compile options to those of 
% the marker file and recompile if needed (marker file: 
% .../bin/ext_serial_mc9s12_comm_marker.txt). Set the debug message level 
% to '0'
remex(0, '', 'check');



% Build stuff...
if mcBuildPars.codeGenerator.buildOpts.generateCodeOnly == 0

    try
        
        % Check for the stupidly long error message (thanks Mathworks!) 
        % that causes stupid CodeWarrior 3.0 to generate a compiler error 
        % (thanks Metrowerks!)
        %
        % Apologies for the rude terminology / comment (thanks Zebb!  ;)  )
        CheckForStupidMessage(mcBuildPars.modelName);

        
        % -------------------------------------------------------------
        % build application
        % -------------------------------------------------------------
        
        % are we building using 'CW/ActiveX' or via the 'make' interface?
        if strcmp(mcBuildPars.codeGenerator.buildStyle, 'ActiveX')
            
            % *** ActiveX based build process ***
            
            % build libraries -- if required
            mc_buildLibrariesActiveX;

            % fully automatic build?
            if strcmp(mcBuildPars.resources.FullyAutoBuild, 'on')

                % yes -> build, download and run
                [errorMsgs, warningMsgs] = mc_buildCodeActiveX('execute');

            else

                % no -> just build
                [errorMsgs, warningMsgs] = mc_buildCodeActiveX('build');

            end
            
            % build errors?
            if ~isempty(errorMsgs)

                % errors
                
                disp('### Encountered problems while building the code:')
                
                % display all errors
                disp('--------------------------------------------------------------------')
                for ii = 1:length(errorMsgs)
                
                    disp(errorMsgs{ii})
                    disp('--------------------------------------------------------------------')
                    
                end
                
            end
            
            % save build error messages and warnings (for post processing)
            save buildErrorsWarnings errorMsgs warningMsgs;
            
        else
            
            % *** make-based build process ***

            % build libraries -- if required
            mc_buildLibrariesMake;

            % fully automatic build?
            if strcmp(mcBuildPars.resources.FullyAutoBuild, 'on')

                % yes -> build, download and run
                mc_buildCodeMake('execute');

            else

                % no -> just build
                mc_buildCodeMake('build');

            end
            
        end  % ActiveX / make

    catch ME
        
        % where did it all go wrong?!
        mc_errorMsgAndExit(mfilename, ME);

    end

    
    % Run code profiling report
    if exist('htmlreport', 'file') == 2
        
        % report generating m-file exists -> run it
        htmlreport;
        
        % housekeeping...
        delete('htmlreport.m');
        
    end

else

    % codegenonly == 1  ->  we're already done (do nothing)
    
end





%% local functions

% =========================================================================
% Checks for the rediculously long #error statement generated when using 
% fixed-point block set. These messages are shortened.
function CheckForStupidMessage(modelName)

fid = fopen([modelName '_private.h'], 'r');
str = fread(fid);
fclose(fid);

str = char(str.');
str = regexprep(str,'#error Code([\w /,.'']*)checks.','#error "Code$1checks."');

fid = fopen([modelName '_private.h'], 'w');
fwrite(fid,str);
fclose(fid);

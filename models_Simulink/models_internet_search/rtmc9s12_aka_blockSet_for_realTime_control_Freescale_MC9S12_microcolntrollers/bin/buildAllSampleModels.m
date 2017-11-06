% test all sample models and write a log file
function resInfo = buildAllSampleModels(varargin)

% check for optional call-up parameters
if nargin == 1
    
    % one optional call-up parameter specified: 
    %
    % 0: generate code only
    % 1: also compile model code
    % 2: also download project to target and run it for a few cycles
    %
    testMode = varargin{1};
    
elseif nargin == 2
    
    % two optional call-up parameter specified: 
    %
    % parameter #1:
    %
    % 0: generate code only
    % 1: also compile model code
    % 2: also download project to target and run it for a few cycles
    %
    testMode = varargin{1};
    
    % parameter #2:
    % true:  visible models
    % false: invisible models
    mdlVisibility = logical(varargin{2});
    
else
    
    % no call-up parameters -> just generate code and exit
    testMode  = 0;
    mdlVisibility = true;
    
end


%% process all models...
examplePath = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'examples');

allMdlFiles = dir(fullfile(examplePath, '*.mdl'));
allSampleNames = { allMdlFiles.name };
allSamples = sort(allSampleNames);
nAllSamples = length(allSamples);

allCompiled = dir(fullfile(examplePath, '*_mc9s12_rtw'));
allCompiledNames = { allCompiled.name };
allDone = regexprep(allCompiledNames, '_mc9s12_rtw', '.mdl');


% fetch global preferences from file '.../bin/mc_prefs.txt'
currPrefs = mc_readOptions('mc_prefs.txt', 'mc9s12_');


% loop over all 'mdl' files
resInfo = cell(nAllSamples, 2);
for ii = 1:nAllSamples
    
    % next model
    currSampleName = allSamples{ii};
    
    % already done?
    if ~ismember(currSampleName, allDone)
    
        % nope -> open model
        if mdlVisibility
            
            % model visisble
            open_system(fullfile(examplePath, currSampleName));
            
        else
            
            % model invisible
            load_system(fullfile(examplePath, currSampleName));
            
        end

        
        % is this a target bound model at all?
        currSysTargetFile = get_param(bdroot, 'RTWSystemTargetFile');
        if strcmp(currSysTargetFile, 'mc9s12.tlc')
            
            % yes -> prepare model for code generation / building

            % generate code only?
            orig_RTWGenerateCodeOnly = get_param(bdroot, 'RTWGenerateCodeOnly');
            if testMode > 0

                % nope -> need to ensure that 'generate code only' is 'off'
                set_param(bdroot, 'RTWGenerateCodeOnly', 'off');
                
            else
                
                % generate code only
                set_param(bdroot, 'RTWGenerateCodeOnly', 'on');
                
            end
            
            % also download code to the target?
            orig_mc9s12_FullyAutoBuild = currPrefs.FullyAutoBuild;
            if testMode > 1

                % yep -> need to ensure that 'FullyAutoBuild' is 'on'
                currPrefs.FullyAutoBuild = 'on';
                
            else
                
                % not downloading code to the target
                currPrefs.FullyAutoBuild = 'off';
                
            end
            
            
            % ensure oscillator property is greyed out
            kk = getActiveConfigSet(gcs);
            setPropEnabled(kk, 'mc9s12_Oscillator', 0);
            
            % write (possibly adjusted) global target options
            mc_writeOptions(gcs, 'mc9s12_', currPrefs);
            save_system(bdroot);

            % generate code /  build model / test model
            try
                
                % build model (CTRL+B)
                rtwbuild(bdroot);
                
                % success?
                try
                    
                    % load build error messages / warnings
                    currMsgs  = load(fullfile(examplePath, [strrep(currSampleName, '.mdl', '') '_mc9s12_rtw'], 'sources', 'buildErrorsWarnings.mat'));
                    errorMsgs = currMsgs.errorMsgs;
                    % warningMsgs = currMsgs.warningMsgs;
                    
                catch ME
                    
                    % error message mat-file not found -> continue...
                    mc_errorMsgNoExit(ME);

                    % continue with the next model...
                    continue
                    
                end
                
                % did CW encounter any errors while building the models?
                if isempty(errorMsgs)
                    
                    % success -> provide some feedback
                    resInfo{ii, 1} = ([datestr(now) ': Successfully built model ''' currSampleName '''']);
                    
                    % no error messages
                    resInfo{ii, 2} = '';
                    
                    
                else
                    
                    % problems -> provide some feedback
                    resInfo{ii, 1} = ([datestr(now) ': Encountered errors when building model ''' currSampleName ...
                                      ''' (see .../' strrep(currSampleName, '.mdl', '') '_mc9s12_rtw/sources/buildErrorsWarnings.mat)']);
                    
                    % store error messages
                    resInfo{ii, 2} = errorMsgs;
                    
                end
                    
                % also try to download and run the model?
                if isempty(errorMsgs) && testMode > 1
                    
                    % yep -> run the model for a few seconds (ExtMode only)
                    if strcmp(currPrefs.ExtMode, 'on')
                        
                        % ExtMode -> connect, start, stop
                        try

                            % wait for flash process to finish...
                            disp('Waiting for flash process to complete...')
                            pause(15)
                            disp('... (hopefully) done?!')

                            % connect
                            disp('Connecting to target...')
                            set_param(bdroot, 'SimulationCommand', 'connect')
                            disp('... connected.')

                            % run model code
                            disp('Starting target model execution... ')
                            set_param(bdroot, 'SimulationCommand', 'start')
                            disp('... model code started.')

                            % wait a few seconds
                            disp('Running the model for a few seconds.')
                            pause(5);

                            % stop model
                            disp('Stopping model code execution...')
                            set_param(bdroot, 'SimulationCommand', 'stop')
                            disp('... model stopped.')

                            % wait for model to be released
                            disp('Waiting for model to be stopped...')
                            pause(5)
                            disp('... (hopefully) done?!')

                        catch exceptionObj

                            disp(' ')
                            disp(exceptionObj.getReport)
                            disp(' ')
                            disp('What errors occurred? Review the error message above. The error')
                            disp('message should indicate that there was a communications failure')
                            disp('between the host and target. This is the error that occurs if')
                            disp('the target application could not be launched.')
                            disp(' ')

                        end
                        
                    end  % ExtMode
                    
                end  % try running the model on the target
                
            catch %#ok<CTCH>
                
                resInfo{ii, 1} = ([datestr(now) ': WARNING -- Encountered problems when building model ''' currSampleName '''']);
                resInfo{ii, 2} = 'unspecific error during CTRL+B';
                
            end
            
            % restore original RTWGenerateCodeOnly option
            set_param(bdroot, 'RTWGenerateCodeOnly', orig_RTWGenerateCodeOnly);

            % restore original mc9s12_FullyAutoBuild option
            set_param(bdroot, 'mc9s12_FullyAutoBuild', orig_mc9s12_FullyAutoBuild);

        end

        % close model (with saving)  --  note, model might still be running
        waitForTerminateCount = 3;
        while waitForTerminateCount > 0

            try
            
                % close model (with saving)
                close_system(bdroot, 1)
                
                % done -> exit while
                waitForTerminateCount = 0;
                
            catch %#ok<CTCH>
                
                % model still running (ExtMode tests) -> wait some more
                pause(3)
                
                % next attempt
                waitForTerminateCount = waitForTerminateCount - 1;
                
            end
            
        end  % while
        
    end
    
end  % nAllSamples

% save log and display results
fid = fopen(fullfile(fileparts(mfilename('fullpath')), 'buildAllSampleModels_log.txt'), 'w');

k1 = [char(10) char(10) char(10) '***********************************************************'];
k2 = 'Results';
k3 = '***********************************************************';

% on screen display
disp(k1)
disp(k2)
disp(k3)

% write to log file
fprintf(fid, '%s\n\r%s\n\r%s\n\r', k1, k2, k3); 

for ii = 1:nAllSamples
    
    % next line
    errState = resInfo{ii, 1};
    errMsgs  = resInfo{ii, 2};
    
    % beautify error messages
    
    
    % on screen display
    disp(errState)
    for kk = 1:length(errMsgs)
        
        % next error message
        fprintf('  --> %s\n', char(regexp(errMsgs(kk), '.*[^\r\n]', 'match', 'once')));
        
    end
    
    % write to log file
    fprintf(fid, '%s\n\r', errState);
    for kk = 1:length(errMsgs)
        
        % next error message
        fprintf(fid, '  --> %s\n', char(regexp(errMsgs(kk), '.*[^\r\n]', 'match', 'once')));
        
    end
    
end

% on screen display
disp(k1)
disp(' ')

% write to log file
fprintf(fid, '%s\n\r', k1); 

% close log file
fclose(fid);

% update all mc9s12-target models in the current checkFolder from
% R2007a to R2008a


function update9s12models(varargin)

% set macro DEBUG_MSG_LVL
if nargin == 0

    % directories to be scanned
    checkFolder = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'examples');

elseif nargin == 1

    checkFolder = varargin{1};

else

    error('USE: update9s12models   OR   update9s12models(checkFolder)   OR   update9s12models(mdlFile)')

end

% stop annoying warings...
% warning('OFF','Simulink:SL_CloseBlockDiagramNotLoaded');


% find all '.mdl' files in this checkFolder
if isdir(checkFolder)
    
    % entire checkFolder
    mdlFiles = dir(fullfile(checkFolder, '*.mdl'));
    
else
    
    % single file...
    mdlFiles = dir(checkFolder);

    % adjust checkFolder to suit processing below...
    if isempty(findstr(checkFolder, '/')) && isempty(findstr(checkFolder, '\'))
        
        checkFolder = '.';
        
    else
        
        % checkFolder section
        checkFolder = checkFolder(1:findstr(checkFolder, mdlFiles.name)-1);
        
    end

end


% ****** MODEL MODIFCIATIONS ******

% when updating R2007a models, substitute these strings...
scanStr{1}  = 'mc9S12.tlc';
scanStr{2}  = 'mc9S12.tmf';
scanStr{3}  = 'make_mc9S12';
scanStr{4}  = 'ADC Input';
scanStr{5}  = 'D to A converter';
scanStr{6}  = 'ext_serial_win32_comm';

% with these replacement strings...
replStr{1}  = 'mc9s12.tlc';
replStr{2}  = 'mc9s12.tmf';
replStr{3}  = 'make_rtw';
replStr{4}  = 'A to D Converter';
replStr{5}  = 'D to A Converter';
replStr{6}  = 'ext_serial_mc9s12_comm';

% known help file entries
myHelpEntries = {
    {'mc9s12_ADC_In_blkref', 'adc_sfcn_9S12.html'}
    {'mc9s12_DAC_In_blkref', 'dac_sfcn_9S12.html'}
    {'mc9s12_PWM_In_blkref', 'pwm_sfcn_9S12.html'}
    {'mc9s12_servoPWM_In_blkref', 'servo_pwm_sfcn_9S12.html'}
    {'mc9s12_DIN_In_blkref', 'digIn_sfcn_9S12.html'}
    {'mc9s12_DOUT_In_blkref', 'digOut_sfcn_9S12.html'}
    {'mc9s12_URXD_In_blkref', 'freePortComms_rxd.html'}
    {'mc9s12_UTXD_In_blkref', 'freePortComms_txd.html'}
    {'mc9s12_FPRXD_In_blkref', 'freePortComms_rxd.html'}
    {'mc9s12_FPTXD_In_blkref', 'freePortComms_txd.html'}
    {'mc9s12_SONAR_In_blkref', 'sonar_sfcn_9S12.html'}
    };

% known block tags
myTags = { ...
    'mcTarget_rfCommsCli', 'rfComms_client.html'; ...
    'mcTarget_rfCommsSrv', 'rfComms_server.html'; ...
    'mcTarget_dac', 'dac_sfcn_9S12.html'; ...
    'mcTarget_dacDragonOnBoard', 'onboardDAC_sfcn_9S12.html'; ...
    'mcTarget_adc', 'adc_sfcn_9S12.html'; ...
    'mcTarget_digOut', 'digOut_sfcn_9S12.html'; ...
    'mcTarget_digIn', 'digIn_sfcn_9S12.html'; ...
    'mcTarget_pwm', 'pwm_sfcn_9S12.html'; ...
    'mcTarget_pwmServo', 'servo_pwm_sfcn_9S12.html'; ...
    'mcTarget_timer', 'timer_sfcn_9S12.html'; ...
    'mcTarget_sonar', 'sonar_sfcn_9S12.html'; ...
    'mcTarget_freePortCommsTX', 'freePortComms_txd.html'; ...
    'mcTarget_freePortCommsRX', 'freePortComms_rxd.html'; ...
    'mcTarget_fuzzy', 'fuzzy_sfcn_9S12.html' ...
    };


% update files...
for jj = 1:length(mdlFiles)

    currFileName = mdlFiles(jj).name;
    disp(['Updating file: ' currFileName])

    currFile = fullfile(checkFolder, currFileName);
    % saveFile = fullfile(checkFolder, ['backup_' currFileName]);

    % tag all blocks of the toolbox
    load_system(currFile);

    % save flag
    anyChanges = false;

    % first pass: check for all tags
    allTags = myTags(:, 1);
    for kk = 1:length(allTags)

        % next tag
        currTag = allTags{kk, 1};

        allMC9S12DriverBlocks = find_system(bdroot, 'FollowLinks', 'on', 'BlockType', 'SubSystem', 'Tag', currTag);
        nAllMC9S12DriverBlocks = length(allMC9S12DriverBlocks);

        for ll = 1:nAllMC9S12DriverBlocks

            % find the underlying S-Function block
            SFblock = find_system(allMC9S12DriverBlocks{ll}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');
            SFblockTag = get_param(SFblock{1}, 'Tag');

            % matching tags?
            if isempty(SFblockTag) || ~strcmp(SFblockTag, currTag)

                % nope -> correct tag
                set_param(SFblock{1}, 'Tag', currTag)

                % set 'save' flag
                anyChanges = true;

            end  % SFblockTag ~= currTag
            
            % ADC block?
            if strcmp(currTag, 'mcTarget_adc')
                
                % yep -> replace initialisation command
                oldInit = get_param(allMC9S12DriverBlocks{ll}, 'MaskInitialization');
                newInit = '[channelsStr, firstChannel, numChannels] = mbc_adcinput(channels);';
                
                % still needs changed?
                if ~strcmp(oldInit, newInit)
                    
                    % yep
                    set_param(allMC9S12DriverBlocks{ll}, 'MaskInitialization', newInit);
                
                    % set 'save' flag
                    anyChanges = true;
                    
                end
                
            end  % ADC block

            % PWM block?
            if strcmp(currTag, 'mcTarget_pwm')

                % yep -> replace SFunction parameters
                oldPara = get_param(SFblock{1}, 'Parameters');
                newPara = 'sampletime, PWMperiod, pulse_pin, sign_port, sign_pin, Vmax, sig_mon';

                % still needs changed?
                if ~strcmp(oldPara, newPara)

                    % yep
                    set_param(SFblock{1}, 'Parameters', newPara);

                    % set 'save' flag
                    anyChanges = true;

                end

            end  % PWM block

            % delete RTWdata from parent block
            oldRTWdata = get_param(allMC9S12DriverBlocks{ll}, 'RTWdata');

            % need to delete this?
            if ~isempty(oldRTWdata)

                % yep
                set_param(allMC9S12DriverBlocks{ll}, 'RTWdata', []);

                % set 'save' flag
                anyChanges = true;

            end
            
        end  % nAllMC9S12DriverBlocks

    end  % for(allTags)

    
    % second pass: check for all help texts
    allHelpTexts = myTags(:, 2);
    for kk = 1:length(allHelpTexts)

        % next help text
        currHelpText = ['web(''' allHelpTexts{kk} ''');'];
        currTag = myTags{kk, 1};

        allMC9S12DriverBlocks = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'MaskHelp', currHelpText);
        nAllMC9S12DriverBlocks = length(allMC9S12DriverBlocks);

        for ll = 1:nAllMC9S12DriverBlocks
            
            % ensure the parent block is tagged
            oldParentTag = get_param(allMC9S12DriverBlocks{ll}, 'Tag');
            
            % missing or incorrect tag?
            if isempty(oldParentTag) || ~strcmp(oldParentTag, currTag)
                
                % yep
                set_param(allMC9S12DriverBlocks{ll}, 'Tag', currTag);
                
                % set 'save' flag
                anyChanges = true;
                
            end

            % find the underlying S-Function block
            SFblock = find_system(allMC9S12DriverBlocks{ll}, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');
            SFblockTag = get_param(SFblock{1}, 'Tag');

            % matching tags?
            if isempty(SFblockTag) || ~strcmp(SFblockTag, currTag)

                % nope -> correct tag
                set_param(SFblock{1}, 'Tag', currTag)

                % set 'save' flag
                anyChanges = true;

            end  % SFblockTag ~= currTag
            
            % ADC block?
            if strcmp(currTag, 'mcTarget_adc')
                
                % yep -> replace initialisation command
                oldInit = get_param(allMC9S12DriverBlocks{ll}, 'MaskInitialization');
                newInit = '[channelsStr, firstChannel, numChannels] = mbc_adcinput(channels);';
                
                % still needs changed?
                if ~strcmp(oldInit, newInit)
                    
                    % yep
                    set_param(allMC9S12DriverBlocks{ll}, 'MaskInitialization', newInit);
                
                    % set 'save' flag
                    anyChanges = true;
                    
                end

            end  % ADC block

            % PWM block?
            if strcmp(currTag, 'mcTarget_pwm')

                % yep -> replace SFunction parameters
                oldPara = get_param(SFblock{1}, 'Parameters');
                newPara = 'sampletime, PWMperiod, pulse_pin, sign_port, sign_pin, Vmax, sig_mon';

                % still needs changed?
                if ~strcmp(oldPara, newPara)

                    % yep
                    set_param(SFblock{1}, 'Parameters', newPara);

                    % set 'save' flag
                    anyChanges = true;

                end

            end  % PWM block

            % delete RTWdata from parent block
            oldRTWdata = get_param(allMC9S12DriverBlocks{ll}, 'RTWdata');

            % need to delete this?
            if ~isempty(oldRTWdata)

                % yep
                set_param(allMC9S12DriverBlocks{ll}, 'RTWdata', []);

                % set 'save' flag
                anyChanges = true;

            end

        end  % nAllMC9S12DriverBlocks

    end  % for(allHelpTexts)

    % close system
    if anyChanges

        % save
        close_system(currFile, 1);

    else

        % don't save
        close_system(currFile, 0);

    end


    % load model file as text file
    fhd = fopen(currFile, 'r');
    fcont = [];
    while(~feof(fhd))
        fcont = [fcont fgets(fhd)]; %#ok<AGROW>
    end
    %fcont = fscanf(fhd, '%s');
    fclose(fhd);

    % find all outdated string replacements
    scanAll = [ ...
        strfind(fcont, scanStr{1}) ...
        strfind(fcont, scanStr{2}) ...
        strfind(fcont, scanStr{3}) ...
        strfind(fcont, scanStr{4}) ...
        strfind(fcont, scanStr{5}) ...
        strfind(fcont, scanStr{6}) ...
        ];

    % check if there is anything to update in this model file
    if ~any(scanAll)
        
        % no -> continue with next file
        disp('... file already up to date.')
        continue

    else

        % need to update something

        % apply straight string replacements...
        for ii = 1:length(scanStr)
            
            fcont = strrep(fcont, scanStr{ii}, replStr{ii});
            
        end

        % fix help system...
        h1 = findstr(fcont, 'MaskHelp');
        h2 = findstr(fcont, 'MaskPromptString');
        h3 = findstr(fcont, 'BlockType');

        % number of help text entries to be fixed:
        numHelps = length(h1);

        % ensure that we're only dealing with proper blocks...
        for ii = 1:numHelps

            hh1 = h1(ii);
            hh2 = h2(ii);

            % check if it's a pair...
            if(hh1 > hh2)
                % no -> need to eliminate index from h2 list
                h2(ii) = [];
                ii = ii - 1;      %#ok<FXSET> % try this index again
            end

        end

        % discard trailing 'MaskPromptString' indicees
        if length(h2) ~= numHelps
            h2(numHelps+1:end) = [];
        end

        % fix help entries
        for ii = 1:numHelps

            % determine name of the help file...
            html_name = [];
            
            hh1 = h1(ii);                            % MaskHelp
            hh2 = h2(ii);                            % MaskPromptString
            hh3 = h3(find(h3 < h1(ii), 1, 'last'));  % BlockType before MaskHelp

            % scan for blocks which previously had incorrect settings in
            % their MaskHelp (freePort, fuzzy and rfComms blocks)
            blockName = fcont(hh3:hh1);
            bnQuotes = find(blockName == '"');
            if(~isempty(bnQuotes) && length(bnQuotes) >= 2)
                blockName = blockName(bnQuotes(1)+1:bnQuotes(2)-1);
            else
                blockName = [];
            end

            % check for all previously untidy blocks
            if ~isempty(findstr(blockName, 'FreePortComms_RX'))
                disp(['Block name: |' blockName '|']);
                html_name = 'freePortComms_rxd.html';
            elseif ~isempty(findstr(blockName, 'FreePortComms_TX'))
                disp(['Block name: |' blockName '|']);
                html_name = 'freePortComms_txd.html';
            elseif ~isempty(findstr(blockName, 'fuzzy controller'))
                disp(['Block name: |' blockName '|']);
                html_name = 'fuzzy_ni1o.html';
            elseif ~isempty(findstr(blockName, 'rfComms_Client'))
                disp(['Block name: |' blockName '|']);
                html_name = 'rfComms_client.html';
            elseif ~isempty(findstr(blockName, 'rfComms_Server'))
                disp(['Block name: |' blockName '|']);
                html_name = 'rfComms_server.html';
            elseif ~isempty(findstr(blockName, 'Timer'))
                disp(['Block name: |' blockName '|']);
                html_name = 'timer_sfcn_9S12.html';
            end

            
            if isempty(html_name)

                % not one of the untidy blocks -> update using the above
                % database

                %disp(['|' fcont(hh1:hh2) '|'])

                % find out what type of block we're dealing with...
                currEntry = fcont(hh1:hh2);
                hhA = findstr(currEntry, 'mc9S12.map''');
                currEntry = fcont(hh1+hhA+length('mc9S12.map''')-1:hh2);
                %disp(['|' currEntry '|'])
                currEntry(currEntry == '"') = [];
                currEntry(currEntry == 10)  = [];
                currEntry(currEntry == 13)  = [];
                currEntry = currEntry(find(currEntry == '''', 1, 'first')+1:find(currEntry == '''', 1, 'last')-1);
                %disp(['|' currEntry '|'])

                % check all known help entries...
                html_name = [];
                for m = 1:length(myHelpEntries)

                    refEntry = myHelpEntries{m};

                    %disp(['currEntry: ' currEntry])
                    %disp(['refEntry: ' refEntry{1}])

                    % check against known entry (case insensitve)
                    if(strcmpi(currEntry, refEntry{1}))
            
                        % found it -> set correct html name
                        html_name = refEntry{2};

                        % html_name found -> break free from the for loop
                        break;

                    end

                end  % for

            end  % if not one of the untidy blocks


            % at this stage we should have found a suitable help file. If
            % not, we'll leave the entry untouched
            if ~isempty(html_name)
                
                hhA = find(fcont(hh1:hh2) == '"', 1, 'first');
                hhB = find(fcont(hh1:hh2) == '"', 1, 'last');
                old_txt = fcont(hh1+hhA-1:hh1+hhB-1);
                old_len = length(old_txt);
                disp(['Old help text: |' old_txt '|'])

                % replace...
                new_txt = ['"web(''' html_name ''');"'];
                new_len = length(new_txt);
                fcont = [fcont(1:hh1+hhA-2) new_txt fcont(hh1+hhB:end)];

                % adjust indicees...
                indexAdjustment = old_len - new_len;
                if(ii < numHelps)
                    h1(ii+1:end) = h1(ii+1:end) - indexAdjustment;
                end
                h2 = h2 - indexAdjustment;
                h3 = h3 - indexAdjustment;

                hh1 = h1(ii);
                hh2 = h2(ii);

                %disp(['|' fcont(hh1:hh2) '|'])

                hhA = find(fcont(hh1:hh2) == '"', 1, 'first');
                hhB = find(fcont(hh1:hh2) == '"', 1, 'last');
                new_txt = fcont(hh1+hhA-1:hh1+hhB-1);
                disp(['New help text: |' new_txt '|'])
                
            end

        end % for all help entries...


        % ensure that the format remains intact
        l2 = find(fcont == 10);

        % fill cell array with lines of the source file
        myLineDelimits = unique([0 l2 length(fcont)]);
        myLines = cell(1, length(myLineDelimits)-1);

        for k = 1:length(myLines)
            myLines{k} = fcont(myLineDelimits(k)+1:myLineDelimits(k+1));
        end


        % write corrected file back to disc
        fcont = [];
        for k = 1:length(myLines)
            fcont = [fcont myLines{k}]; %#ok<AGROW>
        end

        disp(['Writing modified file ' currFileName])
        fhd = fopen(currFile, 'w');
        fwrite(fhd, fcont);
        fclose(fhd);


        disp('... model updated.')

    end % file needs updated...

end % all files


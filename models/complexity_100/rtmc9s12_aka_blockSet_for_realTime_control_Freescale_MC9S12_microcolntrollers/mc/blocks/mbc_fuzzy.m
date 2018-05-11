function [MSFinputXstr, MSFoutputstr, ruleBasestr] = mbc_fuzzy(numInputs, MSFinput1, MSFinput2, MSFinput3, MSFoutput, ruleBase, sampletime)

% Check the sample time:
if sampletime < 0 && sampletime ~= -1
    fprintf ('Fuzzy: Inadmissible sample time.\n');
end


if ~isempty(MSFoutput)
    MSFoutputstr = MSFoutput;
else
    error('Fuzzy: Need to specify the centroids of the output MSFs.');
end

if ~isempty(ruleBase)
    ruleBasestr  = ruleBase;
else
    error('Fuzzy: Need to specify the rule base.');
end


% adjust parameter display
switch numInputs
    
    case 1
        set_param(gcb, 'MaskVisibilities', {'on', 'on', 'off', 'off', 'on', 'on', 'on' });
       
    case 2
        set_param(gcb, 'MaskVisibilities', {'on', 'on', 'on', 'off', 'on', 'on', 'on' });
        
    case 3
        set_param(gcb, 'MaskVisibilities', {'on', 'on', 'on', 'on', 'on', 'on', 'on' });
        
end


% ensure that all required input MSFs have been defined
if numInputs == 1
    
    if ~isempty(MSFinput1)
        MSFinputXstr = ['MSFs input 1: ' MSFinput1];
        MSFinput2 = '-';
        MSFinput3 = '-';
    else
        error('Fuzzy: need to specify input membership functions file for input 1.');
    end
    
elseif numInputs == 2
    
    if ~isempty(MSFinput1) && ~isempty(MSFinput2)
        MSFinputXstr = ['MSFs input 1: ' MSFinput1 '\nMSFs input 2: ' MSFinput2]; %s\nMSFs input 3: '];
        MSFinput3 = '-';
    else
        error('Fuzzy: need to specify input membership functions files for inputs 1 and 2.');
    end
    
elseif numInputs == 3
    
    if ~isempty(MSFinput1) && ~isempty(MSFinput2) && ~isempty(MSFinput3)
        MSFinputXstr = ['MSFs input 1: ' MSFinput1 '\nMSFs input 2: ' MSFinput2 '\nMSFs input 3: ' MSFinput3];
    else
        error('Fuzzy: need to specify input membership functions files for inputs 1 - 3.');
    end

end


%% adjust number of input ports...


% de-activate link to library (permanently)
if ~strcmp(get_param(gcb, 'LinkStatus'), 'inactive')
    
    %set_param(gcb, 'LinkStatus', 'inactive')
    set_param(gcb, 'LinkStatus', 'none')
    
end


% Get current number outputs
num_now = length (find_system (gcb, 'LookUnderMasks', 'on', 'BlockType', 'Inport'));
%disp(['num_now = ' num2str(num_now)]);

if numInputs < num_now

    % too many inputs -> delete the ones that are not required
    for k = numInputs+1:num_now
        delete_line (gcb, ['In', num2str(k), '/1'], ['fuzzy_ni1o_sfcn/', num2str(k)])
        delete_block ([gcb, '/In', num2str(k)])
    end
    
    % adjust the number of input ports of the 'fuzzy_ni1o_sfcn' block
    sPars = get_param ([gcb, '/fuzzy_ni1o_sfcn'], 'Parameters');
    sPars = strrep(sPars, 'numInputs', num2str(numInputs));           % replace parameter 'numInputs' with the actual number
    set_param([gcb, '/fuzzy_ni1o_sfcn'], 'Parameters', sPars);         % force input ports to match the actual number
    sPars = strrep(sPars, num2str(numInputs), 'numInputs');           % restore original parameter 'numInputs'
    set_param([gcb, '/fuzzy_ni1o_sfcn'], 'Parameters', sPars);
    
else

    % too few inputs -> add the missing ones
    
    % adjust the number of input ports of the 'fuzzy_ni1o_sfcn' block
    sPars = get_param ([gcb, '/fuzzy_ni1o_sfcn'], 'Parameters');
    sPars = strrep(sPars, 'numInputs', num2str(numInputs));           % replace parameter 'numInputs' with the actual number
    set_param([gcb, '/fuzzy_ni1o_sfcn'], 'Parameters', sPars);         % force input ports to match the actual number
    sPars = strrep(sPars, num2str(numInputs), 'numInputs');           % restore original parameter 'numInputs'
    set_param([gcb, '/fuzzy_ni1o_sfcn'], 'Parameters', sPars);

    for i = num_now+1:numInputs
        add_block ('built-in/Inport', [gcb, '/In', num2str(i)])
        set_param ([gcb, '/In', num2str(i)], 'Position', get_param ([gcb, '/In', num2str(i-1)], 'Position') + [0 45 0 45])
        set_param ([gcb, '/In', num2str(i)], 'FontSize', '12')
        add_line (gcb, ['In', num2str(i), '/1'], ['fuzzy_ni1o_sfcn/', num2str(i)])
    end
    
end


% determine block name
myName = gcb;
myName(myName == ' ') = '_';
myName(1:find(myName == '/', 1, 'last' )) = [];

% analyze fuzzy specification (MSFs, etc.)
[textInputMSFs, textOutputMSFs, textInputMSFdef, textRules, textOutputSingletons, numMSFsInput1, numMSFsInput2, numMSFsInput3, numMSFsOutput] = ...
    extract_MSF_terms(MSFinput1, MSFinput2, MSFinput3, MSFoutputstr, ruleBasestr, myName);

% Create resource keywords to be reserved in resource database
modelRTWFields = struct( 'InputMSFs', textInputMSFs, ...
                         'OutputMSFs', textOutputMSFs, ...
                         'InputMSFdef', textInputMSFdef, ...
                         'OutputSingletons', textOutputSingletons, ...
                         'Rules', textRules, ...
                         'blockName', myName, ...
                         'numInputs', num2str(numInputs), ...
                         'numMSFsInput1', num2str(numMSFsInput1), ...
                         'numMSFsInput2', num2str(numMSFsInput2), ...
                         'numMSFsInput3', num2str(numMSFsInput3), ...
                         'numMSFsOutput', num2str(numMSFsOutput)); 

                     
% Insert modelRTWFields in the I/O block S-Function containing the Tag 'MC9S12DriverDataBlock'
MC9S12DriverDataBlock = find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function', 'Tag', 'mcTarget_fuzzy');
for i = 1:length(MC9S12DriverDataBlock)
    set_param(MC9S12DriverDataBlock{i}, 'RTWdata', modelRTWFields);
end


% read current options as specified in the source parameters
function sourceResources = mc_readOptions(source, targetPrefix)

% source: preference file or model
if exist(source, 'file') == 4
    
    % model
    isSourceType = 1;
    
elseif exist(source, 'file') == 2
    
    % preference file
    isSourceType = 2;
    
else
    
    % source type not supported
    error('mc_readOptions: unsupported source type ''%s''', source)
    
end
    
% create new 'resources' object
sourceResources = mcResources;

% populate resource object with corresponding source parameters
% note: source option 'Build style' is dealt with separately (see below)
myPars = setdiff(fieldnames(sourceResources), 'BuildStyle');


% parse source
if isSourceType == 1
    
    % source type: model
    for ii = 1:length(myPars)

        % making use of naming convention to automate this: all parameters have
        % the name prefix 'mc9s12_'. The names of the corresponding object 
        % parameters are without this prefix
        currPar = [targetPrefix myPars{ii}];

        % ensure no missing parameters can cause an error here...
        try

            % fetch next parameter
            sourceResources.(myPars{ii}) = feval(@get_param, source, currPar);

        catch %#ok<CTCH>

            % do nothing

        end

    end

else
    
    % source type: preference file
    %
    %  'mc9s12_TargetBoard: 'Dragon12Plus''
    %  'mc9s12_ExtModeStatMemAlloc: 'off''
    %  'mc9s12_ExtModeStatMemSize: 6500'
    %
    allPrefs = textread(source, '%[^\n]');
    
    
    for ii = 1:length(allPrefs)

        % making use of naming convention to automate this: all parameters have
        % the name prefix 'mc9s12_'. The names of the corresponding object 
        % parameters are without this prefix
        currPar = char(regexp(allPrefs{ii}, [targetPrefix '(\w+):'], 'tokens', 'once'));
        currVal = char(regexp(allPrefs{ii}, '\w+:\s*['']{0,1}(\w+)['']{0,1}', 'tokens', 'once'));

        % ensure no missing parameters can cause an error here...
        try

            % fetch next parameter
            sourceResources.(currPar) = currVal;

        catch %#ok<CTCH>

            % do nothing

        end

    end
    
end
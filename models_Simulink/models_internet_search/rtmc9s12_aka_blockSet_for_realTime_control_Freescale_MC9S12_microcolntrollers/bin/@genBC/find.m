% genBC.find : (generic) method find for base class 'genBC'
%
% returns zero or more objects of the specified class with properties
% matching the specified pattern(s). The properties can be located in
% nested objects below the specified return class. The command optionally
% returns a cell array of paths to the resulting objects (see examples).
%
% Examples:
%
% [1]
% >> [objs, paths] = find(nk, 'isa', 'bmwSignal', 'property', ...
%      {'signalStartBitInFrame', {'^0$', '2'}}, 'regexp', 'on')
% ... searches object 'nk' for objects of class 'bmwSignal' which define
% a property 'signalStartBitInFrame' with a value of either '0' or
% including the digit '2' (-> '20', '32', etc.). The search uses regular
% expressions.
%
% [2]
% >> find(nk, 'isa', 'bmwFrame', 'property', ...
%      {'signalStartBitInFrame', {'0', '20'}}, 'searchNestedObjects', true)
% ... searches object 'nk' for objects of class 'bmwFrame' which
% (indirectly) define a property 'signalStartBitInFrame' with a value of
% either '0' or '20'. The search does not make use of regular expressions.
% Note that the requested property ('signalStartBitInFrame') is not 
% directly located/defined in class 'bmwFrame' but in the nested object 
% 'bmwSignal' (each frame defines one or more signals).
%
% [3]
% >> find(nk, 'isa', 'char', 'property', {'frameID', 'frame79'}, ...
%      'regexp', 1, 'findOnce', true)
% ... searches object 'nk' for objects of class 'char' which define a
% property 'frameID' with a value starting with 'frame79'. The search
% makes use of regular expressions. The function returns as soon as the
% first match has been found.
%
% [4]
% >> [objs, paths] = find(nk, 'isa', 'double')
% ... searches object 'nk' for objects of class 'double'. Both the objects
% as well as the path information to these objects are returned.
%
% [5]
% >> [objs, paths] = find(nk, 'property', {'frameID', 'frame79'}, ...
%      'regexp', 1, 'findOnce', true)
% ... searches object 'nk' for the first object with frameID 'frame79'. No
% explicit return class has been specified.
%
% fw-03-09

function [res, resPath] = find(this, varargin)


%% check for presence of optional parameters
optPars = varargin;
nOptPars = length(optPars);

% default values of optional parameters
findOnceFlag            = false;
regexpFlag              = false;
searchNestedObjectsFlag = false;
desiredClass            = '';
propertyPairs           = {};

% parse all optional parameters (if any)
ii = 1;
while ii <= nOptPars

    switch optPars{ii}

        case { 'regexp', 'findOnce', 'searchNestedObjects' }

            % ensure there is at least one further callup parameter
            if ii + 1 > nOptPars

                % nope -> problem
                error(['Option ''' optPars{ii} ''' needs one further parameter: ''on'', ''off'', true, false, 1 or 0'])

            end

            % all good -> parse next parameter
            currFlag = optPars{ii + 1};

            % allow for 'on' / 'off' as well as for true / false and 1 / 0
            if ischar(currFlag)

                if strcmp(currFlag, 'on')

                    currFlag = true;

                else

                    currFlag = false;

                end

            elseif isnumeric(currFlag) && (currFlag == 0 || currFlag == 1)

                currFlag = logical(currFlag);

            elseif islogical(currFlag) && (currFlag == false || currFlag == true)

                % currFlag already properly specified
                % -> do nothing
                
            else

                error('Unknown regular expression flag (permitted values: ''on'', ''off'', true, false, 1 or 0)')

            end
            
            % set flag
            eval([optPars{ii} 'Flag = logical(' num2str(currFlag) ');']);

            % next optional parameter
            ii = ii + 2;

        case 'isa'

            % ensure there is at least one further callup parameter
            if ii + 1 > nOptPars

                % nope -> problem
                error('Option ''isa'' needs one further parameter (class)')

            end

            % all good -> parse next parameter
            desiredClass = optPars{ii + 1};

            % ensure 'desiredClass' is a string
            if ~ischar(desiredClass)

                % not a string -> error
                error('Option ''isa'' needs to be followed by a class specifier (string)')

            end

            % next optional parameter
            ii = ii + 2;

        case 'property'

            % ensure there is at least one further callup parameter
            if ii + 1 > nOptPars

                % nope -> problem
                error('Option ''property'' needs one further parameter: {''name1'', ''value1''[, ''name2'', ''value2''[, etc.]]}')

            end

            % all good -> parse next parameter
            propertyPairs = optPars{ii + 1};

            % ensure 'propertyPairs' is a cell
            if ~iscell(propertyPairs)

                % not a string -> error
                error('Option ''property'' needs to be followed by a cell array: {''name1'', ''value1''[, ''name2'', ''value2''[, etc.]]}')

            end

            % next optional parameter
            ii = ii + 2;

        otherwise

            % unsupported option -> error
            error(['Unknown option: ' optPars{ii}])

    end  % switch

end  % while (optPars)

% extract properties and patterns from 'propertyPairs'
properties = {};
patterns   = {};
while ~isempty(propertyPairs)

    % fetch next property pair
    properties{end + 1} = propertyPairs{1};
    patterns{end + 1}   = propertyPairs{2};

    % remove pair from list
    propertyPairs = propertyPairs(3:end);

end  % while


% set flags according to optional parameters

% properties flag
if isempty(properties)
    
    % no properties specified
    checkProperties = false;
    
else
    
    % some properties specified
    checkProperties = true;
    
end

% classes flag
if isempty(desiredClass)
    
    % no return class specified
    checkReturnClass = false;
    
else
    
    % some return class has been specified
    checkReturnClass = true;
    
end


%% determine all properties and classes included in 'this' (if necessary)

[allProperties, allClasses] = fetchAllPropsAndClasses(this);

% ensure all specified properties exists in the object
if checkProperties && ~all(ismember(properties, allProperties))

    error('Some of the specified property do not exist in the provided object')

end

% ensure the requested class exists in the object
if checkReturnClass && ~isempty(desiredClass) && ~ismember(desiredClass, allClasses)

    error(['Class ''' desiredClass ''' is not a valid return class'])

end

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% AT THIS POINT WE ARE SURE THAT THE (POSSIBLY) REQUESTED RETURN CLASS 
% EXISTS AND THAT THE (POSSIBLY) REQUESTED PROPERTIES EXIST.
% NOTE: IT IS STILL POSSIBLE THAT NO OBJECT FULFILLS BOTH CRITERIA
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%% determine all paths to objects including any of the requested properties

% only search the object once per requested property
uniqueProps = unique(properties);
nUniqueProps = length(uniqueProps);

% do we mind what properties exist?
if checkProperties

    % yes we do -> determine all suitable (properties) paths
    allPropsPaths = {};
    for ii = 1:nUniqueProps

        % fetch all paths to the current property
        currPropsPaths = fetchPropsPaths(this, uniqueProps{ii});

        % append found paths to 'allPropsPaths'
        if iscell(currPropsPaths)

            % more than one path found (cell array)
            for kk = 1:length(currPropsPaths)

                % append next path
                allPropsPaths{end + 1, 1} = currPropsPaths{kk};

            end

        else

            % single path (string)
            allPropsPaths{end + 1, 1} = currPropsPaths;

        end

    end  % for (nUniqueProps)
    
else
    
    % nope (no properties specified)
    allPropsPaths = {};
    
end


%% determine all paths to objects of the desired (return) class

% do we mind the return class?
if checkReturnClass
    
    % yes we do -> determine all suitable (class) paths
    allClassPaths = fetchClassPaths(this, desiredClass);

    % ensure we're working with a cell from here on...
    if ~iscell(allClassPaths)

        allClassPaths = { allClassPaths };

    end
    
    % ensure this is a vertical vector (for added 'prettiness')
    allClassPaths = reshape(allClassPaths, length(allClassPaths), 1);

else
    
    % nope, return class is irrelevant
    allClassPaths = {};
    
end


%% make a list of paths to objects for which BOTH criteria apply

% It's only worth checking those paths for which the desired class is as
% specified AND any of the sought after properties exist. Note: This still 
% does not mean that the specified properties match the specified patterns!

if checkProperties && checkReturnClass
    
    % need to find all paths which fulfil both criteria (properties, class)
    allValidSearchPaths = {};
    for ii = 1:length(allClassPaths)

        % fetch next valid class path
        currClassPath = allClassPaths{ii};

        % is the current class path one of the valid properties paths?
        validIDX = ~strcmp(regexp(allPropsPaths, currClassPath, 'match', 'once'), '');

        if any(validIDX)

            % yes -> filter out valid paths
            validPaths = allPropsPaths(validIDX);
            
            % add compatible 'property' paths to valid search path
            if iscell(validPaths)
                
                % more than one path -> add'em one by one
                for kk = 1:length(validPaths)
                    
                    % append path
                    allValidSearchPaths{end + 1, 1} = validPaths{kk};
                    
                end  % for
                
            else
                
                % not a cell -> single path
                allValidSearchPaths{end + 1, 1} = validPaths;
                
            end

        end  % any(validIDX)

    end

elseif checkProperties
    
    % only checking properties, class is irrelevant
    allValidSearchPaths = allPropsPaths;
    
else
    
    % only checking classes, properties are irrelevant
    allValidSearchPaths = allClassPaths;
        
end

% determine the total number of paths to be scanned
nAllValidSearchPaths = size(allValidSearchPaths, 1);

% any results possible at all?
if nAllValidSearchPaths == 0

    % no objects fulfill all specified criteria (class and/or properties)
    res     = [];
    resPath = [];

    % -> we're done
    return

end

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% AT THIS POINT WE HAVE A LIST OF ALL PATHS TO BE SCANNED FOR EITHER A
% SPECIFIED PROPERTY, A SPECIFIED CLASS OR BOTH. IF 'checkProperties' IS
% 'true' THE PATHS ARE PROPERTY PATHS, OTHERWISE THEY ARE CLASS PATHS.
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%% search -> determine true results, searching the valid paths

% initialize return variable(s): nothing found yet
res = {};
resPath = {};
nothingFound = 1;

% loop over all candidate paths
for ii = 1:nAllValidSearchPaths

    % fetch current candidate path
    currPath = allValidSearchPaths{ii};


    % are we searching for specific properties?
    if checkProperties
        
        % yes -> 'currPath' is a property path
        for kk = 1:nUniqueProps

            % fetch next property
            currProp = uniqueProps{kk};
            
            % check if the current path relates to the current property
            if ~isempty(regexp(currPath, ['.' currProp '$'], 'match', 'once'))
                
                % yes -> remove property from path
                currClassPath = regexprep(currPath, ['([\w\.]+)\.' currProp], '$1');

                % fetch all patterns which correspond to the current property
                validIDX = ~strcmp(regexp(properties, currProp, 'match', 'once'), '');
                currPatterns = patterns(validIDX);

                % recursively search through the current path to determine
                % if the current property matches the specified patterns
                % inOrBelowTargetClass (last call-up parameter) is initially set
                % to 'false'
                [res{end + 1, 1}, resPath{end + 1, 1}] = searchValidPath(this, ...
                    currClassPath, desiredClass, currProp, currPatterns, ...
                    regexpFlag, findOnceFlag, searchNestedObjectsFlag, ...
                    checkReturnClass, false);

                % have we found anything?
                if nothingFound && ~isempty(resPath{ii})

                    % yes -> reset 'nothingFound' flag
                    nothingFound = 0;

                    % are we done altogether?
                    if findOnceFlag

                        % one match is all we are after -> done
                        break

                    end

                end  % nothingFound
                
            end  % currPath relates to currProp
            
        end  % for (all unique properties)
        
    else
        
        % class path -> not looking for any specific properties

        % recursively search through the current path to find all entries
        % matching the desired class. Flag 'inOrBelowTargetClass' (last 
        % call-up parameter) is always 'false' in this case.
        [res{end + 1, 1}, resPath{end + 1, 1}] = searchValidPath(this, ...
            currPath, desiredClass, '', '.*', ...
            regexpFlag, findOnceFlag, searchNestedObjectsFlag, ...
            checkReturnClass, false);

        % have we found anything?
        if nothingFound && ~isempty(resPath{ii})

            % yes -> reset 'nothingFound' flag
            nothingFound = 0;

            % are we done altogether?
            if findOnceFlag

                % one match is all we are after -> done
                break

            end

        end  % nothingFound

    end  % checkProperties

end  % for (allClassPaths)

% any results?
if nothingFound

    % nope -> return empty array
    res     = [];
    resPath = [];

    % we're done
    return

end


%% resolve unnecessary cell arrays

% more than one search pattern (--> AND'em)
if length(res) > 1

    % yes - filter out common results
    allResPaths = unique(vertcat(resPath{:}));

    % no return class specified -> results can be of differing classes
    for ii = 1:length(res)

        % fetch next result
        currRes = res{ii};
        currResPath = resPath{ii};

        % eliminate double entries in 'currRes'
        if iscell(currRes)

            % more than one result -> uniquify
            [dummy, I] = unique(currRes);
            I = sort(I);

            % preserve the original order of all result elements...
            res{ii} = currRes(I);

        end

        % eliminate double entries in 'currResPath'
        if iscell(currResPath)

            % more than one path -> uniquify
            [dummy, I] = unique(currResPath);
            I = sort(I);

            % preserve the original order of all result elements...
            resPath{ii} = currResPath(I);

        end

        % reduce results to common results
        [dummy, I] = intersect(allResPaths, currResPath);
        I = sort(I);

        % preserve the original order of all result elements...
        allResPaths = allResPaths(I);
        
    end  % for (all results)

    % reduce output results
    resPath = allResPaths;

    % corresponding 'res'
    nResPath = length(resPath);
    resOut   = cell(nResPath, 1);

    % loop over all results
    for ii = 1:nResPath

        % fetch result corresponding to current path
        resOut{ii} = eval(resPath{ii});

    end

    % consolidate results
    res = vertcat(resOut{:});

    % sort results
    [dummy, I] = sort(str2double(regexp(resPath, '\d+', 'match', 'once')));
    resPath    = resPath(I);
    res        = res(I);

else

    % a single search pattern has been used -> eliminate cell arrays
    if iscell(res)

        % de-cellify...
        res = res{1};
        resPath = resPath{1};

    end

end





%% local functions




%% recursively determine all fieldnames and classes of the current object

function [thisLevelFieldNames, thisLevelClasses] = fetchAllPropsAndClasses(this)

% is 'this' empty / a 'struct'?
if isstruct(this)
    
    % yep -> get fieldnames
    thisLevelFieldNames = fieldnames(this);
    
    % ensure this is a cell...
    if ~iscell(thisLevelFieldNames)
        
        % cellify
        thisLevelFieldNames = { thisLevelFieldNames };
        
    end
    
    % ... determine classes of all subordinates
    thisLevelClasses = cell(size(thisLevelFieldNames));
    
    % ASSUMPTION: all structs of the array have the same structure -> using
    % 'this(1)' as representative to determine classes...
    for ii = 1:length(thisLevelClasses)
        
        % fetch class of current subordinate
        if isempty(this)
            
            % empty struct 'this' -> assume the class is 'char' (default)
            thisLevelClasses{ii} = 'char';
            
        else
            
            % non-empty struct -> fetch class
            thisLevelClasses{ii} = class(this(1).(thisLevelFieldNames{ii}));
            
        end
        
    end
    
else

    % not a struct array -> determine fieldnames and classes directly

    % avoid bug in fieldnames(*, '-full') by instantiating a non-empty
    % object of the same class as 'this'
    tmpObj = eval(class(this));
    
    thisLevel = fieldnames(tmpObj, '-full');
    thisLevelFieldNames = regexp(thisLevel, '(\w*)\s+%\w*', 'tokens');
    thisLevelFieldNames = [thisLevelFieldNames{:}]';
    thisLevelFieldNames = [thisLevelFieldNames{:}]';

    thisLevelClasses = regexp(thisLevel, '\w*\s+%\s+(\w*)', 'tokens');
    thisLevelClasses = [thisLevelClasses{:}]';
    thisLevelClasses = [thisLevelClasses{:}]';
    
end


% -> determine names & classes of (possibly) nested objects
for ii = 1:length(thisLevelFieldNames)

    % next fieldname
    currFN = thisLevelFieldNames{ii};

    % exclude 'non-existent' entry 'genBC'
    if ~strcmp(currFN, 'genBC')
        
        % fetch next element (to determine its class)...
        
        % struct array?
        if isstruct(this)
            
            % yep -> fetch struct element... using 'this(1)' as
            % representative of the entire array ('homogenious array')
            if ~isempty(this)
                
                % non-empty struct
                currEl = this(1).(currFN);
                
            else
                
                % empty struct
                currEl = [];
                
            end
            
        else
            
            % not a struct -> fetch element (from replacement object to
            % avoid problems with empty 'this' objects
            tmpObj = eval(class(this));
            currEl = get(tmpObj, currFN);
            
        end


        % determine class...

        % cell array?
        if iscell(currEl)

            % get class of cell elements (ASSUMED to be of the same kind!)
            currClass = class(currEl{1});

            % disolve cell (ASSUMPTION: all elements are of the same type)
            if ~ischar(currEl{1}) && ~isnumeric(currEl{1})
                
                % cell array of things other than strings and numbers
                try
                    % default: vertical concatination
                    currEl = vertcat(currEl{:});
                catch
                    % fallback solution: horizontal concatination
                    currEl = [currEl{:}];
                end
                
            end

        else

            % not a cell -> get class directly
            currClass = class(currEl);

        end

        % is this a struct or a nested object?
        try

            % there might be sub levels
            subFN = fieldnames(currEl);

        catch

            % no sub levels
            subFN = [];

        end

        % nested object with sub levels?
        if ~isempty(subFN)

            % yes -> recursively fetch fieldnames and classes
            [subLevelFieldNames, subLevelClasses] = fetchAllPropsAndClasses(currEl);

            % append to existing list
            if ~isempty(subLevelFieldNames)

                thisLevelFieldNames = [thisLevelFieldNames; subLevelFieldNames];
                thisLevelClasses = [thisLevelClasses; subLevelClasses];

            end

        else

            % not a nested object -> just append fieldname and class
            thisLevelFieldNames{end + 1} = currFN;
            thisLevelClasses{end + 1} = currClass;

        end

    end  % if (not 'genBC')

end  % for (thisLevelFieldNames)


% remove 'non-existant' property 'genBC' and its class
thisLevelFieldNames = setdiff(unique(thisLevelFieldNames), 'genBC');
thisLevelClasses = union(setdiff(unique(thisLevelClasses), 'inherited'), class(this));

% ensure this is a vertical vector (for added 'prettiness')
thisLevelFieldNames = reshape(thisLevelFieldNames, length(thisLevelFieldNames), 1);
thisLevelClasses = reshape(thisLevelClasses, length(thisLevelClasses), 1);


%% (recursively) determine all paths to objects with the requested property

function res = fetchPropsPaths(this, property)

% flag to decide if this is a recursive call to this method
persistent recursiveCall;


% initialize return variable
res = {};

% determine the names of all entries at this level
thisLevelFieldNames = fieldnames(this);

% eliminate 'genBC' (if present)
[dummy, idx] = setdiff(thisLevelFieldNames, 'genBC');
thisLevelFieldNames = thisLevelFieldNames(sort(idx));


% loop over all struct entries
for ii = 1:length(thisLevelFieldNames)

    % next fieldname
    currFN = thisLevelFieldNames{ii};

    % initialize return path candidate
    if isempty(recursiveCall)

        % top level -> preceeding fieldname by 'this.'
        currPath = ['this.' currFN];

    else

        % recursive call -> just using the fieldname
        currPath = currFN;

    end

    % fetch corresponding entry
    try

        % not a struct -> fetch element (from replacement object to
        % avoid problems with empty 'this' objects
        tmpObj = eval(class(this));
        currEl = get(tmpObj, currFN);
        
    catch

        % structs
        if ~isempty(this)

            % non-empty struct
            
            % struct array?
            if length(this) > 1
                
                % yes -> resolve (just syntactially -> emerging cell array
                % is 'merged' below -> contents become 'non-sensical')
                eval(['currEl = { this.' currFN ' }'';']);
                
            else
                
                % single struct -> fetch struct element
                eval(['currEl = this.' currFN ';']);
                
            end

        else

            % empty struct
            currEl = [];

        end

    end

    % turn cell array into regular array to 'reveal' class of its elements
    if iscell(currEl)

        % disolve cell (ASSUMPTION: all elements are of the same type)
        if ~ischar(currEl{1}) && ~isnumeric(currEl{1})

            % cell array of things other than strings and numbers
            try
                % default: vertical concatination
                currEl = vertcat(currEl{:});
            catch
                % fallback solution: horizontal concatination
                currEl = [currEl{:}];
            end

        end

    end

    % correct property?
    if strcmp(currFN, property)

        % yes -> append current entry name to 'res'
        res{end + 1} = currPath;

    end

    % is this a struct or a nested object?
    try

        % attempt to get fieldnames of assumed sub-objects
        subFN = fieldnames(currEl);
        [dummy, idx] = setdiff(subFN, 'genBC');
        subFN = subFN(sort(idx));

    catch

        % failed -> no sub-objects
        subFN = [];

    end

    % nested sub-object?
    if ~isempty(subFN)

        % set flag to indicate a 'recursive call'
        if isempty(recursiveCall)

            % first recursive call
            recursiveCall = 1;

        else

            % nested recursive call
            recursiveCall = recursiveCall + 1;

        end

        % yes -> recursively fetch further paths
        subPaths = fetchPropsPaths(currEl, property);

        % reset 'recursive call' flag
        recursiveCall = recursiveCall - 1;

        % reached top level yet?
        if recursiveCall == 0

            % completely out all recursive calls
            recursiveCall = [];

        end

        % append result to existing list of results
        if ~isempty(subPaths)

            % adjust path(s)
            if iscell(subPaths)

                % more than one subpaths -> add'em one by one
                for kk = 1:length(subPaths)

                    % adjust (and store) current path
                    res = appendResult(res, [currPath '.' char(subPaths{kk})]);

                end  % for (all subPaths)

            else

                % only one 'subPath' found
                res = appendResult(res, [currPath '.' subPaths]);

            end  % subPaths is 'cell'

        end  % any subPaths

    end  % any sub levels

end  % for (all entries of this level)


%% (recursively) determine all paths to the sought after class

function res = fetchClassPaths(this, desiredClass)

% flag to decide if this is a recursive call to this method
persistent recursiveCall;


% initialize return variable
if isempty(recursiveCall) && isa(this, desiredClass)

    % top level is of the desired class -> add as first result
    res = { 'this' };

else

    % recursive calls & undesired top level class
    res = {};

end

% determine the names of all entries at this level
thisLevelFieldNames = fieldnames(this);

% eliminate 'genBC' (if present)
[dummy, idx] = setdiff(thisLevelFieldNames, 'genBC');
thisLevelFieldNames = thisLevelFieldNames(sort(idx));


% loop over all struct entries
for ii = 1:length(thisLevelFieldNames)

    % next fieldname
    currFN = thisLevelFieldNames{ii};

    % initialize return path candidate
    if isempty(recursiveCall)

        % top level -> preceeding fieldname by 'this.'
        currPath = ['this.' currFN];

    else

        % recursive call -> just using the fieldname
        currPath = currFN;

    end

    % fetch corresponding entry
    try

        % not a struct -> fetch element (from replacement object to
        % avoid problems with empty 'this' objects
        tmpObj = eval(class(this));
        currEl = get(tmpObj, currFN);

    catch

        % structs
        if ~isempty(this)

            % non-empty struct
            
            % struct array?
            if length(this) > 1
                
                % yes -> resolve (just syntactially -> emerging cell array
                % is 'merged' below -> contents become 'non-sensical')
                eval(['currEl = { this.' currFN ' }'';']);
                
            else
                
                % single struct -> fetch struct element
                eval(['currEl = this.' currFN ';']);
                
            end

        else

            % empty struct
            currEl = [];

        end

    end

    % turn cell array into regular array to 'reveal' class of its elements
    if iscell(currEl)

        % need to determine if all cell array members are of the same class
        homCellArray = true;
        currClass = class(currEl{1});

        % check class of each individual array member
        for kk = 2:length(currEl)

            % class same as that of the first array member?
            if ~isa(currEl{kk}, currClass)

                % nope -> detected inhomogeneous cell array
                homCellArray = false;
                break

            end

        end

        % are all cell array members of the same class?
        if homCellArray

            % yes -> unfold cell array
            try
                % default: vertical concatination
                currEl = vertcat(currEl{:});
            catch
                % fallback solution: horizontal concatination
                currEl = [currEl{:}];
            end

        end

    else

        % not a cell array -> identical classes by definition
        homCellArray = true;

    end


    % inhomogenous cell array?
    if iscell(currEl) && ~homCellArray

        % yes -> need to check each individual member
        for kk = 1:length(currEl)
            
            % fetch next cell array member
            currElmember = currEl{kk};

            % target class?
            if isa(currElmember, desiredClass)

                % yes -> append current entry name to 'res'
                res{end + 1} = currPath;

            end

            % is this a struct or a nested object?
            try

                % attempt to get fieldnames of assumed sub-objects
                subFN = fieldnames(currEl{kk});
                [dummy, idx] = setdiff(subFN, 'genBC');
                subFN = subFN(sort(idx));

            catch

                % failed -> no sub-objects
                subFN = [];

            end

            % nested sub-object?
            if ~isempty(subFN)

                % set flag to indicate a 'recursive call'
                if isempty(recursiveCall)

                    % first recursive call
                    recursiveCall = 1;

                else

                    % nested recursive call
                    recursiveCall = recursiveCall + 1;

                end

                % yes -> recursively fetch further paths
                subPaths = fetchClassPaths(currEl{kk}, desiredClass);

                % reset 'recursive call' flag
                recursiveCall = recursiveCall - 1;

                % reached top level yet?
                if recursiveCall == 0

                    % completely out all recursive calls
                    recursiveCall = [];

                end

                % append result to existing list of results
                if ~isempty(subPaths)

                    % adjust path(s)
                    if iscell(subPaths)

                        % more than one subpaths -> add'em one by one
                        for ll = 1:length(subPaths)

                            % adjust (and store) current path
                            res = appendResult(res, [currPath '.' char(subPaths{ll})]);

                        end  % for (all subPaths)

                    else

                        % only one 'subPath' found
                        res = appendResult(res, [currPath '.' subPaths]);

                    end  % subPaths is 'cell'

                end  % any subPaths

            end  % any sub levels

        end  % all cell array members (kk)

    else  % if (inhomogeneous cell array)

        % 'currEl' is not/no longer a cell array -> check directly

        % target class?
        if isa(currEl, desiredClass)

            % yes -> append current entry name to 'res'
            res{end + 1} = currPath;

        end

        % is this a struct or a nested object?
        try

            % attempt to get fieldnames of assumed sub-objects
            subFN = fieldnames(currEl);
            [dummy, idx] = setdiff(subFN, 'genBC');
            subFN = subFN(sort(idx));

        catch

            % failed -> no sub-objects
            subFN = [];

        end

        % nested sub-object?
        if ~isempty(subFN)

            % set flag to indicate a 'recursive call'
            if isempty(recursiveCall)

                % first recursive call
                recursiveCall = 1;

            else

                % nested recursive call
                recursiveCall = recursiveCall + 1;

            end

            % yes -> recursively fetch further paths
            subPaths = fetchClassPaths(currEl, desiredClass);

            % reset 'recursive call' flag
            recursiveCall = recursiveCall - 1;

            % reached top level yet?
            if recursiveCall == 0

                % completely out all recursive calls
                recursiveCall = [];

            end

            % append result to existing list of results
            if ~isempty(subPaths)

                % adjust path(s)
                if iscell(subPaths)

                    % more than one subpaths -> add'em one by one
                    for kk = 1:length(subPaths)

                        % adjust (and store) current path
                        res = appendResult(res, [currPath '.' char(subPaths{kk})]);

                    end  % for (all subPaths)

                else

                    % only one 'subPath' found
                    res = appendResult(res, [currPath '.' subPaths]);

                end  % subPaths is 'cell'

            end  % any subPaths

        end  % any sub levels

    end  % if ('currEl' is a cell array)

end  % for (all entries of this level)


%% recursive search through valid path for the requested class & property

function [res, resPath] = searchValidPath(this, currPath, desiredClass, ...
    property, patterns, regexpFlag, findOnceFlag, ...
    searchNestedObjectsFlag, checkReturnClass, inOrBelowTargetClass)

% flag to decide if this is a recursive call to this method
persistent recursiveCall;


% initialize results: nothing found yet
res = [];
resPath = {};

% search through these properties for the requested pattern
% 'cellify' patterns (if necessary)
if ~iscell(patterns)

    patterns = { patterns };

end

% find first path separator '.'
if isempty(recursiveCall)

    % top level -> find second path separator '.'
    firstSep = find(currPath == '.', 2);

    % eliminate 'this.'
    if ~isempty(firstSep)

        % eliminate 'this'
        currPath = currPath(firstSep(1)+1:end);

    end

    % adjust list of separators
    if length(firstSep) > 1
        
        % more than one separator -> eliminate first one
        firstSep = firstSep(2) - firstSep(1);
        
    else
        
        % single separator -> remove it
        firstSep = [];
        
    end

else

    % recursive calls -> find first path separator '.'
    firstSep = find(currPath == '.', 1);

end


% further sub-paths?
if ~isempty(firstSep)

    % yes -> initiate recursive search

    % current path name section
    currSect = currPath(1:firstSep-1);

    % remainder path
    remPath = currPath(firstSep+1:end);

    % 'this' could be an array of 'genBC' objects
    nThis = length(this);
    
    % loop over all top level array members
    for hh = 1:nThis

        % fetch object
        currObjArray = get(this(hh), currSect);

        % loop over all members of the current object 'array'
        for ii = 1:length(currObjArray)

            % fetch next entry of the array
            currObj = currObjArray(ii);

            % is this (the first time we find) the class we're looking for?
            if ~inOrBelowTargetClass && isa(currObj, desiredClass)

                % yes -> change state of 'inOrBelowTargetClass' to 'true'
                inOrBelowTargetClass = true;

                % allow further recursions from this level on? (default: yes)
                if searchNestedObjectsFlag

                    % yes, further searching of nested objects below this level
                    % is permitted, however, from here on we only need to look
                    % for a single matching pattern, as the return value is
                    % 'currObj' (this very level)
                    findOnceFlag = true;

                else

                    % no further searching of nested objects below this level
                    % -> prevent further (nested) recursions by setting the
                    % remainder path to the name of this level (= currSect)
                    remPath = currSect;

                end

            end


            % ******************************
            % *** continue the recursion ***
            % ******************************

            % set flag to indicate a(nother) 'recursive call'
            if isempty(recursiveCall)

                % first recursive call
                recursiveCall = 1;

            else

                % nested recursive call
                recursiveCall = recursiveCall + 1;

            end

            % recursive call...
            [recRes, recResPath] = ...
                searchValidPath(currObj, remPath, desiredClass, ...
                property, patterns, regexpFlag, findOnceFlag, ...
                searchNestedObjectsFlag, checkReturnClass, ...
                inOrBelowTargetClass);

            % reset 'recursive call' flag
            recursiveCall = recursiveCall - 1;

            % reached top level yet?
            if recursiveCall == 0

                % completely out all recursive calls
                recursiveCall = [];

            end

            % ******************************
            % ***    end of recursion    ***
            % ******************************

            % ensure the top level path name starts with 'this'
            if isempty(recursiveCall)

                % top level -> do we need an index?
                if nThis > 1
                    
                    % top level is object array -> index
                    currPath = ['this(' num2str(hh) ').' currSect];
                    
                else
                    
                    % top level is scalar object -> no index
                    currPath = ['this.' currSect];
                    
                end

            else
                
                % not at top level yet
                currPath = currSect;
                
            end

            % in or below the target class?
            if inOrBelowTargetClass

                % yes (=> we are in target class or below)
                % -> if any results have been
                % found we need to return the present object

                % append result (vertical vector)
                if ~isempty(recResPath)

                    % found a match -> return base object and path to base obj
                    res = [res(:); currObj];
                    resPath{end + 1, 1} = [currPath '(' num2str(ii) ')'];

                end

                % reset 'inOrBelowTargetClass' flag before considering the next
                % object of the current object array
                inOrBelowTargetClass = false;

            else

                % no (=> we are above the target level)
                % -> pass results of the above recursion to the calling level

                % adjust path (add this level)
                if iscell(recResPath)

                    % more than one entry -> expand individually
                    for kk = 1:length(recResPath)

                        % expand path by name and index of the current object
                        recResPath{kk} = [currPath '(' num2str(ii) ').' recResPath{kk}];

                    end

                else

                    % a single result
                    recResPath = [currPath '(' num2str(ii) ').' recResPath];

                end

                % append result (vertical vector)
                res = [res(:); recRes(:)];
                resPath = [resPath; recResPath];

            end

            % done?
            if findOnceFlag && ~isempty(resPath)

                % found one match -> return
                return

            end

        end  % for (all members of the object array at this level)

    end  % for (all members of object array 'this')

else

    % no further sub-paths -> end of recursion -> check for pattern
    if isa(this, 'struct')

        % struct -> check requested struct entry...
        eval(['allSearchObjects = this.' currPath ';']);

        % get cell array of the actual properties
        eval(['allEntries = allSearchObjects.' property ';']);

    else

        % regular classes -> get containing object
        if ~strcmp(currPath, 'this')

            % not looking for the top-level object 'this' itself
            
            % attempt to determine the fieldnames of the current object
            try
                
                % regular object or struct -> fieldnames available
                thisFN = fieldnames(this);
                
            catch
                
                % 'this' is a 'char', 'double', etc. -> no fieldnames
                thisFN = {};
                
            end
            
            % do we need to fetch the specified sub-object first?
            if ismember(currPath, thisFN)
                
                % yes -> fetch sub-object
                allSearchObjects = get(this, currPath);
                
            else
                
                % no -> end of recursion, we are at the level to be checked
                allSearchObjects = this;
                
            end


            % get cell array of the actual properties (if any)
            if ~isempty(property)
                
                % is 'allSearchObjects' a cell array of objects?
                if  iscell(allSearchObjects)       && ...
                   ~ischar(allSearchObjects{1})    && ...
                   ~isnumeric(allSearchObjects{1})

                    % cell array of things other than strings and numbers
                    try
                        % default: vertical concatination
                        allSearchObjects = vertcat(allSearchObjects{:});
                    catch
                        % fallback solution: horizontal concatination
                        allSearchObjects = [allSearchObjects{:}];
                    end

                end

                % property given -> get entries
                allEntries = get(allSearchObjects, property);
                
            else
                
                % no property specified -> looking for class
                if isa(allSearchObjects, desiredClass)
                    
                    % class match -> set result variables and return
                    res = allSearchObjects;
                    
                    % assemble list of return paths
                    nRes = length(res);
                    resPath = cell(nRes, 1);
                    
                    for kk = 1:nRes
                        
                        % assemble next path...
                        resPath{kk} = [currPath '(' num2str(kk) ')'];
                        
                    end
                    
                    % done
                    return
                    
                else
                    
                    % no class match -> done
                    return
                    
                end
                
            end  % if isempty(property)

        else

            % looking for object 'this' itself
            allSearchObjects = this;

            % get cell array of the actual properties (if any)
            if ~isempty(property)
                
                % is 'allSearchObjects' a cell array of objects?
                if  iscell(allSearchObjects)       && ...
                   ~ischar(allSearchObjects{1})    && ...
                   ~isnumeric(allSearchObjects{1})

                    % cell array of things other than strings and numbers
                    try
                        % default: vertical concatination
                        allSearchObjects = vertcat(allSearchObjects{:});
                    catch
                        % fallback solution: horizontal concatination
                        allSearchObjects = [allSearchObjects{:}];
                    end

                end
                
                % property given -> get entries
                allEntries = get(allSearchObjects, property);
                
            else
                
                % no property specified -> looking for class
                if isa(allSearchObjects, desiredClass)
                    
                    % class match -> set result variables and return
                    res = allSearchObjects;

                    % assemble list of return paths
                    nRes = length(res);
                    resPath = cell(nRes, 1);
                    
                    for kk = 1:nRes
                        
                        % assemble next path...
                        resPath{kk} = [currPath '(' num2str(kk) ')'];
                        
                    end
                    
                    % done
                    return
                    
                else
                    
                    % no class match -> done
                    return
                    
                end
                
            end  % if isempty(property)

        end  % currPath == 'this'?

    end  % class(this) == 'struct'?

    % ensure 'allEntries' is a cell array
    if ~iscell(allEntries)

        allEntries = { allEntries };

    end

    % loop over all patterns...
    for kk = 1:length(patterns)

        % fetch next pattern
        pattern = patterns{kk};

        % are we looking for 'empty' entries?
        if isempty(pattern)

            % yes -> find empty entries
            myIDX = strcmp(regexp(allEntries, '.+', 'match', 'once'), '');

        else

            % no -> find matching entries
            if regexpFlag

                % use regular expressions
                
                % regexp only works in cells of 'strings'...
                try

                    % assumption: they all are 'strings' (no empties)
                    myIDX = ~strcmp(regexp(allEntries, pattern, 'match', 'once'), '');

                catch

                    % fallback position: first eliminate 'empties'
                    myIDX = ~strcmp(regexp(vertcat(allEntries{:}), pattern, 'match', 'once'), '');

                end

            else

                % use exact match search (ignores regular expressions)

                % regexp only works in cells of 'strings'...
                try

                    % assumption: they all are 'strings' (no empties)
                    myIDX = ~strcmp(regexp(allEntries, ['^' pattern '$'], 'match', 'once'), '');

                catch

                    % fallback position: first eliminate 'empties'
                    myIDX = ~strcmp(regexp(vertcat(allEntries{:}), ['^' pattern '$'], 'match', 'once'), '');

                end


                % found anything?
                if any(myIDX)

                    % explicit search for match -> slows things down... :(
                    myIDX = false(size(allEntries));
                    for jj = 1:length(allEntries)

                        % set myIDX
                        myIDX(jj) = any(strcmp(allEntries{jj}, pattern));

                    end

                else

                    % nothing found -> turn myIDX into logic array
                    myIDX = false(length(myIDX), 1);

                end

            end

        end  % empty entries

        % update result (if any matching patterns have been found)
        if any(myIDX)

            % class derived from first cell array entry -> our class?
            if ~checkReturnClass || isa(class(allEntries{1}), desiredClass)

                % yes -> members of 'allEntries' are the desired objects

                % only looking for the first match?
                if findOnceFlag

                    % yes -> return first result and exit
                    res = allEntries(find(myIDX, 1));
                    resPath = currPath;

                    % -> done
                    return

                else

                    % fetch desired objects

                    % uniqueRes = unique(allEntries(myIDX));
                    filteredRes = allEntries(myIDX);
                    [dummyRes, I] = unique(filteredRes);
                    I = sort(I);

                    % preserve the original order of all result elements...
                    uniqueRes = filteredRes(I);
        
                    % append to previously found results (vertical vector)
                    res = [res(:); uniqueRes(:)];
                    
                    % path specifiers ('this(idx)')
                    allResultIDX = find(myIDX);
                    for ll = 1:length(allResultIDX)
                        
                        resPath = [resPath(:); [currPath '(' num2str(allResultIDX(ll)) ')']];
                        
                    end

                end

            else

                % 'allEntries' is/are embedded in the desired object

                % only looking for the first match? (should always be the
                % case if we end up here: every match has the same
                % parent/ancestor object!)
                if findOnceFlag

                    % yes -> return first result and exit
                    firstIDX = find(myIDX, 1);
                    
                    res = allSearchObjects(firstIDX);
                    resPath = [currPath '(' num2str(firstIDX) ')'];

                    % -> done
                    return

                else

                    % fetch including objects
                    resIDX = find(myIDX);
                    
                    % assemble paths
                    resPathTemp = {};
                    for ll = 1:length(resIDX)
                        
                        resPathTemp{end + 1, 1} = [currPath '(' num2str(resIDX(ll)) ')'];
                        
                    end  % ll
                    
                    % append to previously found results (vertical vector)
                    res     = vertcat(res, reshape(allSearchObjects(myIDX), length(allSearchObjects(myIDX)), 1));
                    resPath = vertcat(resPath, reshape(resPathTemp, length(resPathTemp), 1));

                end

            end

        end

    end  % all patterns

end  % if (subpaths)


%% appendResult
function res = appendResult(res, currPath)

% append 'currPath' to 'res'
if ~isempty(res)

    % 'res' already set -> append new result
    if iscell(res)

        % already a cell -> append
        res{end + 1} = currPath;

    else

        % not a cell yet
        res = { res; currPath };

    end

else

    % 'res' not yet set -> 'res' is the result
    res = currPath;

end


% (generic) method diff
%
% fw-03-09

function res = diff(this, that, varargin)

% flag to decide if this is a recursive call to this method
persistent recursiveCall;


% optional callup parameters?
if nargin > 2
    
    % yes -> first one could be 'once'
    if (ischar(varargin{1}) && strcmp(varargin{1}, 'once')) || ...
       (isnumeric(varargin{1}) && varargin{1} == 1)
        
        % find 'once'
        findOnce = 1;
        
    else
        
        % find all
        findOnce = 0;
        
    end
    
else
    
    % only 2 callup parameters -> 'findOnce = 0'
    findOnce = 0;
    
end


% compare object arrays
if eq(this, that)
    
    % objects are the same
    res = [];

else

    % objects are different -> determine differences
    res = [];
    
    % this'n'that can be arrays
    lThis = length(this);
    lThat = length(that);
    
    % assumption: array must be of the same length
    if lThis ~= lThat
        
        % cannot compare arrays of unequal length
        error('Cannot compare arrays of unequal length!')
        
    end


    % loop over all members of the array
    for ii = 1:lThis
        
        % fetch current array members to be compared
        currThis = this(ii);
        currThat = that(ii);
    
        % fetch all fieldnames, exclude dummy entry of base class ('genBC')
        thisFieldNames = fieldnames(currThis);
        [dummy, idx] = setdiff(thisFieldNames, 'genBC');
        thisFieldNames = thisFieldNames(sort(idx));
        nThisFieldNames = length(thisFieldNames);

        % check element by element
        for jj = 1:nThisFieldNames

            % store path
            if isempty(recursiveCall)
                
                % top level call -> starts with 'this'
                currPath = 'this';
                
            else
                
                % recursive call -> no (further) prefix 'this'
                currPath = '';
                
            end

            % scalar or array?
            if lThis == 1
                
                % scalar -> append fieldname
                currPath = [currPath '.' thisFieldNames{jj}];
                
            else
                
                % array -> append index then fieldname
                currPath = [currPath '(' num2str(ii) ').' thisFieldNames{jj}];
                
            end

            elThis = get(currThis, thisFieldNames{jj});
            elThat = get(currThat, thisFieldNames{jj});

            selThis = size(elThis);
            selThat = size(elThat);

            % size and content need to match
            switch class(elThis)

                case 'cell'

                    % cell arrays
                    % -> find all differences ('set' -> not ordered)
                    allDiffs = setxor(elThis, elThat);
                    if ~isempty(allDiffs) && all(selThis == selThat)

                        % same number of cells, but not all the same
                        % -> find first/all difference(s)
                        elDiffComb = false(selThis);
                        for kk = 1:length(allDiffs)

                            % candidates
                            elThisDiff = ~strcmp(regexp(elThis, allDiffs{kk}, 'match', 'once'), '');
                            elThatDiff = ~strcmp(regexp(elThat, allDiffs{kk}, 'match', 'once'), '');

                            % update logic array (indicies)
                            elDiffComb  = elDiffComb | elThisDiff | elThatDiff;

                        end

                        % determine indices of difference elements
                        diffIDX = find(elDiffComb);
                        
                        % need just the first difference?
                        if findOnce
                            
                            % yep -> restrict search to first differenc
                            diffIDX = min(diffIDX);
                            
                        end

                        % assemble result string
                        for kk = 1:length(diffIDX)

                            % current index
                            currIDX = diffIDX(kk);

                            % append new result to 'res'
                            res = appendResult(res, [currPath '{' num2str(currIDX) '}']);

                        end  % for

                    else

                        % number of cells not equal -> no match -> done
                        res = appendResult(res, currPath);
                        
                    end

                case 'struct'

                    % struct arrays -> need to check each struct entry

                    % fetch all struct fieldnames
                    structFieldNames = fieldnames(elThis);
                    nStructFieldNames = length(structFieldNames);

                    % check struct fieldname by struct fieldname
                    for kk = 1:nStructFieldNames
                        
                        % next struct entry
                        currFieldName = structFieldNames{kk};

                        % fetch all entries of the current struct fieldname
                        eval(['entriesThis = { elThis.' currFieldName '};']);
                        eval(['entriesThat = { elThat.' currFieldName '};']);
                        
                        % size of current struct entries cell
                        sentriesThis = size(entriesThis);
                        sentriesThat = size(entriesThat);
                        
                        if all(sentriesThis == sentriesThat)

                            % same number of cells -> check for differences
                            allDiffs = setxor(entriesThis, entriesThat);
                            if ~isempty(allDiffs)

                                % not all cells have the same content
                                % -> determine all differences
                                entriesDiffComb = false(sentriesThis);
                                for ll = 1:length(allDiffs)

                                    % candidates
                                    entriesThisDiff = ~strcmp(regexp(entriesThis, allDiffs{ll}, 'match', 'once'), '');
                                    entriesThatDiff = ~strcmp(regexp(entriesThat, allDiffs{ll}, 'match', 'once'), '');

                                    % update logic array (indicies)
                                    entriesDiffComb  = entriesDiffComb | entriesThisDiff | entriesThatDiff;

                                end  % (ll -> all Diffs)

                                % determine indices of difference elements
                                diffIDX = find(entriesDiffComb);

                                % need just the first difference?
                                if findOnce

                                    % yep -> restrict search to first differenc
                                    diffIDX = min(diffIDX);

                                end

                                % assemble result string
                                for ll = 1:length(diffIDX)

                                    % current index
                                    currIDX = diffIDX(ll);

                                    % append new result to 'res'
                                    res = appendResult(res, [currPath '.' currFieldName '{' num2str(currIDX) '}']);

                                end  % for (ll -> all diffIDX)
                                
                            end  % if (differences found)
                            
                        else

                            % not the same number of cells -> no match
                            res = appendResult(res, currPath);

                        end
                        
                        % finished?
                        if findOnce && ~isempty(res)
                            
                            % found a difference -> done
                            break
                            
                        end

                    end  % for (kk -> all struct fieldnames)

                otherwise

                    % all other data types (no cell)
                    if ~(all(size(elThis) == size(elThat)) && (isempty(elThis) || all(elThis == elThat)))

                        % no match -> determine difference

                        % 'genBC' object?
                        if isa(elThis, 'genBC')

                            % yep -> recursive call to this function
                            
                            % set flag to indicate a 'recursive call'
                            if isempty(recursiveCall)
                                
                                % first recursive call
                                recursiveCall = 1;
                                
                            else

                                % nested recursive call
                                recursiveCall = recursiveCall + 1;
                                
                            end
                            
                            % make recursive call to 'diff'
                            recDiff = diff(elThis, elThat, findOnce);
                            
                            % reset 'recursive call' flag
                            recursiveCall = recursiveCall - 1;
                            
                            % reached top level yet?
                            if recursiveCall == 0
                                
                                % completely out all recursive calls
                                recursiveCall = [];
                                
                            end
                            
                            % determine number of differences...
                            nRecDiff = length(recDiff);
                        
                            % 'res' already set?
                            if ~isempty(res)

                                % yep -> append new result(s)

                                % multiple results?
                                if iscell(recDiff)

                                    % need just the first difference?
                                    if findOnce

                                        % yep -> restrict search to first differenc
                                        nRecDiff = 1;

                                    end
                                    
                                    % yep -> assemble all return paths
                                    for kk = 1:nRecDiff

                                        % append current difference to the
                                        % list of previously found results
                                        currDiff = recDiff{kk};
                                        
                                        % need additional 'dot'?
                                        if currDiff(1) == '('

                                            % nope (array)
                                            res{end + 1} = [currPath currDiff];

                                        else

                                            % yes
                                            res{end + 1} = [currPath '.' currDiff];

                                        end
                                        
                                    end  % for

                                else

                                    % nope -> append simple difference to the
                                    % list of previously found results

                                    % need additional 'dot'?
                                    if recDiff(1) == '('

                                        % nope (array)
                                        currPath = [currPath recDiff];

                                    else

                                        % yes
                                        currPath = [currPath '.' recDiff];

                                    end

                                    % just looking for the very first difference?
                                    if findOnce

                                        % yep -> 'res' is a string
                                        res = currPath;

                                    else
                                        
                                        % find'em all... (cell array)
                                        res = appendResult(res, currPath);
                                        
                                    end

                                end

                            else

                                % 'res' not yet set -> store result(s) in 'res'

                                % multiple results?
                                if iscell(recDiff)

                                    % need just the first difference?
                                    if findOnce

                                        % yep -> restrict search to first differenc
                                        nRecDiff = 1;

                                    end
                                    
                                    % yep -> assemble all return paths
                                    res = cell(nRecDiff, 1);

                                    % assemble all return paths
                                    for kk = 1:nRecDiff

                                        % store path of kk-th difference
                                        currDiff = recDiff{kk};
                                        
                                        % need additional 'dot'?
                                        if currDiff(1) == '('

                                            % nope (array)
                                            res{kk} = [currPath currDiff];

                                        else

                                            % yes
                                            res{kk} = [currPath '.' currDiff];

                                        end
                                        
                                    end  % for

                                else

                                    % nope -> store simple difference in 'res'
                                    
                                    % need additional 'dot'?
                                    if recDiff(1) == '('
                                        
                                        % nope (array)
                                        res = [currPath recDiff];
                                        
                                    else
                                        
                                        % yes
                                        res = [currPath '.' recDiff];
                                        
                                    end

                                end

                            end

                        else

                            % this is the differing el -> return current Path
                            res = appendResult(res, currPath);

                        end

                    end  % no match

            end  % switch

            % need just the first difference?
            if findOnce && ~isempty(res)

                % yep -> we're done
                break;

            end

        end  % for (nThisFieldNames)

        % need just the first difference?
        if findOnce && ~isempty(res)

            % yep -> we're done
            break;

        end

    end  % for (all array members)
    
end  % this and that are not equal...






%% local functions


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



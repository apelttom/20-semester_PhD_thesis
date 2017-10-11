% (generic) method UNIQUE
%
% fw-08-09

function [that, uniqueIdxs] = unique(varargin)

% parse callup parameters
if nargin == 0
    
    % need at least one callup parameter
    error('genBC.unique: need at least one callup parameter.');
    
elseif nargin == 1
    
    % single input -> compare the entire object
    this = varargin{1};
    
    % check all properties -> 'empty' means everything here (see below)
    nUniqueProps = 0;
    
else
    
    % more than one input
    
    % first callup parameter is the object
    this = varargin{1};

    % extract list of properties to be checked
    uniqueProps = varargin{2:end};
    
    % unnamed properties?
    if isnumeric(uniqueProps)
        
        % yes -> fetch corresponding names
        objFieldNames = fieldnames(this);
        [dummy, idx] = setdiff(objFieldNames, 'genBC');
        thisFieldNames = objFieldNames(sort(idx));

        % fetch selected names
        uniqueProps = thisFieldNames(uniqueProps);
        
    end

    % ensure 'uniqueProps' is a cell
    if ~iscell(uniqueProps)

        % not yet -> cellify...
        uniqueProps = { uniqueProps };

    end

    % number of properties to be considered
    nUniqueProps = length(uniqueProps);
    
end

    
% uniquify object array -- safeguard against 'empty' objects
if ~isempty(this)
    
    % turn arbitrarily shaped arrays into a vertical vector
    nThis = numel(this);
    sThis = size(this);
    
    % already a vertical vector?
    if sThis(1) ~= nThis
        
        % nope -> need to reshape
        this = reshape(this, numel(this), 1);
        
    end
    
    % used to filter out a particular element
    myFiltEye = eye(nThis);
    
    % assumption: we are all individuals...
    uniqueIdxs = true(nThis, 1);
    
    for ii = 1:nThis-1
        
        % is the next index still in the race?
        if uniqueIdxs(ii)

            % check all properties or only a subset?
            if nUniqueProps == 0
                
                % check all properties
                
                % delete duplicates while keeping the current (myFiltEye) and
                % previously found (uniqueIdxs) uniques
                uniqueIdxs = uniqueIdxs & (myFiltEye(:, ii) | (this(ii) ~= this));
                
            else
                
                % only check a subset of the properties of the object
                for jj = 1:nUniqueProps
                    
                    % fetch next property
                    currProp = uniqueProps{jj};
                    
                    % fetch candidates to be compared
                    candA = get(this(ii), currProp);
                    candB = get(this, currProp);
                    
                    % candB == cell array of strings?
                    if ischar(candA)
                        
                        % yep -> use 'regexp' to determine members of candB
                        % which do not match candA (exact match!)
                        candAmatch = reshape(~strcmp(regexp(candB, ['^' candA '$'], 'match', 'once'), ''), length(candB), 1);

                        % match of the selectect properties of the two objects?
                        if any(candAmatch)

                            % some double entries found -> remove them from
                            % the status word of unique indices
                            uniqueIdxs = uniqueIdxs & (myFiltEye(:, ii) | ~candAmatch);

                        end
                        
                    else
                        
                        % not cell arrays of strings -> recursive call to
                        % unique
                        
                        % is candB a cell at all?
                        if iscell(candB)
                            
                            % yep -> de-cellify
                            candB = [ candB{:} ];
                            
                        end

                        % uniquify..
                        uniqueIdxs = uniqueIdxs & (myFiltEye(:, ii) | (candA ~= candB));
                        
                    end
                    
                end  % all selected properties
                
            end  % if/else (only check a subset)
            
        end  % if(uniqueIdx(ii))
        
    end  % for (all objects to be checked)

    % filter out unique objects
    that = this(uniqueIdxs);
    
else
    
    % empty input -> empty output
    that = [];
    
end

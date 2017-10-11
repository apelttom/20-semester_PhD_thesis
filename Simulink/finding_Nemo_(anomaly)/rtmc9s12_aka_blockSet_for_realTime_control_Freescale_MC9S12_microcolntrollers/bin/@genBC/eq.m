% (generic) method EQ(ual)
%
% fw-02-09

function res = eq(this, that)

nThis = length(this);
nThat = length(that);

% sanity checks...
if ~isa(this, class(that))
    
    error('%s\n%s', 'Error using ==> eq', 'Objects must be of the same kind.')
    
end


if (nThis > 1) && (nThat > 1)
    
    % both elements are 'vectors'
    if nThis ~= nThat

        error('%s\n%s', 'Error using ==> eq', 'Matrix dimensions must agree.')
        
    end
    
else
    
    % at least one of the two elements is 'scalar'
    if nThis < nThat
        
        % 'this' is scalar, 'that' isn't -> expand 'this' to vector
        currThis = this;
        this = eval([class(this) '(' num2str(nThat) ')']);
        for ii = 1:nThat
            this(ii) = currThis;
        end

        % vectors have the same length now...
        nThis = nThat;
        
    elseif nThat < nThis
        
        % 'that' is scalar, 'this' isn't -> expand 'that' to vector
        currThat = that;
        that = eval([class(that) '(' num2str(nThis) ')']);
        for ii = 1:nThis
            that(ii) = currThat;
        end
        
        % vectors have the same length now...
        % ... but 'nThat' is never used below this point
        
    end
    
end


% ---------------------------------------------------------------------
% at this stage, both 'this' and 'that' are equally sized object arrays
% ---------------------------------------------------------------------

% compare object arrays
res = false(nThis, 1);
for ii = 1:nThis
    
    % fetch the next pair of elements to be checked
    this_ii = this(ii);
    that_ii = that(ii);
    
    % compare object arrays (perform a quick check first: number of bytes)
    thisVar = whos('this_ii');
    thatVar = whos('that_ii');
    if thisVar.bytes == thatVar.bytes
        
        % matching number of bytes -> could be equal -> check
    
        % fetch all fieldnames, exclude dummy entry of base class ('genBC')
        thisFieldNames = setdiff(fieldnames(this_ii), 'genBC');
        nThisFieldNames = length(thisFieldNames);

        % compare object entries (one by one)
        matchState = true;
        for jj = 1:nThisFieldNames

            elThis = get(this_ii, thisFieldNames{jj});
            elThat = get(that_ii, thisFieldNames{jj});

            % size and content need to match
            switch class(elThis)

                case 'cell'

                    % cell arrays -> number of cells needs to match first
                    if all(size(elThis) == size(elThat)) && ~isempty(elThis)

                        % check cell by cell
                        for kk = 1:length(elThis)

                            % candidates
                            currThis = elThis{kk};
                            currThat = elThat{kk};

                            % check (use 'any' here to allow for 'strings')
                            if (length(currThis) ~= length(currThat)) || any(currThis ~= currThat)

                                % no match -> done with this element
                                matchState = false;
                                break;

                            end

                        end  % for (all cells)

                    else

                        % number of cells not equal -> no match -> done
                        matchState = false;
                        break;

                    end

                case 'struct'

                    % struct array -> number of struct array entries needs
                    % to match first
                    if all(size(elThis) == size(elThat)) && ~isempty(elThis)

                        % check entry by entry
                        for kk = 1:length(elThis)

                            % candidates
                            currThis = elThis(kk);
                            currThat = elThat(kk);
                            
                            % field names
                            currThisFieldNames = fieldnames(currThis);
                            currThatFieldNames = fieldnames(currThat);

                            % values
                            currThisValues = struct2cell(currThis);
                            currThatValues = struct2cell(currThat);
                            
                            % check struct entry by struct entry
                            for kk = 1:length(currThisFieldNames)
                                
                                % check (use 'any' here to allow for 'strings')
                                if ~strcmp(currThisFieldNames{kk}, currThatFieldNames{kk}) || ...
                                   ~strcmp(currThisValues{kk}, currThatValues{kk})

                                    % no match -> done with this element
                                    matchState = false;
                                    break;

                                end

                            end

                            % do we need to continue with the struct array?
                            if ~matchState
                                
                                % nope
                                break;
                                
                            end

                        end  % for (all cells)

                    else

                        % number of cells not equal -> no match -> done
                        matchState = false;
                        break;

                    end

                otherwise

                    % all other data types
                    if ~(all(size(elThis) == size(elThat)) && (isempty(elThis) || all(elThis == elThat)))

                        % no match -> done with this element
                        matchState = false;
                        break;

                    end

            end  % switch

        end  % for nThisFieldNames
        
    else
        
        % unequal number of bytes of 'this(ii)' and 'that(ii)' -> no match
        matchState = false;
        
    end  % if (matching number of bytes)
    
    % store result
    res(ii) = matchState;
    
end  % for all objects

% generic function to assign one or more value(s) to the dot-selected 
% elements of the object(s)
%
% fw-12-08

function this = dotAccessAssign(this, item, val)

% scalar or vector access?
if isscalar(this)

    % scalar dot access -> set the selected element

    if any(ismember(setdiff(fieldnames(this), 'genBC'), item))

        % valid item -> assign current value
        this.(item) = val;

    else

        % invalid item
        error([item ' is not a member of class ' class(this) '.']);

    end

else

    % vector access -> val should be a cell array with as many elements as
    % there are elements in 'this'.

    if any(ismember(setdiff(fieldnames(this), 'genBC'), item))

        % Assumption: 'this' and 'val' are 1D vectors of the same length!
        ls = length(this);
        lv = length(val);
        if any(size(this) == 1) && ls == lv

            % valid assignment
            for ii = 1:lv

                % assign 'ii-th' value
                this(ii).(item) = val{ii};

            end

        else

            % 'this' is an array or mismatch between length(this) and length(val)
            error(['Class ' class(this) ' only supports scalar or vector assignments.'])

        end

    else

        % invalid item
        error([item ' is not a member of class ' class(this) '.']);

    end

end  % scalar / vector

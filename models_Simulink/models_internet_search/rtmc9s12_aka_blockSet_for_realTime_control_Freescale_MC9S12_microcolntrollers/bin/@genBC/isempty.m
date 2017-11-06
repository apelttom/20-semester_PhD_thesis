% (generic) method ISEMPTY
%
% fw-01-09

function bRes = isempty(this)

% zero length input object -> 'empty' per definition
if length(this) == 0 %#ok<ISMT>
    
    % empty
    bRes = 1;
    
else

    % not zero length -> create empty object
    newThis = eval(class(this));

    if this == newThis

        % none of the attributes has been set
        bRes = 1;

    else

        bRes = 0;

    end
    
end

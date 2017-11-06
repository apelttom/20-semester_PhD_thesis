% (generic) function returning the dot-selected element(s) of the selected 
% object(s)
%
% fw-12-08

function val = dotAccess(this, item)

% scalar or vector access?
if isscalar(this)

    % scalar access -> return member directly
    
    if any(ismember(setdiff(fieldnames(this), 'genBC'), item))
        
        % valid item -> return current value
        val = this.(item);
        
    else
        
        % invalid item
        error([item ' is not a member of class ' class(this) '.']);
        
    end
        
else

    % vector access -> return cell array (column vector)

    if any(ismember(setdiff(fieldnames(this), 'genBC'), item))
        
        % valid item -> return current value
        val = { this(:).(item) };

    else

        % invalid item
        error([item ' is not a member of class ' class(this) '.']);
        
    end

end  % scalar / vector

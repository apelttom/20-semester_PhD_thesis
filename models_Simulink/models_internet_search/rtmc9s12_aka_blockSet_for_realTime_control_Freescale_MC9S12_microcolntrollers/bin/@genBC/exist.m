% (generic) method EXIST
%
% fw-01-09

function bRes = exist(this, varargin)


if nargin == 1
    
    % no second parameter given -> use 'var' as default
    exType = 'var';
    
elseif nargin == 2
    
    % second parameter provided
    exType = varargin{1};
    
    % currently there is only one valid check type ('var')
    if ~strcmp(exType, 'var')
        
        % unsupported type -> error
        error(['Existence type ''' exType ''' not supported for method ''exist'' of class ' class(this) '.'])
        
    end
    
end


% default assumption: variable does not exist
bRes = false;

switch exType
    
    case 'var'
        
        % the fact that we are in this file already proves that the
        % variable exists -> return 'true' (always)
        bRes = true;
        
end  % switch


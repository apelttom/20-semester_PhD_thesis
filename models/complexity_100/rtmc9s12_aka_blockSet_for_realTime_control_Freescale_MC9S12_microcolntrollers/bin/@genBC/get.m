% (generic) method GET
%
% fw-06-08

function val = get(this, varargin)

if nargin == 1
    
    % get(obj) -> return the entire object
    val = this;
    
else
    
    % get a specific property
    val = dotAccess(this, varargin{1});

end

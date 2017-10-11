% (generic) class constructor for: mcLibraryMarker
%
% fw-01-09

function obj = mcLibraryMarker(varargin)

% define class struct
objName   = mfilename;
objStruct = defineClassStruct;


% construct class (generic)
switch nargin

    case 0

        % register class and inherit generic methods of the generic base
        % class 'genBC'
        obj = class(objStruct, objName, genBC);
        
    case 1

        % copy class
        if isa(varargin{1}, objName)

            % copy input (assignments, eg. "b = a")
            obj = varargin{1};

        elseif isa(varargin{1}, 'double')

            if ~isempty(varargin{1})
                
                % create a column vector of objects of this class
                nRows = varargin{1};
                obj = cell(nRows, 1);
                for row = 1:nRows
                    obj{row} = class(objStruct, objName, genBC);
                end
                
                % turn cell to array
                obj = [ obj{:} ];
                
            else
                
                % varargin{1} = [] -> instantiate an 'empty' object
                kk = class(objStruct, objName, genBC);
                
                % array
                obj = [kk; kk];
                
                % empty array
                obj(end) = [];
                obj(end) = [];
                
            end

        else

            error(['Class constructor ' objName ': Scalar call-up parameter is neither a ' objName ' object nor a double.'])

        end

    otherwise

        if nargin == 2 && isa(varargin{1}, 'double') && isa(varargin{2}, 'double')

            % 2D-array -> create an array of objects of this class
            nRows = varargin{1};
            nCols = varargin{2};
            obj = cell(nRows, nCols);
            
            for row = 1:nRows
                
                for col = 1:nCols
                    
                    % create a new instance of this class
                    obj{row, col} = class(objStruct, objName, genBC);
                    
                end  % col
                
            end  % row

            % turn cell to array
            obj = reshape([ obj{:} ], nRows, nCols);
            
        elseif mod(nargin, 2) == 0

            % list of pairs of strings given -> populate object
            for parIDX = 1:2:nargin

                % check element type and assign it, if possible
                objStruct = setfield(objStruct, varargin{parIDX}, varargin{parIDX + 1}); %#ok<SFLD>

            end

            % create class and instantiate object
            obj = class(objStruct, objName, genBC);

        else

            % uneven number of callup parameters -> need to be pairs!
            error(['Class constructor ' objName ': Class members have to be specified in pairs!'])

        end  % correct number of parameters

end  % switch

function visualizationBlock(block)
% This block realizes all video output blocks of the Lemming Toolbox.
% Depending on its parametrization he will choose the one or the other
% function which visualizes the Lemming.


% Copyright 2010 Moritz Lang
% This file is part of the E. lemming Matlab / Simulink Toolbox and was
% developed for the iGEM 2010 project of ETH Zurich. For further information, please
% visit http://2010.igem.org/Team:ETHZ_Basel
% 
% The Lemming Toolbox is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% The Lemming Toolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with the Lemming Toolbox.  If not, see
% <http://www.gnu.org/licenses/>.
setup(block);
  
%endfunction
%%
function setup(block)
  mode =  block.DialogPrm(4).Data;

  % Sample Time
  block.SampleTimes = block.DialogPrm(5).Data;
  
  % Register number of ports
  if mode == 1 || mode == 3
    block.NumInputPorts  = 7;
  else
      block.NumInputPorts  = 8;
  end
  block.NumOutputPorts = 3; % (R, G, B)
  
  
  xSize = block.DialogPrm(6).Data;
  ySize = block.DialogPrm(7).Data;
  binning = block.DialogPrm(8).Data;
  maxNumCells = block.DialogPrm(9).Data;
  
  % Override output port properties
  % Red
  block.OutputPort(1).DatatypeID   = 3; % uint8
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  block.OutputPort(1).Dimensions = [ySize,xSize] / binning;
  
  % Green
  block.OutputPort(2).DatatypeID   = 3; % uint8
  block.OutputPort(2).Complexity   = 'Real';
  block.OutputPort(2).SamplingMode = 'Sample';
  block.OutputPort(2).Dimensions = [ySize,xSize] / binning;
  
  % Blue
  block.OutputPort(3).DatatypeID   = 3; % uint8
  block.OutputPort(3).Complexity   = 'Real';
  block.OutputPort(3).SamplingMode = 'Sample';
  block.OutputPort(3).Dimensions = [ySize,xSize] / binning;
  
  % Override input port properties
  % Cell_ID
  block.InputPort(1).DatatypeID  = 7; % uint32
  block.InputPort(1).Complexity  = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions = 1;
  block.InputPort(1).DirectFeedthrough = true;
  
  % Image
  block.InputPort(2).DatatypeID   = 3; % uint8
  block.InputPort(2).Complexity   = 'Real';
  block.InputPort(2).DirectFeedthrough = true;
  block.InputPort(2).Dimensions = [ySize,xSize] / binning;
  block.InputPort(2).SamplingMode = 'Sample';
  
  % phi_is
  block.InputPort(3).DatatypeID  = 0; % double
  block.InputPort(3).Complexity  = 'Real';
  block.InputPort(3).DirectFeedthrough = true;
  block.InputPort(3).Dimensions = 1;
  block.InputPort(3).SamplingMode = 'Sample';
  
  % phi_sh
  block.InputPort(4).DatatypeID  = 0; % double
  block.InputPort(4).Complexity  = 'Real';
  block.InputPort(4).DirectFeedthrough = true;
  block.InputPort(4).Dimensions = 1;
  block.InputPort(4).SamplingMode = 'Sample';
  
  % positions of other cells
  block.InputPort(5).DatatypeID  = 0; % double
  block.InputPort(5).Complexity  = 'Real';
  block.InputPort(5).DirectFeedthrough = true;
  block.InputPort(5).Dimensions = [maxNumCells, 2];
  block.InputPort(5).SamplingMode = 'Sample';
  
  % visualization options
  block.InputPort(6).DatatypeID  = 8; % boolean
  block.InputPort(6).Complexity  = 'Real';
  block.InputPort(6).DirectFeedthrough = true;
  block.InputPort(6).Dimensions = 2;
  block.InputPort(6).SamplingMode = 'Sample';
  
  % Table Position
  block.InputPort(7).DatatypeID  = 0; % double
  block.InputPort(7).Complexity  = 'Real';
  block.InputPort(7).DirectFeedthrough = true;
  block.InputPort(7).Dimensions = 2;
  block.InputPort(7).SamplingMode = 'Sample';
  
  if mode == 2
      % Additional keys for gaming
      block.InputPort(8).DatatypeID  = 3; % uint8
      block.InputPort(8).Complexity  = 'Real';
      block.InputPort(8).DirectFeedthrough = true;
      block.InputPort(8).Dimensions = 1;
      block.InputPort(8).SamplingMode = 'Sample';
  end

  % Register parameters
  block.NumDialogPrms     = 9;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable'};

  % Register Callbacks
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Start', @Start);
  block.RegBlockMethod('Outputs', @Outputs);

%endfunction


function DoPostPropSetup(block)

  % Register variables
  numPathElements = block.DialogPrm(1).Data;
    
  block.NumDworks = 9;
  block.Dwork(1).Name = 'xPath'; 
  block.Dwork(1).Dimensions      = numPathElements;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  
  block.Dwork(2).Name = 'yPath'; 
  block.Dwork(2).Dimensions      = numPathElements;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  
  block.Dwork(3).Name = 'currentElement'; 
  block.Dwork(3).Dimensions      = 1;
  block.Dwork(3).DatatypeID      = 0;
  block.Dwork(3).Complexity      = 'Real';
  
  block.Dwork(4).Name = 'allFilled'; 
  block.Dwork(4).Dimensions      = 1;
  block.Dwork(4).DatatypeID      = 0;
  block.Dwork(4).Complexity      = 'Real';
  
  coneWidth = block.DialogPrm(2).Data;
  deltaPhi = block.DialogPrm(3).Data;
  coneHeight = 2 * ceil(coneWidth * tan(deltaPhi / 2)) + 1;
  block.Dwork(5).Name = 'lightImage'; 
  block.Dwork(5).Dimensions      = coneWidth * coneHeight;
  block.Dwork(5).DatatypeID      = 0;
  block.Dwork(5).Complexity      = 'Real';
  
  block.Dwork(6).Name = 'glowing'; 
  block.Dwork(6).Dimensions      = 31^2;
  block.Dwork(6).DatatypeID      = 0;
  block.Dwork(6).Complexity      = 'Real';
  
  block.Dwork(7).Name = 'startTime'; 
  block.Dwork(7).Dimensions      = 1;
  block.Dwork(7).DatatypeID      = 0;
  block.Dwork(7).Complexity      = 'Real';
  
  block.Dwork(8).Name = 'lastCellID'; 
  block.Dwork(8).Dimensions      = 1;
  block.Dwork(8).DatatypeID      = 7; % uint32
  block.Dwork(8).Complexity      = 'Real';
  
  block.Dwork(9).Name = 'lastTablePos'; 
  block.Dwork(9).Dimensions      = 2;
  block.Dwork(9).DatatypeID      = 0; % double
  block.Dwork(9).Complexity      = 'Real';
  

%endfunction

function Start(block)
%% Delete previous paths.
    numPathElements = block.DialogPrm(1).Data;
    block.Dwork(1).Data = NaN * ones(numPathElements, 1);
    block.Dwork(2).Data = NaN * ones(numPathElements, 1);
    block.Dwork(3).Data = 0;
    block.Dwork(4).Data = 0;
    
    block.Dwork(7).Data = cputime;
    block.Dwork(8).Data = uint32(NaN);
    block.Dwork(9).Data = [NaN, NaN];
  
%% Initialize light image
    coneWidth = block.DialogPrm(2).Data;
    deltaPhi = block.DialogPrm(3).Data;
    coneHeight = 2 * ceil(coneWidth * tan(deltaPhi / 2)) + 1;
    xpos = 1;
    ypos = (coneHeight + 1) / 2;
    phi_is = 0;
    
    X = repmat((1:coneWidth), coneHeight, 1);
    Y = repmat((1:coneHeight)', 1, coneWidth);

    dist = 1 - ((X-xpos).^2 + (Y-ypos).^2) / coneWidth ^2;

    indices = dist > 0 ...
        & (Y-ypos) * cos(phi_is - deltaPhi/2) > (X-xpos) * sin(phi_is - deltaPhi/2) ...
        & (Y-ypos) * cos(phi_is + deltaPhi/2) < (X-xpos) * sin(phi_is + deltaPhi/2); 
            
    lightImage = zeros(coneHeight, coneWidth);
    lightImage(indices) = (dist(indices));
    block.Dwork(5).Data = lightImage(:);
    
%% Initialize glowing image
    glowWidth = sqrt(length(block.Dwork(6).Data));
    half = (glowWidth-1)/2;
    glowImage = 1 - (sqrt(repmat((-half:half).^2, glowWidth, 1) + repmat((-half:half)'.^2, 1, glowWidth))) / half;
    glowImage(glowImage<0) = 0;
    block.Dwork(6).Data = glowImage(:);

%% Delete all persistent variables
    eLemming2DOutput([], [], [], [], [],[], [], [], [], [], [], [], []);

%endfunction

function Outputs(block)

%% Get variables.
    cellID = block.InputPort(1).Data;
    lastCellID = block.Dwork(8).Data;
    block.Dwork(8).Data = cellID;
    image = block.InputPort(2).Data;
    [imageHeight, imageWidth] = size(image);
    xposAllCells = round(block.InputPort(5).Data(:, 1) * imageWidth);
    yposAllCells = round(block.InputPort(5).Data(:, 2) * imageHeight);
    tablePosition = round([block.InputPort(7).Data(1) * imageWidth, block.InputPort(7).Data(2) * imageHeight]);
    % Minus due to change of cooardinate system: In our calculations the
    % pixel (1,1) is in the lower left corner. However, most image display
    % methods use a coordinate system with the pixel (1,1) in the upper
    % left corner. Clock wise and counter clock wise directions thus
    % change. Since in the following we need mostly image functions, we
    % change the coordinate system here...
    phi_is = -block.InputPort(3).Data;
    phi_sh = -block.InputPort(4).Data;
    arrowLength = block.DialogPrm(2).Data;
    mode =  block.DialogPrm(4).Data;
    startTime = block.Dwork(7).Data;
    visualization = block.InputPort(6).Data;
    
%% Add current x/y position to list of positions and get path
    currentPathElement = block.Dwork(3).Data;
    isPathFilled = block.Dwork(4).Data;
    if cellID ~= lastCellID
        % We have a different cell. Delete the path.
        currentPathElement = 0;
        isPathFilled = 0;        
    end
    if ~isnan(cellID) && cellID >=1
        xpos = xposAllCells(cellID);
        ypos = yposAllCells(cellID);
        currentPathElement = currentPathElement + 1;
        numPathElements = block.DialogPrm(1).Data;

        if currentPathElement > numPathElements
            % Path is full. Put new values at the beginning
            currentPathElement = 1;
            isPathFilled = 1;
        end

        block.Dwork(1).Data(currentPathElement) = xpos;
        block.Dwork(2).Data(currentPathElement) = ypos;
        block.Dwork(3).Data = currentPathElement;
        block.Dwork(4).Data = isPathFilled;
    end
    if isPathFilled
        xPath = block.Dwork(1).Data;
        yPath = block.Dwork(2).Data;
    else
        xPath = block.Dwork(1).Data(1:currentPathElement);
        yPath = block.Dwork(2).Data(1:currentPathElement);
    end
    
%% Get light cone
    % Get parameters
    coneWidth = block.DialogPrm(2).Data;
    deltaPhi = block.DialogPrm(3).Data;
    coneHeight = 2 * ceil(coneWidth * tan(deltaPhi / 2)) + 1;

    % Rotate image of light cube
    coneImage = reshape(block.Dwork(5).Data, coneHeight, coneWidth);
       
%% Glow image
    glowWidth = sqrt(length(block.Dwork(6).Data));
    glowImage = reshape(block.Dwork(6).Data, glowWidth, glowWidth);
    
%% Change positions according to the current table position (relative
%% coordinate system).
    xPath = xPath - tablePosition(1);
    yPath = yPath - tablePosition(2);
    xposAllCells = xposAllCells - tablePosition(1);
    yposAllCells = yposAllCells - tablePosition(2);
    
%% Detect microscope movements
    if ~any(isnan(block.Dwork(9).Data(1))) && (block.Dwork(9).Data(1) ~= tablePosition(1) || block.Dwork(9).Data(2) ~= tablePosition(2))
        % microscope moved -> Determine direction
        microscopeDirection = -atan2(tablePosition(2) - block.Dwork(9).Data(2), tablePosition(1) - block.Dwork(9).Data(1));
        deltaTable = [tablePosition(2) - block.Dwork(9).Data(2), tablePosition(1) - block.Dwork(9).Data(1)];
    else
        % microscope did not move
        microscopeDirection = NaN;
        deltaTable = [0,0];
    end
    block.Dwork(9).Data = tablePosition;
    
%% Return image
    if mode == 1
        [block.OutputPort(1).Data, block.OutputPort(2).Data, block.OutputPort(3).Data] = scientificOutput(image, cellID, phi_is, phi_sh, xPath, yPath, coneImage, arrowLength, xposAllCells, yposAllCells, glowImage, startTime, visualization, microscopeDirection);
    elseif mode == 2
        [block.OutputPort(1).Data, block.OutputPort(2).Data, block.OutputPort(3).Data] = eLemming2DOutput(image, cellID, phi_is, phi_sh, xPath, yPath, coneImage, arrowLength, xposAllCells, yposAllCells, glowImage, startTime, visualization, microscopeDirection, block.InputPort(8).Data, deltaTable);
    elseif mode == 3
        [block.OutputPort(1).Data, block.OutputPort(2).Data, block.OutputPort(3).Data] = archeanPhotoreceptorOutput(image, cellID, phi_is, phi_sh, xPath, yPath, coneImage, arrowLength, xposAllCells, yposAllCells, glowImage, startTime, visualization, microscopeDirection);
    end

%endfunction
    

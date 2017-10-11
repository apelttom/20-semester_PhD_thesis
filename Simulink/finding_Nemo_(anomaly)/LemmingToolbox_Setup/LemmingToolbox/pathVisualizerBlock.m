function pathVisualizerBlock(block)
% This file realizes the visualization block of the Lemming Toolbox.

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
  % Sample Time
  block.SampleTimes = block.DialogPrm(1).Data;
  
  % Register number of ports
  block.NumInputPorts  = 2;
  block.NumOutputPorts = 3; % (R, G, B)
  
  xSize = block.DialogPrm(2).Data;
  ySize = block.DialogPrm(3).Data;
  maxNumCells = block.DialogPrm(4).Data;
  
  % Override output port properties
  % Red
  block.OutputPort(1).DatatypeID   = 3; % uint8
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  block.OutputPort(1).Dimensions = [ySize, xSize];
  
  % Green
  block.OutputPort(2).DatatypeID   = 3; % uint8
  block.OutputPort(2).Complexity   = 'Real';
  block.OutputPort(2).SamplingMode = 'Sample';
  block.OutputPort(2).Dimensions = [ySize, xSize];
  
  % Blue
  block.OutputPort(3).DatatypeID   = 3; % uint8
  block.OutputPort(3).Complexity   = 'Real';
  block.OutputPort(3).SamplingMode = 'Sample';
  block.OutputPort(3).Dimensions = [ySize, xSize];
  
  % Override input port properties
  % Cell_ID
  block.InputPort(1).DatatypeID  = 7; % uint32
  block.InputPort(1).Complexity  = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions = 1;
  block.InputPort(1).DirectFeedthrough = true;
  
  % positions of all cells
  block.InputPort(2).DatatypeID  = 0; % double
  block.InputPort(2).Complexity  = 'Real';
  block.InputPort(2).DirectFeedthrough = true;
  block.InputPort(2).Dimensions = [maxNumCells, 2];
  block.InputPort(2).SamplingMode = 'Sample';
  
  % Register parameters
  block.NumDialogPrms     = 7;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable'};

  % Register Callbacks
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Start', @Start);
  block.RegBlockMethod('Outputs', @Outputs);

%endfunction


function DoPostPropSetup(block)

  % Register variables
  xSize = block.DialogPrm(2).Data;
  ySize = block.DialogPrm(3).Data;
    
  block.NumDworks = 3;
  block.Dwork(1).Name = 'red'; 
  block.Dwork(1).Dimensions      = ySize * xSize;
  block.Dwork(1).DatatypeID      = 3; % uint8
  block.Dwork(1).Complexity      = 'Real';
  
  block.Dwork(2).Name = 'green'; 
  block.Dwork(2).Dimensions      = ySize * xSize;
  block.Dwork(2).DatatypeID      = 3; % uint8
  block.Dwork(2).Complexity      = 'Real';
  
  block.Dwork(3).Name = 'blue'; 
  block.Dwork(3).Dimensions      = ySize * xSize;
  block.Dwork(3).DatatypeID      = 3; % uint8
  block.Dwork(3).Complexity      = 'Real';
  
%endfunction

function Start(block)    
    % Setup empty white frame with black border
    xSize = block.DialogPrm(2).Data;
    ySize = block.DialogPrm(3).Data;
    frameDim = block.DialogPrm(5).Data;
    redImage = uint8(zeros(ySize, xSize));
    redImage(1:ySize, 1) =  intmax('uint8') / uint8(2);
    redImage(1:ySize, xSize) = intmax('uint8') / uint8(2);
    redImage(1, 1:xSize) = intmax('uint8') / uint8(2);
    redImage(ySize, 1:xSize) = intmax('uint8') / uint8(2);
    greenImage = redImage;
    blueImage = redImage;
    % Draw reference path
    refPathX = block.DialogPrm(6).Data;
    refPathY = block.DialogPrm(7).Data;
    if length(refPathX) ~= length(refPathY)
        error('ETHZ:PathDefineError', 'x and y vectors of the reference path have to have the same lengths!');
    end
    for i=2:length(refPathX)
        startP = [refPathX(i-1), refPathY(i-1)];
        endP = [refPathX(i), refPathY(i)];
        if startP(1) < frameDim(1) || startP(2) < frameDim(2) || startP(1) > frameDim(3) || startP(2) > frameDim(4) ...
                || endP(1) < frameDim(1) || endP(2) < frameDim(2) || endP(1) > frameDim(3) || endP(2) > frameDim(4)
            continue;
        end
        % Translate to pixels
        startP = round((startP - [frameDim(1), frameDim(2)]) ./ ([frameDim(3), frameDim(4)] - [frameDim(1), frameDim(2)]) .* [xSize-2, ySize-2]) + 1;
        endP = round((endP - [frameDim(1), frameDim(2)]) ./ ([frameDim(3), frameDim(4)] - [frameDim(1), frameDim(2)]) .* [xSize-2, ySize-2]) + 1;
        % Draw a blue line
        pixelDist = max(abs(startP - endP)) +1;
        connectionLine = round(repmat(startP', 1, pixelDist * 2 + 1) + (endP - startP)' * (0:1/pixelDist/2:1));
        redImage(sub2ind(size(blueImage), connectionLine(2, :), connectionLine(1, :))) = 0;
        greenImage(sub2ind(size(blueImage), connectionLine(2, :), connectionLine(1, :))) = 0;
        blueImage(sub2ind(size(blueImage), connectionLine(2, :), connectionLine(1, :))) = 200;
    end
    
    block.Dwork(1).Data = redImage(:);
    block.Dwork(2).Data = greenImage(:);
    block.Dwork(3).Data = blueImage(:);
%endfunction

function Outputs(block)
    xSize = block.DialogPrm(2).Data;
    ySize = block.DialogPrm(3).Data;
    frameDim = block.DialogPrm(5).Data;
%% Get variables.
    cellID = block.InputPort(1).Data;
    xposAllCells = block.InputPort(2).Data(:, 1);
    yposAllCells = block.InputPort(2).Data(:, 2);
    if ~isnan(cellID) && cellID >=1
        xpos = xposAllCells(cellID);
        ypos = yposAllCells(cellID);
        if xpos >= frameDim(1) && ypos >= frameDim(2) && xpos <= frameDim(3) && ypos <= frameDim(4)
            xpos = round((xpos - frameDim(1)) / (frameDim(3) - frameDim(1)) * (xSize-2)) + 1;
            ypos = round((ypos - frameDim(2)) / (frameDim(4) - frameDim(2)) * (ySize-2)) + 1;
            block.Dwork(1).Data(sub2ind([ySize, xSize], ypos, xpos)) = intmax('uint8') / uint8(2);
            block.Dwork(2).Data(sub2ind([ySize, xSize], ypos, xpos)) = intmax('uint8') / uint8(2);
            block.Dwork(3).Data(sub2ind([ySize, xSize], ypos, xpos)) = intmax('uint8') / uint8(2);
        end
    end
    block.OutputPort(1).Data = reshape(block.Dwork(1).Data, ySize, xSize);
    block.OutputPort(2).Data = reshape(block.Dwork(2).Data, ySize, xSize);
    block.OutputPort(3).Data = reshape(block.Dwork(3).Data, ySize, xSize);
%endfunction
    

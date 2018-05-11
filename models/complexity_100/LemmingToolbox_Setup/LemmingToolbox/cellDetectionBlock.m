function cellDetectionBlock(block)
% This file is for the configuration of the cell detection block in the
% Lemming Toolbox.

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

function setup(block)
    % Maximal number of detectable cells
    maxNumCells = block.DialogPrm(5).Data;
    % Binning in microscope
    binning = block.DialogPrm(7).Data;
    % Sample time
    block.SampleTimes = block.DialogPrm(8).Data;
  % Register number of ports
  block.NumInputPorts  = 2;
  block.NumOutputPorts = 1;
  
  % Input = Image
  block.InputPort(1).DatatypeID   = 3; % uint8
  block.InputPort(1).Complexity   = 'Real';
  block.InputPort(1).DirectFeedthrough = true;
  block.InputPort(1).SamplingMode = 'Sample';
  xSize = block.DialogPrm(1).Data;
  ySize = block.DialogPrm(2).Data;
  block.InputPort(1).Dimensions = [ySize,xSize] / binning;

  % Input = threshold
  block.InputPort(2).DatatypeID   = 0; 
  block.InputPort(2).Complexity   = 'Real';
  block.InputPort(2).SamplingMode = 'Sample';
  block.InputPort(2).Dimensions = 1;
  block.InputPort(2).DirectFeedthrough = true;
  
  % Output = X & Y positions
  block.OutputPort(1).DatatypeID  = 0; % double
  block.OutputPort(1).Complexity  = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  block.OutputPort(1).Dimensions = [maxNumCells,2];
  
  % Register parameters
  block.NumDialogPrms     = 8;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable'};
  
  % Register Callbacks
  block.RegBlockMethod('Outputs', @Outputs);
  block.RegBlockMethod('Update', @Update);
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Start', @Start);
  
%endfunction

function DoPostPropSetup(block)

  % Register variables
  block.NumDworks = 1;
  
  % Used to store the threshold
  block.Dwork(1).Name = 'threshold'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  
%endfunction
  
function Update(block)
  % Set threshold.
  block.Dwork(1).Data = block.InputPort(2).Data;
  
%endfunction

function Start(block)
    % Initialize threshold.
    block.Dwork(1).Data = 0.2;
  
%endfunction


function Outputs(block)
    %% Configuration
    % Limits for valid cell sizes. All smaller and larger detected objects are
    % sorted out.
    % Lower limit of cell area (in square pixels).
    cellSizeLowerLimit = block.DialogPrm(3).Data; 
    % Upper limit of cell area (in square pixels).
    cellSizeUpperLimit = block.DialogPrm(4).Data;

    % Resize the width and the height of the image by this factor. A lower
    % value will increase speed, but possibly lowers quality of detection.
    resizeScale = block.DialogPrm(6).Data;
    
    %% Binning in the microscope
    binning = block.DialogPrm(7).Data;
    cellSizeLowerLimit = cellSizeLowerLimit / binning^2;
    cellSizeUpperLimit = cellSizeUpperLimit / binning^2;
    
    % Get inputs
    image = block.InputPort(1).Data;
    threshold = block.InputPort(2).Data;%block.Dwork(1).Data;
        
    % Detect cells
    cellPositions = cellDetection(image, cellSizeLowerLimit, cellSizeUpperLimit, threshold, resizeScale);
        
    % Normalize and set outputs
    block.OutputPort(1).Data = NaN * ones(size(block.OutputPort(1).Data));
    block.OutputPort(1).Data(1:size(cellPositions, 1), :) = cellPositions ./ repmat([size(image, 2), size(image, 1)], size(cellPositions,1), 1); 
  
%endfunction
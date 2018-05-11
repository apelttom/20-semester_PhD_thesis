function cellTrackingBlock(block)
% This function realizes the cell tracking block in the Lemming Toolbox.

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
  % Sample time
  block.SampleTimes = block.DialogPrm(4).Data;
  
  % Register number of ports
  block.NumInputPorts  = 3;
  block.NumOutputPorts = 1;
 
  % Input = cell positions
  block.InputPort(1).DatatypeID   = 0; % double
  block.InputPort(1).Complexity   = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions = [block.DialogPrm(2).Data, 2];
  block.InputPort(1).DirectFeedthrough = true;
  
  % Input = reset tracking
  block.InputPort(2).DatatypeID   = 8; % boolean 
  block.InputPort(2).Complexity   = 'Real';
  block.InputPort(2).SamplingMode = 'Sample';
  block.InputPort(2).Dimensions = 1;
  block.InputPort(2).DirectFeedthrough = false;
  
  % Input = table position
  block.InputPort(3).DatatypeID   = 0; % double
  block.InputPort(3).Complexity   = 'Real';
  block.InputPort(3).SamplingMode = 'Sample';
  block.InputPort(3).Dimensions = 2;
  block.InputPort(3).DirectFeedthrough = true;
  
  % Output = sorted cell positions
  block.OutputPort(1).DatatypeID  = 0; % double
  block.OutputPort(1).Complexity  = 'Real';
  block.OutputPort(1).Dimensions = [block.DialogPrm(2).Data, 2];
  block.OutputPort(1).SamplingMode = 'Sample';
 
  % Register parameters
  block.NumDialogPrms     = 4;
  block.DialogPrmsTunable = {'Tunable', 'Nontunable', 'Tunable', 'Nontunable'};
  
  % Register Callbacks
  block.RegBlockMethod('Outputs', @Outputs);
  block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
  block.RegBlockMethod('Start', @Start);
  block.RegBlockMethod('Update', @Update);
  
%endfunction

function DoPostPropSetup(block)

  % Register variables
  maxNumCells =  block.DialogPrm(2).Data;
    
  block.NumDworks = 4;
  
  % Table consisting of all detected cells in the last image. Dworks must
  % be vectors, so we transform our matrix to a vector.
  block.Dwork(1).Name = 'cellTable'; 
  block.Dwork(1).Dimensions      = maxNumCells * 3;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  
  % Table consisting of all cells which were detected once, but not in the
  % last image.
  block.Dwork(2).Name = 'lostCellTable'; 
  block.Dwork(2).Dimensions      = maxNumCells * 4;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  % Every cell gets a unique ID. This is the ID the next detected cell will
  % get.
  block.Dwork(3).Name = 'nextCellID'; 
  block.Dwork(3).Dimensions      = 1;
  block.Dwork(3).DatatypeID      = 0;
  block.Dwork(3).Complexity      = 'Real';
  
  % True if tracking should be resetted
  block.Dwork(4).Name = 'resetTracking'; 
  block.Dwork(4).Dimensions      = 1;
  block.Dwork(4).DatatypeID      = 8; % boolean
  block.Dwork(4).Complexity      = 'Real';

%endfunction

function Start(block)
    % Initialize variables.
    maxNumCells =  block.DialogPrm(2).Data;
    
    block.Dwork(1).Data = NaN * ones(1, maxNumCells * 3);
    block.Dwork(2).Data = NaN * ones(1, maxNumCells * 4);
    block.Dwork(3).Data = 1;
    block.Dwork(4).Data = false;
   
%endfunction

function Update(block)
    block.Dwork(4).Data = block.InputPort(2).Data;
%endfunction

function Outputs(block)
  
    maxNumCells = block.DialogPrm(2).Data;
    lostCellSurvivalTime = block.DialogPrm(3).Data;
    %% Configuration
    % Maximum distance a cell is allowed to travel between two frames to be
    % still tracked. (in pixels).
    maxDistance = block.DialogPrm(1).Data;
    
    % Get inputs
    cellPositions = block.InputPort(1).Data;
    cellPositions(isnan(cellPositions(:, 1)) | isnan(cellPositions(:, 2)), :) = [];
    resetCells = block.Dwork(4).Data;
    tablePosition = block.InputPort(3).Data;
    if size(tablePosition, 1) == 2
        tablePosition = tablePosition';
    end
    cellPositions = cellPositions + repmat(tablePosition, size(cellPositions, 1), 1);
    
    
    % Reset cells if necessary
    if resetCells
        block.Dwork(1).Data = NaN * ones(1, maxNumCells * 3);
        block.Dwork(2).Data = NaN * ones(1, maxNumCells * 4);
        block.Dwork(3).Data = 1;
    end
    
    % Track cells
    cellTable = reshape(block.Dwork(1).Data, maxNumCells, 3);
    lostCellTable = reshape(block.Dwork(2).Data, maxNumCells, 4);
    nextCellID = block.Dwork(3).Data;
    cellTable(isnan(cellTable(:, 3)), :) = [];
    lostCellTable(isnan(lostCellTable(:, 3)), :) = [];
    [cellTable, lostCellTable, nextCellID] = cellTracking(cellTable, lostCellTable, cellPositions, maxDistance, nextCellID, lostCellSurvivalTime);
    
    % If cell ID gets too big, throw error
    if nextCellID - 1 > maxNumCells
        error('ETHZ:TooManyCellsDetected', 'Too many cells were detected. Consider increasing the maximum cell number.');
    end
    
    % Save variables for next time
    saveCellTable = NaN * ones(maxNumCells, 3);
    saveCellTable(1:size(cellTable, 1), :) = cellTable;
    block.Dwork(1).Data = saveCellTable(:);
    saveLostCellTable = NaN * ones(maxNumCells, 4);
    saveLostCellTable(1:size(lostCellTable, 1), :) = lostCellTable;
    block.Dwork(2).Data = saveLostCellTable(:);
    block.Dwork(3).Data = nextCellID;
    
    % Set outputs
    cellPositions = NaN * ones(length(block.OutputPort(1).Data), 2);
    cellPositions(cellTable(:, 3), :) = cellTable(:, 1:2);
    cellPositions(lostCellTable(:, 3), :) = lostCellTable(:, 1:2);
    block.OutputPort(1).Data = cellPositions;
  
%endfunction
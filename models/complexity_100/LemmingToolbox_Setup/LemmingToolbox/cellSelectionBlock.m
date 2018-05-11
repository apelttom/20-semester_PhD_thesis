function cellSelectionBlock(block)
% This file realizes the cell selection block in the Lemming Toolbox.

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
  % Sampling time
  block.SampleTimes = block.DialogPrm(2).Data;
  
  % Register number of ports
  block.NumInputPorts  = 2;
  block.NumOutputPorts = 4;
  
  % Override output port properties
  % X-Pos
  block.OutputPort(1).DatatypeID   = 0; % double
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  block.OutputPort(1).Dimensions = 1;
  
  %Y-Pos
  block.OutputPort(2).DatatypeID   = 0; % double
  block.OutputPort(2).Complexity   = 'Real';
  block.OutputPort(2).SamplingMode = 'Sample';
  block.OutputPort(2).Dimensions = 1;
  
  %Angle
  block.OutputPort(3).DatatypeID   = 0; % double
  block.OutputPort(3).Complexity   = 'Real';
  block.OutputPort(3).SamplingMode = 'Sample';
  block.OutputPort(3).Dimensions = 1;
  
  % Selected cell
  block.OutputPort(4).DatatypeID   = 7; % uint32
  block.OutputPort(4).Complexity   = 'Real';
  block.OutputPort(4).SamplingMode = 'Sample';
  block.OutputPort(4).Dimensions = 1;
  
  % Override input port properties
  % Cell-Positions
  block.InputPort(1).DatatypeID  = 0; % double
  block.InputPort(1).Complexity  = 'Real';
  block.InputPort(1).DirectFeedthrough = true;
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions = [block.DialogPrm(3).Data, 2];
  
  % Control
  block.InputPort(2).DatatypeID   = 0; % double
  block.InputPort(2).Complexity   = 'Real';
  block.InputPort(2).DirectFeedthrough = false;
  block.InputPort(2).SamplingMode = 'Sample';
  block.InputPort(2).Dimensions = 1;

  %% Register parameters
  block.NumDialogPrms     = 3;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable'};
  
  % Register Callbacks
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Outputs', @Outputs);
  block.RegBlockMethod('Start', @Start);

%endfunction

function DoPostPropSetup(block)

  % Register variables
  block.NumDworks = 2;
  
  block.Dwork(1).Name = 'currCell'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  
  block.Dwork(2).Name = 'lastPositions'; 
  block.Dwork(2).Dimensions      = block.DialogPrm(1).Data * 2;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  
%endfunction

%% Start function of the block
function Start(block)
    block.Dwork(1).Data = NaN;
    block.Dwork(2).Data = NaN * ones(size(block.Dwork(2).Data));
%endfunction

function Outputs(block)
  currCell = block.Dwork(1).Data;
  oldCell = currCell;
  numCells = sum(~isnan(block.InputPort(1).Data(:, 1)));
  lastPositions = reshape(block.Dwork(2).Data, length(block.Dwork(2).Data)/2, 2);
 
  if numCells < 1
      block.Dwork(1).Data = 1;
      block.OutputPort(1).Data = NaN;
      block.OutputPort(2).Data = NaN;
      block.OutputPort(3).Data = NaN;
      block.OutputPort(4).Data = uint32(NaN);
      return;
  end
  
  % Get information if we should change the cell
  if block.InputPort(2).Data > 0
      switchCell = 1;
  elseif block.InputPort(2).Data < 0
      switchCell = -1;
  else
      switchCell = 0;
  end
  % If last current cell got deleted, also switch the cell
  if isnan(currCell) || (any(isnan(block.InputPort(1).Data(currCell, :))) && switchCell == 0)
      %switchCell = -1;
      % Return the closest cell
      lastX = lastPositions(end, 1);
      lastY = lastPositions(end, 2);
      if isnan(lastX) || isnan(lastY)
          % Cell was not valid last time, too. Just return the valid cell
          % which is closest to the center
          lastX = 0.5;
          lastY = 0.5;
      end
      [sortDist, sortCellsIdx] = sort((block.InputPort(1).Data(:, 1) - lastX).^2 + (block.InputPort(1).Data(:, 2) - lastY).^2); %#ok<ASGLU>
      currCell = sortCellsIdx(1);
  end
  % If swichting, find the cell which is closest to the last cell in the
  % chosen direction
  if switchCell ~= 0
      lastX = block.InputPort(1).Data(oldCell, 1);
      if isnan(lastX)
          % Cell got deleted, get last valid position
          lastX = lastPositions(end, 1);
      end
      if isnan(lastX)
          % Cell was not valid last time, too. Just return first valid
          % cell.
          %currCell = find(~isnan(block.InputPort(1).Data(:, 1)), 1);
          lastX = 0.5;
      end
      if switchCell > 0
          [sortX, sortCellsIdx] = sort(block.InputPort(1).Data(:, 1));
          currCell = sortCellsIdx(find(~isnan(sortX) & sortX > lastX, 1));
          if isempty(currCell)
              % The last cell was the right-most cell. Switch to the
              % left-most
              currCell = sortCellsIdx(find(~isnan(sortX), 1));
          end
      else
          [sortX, sortCellsIdx] = sort(block.InputPort(1).Data(:, 1));
          currCell = sortCellsIdx(find(~isnan(sortX) & sortX < lastX, 1, 'last'));
          if isempty(currCell)
              % The last cell was the left-most cell. Switch to the
              % right-most
              currCell = sortCellsIdx(find(~isnan(sortX), 1, 'last'));
          end
      end
  end
  
  % If cell switched, delete last positions.
  if oldCell ~= currCell
    lastPositions = NaN * ones(size(lastPositions));
    block.Dwork(1).Data = currCell;
  end
  
  % Save current position
  lastPositions(1:end-1, :) = lastPositions(2:end, :);
  lastPositions(end, :) = block.InputPort(1).Data(currCell, :);
  block.Dwork(2).Data = lastPositions(:);
  
  % Return position current cell
  block.OutputPort(1).Data = block.InputPort(1).Data(currCell, 1);
  block.OutputPort(2).Data = block.InputPort(1).Data(currCell, 2);
  block.OutputPort(4).Data = uint32(currCell);
  if any(isnan(lastPositions(:)))
	block.OutputPort(3).Data = NaN;
  else
	block.OutputPort(3).Data = atan2(block.InputPort(1).Data(currCell, 2) - lastPositions(1, 2), block.InputPort(1).Data(currCell, 1) - lastPositions(1, 1));
  end
  
%endfunction


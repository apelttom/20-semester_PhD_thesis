function tumblingStatisticsBlock(block)
% This file provides the block of the Lemming Toolbox visualizing a
% simplified version of the cellular movement.


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
  % Set block sample time to continuous
  block.SampleTimes = block.DialogPrm(1).Data; % Discrete
  
  % Register number of ports
  block.NumInputPorts  = 5;
  block.NumOutputPorts = 0; 
  
  % Override input port properties
  % xpos
  block.InputPort(1).DatatypeID   = 0; % double
  block.InputPort(1).Complexity   = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions = 1;
  
  % ypos
  block.InputPort(2).DatatypeID   = 0; % double
  block.InputPort(2).Complexity   = 'Real';
  block.InputPort(2).SamplingMode = 'Sample';
  block.InputPort(2).Dimensions = 1;
  
  % direction
  block.InputPort(3).DatatypeID   = 0; % double
  block.InputPort(3).Complexity   = 'Real';
  block.InputPort(3).SamplingMode = 'Sample';
  block.InputPort(3).Dimensions = 1;
  
  % running or tumbling
  block.InputPort(4).DatatypeID   = 8; % boolean
  block.InputPort(4).Complexity   = 'Real';
  block.InputPort(4).SamplingMode = 'Sample';
  block.InputPort(4).Dimensions = 1;
  
  % phi_sh
  block.InputPort(5).DatatypeID   = 0; % double
  block.InputPort(5).Complexity   = 'Real';
  block.InputPort(5).SamplingMode = 'Sample';
  block.InputPort(5).Dimensions = 1;
  
  % Register parameters
  block.NumDialogPrms     = 2;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable'};

  % Register Callbacks
   block.RegBlockMethod('Update',                  @Update);  
   block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
   block.RegBlockMethod('Start',                   @Start);
   
   block.NumContStates = 0;
%endfunction

function DoPostPropSetup(block)
  % Register variables
  block.NumDworks = 8;
  
  block.Dwork(1).Name = 'xposList'; 
  block.Dwork(1).Dimensions      = block.DialogPrm(2).Data;
  block.Dwork(1).DatatypeID      = 0; % double
  block.Dwork(1).Complexity      = 'Real';
  
  block.Dwork(2).Name = 'yposList'; 
  block.Dwork(2).Dimensions      = block.DialogPrm(2).Data;
  block.Dwork(2).DatatypeID      = 0; % double
  block.Dwork(2).Complexity      = 'Real';
  
  block.Dwork(3).Name = 'directionList'; 
  block.Dwork(3).Dimensions      = block.DialogPrm(2).Data;
  block.Dwork(3).DatatypeID      = 0; % double
  block.Dwork(3).Complexity      = 'Real';
  
  block.Dwork(4).Name = 'isRunningList'; 
  block.Dwork(4).Dimensions      = block.DialogPrm(2).Data;
  block.Dwork(4).DatatypeID      = 8; % boolean
  block.Dwork(4).Complexity      = 'Real';
  
  block.Dwork(5).Name = 'timeList'; 
  block.Dwork(5).Dimensions      = block.DialogPrm(2).Data;
  block.Dwork(5).DatatypeID      = 0; % double
  block.Dwork(5).Complexity      = 'Real';
  
   block.Dwork(6).Name = 'endIdx'; 
   block.Dwork(6).Dimensions      = 1;
   block.Dwork(6).DatatypeID      = 0; % double
   block.Dwork(6).Complexity      = 'Real';
   
   block.Dwork(7).Name = 'pathH'; 
   block.Dwork(7).Dimensions      = 1;
   block.Dwork(7).DatatypeID      = 0; % double
   block.Dwork(7).Complexity      = 'Real';
   
   block.Dwork(8).Name = 'dirH'; 
   block.Dwork(8).Dimensions      = 1;
   block.Dwork(8).DatatypeID      = 0; % double
   block.Dwork(8).Complexity      = 'Real';
%endfunction

function Start(block)
    block.Dwork(6).Data = 0;
    
    % Setup output figurs
    
    figH = tumblingStatisticsFig;
    childrenH = get(figH, 'Children');
    block.Dwork(7).Data = childrenH(2);
    block.Dwork(8).Data = childrenH(1);
    
    if ishandle(block.Dwork(7).Data) >= 2
        pathH = block.Dwork(7).Data;
        xlabel(pathH, 'xpos');
        ylabel(pathH, 'ypos');
        grid(pathH, 'on');
    end
%endfunction

function Update(block)
    t = block.CurrentTime;
    xpos = block.InputPort(1).Data;
    ypos = block.InputPort(2).Data;
    direction = block.InputPort(3).Data;
    isRunning = block.InputPort(4).Data;
    
    endIdx = block.Dwork(6).Data;
    bufferLength = block.DialogPrm(2).Data;
    
    if endIdx >= bufferLength
        % Buffer is full, we delete every second element in the first
        % third of the buffer.
        makeSmaller = 0.8;
        smallerBorder = round(makeSmaller * bufferLength);
        keepIdx = [1 : 2 : smallerBorder, smallerBorder+1 : bufferLength];
        block.Dwork(1).Data(1:length(keepIdx)) = block.Dwork(1).Data(keepIdx);
        block.Dwork(2).Data(1:length(keepIdx)) = block.Dwork(2).Data(keepIdx);
        block.Dwork(3).Data(1:length(keepIdx)) = block.Dwork(3).Data(keepIdx);
        block.Dwork(4).Data(1:length(keepIdx)) = block.Dwork(4).Data(keepIdx);
        block.Dwork(5).Data(1:length(keepIdx)) = block.Dwork(5).Data(keepIdx);
        endIdx = length(keepIdx) + 1;
    else
        endIdx = endIdx + 1;
    end
    
    % Save current position
    block.Dwork(1).Data(endIdx) = xpos;
    block.Dwork(2).Data(endIdx) = ypos;
    block.Dwork(3).Data(endIdx) = direction;
    block.Dwork(4).Data(endIdx) = isRunning;
    block.Dwork(5).Data(endIdx) = t;
    block.Dwork(6).Data = endIdx;
    
    dataIdx = 1 : endIdx;
    % Plot data
    if endIdx >= 2
        pathH = block.Dwork(7).Data;
        if ishandle(pathH)
            % Draw path
            cla(pathH);
            plot(pathH, block.Dwork(1).Data(1:endIdx), block.Dwork(2).Data(1:endIdx));
            maxDist = max(max(abs(block.Dwork(1).Data(dataIdx))), max(abs(block.Dwork(2).Data(dataIdx))));
            xlim(pathH, [-maxDist, maxDist]);
            ylim(pathH, [-maxDist, maxDist]);
            drawnow;
        end
        
        dirH = block.Dwork(8).Data;
        if ishandle(dirH)
            % Draw direction
            cla(dirH);
            hold(dirH, 'on');
            plot(dirH, [0, cos(direction)], [0, sin(direction)], 'g');
            plot(dirH, [0, cos(block.InputPort(5).Data)], [0, sin(block.InputPort(5).Data)], 'r');
            xlim(dirH, [-1, 1]);
            ylim(dirH, [-1, 1]);
            drawnow;
        end
    end
    
%endfunction
    

function keyboardInputBlock(block)
% This file realizes the keyboard input for the Lemming Toolbox.


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
  % Set block sample time to continuous
  block.SampleTimes = block.DialogPrm(1).Data;
  
  % Register number of ports
  block.NumInputPorts  = 0;
  block.NumOutputPorts = 7; 
  
  % Override output port properties
  % phi_sh
  block.OutputPort(1).DatatypeID   = 0; % double
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  block.OutputPort(1).Dimensions = 1;
  
  % threshold
  block.OutputPort(2).DatatypeID   = 0; % double
  block.OutputPort(2).Complexity   = 'Real';
  block.OutputPort(2).SamplingMode = 'Sample';
  block.OutputPort(2).Dimensions = 1;
  
  % RL
  block.OutputPort(3).DatatypeID   = 8; % boolean
  block.OutputPort(3).Complexity   = 'Real';
  block.OutputPort(3).SamplingMode = 'Sample';
  block.OutputPort(3).Dimensions = 1;
  
  % FRL
  block.OutputPort(4).DatatypeID   = 8; % boolean
  block.OutputPort(4).Complexity   = 'Real';
  block.OutputPort(4).SamplingMode = 'Sample';
  block.OutputPort(4).Dimensions = 1;
  
  % CellSelect
  block.OutputPort(5).DatatypeID   = 0; % double
  block.OutputPort(5).Complexity   = 'Real';
  block.OutputPort(5).SamplingMode = 'Sample';
  block.OutputPort(5).Dimensions = 1;
  
  % ControlActivation
  block.OutputPort(6).DatatypeID   = 0; % double
  block.OutputPort(6).Complexity   = 'Real';
  block.OutputPort(6).SamplingMode = 'Sample';
  block.OutputPort(6).Dimensions = 1;
  
  % Key ID
  block.OutputPort(7).DatatypeID   = 3; % uint8
  block.OutputPort(7).Complexity   = 'Real';
  block.OutputPort(7).SamplingMode = 'Sample';
  block.OutputPort(7).Dimensions = 1;
  
  % Register parameters
  block.NumDialogPrms     = 2;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable'};

  % Register Callbacks  
   block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
   block.RegBlockMethod('Outputs',                 @Outputs);
   block.RegBlockMethod('Start',                   @Start);
%endfunction

function DoPostPropSetup(block)
  % Register variables
  block.NumDworks = 2;
  
  block.Dwork(1).Name = 'phi_sh'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0; % double
  block.Dwork(1).Complexity      = 'Real';
  
  block.Dwork(2).Name = 'threshold'; 
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0; % double
  block.Dwork(2).Complexity      = 'Real';
%endfunction

function Start(block)
    block.Dwork(1).Data = 0;
    block.Dwork(2).Data = block.DialogPrm(2).Data;
%endfunction

function Outputs(block)
  frameH = get(0,'CurrentFigure');
  pressedButton = 0;
  if(ishandle(frameH))
      pressedButton = double(get(frameH, 'CurrentCharacter'));
      % Set current key to '?'
      set(frameH, 'CurrentCharacter', char(63))
      if isempty(pressedButton)
          pressedButton = 0;
      end
  end
  
  % threshold control
  if pressedButton == 43
      % keys: '+'
      block.Dwork(2).Data = block.Dwork(2).Data + 0.005;
  elseif pressedButton == 45
      % keys: '-'
      block.Dwork(2).Data = block.Dwork(2).Data - 0.005;
  end
  % direct arrow control 
  if pressedButton == 54
      % keys: '6'
      block.Dwork(1).Data = 0;
  elseif pressedButton == 51
      % keys: '3'
      block.Dwork(1).Data = pi/4;
  elseif pressedButton == 50
      % keys '2'
      block.Dwork(1).Data = pi/2;
  elseif pressedButton == 49
      % keys 1
      block.Dwork(1).Data = pi * 3/4;
  elseif pressedButton == 52
      % keys 4
      block.Dwork(1).Data = pi;
  elseif pressedButton == 55
      % keys 7
      block.Dwork(1).Data = pi * 5/4;
  elseif pressedButton == 56
      % keys 8
      block.Dwork(1).Data = pi * 3/2;
  elseif pressedButton == 57
      % keys 9
      block.Dwork(1).Data = pi * 7/4;
  end
  % move arrow a step clock or counterclockwise
  if pressedButton == 29 || pressedButton == 100
      % keys: arrow right or 'd'
      block.Dwork(1).Data = block.Dwork(1).Data + pi/16;
  elseif pressedButton == 28 || pressedButton == 97
      % keys: arrow left or 'a'
      block.Dwork(1).Data = block.Dwork(1).Data - pi/16;
  end
  
  
  % next or previous cell
  if pressedButton == 113
      % keys: q
      block.OutputPort(5).Data = -1;
  elseif pressedButton == 101
      % keys: e
      block.OutputPort(5).Data = 1;
  else
      block.OutputPort(5).Data = 0;
  end
  % RL or FRL
  block.OutputPort(3).Data = false;
  block.OutputPort(4).Data = false;
  if pressedButton == 30 || pressedButton == 119
      % keys: arrow up or 'w'
      block.OutputPort(3).Data = true;
  elseif pressedButton == 31 || pressedButton == 115
      % keys: arrow down or 's'
      block.OutputPort(4).Data = true;
  end
  
  % Control activation
  if pressedButton == 13
      block.OutputPort(6).Data = 1;
  elseif pressedButton == 8
      block.OutputPort(6).Data = -1;
  else
      block.OutputPort(6).Data = 0;
  end
      
  block.OutputPort(1).Data = block.Dwork(1).Data;
  block.OutputPort(2).Data = block.Dwork(2).Data;   
  % Output pressed key
  block.OutputPort(7).Data = uint8(pressedButton);
  
%endfunction
    

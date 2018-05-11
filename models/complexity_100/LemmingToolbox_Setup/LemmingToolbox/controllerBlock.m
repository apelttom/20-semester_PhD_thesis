function controllerBlock(block)
% This function realizes the controller block in the Lemming Toolbox.

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
  block.SampleTimes = block.DialogPrm(1).Data; % Discrete
  
  % Register number of ports
  block.NumInputPorts  = 3;
  block.NumOutputPorts = 2; 
  
  % Override input port properties
  % phis_is
  block.InputPort(1).DatatypeID  = 0; % double
  block.InputPort(1).Complexity  = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions = 1;
  block.InputPort(1).DirectFeedthrough = true;
  
  % phi_sh
  block.InputPort(2).DatatypeID  = 0; % double
  block.InputPort(2).Complexity  = 'Real';
  block.InputPort(2).SamplingMode = 'Sample';
  block.InputPort(2).Dimensions = 1;
  block.InputPort(2).DirectFeedthrough = true;
  
    % Control active
  block.InputPort(3).DatatypeID  = 8; % boolean
  block.InputPort(3).Complexity  = 'Real';
  block.InputPort(3).SamplingMode = 'Sample';
  block.InputPort(3).Dimensions = 1;
  block.InputPort(3).DirectFeedthrough = true;
  
  % Override output port properties
  % RL
  block.OutputPort(1).DatatypeID   = 8; % boolean
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  block.OutputPort(1).Dimensions = 1;
  
  % FRL
  block.OutputPort(2).DatatypeID   = 8; % boolean
  block.OutputPort(2).Complexity   = 'Real';
  block.OutputPort(2).SamplingMode = 'Sample';
  block.OutputPort(2).Dimensions = 1;
  
  block.NumDialogPrms     = 2;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable'};

  % Register Callbacks
   block.RegBlockMethod('Outputs',                 @Outputs);
%endfunction

function Outputs(block)
    if block.InputPort(3).Data
      t = block.CurrentTime;
      controller = block.DialogPrm(2).Data;

      [RL, FRL] = controller(t, block.InputPort(1).Data, block.InputPort(2).Data);

      block.OutputPort(1).Data = boolean(RL);
      block.OutputPort(2).Data = boolean(FRL);
    else
        block.OutputPort(1).Data = false;
        block.OutputPort(2).Data = false;
    end
%endfunction
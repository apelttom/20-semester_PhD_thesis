function lightBlock(block)
% Level-2 M file S-function controlling red and far red microscope light.


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

%% Function to shut on/off RL/FRL
function controlLights(isRL, isOn)
    global microscopeController;

    if ~exist('microscopeController', 'var') || isempty(microscopeController)
        error('ELemming:MicroscopeNotInitialized', 'Microscope is not initialized');
    end
    
    jobManager = microscopeController.jobManager;
    if isRL
        if isOn
            jobManager.startJob(microscopeController.RLOn);
        else
            jobManager.startJob(microscopeController.RLOff);
        end
    else
        if isOn
            jobManager.startJob(microscopeController.FRLOn);
        else
            jobManager.startJob(microscopeController.FRLOff);
        end
    end
%endfunction
  
%% Initialitzation of the block
function setup(block)
  
  %% Register number of ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 0;
  
  block.SampleTimes = block.DialogPrm(2).Data;
  
  %% Setup functional port properties
  block.InputPort(1).DatatypeID   = 8; % boolean
  block.InputPort(1).Complexity   = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions = 1;
  block.InputPort(1).DirectFeedthrough = true;
    
  %% Register parameters
  block.NumDialogPrms     = 3;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable'};

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Outputs',                 @Output);
  block.RegBlockMethod('Start',                   @Start);
   
%endfunction

function DoPostPropSetup(block)
  % Register variables
  block.NumDworks = 1;
  block.Dwork(1).Name = 'lightOn'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 8;
  block.Dwork(1).Complexity      = 'Real';
  
%endfunction

function Start(block)
  block.Dwork(1).Data = false;
%endfunction

%% Output function of the block
function Output(block)
    if block.InputPort(1).Data ~= block.Dwork(1).Data && block.DialogPrm(3).Data
        block.Dwork(1).Data = block.InputPort(1).Data;
        controlLights(block.DialogPrm(1).Data, block.Dwork(1).Data);
    end
   
%endfunction

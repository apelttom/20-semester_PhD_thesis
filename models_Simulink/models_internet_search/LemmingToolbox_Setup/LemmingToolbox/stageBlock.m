function stageBlock(block)
% Level-2 M file S-function for the control of the microscope stage.


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

%% Function to get the image from the microscope
function changeNow(xPos, xNeg, yPos, yNeg, step) %#ok<INUSD>
    global microscopeController;

    if ~exist('microscopeController', 'var') || isempty(microscopeController)
        error('ELemming:MicroscopeNotInitialized', 'Microscope is not initialized');
    end
    
    % For a 40 fold microscope we need
    % pixelsize/magnification*pixels/stepsize/correctionMicroscope
    % --> width = 6.45 / 40 * 1344/4/4 = 13.5450
    % --> height = 6.45 / 40 * 1024/4/4 = 10.3200
    jobManager = microscopeController.jobManager;
    if xPos
        jobManager.startJob(microscopeController.moveRight);
    elseif xNeg
        jobManager.startJob(microscopeController.moveLeft);
    end
    if yPos
        jobManager.startJob(microscopeController.moveDown);
    elseif yNeg
        jobManager.startJob(microscopeController.moveUp);
    end
    
    %jobManager.startJob(microscopeController.imageJob);
%endfunction
  
%% Initialitzation of the block
function setup(block)
  
  %% Register number of ports
  block.NumInputPorts  = 4;
  block.NumOutputPorts = 2;
  
  %% Setup functional port properties
  block.InputPort(1).DatatypeID   = 8; % boolean
  block.InputPort(1).Complexity   = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions = 1;
  block.InputPort(1).DirectFeedthrough = false;
  
  block.InputPort(2).DatatypeID   = 8; % boolean
  block.InputPort(2).Complexity   = 'Real';
  block.InputPort(2).SamplingMode = 'Sample';
  block.InputPort(2).Dimensions = 1;
  block.InputPort(2).DirectFeedthrough = false;
  
  block.InputPort(3).DatatypeID   = 8; % boolean
  block.InputPort(3).Complexity   = 'Real';
  block.InputPort(3).SamplingMode = 'Sample';
  block.InputPort(3).Dimensions = 1;
  block.InputPort(3).DirectFeedthrough = false;
  
  block.InputPort(4).DatatypeID   = 8; % boolean
  block.InputPort(4).Complexity   = 'Real';
  block.InputPort(4).SamplingMode = 'Sample';
  block.InputPort(4).Dimensions = 1;
  block.InputPort(4).DirectFeedthrough = false;
  
  block.OutputPort(1).DatatypeID   = 0; % double
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  block.OutputPort(1).Dimensions = 1;
  
  block.OutputPort(2).DatatypeID   = 0; % double
  block.OutputPort(2).Complexity   = 'Real';
  block.OutputPort(2).SamplingMode = 'Sample';
  block.OutputPort(2).Dimensions = 1;
  
  %% Register parameters
  block.NumDialogPrms     = 5;
  block.DialogPrmsTunable = {'Tunable', 'Tunable', 'Nontunable', 'Nontunable', 'Nontunable'};

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Outputs',                 @Output);
  block.RegBlockMethod('Update',                  @Update);
  block.RegBlockMethod('Start',                   @Start);
   
%endfunction

function DoPostPropSetup(block)
  % Register variables
  block.NumDworks = 4;
  block.Dwork(1).Name = 'dx'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  
  block.Dwork(2).Name = 'dy'; 
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  
  block.Dwork(3).Name = 'lastTimeX'; 
  block.Dwork(3).Dimensions      = 1;
  block.Dwork(3).DatatypeID      = 0;
  block.Dwork(3).Complexity      = 'Real';
  
  block.Dwork(4).Name = 'lastTimeY'; 
  block.Dwork(4).Dimensions      = 1;
  block.Dwork(4).DatatypeID      = 0;
  block.Dwork(4).Complexity      = 'Real';
  
%endfunction

function Start(block)
  initialCondition = block.DialogPrm(5).Data;
  block.Dwork(1).Data = initialCondition(1);
  block.Dwork(2).Data = initialCondition(2);
  block.Dwork(3).Data = 0;
  block.Dwork(4).Data = 0;
%endfunction

%% Output function of the block
function Output(block)
    % Return offset of last evaluation (since the microscope is making the
    % images asynchronosly, the next image won't be moved, yet, but the
    % image after the next. Thus, we have to delay the change in position,
    % too).
    block.OutputPort(1).Data = block.Dwork(1).Data;
    block.OutputPort(2).Data = block.Dwork(2).Data;
%endfunction

%% Update function of the block
function Update(block)
    moveRequests = [block.InputPort(1).Data, block.InputPort(2).Data,...
        block.InputPort(3).Data, block.InputPort(4).Data];
    step = block.DialogPrm(2).Data;
    
    if block.DialogPrm(3).Data && any(moveRequests(1:2))
        % Should move in x direction
        % Check first if a few seconds are over to protect microscope
        if cputime - block.Dwork(3).Data > block.DialogPrm(1).Data
            if moveRequests(1)
                if block.DialogPrm(4).Data
                    changeNow(false, true, false, false, step);
                end
                block.Dwork(1).Data = block.Dwork(1).Data - step;
            else
                if block.DialogPrm(4).Data
                    changeNow(true, false, false, false, step);
                end
                block.Dwork(1).Data = block.Dwork(1).Data + step;
            end
            block.Dwork(3).Data = cputime;
        end
    end
    
    if block.DialogPrm(3).Data && any(moveRequests(3:4))
        % Should move in y direction
        % Check first if a few seconds are over to protect microscope
        if cputime - block.Dwork(4).Data > block.DialogPrm(1).Data
            if moveRequests(3)
                if block.DialogPrm(4).Data
                    changeNow(false, false, false, true, step);
                end
                block.Dwork(2).Data = block.Dwork(2).Data - step;
            else
                if block.DialogPrm(4).Data
                    changeNow(false, false, true, false, step)
                end
                block.Dwork(2).Data = block.Dwork(2).Data + step;
            end
            block.Dwork(4).Data = cputime;
        end
    end
 
%endfunction


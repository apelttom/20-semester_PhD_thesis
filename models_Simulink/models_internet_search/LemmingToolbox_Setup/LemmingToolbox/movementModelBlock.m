function movementModelBlock(block)

setup(block);
  
%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the S-function block's basic characteristics such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%% 
%%   Required         : Yes
%%   C-Mex counterpart: mdlInitializeSizes
%%
function setup(block)
  % Set block sample time to continuous
  block.SampleTimes = block.DialogPrm(1).Data; % Discrete
  
  % Register number of ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 4; 
  
  % Override input port properties
  % Bias
  block.InputPort(1).DatatypeID  = 0; % double
  block.InputPort(1).Complexity  = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions = 1;
  block.InputPort(1).DirectFeedthrough = false;
  
  % Override output port properties
  % xpos
  block.OutputPort(1).DatatypeID   = 0; % double
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  block.OutputPort(1).Dimensions = 1;
  
  % ypos
  block.OutputPort(2).DatatypeID   = 0; % double
  block.OutputPort(2).Complexity   = 'Real';
  block.OutputPort(2).SamplingMode = 'Sample';
  block.OutputPort(2).Dimensions = 1;
  
  % direction
  block.OutputPort(3).DatatypeID   = 0; % double
  block.OutputPort(3).Complexity   = 'Real';
  block.OutputPort(3).SamplingMode = 'Sample';
  block.OutputPort(3).Dimensions = 1;
  
  % running or tumbling
  block.OutputPort(4).DatatypeID   = 8; % boolean
  block.OutputPort(4).Complexity   = 'Real';
  block.OutputPort(4).SamplingMode = 'Sample';
  block.OutputPort(4).Dimensions = 1;
  
  % Register parameters
  block.NumDialogPrms     = 6;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable'};

  % Register Callbacks
   block.RegBlockMethod('Update',                  @Update);  
   block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
   block.RegBlockMethod('Outputs',                 @Outputs);
   block.RegBlockMethod('Start',                   @Start);
   
   block.NumContStates = 0;
%endfunction

function DoPostPropSetup(block)
  % Register variables
  block.NumDworks = 5;
  
  block.Dwork(1).Name = 'isRunning'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 8; % boolean
  block.Dwork(1).Complexity      = 'Real';
  
  block.Dwork(2).Name = 'xpos'; 
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0; % double
  block.Dwork(2).Complexity      = 'Real';
  
  block.Dwork(3).Name = 'ypos'; 
  block.Dwork(3).Dimensions      = 1;
  block.Dwork(3).DatatypeID      = 0; % double
  block.Dwork(3).Complexity      = 'Real';
  
  block.Dwork(4).Name = 'angle'; 
  block.Dwork(4).Dimensions      = 1;
  block.Dwork(4).DatatypeID      = 0; % double
  block.Dwork(4).Complexity      = 'Real';
  
  block.Dwork(5).Name = 'tumblingSpeed'; 
  block.Dwork(5).Dimensions      = 1;
  block.Dwork(5).DatatypeID      = 0; % double
  block.Dwork(5).Complexity      = 'Real';
%endfunction

function Start(block)
    imageWidth = block.DialogPrm(2).Data;
    imageHeight = block.DialogPrm(3).Data;
    binning = block.DialogPrm(4).Data;
    pixelSize = block.DialogPrm(5).Data;
  
    % set initial condition to running
    block.Dwork(1).Data = true;
    % set initial tumbling speed to zero (will be overwritten at the first
    % start of tumbling anyway.
    block.Dwork(5).Data = 0;
    % Set initial position
    block.Dwork(2).Data = block.DialogPrm(6).Data(1) * pixelSize * imageWidth / binning;
    block.Dwork(3).Data = block.DialogPrm(6).Data(2) * pixelSize * imageHeight / binning;
    block.Dwork(4).Data = block.DialogPrm(6).Data(3);
%endfunction

function Outputs(block)
  imageWidth = block.DialogPrm(2).Data;
  imageHeight = block.DialogPrm(3).Data;
  binning = block.DialogPrm(4).Data;
  pixelSize = block.DialogPrm(5).Data;
    
  block.OutputPort(1).Data = block.Dwork(2).Data / pixelSize / imageWidth * binning;
  block.OutputPort(2).Data = block.Dwork(3).Data / pixelSize / imageHeight * binning;
  block.OutputPort(3).Data = mod(block.Dwork(4).Data, 2 * pi);
  block.OutputPort(4).Data = block.Dwork(1).Data;
%endfunction

function Update(block)
    dt = block.DialogPrm(1).Data(1);
    bias = block.InputPort(1).Data;
    
    [dx, block.Dwork(1).Data, block.Dwork(5).Data] = movementModel(block.CurrentTime, [block.Dwork(2).Data, block.Dwork(3).Data, block.Dwork(4).Data], dt, block.Dwork(1).Data, block.Dwork(5).Data, bias);
    % ODE1 integration
    block.Dwork(2).Data = block.Dwork(2).Data + dx(1) * dt;
    block.Dwork(3).Data = block.Dwork(3).Data + dx(2) * dt;
    block.Dwork(4).Data = block.Dwork(4).Data + dx(3) * dt;
%endfunction
    

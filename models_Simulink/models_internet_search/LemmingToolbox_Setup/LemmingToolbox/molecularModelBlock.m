function molecularModelBlock(block)
% This file realizes the molecular model block in the Lemming Toolbox.

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
  block.SampleTimes = [0, 0]; % Continous
  
  % Register number of ports
  block.NumInputPorts  = 2;
  block.NumOutputPorts = 2; 
  
  % Override output port properties
  % CheYp
  block.OutputPort(1).DatatypeID   = 0; % double
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  block.OutputPort(1).Dimensions = 1;
  
  % Override output port properties
  % bias
  block.OutputPort(2).DatatypeID   = 0; % double
  block.OutputPort(2).Complexity   = 'Real';
  block.OutputPort(2).SamplingMode = 'Sample';
  block.OutputPort(2).Dimensions = 1;
  
  % Override input port properties
  % Red light
  block.InputPort(1).DatatypeID  = 8; % boolean
  block.InputPort(1).Complexity  = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Dimensions = 1;
  block.InputPort(1).DirectFeedthrough = false;
  
  % Far-Red light
  block.InputPort(2).DatatypeID  = 8; % boolean
  block.InputPort(2).Complexity  = 'Real';
  block.InputPort(2).SamplingMode = 'Sample';
  block.InputPort(2).Dimensions = 1;
  block.InputPort(2).DirectFeedthrough = false;
  
  % Register parameters
  block.NumDialogPrms     = 7;
  block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable', 'Nontunable'};

  % Register Callbacks
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Derivatives',             @Derivative);  
  block.RegBlockMethod('Outputs', @Outputs);
  
  % Initialize continous states
  chemotaxisModel = block.DialogPrm(1).Data;
  cheSpeciesAttachedToPhyB = block.DialogPrm(3).Data - 1;
  controlledCheSpeciesName = block.DialogPrm(2).Data;
  block.NumContStates = length(molecularModel('IC', chemotaxisModel, controlledCheSpeciesName, cheSpeciesAttachedToPhyB));

%endfunction

function DoPostPropSetup(block)
  % Register variables
  block.NumDworks = 1;
  
  block.Dwork(1).Name = 'CheYp0'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0; % double
  block.Dwork(1).Complexity      = 'Real';
%endfunction

function InitConditions(block)
    %% Initialize states
    chemotaxisModel = block.DialogPrm(1).Data;
    cheSpeciesAttachedToPhyB = block.DialogPrm(3).Data - 1;
    controlledCheSpeciesName = block.DialogPrm(2).Data;
    
    % Aspertate level
    Asp =  block.DialogPrm(4).Data;
    % Equilibrate model
    t_0 = 0; %[s]
    t_final = 800; % [s]
    t_span = [t_0 t_final];
    p = getChangedParameters(block);
    x0 = molecularModel('IC', chemotaxisModel, controlledCheSpeciesName, cheSpeciesAttachedToPhyB, 'p', p);
    [t_out, x_out] = ode15s(@molecularModel, t_span, x0, [], chemotaxisModel, controlledCheSpeciesName, cheSpeciesAttachedToPhyB, 'Asp', Asp, 'p', p); %#ok<ASGLU>

    block.ContStates.Data = x_out(end, :);
    
    % Set WT equilibrated CheYp concentration
     if strcmpi(chemotaxisModel, 'spiro')
         block.Dwork(1).Data = 6.071;
     elseif strcmpi(chemotaxisModel, 'mello')
         block.Dwork(1).Data = 0.9562;
     end
    
%endfunction

function Outputs(block)
  % Reshape states
  chemotaxisModel = block.DialogPrm(1).Data;
  cheSpeciesAttachedToPhyB = block.DialogPrm(3).Data - 1;
  if strcmpi(chemotaxisModel, 'spiro')
    n_chemo = 12;
    n_cheProts = 6;
  else
    n_chemo = 15;
    n_cheProts = 6;
  end
  if cheSpeciesAttachedToPhyB
    n_cheProtsStates = 4;
    n_light = 3;
  else
    n_cheProtsStates = 3;
    n_light = 5;
  end
  cheProteins = reshape(block.ContStates.Data(n_chemo+n_light+1:end), n_cheProts, n_cheProtsStates);
  
  % Calculate bias
  % The formula is taken from Levin et al. (1998), "Origins of Individual
  % Swimming Behavior in Bacteria", Biophysical Journal 74: 175-181.
  CheYpFree = sum(cheProteins(5, 1:end-1));
  CheYp0 =   block.Dwork(1).Data;
  bias = 1 - CheYpFree^5.5 / (17/3 * CheYp0^5.5 + CheYpFree^5.5);
  
  % Set outputs
  block.OutputPort(1).Data =  CheYpFree;
  block.OutputPort(2).Data = bias;%calculateBias(chemotaxisModel, block.OutputPort(1).Data); % bias
  
%endfunction

function Derivative(block)
    % Red ligth strength
    RL =  block.InputPort(1).Data;
    % Far-red light strength
    FRL =  block.InputPort(2).Data;
    % Aspertate level
    Asp =  block.DialogPrm(4).Data;

    % Here we define the chemotaxis model to take (currently only 'spiro' and 'mello')
    chemotaxisModel = block.DialogPrm(1).Data;
    % Here we define the variable which is coupled to PIF3 or PhyB.
    % Valid values are \in  {'CheR', 'CheB', 'CheY', 'CheZ'}
    controlledCheSpeciesName = block.DialogPrm(2).Data;
    % Is the Che protein fused to PhyB or to PIF3
    % 1...fused to PhyB
    % 0...fused to PIF3
    cheSpeciesAttachedToPhyB = block.DialogPrm(3).Data - 1;
    
    p = getChangedParameters(block);
    
    % Get derivatives from model
    t = block.CurrentTime;
    x = block.ContStates.Data;
        
    % Run simulation step
    block.Derivatives.Data = molecularModel(t, x, chemotaxisModel, controlledCheSpeciesName, cheSpeciesAttachedToPhyB, 'Asp', Asp, 'RL', RL, 'FRL', FRL, 'p', p);
    %molecularModel(t, x, Asp, RL, FRL, controlledCheSpeciesName, cheSpeciesAttachedToPhyB, chemotaxisModel);
     
%endfunction
    
function p = getChangedParameters(block)
    % Here we define the chemotaxis model to take (currently only 'spiro' and 'mello')
    chemotaxisModel = block.DialogPrm(1).Data;
    % Here we define the variable which is coupled to PIF3 or PhyB.
    % Valid values are \in  {'CheR', 'CheB', 'CheY', 'CheZ'}
    controlledCheSpeciesName = block.DialogPrm(2).Data;
    % Is the Che protein fused to PhyB or to PIF3
    % 1...fused to PhyB
    % 0...fused to PIF3
    cheSpeciesAttachedToPhyB = block.DialogPrm(3).Data - 1;
    % CheX-protein (CheX=controlledCheSpeciesName) concentration.
    CheX = block.DialogPrm(5).Data;
    % Anker protein concentration
    AnkerProt = block.DialogPrm(6).Data;
    % Anker concentration
    Anker = block.DialogPrm(7).Data;
    
    p = molecularModel('parameters', chemotaxisModel, controlledCheSpeciesName, cheSpeciesAttachedToPhyB);
    p.AnkerProt_tot = AnkerProt;
    p.Anker_tot = Anker;
    switch controlledCheSpeciesName
        case 'CheR'
        	p.R_tot = CheX;
        case 'CheB'
            p.B_tot = CheX;
        case 'CheY'
            p.Y_tot = CheX;
        case 'CheZ'
            p.Z_tot = CheX;
        otherwise
            error('ETH:NotSupportedSpecies', 'Species not supported/implemented.');
    end
         
%endfunction

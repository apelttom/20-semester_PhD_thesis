function xp = molecularModel(varargin)
% The complete molecular model of the light activated chamotaxis. Consists
% of two separate models, one for the chemotaxis pathway and one for the
% light activation. Both models are connected by sharing the same states
% for the Che proteins.
%
% Usage:
% -----------------------
% xp = molecularModel(t, x, chemotaxisModel, cheSpecies, attachedToPhyBOrPIF3);
%           Simulates the chosen model. Assumes RL=FRL=Asp=0 if not set via the parametrization (see below).
% x0 = molecularModel('IC', chemotaxisModel, cheSpecies, attachedToPhyBOrPIF3)
%           Returns a valid (but not necessarily equilibrated) set of
%           initial conditions.
% p = molecularModel('parameters', chemotaxisModel, cheSpecies, attachedToPhyBOrPIF3)
%           Returns the parameter structure for the chosen model.
% molecularModel(..., parameterName1, parameterValue1, parameterName2, parameterValue2, ...)
%           Sets some additional parameters for the model (see below).
%
%
% Standard Parameters:
% -----------------------
% t                     ... current time in integration.
% x                     ... current state.
% p                     ... parameter structure.
% chemotaxisModel       ... The chamotaxis model to use:
%                           {'spiro', 'mello'}.
% cheSpecies            ... Name of Che protein attached to PIF3/CheB:
%                           {'CheR', 'CheB', 'CheY', 'CheZ'}.
% attachedToPhyBOrPIF3  ... 1 if Che species is attached to PhyB, 
%                           0 if attached to PIF3.
%
% Additional Parameters:%
% parameterName         | parameterValue    | Description
% -------------------------------------------------------------------------
% 'Asp'                 | [0, inf)          | The current Asp concentration
% 'AspFunc'             | @function         | A function handle of the type
%                       |                   | Asp = func(t) returning the
%                       |                   | Asp concentration for time t.
% 'RL'                  | {0, 1}            | 1 if RL is on, 0 otherwise.
% 'FRL'                 | {0, 1}            | 1 if FRL is on, 0 otherwise.
% 'RLFunc'              | @function         | A function handle of the type
%                       |                   | RL = func(t) returning the
%                       |                   | RL value for time t.
% 'FRLFunc'             | @function         | A function handle of the type
%                       |                   | FRL = func(t) returning the
%                       |                   | FRL value for time t.
% 'p'                   | struct            | A structure containing the
%                       |                   | parameter values for the
%                       |                   | model (standard parameters
%                       |                   | for the model can be obtained
%                       |                   | with the corresponding
%                       |                   | function call.


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

%% Get standard arguments and type of function call
if ischar(varargin{1})
    % Special calls (e.g. for initial conditions)
    type = varargin{1};
    chemotaxisModel = varargin{2};
    attachedCheSpecies = varargin{3};
    cheSpeciesAttachedToPhyB = varargin{4};
    parameterIdx = 5;
else
    % Normal simulation
    type = 'standard';
    t = varargin{1};
    x = varargin{2};
    chemotaxisModel = varargin{3};
    attachedCheSpecies = varargin{4};
    cheSpeciesAttachedToPhyB = varargin{5};
    parameterIdx = 6;
end

%% Get indices of Che proteins fused to PIF3
switch attachedCheSpecies
    case 'CheR'
        idxOfSpecies = 1;
    case 'CheB'
        idxOfSpecies = [2, 3];
    case 'CheY'
        idxOfSpecies = [4, 5];
    case 'CheZ'
        idxOfSpecies = 6;
    otherwise
        error('ETH:NotSupportedSpecies', 'Species not supported/implemented.');
end

%% Get chemotaxis model as pointer and the respective parameter structure
if strcmpi(chemotaxisModel, 'spiro')
    chemoModel = @spiro1997;
    p = spiro1997_getParameters(attachedCheSpecies);
elseif strcmpi(chemotaxisModel, 'mello')
    chemoModel = @mello2003;
    p = mello2003_getParameters(attachedCheSpecies);
else
    error('ETH:UnsuportedChemotaxisModel', 'Chemotaxis model is (yet) not supported.');
end

%% Return parameter structure if requested
if strcmpi(type, 'parameters')
    xp = p;
    return;
end

%% Get light model as pointer
if cheSpeciesAttachedToPhyB
    lightModel = @lightActivationPhyB;
else
    lightModel = @lightActivationPIF3;
end

%% Get additional parametrization
RL = 0;
FRL= 0;
Asp = 0;
while parameterIdx + 1 <= nargin
    parameterName = lower(varargin{parameterIdx});
    parameterValue = varargin{parameterIdx + 1};
    switch parameterName
        case 'asp'
            Asp = parameterValue;
        case 'aspfunc'
            Asp = parameterValue(t);
        case 'rl'
            RL = parameterValue;
        case 'rlfunc'
            RL= parameterValue(t);
        case 'frl'
            FRL = parameterValue;
        case 'frlfunc'
            FRL= parameterValue(t);
        case 'p'
            p = parameterValue;
        otherwise
            disp(sprintf('Parameter with name %s unknown!', parameterName));
    end
    parameterIdx = parameterIdx + 2;
end


%% Get initial condition and sizes of models
[x0_chemo, che_chemo] = chemoModel(p);
[x0_light, che_light] = lightModel(p);

n_chemo = length(x0_chemo);
n_light = length(x0_light);
n_cheProt_num = size(che_chemo, 1);
n_cheProt_types = size(che_light, 2);

%% Return initial conditions if requested
if strcmpi(type, 'IC')
    cheProteins = [che_chemo, zeros(n_cheProt_num, n_cheProt_types-1)];
    xp = [x0_chemo(:); x0_light(:); cheProteins(:)];
    return;
end

%% Separate states in different kinds.
% States exclusively used by chemotaxis model.
x_chemo = x(1:n_chemo);
% States exclusively used by light model.
x_light = x(1 + n_chemo : n_chemo + n_light);
% States used by both models. The rows represent the different Che
% species (but possibly two species represent the same protein in the
% phosphorylated and unphosphorylated state), columns represent the
% different activation levels. The number and meaning of the columns change
% depending on which light model is chosen. For a documentation please
% refer to the respective light model.
cheProteins = reshape(x(1 + n_chemo + n_light: end), n_cheProt_num, n_cheProt_types);
cheProteins_active = cheProteins(idxOfSpecies, :);

%% Run Chemotaxis model
[xp_spiro, dCheProteins] = chemoModel(t, x_chemo, cheProteins, p, Asp);

%% Run light model on attached species
[xp_light, dCheProteins_active] = lightModel(t, x_light, cheProteins_active, p, RL, FRL);

%% Add changes to the chemotaxis proteins in a linear fashion 
% (if time step is small enough, the both models are effectively linearized).
dCheProteins(idxOfSpecies, :) = dCheProteins(idxOfSpecies, :) + dCheProteins_active;

%% Return change in state.
xp = [xp_spiro(:); xp_light(:); dCheProteins(:)];




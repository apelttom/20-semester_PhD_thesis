%%
% Model of chemotaxis in E. coli
% Based on Barkai & Leibler (1997): "Robustness in simple biochemical
% networks"
%%
% This is the main file of the model, using the same initial conditions as
% the ones used in the paper.
% The output is the System activity, responsible for the umbling frequency
% of the bacterium.
% Figure 1 represents the activity of the system from the 'perfect
% adaptation' point of view, when subject to successive additions/removals
% of ligand, after each 20 mins.
% It reproduces Figure2 from Barkai & Leibler (1997).


% Copyright 2010 Simona Constantinescu, Christoph Hold
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

%%
m=5; %number of methylation states
n_complex = 10000;  % # receptor complexes/cell
n_b = 2000;   % # CheB molecules/cell
n_r = 200;    % # CheR molecules/cell

v_cell = 1.4e-15; % [litre]

N_A = 6.022e23; % Avogadro constant [1/mol]

c_b = n_b/N_A/v_cell; % [mol/l]
c_b = c_b * 1e6; % [umol/l]

c_r = n_r/N_A/v_cell; % [mol/l]
c_r = c_r * 1e6; % [umol/l]

c_complex = n_complex/N_A/v_cell; % [mol/l]
c_complex = c_complex * 1e6; % [umol/l]

c_l = 1; %[umol/l]

% initial concentrations of b(free), r(free) and complexes
y0 = [c_b, c_r, c_complex, zeros(1,25)]; 

p(1) = c_b; %total concentration of CheB (free + bound)
p(2) = c_r; %total concentration of CheR (free + bound)
p(3) = c_l; %initial concentration of ligand

M = eye(length(y0));
M(1,1) = 0;

ode_options = odeset('Mass',M,'MassSingular','yes');

[t1, y1] = ode15s(@chemotaxis_m,[0:1200], y0, ode_options, p);


%figure()

% plot(t1,y1(:,2+sub2ind([2,m,3],2,1,1)),'-o',t1,y1(:,2+sub2ind([2,m,3],2,2,1)),'-o',...
%     t1,y1(:,2+sub2ind([2,m,3],2,3,1)),'-o',t1,y1(:,2+sub2ind([2,m,3],2,4,1)),'-o',...
%     t1,y1(:,2+sub2ind([2,m,3],2,5,1)),'-o',...
%     t1,y1(:,2+sub2ind([2,m,3],1,1,1)),t1,y1(:,2+sub2ind([2,m,3],1,2,1)),...
%     t1,y1(:,2+sub2ind([2,m,3],1,3,1)),t1,y1(:,2+sub2ind([2,m,3],1,4,1)),...
%     t1,y1(:,2+sub2ind([2,m,3],1,5,1))); 
% legend ('E0u','E1u','E2u','E3u','E4u','E1o','E2o','E3o','E4o','E5o');
% 
% title ('Temporal evolution of the individual form of the receptor comple E');
% xlabel('Time (seconds)');
% ylabel('Concentration ([umol/l]');


% hold on

y0 = y1(end,:);
 
p(3) = 0; % changing c_l
[t2, y2] = ode15s(@chemotaxis_m,[1200:2400], y0, ode_options, p);
 
% plot(t2,y2(:,2+sub2ind([2,m,3],2,1,1)),'-o',t2,y2(:,2+sub2ind([2,m,3],2,2,1)),'-o',...
%     t2,y2(:,2+sub2ind([2,m,3],2,3,1)),'-o',t2,y2(:,2+sub2ind([2,m,3],2,4,1)),'-o',...
%     t2,y2(:,2+sub2ind([2,m,3],2,5,1)),'-o',...
%     t2,y2(:,2+sub2ind([2,m,3],1,1,1)),'-',t2,y2(:,2+sub2ind([2,m,3],1,2,1)),...
%     t2,y2(:,2+sub2ind([2,m,3],1,3,1)),'-',t2,y2(:,2+sub2ind([2,m,3],1,4,1)),...
%     t2,y2(:,2+sub2ind([2,m,3],1,5,1))); 
% 
% hold on

y0 = y2(end,:);
 
p(3) = 1; % changing c_l
[t3, y3] = ode15s(@chemotaxis_m,[2400:3600], y0, ode_options, p);
 
% plot(t3,y3(:,2+sub2ind([2,m,3],2,1,1)),'-o',t3,y3(:,2+sub2ind([2,m,3],2,2,1)),'-o',...
%     t3,y3(:,2+sub2ind([2,m,3],2,3,1)),'-o',t3,y3(:,2+sub2ind([2,m,3],2,4,1)),'-o',...
%     t3,y3(:,2+sub2ind([2,m,3],2,5,1)),'-o',...
%     t3,y3(:,2+sub2ind([2,m,3],1,1,1)),'-',t3,y3(:,2+sub2ind([2,m,3],1,2,1)),'-',...
%     t3,y3(:,2+sub2ind([2,m,3],1,3,1)),'-',t3,y3(:,2+sub2ind([2,m,3],1,4,1)),...
%     t3,y3(:,2+sub2ind([2,m,3],1,5,1))); 
% 
% hold on

y0 = y3(end,:);
 
p(3) = 0; % changing c_l
[t4, y4] = ode15s(@chemotaxis_m,[3600:4800], y0, ode_options, p);
 
% plot(t4,y4(:,2+sub2ind([2,m,3],2,1,1)),'-o',t4,y4(:,2+sub2ind([2,m,3],2,2,1)),'-o',...
%     t4,y4(:,2+sub2ind([2,m,3],2,3,1)),'-o',t4,y4(:,2+sub2ind([2,m,3],2,4,1)),'-o',...
%     t4,y4(:,2+sub2ind([2,m,3],2,5,1)),'-o',...
%     t4,y4(:,2+sub2ind([2,m,3],1,1,1)),'-',t4,y4(:,2+sub2ind([2,m,3],1,2,1)),'-',...
%     t4,y4(:,2+sub2ind([2,m,3],1,3,1)),'-',t4,y4(:,2+sub2ind([2,m,3],1,4,1)),...
%     t4,y4(:,2+sub2ind([2,m,3],1,5,1))); 
% 
% hold on

y0 = y4(end,:);

p(3) = 3; % changing c_l
[t5, y5] = ode15s(@chemotaxis_m,[4800:6000], y0, ode_options, p);

% plot(t5,y5(:,2+sub2ind([2,m,3],2,1,1)),'-o',t5,y5(:,2+sub2ind([2,m,3],2,2,1)),'-o',...
%     t5,y5(:,2+sub2ind([2,m,3],2,3,1)),'-o',t5,y5(:,2+sub2ind([2,m,3],2,4,1)),'-o',...
%     t5,y5(:,2+sub2ind([2,m,3],2,5,1)),'-o',...
%     t5,y5(:,2+sub2ind([2,m,3],1,1,1)),'-',t5,y5(:,2+sub2ind([2,m,3],1,2,1)),'-',...
%     t5,y5(:,2+sub2ind([2,m,3],1,3,1)),'-',t5,y5(:,2+sub2ind([2,m,3],1,4,1)),...
%     t5,y5(:,2+sub2ind([2,m,3],1,5,1))); 
% 
%  
% hold on
 
y0 = y5(end,:);
 
p(3) = 0; % changing c_l
[t6, y6] = ode15s(@chemotaxis_m,[6000:7200], y0, ode_options, p);

% plot(t6,y6(:,2+sub2ind([2,m,3],2,1,1)),'-o',t6,y6(:,2+sub2ind([2,m,3],2,2,1)),'-o',...
%     t6,y6(:,2+sub2ind([2,m,3],2,3,1)),'-o',t6,y6(:,2+sub2ind([2,m,3],2,4,1)),'-o',...
%     t6,y6(:,2+sub2ind([2,m,3],2,5,1)),'-o',...
%     t6,y6(:,2+sub2ind([2,m,3],1,1,1)),'-',t6,y6(:,2+sub2ind([2,m,3],1,2,1)),'-',...
%     t6,y6(:,2+sub2ind([2,m,3],1,3,1)),'-',t6,y6(:,2+sub2ind([2,m,3],1,4,1)),...
%     t6,y6(:,2+sub2ind([2,m,3],1,5,1))); 
% 
%  
% hold on

y0 = y6(end,:);
 
p(3) = 5; % changing c_l
[t7, y7] = ode15s(@chemotaxis_m,[7200:8400], y0, ode_options, p);
 

y0 = y7(end,:);
 
p(3) = 0; % changing c_l
[t8, y8] = ode15s(@chemotaxis_m,[8400:9600], y0, ode_options, p);
 
y0 = y8(end,:);
 
p(3) = 7; % changing c_l
[t9, y9] = ode15s(@chemotaxis_m,[9600:11000], y0, ode_options, p);
 
y0 = y9(end,:);
 
p(3) = 0; % changing c_l
[t10,y10] = ode15s(@chemotaxis_m,[11000:12200], y0, ode_options, p);
 


% calculate the activity of the system
% active positions: 1-8; sub2ind([2,m,3],1,1,1) - sub2ind([2,m,3],2,4,1)
% add 2, because in output vector first 2 positions are R and B

% alpha: probabilities for active state: 1 occupied; 2 unoccupied
alpha = [0,0,0.1,0.5,1; ... % occupied
         0,0.1,0.5,0.75,1]; % unoccupied

    
a1 = 0;
for j=1:2
    for i=1:m
        a1 = a1 + alpha(j,i) * y1(:,2+sub2ind([2,m,3],j,i,1));
    end
end;

figure()
plot (t1,a1);
title('The activity of the system over time for successive additions/removals of input ligand');

hold on

a2 = 0;
for j=1:2
    for i=1:m
        a2 = a2 + alpha(j,i) * y2(:,2+sub2ind([2,m,3],j,i,1));
    end
end;
plot (t2,a2);
hold on

a3 = 0;
for j=1:2
    for i=1:m
        a3 = a3 + alpha(j,i) * y3(:,2+sub2ind([2,m,3],j,i,1));
    end
end;
plot (t3,a3);
hold on

a4 = 0;
for j=1:2
    for i=1:m
        a4 = a4 + alpha(j,i) * y4(:,2+sub2ind([2,m,3],j,i,1));
        
    end
end;

plot (t4,a4);
hold on

a5 = 0;
for j=1:2
    for i=1:m
        a5 = a5 + alpha(j,i) * y5(:,2+sub2ind([2,m,3],j,i,1));
    end
end;
plot (t5,a5);
hold on

a6 = 0;
for j=1:2
    for i=1:m
        a6 = a6 + alpha(j,i) * y6(:,2+sub2ind([2,m,3],j,i,1));
    end
end;
plot (t6,a6);
hold on

a7 = 0;
for j=1:2
    for i=1:4
        a7 = a7 + alpha(j,i) * y7(:,2+sub2ind([2,m,3],j,i,1));
    end
end;
plot (t7,a7);
hold on

a8 = 0;
for j=1:2
    for i=1:4
        a8 = a8 + alpha(j,i) * y8(:,2+sub2ind([2,m,3],j,i,1));
    end
end;
plot (t8,a8);
hold on

a9 = 0;
for j=1:2
    for i=1:4
        a9 = a9 + alpha(j,i) * y9(:,2+sub2ind([2,m,3],j,i,1));
    end
end;
plot (t9,a9);
hold on

a10 = 0;
for j=1:2
    for i=1:4
        a10 = a10 + alpha(j,i) * y10(:,2+sub2ind([2,m,3],j,i,1));
    end
end;

%plot (t10,a10);

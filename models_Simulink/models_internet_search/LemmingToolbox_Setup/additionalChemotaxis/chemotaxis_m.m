%%
% Model of chemotaxis in E. coli
% Based on Barkai & Leibler (1997): "Robustness in simple biochemical
% networks"
%%
% This file reproduces the ODE system of the rates of change of receptor 
% complex species as presented in Barkai & Leibler (1997)

% Copyright 2010 Simona Constantinescu
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

function dy = chemotaxis_m(t,y,p)

%--------------------------------------------------------------------------
% general parameters

m = 5; % number of methylation sites (0 to m-1)
n = 2*(3*m-2); %number of equations 

b = y(1); % concentration of free CheB 
r = y(2); % concentration of free CheR

% (initial) concentrations of complexes; the 0 elements are spurious terms
% that appear artificially when the equations are generated 


Em = [y(3:3+sub2ind([2,m,3],1,m,2)-2); 0; 0; 0; 0; y(3+sub2ind([2,m,3],1,m,2)-1:end)]; 
%Em = [y(3:3+sub2ind([2,m,3],1,m,2)-2), 0, 0, 0, 0, y(3+sub2ind([2,m,3],1,m,2)-1:end)]; 

b_total = p(1); %total concentration of B
r_total = p(2); %total concentration of R
l = p(3); %concentration of ligand


% alpha: probabilities for active state
alpha = [0,0,0.1,0.5,1; ... % occupied (1)
         0,0.1,0.5,0.75,1]; % unoccupied (2)       
   
%--------------------------------------------------------------------------

% rate constants
k_l = 1000;  % [1/s/uM] binding of the ligand
k_l_minus = 1000; % [1/s] unbinding of the ligand
a_b = 800; % [1/s/uM] association rate of CheB to the active/inactive receptor complex
d_b = 1000; % [1/s] dissociation rate of CheB from the active/inactive receptor complex
k_r = 0.1; % [1/s] E_mR -> E_m+1
a_r = 80; % [1/s/uM] association rate of CheR to the active receptor
d_r = 100; % [1/s] dissociation rate of CheR from the active/inactive receptor complex
a_r_prime = 80; % [1/s/uM] association rate of CheR to the inactive receptor
k_b = 0.1; % [1/s] E_m+1B -> E_m

%--------------------------------------------------------------------------

% differential equations

% ER and EB are the same for all methylation sites
% E (free) has different expression for first and last methylation site
% E goes from 0 to m-1 in the paper (1 to m here)
% ER goes from 0 to m-2 in the paper (1 to m-1 here)
% EB goes from 1 to m-1 in the paper (2 to m here)

dEm = zeros(1,2*m*3);

for j=1:2 % 1 occupied 2 unoccupied
    for i=1:m % methylation site
        for k = 1:3 %1 free; 2 with R; 3 with B
            
            if i>1 && i<m
                dEm(sub2ind([2,m,3],j,i,k)) =...
                    power(-1,j) * (- k_l * Em(sub2ind([2,m,3],2,i,k))*l +  k_l_minus * Em(sub2ind([2,m,3],1,i,k)))... % ligand
                    + (1-(k==2))*power(-1,(k==1)+1)*(-a_b*alpha(j,i)*Em(sub2ind([2,m,3],j,i,1))*b+ d_b*Em(sub2ind([2,m,3],j,i,3)) ...
                    + (k==1)* k_r * Em(sub2ind([2,m,3],j,i-1,2)) + (k==3)*k_b * Em(sub2ind([2,m,3],j,i,3)))...
                    + (1-(k==3))*power(-1,(k==1)+1)*(a_r*alpha(j,i)*Em(sub2ind([2,m,3],j,i,1))*r - a_r_prime*(1-alpha(j,i))*Em(sub2ind([2,m,3],j,i,1))*r + d_r*Em(sub2ind([2,m,3],j,i,2))...
                    + (k==1)*k_b * Em(sub2ind([2,m,3],j,i+1,3)) + (k==2)*k_r*Em(sub2ind([2,m,3],j,i,2)));
                
            end
                        
            if i==1 %don't care about k=3, EB1 will be zero anyway
                
                dEm(sub2ind([2,m,3],j,i,k)) =...
                    power(-1,j) * (- k_l * Em(sub2ind([2,m,3],2,i,k))*l +  k_l_minus * Em(sub2ind([2,m,3],1,i,k)))...% ligand
                    + power(-1,(k==1)+1)*(a_r*alpha(j,i)*Em(sub2ind([2,m,3],j,i,1))*r - a_r_prime*(1-alpha(j,i))*Em(sub2ind([2,m,3],j,i,1))*r + d_r*Em(sub2ind([2,m,3],j,i,2))...
                    +(k==2)* k_r *Em(sub2ind([2,m,3],j,i,2)) + (k==1)* k_b * Em(sub2ind([2,m,3],j,i+1,3)));              
            end
                
            if i==m %don't care about k=2, ERm will be zero anyway              

                dEm(sub2ind([2,m,3],j,i,k)) =...
                    power(-1,j) * (- k_l * Em(sub2ind([2,m,3],2,i,k))*l +  k_l_minus * Em(sub2ind([2,m,3],1,i,k)))...% ligand
                    + power(-1,(k==1)+1)*(-a_b*alpha(j,i)*Em(sub2ind([2,m,3],j,i,1))*b+ d_b*Em(sub2ind([2,m,3],j,i,3))...
                    + (k==1)* k_r * Em(sub2ind([2,m,3],j,i-1,2)) + (k==3)*k_b * Em(sub2ind([2,m,3],j,i,3)));
            end  
                        
                    
       end;
    end
end;


% algebraic expressions for CheB

db2 = 0; 
for j=1:2
    for i=2:m
        db2 = db2 + Em(sub2ind([2,m,3],j,i,3));
    end
end

db = b + db2 - b_total;
dr = 0; % CheR stays constant throughout the simulation

% dr2 = 0; 
% for j=1:2
%     for i=1:m-1
%     dr2 = dr2 + Em(sub2ind([2,m,3],j,i,2));
%     end
% end
% dr = r + dr2 - r_total;

dy = [db, dr, dEm(1:sub2ind([2,m,3],1,m,2)-1) , dEm(sub2ind([2,m,3],2,1,3)+1:2*m*3)]';

end
  
   
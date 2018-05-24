function [A, B, C, D] = LM1SIP(Mc, Mb, Lb, Kt, Bc, Bb)
% LM1SIP calculates the model of the 1-stage linear motor inverse pendulum
% function [A, B, C, D] = LM1SIP(Mc, Mb, Lb, Kt)
% Mc: mass of the cart (Kg)
% Mb: mass of the pendulum bar (Kg)
% Lb: half length of the pendulum bar (m)
% Kt: torque constant of the system (N/V)
% [A, B, C, D] are the system matrices of the system with the state [x, xdot, a, adot], 
% where x is the position of the cart and a is the angle of the pendulum bar, 
% and xdot and adot are the cart velocity and bar angular velocity respectively
% The interested outputs of the system are x and a
% The input to the system is the voltage to the driver
% (Mc + Mb) ddx + Bc dx - Mb Lb dda = F
% (J + Mb Lb Lb ) dda + Bb da - Mb Lb ddx - Mb g L a = 0
% F = Kt u, J = Mb Lb Lb / 3

if nargin < 1
    %% U-Type
%     Mc = 3.19;
%     Mb = 0.105;
%     Lb = 0.25;
%     Kt = 0.84 * 15;
%     Bb = 0;
%     Bc = 0;
    %% C-Type
%     Mc = 1.6;
%     Mb = 0.1;
%     Lb = 0.2;
%     Kt = 0.51 * 10;
%     Bb = 0;
%     Bc = 0;
    %% C-Type New
    Mc = 1.42;
    Mb = 0.12;
    Lb = 0.188;
    Kt = 0.51 * 10;
    Bb = 0;
    Bc = 0;
else
    if nargin < 4
        help LM1SIP;
        fprintf('-->Not enough input parameters\n');
        return;
    end
    if nargin < 5
        Bc = 0;
        Bb = 0;
    end
    if nargin < 6
        Bb = 0;
    end

    if ~(Mc>0 && Mb>0 && Lb>0 && Kt>0 && Bc>=0 && Bb>=0)
        fprintf('-->Inputs must be positive real numbers\n');
        return;
    end

end

g=9.80665;
J = Mb * Lb * Lb / 3;

A = [0 1 0 0;
    0 -(J+Mb*Lb^2)*Bc/(J*(Mc+Mb)+Mc*Mb*Lb^2) Mb^2*g*Lb^2/(J*(Mc+Mb)+Mc*Mb*Lb^2) Mb*Lb*Bb/(J*(Mc+Mb)+Mc*Mb*Lb^2);
    0 0 0 1;
    0 -Mb*Lb*Bc/(J*(Mc+Mb)+Mc*Mb*Lb^2) Mb*g*Lb*(Mc+Mb)/(J*(Mc+Mb)+Mc*Mb*Lb^2) (Mc+Mb)*Bb/(J*(Mc+Mb)+Mc*Mb*Lb^2)];

B = [0;
    (J+Mb*Lb^2)/(J*(Mc+Mb)+Mc*Mb*Lb^2);
     0;
     Mb*Lb/(J*(Mc+Mb)+Mc*Mb*Lb^2)];
B = B * Kt;

C = [1 0 0 0;
     0 0 1 0];
 
D = [0;
     0];

if nargout < 1
    A
    B
    C
    D
end
 
 
    

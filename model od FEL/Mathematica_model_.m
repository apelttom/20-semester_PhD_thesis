clc;clear;
% IM_dq_matrix_model
    clc;clear;
    Rs = 0.847;
    Rr = 0.6648;
    Lls = 8.031e-3;
    Llr = 6.571e-3;
    Lm = 249.304e-3;
    Lr = Lm+Llr;
    Ls = Lm+Lls;
    J = 0.043;
    pp = 2;
    tauR = Lr/Rr;
% REGULATION
% Hysteresis regulator
    h_Mem = 5;      %Torque hysteresis band    
    h_Psi_s = 0.01; %Flux hysteresis band  
    cur_lim=80;
    
% Sampling
    Ts=25e-6;	%voltage sampling
    Tss=500e-6; %speed sampling
%Speed loop
    Kp = 7;
    Ti = 2.5;
    Ki = Kp/Ti;
    Kt = Ki/2;

    ulim = 600;
% Rotat. Mat
    M = [Ls 0 Lm 0;...
        0 Ls 0 Lm;...
        Lm 0 Lr 0;...
        0 Lm 0 Lr];
    MInv = inv(M);

%Initial conditions
    Isd_0=0.001;
    Isq_0=0.001;
    Ird_0=0.001;
    Irq_0=0.001;


    Psi_dq_0 = M * [Isd_0; Isq_0; Ird_0; Irq_0];
    Psi_sd_0 = Psi_dq_0(1);
    Psi_sq_0 = Psi_dq_0(2);      
    Psi_rd_0 = Psi_dq_0(3);
    Psi_rq_0 = Psi_dq_0(4);

% Regulators
    sigma = 1-Lm^2/(Lr*Ls)
    Lsigma=sqrt(Ls*Lr-Lm*Lm);
% Voltage_Vector_Lookup
% Section I
    Voltage(:,:,1) = [0 1 0 0 1 1;...
                      0 1 1 1 0 0;...
                      0 1 0 1 0 1];
% Section II
    Voltage(:,:,2) = [1 0 1 0 1 0;...
                      1 0 1 1 0 0;...
                      1 0 0 0 1 1];
% Section III
    Voltage(:,:,3) = [0 1 1 1 0 0;...
                      0 1 0 1 0 1;...
                      0 1 0 0 1 1];
% Section IV
    Voltage(:,:,4) = [1 0 1 1 0 0;...
                      1 0 0 0 1 1;...
                      1 0 1 0 1 0];
% Section V
    Voltage(:,:,5) = [0 1 0 1 0 1;...
                      0 1 0 0 1 1;...
                      0 1 1 1 0 0];
% Section VI              
    Voltage(:,:,6) = [1 0 0 0 1 1;...
                      1 0 1 0 1 0;...
                      1 0 1 1 0 1];
        
              
% TRACK DATA
    load('Track_data');
    alpha = [alfa 0];
    speed = speedOptim;
    
% DC Link filter
    Cf = 1000e-6;
    Lf = 1e-6;
    Rf = 2000;
% Power reduction
    reduction=2;
    
% BATTERY
% Battery equivalent circuit
    SoC = [1 0.884 0.769 0.653 0.537 0.421 0.306 0.190 0.074 0];
    Uoc = [4.19 4.06 3.93 3.86 3.8 3.76 3.72 3.6 3.43 3.05];
    R0  = [73 65 74 83 68 65 65 61 76 87].*1e-4;
    RT1 = [9.76 15 11 5.83 11 11 16 44 53 102].*1e-4;
    CT1 = [34.2 88.9 129.8 148.6 139.3 123.3 69.9 25.5 15.1 10.5];
    RT2 = [24 20 16 22 13 16 22 22 47 153].*1e-4;
    CT2 = [754.4 643.3 977.4 708.0 1119.7 970.2 733.8 708.0 359.8 170.7];
    Q0 = 4.8*3600; %Ah capacity * hour in seconds
    
% Battery pack
    n_serial = 162;
    n_paralel = 10;
    

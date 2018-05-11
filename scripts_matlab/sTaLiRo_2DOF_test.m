% This is a script for verification a MTL specification of
% Two Degree-of-Freedom PID Control for Setpoint Tracking using 
% S-TaLiRo tools 
% For more information about the model see https://www.mathworks.com/help/simulink/examples/two-degree-of-freedom-pid-control-for-setpoint-tracking.html

% (C) Tomas Apeltauer 2018 - Czech Technical University in Prague

clear 

cd('..')
cd('C:\apelttom\university\20-semester_PhD_thesis\simulink_myModels')

model = 'dc_pid_2dof';
% load heat30;
time = 50;
cp_array = 4;
input_range = [25 60];
X0 = [];
phi = '[]p';
pred.str = 'p';
pred.A = [-1];
pred.b = [-20];

opt = staliro_options();
opt.runs = 1;
%opt.optim_params.n_tests = 100;

results = staliro(model,X0,input_range,cp_array,phi,pred,time,opt);

% figure(1)
% clf
% [T1,XT1,YT1,IT1] = SimSimulinkMdl(model,X0,input_range,cp_array,results.run(1).bestSample,time,opt);


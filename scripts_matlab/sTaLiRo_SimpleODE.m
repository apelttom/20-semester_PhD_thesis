% This is a script for verification a MTL specification of
% Two Degree-of-Freedom PID Control for Setpoint Tracking using 
% S-TaLiRo tools 
% For more information about the model see https://www.mathworks.com/help/simulink/examples/two-degree-of-freedom-pid-control-for-setpoint-tracking.html

% (C) Tomas Apeltauer 2018 - Czech Technical University in Prague

clear 

cd('..')
cd('C:\apelttom\university\20-semester_PhD_thesis\models\complexity_10')

model = 'mySimpleODEwithInp1';
time = 9;
cp_array = 4;
input_range = [1 3];
X0 = [];
phi = '[]p';
pred.str = 'p';
pred.A = [-1];
pred.b = [-1];

opt = staliro_options();
opt.runs = 1;
%opt.optim_params.n_tests = 100;

results = staliro(model,X0,input_range,cp_array,phi,pred,time,opt);

figure(1)
clf
[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,X0,input_range,cp_array,results.run(1).bestSample,time,opt);

subplot(2,1,1)
plot(T1,XT1)
title('State trajectories')
subplot(2,1,2)
plot(T1,YT1)
title('Output Signal')
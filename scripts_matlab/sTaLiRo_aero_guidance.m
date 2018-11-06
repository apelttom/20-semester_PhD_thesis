% This is a script for verification a MTL specification of
% Two Degree-of-Freedom PID Control for Setpoint Tracking using 
% S-TaLiRo tools 
% For more information about the model see https://www.mathworks.com/help/simulink/examples/two-degree-of-freedom-pid-control-for-setpoint-tracking.html

% (C) Tomas Apeltauer 2018 - Czech Technical University in Prague

%clear 

cd('C:\MATLAB.R2017b\toolbox\simulink\simdemos\aerospace\')

model = 'aero_guidance';
time = 10;
cp_array = [2];
input_range = [3.141592653589793 3.141592653589793];
X0 = [];
phi = '[]p';
pred.str = 'p';
pred.A = [-1];
pred.b = [-1];

opt = staliro_options();
opt.runs = 1;
opt.n_workers = 1;
%opt.optim_params.n_tests = 100;

results = staliro(model,X0,input_range,cp_array,phi,pred,time,opt);

figure(1)
clf
[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,X0,input_range,cp_array,results.run(1).bestSample,time,opt);

% subplot(2,1,1)
% plot(T1,XT1)
% title('State trajectories')
% subplot(2,1,2)
% plot(T1,YT1)
% title('Output Signal')
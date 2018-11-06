% This is a script for verification a MTL specification of
% Fuel Rate Control Subsystem using S-TaLiRo tools 
% For more information about the model see https://www.mathworks.com/help/simulink/examples/two-degree-of-freedom-pid-control-for-setpoint-tracking.html

% (C) Tomas Apeltauer 2018 - Czech Technical University in Prague

%clear 

cd('C:\MATLAB.R2017b\toolbox\simulink\simdemos\automotive\fuelsys')

model = 'sldemo_fuelsys_sTaLiRo';
time = 50;
init_cond = [];
input_range = [10 20; 0 1; 0 1; 0 1; 0 1];
cp_array = [24 2 2 2 2];
X0 = [];
phi = '[]p';
pred.str = 'p';
pred.A = [1];
pred.b = [20];

opt = staliro_options();
opt.runs = 1;
%opt.optim_params.n_tests = 100;

fprintf('S-TaLiRo starting falsification at %s\n', datestr(now,'HH:MM:SS.FFF'))
tic;
results = staliro(model,X0,input_range,cp_array,phi,pred,time,opt);
toc;

fprintf('S-TaLiRo terminated at %s\n', datestr(now,'HH:MM:SS.FFF'))

% figure(1)
% clf
% [T1,XT1,YT1,IT1] = SimSimulinkMdl(model,X0,input_range,cp_array,results.run(1).bestSample,time,opt);
% 
% subplot(2,1,1)
% plot(T1,XT1)
% title('State trajectories')
% % subplot(2,1,1)
% % plot(IT1(:,1),IT1(:,2))
% % title('Input Signal')
% subplot(2,1,2)
% plot(T1,YT1)
% title('Output Signal')

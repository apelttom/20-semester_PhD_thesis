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
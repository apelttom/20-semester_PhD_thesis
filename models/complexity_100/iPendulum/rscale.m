function[Nbar]=rscale(A,B,C,D,K)
% Given the single-input linear system: 
%       .
% 		x = Ax + Bu
%   	y = Cx + Du
% and the feedback matrix K,
% 
% the function rscale(A,B,C,D,K) finds the scale factor N which will 
% eliminate the steady-state error to a step reference 
s = size(A,1);
Z = [zeros([1,s]) 1];
N = inv([A,B;C,D])*Z';
Nx = N(1:s);
Nu = N(1+s);
Nbar=Nu + K*Nx;

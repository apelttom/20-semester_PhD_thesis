function K = LM1SLQR(A, B, Q, R, N)
% LM1SLQR calculates the LQR controller of the given 1-stage inverse
% pendulum

if nargin < 1    
    %% U-Type pitch: 0.032/16000
%     Q11 = 1500; 
%     Q22 = 0;
%     Q33 = 1500;
%     Q44 = 0;
    %% C-Type  pitch: 0.048/10000 without iron, 0.01/10000 with iron
    Q11 = 2000; 
    Q22 = 200;
    Q33 = 100;
    Q44 = 0;
    Q=[Q11 0 0 0;
       0 Q22 0 0;
       0 0 Q33 0;
       0 0 0 Q44];
   
%     R = 2;
    R = 5;
    
    N = 0;
    
    [A, B, C, D] = LM1SIP;
    
end

K = lqr(A,B,Q,R,N);

%  simulation
Ac = [(A-B*K)]; Bc = [B]; Cc = [C]; Dc = [D];
System=ss(Ac,Bc,Cc,Dc);
po=pole(System)

T=0:0.005:5;
U=0.1*ones(size(T));
Cn=[1 0 0 0]; 
Nbar=rscale(A,B,Cn,0,K);
Bcn=[Nbar*B];
[Y,X]=lsim(Ac,Bcn,Cc,Dc,U,T);

plot(T,X(:,1),':');hold on;
plot(T,X(:,2),'-.');hold on;
plot(T,X(:,3),'.');hold on;
plot(T,X(:,4),'-');
legend('CartPos','CartSpd','PendAng','PendSpd');
grid on;

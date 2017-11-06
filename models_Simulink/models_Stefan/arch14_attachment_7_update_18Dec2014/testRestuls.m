mySeed = 2014;
rng(mySeed);
High = 81;
model = 'testHarness';
open testHarness;
num = 100;
ref = 14.7;
start_time = 3;
% model parameters
c1 = 0.41328
c2 = -0.366
c3 = 0.08979
c4 = -0.0337
c5 = 0.0001
c6 = 2.821
c7 = -0.05231
c8 = 0.10299
c9 = -0.00063
c10 = 1.0
c11 = 14.7
c12 = 0.9
c13 = 0.04
c14 = 0.14
% coefficients of polynomial approximations
c15 = 13.893
c16 = -35.2518
c17 = 20.7364
c18 = 2.6287
c19 = -1.592
c20 = -2.3421
c21 = 2.7799
c22 = -0.3273
% sensors and actuatorerror factor
c23 = 1.0
c24 = 1.0
c25 = 1.0
% simulation time
simTime = 30
%%
for en_speed = 2000:500:2000
    %%
    overshoot1 = zeros(num,1);
    undershoot1 = zeros(num,1);
    stime1 = zeros(num,1);
    overshoot2 = zeros(num,1);
    undershoot2 = zeros(num,1);
    stime2 = zeros(num,1);
    RMS = zeros(num, 1);
    
    for i = 1:num
        amplitude = randi(High);
        simOut = sim(model,'SaveTime','on','SaveOutput','on');
        t = simOut.get('tout');
        y = simOut.get('yout');
        u = y(:,3);
        y1 = y(:,1);
        y2 = y(:,2);
        [overshoot1(i),undershoot1(i),stime1(i)] = measure_settling_time(...
            t, u , 1, y1, ref, 3);
        [overshoot2(i),undershoot2(i),stime2(i)] = measure_settling_time(...
            t, u , 1, y2, ref, 3);
        RMS(i) = sqrt(sum(abs((y1-y2)).^2)/t(end));
    end
    fprintf('Results Report Engine Speed = %d\n', en_speed);
    fprintf('M1 overshoot = %f\n', max(overshoot1));
    fprintf('M2 overshoot = %f\n', max(overshoot2));
    fprintf('overshoot delta = %f \n', abs(max(overshoot1)-max(overshoot2))/max(overshoot1)*100);
    fprintf('M1 undershoot = %f\n', min(undershoot1));
    fprintf('M2 undershoot = %f\n', min(undershoot2));
    fprintf('undershoot delta = %f \n', abs(min(undershoot1)-min(undershoot2))/min(undershoot1)*100);
    fprintf('M1 settling time = %f\n', max(stime1));
    fprintf('M2 settling time = %f\n', max(stime2));
    fprintf('settling time delta = %f \n', abs(max(stime1)-max(stime2))/max(stime1))*100;
    fprintf('M1 and M2 RMS = %f\n', max(RMS));
 
    %%
end


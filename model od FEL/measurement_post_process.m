clc;clear;
load('track_measurement');
load('powers_measurement');
load('snezne_kratka_mer4_kp12');
load('snezne_kratka_mer4_yokogawa');

ty = linspace(1,200.3750-9,167)+2;
ty(22:69)=ty(22:69)-(27.0836-25.9367);
ty=transpose(ty);

filename = 'speed_control_sw_sim_comp';
fig=figure;

%subplot(2,1,2)
plot(ans.Time, ans.Data(:,3),'r',...
    ans.Time, ans.Data(:,1),'b');
xlim([0 200])
ylim([-10 30])
title('Track Snezne Kratka (Software simulatoin)','FontSize',14)
xlabel('Time (s)','FontSize',12)
ylabel('Speed (ms^{-1})','FontSize',12)
legend('Speed reference', 'EV speed')
grid on

print(fig,filename,'-dpng')
close(fig);


filename = 'speed_control_hw_sim_comp';
fig=figure;

%subplot(2,1,1)
plot(snezne_kratka_mer4_kp12.X.Data, snezne_kratka_mer4_kp12.Y(8).Data,'r',...
    snezne_kratka_mer4_kp12.X.Data, snezne_kratka_mer4_kp12.Y(4).Data,'b');
xlim([0 200])
ylim([-10 30])
title('Track Snezne Kratka (Hardware simulation)','FontSize',14)
xlabel('Time (s)','FontSize',12)
ylabel('Speed (ms^{-1})','FontSize',12)
legend('Speed reference', 'EV speed')
grid on

print(fig,filename,'-dpng')
close(fig);
%**************************************************************************
hw_en=cumsum(ty.*Pel);
subplot(2,1,1)
plot(ty,hw_en./3600.*4)
xlim([0 200])
title('Track Snezne Kratka (Hardware simulation)','FontSize',14)
xlabel('Time (s)','FontSize',12)
ylabel('Energy (kWh)','FontSize',12)
grid on

subplot(2,1,2)
plot(ans_2.Time, ans_2.Data(:,1)./3600.*4)
xlim([0 200])
title('Track Snezne Kratka (Software simulatoin)','FontSize',14)
xlabel('Time (s)','FontSize',12)
ylabel('Energy (kWh)','FontSize',12)
grid on

close();

%**************************************************************************
filename = 'torque_control_hw_sim_comp';
fig=figure;

%subplot(2,1,1)
plot(snezne_kratka_mer4_kp12.X.Data, snezne_kratka_mer4_kp12.Y(2).Data,'r',...
    ty, abs(Torque),'b')
xlim([0 200])
ylim([0 100])
title('Track Snezne Kratka (Hardware simulation)','FontSize',14)
xlabel('Time (s)','FontSize',12)
ylabel('Torque (Nm)','FontSize',12)
legend('Torque reference', 'Applied torque')
grid on
print(fig,filename,'-dpng')
close(fig);

filename = 'torque_control_sw_sim_comp';
fig=figure;
%subplot(2,1,2)
plot(ans_2.Time, abs(ans_2.Data(:,3)))
xlim([0 200])
ylim([0 100])
title('Track Snezne Kratka (Software simulatoin)','FontSize',14)
xlabel('Time (s)','FontSize',12)
ylabel('Torque (Nm)','FontSize',12)
grid on

print(fig,filename,'-dpng')
close(fig);


filename = 'speed_alpha_profile';
fig=figure;

subplot(2,1,1)
plot(ans.Data(:,2), ans.Data(:,3))
xlim([0 max(ans.Data(:,2))])
ylim([0 25])
title('Speed profile','FontSize',14)
xlabel('Distance (m)','FontSize',12)
ylabel('Speed (ms^{-1})','FontSize',12)
grid on

subplot(2,1,2)
plot(ans.Data(:,2), ans.Data(:,5))
xlim([0 max(ans.Data(:,2))])
ylim([-0.15 0.15])
title('Progile of the angle of inclination','FontSize',14)
xlabel('Distance (m)','FontSize',12)
ylabel('\alpha (rad)','FontSize',12)
grid on

print(fig,filename,'-dpng')
close(fig);




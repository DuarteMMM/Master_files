close all;
clear;

% First plot
t = 0:0.0000001:0.0005;

fs = 16000;

A1 = 1;
A2 = 1;

f1 = 6000;
f2 = 4000;

phi2 = 0;

x1 = A1 * sin(2*pi*f1*t);
x2 = A2 * sin(2*pi*f2*t+phi2);

xd = x2 .* x1;

xd_mean = mean(xd);

figure(1);
hold on;
grid minor;
grid on;
plot(t*1000, x1,'LineWidth',3.0);
plot(t*1000, x2,'LineWidth',3.0);
plot(t*1000, xd,'LineWidth',3.0);
xlabel('Time [ms]','fontsize',25);
ylabel('Amplitude','fontsize',25);
ax = gca;
ax.XTick=[0.1 0.2 0.3 0.4 0.5];
ylim([-1.1 1.1]);
title(["\fontsize{30}Different frequencies (f_1=6kHz>f_2=4kHz)"]);
set(gca,'FontSize',20);
legend({'x_1', 'x_2', 'x_D'},'Location','best')


% Second plot
t = 0:0.0000001:0.0005;

fs = 16000;

A1 = 1;
A2 = 1;

f1 = 4000;
f2 = 4000;

phi2 = 0;

x1 = A1 * sin(2*pi*f1*t);
x2 = A2 * sin(2*pi*f2*t+phi2);

xd = x2 .* x1;

xd_mean = mean(xd);


figure(2);
hold on;
grid minor;
grid on;
plot(t*1000, x1,'LineWidth',3.0);
plot(t*1000, x2,'LineWidth',3.0);
plot(t*1000, xd,'LineWidth',3.0);
xlabel('Time [ms]','fontsize',25);
ylabel('Amplitude','fontsize',25);
ax = gca;
ax.XTick=[0.1 0.2 0.3 0.4 0.5];
ylim([-1.1 1.1]);
title(["\fontsize{30}Same frequency (f_1=f_2=4kHz)"]);
set(gca,'FontSize',20);
legend({'x_1', 'x_2', 'x_D'},'Location','best')

% Third plot
f1 = 4000;
f2 = 4000;
phi2 = pi;

x1 = A1 * sin(2*pi*f1*t);

xd_mean_v = zeros(1, 7000);
phy_values = zeros(1,7000);
i=1;

for phy = 0:0.001:2*pi
    x2 = A2 * cos(2*pi*f2*t + phi2 + phy);
   
    xd = x2 .* x1;
    
    xd_mean_v(i) = mean(xd);
    i = i+1;
    phy_values(i)=phy;
end    



figure(3);
hold on;
grid minor;
grid on;
%plot(xd_mean_v);
plot(xd_mean_v,'Color','#0072BD','LineWidth',3.0);
xlim([0 i-1]);
ylim([-0.6 0.6]);
xt = get(gca, 'XTick');
ax = gca;
%ax.XTick=[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5];
ax.YTick=[-0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5];
%set(gca, 'XTick',xt, 'XTickLabel',xt*0.001)
%set(gca,'XTick',0:pi/2:2*pi)
ax.XTick=[0 1571 3142 4712 6283];
ax.XTickLabel = {'0','\pi/2','\pi','(3/2)\pi','2\pi'};
xlabel('\Delta\phi [rad]','fontsize',25);
ylabel('<x_D>','fontsize',25);
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0);
set(gca,'FontSize',20);
title(["\fontsize{30}Phase detector - mean output value simulation"]);
%editar os ticks horizontais para {(0, 0), (3142 \pi)(6283 2\pi)}
clear;
close all;
%----------------------------------------------------------------------%
f_s = 16000;

%----- Alpha=0.5
% Pole-zero plot
alpha = 0.5;
A = [1, -alpha];
B = (1-alpha);
H = tf(B,A,-1);

figure(1);
pzplot(H);
title("\fontsize{30}Pole-zero plot (\alpha=0.5)");
xlabel('Real Axis','fontsize',20);
ylabel('Imaginary Axis','fontsize',20);
xlim([-1.1 1.1])
ylim([-1.1 1.1])
ax = gca;
ax.XColor = [0, 0, 0];
ax.YColor = [0, 0, 0];
ax.XTick=[-1 -0.75 -0.5 -0.25 0 0.25 0.5 0.75 1];
ax.YTick=[-1 -0.75 -0.5 -0.25 0 0.25 0.5 0.75 1];
%set(gca,'PlotBoxAspectRatio',[1 1 1])
hold on;
grid on;
grid minor;
set(gca,'FontSize',20);

% Frequency response
[h,w]=freqz(B,A,2^20);
figure(2);
plot(w*f_s/(2*pi*1000),20*log10(abs(h)),'Color', '#0072BD', 'LineWidth',3.0);
set(gca,'FontSize',20);
hold on;
grid on;
grid minor;
xlabel('Frequency [kHz]','fontsize',25);
ylabel('Gain [dB]','fontsize',25);
title("\fontsize{30}Loop filter frequency response (\alpha=0.5)");
xlim([0 8])
ylim([-10 0.5])

%----- Alpha=-0.5
% Pole-zero plot
alpha = -0.5;
A = [1, -alpha];
B = (1-alpha);
H = tf(B,A,-1);

figure(3);
pzplot(H);
title("\fontsize{30}Pole-zero plot (\alpha=-0.5)");
xlabel('Real Axis','fontsize',20);
ylabel('Imaginary Axis','fontsize',20);
xlim([-1.1 1.1])
ylim([-1.1 1.1])
ax = gca;
ax.XColor = [0, 0, 0];
ax.YColor = [0, 0, 0];
ax.XTick=[-1 -0.75 -0.5 -0.25 0 0.25 0.5 0.75 1];
ax.YTick=[-1 -0.75 -0.5 -0.25 0 0.25 0.5 0.75 1];
hold on;
grid on;
set(gca,'FontSize',20);

% Frequency response
A = [1, -alpha];
B = (1-alpha);
f_s = 16000;
[h,w]=freqz(B,A,2^20);
figure(4);
plot(w*f_s/(2*pi*1000),20*log10(abs(h)),'Color', '#A2142F', 'LineWidth',3.0);
hold on;
grid on;
grid minor;
xlabel('Frequency [kHz]','fontsize',25);
ylabel('Gain [dB]','fontsize',25);
title("\fontsize{30}Loop filter frequency response (\alpha=-0.5)");
xlim([0 8])
ylim([-0.5 10])
set(gca,'FontSize',20);

%----------------------------------------------------------------------%
vars = {'A','B','f_s','h','w','vars','H'};
clear(vars{:})
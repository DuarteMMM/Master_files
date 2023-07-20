clear;
close all;
%----------------------------------------------------------------------%
M=8192;
f_s = 16000;
B = [1,zeros(1,M-1),-1];
A = [1,-1];
[h,w]=freqz(B/M,A,2^20); % Filter

% Frequency response (amplitude)
figure(1);
plot(w*f_s/(2*pi),20*log10(abs(h)),'LineWidth',3.0);
set(gca,'FontSize',20);
hold on;
grid on;
grid minor;
xlabel('Frequency [Hz]','fontsize',25);
ylabel('Gain [dB]','fontsize',25);
title(["\fontsize{30}CIC filter (with decimator) frequency response - amplitude"]);
xlim([0 5*f_s/M])
ylim([-65 1])

% Frequency response (phase)
figure(2);
plot(w*f_s/(2*pi),(angle(h)*180)/pi,'Color', '#A2142F','LineWidth',3.0);
set(gca,'FontSize',20);
hold on;
grid on;
grid minor;
xlabel('Frequency [Hz]','fontsize',25);
ylabel('Phase [º]','fontsize',25);
title(["\fontsize{30}CIC filter (with decimator) frequency response - phase"]);
ax = gca;
ax.YTick=[-180 -150 -120 -90 -60 -30 0];
xlim([0 5*f_s/M])
ylim([-190 10])

%Calculate attenuation at f=4Hz
f = 4;
H = tf(B/M,A,-1);
gain_linear = abs(evalfr(H,exp(-1i*2*pi*f/f_s)))
gain_db = 20*log10(gain_linear)

% Signal attenuation at f=4Hz
duration = 5;  % Duration in seconds
t = -duration:1/f_s:duration-1/f_s;  % Time vector
x = sin(2*pi*f*t);
y = filter(B/M,A,x);
figure(3);
plot(t,x,t,y,'LineWidth', 3.0);
set(gca,'FontSize',20);
hold on;
grid on;
grid minor;
xlabel('Time [s]','fontsize',25);
ylabel('Amplitude [V]','fontsize',25);
title(["\fontsize{30}CIC filter - signal attenuation at f=4Hz"]);
axis([0,1,-1.2,1.2]);
legend({'Input','Output'},'Location','southwest')

%----------------------------------------------------------------------%
vars = {'A','B','f','f_s','h','H','M','w','x','y','vars','duration'};
clear(vars{:})
clear;
close all;

%Coefficients
K_B     = 1 / (1 + cot(pi * 400 / 16000));
K_f0hz  = cos(2 * pi * 0 / 16000);
K_f2khz = cos(2 * pi * 2000 / 16000);
K_f4khz = 0;
K_f6khz = cos(2 * pi * 6000 / 16000);
K_f8khz = cos(2 * pi * 8000 / 16000);

a0 = 1;
a2 = -(1-2*K_B);
a_0hz  = [a0,  2*K_f0hz*(1-K_B), a2]; 
a_2khz = [a0, 2*K_f2khz*(1-K_B), a2];
a_4khz = [a0, 2*K_f4khz*(1-K_B), a2]; 
a_6khz = [a0, 2*K_f6khz*(1-K_B), a2]; 
a_8khz = [a0, 2*K_f8khz*(1-K_B), a2]; 

b      = [K_B, 0, -K_B];

% Freqz
aux    = -a_0hz;
aux(1) = a0;
[h_0hz, w_0hz]   = freqz(b, aux);

aux    = -a_2khz;
aux(1) = a0;
[h_2khz, w_2khz] = freqz(b,aux);

aux    = -a_4khz;
aux(1) = a0;
[h_4khz, w_4khz] = freqz(b,aux);

aux    = -a_6khz;
aux(1) = a0;
[h_6khz, w_6khz] = freqz(b,aux);

aux    = -a_8khz;
aux(1) = a0;
[h_8khz, w_8khz] = freqz(b,aux);

% Magnitude and phase responses for 2kHz, 4kHz and 6kHz
clear aux;

figure(1);
grid on;
grid minor;
hold on;
plot(w_2khz*8000/(pi*1000), abs(h_2khz),'Color','#0072BD','LineWidth',3.0);
plot(w_4khz*8000/(pi*1000), abs(h_4khz),'Color','#77AC30','LineWidth',3.0);
plot(w_6khz*8000/(pi*1000), abs(h_6khz),'Color','#A2142F','LineWidth',3.0);
title("\fontsize{30}Bandpass filter - magnitude response");
xlabel('Frequency [kHz]','fontsize',20);
ylabel('|T_{BP}(f)|','fontsize',20);
set(gca,'FontSize',20);
legend({'f_0 = 2kHz','f_0 = 4kHz','f_0 = 6kHz'},'Location','best');

figure(2);
grid on;
grid minor;
hold on;
plot(w_2khz*8000/(pi*1000), angle(h_2khz),'Color','#0072BD','LineWidth',3.0);
plot(w_4khz*8000/(pi*1000), angle(h_4khz),'Color','#77AC30','LineWidth',3.0);
plot(w_6khz*8000/(pi*1000), angle(h_6khz),'Color','#A2142F','LineWidth',3.0);
title("\fontsize{30}Bandpass filter - phase response");
xlabel('Frequency [kHz]','fontsize',20);
ylabel('Arg(T_{BP}(f)) [rad]','fontsize',20);
set(gca,'FontSize',20);
legend({'f_0 = 2kHz','f_0 = 4kHz','f_0 = 6kHz'},'Location','best');

% Magnitude and phase responses for 0Hz and 8kHz
figure(3);
grid on;
grid minor;
hold on;
plot(w_0hz*8000/(pi*1000),  abs(h_0hz),'Color','#0072BD','LineWidth',3.0);
plot(w_8khz*8000/(pi*1000), abs(h_8khz),'Color','#A2142F','LineWidth',3.0);
title("\fontsize{30}Second order IIR filter - magnitude response");
xlabel('Frequency [kHz]','fontsize',20);
ylabel('|T(f)|','fontsize',20);
set(gca,'FontSize',20);
legend({'f_0 = 0Hz','f_0 = 8kHz'},'Location','best');

figure(4);
grid on;
grid minor;
hold on;
plot(w_0hz*8000/(pi*1000),  angle(h_0hz),'Color','#0072BD','LineWidth',3.0);
plot(w_8khz*8000/(pi*1000), angle(h_8khz),'Color','#A2142F','LineWidth',3.0);
title("\fontsize{30}Second order IIR filter - phase response");
xlabel('Frequency [kHz]','fontsize',20);
ylabel('Arg(T(f)) [rad]','fontsize',20);
set(gca,'FontSize',20);
legend({'f_0 = 0Hz','f_0 = 8kHz'},'Location','best')

%----------------------------------------------------------------------%
clear w_*;
clear h_*;
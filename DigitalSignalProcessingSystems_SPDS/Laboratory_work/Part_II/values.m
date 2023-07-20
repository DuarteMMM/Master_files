close all;
clear;
%----------------------------------------------------------------------%
% Addicional
K_B     = 1 / (1 + cot(pi * 400 / 16000));
K_f_max_real = cos(2 * pi * 2000 / 16000); % Q15
K_f_max_approx = +(pi/2)*0.5; % Q15
K_f_min_real = cos(2 * pi * 6000 / 16000); % Q15
K_f_min_approx = -(pi/2)*0.5; % Q15
aux = round(2*(1-K_B)*2^14); % 2*(1-K_B) = 1.85408068546347 => Q14
a1_approx = 2*K_f_max_approx*(1-K_B); % 1.4562 => Q14
a1_real = 2*K_f_max_real*(1-K_B); % 1.3110 => Q14
a1_approx_q = bitshift(bitshift(aux*round(K_f_max_approx*2^15),1),-16) % Q14
a1_real_q = bitshift(bitshift(aux*round(K_f_max_real*2^15),1),-16) % Q14
K_f_approx = round(K_f_max_approx*2^15); 
K_f_real = round(K_f_max_real*2^15);
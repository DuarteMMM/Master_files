close all;
clear;

t = 0:0.00001:1;

A1 = 1;
A2 = 1;

%--------------------------------------------------------
f1 = 4000;
f2 = 4000;
phi2 = -pi/2;

x1 = A1 * sin(2*pi*f1*t);
x2 = A2 * cos(2*pi*f2*t + phi2);

xd = x1 .* x2;

xd_mean = mean(xd);

figure(1);
hold on;
grid on;
plot(t, x1);
plot(t, x2);
plot(t, xd);
xlim([0 0.001])
xlabel('Time');
ylabel('Amplitude');
legend({'x1', 'x2', 'xd'});
title('Diferent frequency (f\_x1 > f\_x2)');

%--------------------------------------------------------
f1 = 4000;
f2 = 3500;
phi2 = -pi/2;

x1 = A1 * sin(2*pi*f1*t);
x2 = A2 * cos(2*pi*f2*t + phi2);

xd = x1 .* x2;

xd_mean = mean(xd);

figure(2);
hold on;
grid on;
plot(t, x1);
plot(t, x2);
plot(t, xd);
xlim([0 0.001]);
xlabel('Time (\mus)');
ylabel('Amplitude');
legend({'x1', 'x2', 'xd'});
title(['Same frequency (f\_x1 = f\_x2 = 4kHz)' ...
    ' and same intial phase']);

%---------------------------------------------------------

f1 = 4000;
f2 = 4000;
phi2 = 0;

x1 = A1 * sin(2*pi*f1*t);

xd_mean_v = zeros(1, 7000);
i=1;

for phy = 0:0.001:2*pi
    x2 = A2 * cos(2*pi*f2*t + phi2 + phy);
   
    xd = x1 .* x2;
    
    xd_mean_v(i) = mean(xd);
    i = i+1;
end    

figure(3);
hold on;
grid on;
plot(xd_mean_v);
xlim([0 i-1]);
xlabel('Phase difference');
ylabel('<x_d>');
legend({'\Delta\phi'});
title('Average value variation with a phase difference of \Delta\phi');
%editar os ticks horizontais para {(0, 0), (3142 \pi)(6283 2\pi)}

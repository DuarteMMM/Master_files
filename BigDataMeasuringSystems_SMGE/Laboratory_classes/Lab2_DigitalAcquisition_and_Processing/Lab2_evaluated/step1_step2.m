fs = 20e3; % Acquisition rate
N = 400e3; % Number of acquisitions
TOTAL_ACQ = 3; % Process repeated 3 times, average computed

% -----visualização do DAQ-----
dispositivo = daqlist;
placa_ID = dispositivo.DeviceID;
placa_vendedor = dispositivo.VendorID;
deviceInfo = dispositivo{1, "DeviceInfo"};

% -----Programação do DAQ-----
dq = daq(placa_vendedor);
dq.Rate = fs;
ch = addinput(dq, placa_ID, 'ai0', 'Voltage');
ch.Range=[-10,10];
fs = dq.Rate;

% ----Obter sinal com DAQ----
start(dq, "Continuous")
for i=1:TOTAL_ACQ
    [signal(:, i), t(:, i)] = read(dq, N, "OutputFormat", "Matrix");
    fprintf("Foram obtidas %d amostras do sinal [%d/%d].\n", N, i, TOTAL_ACQ);
end
stop(dq)

% Resoluções e fs reais
dt = t(2)-t(1);
fs = 1/dt;
df = fs/N; 
disp(['Frequencia de amostragem = ', strtrim(evalc('disp(double(fs))')), ' Hz'])
disp(['Resolução Temporal = ', strtrim(evalc('disp(double(dt))')), ' s'])
disp(['Resolução Espectral = ', strtrim(evalc('disp(double(df))')), ' Hz'])
fprintf("Aquisição irá demorar %d s\n", dt*N*TOTAL_ACQ);

% Estimar a frequência
% Transformada de Fourier
for i = 1:TOTAL_ACQ
    fft_signal_c(:,i) = fft(signal(:,i));
end
fft_signal_c = (fft_signal_c/N);                
fft_signal_c = fft_signal_c(1:(floor(N/2))+1,:);   % Apenas considerar um lado do espetro
fft_signal = abs(fft_signal_c);                    % fft apenas com o modulo
fft_signal(2:end-1, :) = 2*fft_signal(2:end-1, :); % Multiplicar por 2 todas as frequências, exceto componente DC e a última frequência, para obter espetro unilateral    
fft_signal = (fft_signal/sqrt(2)).^2;

f = fs*(1:(N/2))/N; % Array de frequências de 0 a fs/2
f = f(1:(10/df));

fft_signal = fft_signal(1:(10/df), :);
fft_signal_m = sum(fft_signal')/TOTAL_ACQ; % Média de T espetros de potência
fft_signal_mdB = 10*log10(fft_signal_m); % Média em dB   

[pico, i(1)]=max(fft_signal_m(2:end)); % Encontar valor maximo do array
i(1) = i(1)+1;
[pico_adj, i(2)] = max(fft_signal_m(i(1)-1:2:i(1)+1)); % Encontrar o máximo entre os vizinhos    
i(2)= i(1) - 1*(i(2)==1) + 1*(i(2)==2);

i = sort(i); % Ordenar as frequências de ordem crescente
fp = [f(i)]; % Obter as frequências correspondentes

% ipdft
% Calcular parâmetros iniciais
omega_a = (2*pi*fp(1))/fs;
omega_b = (2*pi*fp(2))/fs;
UA = real(fft_signal_c(i(1)));
UB = real(fft_signal_c(i(2)));
VA = imag(fft_signal_c(i(1)));
VB = imag(fft_signal_c(i(2)));

% Kopt
Kopt = (((VB-VA)*sin(omega_a))+((UB-UA)*cos(omega_a)))/(UB-UA);
ZA = (VA*((Kopt-cos(omega_a))/(sin(omega_a))))+UA;
ZB = (VB*((Kopt-cos(omega_b))/(sin(omega_b))))+UB;

% Fipdft
Fipdft = (fs/(2*pi))*acos(((ZB*cos(omega_b))-(ZA*cos(omega_a)))/(ZB-ZA));
fprintf("\nFrequencia estimada por IPDFT = %.5f Hz\n", Fipdft);

% Limpar cálculo das frequências
clear pico pico_adj i fp omega_a omega_b UA UB VA VB Kopt ZA ZB fft_signal_c

% Estimar valores médio e eficaz
N_per_period = fs/Fipdft;
N_periods = N/N_per_period;
N_complete_periods = floor(N_periods);
N_avg = round(N_complete_periods * N_per_period);

valor_medio = sum(signal(1:N_avg,1))/N_avg;
fprintf("\nValor medio estimado = %f V\n", valor_medio);

valor_eficaz = sqrt(sum(signal(1:N_avg,1).^2)/N_avg);
fprintf("Valor eficaz estimado = %f V\n", valor_eficaz); 

% Limpar valores médio e eficaz
clear N_complete_periods N_avg

% Plot step1
subplot(2,1,2);plot(f,fft_signal_m);

title('Transformada de fourier unilateral do sinal','fontsize',12)
xlabel('f (Hz)')
ylabel('|Potência| (dB W)')
grid on;

signal_centered(:,1) = signal(:,1) - valor_medio;

subplot(2,1,1); 
if N_periods > 5    
    stem(t(1:round(N_per_period)*5,1), signal_centered(1:round(N_per_period)*5,1));
else
    stem(t, signal, 'filled');    
end

xlabel('t (s)')
ylabel('Tensão (V)')
title('Gráfico temporal do sinal','fontsize',12)

str = sprintf('f = %.2fHz, Valor Médio = %.5fV, Valor Eficaz = %.3fV, N = %d, fs = %.2fHz, Alcance = [-10,10]V',Fipdft, valor_medio, valor_eficaz, N, fs);
sgtitle(str)
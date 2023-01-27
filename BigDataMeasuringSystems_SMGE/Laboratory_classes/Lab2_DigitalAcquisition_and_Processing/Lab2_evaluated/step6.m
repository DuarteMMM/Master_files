clear all
close all

% ---- Load Files with 12V ----
d = uigetdir(pwd, 'Select a folder');
files = dir(fullfile(d, 'x_*_12.mat'));
dfts = [];
freqs = [];
types = [];

% ---- Per file ----
for j = 1:size(files)
    load(strcat(d,'\',files(j).name));
    data = strsplit(files(j).name,'.');
    data = string(data(1));
    
    % Resoluções e fs reais
    dt = t(2)-t(1);
    fs = 1/dt;
    df = fs/N; 
    
    % DFT
    for i = 1:TOTAL_ACQ
        fft_signal_c(:,i) = fft(signal(:,i));
    end
    fft_signal_c = (fft_signal_c/N);                
    fft_signal_c = fft_signal_c(1:(floor(N/2))+1,:);        % Apenas considerar um lado do espetro
    fft_signal = abs(fft_signal_c);                         % fft apenas com o módulo
    fft_signal(2:end-1, :) = 2*fft_signal(2:end-1, :);      % Multiplicar por 2 todas as frequências, menos a componente DC e a última frequencia, que apenas tem uma componente, para obter espetro unilateral    
    fft_signal = (fft_signal/sqrt(2)).^2;

    f = fs*(1:(N/2))/N; % Array de frequências de 0 a fs/2
    f = f(1:(10/df));

    fft_signal = fft_signal(1:(10/df), :);
    fft_signal_m = sum(fft_signal')/TOTAL_ACQ; % Média de T espetros de potência
    fft_signal_mdB = 10*log10(fft_signal_m); % Média em dB   

    dfts(end+1,:) = fft_signal_m(3:end);
    %dfts(end+1,:) = fft_signal_mdB(3:end);
    types(end+1,:) = data;
   
    clear dt fft_sign fft_signal_c fft_signal_m
end

figure(1);
subplot(2,1,1);
imagesc(f(3:end), [0 1 2 3 4 5],dfts);
xlabel('Frequency [Hz]')
ylabel('Number of coins')
c = colorbar;
c.Label.String = '|Power| [W]';

% ---- Load Files with 5 'coins' ----
files = dir(fullfile(d, 'x_5_*.mat'));

dfts = [];
freqs = [];
types = [];

% ---- Per file ----
for j = 1:size(files)
    load(strcat(d,'\',files(j).name));
    data = strsplit(files(j).name,'.');
    data = string(data(1));
    
    % Resoluções e fs reais
    dt = t(2)-t(1);
    fs = 1/dt;
    df = fs/N; 
    
    % DFT
    for i = 1:TOTAL_ACQ
        fft_signal_c(:,i) = fft(signal(:,i));
    end
    fft_signal_c = (fft_signal_c/N);                
    fft_signal_c = fft_signal_c(1:(floor(N/2))+1,:); 
    fft_signal = abs(fft_signal_c);                     
    fft_signal(2:end-1, :) = 2*fft_signal(2:end-1, :); 
    fft_signal = (fft_signal/sqrt(2)).^2;

    f = fs*(1:(N/2))/N;
    f = f(1:(10/df));

    fft_signal = fft_signal(1:(10/df), :);
    fft_signal_m = sum(fft_signal')/TOTAL_ACQ;
    fft_signal_mdB = 10*log10(fft_signal_m);
    
    dfts(end+1,:) = fft_signal_m(3:end);
    %dfts(end+1,:) = fft_signal_mdB(3:end);
    types(end+1,:) = data;
    clear dt fft_sign fft_signal_c fft_signal_m
end

figure(2);
subplot(2,1,1);
imagesc(f(3:end), [4 6 8 9 10 11 12],dfts);
xlabel('Frequency [Hz]')
ylabel('Voltage [V]')
c = colorbar;
c.Label.String = '|Power| [W]';
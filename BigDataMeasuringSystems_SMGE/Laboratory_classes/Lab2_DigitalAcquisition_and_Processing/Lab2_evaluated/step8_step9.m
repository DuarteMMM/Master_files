clear all
close all

% ---- Load all files----
d = uigetdir(pwd, 'Select a folder');
files = dir(fullfile(d, 'x_*.mat'));

data = struct('freq',[],'absValue',[],'coins',[],'voltage',[]);

% ---- Per file ----
for j = 1:size(files)
    load(strcat(d,'\',files(j).name));
    file_name = strsplit(files(j).name,'.');
    file_name = strsplit(string(file_name(1)), '_');
    data.coins(j) = file_name(2);   % in number of coins
    data.voltage(j) = file_name(3); % in volts
    
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

    f = fs*(1:(N/2))/N; % Array de frequencias de 0 a fs/2
    f = f(1:(10/df));

    fft_signal = fft_signal(1:(10/df), :);
    fft_signal_m = sum(fft_signal')/TOTAL_ACQ; % Média de T espetros de potência
    fft_signal_mdB = 10*log10(fft_signal_m);   % Média em dB   
    
    [pico, i(1)]=max(fft_signal_m(2:(4/df)));              % Encontar valor máximo do array
    i(1) = i(1)+1;
    [pico_adj, i(2)] = max(fft_signal_m(i(1)-1:2:i(1)+1)); % Encontrar o máximo entre os vizinhos    
    i(2)= i(1) - 1*(i(2)==1) + 1*(i(2)==2);

    i = sort(i);        % Ordenar as frequências de ordem crescente
    fp = [f(i)];        % Obter as frequências correspondentes

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
    fprintf("\nNmr moedas: %d\nValor absoluto pico: %f\nFrequência estimada por IPDFT: %.5f Hz\n", data.coins(j), pico, Fipdft);
        
    data.freq(j) = Fipdft;    % in Hz
    data.absValue(j) = pico;  % in volts
    
    clear dt fft_sign fft_signal_c fft_signal_m

end

%|CP|=f(CP,m)
p = polyfitn([data.freq', data.coins'],data.absValue',3);
fprintf("\nRegression |CP|=f(CP,m):\n");
display(polyn2sympoly(p))

%CP=f(|CP|,m)
p1 = polyfitn([data.absValue', data.coins'],data.freq',3);
fprintf("\nRegression CP=f(|CP|,m):\n");
display(polyn2sympoly(p1))

%m=f(CP,|CP|)
Polyfit_aprox = polyfitn([data.freq', data.absValue'],data.coins',3);
fprintf("\nRegression m=f(CP,|CP|):\n");
display(polyn2sympoly(Polyfit_aprox))

[xg,yg]=meshgrid(0:0.5:5);
zg = polyvaln(p,[xg(:),yg(:)]);
surf(xg,yg,reshape(zg,size(xg)))
hold on
plot3(data.freq', data.coins',data.absValue', 'o','Color','k','MarkerSize', 5, 'MarkerFaceColor','k');

title('3D surface plot (step 8)');
xlabel('CP [Hz]');
zlabel('|CP| [W]');
ylabel('Number of Coins'); 
hold off

clearvars -except p p1 Polyfit_aprox
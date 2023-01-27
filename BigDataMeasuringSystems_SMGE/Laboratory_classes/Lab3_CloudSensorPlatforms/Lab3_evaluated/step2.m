clear fft_signal_c

% ---- MQTT Credentials ----
clientId = 'NgsoCS0AIjwZMA4XNwgPIwM';
username = 'NgsoCS0AIjwZMA4XNwgPIwM';
password = 'JP+Xfilvo02qkC5dmJM9XwtI';

brokerAddress = "tcp://mqtt3.thingspeak.com";
topicFreq = "channels/2004335/publish/fields/field1";
topicAmp = "channels/2004335/publish/fields/field2";
port = 1883;
javaaddpath('matlab_mqtt_source\mqttasync.jar');
javaaddpath('matlab_mqtt_source\jar\org.eclipse.paho.client.mqttv3-1.1.0.jar');
addpath('matlab_mqtt_source');

mqClient = mqtt(brokerAddress,'Port', port, 'Username', username, 'Password',password,'ClientID', clientId);

fs = 20e3;     % Acquisition rate
TOTAL_ACQ = 3; % Number of acquisitions
N = 1000e3;    % Number of acquisitions

% ----- Visualização do DAQ -----
dispositivo = daqlist;
placa_ID = dispositivo.DeviceID;
placa_vendedor = dispositivo.VendorID;
deviceInfo = dispositivo{1, "DeviceInfo"};

% ----- Programação do DAQ -----
dq = daq(placa_vendedor);
dq.Rate = fs;
ch = addinput(dq, placa_ID, 'ai0', 'Voltage');
ch.Range=[-2,2];

% ---- Carregar buffer ----
start(dq, "Continuous")
fprintf("[INFO] A carregar buffer...\n")
for i=1:TOTAL_ACQ
    [buffer(:, i), t(:, i)] = read(dq, N, "OutputFormat", "Matrix");
    fprintf("    > [INFO] Foram obtidas %d amostras do sinal [%d/%d].\n", N, i, TOTAL_ACQ);
end
stop(dq)
fprintf("[INFO] Buffer carregado com sucesso!\n")

% ---- Main Loop ----
cur_index = 1;
while (1)
    % ---- Estimar CP e obter |CP|----
    % Resoluções e fs reais
    dt = t(2)-t(1);
    fs = 1/dt;
    df = fs/N; 
    
    % DFT
    for i = 1:TOTAL_ACQ
        fft_signal_c(:,i) = fft(buffer(:,i));
    end
    fft_signal_c = (fft_signal_c/N);                
    fft_signal_c = fft_signal_c(1:(floor(N/2))+1,:);   % Apenas considerar um lado do espetro
    fft_signal = abs(fft_signal_c);                    % fft apenas com o módulo
    fft_signal(2:end-1, :) = 2*fft_signal(2:end-1, :); % Multiplicar por 2 todas as frequências, menos a componente DC e a última frequência, que apenas tem uma componente, para obter espetro unilateral
    fft_signal = (fft_signal/sqrt(2)).^2;

    f = fs*(1:(N/2))/N; % Array de frequências de 0 a fs/2
    f = f(1:(10/df));

    fft_signal = fft_signal(1:(10/df), :);
    fft_signal_m = sum(fft_signal')/TOTAL_ACQ; % Média de T espetros de potência
    fft_signal_mdB = 10*log10(fft_signal_m);   % Média em dB   
    
    [pico, index_pico]=max(fft_signal_m(2:(4/df)));        % Encontar valor máximo do array
    i(1) = index_pico+1;
    [pico_adj, i(2)] = max(fft_signal_m(i(1)-1:2:i(1)+1)); % Encontrar o máximo entre os vizinhos    
    i(2)= i(1) - 1*(i(2)==1) + 1*(i(2)==2);

    i = sort(i);  % Ordenar as frequências de ordem crescente
    fp = [f(i)];  % Obter as frequências correspondentes

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
    
    % ---- Enviar dados ----
    formatSpec = '%.20f';
    publish(mqClient, topicFreq, num2str(Fipdft));
    publish(mqClient, topicAmp, num2str(pico, formatSpec));
    
    % ---- Adquirir mais dados e substituir no buffer ----
    start(dq, "Continuous")
    [buffer(:, cur_index), t(:, cur_index)] = read(dq, N, "OutputFormat", "Matrix");
    stop(dq)
    fprintf("[INFO] Foram obtidas %d amostras do sinal\n", N)
    
    cur_index=mod(cur_index+1,TOTAL_ACQ)+1
    clear fft_signal_c
end
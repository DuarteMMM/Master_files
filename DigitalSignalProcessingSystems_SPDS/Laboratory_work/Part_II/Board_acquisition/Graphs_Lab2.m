selec = input('\nFile?\n[1]Approximate ascending\n[2]Approximate descending\n[3]Exact ascending\n[4]Exact descending\n[5]f=4kHz\n[6]CIC filter\n');

if selec==1
    rawTable = readtable('Approximate_ascending.xlsx','Sheet','Sheet1');
elseif selec==2
    rawTable = readtable('Approximate_descending.xlsx','Sheet','Sheet1');
elseif selec==3
    rawTable = readtable('Exact_ascending.xlsx','Sheet','Sheet1');
elseif selec==4
    rawTable = readtable('Exact_descending.xlsx','Sheet','Sheet1');
elseif selec==5
    rawTable = readtable('f_4k.xlsx','Sheet','Sheet1');
elseif selec==6
    rawTable = readtable('CIC_filter.xlsx','Sheet','Sheet1');
end

x = rawTable.Frequency_Hz; %: get the excel column, Header1 (header name)
y = rawTable.Amplitude_dB; %: get the excel column, Header2 (header name)

h = plot(x, y,'Color', '#0072BD', 'LineWidth',3.0);
set(gca,'FontSize',20);
grid on
grid minor
xlabel('Frequency [Hz]','fontsize',25);
ylabel('Magnitude [dB]','fontsize',25);

if selec==1
    title(["\fontsize{30}Approximate control (ascending frequency sweep)"]);
    xlim([0 8100])
    ylim([-85 5])
elseif selec==2
    title(["\fontsize{30}Approximate control (descending frequency sweep)"]);
    xlim([0 8100])
    ylim([-85 5])
    set(h, 'Color', '#A2142F')
elseif selec==3
    title(["\fontsize{30}Exact control (ascending frequency sweep)"]);
    xlim([0 8100])
    ylim([-85 5])
elseif selec==4
    title(["\fontsize{30}Exact control (descending frequency sweep)"]);
    xlim([0 8100])
    ylim([-85 5])
    set(h, 'Color', '#A2142F')
elseif selec==5
    title(["\fontsize{30}Output y(n) with a_1=0 (no frequency control)"]);
    xlim([0 8100])
    ylim([-85 5])
    set(h, 'Color', '#77AC30')
elseif selec==6
    title(["\fontsize{30}CIC filter"]);
    xlim([-90 4100])
    ylim([-90 5])
    set(h, 'Color', '#D95319')
end
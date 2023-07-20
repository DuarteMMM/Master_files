clear;
close all;

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

h = plot(x/1000, y,'Color', '#0072BD', 'LineWidth',3.0);
set(gca,'FontSize',20);
grid on
grid minor
xlabel('Frequency [kHz]','fontsize',25);
ylabel('Magnitude [dB]','fontsize',25);

if selec==1
    title(["\fontsize{30}Approximate control (ascending frequency sweep)"]);
    xline(3.435,'--r',  '\fontsize{15}f=f_C^-=3.435kHz', 'Color', 'black', 'LineWidth', 2,'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xline(6.040,'--r',  '\fontsize{15}f=f_L^+=6.040kHz', 'Color', 'black', 'LineWidth', 2,'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xlim([0 8.1])
    ylim([-85 5])
elseif selec==2
    title(["\fontsize{30}Approximate control (descending frequency sweep)"]);
    xline(4.560,'--r',  '\fontsize{15}f=f_C^+=4.560kHz', 'Color', 'black', 'LineWidth', 2,'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xline(1.972,'--r',  '\fontsize{15}f=f_L^-=1.972kHz', 'Color', 'black', 'LineWidth', 2,'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xlim([0 8.1])
    ylim([-85 5])
    set(h, 'Color', '#A2142F')
elseif selec==3
    title(["\fontsize{30}Exact control (ascending frequency sweep)"]);
    xline(3.435,'--r',  '\fontsize{15}f=f_C^-=3.435kHz', 'Color', 'black', 'LineWidth', 2,'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xline(6.040,'--r',  '\fontsize{15}f=f_L^+=6.040kHz', 'Color', 'black', 'LineWidth', 2,'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xlim([0 8.1])
    ylim([-85 5])
elseif selec==4
    title(["\fontsize{30}Exact control (descending frequency sweep)"]);
    xline(4.560,'--r',  '\fontsize{15}f=f_C^+=4.560kHz', 'Color', 'black', 'LineWidth', 2,'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xline(1.972,'--r',  '\fontsize{15}f=f_L^-=1.972kHz', 'Color', 'black', 'LineWidth', 2,'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xlim([0 8.1])
    ylim([-85 5])
    set(h, 'Color', '#A2142F')
elseif selec==5
    title(["\fontsize{30}Output y(n) with a_1=0 (no frequency control)"]);
    xlim([0 8.1])
    ylim([-85 5])
    set(h, 'Color', '#77AC30')
elseif selec==6
    title(["\fontsize{30}CIC filter"]);
    xlim([0 4])
    ylim([-90 5])
    set(h, 'Color', '#D95319')
end
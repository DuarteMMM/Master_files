clear;
close all;

selec = input('\nPlot?\n[0]CMRR\n[1]PSRR+\n[2]PSRR-\n[3]CMRR (parasitics)\n');

disp('Select the file for the numerator gain.')
[file_num,path_num] = uigetfile('*.csv');
file_num_sheet = erase(file_num, '.csv');

disp('Select the file for the denominator gain.')
[file_den,path_den] = uigetfile('*.csv');
file_den_sheet = erase(file_den, '.csv');

rawTable_num = readtable(file_num,'ReadVariableNames',false);
rawTable_den = readtable(file_den,'ReadVariableNames',false);
x = rawTable_num.Var1;
y_num = rawTable_num.Var2;
y_den = rawTable_den.Var2;

y = y_num-y_den;

if selec==0 || selec==1 || selec==2
    h = semilogx(x, y,'-o','LineWidth',3.0,'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
    h.MarkerSize = 4;
    set(gca,'FontSize',20);
    grid on
    grid minor
    xlabel('f [Hz]','fontsize',25);

elseif selec==3
    disp('Select the file for the other numerator gain.')
    [file_num_other,path_num_other] = uigetfile('*.csv');
    file_num_other_sheet = erase(file_num_other, '.csv');

    disp('Select the file for the other denominator gain.')
    [file_den_other,path_den_other] = uigetfile('*.csv');
    file_den_other_sheet = erase(file_den_other, '.csv');

    rawTable_num_other = readtable(file_num_other,'ReadVariableNames',false);
    rawTable_den_other = readtable(file_den_other,'ReadVariableNames',false);
    x_other = rawTable_num_other.Var1;
    y_num_other = rawTable_num_other.Var2;
    y_den_other = rawTable_den_other.Var2;

    y_other = y_num_other-y_den_other;

    h = semilogx(x, y,'-o','LineWidth',3.0,'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
    hold on
    h_other = semilogx(x, y_other,'-o','LineWidth',3.0,'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
    h.MarkerSize = 4;
    h_other.MarkerSize = 4;
    set(gca,'FontSize',20);
    grid on
    grid minor
    xlabel('f [Hz]','fontsize',25);
end

if selec==0
    title('$\textbf{Common mode rejection ratio}\;\left(\mathbf{CMRR=\left|\frac{A_d}{A_c}\right|}\right)$','Interpreter', 'latex','fontsize',30);
    ylabel('CMRR [dB]','fontsize',25);
    xlim([8 4.5E9])
    %xlim([8 100E9])
    set(h, 'Color', '#A2142F')
elseif selec==1
    title('$\textbf{Power supply rejection ratio}\;(\mathbf{PSRR^+=\frac{A_d}{A^+}}$)','Interpreter', 'latex','fontsize',30);
    ylabel('PSRR^+ [dB]','fontsize',25);
    xlim([7 60E9])
    ylim([-55 45])
    set(h, 'Color', '#A2142F')
elseif selec==2
    title('$\textbf{Power supply rejection ratio}\;(\mathbf{PSRR^-=\frac{A_d}{A^-}}$)','Interpreter', 'latex','fontsize',30);
    ylabel('PSRR^- [dB]','fontsize',25);
    xlim([7 60E9])
    %ylim([-55 45])
    set(h, 'Color', '#0072BD')
elseif selec==3
    title('$\textbf{Common mode rejection ratio}\;\left(\mathbf{CMRR=\left|\frac{A_d}{A_c}\right|}\right)$','Interpreter', 'latex','fontsize',30);
    ylabel('CMRR [dB]','fontsize',25);
    xlim([8 125E9])
    ylim([-10 58])
    set(h, 'Color', '#A2142F')
    set(h_other, 'Color', '#0072BD')
end
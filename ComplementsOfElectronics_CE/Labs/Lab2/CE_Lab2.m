clear;
close all;

disp('Select file.')
[file,path] = uigetfile('*.csv');
file_sheet = erase(file, '.csv');

rawTable = readtable(file,'ReadVariableNames',false);
x = rawTable.Var1;
y = rawTable.Var2;

h = semilogx(x, y,'-o','LineWidth',3.0,'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
h.MarkerSize = 7;
set(gca,'FontSize',20);
grid on
grid minor
xlabel('$\mathrm{f [Hz]}$','Interpreter', 'latex','fontsize',25);

title('Ganho de corrente em função da frequência','fontsize',30);
ylabel('$\mathrm{\Delta i_o/\Delta i_i [dB]}$','Interpreter', 'latex','fontsize',25);
xlim([250 900000])
ylim([32 58])
set(h, 'Color', '#A2142F')
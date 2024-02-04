clear;
close all;

disp('Select file.')
[file,path] = uigetfile('*.csv');
file_sheet = erase(file, '.csv');

rawTable = readtable(file,'ReadVariableNames',false);
x1 = rawTable.Var1;
y1 = rawTable.Var2;

disp('Select file.')
[file1,path1] = uigetfile('*.csv');
file_sheet1 = erase(file1, '.csv');

rawTable1 = readtable(file1,'ReadVariableNames',false);
x2 = rawTable1.Var1;
y2 = rawTable1.Var2;

% Plotting
figure;
h1 = semilogx(x1, y1, '-o','LineWidth',3.0,'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
h1.MarkerSize = 7;
hold on; % Hold the current graph
h2 = semilogx(x2, y2, '-o','LineWidth',3.0,'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
h2.MarkerSize = 7;

set(gca,'FontSize',20);
grid on
grid minor
xlabel('$\mathrm{f [Hz]}$','Interpreter', 'latex','fontsize',25);

title('Ganho de corrente em função da frequência','fontsize',30);
ylabel('$\mathrm{\Delta i_o/\Delta i_i [dB]}$','Interpreter', 'latex','fontsize',25);
xlim([250 400000])
ylim([0 45])
set(h1, 'Color', '#A2142F')
set(h2, 'Color', '#0072BD')

% Release hold
hold off;
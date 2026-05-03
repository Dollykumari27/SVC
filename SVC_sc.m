clc
clear all

% SNR Range
d1 = 0:2:20;

BLER_svc = [0.8800, 0.7400, 0.5500, 0.3800, 0.2100, 0.0950, 0.0380, 0.0120, 0.0045, 0.0012, 0.0004];

width = 5;      % Width in inches
height = 4;     % Height in inches
alw = 1.2;      % AxesLineWidth
fsz = 12;       % Fontsize
lw = 1.2;       % LineWidth
msz = 6;        % MarkerSize

% Plot Setup
% figure
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
set(0,'defaultAxesFontName','Times New Roman');

semilogy(d1, BLER_svc, '-x', 'LineWidth', lw, 'MarkerSize', msz); hold on; grid on

xlabel('SNR (dB)', 'FontSize', fsz)
ylabel('BLER', 'FontSize', fsz)


ax = gca;
ax.FontSize = fsz;
ax.LineWidth = alw;
grid on
axis([0 20 1e-4 1])
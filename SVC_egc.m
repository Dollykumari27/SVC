clc
clear all

% SNR Range
d1 = 0:2:20;

BLER_svc = [0.8200, 0.6500, 0.4100, 0.2200, 0.0850, 0.0280, 0.0072, 0.0015, 0.0003, 0.0001, 0.0000];

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

% Axis and Font configuration
ax = gca;
ax.FontSize = fsz;
ax.LineWidth = alw;
axis([0 20 1e-4 1])
clc
clear all

% SNR Range
d1 = 0:2:20;

%%%%% Kappa = 0 (Ideal Case), SNR Range 0 to 20dB
K0_sim = [0.8500, 0.6200, 0.3800, 0.1900, 0.0820, 0.0310, 0.0095, 0.0028, 0.0006, 0.0001, 0.0000];

%%%%% Kappa = 0.4 (Hardware Impairment), SNR Range 0 to 20dB
K04_sim = [0.9200, 0.7800, 0.5900, 0.4200, 0.2800, 0.1900, 0.1200, 0.0850, 0.0620, 0.0510, 0.0480];

width = 5;      % Width in inches
height = 4;     % Height in inches
alw = 1.2;      % AxesLineWidth
fsz = 12;       % Fontsize
lw = 1.5;       % LineWidth
msz = 7;        % MarkerSize

% Plot Setup
% figure
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
set(0,'defaultAxesFontName','Times New Roman');

semilogy(d1, K0_sim, '-o', 'LineWidth', lw, 'MarkerSize', msz); hold on; grid on
semilogy(d1, K04_sim, '-x', 'LineWidth', lw, 'MarkerSize', msz); hold on; grid on

xlabel('SNR (dB)')
ylabel('BLER')
legend('\kappa = 0 (Ideal)', '\kappa = 0.4 (HI)', 'Location', 'southwest')
axis([0 20 1e-4 1])
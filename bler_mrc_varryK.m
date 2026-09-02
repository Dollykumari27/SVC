clc
clear all

% SNR Range
d1 = [-15 -13 -11 -9 -7 -5 -3 -1 1 3 5 7 9 11 13 15];

%%%%% Sparsity K=2, SNR Range -15 to 15dB
K2_sim = [0.00, 0.02, 0.15, 0.45, 0.78, 0.92, 0.98, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00];

%%%%% Sparsity K=3, SNR Range -15 to 15dB
K3_sim = [0.00, 0.00, 0.05, 0.22, 0.55, 0.81, 0.94, 0.97, 0.99, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00];

%%%%% Sparsity K=4, SNR Range -15 to 15dB
K4_sim = [0.00, 0.00, 0.00, 0.08, 0.30, 0.62, 0.85, 0.92, 0.96, 0.98, 0.99, 1.00, 1.00, 1.00, 1.00, 1.00];

width = 5;      % Width in inches
height = 4;     % Height in inches
alw = 1.2;      % AxesLineWidth
fsz = 12;       % Fontsize
lw = 1.5;       % LineWidth
msz = 6;        % MarkerSize

% Plot Setup
% figure
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
set(0,'defaultAxesFontName','Times New Roman');

plot(d1, K2_sim, '-o', 'LineWidth', lw, 'MarkerSize', msz); hold on; grid on
plot(d1, K3_sim, '-s', 'LineWidth', lw, 'MarkerSize', msz); hold on; grid on
plot(d1, K4_sim, '-^', 'LineWidth', lw, 'MarkerSize', msz); hold on; grid on

xlabel('SNR (dB)')
ylabel('Decoding Success Probability')
legend('K=2', 'K=3', 'K=4', 'Location', 'southeast')
axis([-15 15 0 1.1])

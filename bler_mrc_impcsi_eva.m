%% =========================================================================
% Script: plot_bler_mrc_impcsi_eva.m
% Description: Plots BLER vs. SNR for SVC-MRC under perfect CSI (\epsilon = 0)
%              and imperfect CSI (\epsilon = 0.2, 0.7) matching the IEEE format.
% =========================================================================

clc;
clear;
close all;

%% 1. SNR Vector and Simulated/Extracted Data Points
snr_db = 0:2:14;

% BLER Data corresponding to:
% Curve 1: \epsilon = 0   (pCSI)
% Curve 2: \epsilon = 0.2 (ipCSI)
% Curve 3: \epsilon = 0.7 (ipCSI)
bler_eps_0_0 = [1.25e-1, 4.45e-2, 1.10e-2, 2.05e-3, 3.00e-4, 3.40e-5, 5.00e-6, 1.00e-6];
bler_eps_0_2 = [1.60e-1, 6.20e-2, 1.65e-2, 3.10e-3, 4.70e-4, 4.20e-5, 7.00e-6, 1.50e-6];
bler_eps_0_7 = [2.25e-1, 9.00e-2, 2.60e-2, 5.50e-3, 9.00e-4, 1.10e-4, 1.20e-5, 2.00e-6];

%% 2. Figure Setup & Publication Styling
figure('Units', 'inches', 'Position', [2, 2, 4.8, 4.2], 'Color', [1 1 1]);

% 1. \epsilon = 0 (pCSI) -> Solid Black Line with Asterisk
semilogy(snr_db, bler_eps_0_0, '-k*', ...
    'LineWidth', 1.8, 'MarkerSize', 10, 'DisplayName', '\epsilon = 0  (pCSI)');
hold on;

% 2. \epsilon = 0.2 (ipCSI) -> Dashed Red Line with Square
semilogy(snr_db, bler_eps_0_2, '--rs', ...
    'LineWidth', 1.8, 'MarkerSize', 8, 'MarkerFaceColor', 'none', ...
    'DisplayName', '\epsilon = 0.2  (ipCSI)');

% 3. \epsilon = 0.7 (ipCSI) -> Dashed Blue Line with Pentagram
semilogy(snr_db, bler_eps_0_7, '--bp', ...
    'LineWidth', 1.8, 'MarkerSize', 11, 'MarkerFaceColor', 'b', ...
    'DisplayName', '\epsilon = 0.7  (ipCSI)');

hold off;

%% 3. Axes Formatting
grid on;
set(gca, ...
    'FontName', 'Times New Roman', ...
    'FontSize', 14, ...
    'LineWidth', 1.2, ...
    'Box', 'on', ...
    'XMinorGrid', 'off', ...
    'YMinorGrid', 'off', ...
    'GridLineStyle', '-', ...
    'GridAlpha', 0.4, ...
    'GridColor', [0.4 0.4 0.4]);

xlabel('SNR (dB)', 'FontSize', 15, 'FontName', 'Times New Roman');
ylabel('BLER', 'FontSize', 15, 'FontName', 'Times New Roman');

xlim([0 14]);
ylim([1e-5 1]);
set(gca, 'YTick', [1e-5 1e-4 1e-3 1e-2 1e-1 1e0]);
set(gca, 'XTick', 0:2:14);

%% 4. Legend Styling
leg = legend('show', 'Location', 'northeast');
set(leg, ...
    'FontName', 'Times New Roman', ...
    'FontSize', 13, ...
    'LineWidth', 1.2, ...
    'EdgeColor', 'k', ...
    'Color', [1 1 1]);

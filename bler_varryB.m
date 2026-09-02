%% =========================================================================
% Script: main_svc_diversity_m_comparison.m
% Description: Evaluates and compares Block Error Rate (BLER) vs. SNR for 
%              Sparse Vector Coding (SVC) under MRC, EGC, and SC diversity 
%              combining schemes across spreading sequence lengths m = [28, 42, 63].
% =========================================================================

clc;
clear;
close all;

%% System Parameters
snr_db       = 0:2:20;               % SNR range in dB
snr          = 10.^(snr_db / 10);    % Linear scale SNR
channel_mode = 5;                    % 1:AWGN, 2:Rayleigh, 3:EPA, 4:ETU, 5:EVA
bi           = 12;                   % Total information bits
N_svc        = 96;                   % SVC codebook dimension
m_vec        = [28, 42, 63];         % Spreading sequence lengths
Nr           = 2;                    % Number of Rx antennas
Rep          = 8;                    % Repetition factor
K            = 2;                    % Sparsity level
mu           = 2;                    % Modulation order
Lmmp         = 1;                    % MMP search breadth
lmax         = power(Lmmp, K);       % Maximum candidate paths
nTrials      = 1e4;                  % Monte Carlo trials per SNR point (set to 1e5 or 1e6 for final curves)

%% Performance Result Containers
BLER_MRC = zeros(length(m_vec), length(snr_db));
BLER_EGC = zeros(length(m_vec), length(snr_db));
BLER_SC  = zeros(length(m_vec), length(snr_db));

%% Main Simulation Loop
fprintf('Starting Comparative Diversity Simulation (MRC vs EGC vs SC) over m...\n');

for im = 1:length(m_vec)
    m = m_vec(im);
    
    % Load pre-generated codebook matrices for each scheme
    switch m
        case 28
            data_mrc = load('C_svc_mrc_28.mat'); c_mrc = data_mrc.c_svc;
            data_egc = load('C_svc_egc_28.mat'); c_egc = data_egc.c_svc;
            data_sc  = load('C_svc_sc_28.mat');  c_sc  = data_sc.c_svc;
        case 42
            data_mrc = load('C_svc_mrc_42.mat'); c_mrc = data_mrc.c_svc;
            data_egc = load('C_svc_egc_42.mat'); c_egc = data_egc.c_svc;
            data_sc  = load('C_svc_sc_42.mat');  c_sc  = data_sc.c_svc;
        case 63
            data_mrc = load('C_svc_mrc_63.mat'); c_mrc = data_mrc.c_svc;
            data_egc = load('C_svc_egc_63.mat'); c_egc = data_egc.c_svc;
            data_sc  = load('C_svc_sc_63.mat');  c_sc  = data_sc.c_svc;
    end
    
    tic;
    for s_idx = 1:length(snr_db)
        curr_snr = snr(s_idx);
        
        succ_mrc = 0;
        succ_egc = 0;
        succ_sc  = 0;
        
        for trial = 1:nTrials
            if mod(trial, 10000) == 0
                fprintf('m=%d | SNR=%d/%d dB | Trial: %d/%d\n', ...
                    m, snr_db(s_idx), snr_db(end), trial, nTrials);
            end
            
            % Sparse Support & Signal Generation
            support_tx = sort(randperm(N_svc, K), 'ascend');
            s_svc      = zeros(N_svc, 1);
            s_svc(support_tx(1)) = 1;
            s_svc(support_tx(2)) = 1i;
            
            % Transmitted symbols per scheme codebook
            x_mrc = c_mrc * (1 / sqrt(K)) * s_svc;
            x_mrc = x_mrc ./ norm(x_mrc);
            
            x_egc = c_egc * (1 / sqrt(K)) * s_svc;
            x_egc = x_egc ./ norm(x_egc);
            
            x_sc  = c_sc * (1 / sqrt(K)) * s_svc;
            x_sc  = x_sc ./ norm(x_sc);
            
            var_x_sc = var(x_sc);
            
            % Channel Realizations across Receive Antennas
            H_stack   = [];
            y_mrc_stk = [];
            y_egc_stk = [];
            y_sc_stk  = [];
            W_mrc_stk = [];
            W_egc_stk = [];
            snr_sc    = [];
            
            for inr = 1:Nr
                noise_temp = (1 / sqrt(curr_snr)) * (1 / sqrt(m)) * (1 / sqrt(2)) * (randn(m, 1) + 1i * randn(m, 1));
                
                % Simulate channel for each scheme
                [y_temp_mrc, H_temp] = channel(x_mrc, curr_snr, channel_mode, noise_temp, Rep);
                [y_temp_egc, ~]      = channel(x_egc, curr_snr, channel_mode, noise_temp, Rep);
                [y_temp_sc, ~]       = channel(x_sc,  curr_snr, channel_mode, noise_temp, Rep);
                
                hF = norm(diag(H_temp), 'fro');
                
                % 1. MRC Weights
                w_mrc     = conj(H_temp) ./ hF;
                W_mrc_stk = blkdiag(W_mrc_stk, w_mrc);
                
                % 2. EGC Weights
                w_egc     = y_temp_egc .* diag(exp(-1i * angle(diag(H_temp)))) ./ hF;
                W_egc_stk = blkdiag(W_egc_stk, w_egc);
                
                % Branch SNR for Selection Combining
                varNoise   = var(noise_temp);
                snr_branch = (trace(abs(H_temp).^2) * var_x_sc) / varNoise;
                snr_sc     = [snr_sc, snr_branch];
                
                H_stack   = [H_stack; H_temp];
                y_mrc_stk = [y_mrc_stk; y_temp_mrc];
                y_egc_stk = [y_egc_stk; y_temp_egc];
                y_sc_stk  = [y_sc_stk; y_temp_sc];
            end
            
            % ---------------- 1. MRC Detection ----------------
            Z_mrc   = (1 / sqrt(Nr)) * W_mrc_stk * y_mrc_stk;
            phi_mrc = W_mrc_stk * H_stack * c_mrc;
            [~, supp_mrc, ~] = islsp_EstMMP_BF_reuse(Z_mrc, phi_mrc, K, Lmmp, lmax);
            succ_mrc = succ_mrc + isequal(support_tx, sort(supp_mrc, 'ascend'));
            
            % ---------------- 2. EGC Detection ----------------
            Z_egc   = (1 / sqrt(Nr)) * W_egc_stk * y_egc_stk;
            phi_egc = W_egc_stk * H_stack * c_egc;
            [~, supp_egc, ~] = islsp_EstMMP_BF_reuse(Z_egc, phi_egc, K, Lmmp, lmax);
            succ_egc = succ_egc + isequal(support_tx, sort(supp_egc, 'ascend'));
            
            % ---------------- 3. SC Detection -----------------
            [~, best_idx] = max(snr_sc);
            H_best = H_stack((best_idx - 1) * m + 1 : best_idx * m, 1:m);
            y_best = y_sc_stk((best_idx - 1) * m + 1 : best_idx * m);
            
            hF_sc   = norm(diag(H_best), 'fro');
            W_sc    = conj(H_best) ./ hF_sc;
            Z_sc    = (1 / sqrt(Nr)) * W_sc * y_best;
            phi_sc  = W_sc * H_best * c_sc;
            [~, supp_sc, ~] = islsp_EstMMP_BF_reuse(Z_sc, phi_sc, K, Lmmp, lmax);
            succ_sc = succ_sc + isequal(support_tx, sort(supp_sc, 'ascend'));
        end
        
        BLER_MRC(im, s_idx) = 1 - (succ_mrc / nTrials);
        BLER_EGC(im, s_idx) = 1 - (succ_egc / nTrials);
        BLER_SC(im, s_idx)  = 1 - (succ_sc  / nTrials);
        
        fprintf('m=%d | SNR=%2d dB | BLER MRC: %.3e | EGC: %.3e | SC: %.3e\n', ...
            m, snr_db(s_idx), BLER_MRC(im, s_idx), BLER_EGC(im, s_idx), BLER_SC(im, s_idx));
    end
    fprintf('Completed m=%d in %.2f s\n\n', m, toc);
end

%% Plot Comparative Results
figure('Color', [1 1 1], 'Units', 'inches', 'Position', [2, 2, 6.5, 4.8]);
m_styles = {'o', 's', '^'};
colors   = {'r', 'b', 'k'};

hold on;
for im = 1:length(m_vec)
    % Solid line: MRC
    semilogy(snr_db, BLER_MRC(im, :), ['-', colors{im}, m_styles{im}], ...
        'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', sprintf('MRC (m = %d)', m_vec(im)));
    
    % Dashed line: EGC
    semilogy(snr_db, BLER_EGC(im, :), ['--', colors{im}, m_styles{im}], ...
        'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', sprintf('EGC (m = %d)', m_vec(im)));
        
    % Dash-dot line: SC
    semilogy(snr_db, BLER_SC(im, :), [':', colors{im}, m_styles{im}], ...
        'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', sprintf('SC (m = %d)', m_vec(im)));
end
hold off;

grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.2, 'Box', 'on');
xlabel('SNR (dB)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('Block Error Rate (BLER)', 'FontSize', 13, 'FontWeight', 'bold');
title(sprintf('SVC BLER Comparison: MRC vs. EGC vs. SC (Nr = %d, EVA Channel)', Nr), 'FontSize', 13);
legend('Location', 'southwest', 'FontSize', 9, 'NumColumns', 3);
axis([min(snr_db) max(snr_db) 1e-4 1]);

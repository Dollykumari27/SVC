clc;
clear;
close all;

%% System Parameters
snr_db       = -15:2:5;              % Eb/N0 range matching Fig. 6
snr          = 10.^(snr_db / 10);    % Linear scale SNR
channel_mode = 2;                    %
N_svc        = 96;                   % SVC codebook dimension
Nr           = 2;                    % Number of Rx antennas
Rep          = 2;                    % Repetition factor
K            = 2;                    % Sparsity level
mu           = 1;                    % Modulation order parameter
Lmmp         = 2;                    % MMP tree search width
nTrials      = 1e5;                  % Monte Carlo iterations per SNR point


%% Performance Containers
PER_MRC = zeros(1, length(snr_db));

%% Main Simulation Loop
fprintf('Starting SVC-MRC Simulation over 5G Vehicular-B Channel (Mode 6)...\n');

for s_idx = 1:length(snr_db)
    curr_snr = snr(s_idx);
    succ_mrc = 0;
    
    for trial = 1:nTrials
        if mod(trial, 20000) == 0
            fprintf('Eb/N0 = %d dB | Iteration: %d / %d\n', snr_db(s_idx), trial, nTrials);
        end
        
        % Transmit Vector Generation
        support_tx = sort(randperm(N_svc, K), 'ascend');
        s_svc      = zeros(N_svc, 1);
        s_svc(support_tx(1)) = 1;
        s_svc(support_tx(2)) = 1i;
        
        x_svc = c_svc * (1 / sqrt(K)) * s_svc;
        x_svc = bsxfun(@rdivide, x_svc, sqrt(sum(x_svc .* conj(x_svc), 1)));
        
        % Multi-Antenna Receiver Modeling
        y_svc = []; 
        H_svc = []; 
        
        for inr = 1:Nr
            noise_temp = (1 / sqrt(curr_snr)) * (1 / sqrt(m)) * (1 / sqrt(2)) * (randn(m, 1) + 1i * randn(m, 1));
            
            % External channel function (mode 6: 5G Vehicular-B 6-tap)
            [y_temp, H_temp] = channel(x_svc, curr_snr, channel_mode, noise_temp, Rep);
            
            H_svc = [H_svc; H_temp];
            y_svc = [y_svc; y_temp];
        end
        
        lmax = power(Lmmp, K);
        
        % Call dedicated MRC Combining Function
        Z_mrc = mrc_combiner(y_svc, H_svc, c_svc, Nr, m);
        
        % MMP Detection
        [~, supp_mrc, ~] = islsp_EstMMP_BF_reuse(Z_mrc, phi_mrc, K, Lmmp, lmax);
        succ_mrc         = succ_mrc + isequal(support_tx, sort(supp_mrc, 'ascend'));
    end
    
    PER_MRC(s_idx) = 1 - (succ_mrc / nTrials);
    fprintf('Eb/N0: %3d dB | PER MRC: %.4e\n', snr_db(s_idx), PER_MRC(s_idx));
end

%% Plot Results
figure('Color', [1 1 1]);
semilogy(snr_db, PER_MRC, '-rd', 'LineWidth', 1.5, 'MarkerSize', 7, 'MarkerFaceColor', 'none', 'DisplayName', 'MRC');
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.2, 'Box', 'on');
xlabel('E_b/N_0 (dB)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('PER', 'FontSize', 13, 'FontWeight', 'bold');
title('SVC-MRC Performance over 5G Vehicular-B Channel', 'FontSize', 13);
legend('Location', 'northeast', 'FontSize', 11);
axis([min(snr_db) max(snr_db) 1e-5 1.2]);

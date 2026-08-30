clc;
clear;
close all;

%% System Parameters
snr_db       = -10:2:10;             % SNR range in dB
snr          = 10.^(snr_db / 10);    % Linear scale SNR
channel_mode = 1;                    % 1:AWGN, 2:Rayleigh, 3:EPA, 4:ETU, 5:EVA, 
N_svc        = 96;                   % SVC codebook dimension
m            = 42;                   % Spreading sequence length
Nr           = 2;                    % Number of Rx antennas
Rep          = 2;                    % Repetition factor
K            = 2;                    % Sparsity level
mu           = 1;                    % Modulation order parameter
Lmmp         = 8;% 
nTrials      = 1e4;                  % Monte Carlo iterations per SNR point

%% Codebook Generation
alpha_svc = sqrt(2 * ((2^mu) - 1) / 3);
Cbest = [];
for i = 1:1e3
    c_cand = (1 / alpha_svc) * randsrc(m, N_svc);  
    mu_val = max(max(triu(abs(cN' * cN), 1)));
    if mu_val > 0.3 && mu_val < 0.50
        Cbest = c_cand;
        break;
    end
end
if isempty(Cbest)
    Cbest = c_cand;
end
c_svc      = normc(Cbest);
mu_max_svc = max(max(triu(abs(c_svc' * c_svc), 1)));

%% Performance Containers
BLER_MRC = zeros(1, length(snr_db));
BLER_EGC = zeros(1, length(snr_db));
BLER_SC  = zeros(1, length(snr_db));

%% Main Simulation Loop
fprintf('Starting Diversity Combining Simulation (MRC vs EGC vs SC)...\n');

for s_idx = 1:length(snr_db)
    curr_snr = snr(s_idx);
    
    succ_mrc = 0;
    succ_egc = 0;
    succ_sc  = 0;
    
    for trial = 1:nTrials
        % Transmit Vector Generation
        support_tx = sort(randper(N_svc, K), 'ascend');
        s_svc = zeros(N_svc, 1);
        s_svc(support_tx(1)) = 1;
        s_svc(support_tx(2)) = 1i;
        
        x_svc = c_svc  * s_svc;
        x_svc = bsxfun(@rdivide, x_svc, sqrt(sum(x_svc .* conj(x_svc), 1)));
        var_svc = var(x_svc);
        
        % Channel & Receiver Modeling
        y_svc = []; H_svc = []; noise_svc = []; snr_svc = [];
        for inr = 1:Nr
            noise_temp = (1 / sqrt(curr_snr)) * (1 / sqrt(m)) * (1 / sqrt(2)) * (randn(m, 1) + 1i * randn(m, 1));
            varNoise   = var(noise_temp);
            
            % Generate Channel Matrix
            h_temp = (1 / sqrt(2)) * (randn(m, 1) + 1i * randn(m, 1))
            H_temp = diag(h_temp);
            y_temp = H_temp * x_svc + noise_temp;
            
            snr_branch = (trace(abs(H_temp).^2) * var_svc) / varNoise;
            snr_svc    = [snr_svc, snr_branch];
            
            H_svc      = [H_svc; H_temp];
            y_svc      = [y_svc; y_temp];
            noise_svc  = [noise_svc; noise_temp];
        end
        
        lmax = power(Lmmp, K);
        
        % 1. MRC Combining & Detection
        [Z_mrc, phi_mrc] = svc_diversity_combiner('MRC', y_svc, H_svc, c_svc, Nr, m, snr_svc);
        [~, supp_mrc, ~] = islsp_EstMMP_BF_reuse(Z_mrc, phi_mrc, K, Lmmp, lmax)
        succ_mrc = succ_mrc + isequal(support_tx, sort(supp_mrc, 'ascend'));
        
        % 2. EGC Combining & Detection
        [Z_egc, phi_egc] = svc_diversity_combiner('EGC', y_svc, H_svc, c_svc, Nr, m, snr);
        [supp_egc, ~]    = algo_omp(Z_egc, phi_egc, K, noise_svc);
        succ_egc = succ_egc + isequal(support_tx, sort(supp_egc, 'ascend'));
        
        % 3. SC Combining & Detection
        [Z_sc, phi_sc]   = svc_diversity_combiner('SC', y_svc, H_svc, c_svc, Nr, m, snr);
        [~, supp_sc, ~]  = islsp_EstMMP_BF_reuse(Z_sc, phi_sc, K, Lmmp, lmax);
        succ_sc  = succ_sc + isequal(support_tx, sort(supp_sc, 'ascend'))
    end
    
    BLER_MRC(s_idx) = 1 - (succ_mrc / nTrials);
    BLER_EGC(s_idx) = 1 - (succ_egc / nTrials);
    BLER_SC(s_idx)  = 1 - (succ_sc  / nTrials);
    
    fprintf('SNR: %3d dB | BLER MRC: %.4e | BLER EGC: %.4e | BLER SC: %.4e\n', ...
        snr_db(s_idx), BLER_MRC(s_idx), BLER_EGC(s_idx), BLER_SC(s_idx));
end

%% Plot Results
figure('Color', [1 1 1]);
semilogy(snr_db, BLER_MRC, '-ro', 'LineWidth', 1.5, 'MarkerSize', 7, 'DisplayName', 'MRC (MMP)'); hold on;
semilogy(snr_db, BLER_EGC, '-bs', 'LineWidth', 1.5, 'MarkerSize', 7, 'DisplayName', 'EGC (OMP)');
semilogy(snr_db, BLER_SC,  '-k^', 'LineWidth', 1.5, 'MarkerSize', 7, 'DisplayName', 'SC (MMP)');
grid on;

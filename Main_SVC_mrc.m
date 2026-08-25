function results = main_SVC_EPA()

clc;
clear;
close all;

%% Initialize simulation parameters
p = initialize_parameters();

%% Generate SVC codebook
[p.c_svc, p.mu_max_svc] = ...
    codebook_gen(p.m, p.N_svc, p.mu);

%% Allocate memory
results.success = zeros(p.nTrials, length(p.snr_db));
results.BLER    = zeros(1, length(p.snr_db));

results.enc_time = zeros(1, length(p.snr_db));
results.dec_time = zeros(1, length(p.snr_db));

%% SNR loop
total_timer = tic;

for isnr = 1:length(p.snr_db)

    fprintf('\nSNR = %d dB\n', p.snr_db(isnr));

    for trial = 1:p.nTrials

        %% Generate SVC signal
        t_enc = tic;

        [x_svc, support_tx] = generate_svc_signal(p);

        results.enc_time(isnr) = results.enc_time(isnr) + toc(t_enc);

        %% Generate received signal
        [y, H, W] = generate_received_signal( x_svc, p, p.snr(isnr));

        %% Receive combining
        [Z, Phi] = receive_combining( y, H, W, p);

        %% Support detection
        t_dec = tic;

        support_rx = detect_support(  Z, Phi, p);

        results.dec_time(isnr) =  results.dec_time(isnr) + toc(t_dec);

        %% Support success
        results.success(trial,isnr) =  isequal(support_tx, support_rx);

    end

    %% BLER
    results.BLER(isnr) = calculate_bler(results.success(:,isnr));

    fprintf('BLER = %.6e\n', results.BLER(isnr));

end

results.total_time = toc(total_timer);

%% Average timing
results.enc_time_us = results.enc_time / p.nTrials * 1e6;

results.dec_time_us = results.dec_time / p.nTrials * 1e6;

%% Plot
plot_bler(p.snr_db, results.BLER);

%% Save
save_results(p, results);

end

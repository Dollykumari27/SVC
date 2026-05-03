
% Decoding time averages
data_svc_dec = load('Dec_time_avg_SVC.mat');
data_egc_dec = load('Dec_time_avg_SVC_egc4.mat');
data_mrc_dec = load('Dec_time_avg_SVC_mrc5.mat');
data_sc_dec  = load('Dec_time_avg_SVC_sc3.mat');

% Encoding time averages
data_svc_enc = load('enc_time_avg_SVC4.mat');
data_egc_enc = load('enc_time_avg_SVC_egc4.mat');
data_mrc_enc = load('enc_time_avg_SVC_mrc4.mat');
data_sc_enc  = load('enc_time_avg_SVC_sc4.mat'); 

decoding_means = [mean(data_svc_dec.dec_time_avg_ms), ...
                  mean(data_egc_dec.dec_time_avg_ms), ...
                  mean(data_mrc_dec.dec_time_avg_ms), ...                 
                  mean(data_sc_dec.dec_time_avg_ms)];

encoding_means = [mean(data_svc_enc.enc_time_avg_ms), ...
                  mean(data_egc_enc.enc_time_avg_ms), ...
                  mean(data_mrc_enc.enc_time_avg_ms), ...
                  mean(data_sc_enc.enc_time_avg_ms)];

% 3. Format data for plotting
labels = {'SVC', 'SVC (EGC)', 'SVC (MRC)', 'SVC (SC)'};
plot_data = [decoding_means; encoding_means]';

% 4. Create the Figure
figure('Color', 'w', 'Position', [100, 100, 600, 450]);
hBar = bar(plot_data, 'grouped');

% Styling the bars teal/red scheme
hBar(1).FaceColor = [0.2, 0.7, 0.7]; % Teal (Decoding)
hBar(1).EdgeColor = 'k';
hBar(2).FaceColor = [0.8, 0.2, 0.1]; % Red (Encoding)
hBar(2).EdgeColor = 'k';


set(gca, 'YScale', 'log');
target_ticks = [10^-2,10^-1, 10^0, 10^1, 10^2];
set(gca, 'YTick', target_ticks);
% grid on;
box on;

% Add Labels, Title, and Legend
ylabel('Average run time (milliseconds)', 'FontSize', 12);
set(gca, 'XTickLabel', labels, 'FontSize', 11);
legend({'Decoding time', 'Encoding time'}, 'Location', 'northeast');

% Set Y-axis limits and ticks to match the visual style of your reference
ylim([10^-1, 20]); % Adjusted based on your specific data ranges



function [Z_comb, phi_comb] = svc_diversity_combiner(technique, y_svc, H_svc, c_svc, Nr, m, snr_svc)
% SVC_DIVERSITY_COMBINER Applies MRC, EGC, or SC combining on received SVC signals.
%
% Inputs:
%   technique - 'MRC', 'EGC', or 'SC'
%   y_svc     - Stacked received signal vector (Nr*m x 1)
%   H_svc     - Stacked channel matrices (Nr*m x m)
%   c_svc     - SVC codebook matrix (m x N_svc)
%   Nr        - Number of receive antennas
%   m         - Spreading length
%   snr_svc   - Vector of SNR values per antenna branch (used for SC)
%
% Outputs:
%   Z_comb    - Combined measurement vector
%   phi_comb  - Effective sensing matrix for sparse recovery

    switch upper(technique)
        case 'MRC'
            W_svc = [];
            for inr = 1:Nr
                H_sub = H_svc((inr-1)*m + 1 : inr*m, :);
                hF = norm(diag(H_sub), 'fro');
                w_temp = conj(H_sub) ./ hF;
                W_svc = blkdiag(W_svc, w_temp);
            end
            Z_comb   = (1 / sqrt(Nr)) * W_svc * y_svc;
            phi_comb = W_svc * H_svc * c_svc;

        case 'EGC'
            % Co-phased equalization
            H_egc    = exp(-1j * angle(H_svc));
            y_egc    = sum(H_egc .* y_svc, 2);
            Z_comb   = (1 / sqrt(Nr)) * y_egc;
            phi_comb = H_svc * c_svc;

        case 'SC'
            % Selection combining based on maximum instantaneous branch SNR
            [~, best_idx] = max(snr_svc);
            H_sc   = H_svc((best_idx-1)*m + 1 : best_idx*m, 1:m);
            hF     = norm(diag(H_sc), 'fro');
            W_sc   = conj(H_sc) ./ hF;
            y_sc   = y_svc((best_idx-1)*m + 1 : best_idx*m);
            
            Z_comb   = (1 / sqrt(Nr)) * W_sc * y_sc;
            phi_comb = W_sc * H_sc * c_svc;

        otherwise
            error('Invalid technique specified. Choose ''MRC'', ''EGC'', or ''SC''.');
    end
end

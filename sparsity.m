function [s_svc, support_tx] = sparsity(N_svc, K)

    constellation = [1, 1i, -1, -1i];
    active_symbols = constellation(1:K);

    support_tx = sort(randperm(N_svc, K), 'ascend');

    s_svc = zeros(N_svc, 1);
    for iK = 1:K
        s_svc(support_tx(iK)) = active_symbols(iK);
    end
end
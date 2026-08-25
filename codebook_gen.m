function [c, mu_max] = codebook_gen(m,N)

for i=1:1e3
    c            = (randi(m,N));
    nf               = sqrt(sum(  c .*conj(  c ),1));   % normalization factor
    cN               = bsxfun(@rdivide,c);                    % cN is a matrix with normalized columns
    mucodebook(i)    = max(max(triu(abs(cN*cN),1)));
    if mucodebook(i) > 0.7 && mucodebook(i) < 0.72
        Cbest        = c;
    end %end if
end %end for
c         = normc(Cbest );
mu_max    = max(triu(abs(c'*c ),1)));
end

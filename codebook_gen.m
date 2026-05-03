function [c, mu_max] = codebook_gen(m,N,mu)

alpha     = sqrt(2*((2^mu)-1)/3); % normalization factor decided by the modulated symbols
for i=1:1e3
    c            = (1/alpha)*(randsrc(m,N));
    nf               = sqrt(sum(  c .*conj(  c ),1));   % normalization factor
    cN               = bsxfun(@rdivide,c,nf);                    % cN is a matrix with normalized columns
    mucodebook(i)    = max(max(triu(abs(cN'*cN),1)));
    if mucodebook(i) > 0.7 && mucodebook(i) < 0.72
        Cbest        = c;
        muMIN        = mucodebook(i);
    end %end if
end %end for
c         = normc(Cbest );
mu_max    = max(max(triu(abs(c'*c ),1)));
end
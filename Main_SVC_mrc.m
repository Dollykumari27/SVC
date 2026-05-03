clc;
clear;


snr_db  = 0:2:20;            
snr     = 10.^(snr_db/10);   
channel_mode =3;            
bi   = 12;                  
N_svc   = 96;                 
Nr=2;                      
m       = 42;              
K       = 2;                   
Lmmp    = 4;                   
Rep     = 8;
lmax  = power(Lmmp,K);             
mu      = 2;                          
nTrials = 1e4;                

[c_svc, mu_max_svc] = codebook_gen(m,N_svc,mu); 


Succ_supp_svc   = zeros(nTrials,length(snr_db));
BLER_svc  = zeros(Nr,length(snr_db));

enc_time_total = zeros(1, length(snr_db));
dec_time_total = zeros(1, length(snr_db)); 

% for iNr=1:Nr
    tic;
    for snr_count=1:length(snr_db)
        snr_db_temp=snr_db(snr_count);
        for Trial=1:nTrials
            if mod(Trial,10000)==0
                fprintf(' Nr=%d | SNRDB = %d / %d | Iteration: %d / %d \n ',Nr,snr_db(snr_count),  snr_db(end),  Trial ,nTrials);
                fprintf('------------------------------------------------------------------------------- \n');
            end
            % data input
            bitsSVC       = randi([0 1],1,bi);                       
            bits_char  = num2str(bitsSVC);            
            w10        = bin2dec(bits_char);          
          
            Supp_svc_tx  = sort(randperm(N_svc, K),'ascend');
            s_svc  = zeros(N_svc,1);
            s_svc(Supp_svc_tx(1)) = 1;
            s_svc(Supp_svc_tx(2)) = 1i;              
            x_svc                = (1/sqrt(K))*c_svc*s_svc;
            nfX                  = sqrt(sum(  x_svc .*conj(  x_svc ),1);
            x_svc                = bsxfun(@rdivide,x_svc,nfX);
            NormC_svc            = norm(c_svc(:,1));           
            NormX_svc            = norm(x_svc);
            enc_time_total(snr_count) = enc_time_total(snr_count) + toc(t_enc_start);

            y_svc=[];H_svc=[]; noise_svc=[];W_svc=[];w_temp_svc = [];
            for inr=1:Nr
                noise_temp          = (1/sqrt(snr(snr_count)))*(1/sqrt(m))*(1/sqrt(2)*(randn(m,1)+1i*randn(m,1)));               
             
                var_svc             = var(x_svc);
                varNoise_svc           = var(noise_temp);
                snr_check_svc       = 20*log10(norm(x_svc)/norm(noise_temp));
                [y_temp_svc, H_temp_svc]     = channel(x_svc, snr, channel_mode, noise_temp, Rep);
                hF_svc=norm(diag(H_temp_svc),'fro');  
                w_temp_svc=conj(H_temp_svc)/ hF_svc;
                W_svc=blkdiag(W_svc,w_temp_svc);
                H_svc= [H_svc; H_temp_svc];
                y_svc= [y_svc; y_temp_svc];
                noise_svc= [noise_svc; noise_temp];
             end
        
            Z_svc=1/sqrt(Nr)*W_svc*y_svc;
            phi_new_svc=W_svc*H_svc*c_svc;
            [RecSig_svc, support_rx_svc,  idx_depth] = islsp_EstMMP_BF_reuse(Z_svc,phi_new_svc, K,Lmmp,lmax);
            support_rx_svc=sort(support_rx_svc, 'ascend');
            Succ_supp_svc (Trial,snr_count) = isequal(Supp_svc_tx,support_rx_svc);  
            dec_time_total(snr_count) = dec_time_total(snr_count) + toc(t_dec_start);
        % =====================================================
        end 
    end  
    Avg_succ_svc = mean(Succ_supp_svc,1);
    BLER_svc   = 1 - Avg_succ_svc;    
    time_taken=toc;
    fprintf(' Time taken for one antenna = %d \n', time_taken);
    fprintf('----------------------------------------------- \n');
% end

width = 5;     % Width in inches
height = 4;    % Height in inches
alw = 1.2;    % AxesLineWidth
fsz = 12;      % Fontsize
lw = 1.2;      % LineWidth
msz = 6;       % MarkerSize
% Plot BLER
% figure
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
set(0,'defaultAxesFontName','Times New Roman');

semilogy(snr_db, BLER_svc, '--x', 'LineWidth',lw,'MarkerSize',msz);hold on;

xlabel('SNR (dB)', 'FontSize', fsz)
ylabel('BLER', 'FontSize', fsz)

ax = gca;
ax.FontSize = fsz;
ax.LineWidth = alw;
grid on
hold on

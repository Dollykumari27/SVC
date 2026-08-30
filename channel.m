function [received_signal,channel] = channel(signal,snr,mode, noise, Rep)
m     = size(signal,1);
if mode == 1 % AWGN channel
    channel = 1;
    received_signal_dup = signal + noise;
elseif mode==2 % IID Rayleigh
    channel_spread      = 1/sqrt(2)*1/sqrt(2)*(randn(m,1) + 1i*randn(m,1));  % I.I.D Rayleigh channel condition
    channel             = diag(channel_spread);
    received_signal_dup = channel*signal+noise;
elseif mode==3  % EPA delay profile model
    tap_delay=[0, 30, 70, 90, 110, 190, 410];
    tap_power_db=[0, -1,-2,-3, -8, -17.2, -20.8];
    length_epa=length(tap_delay);
    tap_power_lin=power(10,tap_power_db);
    temp = (1/sqrt(2))*(randn(1,length_epa)+1i* randn(1,length_epa));
    for k=1:length_epa
        temp_h(k)=sqrt(tap_power_lin(k)/2).*temp(k);
    end
    channel_spread = fft(temp_h,m);
    channel             = diag(channel_spread);
    received_signal_dup = channel*signal+noise;    
elseif mode==4  % ETU delay profile model
    tap_delay=[0, 50, 120, 200, 230, 500, 1600, 2300, 5000];
    tap_power_db=[-1, -1,-1,0,0,0,-3,-5,-7];
    length_etu=length(tap_delay);
    tap_power_lin=power(10,tap_power_db);
    temp = (1/sqrt(2))*(randn(1,length_etu)+1i* randn(1,length_etu));
    for k=1:length_etu
        temp_h(k)=sqrt(tap_power_lin(k)/2).*temp(k);
    end
    channel_spread = fft(temp_h,m);
    channel             = diag(channel_spread);
    received_signal_dup = channel*signal+noise;    
elseif mode==5  % EVA delay profile model
    tap_delay=[0,30,150,310,370,710,1090,1730,2510];
    tap_power_db=[0,-1.5,-1.4,-3.6,-0.6,-9.1,-7,-12,-16.9];
    length_eva=length(tap_delay);
    tap_power_lin=power(10,tap_power_db);
    temp = (1/sqrt(2))*(randn(1,length_eva)+1i* randn(1,length_eva));
    for k=1:length_eva
        temp_h(k)=sqrt(tap_power_lin(k)/2).*temp(k);
    end
    channel_spread = fft(temp_h,m);
    channel             = diag(channel_spread);
    received_signal_dup = channel*signal+noise;
    elseif mode==6      % 5G Vehicular-B (6 taps)
    tap_delay = [0 300 8900 12900 17100 20000];
    % tap_power_db = [0 -1 -9 -10 -15 -20];
      tap_power_db = [-2.5 0 -12.8 -10 -25.5 -16.0];
    L = length(tap_delay);
    tap_power_lin = 10.^(tap_power_db/10);

    tap_power_lin = tap_power_lin/sum(tap_power_lin);
    temp = (randn(1,L)+1i*randn(1,L))/sqrt(2);

    temp_h = zeros(1,L);

    for k = 1:L
        temp_h(k) = sqrt(tap_power_lin(k))*temp(k);
    end

    channel_spread = fft(temp_h,m);
    channel_spread = channel_spread ./ sqrt(mean(abs(channel_spread).^2));
    channel = diag(channel_spread);
    received_signal_dup = channel*signal + noise;   
end
received_signal=zeros(size(received_signal_dup ));
for idx_rep = 1:Rep
    received_signal=received_signal+received_signal_dup;
end
end

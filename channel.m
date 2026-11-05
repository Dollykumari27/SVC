function [received_signal,channel] = channel(signal,snr,mode, noise, Rep)
if mode == 1 % AWGN channel
    channel = 1;
elseif mode==2 % IID Rayleigh
elseif mode==3  % EPA delay profile model
    tap_delay=[0, 30, 70, 90, 110, 190, 410];
    tap_power_db=[0, -1,-2,-3, -8, -17.2, -20.8];
    length_epa=length(tap_delay);
    tap_power_lin=power(10,tap_power_db);     
elseif mode==4  % ETU delay profile model
    tap_delay=[0, 50, 120, 200, 230, 500, 1600, 2300, 5000];
    tap_power_db=[-1, -1,-1,0,0,0,-3,-5,-7];
    length_etu=length(tap_delay);
    tap_power_lin=power(10,tap_power_db);   
elseif mode==5  % EVA delay profile model
    tap_delay=[0,30,150,310,370,710,1090,1730,2510];
    tap_power_db=[0,-1.5,-1.4,-3.6,-0.6,-9.1,-7,-12,-16.9];
    length_eva=length(tap_delay);
    tap_power_lin=power(10,tap_power_db);
    elseif mode==6      % 5G Vehicular-B (6 taps)
    tap_delay = [0 300 8900 12900 17100 20000];
    % tap_power_db = [0 -1 -9 -10 -15 -20];
      tap_power_db = [-2.5 0 -12.8 -10 -25.5 -16.0];
    L = length(tap_delay);
    tap_power_lin = 10.^(tap_power_db/10);  
end
end
end

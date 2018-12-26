function [snr, xxb, yy] = calcsnr(st, en, tf, y, fs, f, nfft, win, adv)
% tf -- HARP transfer function
% y  -- raw waveform
% fs -- sampling rate
% f  -- f(1) = 15; f(2) = 30;
% st -- vector of starting samples of calls
% en -- vector of ending samples of calls
% WINLENGTH -- how big a window in samples to look
% quick and dirty SNR measurement
% look at the WINDOW with the signal (+noise): y_sn
% look at the WINDOW before the signal: y_n
% calculate pwelch [dB re uPa^2 Hz^-1]
% apply transfer function for correct HARP
% convert to linear scale
% sum pxx over frequency range of interest (15 - 30 Hz).
% calculate signal as y_s =  y_sn - y_n
% convert back to dB scale (10log10)
% SNR = y_s - y_n



% open one of the test files
% [fnames, dirpath, nfiles] = openall();
% [y fs] = audioread(fullfile(dirpath, fnames{3}));
% 
% nyq = fs / 2;
% 
% f(1) = 15;
% f(2) = 30;
% 
% nfft = fs;
% win = hann(nfft);
% adv = nfft / 2;
% spectrogram(y, win, adv, nfft, fs, 'yaxis');
% set(gca, 'YScale', 'log');
% 
% [ct, st, en] = selectcalls(y, fs);
% 
for i=1:length(st)
    WINLENGTH(i) = length(st(i):en(i));
end

backwardst = st - WINLENGTH + 1;    % start of noise box
backwarden = st;                    % end of noise box

% check to make sure we have room to look behind for a noise box
dese = find(backwardst < 1);
if(length(dese) > 0)
    backwardst(dese) = NaN;
end

yy = [f(1) f(2) f(2) f(1)]; % this is for drawing on the y axis

% convert samples to seconds for the purposes of drawing on the x axis
xxb = [backwardst' backwardst' backwarden' backwarden'] ./ fs;


% load in the transfer function
cal_freq = tf(:, 1);
cal_dB = tf(:, 2);


nst = length(st);
part = ceil(sqrt(nst));
dims = [part part];
difference = part^2 - nst;

if(difference >= part & part*(part - 1) >= nst)
    dims = [part - 1 part];
end

figure('position', [1000 400 600 500]);
for i = 1:length(st)
    if(~isnan(backwardst(i)))    % do we have a noise box?
        yn = y(backwardst(i):backwarden(i));    %noise
        ysn = y(st(i):en(i));                   %signal+noise

        % calculate dB from the pwelch for the signal
        [pxx fff] = pwelch(ysn, win, adv, nfft, fs);
        pxx_db = 10*log10(pxx);
        
        % interpolate the transfer function so that it matches the pxx
        ptf = interp1(cal_freq, cal_dB, fff, 'linear', 'extrap');
        
        % just add them together
        pxx_db_cal = ptf + pxx_db;

        
 subplot(dims(1), dims(2), i);
 semilogx(fff, pxx_db_cal);
        % put it back on the linear scale for summing
        pxx_lin_cal = 10.^(pxx_db_cal/10);

        %in the pxx the 1st index corresponds to freq 0 hz so add 1 to the 
        %frequency to get the correct index to get the correct 

        ysn_sum = sum(pxx_lin_cal((f(1)+1):(f(2)+1)));

        % calculate dB from the pwelch for the noise
        [pxx fff] = pwelch(yn, win, adv, nfft, fs);
        pxx_db = 10*log10(pxx);
        
        % interpolate the transfer function so that it matches the pxx
        % and then
        ptf = interp1(cal_freq, cal_dB, fff, 'linear', 'extrap');
        pxx_db_cal = ptf + pxx_db;

        

 hold on
 semilogx(fff, pxx_db_cal);
 hold off
        pxx_lin_cal = 10.^(pxx_db_cal/10);

        %in the pxx the 1st index corresponds to freq 0 hz so add 1 to the 
        %frequency to get the correct index to get the correct 

        yn_sum = sum(pxx_lin_cal((f(1)+1):(f(2)+1)));

        %calculat ys_sum just the signal minus the noise
        ys_sum = ysn_sum - yn_sum;

        %convert back to dB
        ys_sum_db  = 10*log10(ys_sum);
        yn_sum_db  = 10*log10(yn_sum);
        ysn_sum_db = 10*log10(ysn_sum);

        %calculate snr
        snr(i) = ys_sum_db - yn_sum_db;
        if(~isreal(snr(i)))
            snr(i) = NaN;
        end
        %snr_nominus(i) = ysn_sum_db - yn_sum_db;
    else
        snr(i) = NaN;
    end
end



% figure(1);
% 
% nfft = fs;
% win = hann(nfft);
% adv = nfft / 2;
% spectrogram(y, win, adv, nfft, fs, 'yaxis');
% set(gca, 'YScale', 'log');
% 
% for i = 1:length(ct)
%     hold on;
%     plot(xx_sel(i, :), yy, 'k:');
%     
%     if(~isnan(xxb(i,1)))    %make sure there is noise box to draw
%         plot(xxb(i, :), yy, 'm:');
%     end
%     
%     hold off;
% end

end

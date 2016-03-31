% quick and dirty SNR measurement
% look at the 1 sec with the signal
% look at the 1 sec before the signal
% look at the 1 sec after the signal
% average the 1 sec before and after to mean NOISE

% calculate "inband power" for all three intervals
% SNR = (SIGNAL - NOISE) / NOISE

% to do this in Raven Michael Pitzrick says do this:

% get inband power in linear units
% get SNR in linear units
% convert SNR to dB with 10*log10(SNR)

% another posiibility is the NIS Quick method (incorporated into Raven
% 2.0??)

% check out this question on the forum Laela asked:
% http://ravensoundsoftware.com/forum/archive/index.php?t-7973.html

% do this on the filtered wavform?!
% or do it off the psd?




% open one of the test files
[fnames, dirpath, nfiles] = openall();
[y fs] = audioread(fullfile(dirpath, fnames{3}));

nyq = fs / 2;

f(1) = 15;
f(2) = 30;
[b a] = butter(3, f/nyq);
yf = filtfilt(b, a, y);

nfft = fs;
win = hann(nfft);
adv = nfft / 2;
spectrogram_truthful_labels(y, win, adv, nfft, fs, 'yaxis');
set(gca, 'YScale', 'log');

[ct, st, en] = selectcalls(y, fs);

WINLENGTH = length(st(1):en(1));

forwardst = en;
forwarden = en + WINLENGTH - 1;

backwardst = st - WINLENGTH + 1;
backwarden = st;

xxf = [forwardst'   forwardst'   forwarden'   forwarden'] ./ fs;
yy = [f(1) f(2) f(2) f(1)];

xxb = [backwardst' backwardst' backwarden' backwarden'] ./ fs;


for i = 1:length(ct)
    hold on;
    plot(xxf(i, :), yy, 'm:');
    plot(xxb(i, :), yy, 'm:');
    hold off;
end


for i = 1:length(ct)
    tmpyf_sig = yf(st(i):en(i));
    tmpyf_fnoise = yf(forwardst(i):forwarden(i));
    tmpyf_bnoise = yf(backwardst(i):backwarden(i));
    
    sig(i) = sum(tmpyf_sig .^2);
    fnoise(i) = sum(tmpyf_fnoise .^2);
    backnoise(i) = sum(tmpyf_bnoise .^2);
    meannoise(i) = mean([fnoise(i), backnoise(i)]);
   
%     s(i) = bandpower(y(st(i):en(i)), fs, f);
%     n(i) = bandpower(y(forwardst(i):forwarden(i)));
end

SNR_linear = (sig - meannoise) ./ meannoise;
SNR_dB = 10*log10(SNR_linear);

% SNR_bp_linear = (s - n) ./ n;
% SNR_bp_dB = 10*log10(SNR_bp_linear);



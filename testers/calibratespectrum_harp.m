tf = load('561_090720_invSensit.tf');
cal_freq = tf(:, 1);
cal_dB = tf(:, 2);

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


[pxx fff] = pwelch(y, win, adv, nfft, fs);

pxx = 10*log10(pxx);

ptf = interp1(cal_freq, cal_dB, fff, 'linear', 'extrap');
pxx = ptf + pxx;

semilogx(fff, pxx);
ylabel('Spectrum Level [dB re \muPa^2/Hz]');





%backward

yn = y(backwardst:backwarden);
ys = y(st:en);


[pxx fff] = pwelch(ys, win, adv, nfft, fs);
pxx = 10*log10(pxx);
ptf = interp1(cal_freq, cal_dB, fff, 'linear', 'extrap');
pxx = ptf + pxx;


semilogx(fff, pxx);
ylabel('Spectrum Level [dB re \muPa^2/Hz]');
title('signal');

hold on;

[pxx fff] = pwelch(yn, win, adv, nfft, fs);
pxx = 10*log10(pxx);
ptf = interp1(cal_freq, cal_dB, fff, 'linear', 'extrap');
pxx = ptf + pxx;
semilogx(fff, pxx);
ylabel('Spectrum Level [dB re \muPa^2/Hz]');
title('noise');

hold off;



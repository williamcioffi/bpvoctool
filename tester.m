% tester
LOGTICKS = [10 15 30 100 500 1000];
LINTICKS = [20 100 250 500 750 1000];
currentscale = 'log';
currentticks = LOGTICKS;

f(1) = 15;
f(2) = 25;

fnames = {'clip3_08E_d02_121227_213345.d100.x.wav'};
dirpath = '/Users/cioffi/github/bpvoctool/testclips';
nfile = 1;

[y, fs] = audioread(fullfile(dirpath, fnames{1}));
tf = load('onsloTF/08E_685_120924_invSensit.tf');

nfft = fs;
win = hann(nfft);
adv = nfft / 2;

spectrogram_truthful_labels(y, win, adv, nfft, fs, 'yaxis');
% colorbar off;
set(gca, 'YScale', currentscale);
set(gca, 'YTick', currentticks);

nyq = fs / 2;
[b a] = butter(3, f/nyq);
yf = filtfilt(b, a, y);
spectrogram_truthful_labels(yf, win, adv, nfft, fs, 'yaxis');
% colorbar off;
set(gca, 'YScale', currentscale);
set(gca, 'YTick', currentticks);  
            

[tmpcalls, tmpst, tmpen] = selectcalls(y, fs, 2*fs, fs/2);
[tmpsnr, ~, ~] = calcsnr(tmpst, tmpen, tf, y, fs, f, nfft, win, adv);
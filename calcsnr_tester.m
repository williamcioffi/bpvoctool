%
tf = load('561_090720_invSensit.tf');

%open one of the test files
[fnames, dirpath, nfiles] = openall();
[y fs] = audioread(fullfile(dirpath, fnames{3}));

nyq = fs / 2;

f(1) = 15;
f(2) = 30;

nfft = fs;
win = hann(nfft);
adv = nfft / 2;
spectrogram_truthful_labels(y, win, adv, nfft, fs, 'yaxis');
set(gca, 'YScale', 'log');

[ct, st, en] = selectcalls(y, fs);

[snr, xxb, yy] = calcsnr(st, en, tf, y, fs, f, nfft, win, adv);
xx_sel = [st' st' en' en'] ./ fs;

figure(1);

nfft = fs;
win = hann(nfft);
adv = nfft / 2;
spectrogram_truthful_labels(y, win, adv, nfft, fs, 'yaxis');
set(gca, 'YScale', 'log');

for i = 1:length(st)
    hold on;
    plot(xx_sel(i, :), yy, 'k:');
    
    if(~isnan(xxb(i,1)))    %make sure there is noise box to draw
        plot(xxb(i, :), yy, 'm:');
    end
    
    hold off;
end
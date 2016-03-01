%change this to work with a single click instead and then just go to the
%left and to the right to find the center then recenter.

home = '/Users/cioffi/Documents/developmentofbpvoctool/testclips';
pp = char(strcat(home, filesep, 'clip3_08E_d02_121227_213345.d100.x.wav'));
[y fs] = audioread(pp);


%constants
HALFWINDOW = 2 * fs; % length of window forward from center of call and back from center of call

% these will be the positions in running samples of the file.
runningct = [];
runningst = [];
runningen = [];
runningcount = 0;

nyq = fs / 2;
nfft = 2^(ceil(log2(fs))-1);
win = hann(nfft);
adv = nfft / 2;

spectrogram_truthful_labels(y, win, adv, nfft, fs, 'yaxis');
colorbar off;
set(gca, 'YScale', 'log');

f(1) = 15;
f(2) = 30;

[b a] = butter(3, f/nyq);
yf = filtfilt(b, a, y);

% spectrogram_truthful_labels(yf, win, adv, nfft, fs, 'yaxis');
% colorbar off;
% set(gca, 'YScale', 'log');

done = 0;
while ~done
    count = input('nclass (enter 0 when done) ?> ');
    if count == 0
        done = 1;
    else
        ct = nan(1, count);
        st = nan(1, count);
        en = nan(1, count);
        pt = nan(1, count);

        [a, b] = ginput(count);
        runningcount = runningcount + count;
        
        pt = floor(a * fs);
        st = pt - HALFWINDOW;
        en = pt + HALFWINDOW - 1;
        
        xx = [st   st   en   en  ] ./ fs;
        yy = [f(1) f(2) f(2) f(1)];
        
        hold on;
        plot(xx, yy, 'k:');
        hold off;
        
        for i=1:count
            text(xx(i, 2), yy(2), num2str(i), 'color', 'red');
            clip = st(i):en(i);
            peak = max(abs(yf(clip)));
            ct(i) = clip(find(abs(yf(clip)) == peak));
            
            st(i) = ct(i) - HALFWINDOW;
            en(i) = ct(i) + HALFWINDOW - 1;
        end

        runningct = [runningct ct];
        runningst = [runningst st];
        runningen = [runningen en];
    end
end

% take a look at clips.


nclips = length(runningct);
part = ceil(sqrt(nclips));
dims = [part part];
difference = part^2 - nclips;

if(difference >= part & part*(part - 1) >= nclips)
    dims = [part - 1 part];
end

figure;
spectrogram_truthful_labels(y, win, adv, nfft, fs, 'yaxis');
colorbar off;
set(gca, 'YScale', 'log');

hold on;
for i=1:nclips
    xx = [runningst(i) runningst(i) runningen(i) runningen(i)] ./ fs;
    yy = [f(1) f(2) f(2) f(1)];
    
    plot(xx, yy, 'k:');
    text(xx(2), yy(2), num2str(i), 'color', 'red');
end
hold off;

figure;
for i=1:nclips
    ytmp = yf(runningst(i):runningen(i));
    
    subplot(dims(1), dims(2), i);
    plot(runningst(i):runningen(i), ytmp);
    hold on;
    text(0.05, 0.925, num2str(i), 'Units', 'normalized');
    plot(runningct(i), 0, 'm*');
    hold off
end

function [runningct] = selectcalls(y, fs)
% SELECTCALLS functional version of viewclips
%   last updated: 16Mar2016
%~wrc

%constants
nyq = fs / 2;
HALFWINDOW = 2 * fs; % length of window forward from center of call and back from center of call

% these will be the positions in running samples of the file.
runningct = [];
runningst = [];
runningen = [];

% make a filtered version of the clip to pull the call from
f(1) = 15;
f(2) = 30;
[b a] = butter(3, f/nyq);
yf = filtfilt(b, a, y);

% don't need y anymore after make yf
clear y;

% spectrogram_truthful_labels(yf, win, adv, nfft, fs, 'yaxis');
% colorbar off;
% set(gca, 'YScale', 'log');

runningcount = 1;
done = 0;
while ~done
    count = input('ncalls (enter 0 when done) ?> ');
    if count == 0
        done = 1;
    else
        ct = nan(1, count);
        st = nan(1, count);
        en = nan(1, count);
        pt = nan(1, count);

        [a, b] = ginput(count);
        
        pt = floor(a * fs)';
        st = pt - HALFWINDOW;
        en = pt + HALFWINDOW - 1;
        
        xx = [st'   st'   en'   en'] ./ fs;
        yy = [f(1) f(2) f(2) f(1)];
        
        for i=1:count
            text(xx(i, 2), yy(2), num2str(runningcount), 'color', 'red');
            hold on;
            plot(xx(i,:), yy, 'k:');
            hold off;
            
            runningcount = runningcount + 1;
            
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
for i=1:nclips
    ytmp = yf(runningst(i):runningen(i));
    
    subplot(dims(1), dims(2), i);
    plot(runningst(i):runningen(i), ytmp);
    hold on;
    text(0.05, 0.925, num2str(i), 'Units', 'normalized');
    plot(runningct(i), 0, 'm*');
    hold off
end


end

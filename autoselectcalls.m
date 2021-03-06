function [runningct, runningst, runningen, displayst, displayen, buttons] = autoselectcalls(y, fs, lookwin, returnwindow)

%constants
CHAU_TRESHOLD = 200;
nyq = fs / 2;
nfft = fs;
win = hann(nfft);
adv = nfft / 2;

%these will be the positions in running samples of the file
runningct = [];
runningst = [];
runningen = [];
displayst = [];
displayen = [];
buttons = [];

% make a filtered version of the clip to pull the call from
f(1) = 15;
f(2) = 30;
[b a] = butter(3, f/nyq);
yf = filtfilt(b, a, y);

%calculate fft
[~, ~, T, P] = spectrogram(y, win, adv, nfft, fs, 'yaxis');
p19 = P(20, :);
p19norm = p19 ./ max(p19);

%find peaks
chaudet = chau(p19norm, CHAU_TRESHOLD);
hitdif = chaudet(2:end) - chaudet(1:(end-1));
dese = 1 + [0 find(hitdif > 2)];

a = T(chaudet(dese));
a = a';
count = length(a);
button = repmat(0, 1, count)';

ct = nan(1, count);
st = nan(1, count);
en = nan(1, count);
pt = nan(1, count);

pt = floor(a * fs)';
st = pt - lookwin;
en = pt + lookwin - 1;

% checking to make sure you clicked in the right place
% is there a better way to do this?
dese = find(st > length(yf));
if ~isempty(dese)
    st(dese) = length(yf) - lookwindow*2;
end

dese = find(en > length(yf));

if ~isempty(dese)
    en(dese) = length(yf);
end

dese = find(st < 1);

if ~isempty(dese)
    st = 1;
end

dese = find(en < 1);

if ~isempty(dese)
    en = lookwindow*2;
end
%end of checking to see if you clicked in the right place

displayst = st;
displayen = en;
% xx = [st' st' en' en' st'] ./ fs;
% yy = [f(1) f(2) f(2) f(1) f(1)];

runningcount = 1;

for i=1:count
%     hold on;
%     plot(xx(i, :), yy, 'w');
%     hold off;
%     t = text(st(i) / fs, 35, num2str(i));
%     t.Color = [1 1 1];
    
    runningcount = runningcount + 1;
    clip = st(i):en(i);
    clip = st(i):en(i);
    peak = max(abs(yf(clip)));
    ct(i) = clip(find(abs(yf(clip)) == peak));

    st(i) = ct(i) - returnwindow;
    en(i) = ct(i) + returnwindow - 1;

    % checking to make sure you clicked in the right place
    % is there a better way to do this?
    % makes me feel weird that i have to do this twice
    if st(i) > length(yf);
        st(i) = length(yf) - returnwindow*2;
    end

    if en(i) > length(yf)
        en(i) = length(yf);
    end

    if st(i) < 1
        st(i) = 1;
    end

    if en(i) < 1
        en(i) = returnwindow*2;
    end
    %end of checking to see if you clicked in the right place
end

runningct = [runningct ct];
runningst = [runningst st];
runningen = [runningen en];
buttons   = [buttons button];


% nclips = length(runningct);
% part = ceil(sqrt(nclips));
% dims = [part part];
% difference = part^2 - nclips;
% 
% if(difference >= part & part*(part - 1) >= nclips)
%     dims = [part - 1 part];
% end
% 
% figure('position', [400 400 600 500]);
% for i=1:nclips
%     ytmp = yf(runningst(i):runningen(i));
%     
%     subplot(dims(1), dims(2), i);
%     plot(runningst(i):runningen(i), ytmp);
%     hold on;
%     text(0.05, 0.925, num2str(i), 'Units', 'normalized');
%     plot(runningct(i), 0, 'm*');
%     hold off
% end
% end

% figure;
% subplot 311;
% spectrogram_truthful_labels(y, win, adv, nfft, fs, 'yaxis');
% colorbar off;
% set(gca, 'YScale', 'log');
% set(gca, 'Ylim', [15 25]);
% caxis([-120 -60]);
% hold on;
% plot(a', 20, '*');
% hold off;
% subplot 312;
% plot(yf ./ max(abs(yf)))
% hold on;
% plot(T*fs, p19norm)
% plot(a'*fs, 0.8, '*');
% hold off;
% subplot 313;
% plot(p19norm);
% hold on;
% plot(chaudet, .5, '*');
% hold off;

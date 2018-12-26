minsorsecs = 1; %60 if minutes, 1 if secs
hzorno = 1; % 1000 if khz, 1 if hz

[u fs] = audioread('W:\clips\clip3_08E_d02_121227_213345.d100.x.wav');
st = 1;
en = 2^(ceil(log2(length(u))) - 1);
y = u(st:en);
ny = length(y);

nyq = fs / 2;

nfft = 2^(ceil(log2(fs))-1);
win = hann(nfft);
adv = nfft / 2;

spectrogram(y, win, adv, nfft, fs, 'yaxis');
colorbar off;
set(gca, 'YScale', 'log');

sanitary = 0;
while(~sanitary)
    count = input('ncalls ?> ');
    if isempty(count)
        break;
    elseif count > 0 & count <= 20
        sanitary = 1;
    end
end



ct = nan(1, count);
st = nan(1, count);
en = nan(1, count);
yfs = {};
res = nan(count, 4);
cum = {};

for i=1:count

res(i,:) = getrect;
re = res(i,:);

xx = [re(1) re(1)+re(3)];
yy = [re(2) re(2)+re(4)];
xxx = [xx(1) xx(1) xx(2) xx(2) xx(2) xx(2) xx(1) xx(1) xx(1) xx(1)];
yyy = [yy(1) yy(1) yy(1) yy(1) yy(2) yy(2) yy(2) yy(2) yy(1) yy(1)];

hold on;
plot(xxx, yyy, 'k:');
text(xx(1), yy(2), num2str(i), 'color', 'red');
hold off;


x = floor([re(1) re(1)+re(3)] * minsorsecs * fs);
f = [re(2) re(2)+re(4)] * hzorno;
df = f(2) - f(1);
fbuf = df*0.10;

f(1) = floor(f(1) - fbuf);
f(2) = ceil(f(2) + fbuf);

[b a] = butter(3, f/nyq);
yf = filtfilt(b, a, y);
yfs{i} = yf;

clip = x(1):x(2);
peak = max(abs(yf(clip)));
ct(i) = clip(find(abs(yf(clip)) == peak));
nyf = length(yf(clip));
newpow = floor(log(nyf) / log(2)); 

st(i) = ct(i) - 2^(newpow - 1);
en(i) = ct(i) + 2^(newpow - 1) - 1;
end

nclips = length(yfs);

part = ceil(sqrt(nclips));
dims = [part part];
difference = part^2 - nclips;
    
if difference >= part & part*(part-1) >= nclips
    dims = [part - 1 part];
end
    
figure;
    
for i=1:nclips
    ytmp = yfs{i};
    ytmpclip = ytmp(st(i):en(i));
    re = res(i, :);
    
    subplot(dims(1), dims(2), i);
    plot(st(i):en(i), ytmpclip);
    hold on;
    text(.05, .925, num2str(i), 'Units', 'normalized');
    plot(ct(i), 0, 'm*');
    hold off;
end



% figure;
%     
% for i=1:nclips
%     ytmp = yfs{i};
%     ytmpclip = ytmp(st(i):en(i));
%     re = res(i, :);
    
%     uu = ytmpclip;
%     nu = length(uu);
%     
%      cum = nan(1, nu);
%      for j=1:nu
%         cum(j) = sum(uu(1:j).^2);
%      end
%      
%      qqs = [max(cum)*.10 max(cum)*.50 max(cum)*.90];
%      nqqs = length(qqs);
%  
%      %find the time points
%      for j=1:nqqs
%         qt(j) = find(abs(cum - qqs(j)) == min(abs(cum - qqs(j))));
%      end
      
    
%     subplot(dims(1), dims(2), i);
%     spectrogram(ytmpclip, win, adv, nfft, fs, 'yaxis');
%     xl = xlim;
%     yl = ylim;
%     axis([xl re(2) re(2) + re(4)])
%     colorbar off;
    %axis([st(i)/fs/60 en(i)/fs/60 re(2) re(2)+re(4)]);

%     figure;
%     subplot 211;
%     spectrogram(y, win, adv, nfft, fs, 'yaxis');
%     colorbar off;
%     axis([st(i)/fs/60 en(i)/fs/60 re(2) re(2)+re(4)]);
%     
%     subplot 212;
%     plot(st(i):en(i), ytmpclip);
%     hold on;
%     plot(ct(i), 0, 'm*');
%     hold off;
%     
%     clear ytmp;
%     clear ytmpclip;
% end


% clip = st:en;
% yfclip = yf(clip);
% 
% [p w] = pwelch(y(clip), win, adv, nfft, fs);
% 
% figure;
% subplot 311;
% spectrogram(y, win, adv, nfft, fs, 'yaxis');
% colorbar off;
% axis([st/fs/60 en/fs/60 re(2) re(2)+re(4)]);
% % set(gca, 'YScale', 'log');
% subplot 312;
% plot(clip, yf(clip));
% hold on
% plot(ct, 0, 'm*');
% hold off;
% subplot 313;
% loglog(w, p);
% hold on;
% plot(f, [10^-10 10^-10], 'm*');
% hold off;
% 
% end

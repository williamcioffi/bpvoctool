% take a list of detections and automatically identify those stretches as
% bp included.

%import 01A_det.csv
%cols are smon sday syear shour smin ssec emon eday eyear ehour emin esec

m = csvread('01A_det.csv', 2);
smon    = m(:, 1);
sday    = m(:, 2);
syear   = m(:, 3);
shour   = m(:, 4);
smin    = m(:, 5);
ssec    = m(:, 6);
emon    = m(:, 7);
eday    = m(:, 8);
eyear   = m(:, 9);
ehour   = m(:, 10);
emin    = m(:, 11);
esec    = m(:, 12);

syear = syear - 2000;
eyear = eyear - 2000;

dnumstdet = datenum(syear, smon, sday, shour, smin, ssec);
dnumendet = datenum(eyear, emon, eday, ehour, emin, esec);

[fnames, dirpath, nfiles] = openall();
[stretchst, stretchen, stretchsrc, stretchdst, stretchden] = loadxwavs(fnames, dirpath, nfiles);
nstretches = length(stretchst);
bp_positive = [];

for i=1:length(dnumstdet)
    cur_dnumstdet = dnumstdet(i);
    cur_dnumendet = dnumendet(i);
    
    timedifst = stretchdst - cur_dnumstdet;
    timedifst(timedifst > 0) = NaN;
    st = find(min(abs(timedifst)) == abs(timedifst));
    
    timedifen = stretchden - cur_dnumendet;
    timedifen(timedifen < 0) = NaN;
    en = find(min(abs(timedifen)) == abs(timedifen));
    
    if ~isnan(st) | ~isnan(en)
        bp_positive = [bp_positive st:en]; 
    end
end

% take a list of detections and automatically identify those stretches as
% bp included.

%import 08E.csv
%cols are smon sday syear shour smin ssec emon eday eyear ehour emin esec

function [bp_positive] = id_bp_det_auto(readfile, stretchdst, stretchden)

m = csvread(readfile, 2);
syear   = m(:, 1);
smon    = m(:, 2);
sday    = m(:, 3);
shour   = m(:, 4);
smin    = m(:, 5);
ssec    = m(:, 6);
eyear   = m(:, 7);
emon    = m(:, 8);
eday    = m(:, 9);
ehour   = m(:, 10);
emin    = m(:, 11);
esec    = m(:, 12);

syear = syear - 2000;
eyear = eyear - 2000;

dnumstdet = datenum(syear, smon, sday, shour, smin, ssec);
dnumendet = datenum(eyear, emon, eday, ehour, emin, esec);

nstretches = length(stretchdst);
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
    
    if ~isnan(st) || ~isnan(en)
        bp_positive = [bp_positive st:en]; 
    end
end

end

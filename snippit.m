% snippit to make data table

hits = ~cellfun('isempty', callpos);
hits = find(hits == 1);

nhits = length(hits);

time    = [];
timesec = [];
timedif = [];
snr     = [];
src     = [];

for i = 1:nhits
    cur = hits(i);
    
    cursnr   = callsnr{cur};
    curcalls = callpos{cur};
    dst      = stretchdst(cur);
    seccalls  = curcalls / fs;
    daycalls = seccalls / 60 / 60 / 24;
    calld    = dst + daycalls;
    
    tmpsnr       = cursnr;
    tmptime    = calld;
    tmptimesec = seccalls;
    tmptimedif = [0 (seccalls(2:end) - seccalls(1:(end - 1)))];
    tmpsrc       = repmat(stretchsrc(cur), 1, length(curcalls));
    
    
    snr     = [snr tmpsnr];
    time    = [time tmptime];
    timesec = [timesec tmptimesec];
    timedif = [timedif tmptimedif];
    src     = [src tmpsrc];
    
end

src = fnames(src);
time = datestr(time);
timesec = timesec';
timedif = timedif';
snr = snr';
src = src';

t = table(time, timesec, timedif, snr, src);
writetable(t, 'out.csv');
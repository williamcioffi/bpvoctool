%this is a routine to output a CSV file with the date, time, buttonclick,
%and SNR of selected calls


%first load in the saved file
uiopen();
f                   = savedvars{1};
lookwin             = savedvars{2};
returnwin           = savedvars{3};
currentscale        = savedvars{4};
currentticks        = savedvars{5};
map                 = savedvars{6};
contrastauto        = savedvars{7};
cmin                = savedvars{8};
cmax                = savedvars{9};
curname             = savedvars{10};
bpname              = savedvars{11};
baname              = savedvars{12};
currentstretch      = savedvars{13};
containsbp          = savedvars{14};
containsba          = savedvars{15};
callpos             = savedvars{16};
callpos_marktype    = savedvars{17};
detectpos           = savedvars{18};
callsnr             = savedvars{19};
y                   = savedvars{20};
fs                  = savedvars{21};
nfft                = savedvars{22};
win                 = savedvars{23};
adv                 = savedvars{24};
bits                = savedvars{25};
nfiles              = savedvars{26};
dirpath             = savedvars{27};
fnames              = savedvars{28};
stretchst           = savedvars{29};
stretchen           = savedvars{30};
stretchsrc          = savedvars{31};
stretchdst          = savedvars{32};
stretchden          = savedvars{33};
nstretches          = savedvars{34};
transferfunction    = savedvars{35};
clipplayer          = savedvars{36};
fileprefix          = savedvars{37};
            
            
%which stretches have calls?
desehavecalls = cellfun(@isempty, callpos);
desehavecalls = find(desehavecalls ~= 1);
ndesehavecalls = length(desehavecalls);

pfs = [];
tf = transferfunction;
cal_freq = tf(:, 1);
cal_dB = tf(:, 2);
freqwin = 15:50 + 1;

%start the megaloop going through stretches one by one for peaks
wb = waitbar(0, strcat('calculating peaks... ', num2str(0), '/', num2str(ndesehavecalls)));
for i=1:ndesehavecalls
waitbar(i/ndesehavecalls, wb, strcat('calculating peaks... ', num2str(i), '/', num2str(ndesehavecalls)));
    currentstretch = desehavecalls(i);
    
    [y, fs] = loadstretch(stretchst(currentstretch), ...
                          stretchen(currentstretch), ...
                          stretchsrc(currentstretch, :), ...
                          dirpath, fnames);
                      
    returnwindow = returnwin*fs;
    ct = callpos{currentstretch};
    st = ct - returnwindow;
    en = ct + returnwindow - 1;
    
    %makeing sure the window fits on the screen
    for p=1:length(ct)
        if st(p) > length(y)
            st(p) = length(y) - returnwindow*2;
        end

        if en(p) > length(y)
            en(p) = length(y);
        end

        if st(p) < 1
            st(p) = 1;
        end

        if en(p) < 1
            en(p) = returnwindow*2;
        end
    end
    %end of making sure the window fits on the screen
    
    for q=1:length(st)
        ys = y(st(q):en(q));

        [pxx fff] = pwelch(ys, win, adv, nfft, fs);
        pxx_db = 10*log10(pxx);
        %semilogx(fff, pxx_db);

        % interpolate the transfer function so that it matches the pxx
        ptf = interp1(cal_freq, cal_dB, fff, 'linear', 'extrap');

        % just add them together
        pxx_db_cal = ptf + pxx_db;

        %find the peak
        [mm ii] = max(pxx_db_cal(freqwin));
        peakfreq = freqwin(ii) - 1;

        pfs = [pfs peakfreq];
    end
end
close(wb);

datenumbers = [];
datestrings = [];
year = [];
month = [];
day = [];
hour = [];
min = [];
sec = [];
buttonclick = [];
snr = [];
stretchid = [];

wb = waitbar(0, strcat('tabulating... ', num2str(0), '/', num2str(ndesehavecalls)));
for i=1:ndesehavecalls
waitbar(i/ndesehavecalls, wb, strcat('tabulating... ', num2str(i), '/', num2str(ndesehavecalls)));
    cur = desehavecalls(i);
    
    startdate = stretchdst(cur);
    calldates = callpos{cur}/fs/60/60/24 + startdate;
    
    datestrings = [datestrings; datestr(calldates, 'mm/dd/yyyy HH:MM:SS')];
    year    = [year;    datestr(calldates, 'yyyy') ];
    month   = [month;   datestr(calldates, 'mm')   ];
    day     = [day;     datestr(calldates, 'dd')   ];
    hour    = [hour;    datestr(calldates, 'HH')   ];
    min     = [min;     datestr(calldates, 'MM')   ];
    sec     = [sec;     datestr(calldates, 'SS')   ];
    
    datenumbers = [datenumbers calldates];
    buttonclick = [buttonclick callpos_marktype{cur}];
    snr = [snr callsnr{cur}];
    
    stretchid = [stretchid repmat(cur, 1, length(calldates))];
end

%convert to nums or strings depending
datestrings = cellstr(datestrings);
year        = str2num(year);
month       = str2num(month);
day         = str2num(day);
hour        = str2num(hour);
min         = str2num(min);
sec         = str2num(sec);

%sort the datenums
[datenumbers_sort oo] = sort(datenumbers);

%calculate time differences
timedif = [NaN datenumbers_sort(2:end) - datenumbers_sort(1:(end-1))];
timedif = timedif*24*60*60;

%sort everything
datestrings = datestrings(oo);
year        = year(oo);
month       = month(oo);
hour        = hour(oo);
min         = min(oo);
sec         = sec(oo);
snr         = snr(oo);
stretchid   = stretchid(oo);
buttonclick = buttonclick(oo);
peakfreqs   = pfs(oo);

%flip everything into n x 1 r x c.
buttonclick = buttonclick';
snr         = snr';
stretchid   = stretchid';
timedif     = timedif';
peakfreqs   = peakfreqs';

%make a table
tab = table(datestrings, year, month, day, hour, min, sec, buttonclick, snr, stretchid, peakfreqs, timedif);

%close the bar
close(wb);

%output the file
[fname, fpath] = uiputfile('*.csv', 'save call table', 'calltable.csv');
writetable(tab, fullfile(fpath, fname));

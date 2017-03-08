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

timedif = [NaN datenumbers(2:end) - datenumbers(1:(end-1))];
timedif = timedif*24*60*60;

datestrings = cellstr(datestrings);
year        = str2num(year);
month       = str2num(month);
day         = str2num(day);
hour        = str2num(hour);
min         = str2num(min);
sec         = str2num(sec);

buttonclick = buttonclick';
snr         = snr';
stretchid   = stretchid';
timedif     = timedif';

tab = table(datestrings, year, month, day, hour, min, sec, buttonclick, snr, stretchid, timedif);

close(wb);

[fname, fpath] = uiputfile('*.csv', 'save call table', 'calltable.csv');
writetable(tab, fullfile(fpath, fname));

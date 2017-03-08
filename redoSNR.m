%this is a routine to go back and calculate SNR if you haven't been doing
%it but have detected calls

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

%start the megaloop going through stretches one by one

for i=1:ndesehavecalls
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
    if st(i) > length(y)
        st(i) = length(y) - returnwindow*2;
    end

    if en(i) > length(y)
        en(i) = length(y);
    end

    if st(i) < 1
        st(i) = 1;
    end

    if en(i) < 1
        en(i) = returnwindow*2;
    end
    %end of making sure the window fits on the screen
    
    [tmpsnr, ~, ~] = calcsnr(st, en, transferfunction, y, fs, f, nfft, win, adv);
    callsnr{currentstretch} = tmpsnr;
    
end

savedvars = {                         ...
                f,                    ...
                lookwin,              ...
                returnwin,            ...
                currentscale,         ...
                currentticks,         ...
                map,                  ...
                contrastauto,         ...
                cmin,                 ...
                cmax,                 ...
                curname,              ...
                bpname,               ...
                baname,               ...
                currentstretch,       ...
                containsbp,           ... 
                containsba,           ...
                callpos,              ...
                callpos_marktype      ...
                detectpos,            ...
                callsnr,              ...
                y,                    ...
                fs,                   ...
                nfft,                 ...
                win,                  ...
                adv,                  ...
                bits,                 ...
                nfiles,               ...
                dirpath,              ...
                fnames,               ...
                stretchst,            ...
                stretchen,            ...
                stretchsrc,           ...
                stretchdst,           ...
                stretchden,           ...
                nstretches,           ...
                transferfunction,     ...
                clipplayer,           ...
                fileprefix            ...
              };
uisave('savedvars', 'savedsession'); 

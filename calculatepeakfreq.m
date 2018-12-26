
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

%start the megaloop going through stretches one by one

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



% [S, F, T, P] = spectrogram(y, win, adv, nfft, fs, 'yaxis');
% colormap(map);
% %colorbar off;
% set(gca, 'YScale', 'log');
% set(gca, 'YTick', 1:30);  
% 
% P_db = 10*log10(P);
% 
% fst = find(F == 15);
% fen = find(F == 30);
% 
% q = 4;
% 
% 
% tst = find(floor(2*st(q) / fs)/2 == T);
% ten = find(ceil(2*en(q) / fs)/2 == T);
% 
% clip = P_db(fst:fen, tst:ten);
% 
% [mm ii] = max(clip(:));
% ncols = length(clip(1,:));
% row = ceil(ii / ncols);
% 
% rowstochoose = fst:fen;
% row = rowstochoose(row);
% F(row)

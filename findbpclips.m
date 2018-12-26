function findbpclips()
% FINDBPCLIPS this is a proto-app for measuring bp calls.
% currently:
%
% f -- open a directory find all xwavs and split them into chuncks 
%(stretches) based on cpmtomis stretcjes om duty cycled data (tend to be
% about 5 minutes). If the whole xwav is continuous it splits it into 5 min
% stretches.
%
% s -- save a .mat file of all vars
% o -- open a .mat file of all vars
% z -- save a .wav of current stretch
% p -- save a table of bp calls with info (currently disabled).
%
% m -- mark calls. looks from a second on either side of the click finds
% the peak and saves that position in bppos{index};
% d -- delete marked calls
% q -- display marked calls
%
% b -- mark a stretch as containing at least one bp 20hz call.
% n -- mark a stretch as containing at least one ba train.
%
% g -- go to a particular chunck (by index)
% hjkl -- vim controls (sort of) j k go up and down one stretch h l go up 
% and down one containsbp
%
% t -- load a file of times to mark those stretches as containsbp.
% y -- load xbat detections (currently disabled) and mark strestches as
% containsbp
%
% i -- toggle the spectrogram display between log and linear.
%
% x -- enter debug mode (keyboard).
%
% 1 -- play stretch on screen
% 2 -- pause/resume playing stretch
% 3 -- play at 10x speed (for bp calls)
% 4 -- filter out high freq. and play at 10x speed (for bp calls)
% 
% 0 -- filter spectrogram for bp calls
% r -- redraw current stretch
% 9 -- a contrast/brightness preset I like for bp calls
% 8 -- brighter
% 7 -- darker
% 6 -- more contrast
% 5 -- less contrast
%
% c -- reset contrast and brightness to auto
%
%last updated: 13Feb2017
%~wrc


% to do when you find files make sure to clear all the crucial variables.

%some constants
FILESEP = filesep;
LOGTICKS = [10 15 30 100 500 1000];
LINTICKS = [20 100 250 500 750 1000];
f(1) = 15; %lower freq for fin whale calls
f(2) = 30; %high freq for fin whale calls
lookwin = 2;
returnwin = 1/2;
currentscale = 'log';
currentticks = LOGTICKS;
map = 'parula';   %parula is default colormap
contrastauto = 1;
%contrast and brightness parameters
cmin = []; 
cmax = [];

curname = '';
bpname = '';
baname = '';
currentstretch = -1;        %current screen or 'stretch' tend to be 5 min, unless there is a discontinuity.
containsbp = [];            %is there a bp in the stretch?
containsba = [];            %is there a ba in the stretch?

%these cell arrays represent information about marked calls by stretch. so
%that each index represents one stretch and may contain a vector of
%multiple calls in that stretch. callpos, callpos_marktype, and callsnr
%shoudl all align to each other. detectpos works the same way but is for
%calls imported from an xbat detector using loadxbatdetector function.
callpos = {};               
callpos_marktype = {};     
detectpos = {};             
callsnr = {};
callst = {};
callen = {};
calldisplayst = {};
calldisplayen = {};

%the following refer to the current stretch being displayed
y = [];
fs = [];
nfft = [];
win = [];
adv = [];
bits = [];

%where the files were loaded from
nfiles = 0;
dirpath = '';
fnames = {};

%indexing keys to go between the stretch notation and the actual files and
%positions where those stretches will be found.
stretchst = [];
stretchen = [];
stretchsrc = [];
stretchdst = [];
stretchden = [];

nstretches = 0;

transferfunction = [];
clipplayer = []; %clipplayer which can be used to listen to the current stretch
fileprefix = []; %set a prefix so clips can be saved with sensible filenames
% xwav = NaN;


% create and then hdie the ui as it is being constructed
fig = figure('Visible', 'off', 'Position', [0, 0, 900, 500]);
ha = axes('Units', 'pixels', 'Position', [50,50,800,400]);
ttext = uicontrol('Style', 'text', 'String', curname, 'Position',[20, 465, 700, 15]);
btext = uicontrol('Style', 'text', 'String', bpname, 'Position', [800, 465, 60, 15]);
atext = uicontrol('Style', 'text', 'String', baname, 'Position', [730, 465, 60, 15]);

fig.Units = 'normalized';
ha.Units = 'normalized';
ttext.Units = 'normalized';
btext.Units = 'normalized';
atext.Units = 'normalized';

% assign the name to appear in the window title
fig.Name = '';

% move the window to the center of the screen.
movegui(fig, 'center');

% make the window visible
fig.Visible = 'on';
set(fig, 'KeyPressFcn', @keypress_callback);


% handle keypresses
function keypress_callback(~, eventdata)
    k = eventdata.Key;
    oldcurrentfile = currentstretch;
    
    switch k
%         case 'w'
%             if ~isempty(y)
%                 basefilename = strsplit(fnames{stretchsrc(currentstretch)}, '_');
%                 prefix = strcat(basefilename{1}, '_', basefilename{2}, '_');
%                 datepart = datestr(stretchdst(currentstretch), 'yymmdd_HHMMSS');
%                 extension = '.wav';
%                 writefilename = strcat(prefix, datepart, extension); 
%                 audiowrite(writefilename, y, fs, 'BitsPerSample', bits);
%             end
        case 'q'
            if currentstretch <= length(callpos)
                if ~isempty(callpos{currentstretch})
%                     hold on;
%                     plot(callpos{currentstretch}/fs, 25, '*');
%                     hold off;
                    figure(fig);
                    drawcallboxes(calldisplayst{currentstretch} ./ fs, calldisplayen{currentstretch} ./ fs);
                end
            end
%         case 'w'
%             if currentstretch <= length(detectpos)
%                 hold on;
%                 plot(detectpos{currentstretch}/fs, 25, '*');
%                 hold off;
%             end
        case 'f'
            findfiles();
        case 'o'
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
            callst              = savedvars{38};
            callen              = savedvars{39};
            calldisplayst       = savedvars{40};
            calldisplayen       = savedvars{41};
            
            [y, fs] = redraw();
        case 'z'
            defaultoutfilename = strcat(fileprefix, '_', datestr(stretchdst(currentstretch), 'yyyymmdd_HHMMSS'), '.wav');
            [outfile, outpath] = uiputfile({'*.wav', 'wave file'}, 'save clip..', defaultoutfilename);
            
            if(outpath ~= 0)
                audiowrite(fullfile(outpath, outfile), y, fs, 'BitsPerSample', bits);
            end
        case 's'
                   savedvars = {              ...
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
                        fileprefix,           ...
                        callst,               ...
                        callen,                ...
                        calldisplayst,        ...
                        calldisplayen         ...
                      };
                  uisave('savedvars', 'savedsession');          
        case 'a'
             [tmpcalls, tmpst, tmpen, tmpdisplayst, tmpdisplayen, buttons] = selectcalls(y, fs, lookwin*fs, returnwin*fs);
             
             callpos{currentstretch} = [callpos{currentstretch} tmpcalls];
             callpos_marktype{currentstretch} = [callpos_marktype{currentstretch} buttons'];
             callst{currentstretch} = [callst{currentstretch} tmpst];
             callen{currentstretch} = [callen{currentstretch} tmpen];
             calldisplayst{currentstretch} = [calldisplayst{currentstretch} tmpdisplayst];
             calldisplayen{currentstretch} = [calldisplayen{currentstretch} tmpdisplayen];

             redraw();
             drawcallboxes(calldisplayst{currentstretch} ./ fs, calldisplayen{currentstretch} ./ fs);
             
             seccalls = tmpcalls / fs;
             seccalls = sort(seccalls);
             [seccalls' [0 (seccalls(2:end) - seccalls(1:(end - 1)))]' buttons]
             
             
             if ~isempty(transferfunction)
                [tmpsnr, ~, ~] = calcsnr(tmpst, tmpen, transferfunction, y, fs, f, nfft, win, adv);
                callsnr{currentstretch} = tmpsnr;
                tmpsnr'
             end
             
        case 'm'
            [tmpcalls, tmpst, tmpen, tmpdisplayst, tmpdisplayen, buttons] = autoselectcalls(y, fs, lookwin*fs, returnwin*fs);
            callpos{currentstretch} = tmpcalls;
            callpos_marktype{currentstretch} = buttons';
            callst{currentstretch} = tmpst;
            callen{currentstretch} = tmpen;
            calldisplayst{currentstretch} = tmpdisplayst;
            calldisplayen{currentstretch} = tmpdisplayen;
            
            figure(fig);
            redraw();
            drawcallboxes(calldisplayst{currentstretch} ./ fs, calldisplayen{currentstretch} ./ fs);
            
            seccalls = tmpcalls / fs;
            seccalls = sort(seccalls);
            [seccalls' [0 (seccalls(2:end) - seccalls(1:(end - 1)))]' buttons]
            
            
            if ~isempty(transferfunction)
                [tmpsnr, ~, ~] = calcsnr(tmpst, tmpen, transferfunction, y, fs, f, nfft, win, adv);
                callsnr{currentstretch} = tmpsnr;
                tmpsnr'
            end
            
        case 'g'
            done = 0;
            while ~done
                index = input('go to file ?> ');
                if(index > 0 && index <= nstretches)
                    currentstretch = index;
                    if(currentstretch ~= index)
                        redraw();
                    end
                    done = 1;
                else
                    fprintf('please enter a number between 1 and %i\n', nstretches);
                end
            end
            figure(1);
                
        case 'k'
            currentstretch = currentstretch + 1;
            if(currentstretch > nstretches)
                currentstretch = nstretches;
            end
            
        case 'j'
            currentstretch = currentstretch - 1;
            if(currentstretch < 1)
                currentstretch = 1;
            end
        case 'h'
            if ~isempty(containsbp)
                desebps = find(containsbp == 1);
                currentdif = desebps - currentstretch;
                lowstretch = max(currentdif(currentdif < 0));

                if ~isempty(lowstretch)
                    laststretchwithbp = desebps(lowstretch == currentdif);
                    currentstretch = laststretchwithbp;
                end
            end
        case 'l'
            if ~isempty(containsbp)
                desebps = find(containsbp == 1);
                currentdif = desebps - currentstretch;
                lowstretch = min(currentdif(currentdif > 0));

                if ~isempty(lowstretch)
                    nextstretchwithbp = desebps(lowstretch == currentdif);
                    currentstretch = nextstretchwithbp;
                end
            end
        case 'b'
            switch(containsbp(currentstretch))
                case 0
                    containsbp(currentstretch) = 1;
                case 1
                    containsbp(currentstretch) = 0;
            end
            
            updatename();
        case 'n'
            switch(containsba(currentstretch))
                case 0
                    containsba(currentstretch) = 1;
                case 1
                    containsba(currentstretch) = 0;
            end
            
            updatename();
        case 't'
            % THIS DOES NO ERROR CHECKING FIX THAT LATER
            [csvfilename, csvdirpath] = uigetfile({'*.*'}, dirpath);
            if csvdirpath ~= 0
                csvfilename = strcat(csvdirpath, FILESEP, csvfilename);
                bp_pos_tmp =  id_bp_det_auto(csvfilename, stretchdst, stretchden);
                containsbp(bp_pos_tmp) = 1;
            else
                error('did not find file');
            end 
        case 'y'
            %loadxbatdetections();
        case 'i'
            switch(currentscale)
                case 'log'
                    currentscale = 'linear';
                    currentticks = LINTICKS;
                case 'linear'
                    currentscale = 'log';
                    currentticks = LOGTICKS;
            end
            
            set(gca, 'YScale', currentscale);
            set(gca, 'YTick', currentticks);
        case 'd'
            if ~isempty(callpos)
                lcp = length(callpos{currentstretch});
            
                if lcp ~= 0
                    index = input('delete (index or a=all) ?> ', 's');
                    
                    if index == 'a'
                        fprintf('deleted %i calls\n', lcp);
                        callpos{currentstretch} = [];
                        callst{currentstretch} = [];
                        callen{currentstretch} = [];
                        calldisplayst{currentstretch} = [];
                        calldisplayen{currentstretch} = [];
                        redraw();
                    else
                        index = str2num(index);
                        if all(index > 0 & index <= lcp)
                            fprintf('deleted call #%i\n', index);
                            callpos{currentstretch}(index) = [];
                            callst{currentstretch}(index) = [];
                            callen{currentstretch}(index) = [];
                            calldisplayst{currentstretch}(index) = [];
                            calldisplayen{currentstretch}(index) = [];
                            figure(fig);
                            redraw();
                            drawcallboxes(calldisplayst{currentstretch} ./ fs, calldisplayen{currentstretch} ./ fs);
                        end
                    end
                else
                    fprintf('no calls to delete!\n');
                end
            else
                fprintf('no calls to delete!\n');
            end
                
        case 'x'
            keyboard;
        case '1'
            clipplayer = audioplayer(y/max(abs(y)), fs, bits);
            clipplayer.play();
        case '2'
            if(~isempty(clipplayer))
                if(clipplayer.isplaying())
                    clipplayer.pause();
                else
                    clipplayer.resume();
                end
            end
        case '3'
            clipplayer = audioplayer(y/max(abs(y)), fs*10, bits);
            clipplayer.play();
        case '4'
            nyq = fs / 2;
            [b a] = butter(3, f/nyq);
            yf = filtfilt(b, a, y);
            
            clipplayer = audioplayer(yf/max(abs(yf)), fs*10, bits);
            clipplayer.play();
        case 'p'
        %    getjustbps();
        %    savetableofcalls();
        case '0'
            nyq = fs / 2;
            [b a] = butter(3, f/nyq);
            yf = filtfilt(b, a, y);
            spectrogram(yf, win, adv, nfft, fs, 'yaxis');
            colormap(map);
%           colorbar off;
            set(gca, 'YScale', currentscale);
            set(gca, 'YTick', currentticks);  
        case 'r'
            [y, fs] = redraw();
        case 'c'
            contrastauto = 1; %auto contrast
            redraw();
        case '9'
            contrastauto = 0; %manual contrast
            caxis([-100 -60]);
            [cmin cmax] = caxis;
        case '8' % brighter
            contrastauto = 0; %manual contrast
            caxis([cmin - 10 cmax - 10]);
            [cmin cmax] = caxis; 
        case '7' % darker
            contrastauto = 0; %manual contrast
            caxis([cmin + 10 cmax + 10]);
            [cmin cmax] = caxis; 
        case '6' % more contrast
            contrastauto = 0; %manual contrast
            if(cmin + 5 < cmax - 5)
                caxis([cmin + 5 cmax - 5]);
            end
            [cmin cmax] = caxis; 
        case '5' % less contrast
            contrastauto = 0; %manual contrast
            caxis([cmin - 5 cmax + 5]);
            [cmin cmax] = caxis; 
    end
    
    if(oldcurrentfile ~= currentstretch)
        [y, fs] = redraw();
    end
end

function updatename()
    curname = strcat(datestr(stretchdst(currentstretch), 0), '__',      ...
                          num2str(currentstretch), '/',         ...
                          num2str(nstretches), '__',            ...
                          fnames(stretchsrc(currentstretch)));
    
    asterix = ''; %add an asterix if there are marked calls
    if ~isempty(callpos) && length(callpos) >= currentstretch
        if ~isempty(callpos{currentstretch})
            asterix = '*';
        end
    end
    bpname = char(strcat('BP:', num2str(containsbp(currentstretch)), asterix));
    baname = char(strcat('BA:', num2str(containsba(currentstretch))));
    
    %fig.Name = curname;
    btext.String = bpname;
    atext.String = baname;
    ttext.String = curname;
end

function [y, fs] = redraw()
    clipplayer = [];
    updatename();
    
    [y, fs] = loadstretch(stretchst(currentstretch), ...
                         stretchen(currentstretch), ...
                         stretchsrc(currentstretch, :), ...
                         dirpath, fnames);
                     
%    nfft = 2^(ceil(log2(fs))-1);
    nfft = fs;
    win = hann(nfft);
    adv = nfft / 2;
    
    spectrogram(y, win, adv, nfft, fs, 'yaxis');
%   colorbar off;
    colormap(map);
    setcontrast();
    set(gca, 'YScale', currentscale);
    set(gca, 'YTick', currentticks);
end

function getjustbps()
%     dese = find(containsbp == 1);
%     stretchst   = stretchst(dese);
%     stretchen   = stretchen(dese);
%     stretchsrc  = stretchsrc(dese, :);
%     stretchdst  = stretchdst(dese);
%     stretchden  = stretchden(dese);
%     
%     nstretches  = length(stretchst);
%     containsbp  = containsbp(dese);
%     containsba  = containsba(dese);
%     
%     if ~isempty(callpos)
%         highend = length(callpos);
%         dese2 = dese(dese < highend);
%         callpos = callpos{dese2};
%     end
%     
%     if any(currentstretch == dese)
%         currentstretch = find(currentstretch == dese);
%     else
%         currentstretch = 1;
%     end
%     
%     [y, fs] = redraw();
end

function findfiles()        
    [fnames, dirpath, nfiles] = openall();
    xwav = isxwav(fnames);
    
    %loads a transfer function even if we don't have xwavs
    %instead should only do this for xwavs and then when trying to
    %calculate SNR should check to see if wav or xwav and do the right
    %thing. doesn't check to see if the transfer function is legit.
    
    [tffile, tfpath] = uigetfile({'*.tf', 'transfer function'}, 'select a transfer function file', dirpath);
    if(tfpath == 0)
        warning('did not select a transfer function. will not caclulate snr...');
        transferfunction = [];
    else
        transferfunction = load(fullfile(tfpath, tffile));
    end
    
    if(xwav)
        [stretchst, stretchen, stretchsrc, stretchdst, stretchden, fileprefix] = loadxwavs(fnames, dirpath, nfiles);
    else
        [stretchst, stretchen, stretchsrc, stretchdst, stretchden, fileprefix] = loadwavs(fnames, dirpath, nfiles);
    end
    
    nstretches = length(stretchst);
    
    containsbp = zeros(1, nstretches);
    containsba = zeros(1, nstretches);
    
    callpos = {};
    currentstretch = 1;
    
    info = audioinfo(fullfile(dirpath, fnames{1}));
    bits = info.BitsPerSample;
    
    [y, fs] = redraw();
end


%put this in a separate function file that takes parameters
function loadxbatdetections()
[xfile, xpath] = uigetfile({'*.mat'}, dirpath);

if xpath ~= 0
    xsts = load(fullfile(xpath, xfile));
    xsts = xsts.st*fs;
    xsts_info = nan(1, length(xsts));
    here = [];
    for(i = 1:length(xsts))
        tester = xsts(i) - stretchst;
        tester = tester(find(tester >= 0));

        heretmp = find(min(tester) == tester);
        here = [here heretmp];
        xsts_info(i) = heretmp;
    end

    u_heres = unique(xsts_info);

    for(i = 1:length(u_heres))
        cur = u_heres(i);
        dese = find(xsts_info == cur);
        
        if(length(dese) > 5)
            tmppos = xsts(dese) - stretchst(cur);
            detectpos{cur} = tmppos;
            containsbp(cur) = 1;
        end
    end
else
    error('did not find file');
end
end

function setcontrast()
    if contrastauto == 1
        caxis('auto');
        [cmin cmax] = caxis;
    else
        caxis([cmin cmax]);
    end
end

function savetableofcalls()
    %stub to save a table of calls with information
end

end

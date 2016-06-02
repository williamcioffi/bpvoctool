function findbpclips()
% FINDBPCLIPS this is a proto-app for measuring interpulse interval.
% currently:
%
% f -- open a directory find all xwavs and split them into chuncks based on
% contiuous stretches in duty cycled data. the current code does not deal
% with continuous files.
%
% s -- save a .mat file of all information
% o -- open a .mat file of all information
%
% m -- mark calls. looks from a second on either side of the click finds
% the peak and saves that position in bppos{index};
% d -- delete marked calls
% q -- display marked calls
%
% g -- go to a particular chunck (by index)
% hjkl -- vim controls (sortof) j k go up and down one file h l go up and
% down one containsbp
% b -- mark a chunck as containing at least one bp 20hz call.
% n -- mark a chunck as containing at least one ba train.
% t -- load a file of times to mark those chuncks as bp.
% p -- save a table of the calls.
%
% i -- toggle the spectrogram display between log and linear.
%
% x -- enter debug mode.
%
%last updated: 22Mar2016
%~wrc


% to do when you find files make sure to clear all the crucial variables.

%some constants
FILESEP = filesep;
LOGTICKS = [10 15 30 100 500 1000];
LINTICKS = [20 100 250 500 750 1000];
f(1) = 15;
f(2) = 30;
lookwin = 2;
returnwin = 1/2;
currentscale = 'log';
currentticks = LOGTICKS;
map = 'parula';   %parula is default
contrastauto = 1;
cmin = [];
cmax = [];

%some finances
curname = '';
bpname = '';
baname = '';
currentstretch = -1;
containsbp = [];
containsba = [];
callpos = {};
detectpos = {};
callsnr = {};
y = [];
fs = [];
nfft = [];
win = [];
adv = [];
bits = [];
nfiles = 0;
dirpath = '';
fnames = {};
stretchst = [];
stretchen = [];
stretchsrc = [];
stretchdst = [];
stretchden = [];
nstretches = 0;
tf = [];
clipplayer = [];
fileprefix = [];
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
                if ~isempty(callpos{currentsrtech})
                    hold on;
                    plot(callpos{currentstretch}/fs, 25, '*');
                    hold off;
                end
            end
        case 'w'
            if currentstretch <= length(detectpos)
                hold on;
                plot(detectpos{currentstretch}/fs, 25, '*');
                hold off;
            end
        case 'f'
            findfiles();
        case 'o'
            uiopen()
            [y, fs] = redraw();
        case 'z'
            defaultoutfilename = strcat(fileprefix, '_', datestr(stretchdst(currentstretch), 'yyyymmdd_HHMMSS'), '.wav');
            [outfile, outpath] = uiputfile({'*.wav', 'wave file'}, 'save clip..', defaultoutfilename);
            
            if(outpath ~= 0)
                audiowrite(fullfile(outpath, outfile), y, fs, 'BitsPerSample', bits);
            end
        case 's'
            uisave({'stretchst',        ...
                    'stretchen',        ...
                    'stretchsrc',       ...
                    'nstretches',       ...
                    'stretchdst',       ...
                    'currentstretch',   ...
                    'containsbp',       ...
                    'containsba',       ...
                    'callpos',          ...
                    'callsnr',          ...
                    'detectpos',        ...
                    'fnames',           ...
                    'nfiles',           ...
                    'dirpath',          ...
                    'fs',               ...
                    'tf',               ...
                    'bits',             ...
                    'fileprefix'        ...
                    }, 'savedsession');
            
        case 'm'
             [tmpcalls, tmpst, tmpen] = selectcalls(y, fs, lookwin*fs, returnwin*fs);
             callpos{currentstretch} = tmpcalls;
             seccalls = tmpcalls / fs;
             seccalls = sort(seccalls);
             [seccalls' [0 (seccalls(2:end) - seccalls(1:(end - 1)))]']
             
             if ~isempty(tf)
                [tmpsnr, ~, ~] = calcsnr(tmpst, tmpen, tf, y, fs, f, nfft, win, adv);
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
            %containsbp = [];
            %detectpos = {};
            loadxbatdetections();
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
                    fprintf('deleted %i calls\n', lcp);
                    callpos{currentstretch} = [];
                    redraw();
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
            spectrogram_truthful_labels(yf, win, adv, nfft, fs, 'yaxis');
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
    
    spectrogram_truthful_labels(y, win, adv, nfft, fs, 'yaxis');
%   colorbar off;
    colormap(map);
    setcontrast();
    set(gca, 'YScale', currentscale);
    set(gca, 'YTick', currentticks);
end

function getjustbps()
    dese = find(containsbp == 1);
    stretchst   = stretchst(dese);
    stretchen   = stretchen(dese);
    stretchsrc  = stretchsrc(dese, :);
    stretchdst  = stretchdst(dese);
    stretchden  = stretchden(dese);
    
    nstretches  = length(stretchst);
    containsbp  = containsbp(dese);
    containsba  = containsba(dese);
    
    if ~isempty(callpos)
        highend = length(callpos);
        dese2 = dese(dese < highend);
        callpos = callpos{dese2};
    end
    
    if any(currentstretch == dese)
        currentstretch = find(currentstretch == dese);
    else
        currentstretch = 1;
    end
    
    [y, fs] = redraw();
end

function findfiles()        
    [fnames, dirpath, nfiles] = openall();
    % xwav = isxwav(fnames);
    
    [tffile, tfpath] = uigetfile({'*.tf', 'transfer function'}, 'select a transfer function file', dirpath);
    if(dirpath == 0)
        error('did not select a file...');
    else
        tf = load(fullfile(tfpath, tffile));
    end
    
    %if(xwav)
        [stretchst, stretchen, stretchsrc, stretchdst, stretchden, fileprefix] = loadxwavs(fnames, dirpath, nfiles);
    %else
    %    [stretchst, stretchen, stretchsrc, stretchdst, stretchden, fileprefix] = loadwavs(fnames, dirpath, nfiles);
    %end
    
    nstretches = length(stretchst);
    
    containsbp = zeros(1, nstretches);
    containsba = zeros(1, nstretches);
    
    callpos = {};
    currentstretch = 1;
    
    info = audioinfo(fullfile(dirpath, fnames{1}));
    bits = info.BitsPerSample;
    
    [y, fs] = redraw();
end

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

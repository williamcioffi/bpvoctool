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
% hjkl h first l last j left k right
% b -- mark a chunck as containing at least one bp 20hz call.
% n -- mark a chunck as containing at least one ba train.
% t -- load a file of times to mark those chuncks as bp.
% p -- reduce down to just chuncks identified as having bp.
%
% i -- toggle the spectrogram display between log and linear.
%
% x -- enter debug mode.
%
%last updated: 22Mar2016
%~wrc

%some constants
FILESEP = filesep;
f(1) = 15;
f(2) = 30;

%some finances
curname = '';
bpname = '';
baname = '';
currentstretch = -1;
containsbp = 0;
containsba = 0;
callpos = {};
y = 0;
fs = 0;
nfiles = 0;
dirpath = '';
fnames = {};
currentscale = 'log';
stretchst = [];
stretchen = [];
stretchsrc = [];
stretchdst = [];
stretchden = [];
nstretches = 0;


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
        case 'q'
            if currentstretch <= length(callpos)
                hold on;
                plot(callpos{currentstretch}/fs, 20, '*');
                hold off;
            end
        case 'f'
            findfiles();
        case 'o'
            uiopen()
            [y, fs] = redraw();
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
                    'fnames',           ...
                    'nfiles',           ...
                    'dirpath',          ...
                    'fs'                ...
                    }, 'savedsession');
            
        case 'm'
            callpos{currentstretch} = selectcalls(y, fs);
        case 'g'
            done = 0;
            while ~done
                index = input('go to file ?> ');
                if(index > 0 & index <= nstretches)
                    currentstretch = index;
                    if(currentstretch ~= index)
                        redraw();
                    end
                    done = 1;
                else
                    fprintf('please enter a number between 1 and %i\n', nstretches);
                end
            end
                
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
            [csvfilename, csvdirpath] = uigetfile(dirpath);
            csvfilename = strcat(csvdirpath, FILESEP, csvfilename);
            bp_pos_tmp =  id_bp_det_auto(csvfilename, stretchdst, stretchden);
            containsbp(bp_pos_tmp) = 1;
        case 'i'
            switch(currentscale)
                case 'log'
                    currentscale = 'linear';
                case 'linear'
                    currentscale = 'log';
            end
            
            set(gca, 'YScale', currentscale);
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
        case 'p'
            getjustbps();
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
                      
    bpname = char(strcat('BP:', num2str(containsbp(currentstretch))));
    baname = char(strcat('BA:', num2str(containsba(currentstretch))));
    
    %fig.Name = curname;
    btext.String = bpname;
    atext.String = baname;
    ttext.String = curname;
end

function [y, fs] = redraw()
    updatename();
    
    [y, fs] = loadstretch(stretchst(currentstretch), ...
                         stretchen(currentstretch), ...
                         stretchsrc(currentstretch, :), ...
                         dirpath, fnames);
                     
    nfft = 2^(ceil(log2(fs))-1);
    win = hann(nfft);
    adv = nfft / 2;
    
    spectrogram_truthful_labels(y, win, adv, nfft, fs, 'yaxis');
%   colorbar off;
    set(gca, 'YScale', currentscale);
    set(gca, 'YTick', [10 15 30 100 500 1000]);
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
    [stretchst, stretchen, stretchsrc, stretchdst, stretchden] = loadxwavs(fnames, dirpath, nfiles);
    nstretches = length(stretchst);
    
    containsbp = zeros(1, nstretches);
    containsba = zeros(1, nstretches);
    
    callpos = {};
    currentstretch = 1;
    [y, fs] = redraw();
end

end

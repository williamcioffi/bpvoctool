% this is a proto workflow for measuring the interpulse interval
% first use chunckchecker to split up the clips
% then go through each five minute clip and identify if there are bp there
% are not
% then go through only those clips that have bp and measure the interpulse
% interval.
% 	last updated: 16Mar2016
%~wrc


function findbpclips()
%some constants
FILESEP = filesep;
f(1) = 15;
f(2) = 30;

%some finances
curname = '';
bpname = '';
currentfile = -1;
containsbp = 0;
callpos = {};
y = 0;
fs = 0;
nfiles = 0;
dirpath = '';
fnames = {};


% create and then hdie the ui as it is being constructed
fig = figure('Visible', 'off', 'Position', [0, 0, 900, 500]);
ha = axes('Units', 'pixels', 'Position', [50,50,800,400]);
ttext = uicontrol('Style', 'text', 'String', curname, 'Position',[20, 465, 400, 15]);
btext = uicontrol('Style', 'text', 'String', bpname, 'Position', [800, 465, 60, 15]);

fig.Units = 'normalized';
ha.Units = 'normalized';
ttext.Units = 'normalized';
btext.Units = 'normalized';

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
    oldcurrentfile = currentfile;
    
    switch k
        case 'f'
            findfiles();
        case 'o'
            uiopen()
            [y, fs] = redraw();
        case 's'
            uisave({'currentfile', 'containsbp', 'callpos', 'fnames', 'nfiles', 'dirpath', 'fs'}, 'savedsession');
            
        case 'm'
            callpos{currentfile} = selectcalls(y, fs);
            
        case 'g'
            done = 0;
            while ~done
                index = input('go to file ?> ');
                if(index > 0 & index <= nfiles)
                    currentfile = index;
                    if(currentfile ~= index)
                        redraw();
                    end
                    done = 1;
                else
                    fprintf('please enter a number between 1 and %i\n', nfiles);
                end
            end
                
        case 'k'
            currentfile = currentfile + 1;
            if(currentfile > nfiles)
                currentfile = nfiles;
            end
            
        case 'j'
            currentfile = currentfile - 1;
            if(currentfile < 1)
                currentfile = 1;
            end
            
        case 'b'
            switch(containsbp(currentfile))
                case 0
                    containsbp(currentfile) = 1;
                case 1
                    containsbp(currentfile) = 0;
            end
            
            updatename();
        case 'x'
            keyboard;
    end
    
    if(oldcurrentfile ~= currentfile)
        [y, fs] = redraw();
    end
end

function updatename()
    curname = char(strcat(num2str(currentfile), '/', num2str(nfiles), ':', fnames(currentfile)));
    bpname = char(strcat('BP:', num2str(containsbp(currentfile))));
    
    %fig.Name = curname;
    btext.String = bpname;
    ttext.String = curname;
end

function [y, fs] = redraw()
    updatename();
    
    currentfilepath = char(strcat(dirpath, FILESEP, fnames(currentfile)));
    [y fs] = audioread(currentfilepath);
    nfft = 2^(ceil(log2(fs))-1);
    win = hann(nfft);
    adv = nfft / 2;
    
    spectrogram_truthful_labels(y, win, adv, nfft, fs, 'yaxis');
%   colorbar off;
    set(gca, 'YScale', 'log');
    set(gca, 'YTick', [10 15 30 100 500 1000]);
end

function findfiles()        
    [fnames, dirpath, nfiles] = openall();
    containsbp = zeros(1, nfiles);
    callpos = {};
    currentfile = 1;
    [y, fs] = redraw();
end

end

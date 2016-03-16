% this is a proto workflow for measuring the interpulse interval
% first use chunckchecker to split up the clips
% then go through each five minute clip and identify if there are bp there
% are not
% then go through only those clips that have bp and measure the interpulse
% interval.
% 	last updated: 16Mar2016
%~wrc


function findbpclips()
FILESEP = filesep;
f(1) = 15;
f(2) = 30;

[fnames, dirpath, nfiles] = openall();
containsbp = zeros(1, nfiles);
currentfile = 1;
curname = char(strcat(num2str(currentfile), '/', num2str(nfiles), ':', fnames(currentfile)));
bpname = char(strcat('BP:', num2str(containsbp(currentfile))));


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
[y, fs] = redraw();


% handle keypresses
function keypress_callback(~, eventdata)
    k = eventdata.Key;
    oldcurrentfile = currentfile;
    
    switch k
        case 'm'
            selectcalls(y, fs);
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
end

% this is a proto workflow for measuring the interpulse interval
% first use chunckchecker to split up the clips
% then go through each five minute clip and identify if there are bp there
% are not
% then go through only those clips that have bp and measure the interpulse
% interval.


function findbyclips()
FILESEP = filesep;
f(1) = 15;
f(2) = 30;

[fnames, dirpath, nfiles] = openall();
containsbp = zeros(1, nfiles);
currentfile = 1;
curname = '';


% create and then hdie the ui as it is being constructed
fig = figure('Visible', 'off', 'Position', [0, 0, 800, 400]);
ha = axes('Units', 'pixels');

fig.Units = 'normalized';
ha.Units = 'normalized';

% assign the name to appear in the window title
fig.Name = 'try this';

% move the window to the center of the screen.
movegui(fig, 'center');

% make the window visible
fig.Visible = 'on';
set(fig, 'KeyPressFcn', @keypress_callback);
redraw();


% handle keypresses
function keypress_callback(~, eventdata)
    k = eventdata.Key;
    oldcurrentfile = currentfile;
    
    switch k
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
                    curname = char(strcat('BP...', fnames(currentfile)));
                    fig.Name = curname;
                case 1
                    containsbp(currentfile) = 0;
                    curname = char(fnames(currentfile));
                    fig.Name = curname;
            end
    end
    
    if(oldcurrentfile ~= currentfile)
        redraw();
    end
end

function updatename()
    switch(containsbp(currentfile))
        case 1
            curname = char(strcat('BP...', fnames(currentfile)));
        case 0
            curname = char(fnames(currentfile));
    end
end

function redraw()
    updatename();
    fig.Name = curname;
    
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

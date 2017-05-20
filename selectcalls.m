function [runningct, runningst, runningen, displayst, displayen, buttons] = selectcalls(y, fs, lookwindow, returnwindow)
% SELECTCALLS functional version of viewclips
% lookwindow and returnwindow are specified in samples
%   last updated: 29Apr2016
%~wrc

%constants
nyq = fs / 2;
%HALFWINDOW = 2 * fs; % length of window forward from center of call and back from center of call

% these will be the positions in running samples of the file.
runningct = [];
runningst = [];
runningen = [];
buttons   = [];

% make a filtered version of the clip to pull the call from
f(1) = 15;
f(2) = 30;
[b a] = butter(3, f/nyq);
yf = filtfilt(b, a, y);

% don't need y anymore after make yf
clear y;

% spectrogram_truthful_labels(yf, win, adv, nfft, fs, 'yaxis');
% colorbar off;
% set(gca, 'YScale', 'log');

runningcount = 1;
%done = 0;
%dlgmsg = 'ncalls (enter 0 when done)';

%while ~done
    %instr = inputdialog('', dlgmsg);
    %[count success] = str2num(instr);
    
    %if ~success
    %    dlgmsg = 'only numbers! (0 when done)';
    %else    
    %    if count == 0
    %        done = 1;
    %    else
    
            [a, b, button] = ginput_white(@drawpoints);
            
            count = length(a);
            
            ct = nan(1, count);
            st = nan(1, count);
            en = nan(1, count);
            pt = nan(1, count);

            pt = floor(a * fs)';
            st = pt - lookwindow;
            en = pt + lookwindow - 1;

            % checking to make sure you clicked in the right place
            % is there a better way to do this?
            dese = find(st > length(yf));
            if ~isempty(dese)
                st(dese) = length(yf) - lookwindow*2;
            end
            
            dese = find(en > length(yf));
            
            if ~isempty(dese)
                en(dese) = length(yf);
            end

            dese = find(st < 1);
            
            if ~isempty(dese)
                st = 1;
            end
            
            dese = find(en < 1);

            if ~isempty(dese)
                en = lookwindow*2;
            end
            %end of checking to see if you clicked in the right place

            displayst = st;
            displayen = en;
%             xx = [st'   st'   en'   en'] ./ fs;
%             yy = [f(1) f(2) f(2) f(1)];

            for i=1:count
                %text(xx(i, 2), yy(2), num2str(runningcount), 'color', 'red');
%                 hold on;
%                 plot(xx(i,:), yy, 'r:');
%                 hold off;

                runningcount = runningcount + 1;

                clip = st(i):en(i);
                peak = max(abs(yf(clip)));
                ct(i) = clip(find(abs(yf(clip)) == peak));

                st(i) = ct(i) - returnwindow;
                en(i) = ct(i) + returnwindow - 1;

                % checking to make sure you clicked in the right place
                % is there a better way to do this?
                % makes me feel weird that i have to do this twice
                if st(i) > length(yf);
                    st(i) = length(yf) - returnwindow*2;
                end

                if en(i) > length(yf)
                    en(i) = length(yf);
                end

                if st(i) < 1
                    st(i) = 1;
                end

                if en(i) < 1
                    en(i) = returnwindow*2;
                end
                %end of checking to see if you clicked in the right place
            end

            runningct = [runningct ct];
            runningst = [runningst st];
            runningen = [runningen en];
            buttons   = [buttons button];
    %end
%end

% take a look at clips.
% 
% nclips = length(runningct);
% part = ceil(sqrt(nclips));
% dims = [part part];
% difference = part^2 - nclips;
% 
% if(difference >= part & part*(part - 1) >= nclips)
%     dims = [part - 1 part];
% end
% 
% figure('position', [400 400 600 500]);
% for i=1:nclips
%     ytmp = yf(runningst(i):runningen(i));
%     
%     subplot(dims(1), dims(2), i);
%     plot(runningst(i):runningen(i), ytmp);
%     hold on;
%     text(0.05, 0.925, num2str(i), 'Units', 'normalized');
%     plot(runningct(i), 0, 'm*');
%     hold off
% end
% 
% 
% end

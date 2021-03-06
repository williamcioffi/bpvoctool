function [datstr] = inputdialog(title, prompt, len)
% INPUTDIALOG a no frills replacement for inputdlg which 
% accepts return as 'OK'
% returns a string

if nargin == 2
    len = 50;
end

datstr = []; % in case the user closes the gui
S.fh = figure('units','pixels',...
              'position',[500 500 200 100],...
              'menubar','none',...
              'numbertitle','off',...
              'name',title,...
              'resize','off');
S.ed = uicontrol('style','edit',...
                 'units','pix',...
                'position', [10 10 len 30]);
                %'string', '0');
                 %'position',[10 60 180 30]);%,...
S.msg = uicontrol('style', 'text', ...
                  'position', [10 50 200 30], ...
                  'String', prompt);
                
set(S.ed,'call',@ed_call)
uicontrol(S.ed) % make the editbox active
uiwait(S.fh) % prevent all other processes from starting until closed

    function [] = ed_call(varargin)
        %drawnow %not sure why you would need to do this?
        datstr = get(S.ed,'string');
        close(S.fh)
    end
end
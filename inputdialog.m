function [datstr] = inputdialog(title, prompt)
% Input dialog. User may hit return after entering info.


datstr = []; % In case the user closes the GUI.
S.fh = figure('units','pixels',...
              'position',[500 500 200 100],...
              'menubar','none',...
              'numbertitle','off',...
              'name',title,...
              'resize','off');
S.ed = uicontrol('style','edit',...
                 'units','pix',...
                'position', [10 10 50 30]);
                %'string', '0');
                 %'position',[10 60 180 30]);%,...
S.msg = uicontrol('style', 'text', ...
                  'position', [10 50 200 30], ...
                  'String', prompt);
                
set(S.ed,'call',@ed_call)
uicontrol(S.ed) % Make the editbox active.
uiwait(S.fh) % Prevent all other processes from starting until closed.

    function [] = ed_call(varargin)
        %drawnow %not sure why you would need to do this?
        datstr = get(S.ed,'string');
        close(S.fh)
    end
end
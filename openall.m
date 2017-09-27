function [fnames dirpath nfiles] = openall()
% OPENALL returns names of wav files in the selected directory
%   usage: [fnames, dirpath, nfiles] = openall();
%       fnames      -- a celery of filenames
%       dirpath     -- a string representing the path to the directory
%                      selected
%       nfiles      -- a 1x1 array containing number of wav files
%
%   last modified: 28Jan2016
%   to do: formal exception handling
%~wrc
%
% holy shit matlab 2017b (at least) did a crazy thing
% where the dir listing is different. Now row 5 is isdir
% before it was row 4. this reverses the behavior of existing code!

fnames = [];
nfiles = [];

dirpath = uigetdir(pwd, 'select input dir');
if(dirpath == 0)
    error('did not select a directory...');
end

files = dir(dirpath);

files_cell = struct2cell(files);
fnames = files_cell(1, :);

%get rid of directories if there are any
%if using earlier versions of matlab this
%should be row 4. don't worry about how this
%is hard coded right now.
isdir = files_cell(5, :);
keeps = find(cellfun(@(x) x == 0, isdir) == 1);
fnames = fnames(keeps);

% grab only file names which end in .wav
wavs = regexp(fnames, '[.]wav$');
keeps = ~cellfun('isempty', wavs);

if(keeps == 0)
    error('no wav files in directory...');
end

fnames = fnames(keeps);
nfiles = length(fnames);

end

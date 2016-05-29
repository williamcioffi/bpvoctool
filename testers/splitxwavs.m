%function [nouts] = splitxwavs(splitonthemin, INDATEFORMAT, dateindex)

% SPLITXWAVS outputs a directory of wavs split on the specified interval
% when given an input of a directory of x.wavs from a HARP deployment
%   usage: [nouts] = splitxwavs(splitonthemin, INDATEFORMAT, dateindices);
%       splitonthemin    -- split files on a given minute (e.g., 5
%       would indicate to split on the five minutes (real time)
%
%       INDATEFORMAT     -- a valid date format as it appears in the file
%       names. See datenum for details.
%       
%       dateindex        -- the start position of the date in the filename.
%
% Output files are of the format: yyyymmdd_HHMMSS.wav
%
%   last modified: 15Mar2016
%~wrc


%set these first for procedural version (easier to debug) and then convert
%it to functional format later
splitonthemin = 5;
INDATEFORMAT = 'yymmdd_HHMMSS';
dateindex = 14;

FILESEP = filesep;
% make sure you use the right fileseperator
% \ on windows
% / on every other sensibile operating system

% some constants
outdirname = 'out';
datest = dateindex;
dateen = dateindex + length(INDATEFORMAT);
outdateformat = 'yyyymmdd_HHMMSS';

%get input files
[infilenames dirpath nfiles] = openall();

%get fs and bit rate and fileprefix
info = audioinfo(strcat(dirpath, FILESEP, infilenames{1}));
fs = info.SampleRate;
bits = info.BitsPerSample;
fileprefix = infilenames{1}(1:(dateindex-1));

%make a new directory for outs
outdirpath = uigetdir(dirpath, 'select output dir');
if(outdirpath == 0)
    error('did not select a directory...');
end
[success] = mkdir(outdirpath, outdirname);
if(success ~= 1)
    error('error creating new directory. do you have write permission?');
end

newpath = strcat(outdirpath, FILESEP, outdirname, FILESEP);

%make an empty vector for the start datetimes to live in
dd = nan(1, nfiles);

for i=1:nfiles
    fn_ch = char(infilenames(i));
    dd = datenum(fn_ch(datest:dateen), INDATEFORMAT);
    info = audioinfo(strcat(dirpath, FILESEP, infilenames{i}));
    filelength = info.TotalSamples;
    
    st = 1;
    en = 1;
    
    while en < filelength
        year = str2num(datestr(dd, 'yyyy'));
        month = str2num(datestr(dd, 'mm'));
        day = str2num(datestr(dd, 'dd'));
        hh = str2num(datestr(dd, 'HH'));
        mm = str2num(datestr(dd, 'MM'));
        ss = str2num(datestr(dd, 'SS'));
    
        outfilename = strcat(fileprefix, datestr(dd, outdateformat), '.wav');
        ofi = char(strcat(newpath, outfilename));
                    
        nearestmm = ceil((mm + (ss + 1)/60) / splitonthemin) * splitonthemin;
    
        datenumofsplit = datenum(year, month, day, hh, nearestmm, 00);
        timedif = datenumofsplit - dd(1);
        
        en = st + round(timedif*24*60*60) * fs - 1;
        
        if(en < filelength)
            [y fs] = audioread(strcat(dirpath, FILESEP, infilenames{i}), [st en]);
            audiowrite(ofi, y, fs, 'BitsPerSample', bits);
            dd = datenumofsplit;
            st = en + 1;
        else
            en = filelength;
            [y fs] = audioread(strcat(dirpath, FILESEP, infilenames{i}), [st en]);
            audiowrite(ofi, y, fs, 'BitsPerSample', bits);
        end
    end
end
    


%end

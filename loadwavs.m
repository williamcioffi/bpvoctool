function [stretchst stretchen stretchsrc stretchdst stretchden, fileprefix] = loadwavs(fnames, dirpath, nfiles)
% loads a folder of wavs and sets up stretches
% wrc 10Jul2016

%asks for the date format in the file names, the start index and the
%experiment name because these are hard to figure out otherwise. if you
%enter 0 for the start index of the file format then it just assigns
%arbitrary dates. right now it considers each file a stretch. if you want
%to bridge files with stretches add this functionality later or paste up
%files.

fnames{1} %print an example file so you can see what the indices are

answer = inputdlg({'date format', 'start index', 'exp name'}, ...
                                   '', 1, {'yyyymmdd_HHMMSS', '', ''});
dateformat = answer{1};
startindex = str2num(answer{2});
fileprefix = answer{3};
endindex = startindex + length(dateformat) - 1;

rst = [];
ren = [];
dst = [];
den = [];
srcfile = [];
stretch = [];
    
wb = waitbar(0, strcat('loading files:', ...
num2str(0), '/', num2str(nfiles)));

for fi = 1:nfiles
    currentfilename = fullfile(dirpath, fnames{fi});
    info = audioinfo(currentfilename);
    
    nclips = ceil(info.Duration / 300);
    fs = info.SampleRate;
    
    if(startindex == 0)
        startfiletime = 1;
    else
        startfiletime = datenum(fnames{fi}(startindex:endindex), dateformat);
    end
    
    if(nclips == 1)
        rst = [rst 1];
        ren = [ren info.TotalSamples];
        dst = [dst startfiletime];
        den = [den dst(end) + info.Duration/60/60/24];
        srcfile = [srcfile fi];
    else
        rst = [rst 1];
        ren = [ren 300*fs];
        dst = [dst startfiletime];
        den = [den dst(end) + 300/60/60/24];
        
        srcfile = [srcfile fi];
        
        for i=2:nclips
            rst = [rst ren(end) + 1];
            dst = [dst den(end) + 1/60/60/24];
            
            if(i == nclips)
                ren = [ren info.TotalSamples];
                den = [den startfiletime + info.Duration/60/60/24]; 
            else
                ren = [ren rst(end) + 300*fs];
                den = [den dst(end) + 300/60/60/24];
            end
            
            srcfile = [srcfile fi];
        end
    end
end


nraw = length(srcfile);
stretch = srcfile;

ustretch = unique(stretch);
nstretch = length(ustretch);
 
stretchst = ustretch * NaN;
stretchen = ustretch * NaN;
stretchsrc = nan(nstretch, 2);
stretchdst = nan(nstretch, 1);
stretchden = nan(nstretch, 1);
 
for i=1:nstretch
     curstretch = find(stretch == ustretch(i));
     stretchst(i) = rst(curstretch(1));
     stretchen(i) = ren(curstretch(end));
     stretchsrc(i, 1) = srcfile(curstretch(1));
     stretchsrc(i, 2) = srcfile(curstretch(end));
     stretchdst(i) = dst(curstretch(1));
     stretchden(i) = den(curstretch(end));
end
close(wb);

end

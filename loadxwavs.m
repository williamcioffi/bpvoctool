function [stretchst stretchen stretchsrc stretchdst stretchden] = loadxwavs(fnames, dirpath, nfiles)
% loads a folder of xwavs and sets up stretches
% still experimental so it has a dumb name change that later
% only returns information about stretches right now but could easily be
% changed to also return the datenum values for each stretch or more
% information about the raws.
% wrc 20Mar2016

dst = [];
den = [];
ren = [];
rst = [];
srcfile = [];

wb = waitbar(0, strcat('loading files:', ...
num2str(0), '/', num2str(nfiles)));
for f = 1:nfiles
    xwavparams = rdxwavhd(dirpath, fnames{f});
    
    dst_tmp = xwavparams.raw.dnumStart;
    den_tmp = xwavparams.raw.dnumEnd;
    fs      = xwavparams.fs;
    nraw    = length(dst_tmp);
    
    sampnum = fix((den_tmp(1:end) - dst_tmp(1:end))*60*24*60*fs);
    cumsamp  = sampnum * NaN;
    
    for i=1:nraw
        cumsamp(i) = sum(sampnum(1:i));
    end
    
    ren_tmp = cumsamp;
    rst_tmp = ren_tmp - sampnum + 1;
    
    srcfile_tmp = repmat(f, 1, nraw);
    
    dst = [dst dst_tmp];
    den = [den den_tmp];
    ren = [ren ren_tmp];
    rst = [rst rst_tmp];
    srcfile = [srcfile srcfile_tmp];
    
waitbar(f/nfiles, wb, strcat('loading files:', ...
num2str(f), '/', num2str(nfiles)));
end

nraw = length(dst);
stretch     = nraw * NaN;
curstretch  = 1;
stretch(1)  = curstretch;


% wb = waitbar(0, strcat('generating stretches:', ...
% num2str(0), '/', num2str(nraw)));
for i=2:nraw
     ddif = dst(i) - den(i-1);
     ddif_sec = round(ddif * 24 * 60 * 60);
     
     if ddif_sec ~= 0
         curstretch = curstretch + 1;
     else
         dese = find(stretch == curstretch);
         stretchdiff = den(i) - dst(dese(1));
         stretchdiff_sec = round(stretchdiff * 24 * 60 * 60);
         
         if stretchdiff_sec > 300
             curstretch = curstretch + 1;
         end
     end
     
     stretch(i) = curstretch; 

% if mod(i, 1000) == 0
% waitbar(i/nraw, wb, strcat('generating stretches:', ...
%num2str(i), '/', num2str(nraw)));
% end
end


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
function [y fs] = loadstretch(stretchst, stretchen, stretchsrc, dirpath, fnames)
% experimental function to load a stretch. deals with the case where a
% stretch bridges two or more files.

FILESEP = filesep;

if stretchsrc(1) == stretchsrc(2)
    infile = strcat(dirpath, FILESEP, fnames{stretchsrc(1)});
    st = stretchst;
    en = stretchen;
    
    [y fs] = audioread(infile, [st en]);
else
    filestobridge = stretchsrc(1):stretchsrc(2);
    y = [];
    
    for i=1:length(filestobridge)
        infile = strcat(dirpath, FILESEP, fnames{filestobridge(i)});
        info = audioinfo(infile);
        
        st = 1;
        en = info.TotalSamples;
        
        if i == 1
            st = stretchst;
        elseif i == length(filestobridge);
            en = stretchen;
        end
        
        [ytmp fs] = audioread(infile, [st en]);
        y = [y; ytmp];
    end
end
end

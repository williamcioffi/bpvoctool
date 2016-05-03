function xwav = isxwav(fnames)
% given a list of fnames that definitely end in .wav, tests to see if also
% ends in .x.wav

xwav = NaN;

wavorxwav = regexp(fnames, '[.]x[.]wav$');
yesx = ~cellfun('isempty', wavorxwav);
allsame = (length(unique(yesx)) == 1);

if(allsame & yesx(1) == 1)
    xwav = 1;
else
    xwav = 0;
end

end
%tester
path = '/Volumes/My Passport/onslo/USWTR01A_D01-08_df100';
ff = 'USWTR01A_DL08_071008_183830.x.wav';

PARAMS = rdxwavhd(path, ff);
dst = PARAMS.raw.dnumStart;
den = PARAMS.raw.dnumEnd;

ddif = dst(2:end) - den(1:(end-1));
ddif_sec = ddif * 24 * 60 * 60;
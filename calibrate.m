%so that will get you those means you were after but that is in dB count re 1 µPa. and you want dB V re 1 µPa. So if I understand Jay's instructions correctly you can do the following.

%% convert dB count re 1 µPa to dB V re 1 µPa.

s = ;    % dB count re 1 µPa

bits = 2^16;    % bit rate or number of counts
vppk = 5;       % voltage peak to peak
k = vppk /2;    % voltage 0 to peak

a = 10^(-s / 20);
b = vppk / bits;
c = a * (1/b);
d = 20 * log10(c);
e = -d;            % dB V re 1 µPa.

%now 'e' should be your dB V re 1 µPa and you can enter this directly in PAMGuide... as long as I haven't done something really stupid. 
%and it should be somewhere close to -170. if you wanted to get your 'm' to apply to the waveform yourself it should be:

m = k * 10^(-e / 20);

info = audioinfo('W:\chuncks\USWTR08E_d02_121227_213345.d100.x.wav');
fs = info.SampleRate;
bits = info.BitsPerSample;

nouts = chunckchecker(fs, bits, 300, -1, 'yymmdd_HHMMSS', 14);
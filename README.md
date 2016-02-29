# bpvoctool
fin whale vocalization analyzing tool in matlab

#spectrogram_truthful_labels.m

this is almost identical to the matlab 2015b m-file spectrogram.m. I've removed the "engineering" units automatic converter so that the y axis always displays in hz and the x axis always displays in seconds. You can be confident no matter how big the file you display is with this function that the units will be consistent.

#wavread_2010a.m

this is the unchanged matlab 2010a m-file for wavread. the goal is to look at how it reads in metadata of a wav file and if it is better or faster than audioinfo which seems to me to be very slow.

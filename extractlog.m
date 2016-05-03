% load in an xbat log and extract the samples
function [st] = extractlog(logpath)

log = load(logpath);
logname = char(fieldnames(log));
log = getfield(log, logname);
events = getfield(log, 'event');
eventstab = struct2table(events);
times = eventstab(:, 7);
timesmat = table2array(times);
st = timesmat(:,1);

end
function [ peakFreq ] = RI_findPeak( data, freqRange, component )
% RI_FINDPEAK Summary of this function goes here
%   Detailed explanation goes here

% -------------------------------------------------------------------------
% Determine frequency range of interest
% -------------------------------------------------------------------------
if(length(freqRange) ~= 2)
  error('Specify a frequency range: [freqLow freqHigh]');
end

idxLow = find(data{1}.freq >= freqRange(1), 1, 'first');
idxHigh = find(data{1}.freq <= freqRange(2), 1, 'last');

if idxLow == idxHigh
  error('Selected range results in one frequency, please select a larger range');
else
  freqCols = idxLow:idxHigh;
  actFreqRange = data{1}.freq(idxLow:idxHigh);                               % Calculate actual frequency range
end

% -------------------------------------------------------------------------
% Determine data length
% -------------------------------------------------------------------------
dataLength = length(data);
peakFreq{dataLength} = [];

% -------------------------------------------------------------------------
% Interpret component specification
% -------------------------------------------------------------------------
if isnumeric(component)
  if ~(component >= 1 && component <= length(data{1}.label))
    error('Chosen component is not available');
  end
else
  component = find(strcmp(data{1}.label, component));
  if isempty(component)
    error('Chosen component is not available');
  end
end
    
% -------------------------------------------------------------------------
% Find largest peak in specified range
% -------------------------------------------------------------------------
for i=1:1:dataLength
  if ~isempty(data{i})
    [pks, locs] = findpeaks(data{i}.powspctrm(component, freqCols));
    if length(pks) > 1
      [~, maxLocs] = max(pks);
      peakFreq{i} = actFreqRange(locs(maxLocs));
    else
      peakFreq{i} = actFreqRange(locs);
    end
  end
end

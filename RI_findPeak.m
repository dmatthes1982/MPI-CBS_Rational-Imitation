function [ peakFreq ] = RI_findPeak( cfg, data )
% RI_FINDPEAK searches for peaks in a certain passband of a certain
% component. The most prominent peak will be returned.
%
% Use as
%   [ peakFreq ] = RI_findPeak( cfg, data )
% where the input data is the result from RI_PSDANALYSIS
%
% The configuration options are
%    cfg.freq      = frequency range: [begin end], uinit = Hz
%    cfg.component = a certain component (i.e. specified as label ('C3' or 'P4') or a decimal number (1 or 6))
%
% See also FINDPEAKS

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Check input variables
% -------------------------------------------------------------------------
if isfield(cfg, 'freqRange')
  freqRange = cfg.freqRange;
else
  error('Frequency range is not defined in cfg');
end

if isfield(cfg, 'component')
  
  component = cfg.component;
else
  error('A certain Component is not defined in cfg');
end


% -------------------------------------------------------------------------
% Determine frequency range of interest
% -------------------------------------------------------------------------
if(length(freqRange) ~= 2)
  error('Specify a frequency range: [freqLow freqHigh]');
end

num = 1;
while isempty(data{num})
  num = num + 1; 
end

idxLow = find(data{num}.freq >= freqRange(1), 1, 'first');
idxHigh = find(data{num}.freq <= freqRange(2), 1, 'last');

if idxLow == idxHigh
  error('Selected range results in one frequency, please select a larger range');
else
  freqCols = idxLow:idxHigh;
  actFreqRange = data{num}.freq(idxLow:idxHigh);                            % Calculate actual frequency range
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
  if ~(component >= 1 && component <= length(data{num}.label))
    error('Chosen component is not available');
  end
else
  component = find(strcmp(data{num}.label, component));
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

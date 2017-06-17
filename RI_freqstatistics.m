function [data_pttest] = RI_freqstatistics(cfg, data_hand, data_head)
% RI_FREQSTATISTICS conducts a paired-ttest between two conditions.
%
% Use as
%   [data_pttest] = RI_freqstatistics(cfg, data_hand, data_head)
% where the input data is the result from RI_PSDANALYSIS
%
% The configuration options are
%    cfg.frequency    = number or range or 'all' (i.e. 6 or [begin end]), unit = Hz     (default = 'all')
%    cfg.channel      = 'all' or a specific selection (i.e. {'C3', 'P*', '*4'})         (default = 'all')
%    cfg.avgoverfreq  = 'no' or 'yes'                                                   (default = 'no')
%    cfg.avgoverchan  = 'no' or 'yes'                                                   (default = 'no')
%
% This function requires the fieldtrip toolbox.
%
% See also FT_FREQSTATISTICS

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Calculate paired t-test
% -------------------------------------------------------------------------
cfg.parameter     = 'powspctrm';                                            % kind of data
cfg.method        = 'stats';                                                % using MATLAB statistic toolbox for analysis  
cfg.statistic     = 'paired-ttest';                                         % using depentend t-test
cfg.alpha         = 0.05;                                                   % significance level   

hand_tmp = data_hand;                                                       % formatting steps, remove empty datasets from cell array
head_tmp = data_head;
eHand = cellfun('isempty', hand_tmp);
eHead = cellfun('isempty', head_tmp);
hand_tmp(eHand) = [];
head_tmp(eHead) = [];

cfg.design=[ones(1, length(hand_tmp)), 2*ones(1, length(hand_tmp))];        % define design, sepearte the datasets into the two conditions

data_pttest = ft_freqstatistics(cfg, head_tmp{:}, hand_tmp{:});             % calculate statistics

% -------------------------------------------------------------------------
% Determine channels/electrodes of interest
% -------------------------------------------------------------------------
if isfield(cfg, 'channel')
  channel = cfg.channel;
  if ~iscell(channel)
    tmp = channel;
    channel = {tmp};
  end
else
  channel = 'all';
end

if any(strcmp(cfg.channel, 'all'))
  channel = data_hand{1}.label;
  chnNum = num2cell(1:1:length(channel));
else
  channel = unique(channel);                                                % Remove multiple entries
  [channel, chnNum] = RI_channelselection(channel, data_hand{1}.label);
end

numOfElec = length(channel);                                                % Get number of channels

% -------------------------------------------------------------------------
% Determine frequencies of interest
% -------------------------------------------------------------------------
if isfield(cfg, 'frequency')
  freq = cfg.frequency;
  if ischar(freq)
    if strcmp(freq, 'all')
      freq = [data_hand{1}.freq(1) data_hand{1}.freq(end)];
    end
  end
else
  freq = [data_hand{1}.freq(1) data_hand{1}.freq(end)];
end

if(length(freq) > 2)
  error('Define a single frequency or specify a frequency range: i.e. [6 10]');
end

if(length(freq) == 1)
  [~, freqCols] = min(abs(data_hand{1}.freq-freq));                         % Calculate data column of selected frequency
end

if(length(freq) == 2)                                                       % Calculate data column range of selected frequency range
  idxLow = find(data_hand{1}.freq >= freq(1), 1, 'first');
  idxHigh = find(data_hand{1}.freq <= freq(2), 1, 'last');
  if idxLow == idxHigh
    freqCols = idxLow;
  else
    freqCols = idxLow:idxHigh;
  end
end


% -------------------------------------------------------------------------
% Create reduced power spectrum relating to channels of interest
% -------------------------------------------------------------------------
powspctrmHead{length(data_head)} = [];
powspctrmHand{length(data_head)} = [];

for i=1:1:numOfElec
  for j=1:1:length(data_head)
    if ~isempty(data_head{j})
      powspctrmHead{j}(i,:) = mean(data_head{1, j}.powspctrm(chnNum{i},:), 1);
      powspctrmHand{j}(i,:) = mean(data_hand{1, j}.powspctrm(chnNum{i},:), 1);
    end
  end
end

% -------------------------------------------------------------------------
% Calculate descriptive statistic
% -------------------------------------------------------------------------
chanNames{2*numOfElec} = [];
for i=1:1:numOfElec
  chanNames{i}            = strcat(channel{i}, 'Head');
  chanNames{i+numOfElec}  = strcat(channel{i}, 'Hand');
end

descStat = array2table(zeros(2, 2*numOfElec), 'VariableNames', chanNames);  % Generate descriptive statistics table
descStat.Properties.RowNames = {'mean', 'standard deviation'};

matrixHead = cat(3, powspctrmHead{:});
matrixHand = cat(3, powspctrmHand{:});

for i=1:1:numOfElec
  descStat(1,i) = num2cell(mean(mean(matrixHead(i,freqCols,:),2),3));
  descStat(2,i) = num2cell(std(mean(matrixHead(i,freqCols,:),2),0,3));
  descStat(1,i+numOfElec) = num2cell(mean(mean(matrixHand(i, ...
                                  freqCols,:),2),3));
  descStat(2,i+numOfElec) = num2cell(std(mean(matrixHand(i, ...
                                  freqCols,:),2),0,3));
end

data_pttest.descStat = descStat;

end

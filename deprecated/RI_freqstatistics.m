function [data_pttest] = RI_freqstatistics(cfg, data_hand, data_head)
% RI_FREQSTATISTICS conducts a paired-ttest between two conditions.
%
% Use as
%   [data_pttest] = RI_freqstatistics(cfg, data_hand, data_head)
% where the input data is the result from RI_PSDANALYSIS
%
% The configuration options are
%    cfg.freq         = number or range or 'all' (i.e. 6 or [begin end]), unit = Hz     (default = 'all')
%    cfg.channel      = 'all' or a specific selection (i.e. {'C3', 'P4', 'Fz'})         (default = 'all')
%    cfg.avgoverchan  = 'no' or 'yes'                                                   (default = 'no')
%
% This function requires the fieldtrip toolbox.
%
% See also FT_FREQSTATISTICS

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Check input
% -------------------------------------------------------------------------
if (any(~cellfun('isempty',(strfind(cfg.channel, '*')))) || ...
   any(~cellfun('isempty',(strfind(cfg.channel, '+')))))
 error('* and + are not accepted within channel definitions with this function');
end

% -------------------------------------------------------------------------
% Calculate paired t-test
% -------------------------------------------------------------------------
cfg.avgoverchan = ft_getopt(cfg, 'avgoverchan', 'no');

cfg.parameter     = 'powspctrm';                                            % kind of data
cfg.frequency     = cfg.freq;
cfg.avgoverfreq   = 'yes';
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

num = 1;
while isempty(data_head{num})                                               % get number of first non-empty member of datasets
  num = num + 1; 
end

if any(strcmp(cfg.channel, 'all'))
  channel = data_hand{num}.label;
  chnNum = num2cell(1:1:length(channel));
else
  channel = unique(channel);                                                % Remove multiple entries
  [channel, chnNum] = RI_channelselection(channel, data_hand{num}.label);
end

numOfChan = length(channel);                                                % Get number of selected channels
if strcmp(cfg.avgoverchan, 'yes')                                           % Get number of actual channels /components (depends on cfg.avgoverchan)
  numOfComp = 1;
else
  numOfComp = numOfChan;
end

% -------------------------------------------------------------------------
% Determine frequencies of interest
% -------------------------------------------------------------------------
if isfield(cfg, 'freq')
  freq = cfg.freq;
  if ischar(freq)
    if strcmp(freq, 'all')
      freq = [data_hand{num}.freq(1) data_hand{num}.freq(end)];
    end
  end
else
  freq = [data_hand{num}.freq(1) data_hand{num}.freq(end)];
end

if(length(freq) > 2)
  error('Define a single frequency or specify a frequency range: i.e. [6 10]');
end

if(length(freq) == 1)
  [~, freqCols] = min(abs(data_hand{num}.freq-freq));                       % Calculate data column of selected frequency
end

if(length(freq) == 2)                                                       % Calculate data column range of selected frequency range
  idxLow = find(data_hand{num}.freq >= freq(1), 1, 'first');
  idxHigh = find(data_hand{num}.freq <= freq(2), 1, 'last');
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

for i=1:1:numOfChan
  for j=1:1:length(data_head)
    if ~isempty(data_head{j})
      powspctrmHead{j}(i,:) = data_head{1, j}.powspctrm(chnNum{i},:);
      powspctrmHand{j}(i,:) = data_hand{1, j}.powspctrm(chnNum{i},:);
    end
  end
end

% -------------------------------------------------------------------------
% Calculate descriptive statistic over all dyads
% Generate pttest source table (for comparision with SPSS)
% -------------------------------------------------------------------------
chanNames{2*numOfComp+1} = [];
chanNames{1} = 'participant';

if strcmp(cfg.avgoverchan, 'yes')
  chanNames{2} = [];
  chanNames{3} = [];
  if numOfChan > 1
    for i = 1:1:numOfChan
      chanNames{2} = [chanNames{2}, channel{i}];
      chanNames{3} = [chanNames{3}, channel{i}];
    end
  end
  chanNames{2} = [chanNames{2}, 'Head'];
  chanNames{3} = [chanNames{3}, 'Hand'];
else
  for i = 1:1:numOfChan
    chanNames{i+1}            = [channel{i}, 'Head'];
    chanNames{i+1+numOfComp}  = [channel{i}, 'Hand'];
  end
end

descStat = array2table(zeros(2, 2*numOfComp), 'VariableNames', ...          % Generate descriptive statistics table template
                        chanNames(2:end));  
descStat.Properties.RowNames = {'mean', 'standard deviation'};

numOfPart = find(~cellfun(@isempty, data_hand));
pttestSource = array2table(zeros(length(numOfPart), 2*numOfComp+1), ...     % Generate pttestSource table template
                          'VariableNames', chanNames);
pttestSource.participant = numOfPart';

matrixHead = cat(3, powspctrmHead{:});                                      % Convert data matrix from cell to array structure
matrixHand = cat(3, powspctrmHand{:});

if strcmp(cfg.avgoverchan, 'yes')
  matrixHead = mean(matrixHead, 1);
  matrixHand = mean(matrixHand, 1);
end

for i=1:1:numOfComp                                                         % Insert data into descriptive statistics table
  descStat(1,i) = num2cell(mean(mean(matrixHead(i,freqCols,:),2),3));
  descStat(2,i) = num2cell(std(mean(matrixHead(i,freqCols,:),2),0,3));
  descStat(1,i+numOfComp) = num2cell(mean(mean(matrixHand(i, ...
                                  freqCols,:),2),3));
  descStat(2,i+numOfComp) = num2cell(std(mean(matrixHand(i, ...
                                  freqCols,:),2),0,3));
end

data_pttest.descStat = descStat;

for i=1:1:numOfComp
  for j=1:1:(length(numOfPart))
    pttestSource(j, i+1)            = num2cell(mean(...
                                      matrixHead(i,freqCols,j), 2));
    pttestSource(j, i+1+numOfComp)  = num2cell(mean(...
                                      matrixHand(i,freqCols,j), 2));
  end
end

data_pttest.pttestSource = pttestSource;

end

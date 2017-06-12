function data_rmanova = RI_rmAnova(cfg, data_hand, data_head)
% RI_RMANOVA estimates a repeated measured ANOVA for two conditions
% (data_hand, data_head) and a free selectable number of electrodes.
%
% Use as
%   [data_rmanova] = RI_rmAnova(cfg, data_hand, data_head)
% where the input data is the result from RI_PSDANALYSIS
%
% The configuration options are
%    cfg.freq      = number or range (i.e. 6 or [6 10]), unit = Hz
%    cfg.channel   = 'all' or a specific selection (i.e. {'C3', 'P*', '*4'})
%
% See also RI_CHANNELSELECTION, FITRM, ranova, epsilon, mauchly

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Initialize output structure
% -------------------------------------------------------------------------
data_rmanova = struct;

% -------------------------------------------------------------------------
% Determine frequencies of interest
% -------------------------------------------------------------------------
if isfield(cfg, 'freq')
  freq = cfg.freq;
else
  error('Frequency range is not defined in cfg');
end

if(length(freq) > 2)
  error('Define a single frequency or specify a frequency range: i.e. [6 10]');
end

if(length(freq) == 1)
  [~, freqCols] = min(abs(data_hand{1}.freq-freq));                         % Calculate data column of selected frequency
  data_rmanova.cfg.freq = data_hand{1}.freq(freqCols);                      % Calculate actual frequency
end

if(length(freq) == 2)                                                       % Calculate data column range of selected frequency range
  idxLow = find(data_hand{1}.freq >= freq(1), 1, 'first');
  idxHigh = find(data_hand{1}.freq <= freq(2), 1, 'last');
  if idxLow == idxHigh
    freqCols = idxLow;
    data_rmanova.cfg.freq  = data_hand{1}.freq(freqCols);                   % Calculate actual frequency
  else
    freqCols = idxLow:idxHigh;
    actFreqLow = data_hand{1}.freq(idxLow);
    actFreqHigh = data_hand{1}.freq(idxHigh);
    data_rmanova.cfg.freq = [actFreqLow actFreqHigh];                       % Calculate actual frequency range
  end
end

% -------------------------------------------------------------------------
% Determine channels/electrodes of interest
% -------------------------------------------------------------------------
if isfield(cfg, 'channel')
  channel = cfg.channel;
else
  error('Channels of interest are not defined in cfg');
end

if any(strcmp(cfg.channel, 'all'))
  channel = data_hand{1}.label;
  data_rmanova.cfg.channel = channel';
  chnNum = num2cell(1:1:length(channel));
else
  channel = unique(channel);                                                % Remove multiple entries
  data_rmanova.cfg.channel = channel;
  [channel, chnNum] = RI_channelselection(channel, data_hand{1}.label);
end

numOfElec = length(channel);                                                % Get number of channels

% -------------------------------------------------------------------------
% Determine number of repetitions
% -------------------------------------------------------------------------
numOfPart = find(~cellfun(@isempty, data_hand));                            % Get numbers of good participants
dataLength = length(numOfPart);                                             % Get number of good participants

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
stats = array2table(zeros(2, 2*numOfElec), 'VariableNames', chanNames);     % Generate descriptive statistics table
stats.Properties.RowNames = {'mean', 'standard deviation'};

matrixHead = cat(3, powspctrmHead{:});
matrixHand = cat(3, powspctrmHand{:});

for i=1:1:numOfElec
  stats(1,i) = num2cell(mean(mean(matrixHead(i,freqCols,:),2),3));
  stats(2,i) = num2cell(std(mean(matrixHead(i,freqCols,:),2),0,3));
  stats(1,i+numOfElec) = num2cell(mean(mean(matrixHand(i, ...
                                  freqCols,:),2),3));
  stats(2,i+numOfElec) = num2cell(std(mean(matrixHand(i, ...
                                  freqCols,:),2),0,3));
end

data_rmanova.stats = stats;

% -------------------------------------------------------------------------
% Create data table and between-subjects model of reapeated measure model
% -------------------------------------------------------------------------
chanNames{2*numOfElec+1} = [];
chanNames{1} = 'participant';

for i=2:1:numOfElec+1
  chanNames{i}            = strcat(channel{i-1}, 'Head');
  chanNames{i+numOfElec}  = strcat(channel{i-1}, 'Hand');
end
data = array2table(zeros(dataLength, 2*numOfElec+1), 'VariableNames', ...   % Generate data table
          chanNames);

data.participant = numOfPart';                                              % Put numbers of participants into the table
rowNum = 0;                                                                 % Initialize pointer to rows  

for i=1:1:length(data_head)                                                 % Put FFT data into data table  
  if ~isempty(data_head{i})
    rowNum = rowNum + 1;
    data(rowNum, 2:numOfElec+1) = num2cell(...
                    mean(powspctrmHead{i}(:,freqCols),2)');
    data(rowNum, numOfElec+2:2*numOfElec+1) = num2cell(...
                    mean(powspctrmHand{i}(:,freqCols),2)');
  end
end
% -------------------------------------------------------------------------
% Create within-subjects model
% -------------------------------------------------------------------------
condVector = nominal(cat(1,repmat('Head',numOfElec,1), ...
                           repmat('Hand',numOfElec,1)));
elecVector = nominal([1:numOfElec 1:numOfElec]');
withinDesign = table(condVector, elecVector, 'VariableNames', ...
                    {'Condition', 'Electrode'});
                  
% -------------------------------------------------------------------------
% Build repeated measures model
% -------------------------------------------------------------------------
range = strcat(chanNames{2},'-',chanNames{end},' ~ 1');
repMeasMod = fitrm(data, range, 'WithinDesign', withinDesign);

% -------------------------------------------------------------------------
% Calculate repeated measures ANOVA, epsilon adjustments and Mauchly's 
% test on sphericity
% -------------------------------------------------------------------------
[data_rmanova.table, ~, C, ~] = ranova(repMeasMod, 'WithinModel', ...
                                       'Condition*Electrode');
           
for i=1:1:4
  [Q,~] = qr(C{i},0);
  data_rmanova.eps(i,:) = epsilon(repMeasMod, Q);                           % epsilon adjustments
  data_rmanova.mauchly(i,:) = mauchly(repMeasMod, Q);                       % Mauchly's test on sphericity
end

data_rmanova.eps.Properties.RowNames = {'(Intercept)', ...
          '(Intercept):Condition', '(Intercept):Electrode', ...
          '(Intercept):Condition:Electrode'};

data_rmanova.mauchly.Properties.RowNames = {'(Intercept)', ...
          '(Intercept):Condition', '(Intercept):Electrode', ...
          '(Intercept):Condition:Electrode'};

data_rmanova.comment = ...
          'DF und MeanSq has the correct value for assumed sphericity';

% -------------------------------------------------------------------------
% Calculate effect size
% partial eta squared = SumSq(effect)/(SumSq(effect)+SumSq(error))
% -------------------------------------------------------------------------
data_rmanova.table.pEtaSq = zeros(8,1);
data_rmanova.table.pEtaSq(1) = data_rmanova.table.SumSq(1) / ...
                        (data_rmanova.table.SumSq(1) + ...
                        data_rmanova.table.SumSq(2));
data_rmanova.table.pEtaSq(3) = data_rmanova.table.SumSq(3) /...
                        (data_rmanova.table.SumSq(3) + ...
                        data_rmanova.table.SumSq(4));
data_rmanova.table.pEtaSq(5) = data_rmanova.table.SumSq(5) /...
                        (data_rmanova.table.SumSq(5) + ...
                        data_rmanova.table.SumSq(6));
data_rmanova.table.pEtaSq(7) = data_rmanova.table.SumSq(7) /...
                        (data_rmanova.table.SumSq(7) + ...
                        data_rmanova.table.SumSq(8));  

end
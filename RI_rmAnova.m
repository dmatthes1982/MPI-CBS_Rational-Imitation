function [data_rmanova, bsData] = RI_rmAnova(cfg, data_hand, data_head, varargin)
% RI_RMANOVA estimates a repeated measured ANOVA for two conditions
% (data_hand, data_head) and a free selectable number of electrodes or if
% required a mixed repeated measured ANOVA with one additional 
% between-subjects parameter, which can have two different values.
%
% Use as
%   [data_rmanova] = RI_rmAnova(cfg, data_hand, data_head)
%                  or
%   [data_rmanova] = RI_rmAnova(cfg, data_hand1, data_head1, data_hand2, data_head2, bsVal1, bsVal2)
%                  or
%   [data_rmanova, bsData] = RI_rmAnova(cfg, data_hand, data_head)
%                  or
%   [data_rmanova, bsData] = RI_rmAnova(cfg, data_hand1, data_head1, data_hand2, data_head2, bsVal1, bsVal2)
%
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
% Check input
% -------------------------------------------------------------------------
switch length(varargin)
  case 0
    bwSubParam = 0;
  case 4
    data_hand2 = varargin{1};
    data_head2 = varargin{2};
    bsVal1 = varargin{3};
    bsVal2 = varargin{4};
    bwSubParam = 1;
  otherwise
    error('to many or to few input values, see specifications: help RI_rmAnova');
end

if bwSubParam == 1                                                          % Check if different datasets share the same labels and the same frequency resolution/range
  if ~all(strcmp(data_head{1}.label, data_head2{1}.label))
    error('The datasets consist of different labels');
  end
  if ~all(eq(data_head{1}.freq, data_head2{1}.freq))
    error('The datasets consist of different frequencies');
  end
end
  

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

if bwSubParam == 1
  numOfPart2 = find(~cellfun(@isempty, data_hand2));                        % Get numbers of good participants in the second dataset
  dataLength2 = length(numOfPart2);                                         % Get number of good participants in the second dataset
else
  numOfPart2 = [];
  dataLength2 = 0;
end

% -------------------------------------------------------------------------
% Create reduced power spectrum relating to channels of interest
% -------------------------------------------------------------------------
powspctrmHead{length(data_head)} = [];
powspctrmHand{length(data_head)} = [];

if bwSubParam == 1
  powspctrmHead2{length(data_head2)} = [];
  powspctrmHand2{length(data_head2)} = [];
end

for i=1:1:numOfElec
  for j=1:1:length(data_head)
    if ~isempty(data_head{j})
      powspctrmHead{j}(i,:) = mean(data_head{1, j}.powspctrm(chnNum{i},:), 1);
      powspctrmHand{j}(i,:) = mean(data_hand{1, j}.powspctrm(chnNum{i},:), 1);
    end
  end
end

if bwSubParam == 1
  for i=1:1:numOfElec
    for j=1:1:length(data_head2)
      if ~isempty(data_head2{j})
        powspctrmHead2{j}(i,:) = mean(data_head2{1, j}.powspctrm(chnNum{i},:), 1);
        powspctrmHand2{j}(i,:) = mean(data_hand2{1, j}.powspctrm(chnNum{i},:), 1);
      end
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

if bwSubParam == 1
  n = 2;
else
  n = 1;
end

stats = array2table(zeros(2*n, 2*numOfElec), 'VariableNames', chanNames);   % Generate descriptive statistics table

if bwSubParam == 0
  stats.Properties.RowNames = {'mean', 'standard deviation'};
else
  stats.Properties.RowNames = {'mean', 'standard deviation', 'mean2', ...
                               'standard deviation2'};
end

matrixHead = cat(3, powspctrmHead{:});
matrixHand = cat(3, powspctrmHand{:});
if bwSubParam == 1
  matrixHead2 = cat(3, powspctrmHead2{:});
  matrixHand2 = cat(3, powspctrmHand2{:});
end

for i=1:1:numOfElec
  stats(1,i) = num2cell(mean(mean(matrixHead(i,freqCols,:),2),3));
  stats(2,i) = num2cell(std(mean(matrixHead(i,freqCols,:),2),0,3));
  stats(1,i+numOfElec) = num2cell(mean(mean(matrixHand(i, ...
                                  freqCols,:),2),3));
  stats(2,i+numOfElec) = num2cell(std(mean(matrixHand(i, ...
                                  freqCols,:),2),0,3));
  if bwSubParam == 1
    stats(3,i) = num2cell(mean(mean(matrixHead2(i,freqCols,:),2),3));
    stats(4,i) = num2cell(std(mean(matrixHead2(i,freqCols,:),2),0,3));
    stats(3,i+numOfElec) = num2cell(mean(mean(matrixHand2(i, ...
                                    freqCols,:),2),3));
    stats(4,i+numOfElec) = num2cell(std(mean(matrixHand2(i, ...
                                    freqCols,:),2),0,3));
  end
end

data_rmanova.stats = stats;

% -------------------------------------------------------------------------
% Create data table and between-subjects model of reapeated measure model
% -------------------------------------------------------------------------
if bwSubParam == 1
  m = 1;
else
  m = 0;
end

chanNames{2*numOfElec+1+m} = [];
chanNames{1} = 'participant';
if bwSubParam == 1
  chanNames{2} = 'experiment';
end

for i=2+m:1:numOfElec+1+m
  chanNames{i}            = strcat(channel{i-1-m}, 'Head');
  chanNames{i+numOfElec}  = strcat(channel{i-1-m}, 'Hand');
end
bsData = array2table(zeros(dataLength + dataLength2, ...                    % Generate data table
                          2*numOfElec+1+m), 'VariableNames', chanNames);

bsData.participant = [numOfPart, numOfPart2]';                              % Put numbers of participants into the table
if bwSubParam == 1
  bsData.experiment = cat(1, repmat({bsVal1}, dataLength, 1), ...           % Put between-subject information into the tabel
                           repmat({bsVal2}, dataLength2, 1));
end

rowNum = 0;                                                                 % Initialize pointer to rows  

for i=1:1:length(data_head)                                                 % Put FFT data into data table  
  if ~isempty(data_head{i})
    rowNum = rowNum + 1;
    bsData(rowNum, 2+m:numOfElec+1+m) = num2cell(...
                    mean(powspctrmHead{i}(:,freqCols),2)');
    bsData(rowNum, numOfElec+2+m:2*numOfElec+1+m) = num2cell(...
                    mean(powspctrmHand{i}(:,freqCols),2)');
  end
end

if bwSubParam == 1
  for i=1:1:length(data_head2)                                              % Put FFT data2 into data table  
    if ~isempty(data_head2{i})
      rowNum = rowNum + 1;
      bsData(rowNum, 2+m:numOfElec+1+m) = num2cell(...
                      mean(powspctrmHead2{i}(:,freqCols),2)');
      bsData(rowNum, numOfElec+2+m:2*numOfElec+1+m) = num2cell(...
                      mean(powspctrmHand2{i}(:,freqCols),2)');
    end
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
if bwSubParam == 0
  range = strcat(chanNames{2},'-',chanNames{end},' ~ 1');
else
  range = strcat(chanNames{3},'-',chanNames{end},' ~ experiment');
end

repMeasMod = fitrm(bsData, range, 'WithinDesign', withinDesign);

% -------------------------------------------------------------------------
% Calculate repeated measures ANOVA, epsilon adjustments and Mauchly's 
% test on sphericity
% -------------------------------------------------------------------------
[data_rmanova.table, ~, C, ~] = ranova(repMeasMod, 'WithinModel', ...
                                       'Condition*Electrode');
           
for i=1:1:length(C)
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
if bwSubParam == 0
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
else
  data_rmanova.table.pEtaSq = zeros(12,1);
  data_rmanova.table.pEtaSq(1) = data_rmanova.table.SumSq(1) / ...
                          (data_rmanova.table.SumSq(1) + ...
                          data_rmanova.table.SumSq(2) + ...
                          data_rmanova.table.SumSq(3));
  data_rmanova.table.pEtaSq(2) = data_rmanova.table.SumSq(2) / ...
                          (data_rmanova.table.SumSq(1) + ...
                          data_rmanova.table.SumSq(2) + ...
                          data_rmanova.table.SumSq(3));
  data_rmanova.table.pEtaSq(4) = data_rmanova.table.SumSq(4) / ...
                          (data_rmanova.table.SumSq(4) + ...
                          data_rmanova.table.SumSq(5) + ...
                          data_rmanova.table.SumSq(6));
  data_rmanova.table.pEtaSq(5) = data_rmanova.table.SumSq(5) / ...
                          (data_rmanova.table.SumSq(4) + ...
                          data_rmanova.table.SumSq(5) + ...
                          data_rmanova.table.SumSq(6));
  data_rmanova.table.pEtaSq(7) = data_rmanova.table.SumSq(7) / ...
                          (data_rmanova.table.SumSq(7) + ...
                          data_rmanova.table.SumSq(8) + ...
                          data_rmanova.table.SumSq(9));
  data_rmanova.table.pEtaSq(8) = data_rmanova.table.SumSq(8) / ...
                          (data_rmanova.table.SumSq(7) + ...
                          data_rmanova.table.SumSq(8) + ...
                          data_rmanova.table.SumSq(9));
  data_rmanova.table.pEtaSq(10) = data_rmanova.table.SumSq(10) / ...
                          (data_rmanova.table.SumSq(10) + ...
                          data_rmanova.table.SumSq(11) + ...
                          data_rmanova.table.SumSq(12));
  data_rmanova.table.pEtaSq(11) = data_rmanova.table.SumSq(11) / ...
                          (data_rmanova.table.SumSq(10) + ...
                          data_rmanova.table.SumSq(11) + ...
                          data_rmanova.table.SumSq(12));
end

end

function [data_rmanova] = RA_rmAnova(cfg, data_SegHand, data_SegHead)
% RA_RMANOVA estimates a repeated measures ANOVA for two conditions
% (data_SegHand, data_SegHead) and a free selectable number of electrodes.
%
% Use as
%   [data_rmanova] = RA_rmAnova(cfg, data_SegHand, data_SegHead)
%
% where the input data has to be a cell vector with results of 
% RA_POWERAVERAGE
%
% The configuration options are
%   cfg.numOfPart  = 1xN vector including all selected participant numbers
%   cfg.ident      = dataset identifier, possible options are:
%                     - 03a_pow_avgpow2to5
%                     - 03b_pow_avgpow6to9
%   cfg.channel    = 'all' or a specific selection (i.e. {'C3', 'P*', '*4', 'F3+F4'})
%                       (default: {'F3','F4','Fz','C3','C4','Cz','P3','P4','Pz'})
%
% See also RA_CHANNELSELECTION, FITRM, ranova, epsilon, mauchly

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
numOfPart = ft_getopt(cfg, 'numOfPart', []);
ident     = ft_getopt(cfg, 'ident', []);
channel   = ft_getopt(cfg, 'channel', {'F3','F4','Fz','C3','C4','Cz',...
                                     'P3','P4','Pz'});
                        
if ~(length(numOfPart) == length(data_SegHand))                             % check cfg.numOfPart
  error(['The numOfPart vector must have the same length like the '...
        'data cells']);
else
  dataLength = length(numOfPart);                                           % get number of participants
end
                                                     
if any(strcmp(channel, 'all'))                                              % check cfg.channel
  channel = data_SegHand{1}.label';
  chnNum = num2cell(1:1:length(channel));
else
  channel = unique(channel);                                                % remove multiple entries
  [channel, chnNum] = RA_channelselection(channel, data_SegHand{1}.label);
end

numOfElec = length(channel);                                                % get number of channels

% -------------------------------------------------------------------------
% Initialize output structure
% -------------------------------------------------------------------------
data_rmanova              = struct;
data_rmanova.cfg.freq     = data_SegHand{1}.freq;
data_rmanova.cfg.ident    = ident;
data_rmanova.cfg.channel  = channel;

% -------------------------------------------------------------------------
% Create reduced power spectrum relating to channels of interest
% -------------------------------------------------------------------------
powspctrmSegHand{length(data_SegHand)} = [];
powspctrmSegHead{length(data_SegHead)} = [];

for i=1:1:numOfElec
  for j=1:1:length(data_SegHead)
    powspctrmSegHead{j}(i,:) = mean(data_SegHead{1, j}.powspctrm(chnNum{i},:), 1);
    powspctrmSegHand{j}(i,:) = mean(data_SegHand{1, j}.powspctrm(chnNum{i},:), 1);
  end
end

% -------------------------------------------------------------------------
% Calculate descriptive statistic
% -------------------------------------------------------------------------
chanNames{2 * numOfElec} = [];
for i=1:1:numOfElec
  chanNames{i}              = strcat(channel{i}, 'SegHand');
  chanNames{i + numOfElec}  = strcat(channel{i}, 'SegHead');
end

stats = array2table(zeros(2, 2*numOfElec), 'VariableNames', chanNames);     % generate descriptive statistics table
stats.Properties.RowNames = {'mean', 'standard deviation'};

matrixSegHand  = squeeze(cat(3, powspctrmSegHand{:}));
matrixSegHead  = squeeze(cat(3, powspctrmSegHead{:}));

for i=1:1:numOfElec
  stats(1,i)              = num2cell(mean(matrixSegHand(i,:),2));
  stats(2,i)              = num2cell(std(matrixSegHand(i,:),0,2));
  stats(1,i + numOfElec)  = num2cell(mean(matrixSegHead(i,:),2));
  stats(2,i + numOfElec)  = num2cell(std(matrixSegHead(i,:),0,2));
end

data_rmanova.stats = stats;

% -------------------------------------------------------------------------
% Create data table and between-subjects model of reapeated measure model
% -------------------------------------------------------------------------
chanNames{2 * numOfElec + 1} = [];
chanNames{1} = 'participant';

for i=2:1:numOfElec+1
  chanNames{i}            = strcat(channel{i-1}, 'SegHand');
  chanNames{i+numOfElec}  = strcat(channel{i-1}, 'SegHead');
end
bsData = array2table(zeros(dataLength , 2*numOfElec+1), 'VariableNames',... % generate data table
                     chanNames);
                          
bsData.participant = numOfPart';                                            % put numbers of participants into the table

for i=1:1:length(data_SegHead)                                              % put FFT data into data table  
    bsData(i, 2:numOfElec+1) = num2cell(powspctrmSegHand{i}(:)');
    bsData(i, numOfElec+2:2*numOfElec+1) = num2cell(powspctrmSegHead{i}(:)');
end

data_rmanova.bsData = bsData;                                               % add model to output

% -------------------------------------------------------------------------
% Create within-subjects model
% -------------------------------------------------------------------------
condVector    = nominal(cat(1,repmat({'Cond'},numOfElec,1), ...
                           repmat({'SegHead'},numOfElec,1)));
elecVector    = nominal([1:numOfElec 1:numOfElec]');
withinDesign  = table(condVector, elecVector, 'VariableNames', ...
                    {'Condition', 'Electrode'});
                  
% -------------------------------------------------------------------------
% Build repeated measures model
% -------------------------------------------------------------------------
range       = strcat(chanNames{2},'-',chanNames{end},' ~ 1');
repMeasMod  = fitrm(bsData, range, 'WithinDesign', withinDesign);

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

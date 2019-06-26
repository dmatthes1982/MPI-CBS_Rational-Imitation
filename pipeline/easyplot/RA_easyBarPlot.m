function RA_easyBarPlot( cfg, data_hand, data_head, cond, varargin )
% RA_EASYBARPLOT generates a bar graph for the comparision of certain
% channels in different conditions and experiments. A averaging over
% frequency will be done if a frequency range is defined (cfg.freq).
% Averaging over electrodes is also possible (see cfg.channel).
%
% Use as
%   RI_easyBarPlot( cfg, data_hand, data_head, 'handsFree' )
%                 or
%   RI_easyBarPlot( cfg, data_hand, data_head, 'handsFree', data_hand2, data_head2, 'handsRestr' )
% 
% where the input data is the result from RI_PSDANALYSIS
%
% The configuration options are
%    cfg.pdf_title = 'tite of output file' (default: BarGraph)
%    cfg.freq      = number or range (i.e. 6 or [6 8]), unit = Hz, (default: [6 8])
%    cfg.channel   = 'all' or a specific selection (i.e. {'C3', 'P*', '*4', 'F3+F4'}),
%                    (default: {'Cz'})
%
% See also RI_CHANNELSELECTION

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check input
% -------------------------------------------------------------------------
pdf_title = ft_getopt(cfg, 'pdf_title', 'BarGraph');
freq      = ft_getopt(cfg, 'freq', [6 8]);
channel   = ft_getopt(cfg, 'channel', {'Cz', 'P*', 'F3+F4'});

switch length(varargin)
  case 0
    extInput = 0; 
  case 3
    extInput = 1;
    data_hand2 = varargin{1};
    data_head2 = varargin{2};
    cond2 = varargin{3};
  otherwise
    error('to many or to few input values, see specifications: help RI_easyBarPlot');
end

num = 1;
while isempty(data_head{num})                                               % get number of first non-empty member of datasets
  num = num + 1; 
end

if extInput == 1                                                            % if extended input is defined
  if ~all(strcmp(data_head{num}.label, data_head2{num}.label))              % Check if different datasets share the same labels and the same frequency resolution/range
    error('The datasets consist of different labels');
  end
  if ~all(eq(data_head{num}.freq, data_head2{num}.freq))
    error('The datasets consist of different frequencies');
  end
end

% -------------------------------------------------------------------------
% Determine frequencies of interest
% -------------------------------------------------------------------------
if(length(freq) > 2)
  error('Define a single frequency or specify a frequency range: i.e. [6 10]');
end

if(length(freq) == 1)
  [~, freqCols] = min(abs(data_hand{num}.freq-freq));                       % Calculate data column of selected frequency
  freq = data_hand{num}.freq(freqCols);                                     % Calculate actual frequency
end

if(length(freq) == 2)                                                       % Calculate data column range of selected frequency range
  idxLow = find(data_hand{num}.freq >= freq(1), 1, 'first');
  idxHigh = find(data_hand{num}.freq <= freq(2), 1, 'last');
  if idxLow == idxHigh
    freqCols = idxLow;
    freq  = data_hand{num}.freq(freqCols);                                  % Calculate actual frequency
  else
    freqCols = idxLow:idxHigh;
    actFreqLow = data_hand{num}.freq(idxLow);
    actFreqHigh = data_hand{num}.freq(idxHigh);
    freq = [actFreqLow actFreqHigh];                                        % Calculate actual frequency range
  end
end

% -------------------------------------------------------------------------
% Determine channels/electrodes of interest
% -------------------------------------------------------------------------
cfgSD.channel = {'F3','F4','Fz','C3','C4','Cz','P3','P4','Pz'};             % principal channels of interest
cfgSD.avgoverchan = 'no';
cfgSD.showcallinfo = 'no';

for i=1:1:length(data_hand)                                                 % leave only principal channels of interest in the data
  if ~isempty(data_hand{i})
    data_hand{i} = ft_selectdata(cfgSD, data_hand{i});
    data_head{i} = ft_selectdata(cfgSD, data_head{i});
  end
end

if extInput == 1                                                            % if extended input is defined
  for i=1:1:length(data_hand2)
    if ~isempty(data_hand2{i})
      data_hand2{i} = ft_selectdata(cfgSD, data_hand2{i});
      data_head2{i} = ft_selectdata(cfgSD, data_head2{i});
    end
  end
end
                                                      
if any(strcmp(channel, 'all'))                                              % exploit channel definition
  channel = data_hand{num}.label;
  channel = channel';
  chnNum = num2cell(1:1:length(channel));
else
  channel = unique(channel, 'stable');                                      % Remove multiple entries
  [channel, chnNum] = RI_channelselection(channel, data_hand{num}.label);
end

numOfChan = length(channel);                                                % Get number of channels

% -------------------------------------------------------------------------
% Calculate the power for the actual channel of interest averaged over 
% the selected frequency range
% -------------------------------------------------------------------------
powspctrmHead{length(data_head)} = [];
powspctrmHand{length(data_head)} = [];

if extInput == 1                                                            % if extended input is defined
  powspctrmHead2{length(data_head2)} = [];
  powspctrmHand2{length(data_head2)} = [];
end

for i=1:1:numOfChan
  for j=1:1:length(data_head)
    if ~isempty(data_head{j})
      powspctrmHead{j}(i,:) = mean(mean(data_head{1, j}.powspctrm(...
                                  chnNum{i},freqCols), 1), 2);
      powspctrmHand{j}(i,:) = mean(mean(data_hand{1, j}.powspctrm(...
                                  chnNum{i},freqCols), 1), 2);
    end
  end
end

if extInput == 1                                                            % if extended input is defined
  for i=1:1:numOfChan
    for j=1:1:length(data_head2)
      if ~isempty(data_head2{j})
        powspctrmHead2{j}(i,:) = mean(mean(data_head2{1, j}.powspctrm(...
                                      chnNum{i},freqCols), 1), 2);
        powspctrmHand2{j}(i,:) = mean(mean(data_hand2{1, j}.powspctrm(...
                                      chnNum{i},freqCols), 1), 2);
      end
    end
  end
end

matrixHead = squeeze(cat(3, powspctrmHead{:}));                             % transform the cell array into a matrix
matrixHand = squeeze(cat(3, powspctrmHand{:}));
if extInput == 1
  matrixHead2 = squeeze(cat(3, powspctrmHead2{:}));
  matrixHand2 = squeeze(cat(3, powspctrmHand2{:}));
end

% -------------------------------------------------------------------------
% Estimate data matrix
% -------------------------------------------------------------------------

if extInput == 1                                                             % if extended input is defined
  graphMean = zeros(numOfChan*2, 2);
  graphSEM = zeros(numOfChan*2, 2);
  graphLabel{numOfChan*2} = [];
else
  graphMean = zeros(numOfChan, 2);
  graphSEM = zeros(numOfChan, 2);
  graphLabel{numOfChan} = [];
end

if extInput == 1                                                             % if extended input is defined
  for i=1:1:numOfChan
    graphMean(i*2 - 1, 1) = mean(matrixHead(i,:));
    graphSEM(i*2 - 1, 1) = std(matrixHead(i,:)) / ...
                            sqrt(length(matrixHead(i,:)));
    graphMean(i*2 - 1, 2) = mean(matrixHand(i,:));
    graphSEM(i*2 - 1, 2) = std(matrixHand(i,:)) / ...
                            sqrt(length(matrixHand(i,:)));
    graphLabel{i*2 - 1} = strcat(channel{i}, '-', cond);
    graphMean(i*2, 1) = mean(matrixHead2(i,:));
    graphSEM(i*2 , 1) = std(matrixHead2(i,:)) / ...
                         sqrt(length(matrixHead2(i,:)));
    graphMean(i*2, 2) = mean(matrixHand2(i,:));
    graphSEM(i*2, 2) = std(matrixHand2(i,:)) / ...
                        sqrt(length(matrixHand2(i,:)));
    graphLabel{i*2} = strcat(channel{i}, '-', cond2);
  end
   graphVector = 1:1:numOfChan*2;    
else
  for i=1:1:numOfChan
    graphMean(i, 1) = mean(matrixHead(i,:));
    graphSEM(i, 1) = std(matrixHead(i,:)) / ...
                     sqrt(length(matrixHead(i,:)));
    graphMean(i, 2) = mean(matrixHand(i,:));
    graphSEM(i, 2) = std(matrixHand(i,:)) / ...
                      sqrt(length(matrixHand(i,:)));
    graphLabel{i} = strcat(channel{i}, '-', cond);
  end
  graphVector = 1:1:numOfChan;
end

% -------------------------------------------------------------------------
% Plot data
% -------------------------------------------------------------------------
bar(graphVector, graphMean);
set(gca, 'XTick', graphVector,'XTickLabel',graphLabel);
set(gca, 'YGrid', 'on');
if length(freq) == 2
  title(sprintf('head vs. hand in a freq range of %d to %d Hz', freq(1),... 
                freq(2)));
else
  title(sprintf('head vs. hand at %d Hz', freq(1)));
end

graphMean = graphMean';
graphSEM = graphSEM';

hold on;
for k = 1:2
  errorbar(graphVector+0.145*((-1)^k),  graphMean(k,:),  graphSEM(k,:), '.k', 'LineWidth', 1.5);
end
hold off;

legend('head touch', 'hand touch');
xlabel('Electrodes');
ylabel('Power (\muV^2)');
ylim([0 18]);

% -------------------------------------------------------------------------
% Save graphic as pdf-File
% -------------------------------------------------------------------------
h=gcf;
set(h, 'PaperOrientation','landscape');
set(h, 'PaperType','a3');
set(h, 'PaperUnit', 'centimeters');
set(h, 'PaperSize', [42 29.7]);
set(h, 'unit', 'normalized', 'Position', [0 0 0.9 0.9]);
doc_title = sprintf('/data/pt_01798/Rational_Imitation_results/%s', ...
                    pdf_title);
file_path = strcat(doc_title, '_001.pdf');
if exist(file_path, 'file') == 2
  file_pattern = strcat(doc_title, '_*.pdf');
  file_num = length(dir(file_pattern))+1;
  file_path = sprintf('/data/pt_01798/Rational_Imitation_results/%s_%03d.pdf', ... 
                      pdf_title, file_num);
end
print(gcf, '-dpdf', file_path);

end
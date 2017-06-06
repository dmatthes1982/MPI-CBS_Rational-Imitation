%% Determine frequencies of interest
freq    = [6];                                                                

if(length(freq) > 2)
  error('Define a single frequency or specify a frequency range');
end

if(length(freq) == 1)
  [~, freqCols] = min(abs(data_hand_fft{1}.freq-freq));                     % Calculate data column of selected frequency
  actFreq       = data_hand_fft{1}.freq(freqCols);                          % Calculate actual frequency
end

if(length(freq) == 2)                                                       % Calculate data column range of selected frequency range
  idxLow = find(data_hand_fft{1}.freq >= freq(1), 1, 'first');
  idxHigh = find(data_hand_fft{1}.freq <= freq(2), 1, 'last');
  if idxLow == idxHigh
    freqCols = idxLow;
    actFreq  = data_hand_fft{1}.freq(freqCols);                             % Calculate actual frequency
  else
    freqCols = idxLow:idxHigh;
    actFreqLow = data_hand_fft{1}.freq(idxLow);
    actFreqHigh = data_hand_fft{1}.freq(idxHigh);
    actFreq = [actFreqLow actFreqHigh];                                     % Calculate actual frequency range
  end
end

%% Determine number of repetitions
numOfPart = find(~cellfun(@isempty, data_hand_fft));                        % Get numbers of good participants
dataLength = length(numOfPart);                                             % Get number of good participants

%% Create data table and between-subjects model of reapeated measure model
data = array2table(zeros(dataLength, 19), 'VariableNames', {...             % Generate data table
          'participant', ... 
          'F3Head', 'F4Head', 'FzHead', ...
          'C3Head', 'C4Head', 'CzHead', ...
          'P3Head', 'P4Head', 'PzHead', ...
          'F3Hand', 'F4Hand', 'FzHand', ...
          'C3Hand', 'C4Hand', 'CzHand', ... 
          'P3Hand', 'P4Hand', 'PzHand'});

data.participant = numOfPart';                                              % Put numbers of participants into the table
rowNum = 0;                                                                 % Initialize pointer to rows  

for i=1:1:length(trialsAveraged)                                            % Put FFT data into data table  
  if ~isempty(data_head_fft{i})
    rowNum = rowNum + 1;
    data(rowNum, 2:10) = num2cell(...
                    mean(data_head_fft{1, i}.powspctrm(:,freqCols),2)');
    data(rowNum, 11:19) = num2cell(...
                    mean(data_hand_fft{1, i}.powspctrm(:,freqCols),2)');
  end
end

%% Create within-subjects model
condVector = nominal(cat(1,repmat('Head',9,1), repmat('Hand',9,1)));
elecVector = nominal([1:9 1:9]');
withinDesign = table(condVector, elecVector, 'VariableNames', ...
                    {'Condition', 'Electrode'});
%% Build repeated measures model
repMeasMod = fitrm(data, 'F3Head-PzHand ~ 1', 'WithinDesign', withinDesign);

%% Calculate repeated measures ANOVA and epsilon adjustment
[rmANOVAtbl, ~, C, ~] = ranova(repMeasMod, 'WithinModel', ...
                    'Condition*Electrode');
           
for i=1:1:4
  [Q,~] = qr(C{i},0);
  Eps(i,:) = epsilon(repMeasMod, Q);
end

Eps.Properties.RowNames = {'(Intercept)', '(Intercept):Condition', ...
         '(Intercept):Electrode', '(Intercept):Condition:Electrode'};

comment = 'DF und MeanSq has the correct value for assumed sphericity';

%% Calculate effect size
% partial eta squared = SumSq(effect)/(SumSq(effect)+SumSq(error))
% -------------------------------------------------------------------------

rmANOVAtbl.pEtaSq = zeros(8,1);
rmANOVAtbl.pEtaSq(1) = rmANOVAtbl.SumSq(1) / (rmANOVAtbl.SumSq(1) + ...
                        rmANOVAtbl.SumSq(2));
rmANOVAtbl.pEtaSq(3) = rmANOVAtbl.SumSq(3) / (rmANOVAtbl.SumSq(3) + ...
                        rmANOVAtbl.SumSq(4));
rmANOVAtbl.pEtaSq(5) = rmANOVAtbl.SumSq(5) / (rmANOVAtbl.SumSq(5) + ...
                        rmANOVAtbl.SumSq(6));
rmANOVAtbl.pEtaSq(7) = rmANOVAtbl.SumSq(7) / (rmANOVAtbl.SumSq(7) + ...
                        rmANOVAtbl.SumSq(8));
                      
%% Clear variables                  
% -------------------------------------------------------------------------

clear freq freqCols idxLow idxHigh actFreqLow actFreqHigh numOfPart ...
      dataLength rowNum i condVector elecVector C Q

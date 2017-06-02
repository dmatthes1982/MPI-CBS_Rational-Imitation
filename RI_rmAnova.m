freq    = 6;                                                                % Define frequency of interest
freqCol = find(data_hand_fft{1}.freq == freq);                              % Calculate data column of selected frequency

numOfPart = find(~cellfun(@isempty, data_hand_fft));                        % Get numbers of good participants
dataLength = length(numOfPart);                                             % Get number of good participants

data = array2table(zeros(dataLength, 19), 'VariableNames', {...             % Generate data table
          'participant', ... 
          'F3Head', 'F4Head', 'FzHead', ...
          'C3Head', 'C4Head', 'CzHead', ...
          'P3Head', 'P4Head', 'PzHead', ...
          'F3Hand', 'F4Hand', 'FzHand', ...
          'C3Hand', 'C4Hand', 'CzHand', ... 
          'P3Hand', 'P4Hand', 'PzHand'});

data.participant = numOfPart';                                              % Put numbers of participants into the table

rowNum = 0;

for i=1:1:length(trialsAveraged)                                            % Put FFT data into data table  
  if ~isempty(data_head_fft{i})
    rowNum = rowNum + 1;
    data(rowNum, 2:10) = num2cell(data_head_fft{1, i}.powspctrm(:,freqCol)');
    data(rowNum, 11:19) = num2cell(data_hand_fft{1, i}.powspctrm(:,freqCol)');
  end
end

condVector = nominal(cat(1,repmat('Head',9,1), repmat('Hand',9,1)));
elecVector = nominal([1:9 1:9]');
withinDesign = table(condVector, elecVector, 'VariableNames', ...
                    {'Condition', 'Electrode'});

repMod = fitrm(data, 'F3Head-PzHand ~ 1', 'WithinDesign', withinDesign);
rmANOVAtbl = ranova(repMod, 'WithinModel', ...
                    'Condition*Electrode');

clear freq freqCol numOfPart dataLength rowNum i condVector elecVector
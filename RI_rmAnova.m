freq    = 6;                                                                % Define frequency of interest
freqCol = find(data_hand_fft{1}.freq == freq);                              % Calculate data column of selected frequency

numOfPart = find(~cellfun(@isempty, data_hand_fft));                        % Get numbers of good participants
dataLength = length(numOfPart);                                             % Get number of good participants

data = array2table(zeros(dataLength, 19), 'VariableNames', {...             % Generate data table
          'participant', ... 
          'F3_head', 'F4_head', 'Fz_head', ...
          'C3_head', 'C4_head', 'Cz_head', ...
          'P3_head', 'P4_head', 'Pz_head', ...
          'F3_hand', 'F4_hand', 'Fz_hand', ...
          'C3_hand', 'C4_hand', 'Cz_hand', ... 
          'P3_hand', 'P4_hand', 'Pz_hand'});

data.participant = numOfPart';                                              % Put numbers of participants into the table

rowNum = 0;

for i=1:1:length(trialsAveraged)                                            % Put FFT data into data table  
  if ~isempty(data_head_fft{i})
    rowNum = rowNum + 1;
    data(rowNum, 2:10) = num2cell(data_head_fft{1, i}.powspctrm(:,freqCol)');
    data(rowNum, 11:19) = num2cell(data_hand_fft{1, i}.powspctrm(:,freqCol)');
  end
end

condVector = cat(1,repmat({'Head'},9,1), repmat({'Hand'},9,1));
elecVector = [1:9 1:9]';
withinDesign = dataset(condVector, elecVector, 'VarNames', ...
                    {'Condition', 'Electrode'});

rm = fitrm(data, 'F3_head-Pz_hand~1', 'WithinDesign', withinDesign, ...
           'WithinModel', 'Condition+Electrode');
rmANOVAtbl = ranova(rm, 'WithinModel', 'Condition+Electrode');

clear freq freqCol numOfPart dataLength rowNum i condVector elecVector
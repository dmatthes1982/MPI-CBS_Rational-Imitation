% -------------------------------------------------------------------------
% EXPERIMENT - HANDS FREE
% -------------------------------------------------------------------------

%% import and revice data
[data_head, data_hand, trialsAveraged] = RI_preprocBVA( ...
  '../../data/RationalImitation/handsFree_SegHead_BVA/', ...
  '../../data/RationalImitation/handsFree_SegHand_BVA/', ...
  52 );
%% export reviced data into a mat-File
dest_folder = '../../processed/RationalImitation/';
file_name = strcat(dest_folder, ...
                  'RationalImitation_handsFree_01_Preprocessed');
file_path = strcat(file_name, '_001.mat');
if exist(file_path, 'file') == 2
  file_pattern = strcat(file_name, '_*.mat');
  file_num = length(dir(file_pattern))+1;
  file_version = sprintf('_%03d.mat', file_num);
  file_path = strcat(file_name, file_version);
end
save(file_path, 'data_head', 'data_hand', 'trialsAveraged');

%% shorten trials
data_head_short=RI_redefinetrial(data_head);
data_hand_short=RI_redefinetrial(data_hand);

clear data_head data_hand

%% export shortened trials into a mat-File
file_name = strcat(dest_folder, ...
                  'RationalImitation_handsFree_02_Shorten');
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_short', 'data_hand_short', 'trialsAveraged');

%% calculate PSD
data_head_fft=RI_psdanalysis(data_head_short);
data_hand_fft=RI_psdanalysis(data_hand_short);

clear data_head_short data_hand_short

%% export psd data into a mat-File
file_name = strcat(dest_folder, ...
                  'RationalImitation_handsFree_03_FFT');
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_fft', 'data_hand_fft', 'trialsAveraged');

%% calculate mean PSD over all people
RI_averagePeople;

%% export psd data into a mat-File
file_name = strcat(dest_folder, ...
                  'RationalImitation_handsFree_04_FFTmean');
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_fft_mean', 'data_hand_fft_mean');

%% create and export plots
RI_psdPlot(data_head_fft, ...
          'Hands free - Condition: Head - Mean power of every person', ...
          'Handsfree-Head');
RI_psdPlot(data_hand_fft, ...
          'Hands free - Condition: Hand - Mean power of every person', ...
          'Handsfree-Hand');
RI_psdPlot(data_head_fft_mean, ...
          'Hands free - Condition: Head - Power over all persons', ...
          'Handsfree-HeadMean');
RI_psdPlot(data_hand_fft_mean, ...
          'Hands free - Condition: Hand - Power over all persons', ...
          'Handsfree-HandMean');

data_fft_mean = cell(1,2);
data_fft_mean{1} = data_hand_fft_mean;
data_fft_mean{2} = data_head_fft_mean;

RI_psdPlot(data_fft_mean, ...
          'Hands free - Condition: Hand & Head - Power over all persons', ...
          'Handsfree-Compare-HandHeadMean');

clear data_head_fft data_head_fft_mean data_hand_fft data_hand_fft_mean ... 
      trialsAveraged

% -------------------------------------------------------------------------
% EXPERIMENT - HANDS RESTRAINT
% -------------------------------------------------------------------------

%% import and revice data
[data_head, data_hand, trialsAveraged] = RI_preprocBVA( ...
  '../../data/RationalImitation/handsRestr_SegHead_BVA/', ...
  '../../data/RationalImitation/handsRestr_SegHand_BVA/', ...
  68 );
%% export reviced data into a mat-File
dest_folder = '../../processed/RationalImitation/';
file_name = strcat(dest_folder, ...
                  'RationalImitation_handsRestr_01_Preprocessed');
file_path = strcat(file_name, '_001.mat');
if exist(file_path, 'file') == 2
  file_pattern = strcat(file_name, '_*.mat');
  file_num = length(dir(file_pattern))+1;
  file_version = sprintf('_%03d.mat', file_num);
  file_path = strcat(file_name, file_version);
end
save(file_path, 'data_head', 'data_hand', 'trialsAveraged');

%% shorten trials
data_head_short=RI_redefinetrial(data_head);
data_hand_short=RI_redefinetrial(data_hand);

clear data_head data_hand

%% export shortened trials into a mat-File
file_name = strcat(dest_folder, ...
                  'RationalImitation_handsRestr_02_Shorten');
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_short', 'data_hand_short', 'trialsAveraged');

%% calculate PSD
data_head_fft=RI_psdanalysis(data_head_short);
data_hand_fft=RI_psdanalysis(data_hand_short);

clear data_head_short data_hand_short

%% export psd data into a mat-File
file_name = strcat(dest_folder, ...
                  'RationalImitation_handsRestr_03_FFT');
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_fft', 'data_hand_fft', 'trialsAveraged');

%% calculate mean PSD over all people
RI_averagePeople;

%% export psd data into a mat-File
file_name = strcat(dest_folder, ...
                  'RationalImitation_handsRestr_04_FFTmean');
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_fft_mean', 'data_hand_fft_mean');

% create and export plots
RI_psdPlot(data_head_fft, ...
          'Hands restraint - Condition: Head - Mean power of every person', ...
          'Handsrestr-Head');
RI_psdPlot(data_hand_fft, ...
          'Hands restraint - Condition: Hand - Mean power of every person', ...
          'Handsrestr-Hand');
RI_psdPlot(data_head_fft_mean, ...
          'Hands restraint - Condition: Head - Power over all persons', ...
          'Handsrestr-HeadMean');
RI_psdPlot(data_hand_fft_mean, ...
          'Hands restraint - Condition: Hand - Power over all persons', ...
          'Handsrestr-HandMean');

data_fft_mean = cell(1,2);
data_fft_mean{1} = data_hand_fft_mean;
data_fft_mean{2} = data_head_fft_mean;

RI_psdPlot(data_fft_mean, ...
          'Hands restraint - Condition: Hand & Head - Power over all persons', ...
          'Handsrestr-Compare-HandHeadMean');

clear data_head_fft data_head_fft_mean data_hand_fft data_hand_fft_mean ... 
      trialsAveraged file_name file_path file_pattern file_num ...
      file_version dest_folder data_fft_mean
    
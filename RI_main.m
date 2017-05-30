% -------------------------------------------------------------------------
% GENERAL DESCRIPTIONS
% -------------------------------------------------------------------------
data_import = 1;                                                            % 1 = Import data from BVA files / 0 = Load already imported data

if data_import == 0
  selected_version = 1;                                                     % Select version of already imported data / if data_import = 1, variable is not used 
end

children = 0;                                                               % 1 = Dataset with children / 0 = Dataset with adults

if children == 0                                                            % Adults
  handsFree_SegHand_srcFolder = ...
    '../../data/RationalImitation/handsFree_Ad_SegHand_BVA/';
  handsFree_SegHead_srcFolder = ...
    '../../data/RationalImitation/handsFree_Ad_SegHead_BVA/';
  handsRestr_SegHand_srcFolder = ...
    '../../data/RationalImitation/handsRestr_Ad_SegHand_BVA/';
  handsRestr_SegHead_srcFolder = ...
    '../../data/RationalImitation/handsRestr_Ad_SegHead_BVA/';
  participants_handsFree = 32;
  participants_handsRestr = 27;
  handsFree_out_01_name = 'RI_handsFree_Ad_01_Preprocessed';
  handsFree_out_02_name = 'RI_handsFree_Ad_02_Shorten';
  handsFree_out_03_name = 'RI_handsFree_Ad_03_FFT';
  handsFree_out_04_name = 'RI_handsFree_Ad_04_FFTmean';
  handsRestr_out_01_name = 'RI_handsRestr_Ad_01_Preprocessed';
  handsRestr_out_02_name = 'RI_handsRestr_Ad_02_Shorten';
  handsRestr_out_03_name = 'RI_handsRestr_Ad_03_FFT';
  handsRestr_out_04_name = 'RI_handsRestr_Ad_04_FFTmean';
  handsFree_fig_01_title = ... 
    'Adults - Hands free - Hand - Mean power of every person';
  handsFree_fig_02_title = ... 
    'Adults - Hands free - Head - Mean power of every person';
  handsFree_fig_03_title = ... 
    'Adults - Hands free - Hand - Power over all persons';
  handsFree_fig_04_title = ... 
    'Adults - Hands free - Head - Power over all persons';
  handsFree_fig_05_title = ... 
    'Adults - Hands free - Hand vs. Head - Power over all persons';
  handsRestr_fig_01_title = ... 
    'Adults - Hands restraint - Hand - Mean power of every person';
  handsRestr_fig_02_title = ... 
    'Adults - Hands restraint - Head - Mean power of every person';
  handsRestr_fig_03_title = ... 
    'Adults - Hands restraint - Hand - Power over all persons';
  handsRestr_fig_04_title = ... 
    'Adults - Hands restraint - Head - Power over all persons';
  handsRestr_fig_05_title = ... 
    'Adults - Hands restraint - Hand vs. Head - Power over all persons';
  handsFree_pdf_01_title = 'Adults-Handsfree-Hand';
  handsFree_pdf_02_title = 'Adults-Handsfree-Head';
  handsFree_pdf_03_title = 'Adults-Handsfree-HandMean';
  handsFree_pdf_04_title = 'Adults-Handsfree-HeadMean';
  handsFree_pdf_05_title = 'Adults-Handsfree-Compare-HandHeadMean';
  handsRestr_pdf_01_title = 'Adults-Handsrestr-Hand';
  handsRestr_pdf_02_title = 'Adults-Handsrestr-Head';
  handsRestr_pdf_03_title = 'Adults-Handsrestr-HandMean';
  handsRestr_pdf_04_title = 'Adults-Handsrestr-HeadMean';
  handsRestr_pdf_05_title = 'Adults-Handsrestr-Compare-HandHeadMean';
elseif children == 1                                                        % Children
  handsFree_SegHand_srcFolder = ...
    '../../data/RationalImitation/handsFree_SegHand_BVA/';
  handsFree_SegHead_srcFolder = ...
    '../../data/RationalImitation/handsFree_SegHead_BVA/';
  handsRestr_SegHand_srcFolder = ...
    '../../data/RationalImitation/handsRestr_SegHand_BVA/';
  handsRestr_SegHead_srcFolder = ...
    '../../data/RationalImitation/handsRestr_SegHead_BVA/';
  participants_handsFree = 52;
  participants_handsRestr = 68;
  handsFree_out_01_name = 'RI_handsFree_01_Preprocessed';
  handsFree_out_02_name = 'RI_handsFree_02_Shorten';
  handsFree_out_03_name = 'RI_handsFree_03_FFT';
  handsFree_out_04_name = 'RI_handsFree_04_FFTmean';
  handsRestr_out_01_name = 'RI_handsRestr_01_Preprocessed';
  handsRestr_out_02_name = 'RI_handsRestr_02_Shorten';
  handsRestr_out_03_name = 'RI_handsRestr_03_FFT';
  handsRestr_out_04_name = 'RI_handsRestr_04_FFTmean';
  handsFree_fig_01_title = ... 
    'Children - Hands free - Hand - Mean power of every person';
  handsFree_fig_02_title = ... 
    'Children - Hands free - Head - Mean power of every person';
  handsFree_fig_03_title = ... 
    'Children - Hands free - Hand - Power over all persons';
  handsFree_fig_04_title = ... 
    'Children - Hands free - Head - Power over all persons';
  handsFree_fig_05_title = ... 
    'Children - Hands free - Hand vs. Head - Power over all persons';
  handsRestr_fig_01_title = ... 
    'Children - Hands restraint - Hand - Mean power of every person';
  handsRestr_fig_02_title = ... 
    'Children - Hands restraint - Head - Mean power of every person';
  handsRestr_fig_03_title = ... 
    'Children - Hands restraint - Hand - Power over all persons';
  handsRestr_fig_04_title = ... 
    'Children - Hands restraint - Head - Power over all persons';
  handsRestr_fig_05_title = ... 
    'Children - Hands restraint - Hand vs. Head - Power over all persons';
  handsFree_pdf_01_title = 'Children-Handsfree-Hand';
  handsFree_pdf_02_title = 'Children-Handsfree-Head';
  handsFree_pdf_03_title = 'Children-Handsfree-HandMean';
  handsFree_pdf_04_title = 'Children-Handsfree-HeadMean';
  handsFree_pdf_05_title = 'Children-Handsfree-Compare-HandHeadMean';
  handsRestr_pdf_01_title = 'Children-Handsrestr-Hand';
  handsRestr_pdf_02_title = 'Children-Handsrestr-Head';
  handsRestr_pdf_03_title = 'Children-Handsrestr-HandMean';
  handsRestr_pdf_04_title = 'Children-Handsrestr-HeadMean';
  handsRestr_pdf_05_title = 'Children-Handsrestr-Compare-HandHeadMean';
end

% -------------------------------------------------------------------------
% EXPERIMENT - HANDS FREE
% -------------------------------------------------------------------------

%% import and revice data (Step 1)
if data_import == 1
  [data_hand, data_head, trialsAveraged] = RI_preprocBVA( ...
    handsFree_SegHand_srcFolder, handsFree_SegHead_srcFolder, ...
    participants_handsFree );
else
  dest_folder = '../../processed/RationalImitation/';
  file_name = strcat(dest_folder, handsFree_out_01_name);
  file_version = sprintf('_%03d.mat', selected_version);
  file_path = strcat(file_name, file_version);
  load(file_path);
end

%% export reviced data into a mat-File 
if data_import == 1
  dest_folder = '../../processed/RationalImitation/';
  file_name = strcat(dest_folder, handsFree_out_01_name);
  file_path = strcat(file_name, '_001.mat');
  file_version = '_001.mat';
  if exist(file_path, 'file') == 2
    file_pattern = strcat(file_name, '_*.mat');
    file_num = length(dir(file_pattern))+1;
    file_version = sprintf('_%03d.mat', file_num);
    file_path = strcat(file_name, file_version);
  end
  save(file_path, 'data_head', 'data_hand', 'trialsAveraged');
else
  file_pattern = strcat(dest_folder, handsFree_out_02_name, '_*.mat' );
  file_num = length(dir(file_pattern))+1;
  file_version = sprintf('_%03d.mat', file_num);
end

%% shorten trials (Step 2)
data_head_short = RI_redefinetrial(data_head);
data_hand_short = RI_redefinetrial(data_hand);

clear data_head data_hand

%% export shortened trials into a mat-File
file_name = strcat(dest_folder, handsFree_out_02_name);
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_short', 'data_hand_short', 'trialsAveraged');

%% calculate PSD (Step 3)
data_head_fft = RI_psdanalysis(data_head_short);
data_hand_fft = RI_psdanalysis(data_hand_short);

clear data_head_short data_hand_short

%% export psd data into a mat-File
file_name = strcat(dest_folder, handsFree_out_03_name);
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_fft', 'data_hand_fft', 'trialsAveraged');

%% calculate mean PSD over all people (Step 4)
RI_averagePeople;

%% export psd data into a mat-File
file_name = strcat(dest_folder, handsFree_out_04_name);
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_fft_mean', 'data_hand_fft_mean');

%% create and export plots
RI_psdPlot(data_hand_fft, handsFree_fig_01_title, handsFree_pdf_01_title);
RI_psdPlot(data_head_fft, handsFree_fig_02_title, handsFree_pdf_02_title);
RI_psdPlot(data_hand_fft_mean, handsFree_fig_03_title, ...
          handsFree_pdf_03_title);
RI_psdPlot(data_head_fft_mean, handsFree_fig_04_title, ...
          handsFree_pdf_04_title);

data_fft_mean = cell(1,2);
data_fft_mean{1} = data_hand_fft_mean;
data_fft_mean{2} = data_head_fft_mean;

RI_psdPlot(data_fft_mean, handsFree_fig_05_title, handsFree_pdf_05_title);
        
%% clear variables
clear data_head_fft data_head_fft_mean data_hand_fft data_hand_fft_mean ... 
      trialsAveraged data_fft_mean

% -------------------------------------------------------------------------
% EXPERIMENT - HANDS RESTRAINT
% -------------------------------------------------------------------------

%% import and revice data (Step 1)
if data_import == 1
  [data_hand, data_head, trialsAveraged] = RI_preprocBVA( ...
    handsRestr_SegHand_srcFolder, handsRestr_SegHead_srcFolder, ...
    participants_handsRestr);
else
  dest_folder = '../../processed/RationalImitation/';
  file_name = strcat(dest_folder, handsRestr_out_01_name);
  file_version = sprintf('_%03d.mat', selected_version);
  file_path = strcat(file_name, file_version);
  load(file_path);
end


%% export reviced data into a mat-File
if data_import == 1
  dest_folder = '../../processed/RationalImitation/';
  file_name = strcat(dest_folder, handsRestr_out_01_name);
  file_path = strcat(file_name, '_001.mat');
  file_version = '_001.mat';
  if exist(file_path, 'file') == 2
    file_pattern = strcat(file_name, '_*.mat');
    file_num = length(dir(file_pattern))+1;
    file_version = sprintf('_%03d.mat', file_num);
    file_path = strcat(file_name, file_version);
  end
  save(file_path, 'data_head', 'data_hand', 'trialsAveraged');
else
  file_pattern = strcat(dest_folder, handsRestr_out_02_name, '_*.mat');
  file_num = length(dir(file_pattern))+1;
  file_version = sprintf('_%03d.mat', file_num);
end

%% shorten trials (Step 2)
data_head_short=RI_redefinetrial(data_head);
data_hand_short=RI_redefinetrial(data_hand);

clear data_head data_hand

%% export shortened trials into a mat-File
file_name = strcat(dest_folder, handsRestr_out_02_name);
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_short', 'data_hand_short', 'trialsAveraged');

%% calculate PSD (Step 3)
data_head_fft=RI_psdanalysis(data_head_short);
data_hand_fft=RI_psdanalysis(data_hand_short);

clear data_head_short data_hand_short

%% export psd data into a mat-File
file_name = strcat(dest_folder, handsRestr_out_03_name);
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_fft', 'data_hand_fft', 'trialsAveraged');

%% calculate mean PSD over all people (Step 4)
RI_averagePeople;

%% export psd data into a mat-File
file_name = strcat(dest_folder, handsRestr_out_04_name);
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_fft_mean', 'data_hand_fft_mean');

%% create and export plots
RI_psdPlot(data_hand_fft, handsRestr_fig_01_title, handsRestr_pdf_01_title);
RI_psdPlot(data_head_fft, handsRestr_fig_02_title, handsRestr_pdf_02_title);
RI_psdPlot(data_hand_fft_mean, handsRestr_fig_03_title, ...
          handsRestr_pdf_03_title);
RI_psdPlot(data_head_fft_mean, handsRestr_fig_04_title, ...
          handsRestr_pdf_04_title);

data_fft_mean = cell(1,2);
data_fft_mean{1} = data_hand_fft_mean;
data_fft_mean{2} = data_head_fft_mean;

RI_psdPlot(data_fft_mean, handsRestr_fig_05_title, handsRestr_pdf_05_title);
        
%% clear variables
clear data_head_fft data_head_fft_mean data_hand_fft data_hand_fft_mean ... 
      trialsAveraged file_name file_path file_pattern file_num ...
      file_version dest_folder data_fft_mean data_import selected_version ...
      children handsFree_SegHand_srcFolder handsFree_SegHead_srcFolder ...
      handsRestr_SegHand_srcFolder handsRestr_SegHead_srcFolder ...
      participants_handsFree participants_handsRestr handsFree_out_01_name ...
      handsFree_out_02_name handsFree_out_03_name handsFree_out_04_name ...
      handsRestr_out_01_name handsRestr_out_02_name handsRestr_out_03_name ...
      handsRestr_out_04_name handsFree_pdf_01_title handsFree_pdf_02_title ...
      handsFree_pdf_03_title handsFree_pdf_04_title handsFree_pdf_05_title ...
      handsRestr_pdf_01_title handsRestr_pdf_02_title handsRestr_pdf_03_title ...
      handsRestr_pdf_04_title handsRestr_pdf_05_title handsFree_fig_01_title ...
      handsFree_fig_02_title handsFree_fig_03_title handsFree_fig_04_title ...
      handsFree_fig_05_title handsRestr_fig_01_title handsRestr_fig_02_title ...
      handsRestr_fig_03_title handsRestr_fig_04_title handsRestr_fig_05_title
    
function RI_main( cfg )
% RI_MAIN is main analysis function of the "Rational Imitation" study. It
% includes the whole pipeline from the data import to the export of
% generated figures into a pdf file.
%
% Use as
%   RI_main( cfg )
%
% The configuration can have the following parameters:
%   cfg.condition = 'HandsFree', 'HandsRestrained' (default: 'HandsFree')
%   cfg.agegroup  = '9Months', '12Months', 'Adults' (default: '12Months')
%   cfg.import    = 'yes', 'no' (Import from original files) (default: 'yes')
%   cfg.version   = number (only relevant if cfg.import == 'no') (default: 1)
%
% This function requires the fieldtrip toolbox
%
% See also RI_PREPROCBVA, RI_REDEFINETRIAL, RI_PSDANALYSIS,
% RI_AVERAGEPEOPLE, RI_PSDPLOT 

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------

condition = ft_getopt(cfg, 'condition', 'HandsFree');
agegroup  = ft_getopt(cfg, 'agegroup', '12Months');
import    = ft_getopt(cfg, 'import', 'yes');                                % if import == 0, already imported data will be loaded
version   = ft_getopt(cfg, 'version', '1');                                 % is only used, if import == 'no'

switch condition
  case 'HandsFree'
    condFileString = 'handsFree';
    condFigString = 'Hands free';
  case 'HandsRestrained'
    condFileString = 'handsRestr';
    condFigString = 'Hands restrained';
  otherwise
    error('This condition currently does not exist.');
end

switch agegroup                                                             % if further agegroups are available, just add one new case and update the function description
  case '9Months'
    acronym = '9M';
    grpFigString = 'Infants 9M';
    grpFileString = 'Infants-9M';
    if strcmp(condition, 'HandsFree')
      part = 74;
    else
      error('No data for Infants 9M - Hands restrained available');
    end
  case '12Months'
    acronym = '12M';
    grpFigString = 'Infants 12M';
    grpFileString = 'Infants-12M';
    if strcmp(condition, 'HandsFree')
      part = 52;
    else
      part = 68;
    end
  case 'Adults'
    acronym = 'AD';
    grpFigString = 'Adults';
    grpFileString = 'Adults';
    if strcmp(condition, 'HandsFree')
      part = 32;
    else
      part = 27;
    end
  otherwise
    error('This agegroup currently does not exist.');
end

% -------------------------------------------------------------------------
% Import and revice data (Step 1)
% -------------------------------------------------------------------------
if strcmp(import, 'yes')
  [data_hand, data_head, trialsAveraged] = RI_preprocBVA( ...
    sprintf('/data/pt_01798/Rational_Imitation_processedBVA/%s_%s_SegHand_BVA/', ...
           condFileString, acronym), ...
    sprintf('/data/pt_01798/Rational_Imitation_processedBVA/%s_%s_SegHead_BVA/', ...
           condFileString, acronym), ...
           part ); %#ok<ASGLU>
else
  dest_folder = '/data/pt_01798/Rational_Imitation_processedFT/';
  file_name = strcat(dest_folder, sprintf('RI_%s_%s_01_Preprocessed', ...
              condFileString, acronym));
  file_version = sprintf('_%03d.mat', version);
  file_path = strcat(file_name, file_version);
  file_num = length(dir(file_path));
  if ~isemty(file_num)
    load(file_path);
  else
    error('File %s does not exist', file_path);
  end
end

% -------------------------------------------------------------------------
% Export reviced data into a mat-File
% -------------------------------------------------------------------------
if strcmp(import, 'yes')
  dest_folder = '/data/pt_01798/Rational_Imitation_processedFT/';
  file_name = strcat(dest_folder, sprintf('RI_%s_%s_01_Preprocessed', ...
              condFileString, acronym));
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
  file_pattern = strcat(dest_folder, sprintf('RI_%s_%s_02_Shorten', ...
                 condFileString, acronym), '_*.mat' );
  file_num = length(dir(file_pattern))+1;
  file_version = sprintf('_%03d.mat', file_num);
end

% -------------------------------------------------------------------------
% Shorten trials (Step 2)
% -------------------------------------------------------------------------
data_head_short = RI_redefinetrial(data_head);
data_hand_short = RI_redefinetrial(data_hand);

% -------------------------------------------------------------------------
% Export shortened trials into a mat-File
% -------------------------------------------------------------------------
file_name = strcat(dest_folder, sprintf('RI_%s_%s_02_Shorten', ...
                 condFileString, acronym));
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_short', 'data_hand_short', 'trialsAveraged');

% -------------------------------------------------------------------------
% Calculate PSD (Step 3)
% -------------------------------------------------------------------------
data_head_fft = RI_psdanalysis(data_head_short);
data_hand_fft = RI_psdanalysis(data_hand_short);

% -------------------------------------------------------------------------
% Export psd data into a mat-File
% -------------------------------------------------------------------------
file_name = strcat(dest_folder, sprintf('RI_%s_%s_03_FFT', ...
                 condFileString, acronym));
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_fft', 'data_hand_fft', 'trialsAveraged');

% -------------------------------------------------------------------------
% Calculate mean PSD over all people (Step 4)
% -------------------------------------------------------------------------
[data_hand_fft_mean, data_head_fft_mean, data_all_fft_mean] = ...
                RI_averagePeople(data_hand_fft, data_head_fft);             %#ok<ASGLU>

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'subtract';
                                          
data_diff_fft_mean = ft_math(cfg, data_hand_fft_mean, data_head_fft_mean);  %#ok<NASGU>

% -------------------------------------------------------------------------
% Export psd data into a mat-File
% -------------------------------------------------------------------------
file_name = strcat(dest_folder, sprintf('RI_%s_%s_04_FFTmean', ...
                 condFileString, acronym));
file_path = strcat(file_name, file_version);
save(file_path, 'data_head_fft_mean', 'data_hand_fft_mean', ...
                'data_diff_fft_mean', 'data_all_fft_mean');

% -------------------------------------------------------------------------
% Create and export plots
% -------------------------------------------------------------------------
cfg = [];
cfg.fig_title = sprintf('%s - %s - Hand - Mean power of every person', ... 
                  grpFigString, condFigString);
cfg.pdf_title = sprintf('%s-%s-Hand', grpFileString, condFileString);
RI_psdPlot(cfg, data_hand_fft);

cfg.fig_title = sprintf('%s - %s - Head - Mean power of every person', ... 
                  grpFigString, condFigString);
cfg.pdf_title = sprintf('%s-%s-Head', grpFileString, condFileString);
RI_psdPlot(cfg, data_head_fft);

cfg.fig_title = sprintf('%s - %s - Hand - Power over all persons', ... 
                  grpFigString, condFigString);
cfg.pdf_title = sprintf('%s-%s-HandMean', grpFileString, condFileString);
RI_psdPlot(cfg, data_hand_fft_mean);

cfg.fig_title = sprintf('%s - %s - Head - Power over all persons', ... 
                  grpFigString, condFigString);
cfg.pdf_title = sprintf('%s-%s-HeadMean', grpFileString, condFileString);
RI_psdPlot(cfg, data_head_fft_mean);

data_fft_mean = cell(1,2);
data_fft_mean{1} = data_hand_fft_mean;
data_fft_mean{2} = data_head_fft_mean;

cfg.fig_title = sprintf('%s - %s - Hand vs. Head - Power over all persons', ... 
                  grpFigString, condFigString);
cfg.pdf_title = sprintf('%s-%s-Compare-HandHeadMean', grpFileString, ...
                        condFileString);
RI_psdPlot(cfg, data_fft_mean);

end
    
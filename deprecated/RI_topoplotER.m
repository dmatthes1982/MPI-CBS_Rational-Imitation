function RI_topoplotER( cfg )
% RI_TOPOPLOTER a multiplot consisting of four power distributions over the
% head. The first figure shows the power for condition hand, the second one
% for condition head, the averaged power over all conditions is shown in
% figure three and the last one illustrates the difference between the two
% conditions. The electrodes of interest and the frequency region of 
% interest are free selectable.
%
% Use as
%   RI_topoplotER( cfg )
%
% The configuration can have the following parameters:
%   cfg.condition = 'HandsFree', 'HandsRestrained' (default: 'HandsFree')
%   cfg.agegroup  = '9Months', '12Months', '12MonthsV2', 'Adults' (default: '12Months')
%   cfg.foi       = [begin end] (default: [6 8]);
%   cfg.channel   = electrodes of interest (default: {'all', '-VEOG1', '-VEOG2', '-HEOG1', '-HEOG2'})
%   cfg.filename  = title of pdf file
%   cfg.version   = Version number of input data (default: 001)
%   cfg.zlim      = plotting limits for color dimension, 'maxmin', 'maxabs', 'zeromax', 'minzero', or [zmin zmax] (default: 'maxmin')
%
% This function requires the fieldtrip toolbox

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
condition = ft_getopt(cfg, 'condition', 'HandsFree');
agegroup  = ft_getopt(cfg, 'agegroup', '12Months');
foi       = ft_getopt(cfg, 'foi', [6 8]);
channel   = ft_getopt(cfg, 'channel', {'all', '-VEOG1', '-VEOG2', ...
                                              '-HEOG1', '-HEOG2'});
filename  = ft_getopt(cfg, 'filename', 'topoplot');
version   = ft_getopt(cfg, 'version', '001');
zlim      = ft_getopt(cfg, 'zlim', 'maxmin');

input_path = '/data/pt_01798/Rational_Imitation_processedFT';

switch condition
  case 'HandsFree'
    figure_title = 'Hands free';
    input_cond = 'handsFree';
  case 'HandsRestrained'
    figure_title = 'Hands restraint';
    input_cond = 'handsRestr';
  otherwise
    error('This condition currently does not exist.');
end

switch agegroup
  case '9Months'
    input_ag = '9M';
  case '12Months'
    input_ag = '12M';
  case '12MonthsV2'
    input_ag = '12Mv2';
  case 'Adults'
    input_ag = 'AD';
end

% -------------------------------------------------------------------------
% Load data
% -------------------------------------------------------------------------
input_file = sprintf('%s/RI_%s_%s_04_FFTmean_%s.mat', input_path, ...
                      input_cond, input_ag, version);
                    
load(input_file);

% -------------------------------------------------------------------------
% Create multiplot
% -------------------------------------------------------------------------
cfg = [];
cfg.parameter = 'powspctrm';
cfg.channel = channel;
cfg.baseline = 'no';
cfg.xlim = foi;
cfg.zlim = zlim;
cfg.colormap = 'jet';
cfg.marker = 'labels';
cfg.layout = 'hdbg_customized_acticap32.mat';
cfg.interplimits = 'head';
cfg.interpolation = 'v4';

figure(2);
subplot(2,2,1);
title(sprintf('%s - Condition: Hand', figure_title));
ft_topoplotER(cfg, data_hand_fft_mean);
colorbar;
subplot(2,2,2);
title(sprintf('%s - Condition: Head', figure_title));
ft_topoplotER(cfg, data_head_fft_mean);
colorbar;
subplot(2,2,3);
title(sprintf('%s - All Conditions', figure_title));
ft_topoplotER(cfg, data_all_fft_mean);
colorbar;
subplot(2,2,4);
title(sprintf('%s - Diff Hand/Head', figure_title));
ft_topoplotER(cfg, data_diff_fft_mean);
colorbar;

% -------------------------------------------------------------------------
% Save graphic as pdf-File
% -------------------------------------------------------------------------
h = gcf;
set(h, 'PaperOrientation','landscape');
set(h, 'PaperType','a3');
set(h, 'PaperUnit', 'centimeters');
set(h, 'PaperSize', [42 29.7]);
set(h, 'unit', 'normalized', 'Position', [0 0 0.9 0.9]);
doc_title = sprintf('/data/pt_01798/Rational_Imitation_results/%s', ...
                    filename);
file_path = strcat(doc_title, '_001.pdf');
if exist(file_path, 'file') == 2
  file_pattern = strcat(doc_title, '_*.pdf');
  file_num = length(dir(file_pattern))+1;
  file_path = sprintf('/data/pt_01798/Rational_Imitation_results/%s_%03d.pdf', ... 
                      filename, file_num);
end
print(gcf, '-dpdf', file_path);
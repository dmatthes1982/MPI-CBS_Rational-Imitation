if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '01c_pruned/';
  cfg.filename  = 'RA_SegHead_p30_01c_pruned';
  sessionNum    = RA_getSessionNum( cfg );
  if sessionNum == 0
    sessionNum = 1;
  end
  sessionStr    = sprintf('%03d', sessionNum);                              % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01778/eegData/EEG_RA_processedFT/';                   % destination path for processed data
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in repaired data folder
  sourceList    = dir([strcat(desPath, '01c_pruned/'), ...
                       strcat('RA_SegHead*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RA_SegHead_p%d_01c_pruned_', sessionStr, '.mat'));
  end
  numOfPart = sort(numOfPart);
end

%% part 2
% 1. estimate the power for each trial and average over trials.

cprintf([0,0.6,0], '<strong>[2] - Power analysis</strong>\n');
fprintf('\n');

%% power estimation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  fprintf('<strong>Participant %d</strong>\n\n', i);

  % SegHand data --------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01c_pruned/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_01c_pruned', i);
  cfg.sessionStr  = sessionStr;

  fprintf('Load pruned SegHand data...\n\n');
  RA_loadData( cfg );

  % estimate power
  fprintf('<strong>Estimate pure power...</strong>\n');
  data_pow = RA_pow(data_pruned);

  % export power data in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02_pow/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_02_pow', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('\nThe power data of participant %d in the SegHand condition will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_pow', data_pow);
  fprintf('Data stored!\n\n');
  clear data_pruned data_pow

  % SegHead data --------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01c_pruned/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_01c_pruned', i);
  cfg.sessionStr  = sessionStr;

  fprintf('Load pruned SegHead data...\n\n');
  RA_loadData( cfg );

  % estimate power
  fprintf('<strong>Estimate pure power...</strong>\n');
  data_pow = RA_pow(data_pruned);

  % export power data in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02_pow/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_02_pow', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('\nThe power data of participant %d in the SegHead condition will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_pow', data_pow);
  fprintf('Data stored!\n\n');
  clear data_pruned data_pow
end


%% clear workspace
clear i cfg file_path

if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '02_pow/';
  cfg.filename  = 'RA_SegHead_p30_02_pow';
  sessionNum    = RA_getSessionNum( cfg );
  if sessionNum == 0
    sessionNum = 1;
  end
  sessionStr    = sprintf('%03d', sessionNum);                              % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01778/eegData/EEG_RA_processedFT/';                   % destination path for processed data
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in pwelch data folder
  sourceList    = dir([strcat(desPath, '02_pow/'), ...
                       strcat('RA_SegHead*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RA_SegHead_p%d_02_pow_', sessionStr, '.mat'));
  end
  numOfPart = sort(numOfPart);
end

%% part 3
% 1. estimate power average in the range from 2 to 5.333 Hz
% 2. estimate power average in the range from 6 to 8 Hz

cprintf([0,0.6,0], '<strong>[3] - Averaging power over frequencies</strong>\n');
fprintf('\n');

%% estimate power average %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  fprintf('<strong>Participant %d</strong>\n\n', i);
  
  % SegHand data --------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_pow/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_02_pow', i);
  cfg.sessionStr  = sessionStr;

  fprintf('Load SegHand power data...\n');
  RA_loadData( cfg );
  
  % estimate power average in the range from 2 to 5.333 Hz
  fprintf('<strong>Estimate power average in the range from 2 to 5.333 Hz...</strong>\n');
  cfg           = [];
  cfg.freqrange = [2 5.34];
  
  data_powavg     = RA_powerAverage(cfg, data_pow);
  
  % export averaged data into *.mat files
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03a_avgpow2to5/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_03a_avgpow2to5', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The averaged power (data_pow, 2-5.333 Hz) of participant %d in the SegHand condition will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_powavg', data_powavg);
  fprintf('Data stored!\n\n');
  clear data_powavg
  
  % estimate power average in the range from 6 to 8 Hz
  fprintf('<strong>Estimate power average in the range from 6 to 8 Hz...</strong>\n');
  cfg           = [];
  cfg.freqrange = [6 8];
  
  data_powavg     = RA_powerAverage(cfg, data_pow);
  
  % export averaged data into *.mat files
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03b_avgpow6to9/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_03b_avgpow6to9', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The averaged power (data_pow, 6-8 Hz) of participant %d in the SegHand condition will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_powavg', data_powavg);
  fprintf('Data stored!\n\n');
  clear data_powavg data_pow
    
  % SegHead data ------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_pow/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_02_pow', i);
  cfg.sessionStr  = sessionStr;

  fprintf('Load SegHead power data...\n');
  RA_loadData( cfg );
  
  % estimate power average in the range from 2 to 5.333 Hz
  fprintf('<strong>Estimate power average in the range from 2 to 5.333 Hz...</strong>\n');
  cfg           = [];
  cfg.freqrange = [2 5.34];
  
  data_powavg     = RA_powerAverage(cfg, data_pow);
  
  % export averaged data into *.mat files
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03a_avgpow2to5/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_03a_avgpow2to5', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The averaged power (data_pow, 2-5.333 Hz) of participant %d in the SegHead condition will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_powavg', data_powavg);
  fprintf('Data stored!\n\n');
  clear data_powavg
  
  % estimate power average in the range from 6 to 8 Hz
  fprintf('<strong>Estimate power average in the range from 6 to 8 Hz...</strong>\n');
  cfg           = [];
  cfg.freqrange = [6 8];
  
  data_powavg     = RA_powerAverage(cfg, data_pow);
  
  % export averaged data into *.mat files
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03b_avgpow6to9/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_03b_avgpow6to9', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The averaged power (data_pow, 6-8 Hz) of participant %d in the SegHead condition will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_powavg', data_powavg);
  fprintf('Data stored!\n\n');
  clear data_powavg data_pow
end

%% clear workspace
clear i cfg file_path

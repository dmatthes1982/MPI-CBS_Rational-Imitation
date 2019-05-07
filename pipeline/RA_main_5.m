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
  desPath = ['/data/tu_dmatthes_temp/LanguageIntention/'...                 % destination path for processed data
             'eegData/EEG_RA_processedFT/'];
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in power data folder
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

%% part 5
% 1. average power results over participants

cprintf([0,0.6,0], '<strong>[5] - Averaging power over participants</strong>\n');
fprintf('\n');

%% load and structure data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_SegHand_pow     = cell(1, length(numOfPart));
data_SegHead_pow     = cell(1, length(numOfPart));

for i = 1:1:length(numOfPart)
  fprintf('<strong>Participant %d</strong>\n', numOfPart(i));
  % SegHand data ----------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_pow/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_02_pow', numOfPart(i));
  cfg.sessionStr  = sessionStr;

  fprintf('Load SegHand power data...\n');
  RA_loadData( cfg );
  data_SegHand_pow{i} = data_pow;
  
  clear data_pow
  
  % SegHead data ----------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_pow/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_02_pow', numOfPart(i));
  cfg.sessionStr  = sessionStr;

  fprintf('Load SegHead pow data...\n');
  RA_loadData( cfg );
  data_SegHead_pow{i} = data_pow;
  
  clear data_pow
end

%% estimate power average over participants %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfgAvg                = [];
cfgAvg.keepindividual = 'no';
cfgAvg.foilim         = 'all';
cfgAvg.channel        = 'all';
cfgAvg.parameter      = 'powspctrm';
cfgAvg.feedback       = 'no';
cfgAvg.showcallinfo   = 'no';

ft_info off;

% SegHand power data ------------------------------------------------------
fprintf('\n<strong>Average SegHand power results over participants...</strong>\n');
data_pow            = ft_freqgrandaverage(cfgAvg, data_SegHand_pow{:});
data_pow.numOfPart  = numOfPart;

% export averaged SegHand power results into *.mat files
cfg             = [];
cfg.desFolder   = strcat(desPath, '05_powop/');
cfg.filename    = 'RA_05_powop_SegHand';
cfg.sessionStr  = sessionStr;

file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                   '.mat');

fprintf('The averaged SegHand power results will be saved in:\n');
fprintf('%s ...\n', file_path);
RA_saveData(cfg, 'data_pow', data_pow);
fprintf('Data stored!\n\n');
clear data_pow data_SegHand_pow

% SegHead power data ------------------------------------------------------
fprintf('<strong>Average SegHead power results over participants...</strong>\n');
data_pow            = ft_freqgrandaverage(cfgAvg, data_SegHead_pow{:});
data_pow.numOfPart  = numOfPart;

% export averaged SegHead power results into *.mat files
cfg             = [];
cfg.desFolder   = strcat(desPath, '05_powop/');
cfg.filename    = 'RA_05_powop_SegHead';
cfg.sessionStr  = sessionStr;

file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                   '.mat');

fprintf('The averaged SegHead power results will be saved in:\n');
fprintf('%s ...\n', file_path);
RA_saveData(cfg, 'data_pow', data_pow);
fprintf('Data stored!\n');
clear data_pow data_SegHead_pow

ft_info on;

%% clear workspace
clear i cfg file_path cfgAvg


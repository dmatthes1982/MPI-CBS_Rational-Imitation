if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '01a_import/';
  cfg.filename  = 'RA_SegHand_p05_01a_import';
  sessionNum    = RA_getSessionNum( cfg );
  if sessionNum == 0
    sessionNum = 1;
  end
  sessionStr    = sprintf('%03d', sessionNum);                              % estimate current session number
end

if ~exist('srcPath', 'var')
  srcPath = '/data/pt_01778/eegData/EEG_RA_processedBVA/';                  % source path to raw data                 
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01778/eegData/EEG_RA_processedFT/';                   % destination path for processed data
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([srcPath, '/*SegHand.vhdr']);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}(7:end), '_ra%d_SegHand.vhdr');
  end
  
  numOfPart = sort(numOfPart);
end

%% part 1
% 1. import data from brain vision eeg files
% 2. reject segments with bad intervals
% 3. prune segments --> remove pre stimulus offset

cprintf([0,0.6,0], '<strong>[1] - Data import, bad segments and pre-stimulus offset rejection</strong>\n');
fprintf('\n');

%% import data from brain vision eeg files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  fprintf('<strong>Paricipant %d</strong>\n\n', i);
  
  % SegHand data ----------------------------------------------------------
  cfg           = [];
  cfg.path      = srcPath;
  cfg.part      = i;
  cfg.condition = 'SegHand';
  
  fprintf('<strong>Import SegHand data</strong> from: \n%s ...\n\n', cfg.path);
  data_import = RA_importDataset( cfg );
  
  % export imported data in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01a_import/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_01a_import', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('The imported SegHand data of participant %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_import', data_import);
  fprintf('Data stored!\n\n');
  clear data_import
  
  % SegHead data ----------------------------------------------------------
  cfg           = [];
  cfg.path      = srcPath;
  cfg.part      = i;
  cfg.condition = 'SegHead';
  
  fprintf('<strong>Import SegHead data</strong> from: \n%s ...\n\n', cfg.path);
  data_import = RA_importDataset( cfg );
  
  % export imported data in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01a_import/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_01a_import', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('The imported SegHead data of participant %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_import', data_import);
  fprintf('Data stored!\n\n');
  clear data_import
end

%% reject segments with bad intervals %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  fprintf('<strong>Participant %d</strong>\n\n', i);
  
  % Create settings file if not existing
  NoT_file = [desPath '00_settings/' ...
                    sprintf('numoftrials_%s', sessionStr) '.xls'];
  if ~(exist(NoT_file, 'file') == 2)                                        % check if number of trials file already exist
    cfg = [];
    cfg.desFolder   = [desPath '00_settings/'];
    cfg.type        = 'numoftrials';
    cfg.sessionStr  = sessionStr;

    RA_createTbl(cfg);                                                      % create number of trials file
  end

  % SegHand data ----------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01a_import/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_01a_import', i);
  cfg.sessionStr  = sessionStr;
    
  fprintf('Load imported SegHand data...\n\n');
  RA_loadData( cfg );
  
  % reject segments with bad intervals
  data_revised = RA_rejectBadIntervalArtifacts(data_import);
  
  numOfTrialsSegHand = length(data_import.trial);
  SegHandTrials      = 1:1:numOfTrialsSegHand;
  SegHandBadTrials   = SegHandTrials(~ismember(SegHandTrials, ...
                            data_revised.sampleinfo(:,2)/850));

  % export revised data in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01b_revised/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_01b_revised', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('\nThe revised SegHand data of participant %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_revised', data_revised);
  fprintf('Data stored!\n\n');
  clear data_import data_revised
  
  % SegHead data ----------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01a_import/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_01a_import', i);
  cfg.sessionStr  = sessionStr;
    
  fprintf('Load imported SegHead data...\n\n');
  RA_loadData( cfg );
  
  % reject segments with bad intervals
  data_revised = RA_rejectBadIntervalArtifacts(data_import);
  
  numOfTrialsSegHead = length(data_import.trial);
  SegHeadTrials      = 1:1:numOfTrialsSegHead;
  SegHeadBadTrials   = SegHeadTrials(~ismember(SegHeadTrials, ...
                            data_revised.sampleinfo(:,2)/850));

  % export revised data in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01b_revised/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_01b_revised', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('\nThe revised SegHead data of participant %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_revised', data_revised);
  fprintf('Data stored!\n\n');
  clear data_import data_revised

  % Load number of trials file
  T = readtable(NoT_file);
  warning off;
  T.participant(i - 4) = i;
  T.SegHandNoT(i - 4)  = numOfTrialsSegHand;
  T.SegHeadNoT(i - 4)  = numOfTrialsSegHead;
  T.SegHandBad(i - 4)  = {vec2str(SegHandBadTrials, [], [], 0)};
  T.SegHeadBad(i - 4)  = {vec2str(SegHeadBadTrials, [], [], 0)};
  T.SegHandNogT(i - 4) = numOfTrialsSegHand - size(SegHandBadTrials, 2);
  T.SegHeadNogT(i - 4) = numOfTrialsSegHead - size(SegHeadBadTrials, 2);
  warning on;

  clear numOfTrialsSegHand numOfTrialsSegHead SegHandBadTrials ...
        SegHeadBadTrials SegHandTrials SegHeadTrials

  % store settings table
  delete(NoT_file);
  writetable(T, NoT_file);
end

%% prune segments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  fprintf('<strong>Participant %d</strong>\n\n', i);
  
  % SegHand data ----------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01b_revised/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_01b_revised', i);
  cfg.sessionStr  = sessionStr;
    
  fprintf('Load revised SegHand data...\n');
  RA_loadData( cfg );
  
  % prune segments --> remove pre stimulus offset
  cfg         = [];
  cfg.begtime = 0;
  cfg.endtime = 1.5;

  data_pruned = RA_pruneSegments(cfg, data_revised);
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01c_pruned/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_01c_pruned', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('\nThe pruned SegHand data of participant %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_pruned', data_pruned);
  fprintf('Data stored!\n\n');
  clear data_revised data_pruned
  
  % SegHead data ----------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01b_revised/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_01b_revised', i);
  cfg.sessionStr  = sessionStr;
    
  fprintf('Load revised SegHead data...\n');
  RA_loadData( cfg );
  
  % prune segments --> remove pre stimulus offset
  cfg         = [];
  cfg.begtime = 0;
  cfg.endtime = 1.5;

  data_pruned = RA_pruneSegments(cfg, data_revised);
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01c_pruned/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_01c_pruned', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('\nThe pruned SegHead data of participant %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RA_saveData(cfg, 'data_pruned', data_pruned);
  fprintf('Data stored!\n\n');
  clear data_revised data_pruned
end

%% clear workspace
clear i cfg file_path T NoT_file

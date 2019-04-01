if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '03b_avgpow6to9/';
  cfg.filename  = 'RA_SegHead_p30_03b_avgpow6to9';
  sessionNum    = RA_getSessionNum( cfg );
  if sessionNum == 0
    sessionNum = 1;
  end
  sessionStr    = sprintf('%03d', sessionNum);                              % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01778/eegData/EEG_RA_processedFT/';                   % destination path for processed data
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in power data folder
  sourceList    = dir([strcat(desPath, '03b_avgpow6to9/'), ...
                       strcat('RA_SegHead*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RA_SegHead_p%d_03b_avgpow6to9_', sessionStr, '.mat'));
  end
  numOfPart = sort(numOfPart);
end

%% part 4
% 1. select specific results
% 2. load and structure data
% 3. do repeated measures ANOVA (rmANOVA)

cprintf([0,0.6,0], '<strong>[4] - Repeated measures ANOVA (rmANOVA)</strong>\n');
fprintf('\n');

%% select specific datasets %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Which result do you want to use for the analysis:\n');
  fprintf('[1] - Power result in a range from 2 to 5 Hz\n');
  fprintf('[2] - Power result in a range from 6 to 9 Hz\n');
  x = input('Option: ');

  switch x
    case 1
      selection = true;
      filename = '03a_avgpow2to5';
    case 2
      selection = true;
      filename = '03b_avgpow6to9';
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end
fprintf('\n');

%% load and structure data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_SegHand = cell(1, length(numOfPart));
data_SegHead = cell(1, length(numOfPart));

for i = 1:1:length(numOfPart)
  fprintf('<strong>Participant %d</strong>\n', numOfPart(i));
  % SegHand data --------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, filename, '/');
  cfg.filename    = sprintf('RA_SegHand_p%02d_%s', numOfPart(i), filename);
  cfg.sessionStr  = sessionStr;

  fprintf('Load SegHand data...\n');
  RA_loadData( cfg );
  
  data_SegHand{i} = data_powavg;
  
  % SegHead data ------------------------------------------------------
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, filename, '/');
  cfg.filename    = sprintf('RA_SegHead_p%02d_%s', numOfPart(i), filename);
  cfg.sessionStr  = sessionStr;

  fprintf('Load SegHead data...\n');
  RA_loadData( cfg );
  
  data_SegHead{i} = data_powavg;
end

clear data_powavg

%% do repeated measures ANOVA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cprintf([0,0.6,0], '\nMake your channel selection in curly brackets.\n');
cprintf([0,0.6,0], 'Here is an example which includes all possible mixtures: ''C3'',''P*'',''*4'',''F3+F4''\n');
cprintf([0,0.6,0], ['If you press just enter, the default setting:\n' ... 
                    '{''F3'',''F4'',''Fz'',''C3'',''C4'',''Cz'',''P3'',''P4'',''Pz''} will be used\n\n']);
    
x = input('Selection: ');
fprintf('\n');

cfg           = [];
cfg.numOfPart = numOfPart;
cfg.ident     = filename;
if ~isempty(x)
  cfg.channel   = x;
end

fprintf('<strong>Run repeated measures analysis of variance with selected datasets...\n</strong>');
data_rmanova  = RA_rmAnova(cfg, data_SegHand, data_SegHead);

% export ANOVA results into *.mat files
cfg             = [];
cfg.desFolder   = strcat(desPath, '04_rmanova/');
cfg.filename    = 'RA_04_rmanova';
cfg.sessionStr  = sessionStr;

file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                   '.mat');

fprintf('The result of the repeated measures ANOVA will be saved in:\n');
fprintf('%s ...\n', file_path);
RA_saveData(cfg, 'data_rmanova', data_rmanova);
fprintf('Data stored!\n\n');
clear data_rmanova data_SegHand data_SegHead

%% clear workspace
clear i cfg file_path selection filename x

function RA_easyExtPowPlot(cfg)
% RA_EASYEXTPOWPLOT is a function, which makes it easier to plot the power
% of multiple participants in one graphik.
%
% Use as
%   RA_easyExtPowPlot(cfg)
%
% where the input data have to be a result from RA_POW.
%
% The configuration options are
%   cfg.srcFolder   = source folder (default: '/data/pt_01778/eegData/EEG_RA_processedFT/02_pow/')
%   cfg.sessionStr  = session string (default: '001')
%   cfg.condition   = options: 'SegHand' or 'SegHead' (default: 'SegHand')
%   cfg.freqrange   = frequency range [fmin fmax], (default: [0 50])
%   cfg.electrode   = number of electrodes (default: {'Cz'} repsectively [10])
%                     examples: {'Cz'}, {'F3', 'Fz', 'F4'}, [10] or [1, 3, 2]
%
% This function requires the fieldtrip toolbox
%
% See also RA_POW

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
srcFolder   = ft_getopt(cfg, 'srcFolder', '/data/pt_01778/eegData/EEG_RA_processedFT/02_pow/');
sessionStr  = ft_getopt(cfg, 'sessionStr', '001');
condition   = ft_getopt(cfg, 'condition', 'SegHand');
freqrange   = ft_getopt(cfg, 'freqrange', [0 50]);
elec        = ft_getopt(cfg, 'electrode', {'Cz'});

if ~ismember(condition, {'SegHead','SegHand'})
  error('Invalid condition! Choose either ''SegHand'' or ''SegHead''.');
end

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
fprintf('Select Participants...\n\n');
fileList     = dir([srcFolder 'RA_' condition '_p*_02_pow_' ...
                    sessionStr '.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);                                               % generate list with file names of all existing participants
numOfFiles   = length(fileList);

listOfPart = zeros(numOfFiles, 1);

for i = 1:1:numOfFiles
  listOfPart(i) = sscanf(fileList{i}, ['RA_' condition '_p%d_02_pow_' ...   % generate a list of all available numbers of participants
                                        sessionStr '.mat']);
end

listOfPartStr = num2cell(listOfPart);
listOfPartStr = cellfun(@(x) num2str(x), listOfPartStr, ...
                        'UniformOutput', false);
part = listdlg('ListString', listOfPartStr);                                % open the dialog window --> the user can select the participants of interest

fileList      = fileList(ismember(1:1:numOfFiles, part));                   % reduce file list to selection
listOfPart    = listOfPart(ismember(1:1:numOfFiles, part));
listOfPartStr = num2cell(listOfPart);
listOfPartStr = cellfun(@(x) num2str(x), listOfPartStr, ...
                        'UniformOutput', false);
numOfFiles    = length(fileList);                                           % estimate actual number of files (participants)

% -------------------------------------------------------------------------
% Check freqrange electrode 
% -------------------------------------------------------------------------
load([srcFolder fileList{1}]);                                                %#ok<LOAD> % load data of first participant

begCol = find(data_pow.freq >= freqrange(1), 1, 'first');                   % estimate desired powspctrm colums
endCol = find(data_pow.freq <= freqrange(2), 1, 'last');

label     = data_pow.label;                                                 % get labels 
if isnumeric(elec)                                                          % check cfg.electrode
  for i=1:length(elec)
    if elec(i) < 1 || elec(i) > 32
      error('cfg.elec has to be a numbers between 1 and 32 or a existing labels like {''Cz''}.');
    end
  end
else
  tmpElec = zeros(1, length(elec));
  for i=1:length(elec)
    tmpElec(i) = find(strcmp(label, elec{i}));
    if isempty(tmpElec(i))
      error('cfg.elec has to be a cell array of existing labels like ''Cz''or a vector of numbers between 1 and 32.');
    end
  end
  elec = tmpElec;
end

labelString = strjoin(data_pow.label(elec), ',');

% -------------------------------------------------------------------------
% Plot power
% -------------------------------------------------------------------------
fprintf('Plot signals...\n');
figure();
if length(elec) == 1
  title(sprintf('Power - %s - %s', condition, labelString));
else
  title(sprintf('Power - %s - %s (averaged)', condition, labelString));
end
xlabel('frequency in Hz');                                                  % set xlabel
ylabel('power in \muV^2');                                                  % set ylabel
hold on;

f = waitbar(0,'Please wait...');

for i = 1:1:numOfFiles
  load([srcFolder fileList{i}]);                                              %#ok<LOAD>
  waitbar(i/numOfFiles, f, 'Please wait...');
  
  plot(data_pow.freq(begCol:endCol), mean(data_pow.powspctrm(elec, begCol:endCol),1));

  clear data_pow
end

close(f);                                                                   % close waitbar
legend(listOfPartStr);                                                      % add legend

end

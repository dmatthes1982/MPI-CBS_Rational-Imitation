function [ data_peak ] = RA_findPeak(cfg)
% RA_FINDPEAK searches for peaks in a certain passband of a certain
% electrode. The most prominent peak will be returned.
%
% Use as
%   [ data_peak ] = RI_findPeak( cfg )
%
% where the input data is the result from RA_POW
%
% The configuration options are
%   cfg.srcFolder   = source folder (default: '/data/pt_01778/eegData/EEG_RA_processedFT/02_pow/')
%   cfg.sessionStr  = session string (default: '001')
%   cfg.condition   = options: 'SegHand' or 'SegHead' (default: 'SegHand')
%   cfg.freqrange   = frequency range: [begin end], unit = Hz
%   cfg.electrode   = select a certain or multiple components (i.e. 'C3', 'P4', {'C3', 'P4'}, 14, 24, [14, 24]),
%                     channel labels as well as channel numbers are supported (default: 'C3'),
%                     if multiple components are defined, the averaged signal will be used for peak detection
%
% This function requires the fieldtrip toolbox
%
% See also FINDPEAKS

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
srcFolder   = ft_getopt(cfg, 'srcFolder', '/data/pt_01778/eegData/EEG_RA_processedFT/02_pow/');
sessionStr  = ft_getopt(cfg, 'sessionStr', '001');
condition   = ft_getopt(cfg, 'condition', 'SegHand');
freqrange   = ft_getopt(cfg, 'freqrange', [6 9.34]);
elec        = ft_getopt(cfg, 'electrode', {'C3'});

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
numOfFiles    = length(fileList);                                           % estimate actual number of files (participants)

% -------------------------------------------------------------------------
% Check freqrange and electrode
% -------------------------------------------------------------------------
if(length(freqrange) ~= 2)
  error('Specify a frequency range: [freqLow freqHigh]');
end

load([srcFolder fileList{1}]);                                              %#ok<LOAD> % load data of first participant

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

labelString = data_pow.label(elec);

if begCol == endCol
  error('Selected range results in one frequency, please select a larger range');
else
  freqCols = begCol:endCol;
  actFreqRange = data_pow.freq(begCol:endCol);                              % Calculate actual frequency range
end

clear data_pow

% -------------------------------------------------------------------------
% Find largest peak in specified range
% -------------------------------------------------------------------------
peakFreq{numOfFiles} = [];

f = waitbar(0,'Please wait...');

for i=1:1:numOfFiles
  load([srcFolder fileList{i}]);                                            %#ok<LOAD>
  waitbar(i/numOfFiles, f, 'Please wait...');
  
  data = mean(data_pow.powspctrm(elec, freqCols),1);
  [pks, locs, ~, p] = findpeaks(data);
  if length(pks) > 1
    [~, maxLocs] = max(p);                                                  % select always the most prominent peak
    peakFreq{i} = actFreqRange(locs(maxLocs));
  else
    peakFreq{i} = actFreqRange(locs);
  end
  
  clear data_pow
end

close(f);                                                                   % close waitbar

data_peak.condition = condition;
data_peak.label     = labelString;
data_peak.freq      = actFreqRange;
data_peak.part      = listOfPart';
data_peak.peakFreq  = peakFreq;

end

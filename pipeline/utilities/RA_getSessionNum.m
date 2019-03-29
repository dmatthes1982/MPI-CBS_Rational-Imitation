function [ num ] = RA_getSessionNum( cfg )
% RA_GETSESSIONNUM determines the highest session number of a specific 
% data file 
%
% Use as
%   [ num ] = RA_getSessionNum( cfg )
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01778/eegData/EEG_RA_processedFT/')
%   cfg.subFolder   = name of subfolder (default: '01a_import/')
%   cfg.filename    = filename (default: 'RA_SegHead_p01_01a_import')
%
% This function requires the fieldtrip toolbox.

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = ft_getopt(cfg, 'desFolder', '/data/pt_01778/eegData/EEG_RA_processedFT/');
subFolder   = ft_getopt(cfg, 'subFolder', '01a_import/');
filename    = ft_getopt(cfg, 'filename', 'RA_SegHead_p01_01a_import');

% -------------------------------------------------------------------------
% Estimate highest session number
% -------------------------------------------------------------------------
file_path = strcat(desFolder, subFolder, filename, '_*.mat');

sessionList    = dir(file_path);
if isempty(sessionList)
  num = 0;
else
  sessionList   = struct2cell(sessionList);
  sessionList   = sessionList(1,:);
  numOfSessions = length(sessionList);

  sessionNum    = zeros(1, numOfSessions);
  filenameStr   = strcat(filename, '_%d.mat');
  
  for i=1:1:numOfSessions
    sessionNum(i) = sscanf(sessionList{i}, filenameStr);
  end

  num = max(sessionNum);
end

end

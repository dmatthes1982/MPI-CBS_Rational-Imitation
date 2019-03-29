function [ data ] = RA_importDataset( cfg )
% RA_IMPORTDATASET imports one specific dataset, which was previously
% processed and exported with the brain vision analyzer.
%
% Use as
%   [ data ] = RA_importDataset( cfg )
%
% The configuration options are
%   cfg.path      = source path ('i.e. '/data/pt_01778/eegData/EEG_RA_processedBVA/')
%   cfg.part      = number of participant
%   cfg.condition = condition string, available options: 'SegHand' and 'SegHead'
%
% You can use relativ path specifications (i.e. '../../MATLAB/data/') or 
% absolute path specifications like in the example. Please be aware that 
% you have to mask space signs of the path names under linux with a 
% backslash char (i.e. '/home/user/test\ folder')
%
% This function requires the fieldtrip toolbox.
%
% See also FT_DEFINETRIAL, FT_PREPROCESSING, FT_TRIALFUN_BRAINVISION_SEGMENTED

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', []);
part      = ft_getopt(cfg, 'part', []);
condition = ft_getopt(cfg, 'condition', 'incong');

if isempty(path)
  error('No source path is specified!');
end

if isempty(part)
  error('No specific participant is defined!');
end

if ~ismember(condition, {'SegHead','SegHand'})
  error('Invalid condition! Choose either ''SegHand'' or ''SegHead''.');
end

headerfile = sprintf('%s*%02d_%s.vhdr', path, part, condition);             % determine full headerfile name
headerList = dir(headerfile);
headerfile = [path headerList(1).name];

% -------------------------------------------------------------------------
% Import data
% -------------------------------------------------------------------------
cfg              = [];
cfg.dataset      = headerfile;
cfg.trialfun     = 'ft_trialfun_brainvision_segmented';
cfg.stimformat   = '%d';
cfg.showcallinfo = 'no';

ft_warning off;                                                             % to suppress warning in read_brainvision_vhdr.m
cfg = ft_definetrial(cfg);
cfg = rmfield(cfg, {'notification'});                                       % workarround for mergeconfig bug
ft_warning off;                                                             % to suppress warning in read_brainvision_vhdr.m
data = ft_preprocessing(cfg);
ft_warning on;

end

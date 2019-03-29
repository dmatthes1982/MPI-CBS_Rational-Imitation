function [ data ] = RA_segmentation(cfg, data )
% RA_SEGMENTATION segments the data of each trial into segments with a
% certain length
%
% Use as
%   [ data ] = RA_segmentation( cfg, data )
%
% where the input data can be the result from RA_IMPORTDATASET,
% RA_PRUNESEGMENTS or RA_REJECTBADINTERVALARTIFACTS
%
% The configuration options are
%   cfg.length    = length of segments
%   cfg.overlap   = percentage of overlapping (range: 0 ... 1, default: 0)
%
% This function requires the fieldtrip toolbox.
%
% See also RA_IMPORTDATASET, RA_PRUNESEGMENTS, 
% RA_REJECTBADINTERVALARTIFACTS

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
segLength = ft_getopt(cfg, 'length', 1);
overlap   = ft_getopt(cfg, 'overlap', 0);

% -------------------------------------------------------------------------
% Segmentation settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.feedback        = 'no';
cfg.showcallinfo    = 'no';
cfg.trials          = 'all';                                                  
cfg.length          = segLength;
cfg.overlap         = overlap;

% -------------------------------------------------------------------------
% Segmentation
% -------------------------------------------------------------------------
fprintf('Segment data in segments of %d sec with %d %% overlapping...\n', ...
        segLength, overlap*100);
ft_info off;
ft_warning off;

data = ft_redefinetrial(cfg, data);

ft_info on;
ft_warning on;

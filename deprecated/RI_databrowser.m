function cfg = RI_databrowser(data_in)
% RI_DATABROWSER displays a rational imitation dataset using a appropriate
% scaling
%
% Params:
%   data_in         fieldtrip data structure
%
% This function requires the fieldtrip toolbox
%
% See also FT_DATABROWSER

% Copyright (C) 2017, Daniel Matthes, MPI CBS

cfg = [];
cfg.ylim      = [-80  80];
cfg.viewmode = 'vertical';
cfg.continuous = 'no';
cfg.channel = 'all';

cfg = ft_databrowser(cfg, data_in);

end
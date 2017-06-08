function [data_pttest] = RI_freqstatistics(cfg, data_hand, data_head)
% RI_FREQSTATISTICS conducts a paired-ttest between two conditions.
%
% Use as
%   [data_pttest] = RI_freqstatistics(cfg, data_hand, data_head)
% where the input data is the result from RI_PSDANALYSIS
%
% The configuration options are
%    cfg.frequency    = number or range or 'all' (i.e. 6 or [beginn end]), unit = Hz     (default = 'all')
%    cfg.channel      = 'all' or a specific selection (i.e. {'C3', 'P*', '*4'})          (default = 'all')
%    cfg.avgoverfreq  = 'no' or 'yes'                                                    (default = 'no')
%    cfg.avgoverchan  = 'no' or 'yes'                                                    (default = 'no')
%
% This function requires the fieldtrip toolbox.
%
% See also FT_FREQSTATISTICS

% Copyright (C) 2017, Daniel Matthes, MPI CBS

cfg.parameter     = 'powspctrm';                                            % kind of data
cfg.method        = 'stats';                                                % using MATLAB statistic toolbox for analysis  
cfg.statistic     = 'paired-ttest';                                         % using depentend t-test
cfg.alpha         = 0.05;                                                   % significance level   

hand_tmp = data_hand;                                                       % formatting steps, remove empty datasets from cell array
head_tmp = data_head;
eHand = cellfun('isempty', hand_tmp);
eHead = cellfun('isempty', head_tmp);
hand_tmp(eHand) = [];
head_tmp(eHead) = [];

cfg.design=[ones(1, length(hand_tmp)), 2*ones(1, length(hand_tmp))];        % define design, sepearte the datasets into the two conditions

data_pttest = ft_freqstatistics(cfg, head_tmp{:}, hand_tmp{:});             % calculate statistics

end

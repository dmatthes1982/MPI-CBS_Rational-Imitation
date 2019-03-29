function [hand_mean, head_mean, all_mean] = RI_averagePeople(data_hand_fft, data_head_fft)
% RI_AVERAGEPEOPLE is a function, which estimate the averaged power
% spectrial density over all participants of the datasets.
%
% Use as
%   [hand_mean, head_mean, all_mean] = RI_averagePeople(data_hand_fft, data_head_fft)
%
% This function requires the fieldtrip toolbox
%
% See also FT_FREQGRANDAVERAGE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

cfg                = [];
cfg.keepindividual = 'no';
cfg.foilim         = 'all';
cfg.toilim         = 'all';
cfg.channel        = 'all';
cfg.parameter      = 'powspctrm';
cfg.feedback       = 'no';
cfg.showcallinfo   = 'no';

hand_tmp = data_hand_fft;
head_tmp = data_head_fft;
all_tmp = [data_hand_fft data_head_fft]; 

eHand = cellfun('isempty', hand_tmp);
eHead = cellfun('isempty', head_tmp);
eAll =  cellfun('isempty', all_tmp);

hand_tmp(eHand) = [];
head_tmp(eHead) = [];
all_tmp(eAll) = [];

hand_mean = ft_freqgrandaverage(cfg, hand_tmp{1:end});
head_mean = ft_freqgrandaverage(cfg, head_tmp{1:end});
all_mean = ft_freqgrandaverage(cfg, all_tmp{1:end});
 
end
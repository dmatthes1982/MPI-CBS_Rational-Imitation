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

eHand = cellfun('isempty', hand_tmp);
eHead = cellfun('isempty', head_tmp);

hand_tmp(eHand) = [];
head_tmp(eHead) = [];

data_hand_fft_mean = ft_freqgrandaverage(cfg, hand_tmp{1:end});
data_head_fft_mean = ft_freqgrandaverage(cfg, head_tmp{1:end});
 
clear cfg hand_tmp head_tmp eHand eHead
cfg               = [];
cfg.frequency     = [4 10];
cfg.channel       = {'F4'};
cfg.parameter     = 'powspctrm';
cfg.method        = 'stats';
cfg.statistic     = 'ttest2';
cfg.alpha         = 0.05;
cfg.avgoverfreq   = 'no';

data_fft_mean = cell(1,2);
data_fft_mean{1} = data_hand_fft_mean;
data_fft_mean{2} = data_head_fft_mean;

hand_tmp = data_hand_fft;
head_tmp = data_head_fft;
eHand = cellfun('isempty', hand_tmp);
eHead = cellfun('isempty', head_tmp);
hand_tmp(eHand) = [];
head_tmp(eHead) = [];

cfg.design=[ones(1, length(hand_tmp)), 2*ones(1, length(hand_tmp))];

stat = ft_freqstatistics(cfg, hand_tmp{:}, head_tmp{:});

clear hand_tmp head_tmp eHand eHead

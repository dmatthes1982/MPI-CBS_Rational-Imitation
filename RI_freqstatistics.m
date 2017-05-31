cfg               = [];
cfg.frequency     = [3 5];                                                  % frequencies of interest
cfg.channel       = {'C3', 'Cz', 'C4'};                                     % channels/components of interest
cfg.parameter     = 'powspctrm';                                            % kind of data
cfg.method        = 'stats';                                                % using MATLAB statistic toolbox for analysis  
cfg.statistic     = 'paired-ttest';                                         % using depentend t-test
cfg.alpha         = 0.05;                                                   % significance level   
cfg.avgoverfreq   = 'yes';                                                  % average over frequencies (yes or no)
cfg.avgoverchan   = 'yes';                                                  % average over channels (yes or no)

data_fft_mean = cell(1,2);                                                  % only for additional plotting purpose
data_fft_mean{1} = data_hand_fft_mean;
data_fft_mean{2} = data_head_fft_mean;

hand_tmp = data_hand_fft;                                                   % formatting steps, remove empty datasets from cell array
head_tmp = data_head_fft;
eHand = cellfun('isempty', hand_tmp);
eHead = cellfun('isempty', head_tmp);
hand_tmp(eHand) = [];
head_tmp(eHead) = [];

cfg.design=[ones(1, length(hand_tmp)), 2*ones(1, length(hand_tmp))];        % define design, sepearte the datasets into the two conditions

stat = ft_freqstatistics(cfg, hand_tmp{:}, head_tmp{:});                    % calculate statistics

clear hand_tmp head_tmp eHand eHead                                         % clear temporary variables

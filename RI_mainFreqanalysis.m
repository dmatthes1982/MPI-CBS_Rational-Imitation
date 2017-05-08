%warning('off','all');

cfg                 = [];
cfg.method          = 'mtmconvol';
cfg.taper           = 'hanning';
cfg.output          = 'pow';
cfg.channel         = 'all';                                                % calculate spectrum of every channel  
cfg.trials          = 'all';                                                % calculate spectrum for every trial  
cfg.keeptrials      = 'yes';                                                % do not average over trials
cfg.pad             = 500;                                                  % data are padded with zero pads to a length of 2*fs
cfg.foi             = 1:1:30;                                               % analysis from 1 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin       = ones(length(cfg.foi),1) .* 1;
cfg.toi             = 'all';                                                % spectral estimates on each sample
%cfg.feedback        = 'no';                                                % suppress feedback output
%cfg.showcallinfo    = 'no';                                                % suppress function call output

data_fft = ft_freqanalysis(cfg, data_head{1});                              % calculate time frequency responses

cfg                 = [];
cfg.method          = 'wavelet';
cfg.taper           = 'hanning';
cfg.output          = 'pow';
cfg.channel         = 'all';                                                % calculate spectrum of every channel  
cfg.trials          = 'all';                                                % calculate spectrum for every trial  
cfg.keeptrials      = 'yes';                                                % do not average over trials
cfg.pad             = 500;                                                  % data are padded with zero pads to a length of 2*fs
cfg.foi             = 1:1:30;                                               % analysis from 1 to 30 Hz in steps of 1 Hz 
cfg.width           = 7;
cfg.toi             = 'all';                                                % spectral estimates on each sample
%cfg.feedback        = 'no';                                                % suppress feedback output
%cfg.showcallinfo    = 'no';                                                % suppress function call output

data_wav = ft_freqanalysis(cfg, data_head{1});                              % calculate time frequency responses

figure;
subplot(1,2,1);
RI_singleplotTFR( data_fft );
subplot(1,2,2);
RI_singleplotTFR( data_wav );

%warning('on','all');

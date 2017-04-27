function [ data ] = RI_importData( headerfile )

cfg              = [];
cfg.dataset      = headerfile;
cfg.trialfun     = 'ft_trialfun_brainvision_segmented';
cfg.stimformat   = 'S %d';
cfg.showcallinfo = 'no';

cfg = ft_definetrial(cfg);
data = ft_preprocessing(cfg);

end

function [ data ] = RI_importData( headerfile )

cfg              = [];
cfg.dataset      = headerfile;
cfg.trialfun     = 'ft_trialfun_brainvision_segmented';
cfg.stimformat   = 'S %d';
cfg.showcallinfo = 'no';

ft_warning off;                                                             % to suppress warning in read_brainvision_vhdr.m
cfg = ft_definetrial(cfg);
cfg = rmfield(cfg, {'notification'});
ft_warning off;
data = ft_preprocessing(cfg);                                               % to suppress warning in read_brainvision_vhdr.m
ft_warning on;

end

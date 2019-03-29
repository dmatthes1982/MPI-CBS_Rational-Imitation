function RI_singleplotTFR( data_in )
%RI_SINGLEPLOTTFR Summary of this function goes here
%   Detailed explanation goes here

% -------------------------------------------------------------------------
% Create figure
% -------------------------------------------------------------------------
colormap jet;                                                               % use the older and more common colormap

cfg                 = [];                                                       
cfg.maskstyle       = 'saturation';
cfg.xlim            = [-0.2 1.5];
cfg.ylim            = [1 30];
cfg.zlim            = 'maxmin';
cfg.trials          = 'all';                                                % select trial (or 'all' trials)
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output
cfg.channel         = 4;      

ft_singleplotTFR(cfg, data_in);                                             % plot the time frequency response

end


pdf_title = 'output';

cfg=[];
cfg.layout = 'elec1020.lay';
layout = ft_prepare_layout(cfg, data_head_short{1});

cfg=[];
cfg.parameter = 'powspctrm';
cfg.channel = {'F3', 'Fz', 'F4', 'C3', 'Cz', 'C4', 'P3', 'Pz', 'P4'};
cfg.baseline = 'no';
cfg.xlim = [3 6];                                                           % passband 3-6 Hz
%cfg.zlim = [25 43];
cfg.colormap = 'jet';
cfg.marker = 'labels';
cfg.layout = layout;
cfg.interplimits = 'head';
cfg.interpolation = 'v4';

figure(2);
subplot(1,2,1);
title('Hands Free - Condition: Hand');
ft_topoplotER(cfg, data_hand_fft_mean);
colorbar;
subplot(1,2,2);
title('Hands Free - Condition: Head');
ft_topoplotER(cfg, data_head_fft_mean);
colorbar;

% -------------------------------------------------------------------------
% Save graphic as pdf-File
% -------------------------------------------------------------------------
h=gcf;
set(h, 'PaperOrientation','landscape');
set(h, 'PaperType','a3');
set(h, 'PaperUnit', 'centimeters');
set(h, 'PaperSize', [42 29.7]);
set(h, 'unit', 'normalized', 'Position', [0 0 0.9 0.9]);
doc_title = sprintf('../../results/RationalImitation/%s', pdf_title);
file_path = strcat(doc_title, '_001.pdf');
if exist(file_path, 'file') == 2
  file_pattern = strcat(doc_title, '_*.pdf');
  file_num = length(dir(file_pattern))+1;
  file_path = sprintf('../../results/RationalImitation/%s_%03d.pdf', ... 
              pdf_title, file_num);
end
print(gcf, '-dpdf', file_path);

clear cfg h file_num file_path file_pattern pdf_title doc_title
pdf_title = 'output';

cfg=[];
cfg.parameter = 'powspctrm';
cfg.channel = {'all', '-VEOG1', '-VEOG2', '-HEOG1', '-HEOG2'};
cfg.baseline = 'no';
cfg.xlim = [6 8];                                                           % passband 3-6 Hz
%cfg.zlim = [0 1000];
cfg.colormap = 'jet';
cfg.marker = 'labels';
cfg.layout = 'hdbg_customized_acticap32.mat';
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
h = gcf;
set(h, 'PaperOrientation','landscape');
set(h, 'PaperType','a3');
set(h, 'PaperUnit', 'centimeters');
set(h, 'PaperSize', [42 29.7]);
set(h, 'unit', 'normalized', 'Position', [0 0 0.9 0.9]);
doc_title = sprintf('/data/pt_01798/Rational_Imitation_results/%s', ...
                    pdf_title);
file_path = strcat(doc_title, '_001.pdf');
if exist(file_path, 'file') == 2
  file_pattern = strcat(doc_title, '_*.pdf');
  file_num = length(dir(file_pattern))+1;
  file_path = sprintf('/data/pt_01798/Rational_Imitation_results/%s_%03d.pdf', ... 
                      pdf_title, file_num);
end
print(gcf, '-dpdf', file_path);

clear cfg h file_num file_path file_pattern pdf_title doc_title
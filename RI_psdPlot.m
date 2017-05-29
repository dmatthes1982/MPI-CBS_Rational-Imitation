function RI_psdPlot( data_in, fig_title, pdf_title )
%RI_PSDPLOT Summary of this function goes here
%   Detailed explanation goes here

lengthInput = length(data_in);

% -------------------------------------------------------------------------
% Create panels for headline and the subplots
% -------------------------------------------------------------------------
f = figure('units','normalized','outerposition',[0 0 0.9 0.9]);
p = uipanel('Parent', f, 'BackgroundColor', 'white', 'BorderType', ...      % create panel p for the power spectra
  'none', 'Position', [0 0 1 0.95]);
q = uipanel('Parent', f, 'BackgroundColor', 'white', 'BorderType', ...      % create panel q for the headline
  'none', 'Position', [0 0.95 1 0.05]);

q.Title = fig_title; 
q.TitlePosition = 'centerbottom'; 
q.FontSize = 12;
q.FontWeight = 'bold';

for a=1:1:9
  subplot(3,3,a, 'Parent', p);
  xlabel('frequency (Hz)');
  ylabel('power/frequency (dB/Hz)');
  hold on;
end

subplot(3,3,1, 'Parent', p);
title('Power Spectrum of F3');
subplot(3,3,2, 'Parent', p);
title('Power Spectrum of F4');
subplot(3,3,3, 'Parent', p);
title('Power Spectrum of Fz');
subplot(3,3,4, 'Parent', p);
title('Power Spectrum of C3');
subplot(3,3,5, 'Parent', p);
title('Power Spectrum of C4');
subplot(3,3,6, 'Parent', p);
title('Power Spectrum of Cz');
subplot(3,3,7, 'Parent', p);
title('Power Spectrum of P3');
subplot(3,3,8, 'Parent', p);
title('Power Spectrum of P4');
subplot(3,3,9, 'Parent', p);
title('Power Spectrum of Pz');

if lengthInput > 1
  for i=1:1:lengthInput
    if ~isempty(data_in{i})
      for j=1:1:9
        subplot(3,3,j);
        plot(data_in{i}.freq(1:46), 10*log(data_in{i}.powspctrm(j,1:46)));
      end
    end
  end
else
  for j=1:1:9
    subplot(3,3,j);
    plot(data_in.freq(1:46), 10*log(data_in.powspctrm(j,1:46)));
  end
end

% -------------------------------------------------------------------------
% Resize y-axis subplots to common base
% -------------------------------------------------------------------------
y_min = 2000;                                                                 
y_max = 0;
for sub=1:1:9
  subplot(3,3,sub);
  y_limits = get(gca,'ylim');
  if y_limits(1) < y_min
    y_min = y_limits(1);
  end
  if y_limits(2) > y_max
    y_max = y_limits(2);
  end
end

for sub=1:1:9
  subplot(3,3,sub);
  ylim([y_min y_max]);
end


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

end


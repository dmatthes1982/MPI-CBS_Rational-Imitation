function RI_psdPlot2( data_in, fig_title, pdf_title )
% RI_PSDPLOT2 plots the mean power spectrum of frontal and central 
% electrodes from different datasets.
%
% Use as, i.e.:
%   RI_psdPlot2(data_hand_fft, 'Fig. Title', 'File Title')
%              or
%   RI_psdPlot2({data_hand_fft_mean, data_head_fft_mean}, 'Fig. Title', 'File Title')
%
% The first example refers to data cells with multiple data structures and
% the second example to list of single data structures.
%
% If you want combine two sets of data cells, you have to call this
% function in the following order
%   RI_psdPlot([data_hand_fft, data_head_fft], 'Fig. Title', 'File Title')
%
% Input data ist the result from RI_PSDANALYSIS or from RI_AVERAGEPEOPLE
%
% See also RI_PSDANALYSIS, RI_AVERAGEPEOPLE, RI_PSDPLOT

% Copyright (C) 2017, Daniel Matthes, MPI CBS

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

for a=1:1:2
  subplot(1,2,a, 'Parent', p);
  xlabel('frequency (Hz)');
  ylabel('power/frequency (dB/Hz)');
  hold on;
end

subplot(1,2,1, 'Parent', p);
title('Power Spectrum of F*');
subplot(1,2,2, 'Parent', p);
title('Power Spectrum of C*');


if lengthInput > 1
  for i=1:1:lengthInput
    if ~isempty(data_in{i})
      for j=1:1:2
        subplot(1,2,j);
        plot(data_in{i}.freq(1:46), 10*log(mean(data_in{i}.powspctrm((j-1)*3+1:j*3,1:46),1)));
      end
    end
  end
else
  for j=1:1:2
    subplot(1,2,j);
    plot(data_in.freq(1:46), 10*log(mean(data_in.powspctrm((j-1)*3+1:j*3,1:46),1)));
  end
end

% -------------------------------------------------------------------------
% Resize y-axis subplots to common base
% -------------------------------------------------------------------------
y_min = 2000;                                                                 
y_max = 0;
for sub=1:1:2
  subplot(1,2,sub);
  y_limits = get(gca,'ylim');
  if y_limits(1) < y_min
    y_min = y_limits(1);
  end
  if y_limits(2) > y_max
    y_max = y_limits(2);
  end
end

for sub=1:1:2
  subplot(1,2,sub);
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


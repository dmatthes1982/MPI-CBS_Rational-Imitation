function RI_powerPlot( cfg, data )
% RI_POWERPLOT is a function, which can be used to generate a figures with
% various power activity plots.
%
% Use as
%   RI_powerPlot(cfg, data) 
% or
%   RI_powerPlot(cfg, [data_a, data_b])
% or
%   RI_powerPlot(cfg, {data1, data2})
%
% where data, data_a and data_b are a cell arrays of multiple datasets and 
% data1 and data2 are single datasets. They can be results of 
% RI_POWERANALYSIS or from RI_AVERAGEPEOPLE
%
% The configuration can have the following parameters:
%   cfg.fig_title     = 'title of figure' (default: Power activity)
%   cfg.pdf_title     = 'tite of output file' (default: Power-plot)
%   cfg.channels      = 1xN cell array with selection of channels or 'all' (default = 'all');
%                       i.e. {'P3', {'F3', 'F4'}, {'Pz', 'Cz', 'Fz'}},
%                       channels within curly brackets will be averaged
%   cfg.freqmax       = frequency range to display (default: 30)
%   cfg.freqhighlight = frequency section which shall be highlighted in gray
%                       i.e. [6 8] (default: [])
%   cfg.fontName      = font name (default: 'Helvetica');
%   cfg.titleSize     = font size of figure title (default: 12)
%   cfg.subSize       = font size of graph title (default: 11)
%   cfg.labelSize     = font size of labels (default: 11)
%   cfg.axisSize      = font size of units (default: 10)
%
% This function requires the fieldtrip toolbox
%
% See also RI_POWERANALYSIS, RI_AVERAGEPEOPLE

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------

default_label = {'F3'; 'Fz'; 'F4'; 'C3'; 'Cz'; 'C4'; 'P3'; 'Pz'; 'P4'};

fig_title     = ft_getopt(cfg, 'fig_title', 'Power activity');
pdf_title     = ft_getopt(cfg, 'pdf_title', 'Power-plot');
channels      = ft_getopt(cfg, 'channels', 'all');
freqmax       = ft_getopt(cfg, 'freqmax', 30);
freqhighlight = ft_getopt(cfg, 'freqhighlight', []);
fontName      = ft_getopt(cfg, 'fontName', 'Helvetica');
titleSize     = ft_getopt(cfg, 'titleSize', 12);
subSize       = ft_getopt(cfg, 'subSize', 11);
labelSize     = ft_getopt(cfg, 'labelSize', 11);
axisSize      = ft_getopt(cfg, 'axisSize', 10);

if ~iscell(channels)
  numOfChan = 9;
  channels = default_label';
  subX = 3; subY = 3;
else
  numOfChan = length(channels);

  if numOfChan < 1 || numOfChan > 9                                         % check number of channels
    error('The numbers of channels have to be between 1 and 9.');
  else
    switch numOfChan
      case 1
        subX = 1; subY = 1;
      case 2
        subX = 2; subY = 1;
      case 3
        subX = 1; subY = 3;
      case 4
        subX = 2; subY = 2;
      case {5, 6}
        subX = 3; subY = 2;
      case {7, 8, 9}
        subX = 3; subY = 3;      
    end
  end
  
  for i=1:1:numOfChan                                                       % check channel labels
    if ~iscell(channels{i})
      if isempty(any(strcmp(default_label, channels{i})))
        error('Channel: %s does not exist.', channels{i});
      end
    else
      chanLength = length(channels{i});
      for j=1:1:chanLength
        if isempty(any(strcmp(default_label, channels{i}{j})))
        error('Channel: %s does not exist.', channels{i}{j});
        end
      end
    end
  end
end

% -------------------------------------------------------------------------
% Get data length
% -------------------------------------------------------------------------

lengthInput = length(data);

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
q.FontSize = titleSize;
q.FontWeight = 'bold';
q.FontName = fontName;

for i=1:1:numOfChan
  subplot(subX, subY, i, 'Parent', p);
  ax = gca;
  ax.FontSize = axisSize;
  ax.FontName = fontName;
  xlabel('Frequency (Hz)', 'FontSize', labelSize, ...
                          'FontName', fontName);
  ylabel('Power (dB)', 'FontSize', labelSize, ...
                                    'FontName', fontName);
  hold on;
  if ~iscell(channels{i})
    titleString = ['Power of ', channels{i}];
  else
    chanLength = length(channels{i});
    if chanLength == 2
      titleString = ['Mean power activity of ', channels{i}{1}, ' and ', ...
            channels{i}{2}];
    else
      titleString = 'Mean power activity of ';
      for j = 1:1:chanLength - 2
        titleString = [titleString, channels{i}{j}, ', ']; %#ok<AGROW>
      end
      titleString = [titleString, channels{i}{chanLength - 1}, ' and ', ...
            channels{i}{chanLength}];  %#ok<AGROW>
    end
  end
  title(titleString, 'Fontsmoothing', 'off', 'FontSize', subSize, ...
                    'FontName', fontName, 'FontWeight', 'bold');
end

% -------------------------------------------------------------------------
% Convert channel strings in numbers
% -------------------------------------------------------------------------
chanNumbers{numOfChan} = [];

if lengthInput > 1
  num = 1;
  while isempty(data{num})
    num = num + 1; 
  end
  label = data{num}.label;
else
  label = data.label;
end

for i=1:1:numOfChan
  if ~iscell(channels{i})
    chanNumbers{i} = find(strcmp(label, channels{i}));
  else
    chanLength = length(channels{i});
    clear tmp;
    tmp = cell(1, chanLength);
    for j=1:1:chanLength
      tmp{j} = find(strcmp(label, channels{i}{j}));
    end
    chanNumbers{i} = cell2mat(tmp);
  end
end

% -------------------------------------------------------------------------
% Plot graphs
% -------------------------------------------------------------------------
for i=1:1:numOfChan
  subplot(subX, subY, i);
  if lengthInput > 1
    for j=1:1:lengthInput
      if ~isempty(data{j})
        fmaxpos = find(data{j}.freq >= freqmax, 1, 'first');
        if isempty(fmaxpos)
          fmaxpos = length(data{j}.freq);
        end
        plot(data{j}.freq(1:fmaxpos), 10*log10(mean( ...
             data{j}.powspctrm(chanNumbers{i},1:fmaxpos), 1)));
      end
    end
  else
    subplot(subX, subY, i);
    fmaxpos = find(data{j}.freq >= freqmax, 1, 'first');
    if isempty(fmaxpos)
      fmaxpos = length(data{j}.freq);
    end
    plot(data.freq(1:fmaxpos), 10*log10(mean( ...
         data.powspctrm(chanNumbers{i},1:fmaxpos), 1)));
  end
  xlim([0 freqmax]);
  set(gca, 'YGrid', 'on');
  if ~isempty(freqhighlight)
    x_vect = [freqhighlight(1) freqhighlight(2) ...
              freqhighlight(2) freqhighlight(1)];
    currAxis = gca;
    y_vect = [currAxis.YLim(1) currAxis.YLim(1) ...
              currAxis.YLim(2) currAxis.YLim(2)];
    patch(x_vect, y_vect, [0.8 0.8 0.8], 'LineStyle', 'none');
    set(currAxis,'children',flipud(get(currAxis,'children')));
  end
end

% -------------------------------------------------------------------------
% Resize y-axis subplots to common base
% -------------------------------------------------------------------------
y_min = 2000;
y_max = 0;

for j=1:1:numOfChan
  subplot(subX, subY, j);
  y_limits = get(gca,'ylim');
  if y_limits(1) < y_min
    y_min = y_limits(1);
  end
  if y_limits(2) > y_max
    y_max = y_limits(2);
  end
end

for j=1:1:numOfChan
  subplot(subX, subY, j);
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

end

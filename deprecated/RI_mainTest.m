%% load or generate data

load('../../test/RationalImitation/RI_test_01_Preprocessed.mat');
%RI_genTestData;

%% shorten trials
data_head_short = RI_redefinetrial(data_head);
data_hand_short = RI_redefinetrial(data_hand);

%% calculate PSD
data_head_fft = RI_psdanalysis(data_head_short);
data_hand_fft = RI_psdanalysis(data_hand_short);

%% calculate mean PSD over all people
RI_averagePeople;

%% create and export plots
fig_01_title = 'Hand - Mean power of every person';
fig_02_title = 'Head - Mean power of every person';
fig_03_title = 'Hand - Power over all persons';
fig_04_title = 'Head - Power over all persons';
fig_05_title = 'Hand vs. Head - Power over all persons';
pdf_01_title = '../../test/RationalImitation/Hand';
pdf_02_title = '../../test/RationalImitation/Head';
pdf_03_title = '../../test/RationalImitation/HandMean';
pdf_04_title = '../../test/RationalImitation/HeadMean';
pdf_05_title = '../../test/RationalImitation/Compare-HandHeadMean';

RI_psdPlot(data_hand_fft, fig_01_title, pdf_01_title);
RI_psdPlot(data_head_fft, fig_02_title, pdf_02_title);
RI_psdPlot(data_hand_fft_mean, fig_03_title, pdf_03_title);
RI_psdPlot(data_head_fft_mean, fig_04_title, pdf_04_title);

data_fft_mean = cell(1,2);
data_fft_mean{1} = data_hand_fft_mean;
data_fft_mean{2} = data_head_fft_mean;

RI_psdPlot(data_fft_mean, fig_05_title, pdf_05_title);

%% clear temporary variables
clear fig_01_title fig_02_title fig_03_title fig_04_title fig_05_title ...
      pdf_01_title pdf_02_title pdf_03_title pdf_04_title pdf_05_title ...
      data_fft_mean

%% calculate paired t-tests

cfg = [];
cfg.frequency = 10;
cfg.channel = 'C3';

ptttest_10Hz_C3 = RI_freqstatistics(cfg, data_hand_fft, data_head_fft);

cfg.frequency = 10;
cfg.channel = 'F4';

ptttest_10Hz_F4 = RI_freqstatistics(cfg, data_hand_fft, data_head_fft);

cfg.frequency = 4;
cfg.channel = 'C3';

ptttest_4Hz_C3 = RI_freqstatistics(cfg, data_hand_fft, data_head_fft);

cfg.frequency = 4;
cfg.channel = 'F4';

ptttest_4Hz_F4 = RI_freqstatistics(cfg, data_hand_fft, data_head_fft);

clear cfg;

%% calculate rmANOVAs

cfg.freq = 10;
cfg.channel = 'all';

rmAnova_10Hz = RI_rmAnova(cfg, data_hand_fft, data_head_fft);

cfg.freq = 4;
cfg.channel = 'all';

rmAnova_4Hz = RI_rmAnova(cfg, data_hand_fft, data_head_fft);

clear cfg;

function [ dataPeaks ] = RI_mainFindPeak( cfg )
% RI_MAINFINDPEAK determines the specific mu and theta range of in a
% certain agegroup
%
% Use as
%   [ dataPeaks ] = RI_mainFindPeak( cfg )
%
% The configuration can have the following parameters:
%   cfg.agegroup  = '9Months', '12Months', '12MonthsV2', 'Adults' (default: '12Months')
%
% This function requires the fieldtrip toolbox
%
% See also RI_FINDPEAK

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
agegroup  = ft_getopt(cfg, 'agegroup', '12Months');

switch agegroup
  case '9Months'
    freqRange_mu =  [6 9];                                                  % define here principal mu-range
    freqRange_theta = [3.333 5.333];                                        % define here principal theta-range
    HandsFreeFile = 'RI_handsFree_9M_03_FFT_001.mat'; 
  case '12Months'
    freqRange_mu =  [6 9];                                                  % define here principal mu-range
    freqRange_theta = [3.333 5.333];                                        % define here principal theta-range
    HandsFreeFile = 'RI_handsFree_12M_03_FFT_001.mat';
    HandsRestrFile = 'RI_handsRestr_12M_03_FFT_001.mat';
  case '12MonthsV2'
    freqRange_mu =  [6 9];                                                  % define here principal mu-range
    freqRange_theta = [3.333 5.333];                                        % define here principal theta-range
    HandsFreeFile = 'RI_handsFree_12Mv2_03_FFT_001.mat';
    HandsRestrFile = 'RI_handsRestr_12Mv2_03_FFT_001.mat'; 
  case 'Adults'
    freqRange_mu = [8 13];                                                  % define here principal mu-range
    freqRange_theta = [3 7];                                                % define here principal theta-range
    HandsFreeFile = 'RI_handsFree_AD_03_FFT_001.mat';
    HandsRestrFile = 'RI_handsRestr_AD_03_FFT_001.mat';
end

% -------------------------------------------------------------------------
% General initialization
% -------------------------------------------------------------------------
srcFolder = '/data/pt_01798/Rational_Imitation_processedFT/';               % define source folder

% -------------------------------------------------------------------------
% Load data
% -------------------------------------------------------------------------
load(strcat(srcFolder, HandsFreeFile), 'data_hand_fft', 'data_head_fft');

[Peaks_HandsFree_Hand, Peaks_HandsFree_Head] = getPeaks( ...
      data_hand_fft, data_head_fft, freqRange_mu, freqRange_theta);
    
clear data_hand_fft data_head_fft

dataPeaks.Peaks_HandsFree_Hand = Peaks_HandsFree_Hand;
dataPeaks.Peaks_HandsFree_Head = Peaks_HandsFree_Head;

if ~strcmp(agegroup, '9Months')
  load(strcat(srcFolder, HandsRestrFile), 'data_hand_fft', 'data_head_fft');
  
  [Peaks_HandsRestr_Hand, Peaks_HandsRestr_Head] = getPeaks( ...
      data_hand_fft, data_head_fft, freqRange_mu, freqRange_theta);
    
  dataPeaks.Peaks_HandsRestr_Hand = Peaks_HandsRestr_Hand;
  dataPeaks.Peaks_HandsRestr_Head = Peaks_HandsRestr_Head;
end
   
end

function [PeaksCondHand, PeaksCondHead] = getPeaks(data_hand, data_head, mu, theta)

PeaksCondHand = struct;
PeaksCondHead = struct;

num = 1;
while isempty(data_hand{num})
  num = num + 1; 
end

labelOfInterest = {'F3', 'F4', 'Fz', 'C3', 'C4', 'Cz', 'P3', 'P4', 'Pz'};
components = find(ismember(data_hand{1}.label,labelOfInterest))';

numChn = length(components);                                                % get number of channels/electrodes
             
PeaksCondHand.label = labelOfInterest;
PeaksCondHand.goodParticipants = length(data_hand) ...                      % calculate length of dataset / number of good participants
               - sum(cellfun(@isempty, data_hand));       
PeaksCondHand.peaksMu = zeros(1, numChn);
PeaksCondHand.minMu = zeros(1, numChn);
PeaksCondHand.maxMu = zeros(1, numChn);
PeaksCondHand.peaksTheta = zeros(1, numChn);
PeaksCondHand.minTheta = zeros(1, numChn);
PeaksCondHand.maxTheta = zeros(1, numChn);
     
PeaksCondHead.label = labelOfInterest;                            
PeaksCondHead.goodParticipants = length(data_head) ...                      % calculate length of dataset / number of good participants
               - sum(cellfun(@isempty, data_head));
PeaksCondHead.peaksMu = zeros(1, numChn);
PeaksCondHead.minMu = zeros(1, numChn);
PeaksCondHead.maxMu = zeros(1, numChn);
PeaksCondHead.peaksTheta = zeros(1, numChn);
PeaksCondHead.minTheta = zeros(1, numChn);
PeaksCondHead.maxTheta = zeros(1, numChn);

cfgP = [];

for j=1:1:numChn                                                            % repeat this subloop for all channels/electrodes 
  cfgP.freqRange = mu;
  cfgP.component = data_hand{num}.label{components(j)};
  peakFreq = cell2mat(RI_findPeak(cfgP, data_hand));                        % determine peaks in the mu-range of all participants (condition hand)
  PeaksCondHand.peaksMu(j) = length(peakFreq);                              % get the number of the determined peaks
  if (PeaksCondHand.peaksMu(j))                                             % calculate minimum and maximum peaks are found
    PeaksCondHand.minMu(j) = min(peakFreq);
    PeaksCondHand.maxMu(j) = max(peakFreq);
  else
    PeaksCondHand.minMu(j) = NaN;
    PeaksCondHand.maxMu(j) = NaN; 
  end
    
  cfgP.freqRange = mu;
  cfgP.component = data_head{num}.label{components(j)};                              
  peakFreq = cell2mat(RI_findPeak(cfgP, data_head));                        % determine peaks in the mu-range of all participants (condition head)
  PeaksCondHead.peaksMu(j) = length(peakFreq);                              % get the number of the determined peaks            
  if(PeaksCondHead.peaksMu(j))                                              % calculate minimum and maximum peaks are found
    PeaksCondHead.minMu(j) = min(peakFreq);
    PeaksCondHead.maxMu(j) = max(peakFreq);
  else
    PeaksCondHead.minMu(j) = NaN;
    PeaksCondHead.maxMu(j) = NaN;
  end
    
  cfgP.freqRange = theta;
  cfgP.component = data_hand{num}.label{components(j)};
  peakFreq = cell2mat(RI_findPeak(cfgP, data_hand));                        % determine peaks in the theta-range of all participants (condition hand)
  PeaksCondHand.peaksTheta(j) = length(peakFreq);                           % get the number of the determined peaks
  if(PeaksCondHand.peaksTheta(j))                                           % calculate minimum and maximum peaks are found 
    PeaksCondHand.minTheta(j) = min(peakFreq);
    PeaksCondHand.maxTheta(j) = max(peakFreq);
  else
    PeaksCondHand.minTheta(j) = NaN;
    PeaksCondHand.maxTheta(j) = NaN;
  end
    
  cfgP.freqRange = theta;
  cfgP.component = data_head{num}.label{components(j)};
  peakFreq = cell2mat(RI_findPeak(cfgP, data_head));                        % determine peaks in the theta-range of all participants (condition head)
  PeaksCondHead.peaksTheta(j) = length(peakFreq);                           % get the number of the determined peaks
  if (PeaksCondHead.peaksTheta(j))                                          % calculate minimum and maximum peaks are found
    PeaksCondHead.minTheta(j) = min(peakFreq);
    PeaksCondHead.maxTheta(j) = max(peakFreq);
  else
    PeaksCondHead.minTheta(j) = NaN;
    PeaksCondHead.maxTheta(j) = NaN;
  end
end

end

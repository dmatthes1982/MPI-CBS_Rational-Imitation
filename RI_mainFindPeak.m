% -------------------------------------------------------------------------
% Select frequency ranges
% -------------------------------------------------------------------------
MuInfants = [6 9];                                                          % define here general mu-range for infants
MuAdult = [8 13];                                                           % define here general theta-range for infants 

ThetaInfants = [3.333 5.333];                                               % define here general mu-range for adults
ThetaAdult = [3 7];                                                         % define here general theta-range for adults

% -------------------------------------------------------------------------
% General initialization
% -------------------------------------------------------------------------
Peaks_Infants_HandsFree_Hand = struct;                                      % output structure for infants in study hands free of condition hand
Peaks_Infants_HandsFree_Head = struct;                                      % output structure for infants in study hands free of condition head
Peaks_Infants_HandsRestr_Hand = struct;                                     % output structure for infants in study hands restraint of condition hand
Peaks_Infants_HandsRestr_Head = struct;                                     % output structure for infants in study hands restraint of condition head
Peaks_Adults_HandsFree_Hand = struct;                                       % output structure for adults in study hands free of condition hand
Peaks_Adults_HandsFree_Head = struct;                                       % output structure for adults in study hands free of condition head
Peaks_Adults_HandsRestr_Hand = struct;                                      % output structure for adults in study hands restraint of condition hand
Peaks_Adults_HandsRestr_Head = struct;                                      % output structure for adults in study hands restraint of condition head

srcFolder = '../../processed/RationalImitation/';                           % define source folder
infHandsFreeFile = 'RI_handsFree_03_FFT_001.mat';                           % first data set: infants hands free
infHandsRestrFile = 'RI_handsRestr_03_FFT_001.mat';                         % second data set: infants hands restraint
adHandsFreeFile = 'RI_handsFree_Ad_03_FFT_001.mat';                         % third data set: adults hands free
adHandsRestrFile = 'RI_handsRestr_Ad_03_FFT_001.mat';                       % fourth data set: adults hands restraint

for i=1:1:4                                                                 % repeat loop for the four defined data sets  
  switch i
    case 1                                                                  % set parameter the first data
      load(strcat(srcFolder, infHandsFreeFile));
      freqRange_mu = MuInfants;
      freqRange_theta = ThetaInfants;
    case 2                                                                  % set parameter the second data
      load(strcat(srcFolder, infHandsRestrFile));
      freqRange_mu = MuInfants;
      freqRange_theta = ThetaInfants;
    case 3                                                                  % set parameter the third data
      load(strcat(srcFolder, adHandsFreeFile));
      freqRange_mu = MuAdult;
      freqRange_theta = ThetaAdult;
    case 4                                                                  % set parameter the fourth data
      load(strcat(srcFolder, adHandsRestrFile));
      freqRange_mu = MuAdult;
      freqRange_theta = ThetaAdult;
  end
      
  goodParticipants = length(data_hand_fft) - sum(cellfun(@isempty, ...            % calculate length of dataset / number of good participants
               data_hand_fft)); 
  numChn = length(data_hand_fft{1}.label);                                  % get number of channels/electrodes
  numPeaks_m_hand = zeros(1, numChn);                                       % initialize/reset temporary variables
  minVal_m_hand = zeros(1, numChn);
  maxVal_m_hand = zeros(1, numChn);
  numPeaks_t_hand = zeros(1, numChn);
  minVal_t_hand = zeros(1, numChn);
  maxVal_t_hand = zeros(1, numChn);
  numPeaks_m_head = zeros(1, numChn);
  minVal_m_head = zeros(1, numChn);
  maxVal_m_head = zeros(1, numChn);
  numPeaks_t_head = zeros(1, numChn);
  minVal_t_head = zeros(1, numChn);
  maxVal_t_head = zeros(1, numChn);
  
  
  for j=1:1:numChn                                                          % repeat this subloop for all channels/electrodes 
    peakFreq = cell2mat(RI_findPeak(data_hand_fft, freqRange_mu, ...        % determine peaks in the mu-range of all participants (condition hand)
                        data_hand_fft{1}.label{j}));
    numPeaks_m_hand(j) = length(peakFreq);                                  % get the number of the determined peaks
    if (numPeaks_m_hand(j))                                                 % calculate minimum and maximum peaks are found
      minVal_m_hand(j) = min(peakFreq);
      maxVal_m_hand(j) = max(peakFreq);
    else
      minVal_m_hand(j) = NaN;
      maxVal_m_hand(j) = NaN; 
    end
    
    peakFreq = cell2mat(RI_findPeak(data_head_fft, freqRange_mu, ...        % determine peaks in the mu-range of all participants (condition head)
                        data_head_fft{1}.label{j}));
    numPeaks_m_head(j) = length(peakFreq);                                  % get the number of the determined peaks            
    if(numPeaks_m_head(j))                                                  % calculate minimum and maximum peaks are found
      minVal_m_head(j) = min(peakFreq);
      maxVal_m_head(j) = max(peakFreq);
    else
      minVal_m_head(j) = NaN;
      maxVal_m_head(j) = NaN;
    end
    
    peakFreq = cell2mat(RI_findPeak(data_hand_fft, freqRange_theta, ...     % determine peaks in the theta-range of all participants (condition hand)
                        data_hand_fft{1}.label{j}));
    numPeaks_t_hand(j) = length(peakFreq);                                  % get the number of the determined peaks
    if(numPeaks_t_hand(j))                                                  % calculate minimum and maximum peaks are found 
      minVal_t_hand(j) = min(peakFreq);
      maxVal_t_hand(j) = max(peakFreq);
    else
      minVal_t_hand(j) = NaN;
      maxVal_t_hand(j) = NaN;
    end
    
    peakFreq = cell2mat(RI_findPeak(data_head_fft, freqRange_theta, ...     % determine peaks in the theta-range of all participants (condition head)
                        data_head_fft{1}.label{j}));
    numPeaks_t_head(j) = length(peakFreq);                                  % get the number of the determined peaks
    if (numPeaks_t_head(j))                                                 % calculate minimum and maximum peaks are found
      minVal_t_head(j) = min(peakFreq);
      maxVal_t_head(j) = max(peakFreq);
    else
      minVal_t_head(j) = NaN;
      maxVal_t_head(j) = NaN;
    end
  end
  
  switch i
    case 1                                                                  % save results of the first dataset
      Peaks_Infants_HandsFree_Hand.label = data_hand_fft{1}.label';
      Peaks_Infants_HandsFree_Hand.goodParticipants = goodParticipants;       
      Peaks_Infants_HandsFree_Hand.peaksMu = numPeaks_m_hand;
      Peaks_Infants_HandsFree_Hand.minMu = minVal_m_hand;
      Peaks_Infants_HandsFree_Hand.maxMu = maxVal_m_hand;
      Peaks_Infants_HandsFree_Hand.peaksTheta = numPeaks_t_hand;
      Peaks_Infants_HandsFree_Hand.minTheta = minVal_t_hand;
      Peaks_Infants_HandsFree_Hand.maxTheta = maxVal_t_hand;
     
      Peaks_Infants_HandsFree_Head.label = data_head_fft{1}.label';
      Peaks_Infants_HandsFree_Head.goodParticipants = goodParticipants;
      Peaks_Infants_HandsFree_Head.peaksMu = numPeaks_m_head;
      Peaks_Infants_HandsFree_Head.minMu = minVal_m_head;
      Peaks_Infants_HandsFree_Head.maxMu = maxVal_m_head;
      Peaks_Infants_HandsFree_Head.peaksTheta = numPeaks_t_head;
      Peaks_Infants_HandsFree_Head.minTheta = minVal_t_head;
      Peaks_Infants_HandsFree_Head.maxTheta = maxVal_t_head;
    case 2                                                                  % save results of the second dataset
      Peaks_Infants_HandsRestr_Hand.label = data_hand_fft{1}.label';
      Peaks_Infants_HandsRestr_Hand.goodParticipants = goodParticipants;
      Peaks_Infants_HandsRestr_Hand.peaksMu = numPeaks_m_hand;
      Peaks_Infants_HandsRestr_Hand.minMu = minVal_m_hand;
      Peaks_Infants_HandsRestr_Hand.maxMu = maxVal_m_hand;
      Peaks_Infants_HandsRestr_Hand.peaksTheta = numPeaks_t_hand;
      Peaks_Infants_HandsRestr_Hand.minTheta = minVal_t_hand;
      Peaks_Infants_HandsRestr_Hand.maxTheta = maxVal_t_hand;
      
      Peaks_Infants_HandsRestr_Head.label = data_head_fft{1}.label';
      Peaks_Infants_HandsRestr_Head.goodParticipants = goodParticipants;
      Peaks_Infants_HandsRestr_Head.peaksMu = numPeaks_m_head;
      Peaks_Infants_HandsRestr_Head.minMu = minVal_m_head;
      Peaks_Infants_HandsRestr_Head.maxMu = maxVal_m_head;
      Peaks_Infants_HandsRestr_Head.peaksTheta = numPeaks_t_head;
      Peaks_Infants_HandsRestr_Head.minTheta = minVal_t_head;
      Peaks_Infants_HandsRestr_Head.maxTheta = maxVal_t_head;
    case 3                                                                  % save results of the third dataset
      Peaks_Adults_HandsFree_Hand.label = data_hand_fft{1}.label';
      Peaks_Adults_HandsFree_Hand.goodParticipants = goodParticipants;
      Peaks_Adults_HandsFree_Hand.peaksMu = numPeaks_m_hand;
      Peaks_Adults_HandsFree_Hand.minMu = minVal_m_hand;
      Peaks_Adults_HandsFree_Hand.maxMu = maxVal_m_hand;
      Peaks_Adults_HandsFree_Hand.peaksTheta = numPeaks_t_hand;
      Peaks_Adults_HandsFree_Hand.minTheta = minVal_t_hand;
      Peaks_Adults_HandsFree_Hand.maxTheta = maxVal_t_hand;
      
      Peaks_Adults_HandsFree_Head.label = data_head_fft{1}.label';
      Peaks_Adults_HandsFree_Head.goodParticipants = goodParticipants;
      Peaks_Adults_HandsFree_Head.peaksMu = numPeaks_m_head;
      Peaks_Adults_HandsFree_Head.minMu = minVal_m_head;
      Peaks_Adults_HandsFree_Head.maxMu = maxVal_m_head;
      Peaks_Adults_HandsFree_Head.peaksTheta = numPeaks_t_head;
      Peaks_Adults_HandsFree_Head.minTheta = minVal_t_head;
      Peaks_Adults_HandsFree_Head.maxTheta = maxVal_t_head;
    case 4                                                                  % save results of the fourth dataset
      Peaks_Adults_HandsRestr_Hand.label = data_hand_fft{1}.label';
      Peaks_Adults_HandsRestr_Hand.goodParticipants = goodParticipants;
      Peaks_Adults_HandsRestr_Hand.peaksMu = numPeaks_m_hand;
      Peaks_Adults_HandsRestr_Hand.minMu = minVal_m_hand;
      Peaks_Adults_HandsRestr_Hand.maxMu = maxVal_m_hand;
      Peaks_Adults_HandsRestr_Hand.peaksTheta = numPeaks_t_hand;
      Peaks_Adults_HandsRestr_Hand.minTheta = minVal_t_hand;
      Peaks_Adults_HandsRestr_Hand.maxTheta = maxVal_t_hand;
      
      Peaks_Adults_HandsRestr_Head.label = data_head_fft{1}.label';
      Peaks_Adults_HandsRestr_Head.goodParticipants = goodParticipants;
      Peaks_Adults_HandsRestr_Head.peaksMu = numPeaks_m_head;
      Peaks_Adults_HandsRestr_Head.minMu = minVal_m_head;
      Peaks_Adults_HandsRestr_Head.maxMu = maxVal_m_head;
      Peaks_Adults_HandsRestr_Head.peaksTheta = numPeaks_t_head;
      Peaks_Adults_HandsRestr_Head.minTheta = minVal_t_head;
      Peaks_Adults_HandsRestr_Head.maxTheta = maxVal_t_head;
  end
    
  clear data_hand_fft data_head_fft trialsAveraged;                         % remove loaded dataset from workspace
end

clear i j freqRange_mu freqRange_theta peakFreq maxVal_m_hand ...           % delete temporary variables
      goodParticipants numChn numPeaks_m_hand minVal_m_hand ...
      numPeaks_t_hand minVal_t_hand maxVal_t_hand numPeaks_m_head ...
      minVal_m_head maxVal_m_head numPeaks_t_head minVal_t_head ...
      maxVal_t_head srcFolder infHandsFreeFile infHandsRestrFile ...
      adHandsFreeFile adHandsRestrFile  

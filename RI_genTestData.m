load('../../processed/RationalImitation/RI_handsFree_01_Preprocessed_001.mat');

freqSamp    = data_hand{1}.fsample;
channels    = length(data_hand{1}.label);
dataLength  = length(data_hand);
trialLength = size(data_hand{1}.trial{1}, 2);

cfg         = [];
cfg.fsample = freqSamp;
cfg.method  = 'superimposed';
cfg.trllen  = trialLength./freqSamp;
cfg.s1.freq = 2;
cfg.s1.ampl = 400;
cfg.s2.freq = 4;
cfg.s2.ampl = 70;
cfg.s3.freq = 10;
cfg.s3.ampl = 20;
cfg.noise.ampl = 10;
cfg.showcallinfo = 'no';

for i=1:1:dataLength
  fprintf('%02d\n', i);
  if ~isempty(data_hand{i})
    for j=1:1:trialsAveraged(i).hand
      for k=1:1:channels
        sig_orig = ft_freqsimulation(cfg);
        data_hand{i}.trial{j}(k,:) = sig_orig.trial{1}(1,:);
      end
    end
  end
  if ~isempty(data_head{i})
    for j=1:1:trialsAveraged(i).head
      for k=1:1:channels
        sig_orig = ft_freqsimulation(cfg);
        data_head{i}.trial{j}(k,:) = sig_orig.trial{1}(1,:);
      end
    end    
  end  
end

labelFrontal = {'F3' 'F4' 'Fz'};
labelCentral = {'C3' 'C4' 'Cz'};
posFrontal = zeros(1,3);
posCentral = zeros(1,3);

for i=1:1:3
  posFrontal(i) = find(strcmp(data_head{1}.label, labelFrontal{i}));
  posCentral(i) = find(strcmp(data_head{1}.label, labelCentral{i}));
end

for i=1:1:dataLength
  fprintf('%02d\n', i);
  cfg.s2.ampl = 120;
  cfg.s3.ampl = 20;
  if ~isempty(data_hand{i})
    for j=1:1:trialsAveraged(i).head
      for k=posFrontal
        sig_theta = ft_freqsimulation (cfg);
        data_head{i}.trial{j}(k,:) = sig_theta.trial{1}(1,:);
      end
    end
  end
  cfg.s2.ampl = 70;
  cfg.s3.ampl = 60;
  if ~isempty(data_head{i})
    for j=1:1:trialsAveraged(i).head
      for k=posCentral
        sig_alpha = ft_freqsimulation (cfg);
        data_head{i}.trial{j}(k,:) = sig_alpha.trial{1}(1,:);
      end
    end    
  end  
end

clear i j k sig_alpha sig_theta posFrontal posCentral channels ...
      dataLength sig_theta sig_alpha freqSamp trialLength labelFrontal ...
      labelCentral cfg sig_orig

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

parfor i=1:1:dataLength
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

labelFrontal = {'F4'};
labelCentral = {'C3'};
posFrontal = zeros(1,1);
posCentral = zeros(1,1);

for i=1:1:length(labelFrontal)
  posFrontal(i) = find(strcmp(data_head{1}.label, labelFrontal{i}));
  posCentral(i) = find(strcmp(data_head{1}.label, labelCentral{i}));
end

cfgThetaH = cfg;
cfgThetaH.s2.ampl = 72;
cfgThetaH.s3.ampl = 20;

cfgAlphaH = cfg;
cfgAlphaH.s2.ampl = 70;
cfgAlphaH.s3.ampl = 21;

cfgThetaL = cfg;
cfgThetaL.s2.ampl = 68;
cfgThetaL.s3.ampl = 20;

cfgAlphaL = cfg;
cfgAlphaL.s2.ampl = 70;
cfgAlphaL.s3.ampl = 19;


parfor i=1:1:dataLength
  fprintf('%02d\n', i);
  if ~isempty(data_hand{i})
    for j=1:1:trialsAveraged(i).hand
      for k=posFrontal
        sig_theta = ft_freqsimulation(cfgThetaH);
        data_hand{i}.trial{j}(k,:) = sig_theta.trial{1}(1,:);
      end
      for k=posCentral
        sig_alpha = ft_freqsimulation(cfgAlphaL);
        data_hand{i}.trial{j}(k,:) = sig_alpha.trial{1}(1,:);
      end
    end
  end
  if ~isempty(data_head{i})
    for j=1:1:trialsAveraged(i).head
      for k=posFrontal
        sig_theta = ft_freqsimulation(cfgThetaL);
        data_head{i}.trial{j}(k,:) = sig_theta.trial{1}(1,:);
      end
      for k=posCentral
        sig_alpha = ft_freqsimulation(cfgAlphaH);
        data_head{i}.trial{j}(k,:) = sig_alpha.trial{1}(1,:);
      end
    end    
  end  
end

clear i j k sig_alpha sig_theta posFrontal posCentral channels ...
      dataLength sig_theta sig_alpha freqSamp trialLength labelFrontal ...
      labelCentral cfg cfgThetaH cfgAlphaH cfgThetaL cfgAlphaL sig_orig

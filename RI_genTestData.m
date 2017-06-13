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
cfg.s2.ampl = 100;
cfg.s3.freq = 10;
cfg.s3.ampl = 50;
cfg.noise.ampl = 20;

test_data = ft_freqsimulation (cfg);
sig_org_hand = test_data.trial{1}(1,:);

test_data = ft_freqsimulation (cfg);
sig_org_head = test_data.trial{1}(1,:);

cfg.s2.ampl = 150;
test_data = ft_freqsimulation (cfg);
sig_theta = test_data.trial{1}(1,:);

cfg.s2.ampl = 100;
cfg.s3.ampl = 100;
test_data = ft_freqsimulation (cfg);
sig_alpha = test_data.trial{1}(1,:);

clear freqSamp trialLength test_data cfg

for i=1:1:dataLength
  if ~isempty(data_hand{i})
    for j=1:1:trialsAveraged(i).hand
      for k=1:1:channels
        data_hand{i}.trial{j}(k,:) = sig_org_hand;
      end
    end
  end
  if ~isempty(data_head{i})
    for j=1:1:trialsAveraged(i).head
      for k=1:1:channels
        data_head{i}.trial{j}(k,:) = sig_org_head;
      end
    end    
  end  
end

clear i j k sig_org_hand sig_org_head

labelFrontal = {'F3' 'F4' 'Fz'};
labelCentral = {'C3' 'C4' 'Cz'};
posFrontal = zeros(1,3);
posCentral = zeros(1,3);

for i=1:1:3
  posFrontal(i) = find(strcmp(data_head{1}.label, labelFrontal{i}));
  posCentral(i) = find(strcmp(data_head{1}.label, labelCentral{i}));
end

clear labelFrontal labelCentral i

for i=1:1:dataLength
  if ~isempty(data_hand{i})
    for j=1:1:trialsAveraged(i).hand
      for k=posFrontal
        data_head{i}.trial{j}(k,:) = sig_theta;
      end
    end
  end
  if ~isempty(data_head{i})
    for j=1:1:trialsAveraged(i).head
      for k=posCentral
        data_head{i}.trial{j}(k,:) = sig_alpha;
      end
    end    
  end  
end

clear i j k sig_alpha sig_theta posFrontal posCentral channels dataLength

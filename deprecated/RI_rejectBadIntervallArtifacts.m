function [ data_out ] = RI_rejectBadIntervallArtifacts( data_in )
%RI_REJECTBADINTERVALLARTIFACTS Summary of this function goes here
%   Detailed explanation goes here

events = data_in.cfg.event;
artifact = zeros(length(events), 2);
j = 1;

for i=1:1:length(events)
  if(strcmp(events(i).type, 'Bad Interval'))
    artifact(j,1)=events(i).sample;
    artifact(j,2)=events(i).sample + events(i).duration - 1;
    j = j +1;
  end
end

artifact = artifact(1:j-1, :);

cfg                           = [];
cfg.event                     = events;
cfg.artfctdef.reject          = 'complete';
cfg.artfctdef.feedback        = 'no';
cfg.artfctdef.xxx.artifact    = artifact;
cfg.showcallinfo              = 'no';

data_out = ft_rejectartifact(cfg, data_in);

end

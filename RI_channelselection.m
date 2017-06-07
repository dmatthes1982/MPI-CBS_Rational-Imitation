function [ channel, chnNum ] = RI_channelselection( channel, label )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

channel = unique(channel);
numChan = length(channel);
chnNum{numChan} = [];

starlets = strfind(channel, '*');
channel = erase(channel, '*');

for i=1:1:numChan
  if isempty(starlets{i})
    num = find(strcmp(label, channel{i}));
    if ~isempty(num)
      chnNum{i} = num;
    else
      error('%s is not available in data', channel{i});
    end
  else
    if starlets{i} == 1
      num = find(~cellfun('isempty',(strfind(label, channel{i}))));
      if ~isempty(num)
        chnNum{i} = num';
      else
        error('No channel with number/letter %s is in data', channel{i});
      end
    else
      num = find(startsWith(label, channel{i}));
      if ~isempty(num)
        chnNum{i} = num';
      else
        error('No channel starts with letter %s', channel{i});
      end
    end
  end
end

end


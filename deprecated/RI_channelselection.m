function [ channel, chnNum ] = RI_channelselection( channel, label )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

channel = unique(channel);
numChan = length(channel);
chnNum{numChan} = [];

starlets = strfind(channel, '*');
channel = erase(channel, '*');
plus = strfind(channel, '+');

for i=1:1:numChan
  if ~isempty(starlets{i}) && ~isempty(plus{i})
    error('Use either * or + in channel definition. Definitions like F*+C* are not supported');
  elseif isempty(starlets{i}) && isempty(plus{i})
    num = find(strcmp(label, channel{i}));
    if ~isempty(num)
      chnNum{i} = num;
    else
      error('%s is not available in data', channel{i});
    end
  elseif ~isempty(starlets{i})
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
  elseif ~isempty(plus{i})
    channel{i} = strsplit(channel{i}, '+');
    numOfElements = length(channel{i});
    num = zeros(1, numOfElements);
    
    for j=1:1:numOfElements
      tmp = find(strcmp(label, channel{i}{j}));
      if ~isempty(tmp)
        num(j) = tmp;
      else
        error('%s is not available in data', channel{i}{j});
      end
    end
    
    chnNum{i} = num;
    tmp = [];
    for j=1:1:numOfElements
      tmp=strcat(tmp,channel{i}{j});
    end
    channel{i} = tmp;
  end
end

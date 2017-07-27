function [ data_out ] = RI_redefinetrial( data_in, varargin )
%RI_REDEFINETRIAL Summary of this function goes here
%   Detailed explanation goes here

num = 1;
while isempty(data_in{num})
  num = num + 1; 
end

switch length(varargin)
  case 0
    tStart = 0;
    tStop  = data_in{num}.time{1}(end);
  case 1
    tStart = varargin{1};
    tStop  = data_in{num}.time{1}(end);
  case 2
    tStart = varargin{1};
    tStop  = varargin{2};
end

lengthInput = length(data_in);
data_out{1, lengthInput} = [];

cfg.trials = 'all';
cfg.toilim = [tStart tStop];

for i=1:1:lengthInput
  if ~isempty(data_in{i})
    data_out{i} = ft_redefinetrial(cfg, data_in{i});
  end
end


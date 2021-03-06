function [ data_out ] = RI_poweranalysis( data_in )
% RI_POWERANALYSIS estimates the power activity using following settings:
%   freq range:       0 ... Fs/2 Hz
%   freq resolution:  Fs / L Hz
%
% Params:
%   data_in         fieldtrip data structure
%
% Output:
%   data_out        fieldtrip data structure
%
% This function requires the fieldtrip toolbox
%
% See also FT_FREQANALYSIS

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

num = 1;

while isempty(data_in{num})
  num = num + 1; 
end

Fs = data_in{num}.fsample;
L = length(data_in{num}.time{1});
lengthInput = length(data_in);
data_out{1, lengthInput} = [];

warning('off','all');

cfg                 = [];
cfg.method          = 'mtmfft';
cfg.output          = 'pow';
cfg.channel         = 'all';                            
cfg.trials          = 'all';                                                % calculate spectrum for every trial  
cfg.keeptrials      = 'no';                                                 % average over trials
cfg.pad             = 'maxperlen';                                          % no padding
cfg.taper           = 'hanning';                                            % hanning taper the segments
cfg.foi             = 0:Fs/L:Fs/2;                                          % range from zero to Fs/2 
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output

for i=1:1:lengthInput
  if ~isempty(data_in{i})
    data_out{i} = ft_freqanalysis(cfg, data_in{i});                         % calculate power spectral density
  end
end

warning('on','all');

end
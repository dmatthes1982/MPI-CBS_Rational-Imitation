function RI_writeTbl( rmANOVAtbl, destination, filename)
%RI_WRITEANOVATBL Summary of this function goes here
%   Detailed explanation goes here

writetable(rmANOVAtbl, strcat(destination, filename, '.xlsx'));

end


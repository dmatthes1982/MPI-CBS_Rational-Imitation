function [data_hand, data_head, trialsAveraged] = RI_preprocBVA( path_hand, ...
  path_head, childs )

% -------------------------------------------------------------------------
% General definitions & Allocating memory
% -------------------------------------------------------------------------
trialsAveraged(childs).head = [];                                           % shows how many good trials are in condition head touch for each participant
trialsAveraged(childs).hand = [];                                           % shows how many good trials are in condition hand touch for each participant
data_head{childs}           = [];                                           % data cell array for condition head touch
data_hand{childs}           = [];                                           % data cell array for condition hand touch 

% -------------------------------------------------------------------------
% Prerocessing data of condition "head touch"
% -------------------------------------------------------------------------
folder      = path_head;                                                    % specifies the data folder
filelist    = dir([folder, '/*.vhdr']);                                     % gets the filelist of the folder
filelist    = struct2cell(filelist);
filelist    = filelist(1,:);

parfor i=1:1:childs                                                            % preproocessing of all files of the data folder
  
  cellnumber  = find(contains(filelist, num2str(i,'%02.0f')), 1);
  
  if ~isempty(cellnumber)
    header = char(filelist(cellnumber));
    path = strcat(folder, header);

    data_head{i} = RI_importData(path);
    data_head{i} = RI_rejectBadIntervallArtifacts( data_head{i} );
    trialsAveraged(i).head = length(data_head{i}.trial);
  end
end

% -------------------------------------------------------------------------
% Prerocessing data of condition "hand touch"
% -------------------------------------------------------------------------
folder      = path_hand;                                                    % specifies the data folder
filelist    = dir([folder, '/*.vhdr']);                                     % gets the filelist of the folder
filelist    = struct2cell(filelist);
filelist    = filelist(1,:);

parfor i=1:1:childs                                                         % preprocessing of all files of the data folder
  
  cellnumber  = find(contains(filelist, num2str(i,'%02.0f')), 1);
  
  if ~isempty(cellnumber)
    header = char(filelist(cellnumber));
    path = strcat(folder, header);

    data_hand{i} = RI_importData(path);
    data_hand{i} = RI_rejectBadIntervallArtifacts( data_hand{i} );
    trialsAveraged(i).hand = length(data_hand{i}.trial);
  end
end

end

childs      = 54;
conditions  = 2;
trialsAveraged{childs, conditions} = [];
data{childs} = [];

folder      = '../../data/RationalImitation/handsFree_SegHead_BVA/';
filelist    = dir([folder, '/*.vhdr']);
filelist    = struct2cell(filelist);
filelist    = filelist(1,:);


for i=1:1:54
  
  cellnumber  = find(contains(filelist, num2str(i,'%02.0f')), 1);
  
  if ~isempty(cellnumber)
    header = char(filelist(cellnumber));
    path = strcat(folder, header);

    data{i} = RI_importData(path);
    data{i} = RI_rejectBadIntervallArtifacts( data{i} );
    trialsAveraged{i, 1} = length(data{i}.trial);
  end
end

clear i childs conditions folder filelist cellnumber header path;

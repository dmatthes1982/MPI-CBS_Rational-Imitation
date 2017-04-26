folder = '../../data/RationalImitation/handsFree_SegHand_BVA/';
header = 'RationalImitation_handsFree_01_Leonhard_SegHand.vhdr';
path = strcat(folder, header);

data = RI_importData(path);

clear folder header path;
filename='C:\Users\admin\Desktop\data.xlsx';
imported_data=importdata(filename,',',1);

text_data = imported_data.textdata;
header_data = text_data(1,:);
[rows, cols] = size(text_data);
label_data = text_data(2:rows,:);
[imrow,imcol] = size(imported_data.data);
indicator_data = imported_data.data(:,13:imcol);
cluster_data = label_data(:,5);
clst = categorical(cluster_data);

[indrow, indcol] = size(indicator_data);
ind =  indicator_data;
for ii = 1:indcol
   ind(:,ii) = ind(:,ii) - mean(ind(:,ii));
   ind(:,ii) = ind(:,ii)/ std(ind(:,ii));
end

[B,dev,stats] = mnrfit(ind,clst);

X = ind(1,:);
p=mnrval(B,X);






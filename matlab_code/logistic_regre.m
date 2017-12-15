filename='C:\Users\admin\Desktop\data_prep_D_C_02.xlsx';
imported_data=importdata(filename,',',1);

text_data = imported_data.textdata.data;
header_data = text_data(1,:);
[rows, cols] = size(text_data);
label_data = text_data(2:rows,:);
[imrow,imcol] = size(imported_data.data.data);
indicator_data = imported_data.data.data(:,12:imcol);

[indrow, indcol] = size(indicator_data);
ind =  indicator_data;
for ii = 1:indcol
   ind(:,ii) = ind(:,ii) - mean(ind(:,ii));
   ind(:,ii) = ind(:,ii)/ std(ind(:,ii));
end
% change in each loop from 1:11
for i=1:11
    disp('For group:');
    disp(i);
    cluster_data = imported_data.data.data(:,i);
    clst = categorical(cluster_data);
    [B,dev,stats] = mnrfit(ind,clst);
    %X = ind(1,:);
    X = ind;
    p=mnrval(B,X);
    %%%%% check the predicted results
    err = round(cluster_data - p(:,2));
    target = round(cluster_data);
    predicted = round(p(:,2));
    adele = [target,predicted , err];

    %%%%% list relevant indicators 
    %%%  [number of indicator, coefficient value]

    % factor that increase the risk to be in group two
    [iNeg] = find( B < -1000);
    count_iNeg = size(iNeg);
    disp('Relevant variables - This higher, higher probability');
    disp(iNeg);
    % factor that increase the risk to be in group one
    [iPos] = find( B > 1000);
    count_iPos = size(iPos);
    disp('Relevant variables - This higher, lower probability');
    disp(iPos);
end








% %X = ind(1,:);
% X = ind;
% p=mnrval(B,X);
% 
% %%%%% check the predicted results
% err = round(cluster_data - p(:,2));
% target = round(cluster_data);
% predicted = round(p(:,2));
% adele = [target,predicted , err];
% 
% %%%%% list relevant indicators 
% %%%  [number of indicator, coefficient value]
% 
% % factor that increase the risk to be in group two
% [iNeg] = find( B < -1000);
% count_iNeg = size(iNeg);
% disp('Relevant variables - This higher, higher probability');
% disp(iNeg);
% 
% 
% % factor that increase the risk to be in group one
% [iPos] = find( B > 1000);
% count_iPos = size(iPos);
% disp('Relevant variables - This higher, lower probability');
% disp(iPos);

%%%%%%%%%%%








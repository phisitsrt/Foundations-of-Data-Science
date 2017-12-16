rng(3)  % For reproducibility of random number

%%%%% Use this code to import data at first time. %%%%%

filename='data/data_Prep_D_C.xlsx';
imported_data=importdata(filename,',',1);

%%%%%%%%%%

text_data = imported_data.textdata.data;

header_data = text_data(1,:);
[rows, cols] = size(text_data);

label_data = text_data(2:rows,1:6);

[imrow,imcol] = size(imported_data.data.data);
indicator_data = imported_data.data.data(:,12:imcol);

%%%%%%%%%

% normalisation
[indrow, indcol] = size(indicator_data);
ind =  indicator_data;
for ii = 1:indcol
   ind(:,ii) = ind(:,ii) - mean(indicator_data(:,ii));
   ind(:,ii) = ind(:,ii)/ std(indicator_data(:,ii));
end

%%%%%%%%%

disp('file name: ');
disp(filename);

% change in each loop from 1:11
for i=1:11
    %i = 1;
    
    disp('For group:');
    disp(i);
    cluster_data = imported_data.data.data(:,i);
    clst = categorical(cluster_data);
    [B,dev,stats] = mnrfit(ind,clst);
        %X = ind(1,:);
    X = ind;
    p=mnrval(B,X);
    
    %%%%% check the predicted results
    target = round(cluster_data);
    predicted = round(p(:,2));
    
    err = round(cluster_data - p(:,2));
    
    adele = [target,predicted,err];
    
    [iErr] = find( err > 0 | err < 0 );
    [count_iErr,~] = size(iErr);
    disp('Count Error: ');
    disp(count_iErr);

    %%%%% list relevant indicators 
    %%%  [number of indicator, coefficient value]
    
    % dynamic threshold
    thrh = mean(abs(B));   % use mean value of coefficient
    disp('Coefficient Threshold: ');
    disp(thrh);
    
    % factor that increase the risk to be in group two
    [iNeg] = find( B < (-1*thrh) );
    count_iNeg = size(iNeg);
    disp('Relevant variables - This higher, higher probability');
    disp(iNeg);
    
    % factor that increase the risk to be in group one
    [iPos] = find( B > thrh);
    count_iPos = size(iPos);
    disp('Relevant variables - This higher, lower probability');
    disp(iPos);
end














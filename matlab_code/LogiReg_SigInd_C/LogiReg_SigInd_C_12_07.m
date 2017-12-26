rng(3)  % For reproducibility of random number

%%%%% Use this code to import data at first time. %%%%%

filename='data/data_Prep_D_C.xlsx';
imported_data=importdata(filename,',',1);

%%%%%%%%%%

text_data = imported_data.textdata.data;

header_data = text_data(1,:);
[rows, cols] = size(text_data);

pre_indicator_name = header_data(1,18:cols);
pre_indicator_name = ['intercept' pre_indicator_name];

clst_trans =  header_data(1,7:17);

label_data = text_data(2:rows,1:6);

[imrow,imcol] = size(imported_data.data.data);
pre_indicator_data = imported_data.data.data(:,12:imcol);

%%%%%%%%%
 
% indicator_name = pre_indicator_name;
% indicator_data = pre_indicator_data;

chs = [ 2:6 8 9 11 14:16 19:53 ];
indicator_name = pre_indicator_name(:,[1 chs]);
indicator_data = pre_indicator_data(:,chs-1);

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
    %i = [1 3]; % best
    %i = [3]; % better, high 
    %i = [2 5]; % worse
    %i = [6 9]; % better, low
    %i = 11;
    
    disp('For group:');
    disp(i);
    disp(clst_trans(i));
    
    clst_ii = imported_data.data.data(:,i);
    [ctry_rows,~] = size(clst_ii);
    cluster_data = zeros(ctry_rows,1);
    
    [~,iimax] = size(i);
    for ii = 1:iimax
        cluster_data = cluster_data + clst_ii(:,ii); 
    end
    
    iCntry = find(cluster_data == 1);
    [mvup_cntry,~] = size(iCntry); 
    disp('number of countries :');
    disp(mvup_cntry)
    disp(label_data(iCntry,1:2));
    
    
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
    [Brow,~] = size(B);
    
    % dynamic threshold
    thrh = prctile(abs(B(2:Brow,:)),80);   
    disp('Coefficient Threshold: ');
    disp(thrh);
    
    % factor that increase the risk to be in group two
    [iNeg] = find( B < (-1*thrh) );
    count_iNeg = size(iNeg);
    disp('Relevant variables - This high, higher probability');
    disp(iNeg);
    
    disp_ind_name = indicator_name(iNeg);
    disp_ind_name = disp_ind_name';
    disp(disp_ind_name);
    
    disp_B = B(iNeg);
    [disp_rows,~] = size(disp_B);
    
    for ii = 1:disp_rows
        disp([num2str(iNeg(ii,1)),disp_ind_name(ii,1),num2str(disp_B(ii,1))]);
    end
    
    %%%%%%%%%%%%
    
    % factor that increase the risk to be in group one
    [iPos] = find( B > thrh);
    count_iPos = size(iPos);
    disp('Relevant variables - This low, higher probability');
    disp(iPos);
    
    disp_ind_name = indicator_name(iPos);
    disp_ind_name = disp_ind_name';
    disp(disp_ind_name);
    
    disp_B = B(iPos);
    [disp_rows,~] = size(disp_B);
    
    for ii = 1:disp_rows
        disp([num2str(iPos(ii,1)),disp_ind_name(ii,1),num2str(disp_B(ii,1))]);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%
    pval = stats.p;
    
    % dynamic threshold
    p_thrh = prctile( pval(2:Brow,:) ,5);   
    disp('P-value Threshold: ');
    disp(p_thrh);
    
    % factor that increase the risk to be in group two
    [iSigInd] = find( pval <= p_thrh );
    count_iSigInd = size(iSigInd);
    disp('Significant Indicators: ');
    disp(iSigInd);
    
    disp_ind_name = indicator_name(iSigInd);
    disp_ind_name = disp_ind_name';
    disp(disp_ind_name);
    
    disp_B = B(iSigInd);
    [disp_rows,~] = size(disp_B);
    
    disp('Coefficient : ');
    for ii = 1:disp_rows
        disp([num2str(iSigInd(ii,1)),disp_ind_name(ii,1),num2str(disp_B(ii,1))]);
    end
    
    disp_pval = pval(iSigInd);
    [disp_rows,~] = size(disp_pval);
    
    disp('p-Value : ');
    for ii = 1:disp_rows
        disp([num2str(iSigInd(ii,1)),disp_ind_name(ii,1),num2str(disp_pval(ii,1))]);
    end
    
    %%%%%%%%%%%%
    disp('Count Error: ');
    disp(count_iErr);
    
    disp('----------------');
end














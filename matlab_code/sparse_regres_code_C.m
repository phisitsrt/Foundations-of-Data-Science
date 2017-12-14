rng(3)  % For reproducibility of random number

% import the data
filename = 'data/FTSE100_Prep.csv';
delimiterIn = ',';
headerIn = 1;
imported_data = importdata(filename,delimiterIn,headerIn);

% get the text data
text_data = imported_data.textdata;
    % check_data = text_data(1,:)
    % check_data = text_data(2,:)
header_name = text_data(1,:); % for headers

% get the numerical data
num_data = imported_data.data;
    % check_data = num_data(1,[1 3 5])
    size(num_data);

% select some rows to use
%data = num_data(99:1360,:); % five years from 2012 to 2016 
data = num_data(99:1596,:); % five years from 2012 to 2017
[rows_size, ~] = size(data);

% get closed price data
price = data(:,1);
    %%% size(price)

% get trade volume data
volume = data(:,6);

% get date_value 
date_value = data(:,7:10);

p = 20; % price dimensions
v = 20; % volume dimensions
data_sample_size = rows_size;
numRow = data_sample_size - p;

% create the index matrix for the timeseries
index_matrix = zeros(numRow,p+1);
for dim=1:p+1
    index = linspace(1 + (dim-1), numRow + (dim-1), numRow);
    index_matrix(:,dim)= index';
end
[index_row, index_col] = size(index_matrix);

% create the index matrix for the timeseries
index_matrix_2 = zeros(numRow,v);
for dim=1:v
    index = linspace(1 + (dim-1), numRow + (dim-1), numRow);
    index_matrix_2(:,dim)= index';
end
[index_row_2, index_col_2] = size(index_matrix_2);

% create the data matrix
price_matrix = zeros(numRow,p+1);
% insert price data
for i = 1:index_row
    for j = 1:index_col
        price_matrix(i,j) = price(index_matrix(i,j));
    end
end
vol_matrix = zeros(numRow,v);
% insert volume data
for i = 1:index_row_2
    for j = 1:index_col_2
        vol_matrix(i,j) = volume(index_matrix_2(i,j));
    end
end

data_matrix = [vol_matrix price_matrix];

%%%%%%%%%%%%%%%%%%%%%%%%%%
% keep data for reverse normalization
price_mtx_nml = price_matrix;
vol_mtx_nml = vol_matrix;

% Normalize the data to have zero mean and unit standard deviation
% Normalize each row by data of that row
for ii = 1:numRow
    price_mtx_nml(ii,:) = price_mtx_nml(ii,:) - mean(price_matrix(ii,1:p));
    price_mtx_nml(ii,:) = price_mtx_nml(ii,:)/(std(price_matrix(ii,1:p)));
    
    vol_mtx_nml(ii,:) = vol_mtx_nml(ii,:) - mean(vol_matrix(ii,1:v));
    vol_mtx_nml(ii,:) = vol_mtx_nml(ii,:)/(std(vol_matrix(ii,1:v)));
end

data_mtx_nml = [vol_mtx_nml price_mtx_nml];

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% select a few dimension to use
     data_matrix = data_matrix(:,[30, 40, 41]);
     data_mtx_nml = data_mtx_nml(:,[30,40, 41]);
     
[data_rows, data_cols] = size(data_matrix);
     
%%%%%%%%%%%%%%%%%%%%%%%%%%

Inp_all = data_matrix(:,1:data_cols-1);
Out_all = data_matrix(:,data_cols);

%%%%%%%%%%%%%%%%

 % use data from 2015 to 2016 as test set
test_data_size = 1596-857+1-20;   
        % 720 rows for 857:1596 with 20 dimensions
train_data_size = data_rows - test_data_size;

% training data
Xtr = data_mtx_nml(1:train_data_size,1:data_cols-1);
Ytr = data_mtx_nml(1:train_data_size,data_cols);
% test data
Xts = data_mtx_nml(train_data_size+1:data_rows,1:data_cols-1);
Yts = data_mtx_nml(train_data_size+1:data_rows,data_cols);

%%%%%%%%%%%%%%%%

% add column for intercept term
Xtr = [Xtr  ones(train_data_size,1)];
Xts = [Xts  ones(test_data_size,1)];

% Least squares linear regression using pseudo inverse
W = inv(Xtr'*Xtr)*Xtr'*Ytr;
Yhtr = Xtr*W;
Yhts = Xts*W;

% reverse normalization by rows
Yhall = [Yhtr; Yhts];
Yhall_rv = Yhall;
for ii = 1:data_rows
    Yhall_rv(ii) = Yhall_rv(ii)*std(price_matrix(ii,1:p));
    Yhall_rv(ii) = Yhall_rv(ii) + mean(price_matrix(ii,1:p));
end

%%%%%%%%%%%%%%%%%%%
Out_ts = Out_all(train_data_size+1:data_rows,:);
Yhts_rv = Yhall_rv(train_data_size+1:data_rows,:);

err_yhts1 = Yhts_rv - Out_ts;
%%%%%%%%%%%%%%%%%%%

% plot of prediction on test set
figure(1) 
plot(Out_ts, Yhts_rv, 'b*')  
grid on 
title('Linear Regression Prediction on Test Data', 'FontSize', 14); 
xlabel('Target', 'FontSize', 14); 
ylabel('Prediction', 'FontSize', 14);
daspect([1 1 1]);
hold on,
pic_lim = linspace(min(Yhts_rv),max(Yhts_rv),10);
plot(pic_lim,pic_lim,'g')
hold off
legend({'Predicted Outputs','Accuracy Line'},'Location','southeast')

%%%%%%%%%%%%%%%%%%%

% prepare axis value as date value for test set 
dt_steps = 1+(data_rows - test_data_size):data_rows;
dt_val = datetime(date_value(dt_steps,2),date_value(dt_steps,3),date_value(dt_steps,4));

% number of data points to plot
%plot_steps = 1:test_data_size; 
plot_steps = 1:20; 

figure(2), clf,
plot(dt_val(plot_steps),Yhts_rv(plot_steps,1),'b.-')
grid on
hold on,
plot(dt_val(plot_steps),Out_ts(plot_steps,1),'r.-')
hold off
title('LR Prediction and Target on Test Data', 'FontSize', 14); 
xlabel('Date', 'FontSize', 14); 
ylabel('FTSE100 Value', 'FontSize', 14);
legend({'Predicted time series','Target time series'},'Location','northwest')
%datetick('x','yyyy-mm-dd','keepticks','keeplimits')


plot_steps_02 = 1:20; 

%%%%%%%%%%%%%%%%%%%%

%Sparse Regression
[Xtr_rows, Xtr_cols] = size(Xtr);

gama = 2.7;
cvx_begin quiet
variable W2( Xtr_cols );
minimize( norm(Xtr*W2-Ytr) + gama*norm(W2,1) );
cvx_end

Yhtr = Xtr*W2;
Yhts = Xts*W2;

% reverse normalization by rows
Yhall = [Yhtr; Yhts];
Yhall_rv = Yhall;
for ii = 1:data_rows
    Yhall_rv(ii) = Yhall_rv(ii)*std(price_matrix(ii,1:p));
    Yhall_rv(ii) = Yhall_rv(ii) + mean(price_matrix(ii,1:p));
end

Yhts_rv = Yhall_rv(train_data_size+1:data_rows,:);

err_yhts3 = Yhts_rv - Out_ts;
%%%%%%%%%%%%%%%%%%%%

figure(7), clf,
plot(Out_ts, Yhts_rv, 'm*')
legend('Sparse Regression');
title('Linear Regression with Regularisation', 'FontSize', 14)
xlabel('Target', 'FontSize', 14)
ylabel('Prediction', 'FontSize', 14)
grid on
daspect([1 1 1]);
hold on,
pic_lim = linspace(min(Yhts_rv),max(Yhts_rv),10);
plot(pic_lim,pic_lim,'g')
hold off
legend({'Predicted Outputs','Accuracy Line'},'Location','northwest')

%%%%%%%%%%%%%%%%%%%%

%Find the non-zero coefficients that are not switched off by the regularizer:
[iNzero] = find(abs(W2) > 1e-5);
disp('Relevant variables');
disp(iNzero);

%%%%%%%%%%%%%%%%%%%%

figure(8), clf,
plot(dt_val(plot_steps),Yhts_rv(plot_steps,1),'b.-')
grid on
hold on,
plot(dt_val(plot_steps),Out_ts(plot_steps,1),'r.-')
hold off
title('Sparse Regression Prediction and Target on Test Data', 'FontSize', 12); 
xlabel('Date', 'FontSize', 14); 
ylabel('FTSE100 Value', 'FontSize', 14);
legend({'Predicted time series','Target time series'},'Location','northwest')
%datetick('x','yyyy-mm-dd','keepticks','keeplimits')

%%%%%%%%%%%%%%%%%

figure(10)
boxplot( [err_yhts1 err_yhts2 err_yhts3] ,'Labels',{'LR','ANN','Sparse'})
xlabel('Dataset')
ylabel('Prediction Error Value')
title('Prediction Errors on Test Data.')

% display Mean Squared Error
disp('Root Mean Squared Error');
disp('Linear Regression : ');
disp(mean(err_yhts1.^2).^(1/2));
disp('ANN : ');
disp(mean(err_yhts2.^2).^(1/2));
disp('Sparse Regression : ');
disp(mean(err_yhts3.^2).^(1/2));

%%%%%%%%%%%%%%%%%%%%

% Increasing Regularization - Change Gamma value
part = 100;
gama_rng = linspace(0.01,10,part);
count_iNzero = zeros(part,2);
rnd = 1;

err_yhts_w2 = zeros(test_data_size,part);

%Sparse Regression
for rnd = 1:part
    
gama = gama_rng(rnd);
cvx_begin quiet
variable w2( Xtr_cols );
minimize( norm(Xtr*w2-Ytr) + gama*norm(w2,1) );
cvx_end

Yhtr = Xtr*w2;
Yhts = Xts*w2;

% reverse normalization by rows
Yhall = [Yhtr; Yhts];
Yhall_rv = Yhall;
for ii = 1:data_rows
    Yhall_rv(ii) = Yhall_rv(ii)*std(price_matrix(ii,1:p));
    Yhall_rv(ii) = Yhall_rv(ii) + mean(price_matrix(ii,1:p));
end

Yhts_rv = Yhall_rv(train_data_size+1:data_rows,:);

err_yhts_w2(:,rnd) = Yhts_rv - Out_ts;

%Find the non-zero coefficients that are not switched off by the regularizer:
[iNzero] = find(abs(w2) > 1e-5);
count_iNzero(rnd,:) = size(iNzero);
end

figure(9), clf,
plot(gama_rng, count_iNzero(:,1),'bx-','LineWidth', 2),
title('Increasing Regularization', 'FontSize', 14)
xlabel('Gamma', 'FontSize', 14)
ylabel('Number of non-zero coefficient', 'FontSize', 14)
grid on

%%%%%%%%%%%%%%%%%

figure(11), clf,
plot(gama_rng, mean(err_yhts_w2.^2).^(1/2),'mx-','LineWidth', 2),
title('Increasing Regularization', 'FontSize', 14)
xlabel('Gamma', 'FontSize', 14)
ylabel('Root Mean Squared Error', 'FontSize', 14)
grid on

%%%%%%

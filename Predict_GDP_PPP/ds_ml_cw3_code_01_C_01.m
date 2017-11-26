% Load Boston Housing Data from UCI ML Repository
% into an array imported_data; 
filename = 'cw3_data_103.csv';
delimiterIn = ',';
headerIn = 1;
imported_data = importdata(filename,delimiterIn,headerIn);

% get the text data
text_data = imported_data.textdata;
    % check_data = text_data(1,:)
    % check_data = text_data(2,:)
header_name = text_data(1,:); % for headers

% get country data from the text data
[txt_row,txt_col] = size(text_data);
country_data = text_data(2:txt_row,1:2);

% get the numerical data
num_data = imported_data.data;
    % check_data = num_data(1,[5 6 9 10])
data = num_data(:,[5 6 9 10]);

year_data = array2table(num_data(:,1),'VariableNames',header_name(1,3));
country_year_data = [country_data year_data];

%%%%%%

% get size of samples and dimensions
[N, p1] = size(data);
p = p1-1;  % size of dimensions
% disp(['number of dimension, p : ' num2str(p) ]);

% keep data for reverse normalization
Xdata = data(:,1+1:1+p);
ydata = data(:,1);

% % Normalize the data to have zero mean and unit standard deviation
X = data(:,1+1:1+p);
for j=1:p
X(:,j)=X(:,j)-mean(Xdata(:,j));
X(:,j)=X(:,j)/std(Xdata(:,j));
end
y = data(:,1);
y = y - mean(ydata);
y = y/std(ydata);

% Separate randomly into training and test sets 
rng default  % For reproducibility of random number
ii = randperm(N);

training_size = round(N/10);

% set training and test data
    % training set
Xtr = X(ii(1:training_size),:);
ytr = y(ii(1:training_size),:);
    % test set
Xts = X(ii(training_size+1:N),:);
yts = y(ii(training_size+1:N),:);

% Get the size of training set and test set.
[Ntr, ptr] = size(Xtr);
[Nts, pts] = size(Xts);

% transpose for the neural network function
Xtr = Xtr';
ytr = ytr';
Xts = Xts';
yts = yts';

% train neural network
net_01 = feedforwardnet(20); 
net_01 = train(net_01, Xtr, ytr); 

% predict
yh = net_01(Xtr);
perf_tr_net_01 = perform(net_01,yh,ytr);

yhts = net_01(Xts);
perf_ts_net_01 = perform(net_01,yhts,yts);

% plot
figure(1)
plot(ytr, yh, 'bx', 'LineWidth', 2), grid on 
title('Prediction on Training Data', 'FontSize', 14); 
xlabel('Target', 'FontSize', 14); 
ylabel('Prediction', 'FontSize', 14);
daspect([1 1 1]);
hold on,
plot(-5:5,-5:5,'g')
hold off

figure(2)
plot(yts, yhts, 'rx', 'LineWidth', 2), grid on 
title('Prediction on Test Data', 'FontSize', 14); 
xlabel('Target', 'FontSize', 14); 
ylabel('Prediction', 'FontSize', 14);
daspect([1 1 1]);
hold on,
plot(-5:5,-5:5,'g')
hold off

% transpose back and
% keep the results in variables
pXtr = Xtr';
pytr = ytr';
pXts = Xts';
pyts = yts';
pyh = yh';
pyhts = yhts';

% set X1 as life expectancy
X1 = X(:,2);
% set X2 as patent appliations per million people
X2 = X(:,3);

% use the prediction model to calculate posterior probability of classes
numGrid = 50;
xMin = -10.0;
xMax = 2.0;
yMin = -2.0;
yMax = 10.0;
xRange = linspace(xMin, xMax, numGrid);
yRange = linspace(yMin, yMax, numGrid);

% initialize plot-point matrix
model_output = zeros(numGrid, numGrid);

% loop to get posterior probability of each plot-points
for i=1:numGrid
	for j=1:numGrid
        x = [1 yRange(j) xRange(i)];
        
        %transpose for the neural net function
        x = x';
        
        % calculate output by the prediction model
        model_output(i,j) = net_01(x);
	end
end

% plot inputs
figure(3), clf,
plot(X1(:,1),X2(:,1),'m*');
title('Inputs and Outputs Contour', 'FontSize', 14); 
xlabel('x1', 'FontSize', 14); 
ylabel('x2', 'FontSize', 14);
daspect([1 1 1]);

hold on,
% plot contour
contour(xRange,yRange,model_output, [0 3 5], 'LineWidth', 2);
colorbar;
hold off

% draw output in mesh
figure(4), clf,
mesh(xRange,yRange,model_output);
xlabel('x1', 'FontSize', 14); 
ylabel('x2', 'FontSize', 14);
zlabel('Prediction Outputs', 'FontSize', 14);
xlim([xMin xMax]);
ylim([yMin yMax]);
title('Prediction Output', 'FontSize', 14); 
colorbar;
view(45,45);

%%%%%%
% 
% disp('------------------------' );
% disp('cross validation' );
% 
% figure(5), clf,
% hold off
% 
% % Compute cross validation and get RMS errors of test set.
% fold = 10;
% testset_size = round(N/fold);
% 
% disp(['fold : ' num2str(fold) ]); 
% 
% % Variable to collect all values of error 
% all_err_yh = zeros(N);  % for prediction error on training set.
% all_err_yhts = zeros(N);  % for prediction error on test set.
% 
% % Variable to collect Root Mean Square (RMS) error values of each fold.
% fold_RMS_err_yh = zeros(fold,1);      % for training set
% fold_RMS_err_yhts = zeros(fold,1);    % for test set
% 
% % Variable to collect different between RMS_err_yh and RMS_err_yhts of each fold.
% fold_diff_err_yhts_yh = zeros(fold,1);
% 
% % Variable to collect variance of error values of each fold.
% fold_var_err_yh = zeros(fold,1);     % for training set
% fold_var_err_yhts = zeros(fold,1);   % for test set
% 
% % Variable to collect Standard Deviation of error values of each fold.
% fold_sd_err_yh = zeros(fold,1);     % for training set
% fold_sd_err_yhts = zeros(fold,1);   % for test set
% 
% % count = 10;
% for count = 1:fold
%     % Separate into training and test sets 
%     if count == 1
%         %training set
%         Xtr = X(testset_size+1:N,:);
%         ytr = y(testset_size+1:N,:);
%         %test set
%         Xts = X(1:testset_size,:);
%         yts = y(1:testset_size,:);
%     elseif (count > 1 && count < fold)
%         %training set first part
%         Xtr = X(1:testset_size*(count-1),:);
%         ytr = y(1:testset_size*(count-1),:);
%         %training set second part
%         Xtr = [Xtr; X( (testset_size*count)+1:N,:) ] ;
%         ytr = [ytr; y( (testset_size*count)+1:N,:) ] ;
%         %test set
%         Xts = X( testset_size*(count-1)+1:(testset_size*count),:);
%         yts = y( testset_size*(count-1)+1:(testset_size*count),:);
%     elseif (count == fold)
%         %training set
%         Xtr = X(1:testset_size*(count-1),:);
%         ytr = y(1:testset_size*(count-1),:);
%         %test set
%         Xts = X( testset_size*(count-1)+1:N,:);
%         yts = y( testset_size*(count-1)+1:N,:);
%     end
%     
%     % Get the size of training set and test set.
%     [Ntr, ptr] = size(Xtr);
%     [Nts, pts] = size(Xts);
% 	
%     %%%%%%
%     % if fold = 1 that means no training set. so, just stop.
%     if(fold <= 1) 
%         break; 
%     end
%     
%     % transpose for the neural network function
%     Xtr = Xtr';
%     ytr = ytr';
%     Xts = Xts';
%     yts = yts';
% 
%     % train neural network
%     net_02 = feedforwardnet(20); 
%     net_02 = train(net_02, Xtr, ytr); 
% 
%     % predict
%     yh = net_02(Xtr);
%     % perf_tr_net_02 = perform(net_02,yh,ytr);
% 
%     yhts = net_02(Xts);
%     % perf_ts_net_02 = perform(net_02,yhts,yts);
% 
%     % transpose back
%     Xtr = Xtr';
%     ytr = ytr';
%     Xts = Xts';
%     yts = yts';
%     yh  = yh';
%     yhts = yhts';
%     
%     % plot between prediction on test set and target outputs
%     figure(5)
%     if count > 1 
%         hold on; 
%     end
%     plot(yts, yhts, '.', 'LineWidth', 2) 
% 
%     % Compute the difference between training and test errors
% 
%     % % calculate Root Mean Squared error
%     fold_RMS_err_yh(count,1) = mean((yh - ytr).^2).^(1/2);
%     fold_RMS_err_yhts(count,1) = mean((yhts - yts).^2).^(1/2);
% 
%     % % calculate different between test error and training error
%     fold_diff_err_yhts_yh(count,1) = fold_RMS_err_yhts(count,1) - fold_RMS_err_yh(count,1);
% 
%     % % calculate variance of error
%     fold_var_err_yh(count,1) = var(yh - ytr);
%     fold_var_err_yhts(count,1) = var(yhts - yts);
%     
%     % % calculate Standard Deviation of error
%     fold_sd_err_yh(count) = var(yh - ytr)^(1/2);
%     fold_sd_err_yhts(count) = var(yhts - yts)^(1/2);    
%      
%     % collect all values of error from every fold
%     if count == 1
%         all_err_yh = (yh - ytr);
%     else
%         all_err_yh = [all_err_yh; (yh - ytr)];
%     end
%     % % check number of error values on training set
%     % disp( num2str(size(all_err_yhts)));
%     
%     if count == 1
%         all_err_yhts = (yhts - yts);
%     else
%         all_err_yhts = [all_err_yhts; (yhts - yts)];
%     end
%     % % check number of error values should equan to N number of data points
%     % disp( num2str(size(all_err_yhts)));
% end
% hold off,
% grid on 
% title('Prediction on Test Data  ', 'FontSize', 16); 
% xlabel('Target', 'FontSize', 14); 
% ylabel('Prediction', 'FontSize', 14);
% daspect([1 1 1]);
% hold on,
% plot(-5:5,-5:5,'g')
% hold off
% 
% % boxplot between training and test errors
% fold_RMS_err_tr_ts = [fold_RMS_err_yh fold_RMS_err_yhts] ;
% 
% figure(6)
% boxplot([fold_RMS_err_yh fold_RMS_err_yhts],'Labels',{'Training set','Test set'})
% xlabel('Dataset')
% ylabel('Root Mean Squared Error')
% title('Prediction Errors on Training and Test Dataset.')
% 
% % plot histogram of error on test set
% figure(7), clf,
% hist(all_err_yh);
% title('Histogram of Prediction Error on Training Dataset', 'FontSize', 14)
% xlabel('Error Value', 'FontSize', 14)
% ylabel('Frequency', 'FontSize', 14)
% 
% % plot histogram of error on test set
% figure(8), clf,
% hist(all_err_yhts);
% title('Histogram of Prediction Error on Test Dataset', 'FontSize', 14)
% xlabel('Error Value', 'FontSize', 14)
% ylabel('Frequency', 'FontSize', 14)
% 
% % print the calculated values about error
% disp('Average different between error on training set and test set: ');
% disp(num2str(mean(fold_diff_err_yhts_yh)));
% 
% disp('Average RMS of error on training set:' );
% disp(num2str(mean(fold_RMS_err_yh)));
% disp('Average RMS of error on test set:' );
% disp(num2str(mean(fold_RMS_err_yhts)))
% 
% disp('Average variance of error on training set: '  );
% disp(num2str(mean(fold_var_err_yh)) );  
% disp('Average variance of error on test set: '  );
% disp(num2str(mean(fold_var_err_yhts)) );  
% 
% disp('Average SD of error on training set: ');
% disp(num2str(mean(fold_sd_err_yh)));    
% disp('Average SD of error on test set: ');
% disp(num2str(mean(fold_sd_err_yhts))); 
% 
%%%%%%%

% transpose for the neural network function
  X = X';
  y = y';

% predict
yhall = net_01(X);
perf_all_net_01 = perform(net_01,yhall,y);

% transpose back
X = X';
y = y';
yhall = yhall';

% reverse normalization back;
Xrv = X;
yrv = y;
for j=1:p
    Xrv(:,j)=Xrv(:,j)*std(Xdata(:,j));
    Xrv(:,j)=Xrv(:,j)+mean(Xdata(:,j));
end
yrv = yrv*std(ydata);
yrv = yrv + mean(ydata);

yhall = yhall*std(ydata);
yhall = yhall + mean(ydata);

% reverse normalization back
for j=1:p
pXts(:,j)=pXts(:,j)*std(Xdata(:,j));
pXts(:,j)=pXts(:,j)+mean(Xdata(:,j));
end

pyts = pyts*std(ydata);
pyts = pyts + mean(ydata);

pyhts = pyhts*std(ydata);
pyhts = pyhts + mean(ydata);

% plot in time-series
figure(9), clf,
cntr_year = 317:338; % period of years for a country
plot(num_data(cntr_year,1), ydata(cntr_year,1),'c-o');
hold on
% plot(num_data(cntr_year,1), yrv(cntr_year,1),'g-x');
plot(num_data(cntr_year,1), yhall(cntr_year,1),'m-*');
hold off
title('Prediction on the Data', 'FontSize', 14); 
xlabel('Year', 'FontSize', 14); 
ylabel('GDP per capita, PPP', 'FontSize', 14);
legend('Actual','Predicted')

%%%%%%%%%%%














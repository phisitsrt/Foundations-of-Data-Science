[N, p1] = size(indicator_data);
p = 8;
Y = [indicator_data(:,1:p1) ones(N,1)];
for j=1:p1
    Y(:,j)=Y(:,j)-mean(Y(:,j));
    Y(:,j)=Y(:,j)/std(Y(:,j));
end
f = imported_data.data(:,8);
%f = f - mean(f);
%f = f/std(f);
% Least squares regression as pseudo inverse
w = (Y'*Y)\Y'*f;
fh = Y*w;%prediction
part = 100;
gama_rng = linspace(0.01,10,part);
count_iNzero = zeros(part,2);
rnd = 1;
err_yhts_w2 = zeros(N,part);
%Sparse Regression
for rnd = 1:part
    
gama = gama_rng(rnd);
cvx_begin quiet
variable w2(p1+1);
minimize(norm(Y*w2 - f) + gama*norm(w2,1) );
cvx_end

Yhn = Y*w2;

err_yhts_w2(:,rnd) = Yhn - f;

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

figure(11), clf,
plot(gama_rng, mean(err_yhts_w2.^2).^(1/2),'mx-','LineWidth', 2),
title('Increasing Regularization', 'FontSize', 14)
xlabel('Gamma', 'FontSize', 14)
ylabel('Root Mean Squared Error', 'FontSize', 14)
grid on


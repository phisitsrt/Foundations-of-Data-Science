[N, p1] = size(indicator_data);
p = 8;
Y = [indicator_data(:,1:p1) ones(N,1)];
for j=1:p1
    Y(:,j)=Y(:,j)-mean(Y(:,j));
    Y(:,j)=Y(:,j)/std(Y(:,j));
end
f = imported_data.data(:,8);
f = f - mean(f);
f = f/std(f);
% Least squares regression as pseudo inverse
w = (Y'*Y)\Y'*f;
fh = Y*w;%prediction

gama = 0.2;%
cvx_begin quiet
   variable w2(p1+1);
   minimize (norm(Y*w2 - f) + gama*norm(w2,1));
cvx_end
fh2 = Y*w2;
[iNzero] = find(abs(w2) > 1e-5);
disp('Relevant variables');
disp(iNzero);

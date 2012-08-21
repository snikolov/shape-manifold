function [c,error]=lap_rls(X,L,Yl,Y,K,lambdaA,lambdaI)
global l m u

m=size(X,1);
l=size(Yl,1);
u=m-l;

c=lap_rls_train(X,L,Yl,K,lambdaA,lambdaI);
f=K*c;
if any(isnan(f))
  error=1;
else
  error=cverrForLambda(X,L,Y,K,lambdaA,lambdaI);
end

function c=lap_rls_train(X,L,Yl,K,lambdaA,lambdaI)
l=numel(Yl);
m=size(X,1);
u=m-l;
J=[diag(ones(l,1)), zeros(l,u); zeros(u,l), zeros(u,u)];
Ytrunc=[Yl;zeros(u,1)];
c=(J*K+lambdaA*l*eye(m)+lambdaI*(l^2/m^2)*L*K)\Ytrunc;

function cverr=cverrForLambda(X,L,Y,K,lambdaA,lambdaI)
global l u
% Do k-fold crossvalidation
folds=8;
cvp=cvpartition(numel(Y),'kfold',folds);
cverr=0;
Yl=Y(1:l);
for fold=1:folds
  itrain=cvp.training(fold);
  itest=cvp.test(fold);
  Xtrain=X(itrain,:);
  Xtest=X(itest,:);
  Yltrain=Yl(itrain(1:l));
  Ytest=Y(itest);
  Ltrain=L(itrain,itrain);
  K_test_train=K(itest,itrain);
  K_train_train=K(itrain,itrain);
  c=lap_rls_train(Xtrain,Ltrain,Yltrain,K_train_train,lambdaA,lambdaI);
  f=K_test_train*c;
  cverr=cverr+mean(abs(sign(f)-Ytest))/2;
end
cverr=cverr/folds;
   
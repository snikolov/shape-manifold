function [f,error,F1]=shape_lap_rls(X,L,Y,p_flip,p_labeled,mode)

PLOT=1;

% Split into training and test sets.
itest=rand(numel(Y),1)<0.25;
itrain=~itest;

Xtrain=X(itrain,:);
Ytrain=Y(itrain);
Xtest=X(itest,:);
Ytest=Y(itest);
Ltrain=L(itrain,itrain);

i_labeled=rand(numel(Ytrain),1)<p_labeled;
n_pos_labeled=sum(Ytrain>0);
n_neg_labeled=sum(Ytrain<=0);
if n_pos_labeled>n_neg_labeled
  p_pos_labeled=n_neg_labeled/n_pos_labeled;
  i_labeled(Ytrain>0)=i_labeled(Ytrain>0)&(rand(n_pos_labeled,1)<p_pos_labeled);
else
  p_neg_labeled=n_pos_labeled/n_neg_labeled;
  i_labeled(Ytrain<=0)=i_labeled(Ytrain<=0)&(rand(n_neg_labeled,1)<p_neg_labeled);
end

l=sum(i_labeled);
u=numel(Y)-l;
Ytrain=[Ytrain(i_labeled);Ytrain(~i_labeled)];
Xtrain=[Xtrain(i_labeled,:);Xtrain(~i_labeled,:)];
Ltrain=[Ltrain(i_labeled,i_labeled),Ltrain(i_labeled,~i_labeled); ...
    Ltrain(~i_labeled,i_labeled),Ltrain(~i_labeled,~i_labeled)];
Yltrain=Ytrain(1:l);
Yltrain=Yltrain.*(1-2*double(rand(l,1)<p_flip));

% Precompute the kernel matrix so we don't compute it in every iteration
% while optimizing lambdas.
K_train_train=kernel_mat(Xtrain,Xtrain);

[eigvecK,eigvalK]=eig(K_train_train);
lambda_max=eigvalK(end,end);
  
if strcmpi(mode,'unregularized')
  [c,error]=lap_rls(Xtrain,Ltrain,Yltrain,Ytrain,K_train_train,0,0);
elseif strcmpi(mode,'A_regularized')
  %lambdaAs=exp(linspace(0,3,25))-1;
  lambdaAs=linspace(0, lambda_max, 20);
  errors=zeros(numel(lambdaAs),1);
  min_error=Inf;
  best_lambdaA=[];
  for i=1:numel(lambdaAs)
    lambdaA=lambdaAs(i);
    [ci,error_i]=lap_rls(Xtrain,Ltrain,Yltrain,Ytrain,K_train_train,lambdaA,0);
    errors(i)=error_i;
    if error_i<min_error
      min_error=error_i;
      best_lambdaA=lambdaA;
      c=ci;
    end
  end
  error=min_error;
  if PLOT
    plot(errors)
    pause
  end
elseif strcmpi(mode,'AI_regularized')
  lambdaAs=linspace(0,lambda_max,6);
  lambdaIs=linspace(0,lambda_max,4);
  %lambdaAs=exp(linspace(0,1,5))-1;
  lambdaAs=lambdaAs(2:end);
  %lambdaIs=exp(linspace(0,2,5))-1;
  errors=zeros(numel(lambdaAs),numel(lambdaIs));
  min_error=Inf;
  best_lambdaA=[];
  best_lambdaI=[];
  for i=1:numel(lambdaAs)
    lambdaA=lambdaAs(i);
    for j=1:numel(lambdaIs)
      lambdaI=lambdaIs(j);
      [cij,error_ij]=lap_rls(Xtrain,Ltrain,Yltrain,Ytrain,K_train_train,lambdaA,lambdaI);
      errors(i,j)=error_ij;
      if error_ij<min_error
        min_error=error_ij;
        best_lambdaI=lambdaI;
        best_lambdaA=lambdaA;
        c=cij;
      end
    end
  end
  if PLOT
    imagesc(lambdaAs,lambdaIs,errors);
    colorbar
    pause;
  end
  error=min_error;
end

lambda_max
if exist('best_lambdaA', 'var')
  best_lambdaA
end
if exist('best_lambdaI', 'var')
  best_lambdaI
end
 

K_test_train=kernel_mat(Xtest,Xtrain);
f=K_test_train*c;
tp=sum((Ytest>0)&(f>0));
tn=sum((Ytest<0)&(f<0));
fp=sum((Ytest<=0)&(f>0));
fn=sum((Ytest>0)&(f<=0));
precision=tp/(tp+fp);
recall=tp/(tp+fn);
F1p=2*tp/(2*tp + fp + fn);
F1n=2*tn/(2*tn + fn + fp);
F1=0.5*(F1n+F1p);
PRINT=0;
if PRINT
  fprintf('Precision: %.4f\n',precision)
  fprintf('Recall: %.4f\n',recall)
  fprintf('F1 score (p): %.4f\nF1 score (n): %.4f\n',F1p,F1n);
  fprintf('Symmetric F1 score: %.4f\n',F1);
  fprintf('Accuracy: %.4f\n\n',1-error);
end

if PLOT
  [V,S_train]=princomp(Xtrain);
  [V,S_test]=princomp(Xtest);
  figure(346)
  % Unlabeled Training
  scatter(S_train(l+1:end,1),S_train(l+1:end,2),'ko','filled','SizeData',10);
  hold on;
  % Labeled Training
  lposi=logical([Yltrain>0;zeros(u,1)]);
  lnegi=logical([Yltrain<0;zeros(u,1)]);
  scatter(S_train(lposi,1),S_train(lposi,2),'b','filled','SizeData',65);
  scatter(S_train(lnegi,1),S_train(lnegi,2),'r','filled','SizeData',65);
  pause;
  % Test
  tpi=(Ytest>0)&(f>0);
  fpi=(Ytest<0)&(f>0);
  tni=(Ytest<0)&(f<=0);
  fni=(Ytest>0)&(f<=0);
  % True Positive
  scatter(S_test(tpi,1),S_test(tpi,2),'b','SizeData',25);
  % False Positive
  scatter(S_test(fpi,1),S_test(fpi,2),'mv','SizeData',25);
  % True Negative
  scatter(S_test(tni,1),S_test(tni,2),'r','SizeData',25);
  % False Negative
  scatter(S_test(fni,1),S_test(fni,2),'g<','SizeData',25);
  pause;
  hold off
end

function [f,error,F1]=shape_knn(X,Y,p_flip,p_labeled)

% Split into training and test sets.
itest=rand(numel(Y),1)<0.25;
itrain=~itest;

Xtrain=X(itrain,:);
Ytrain=Y(itrain);
Xtest=X(itest,:);
Ytest=Y(itest);

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

Yltrain=Ytrain(1:l);
Yltrain=Yltrain.*(1-2*double(rand(l,1)<p_flip));
Xltrain=Xtrain(1:l,:);

Yutrain=Ytrain(l+1:end,:);
Xutrain=Xtrain(l+1:end,:);

% Create validation splits.
% Go through validation splits and come up with best k.
folds=8;
min_error=Inf;
best_k=[];
for k=1:1:10
  cvp=cvpartition(numel(Ytrain),'kfold',folds);
  cverr=0;
  min_train_size = Inf;
  for fold=1:folds
    itrain = cvp.training(fold);
    min_train_size = min(sum(itrain(1:l)), min_train_size);
  end
  if k >= min_train_size
    continue
  end
  for fold=1:folds
    itrain=cvp.training(fold);
    itest=cvp.test(fold);
  
    Yltrain_train=Yltrain(itrain(1:l));
    Xltrain_train=Xltrain(itrain(1:l),:);
    
    Yutrain_test=Yutrain(itest(l+1:end));
    Xutrain_test=Xutrain(itest(l+1:end),:);

    fi=knnclassify(Xutrain_test,Xltrain_train,Yltrain_train,k);
    error_i=mean(fi~=Yutrain_test);
    cverr=cverr+error_i;
  end
  if cverr < min_error
    min_error = cverr;
    best_k = k;
  end
end

if isempty(best_k)
  best_k = 1;
end
% Compute error on test set using best K
f = knnclassify(Xtest, Xltrain, Yltrain, best_k);
error=mean(f~=Ytest);
F1 = 0;
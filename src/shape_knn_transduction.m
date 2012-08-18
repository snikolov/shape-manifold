function [f,error,F1]=shape_knn_transduction(X,Y,p_flip,p_labeled)

% Choose which points are labeled, and flip some of the labels.

i_labeled=rand(numel(Y),1)<p_labeled;
n_pos_labeled=sum(Y>0);
n_neg_labeled=sum(Y<=0);
if n_pos_labeled>n_neg_labeled
  p_pos_labeled=n_neg_labeled/n_pos_labeled;
  i_labeled(Y>0)=i_labeled(Y>0)&(rand(n_pos_labeled,1)<p_pos_labeled);
else
  p_neg_labeled=n_pos_labeled/n_neg_labeled;
  i_labeled(Y<=0)=i_labeled(Y<=0)&(rand(n_neg_labeled,1)<p_neg_labeled);
end

l=sum(i_labeled);
Y=[Y(i_labeled);Y(~i_labeled)];
X=[X(i_labeled,:);X(~i_labeled,:)];
Yl=Y(1:l);
Yl=Yl.*(1-2*double(rand(l,1)<p_flip));

ks=1:1:10;
min_error=Inf;
best_k=[];
for i=numel(ks)
  k=ks(i);
  fi=knnclassify(X(l+1:end,:),X(1:l,:),Yl,k);
  error_i=mean(abs(sign(fi)-Y(l+1:end)))/2;
  if error_i<min_error
    min_error=error_i;
    f=fi;
    best_k=k;
  end
end
tp=sum((Y(l+1:end)>0)&(f>0));
fp=sum((Y(l+1:end)<=0)&(f>0));
fn=sum((Y(l+1:end)>0)&(f<=0));
precision=tp/(tp+fp);
recall=tp/(tp+fn);
F1=2*tp/(2*tp + fp + fn);
error=min_error;
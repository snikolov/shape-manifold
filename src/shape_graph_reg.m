function [f,error,F1]=shape_graph_reg(X,L,Y,p_flip,p_labeled,mode,feature_type,setname1,setname2)

PLOT=0;
PRINT=0;

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

u=sum(~i_labeled);
l=sum(i_labeled);
Y=[Y(i_labeled);Y(~i_labeled)];
X=[X(i_labeled,:);X(~i_labeled,:)];
L=[L(i_labeled,i_labeled),L(i_labeled,~i_labeled);L(~i_labeled,i_labeled),L(~i_labeled,~i_labeled)];
Yl=Y(1:l);
Yl=Yl.*(1-2*double(rand(l,1)<p_flip));

if strcmpi(mode,'unregularized')
  f=transductive(X,L,Yl,mode);
  if any(isnan(f))
    error=1;
  else
    error=mean(abs(sign(f(l+1:end))-Y(l+1:end)))/2;
  end
elseif strcmpi(mode,'regularized')
  %lambdas=linspace(0,100,100);
  lambdas=exp(linspace(0,7,50))-1;
  lambda_errors=zeros(size(lambdas));
  best_lambda=0;
  min_error=Inf;
  for i=1:numel(lambdas)
    lambda=lambdas(i);
    fi=transductive(X,L,Yl,mode,lambda);
    if any(isnan(fi))
      error=1;
    else
      error=mean(abs(sign(fi(l+1:end))-Y(l+1:end)))/2;
    end
    lambda_errors(i)=error;
    if lambda_errors(i)<min_error
      min_error=lambda_errors(i);
      best_lambda=lambda;
      f=fi;
    end
  end
  error=min_error;
  if PRINT
    fprintf('Best lambda: %.4f\n',best_lambda);
  end
  if PLOT
    plot(lambdas,lambda_errors)
  end
end

  tp=sum((Y(l+1:end)>0)&(f(l+1:end)>0));
  tn=sum((Y(l+1:end)<=0)&(f(l+1:end)<0));
  fp=sum((Y(l+1:end)<=0)&(f(l+1:end)>0));
  fn=sum((Y(l+1:end)>0)&(f(l+1:end)<=0));
  precision=tp/(tp+fp);
  recall=tp/(tp+fn);
  %F1=2*(precision*recall)/(precision+recall);
  F1p=2*tp/(2*tp + fp + fn);
  F1n=2*tn/(2*tn + fn + fp);
  F1=0.5*(F1n+F1p);
  
  if PRINT
    fprintf('Precision: %.4f\n',precision)
    fprintf('Recall: %.4f\n',recall)
    fprintf('F1 score: %.4f\n',F1);
    fprintf('Accuracy: %.4f\n\n',1-error);
  end
 % Do PCA on data to visualize it.
    dims=2;
    if PLOT
      [V,S]=princomp(X);
      i_pos=f>0;
      i_neg=f<=0;
      i_pos_l=Yl>0;
      i_pos_l=logical([i_pos_l;zeros(u,1)]);
      i_neg_l=Yl<=0;
      i_neg_l=logical([i_neg_l;zeros(u,1)]);
      if dims==2
        scatter(S(i_pos_l,1),S(i_pos_l,2),'sb','filled','SizeData',20)
      elseif dims==3
        scatter3(S(i_pos_l,1),S(i_pos_l,2),S(i_pos_l,3),'sb','filled','SizeData',20)
      end
      %title(sprintf('p_{labeled}=%.3f, p_{flip}=%.3f, features=%s, error=%.3f, %s, (%s vs %s)', ... 
      %  p_labeled,p_flip,feature_type,error,mode,setname1,setname2));
      hold on;
      if dims==2
         scatter(S(i_neg_l,1),S(i_neg_l,2),'sr','filled','SizeData',20)
      elseif dims==3
         scatter3(S(i_neg_l,1),S(i_neg_l,2),S(i_neg_l,3),'sr','filled','SizeData',20)
      end
     
      pause
      if dims==2
        % True positives
        scatter(S(i_pos&(Y>0),1),S(i_pos&(Y>0),2),'b','LineWidth',1)
        % False positives
        scatter(S(i_pos&(Y<0),1),S(i_pos&(Y<0),2),'mv','LineWidth',1)
        % True negatives
        scatter(S(i_neg&(Y<0),1),S(i_neg&(Y<0),2),'r','LineWidth',1)
        % False negatives
        scatter(S(i_neg&(Y>0),1),S(i_neg&(Y>0),2),'g<','LineWidth',1)
      elseif dims==3
        scatter3(S(i_pos,1),S(i_pos,2),S(i_pos,3),'b','LineWidth',1)
        scatter3(S(i_neg,1),S(i_neg,2),S(i_neg,3),'r','LineWidth',1)
      end
      drawnow;
      hold off;
      pause
    end

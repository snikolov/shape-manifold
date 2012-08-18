function f=transductive(X,L,Y,mode,varargin)
if ~isempty(varargin)
  lambda=varargin{1};
end
m=size(X,1);
d=size(X,2);
l=size(Y,1);
u=m-l;
f=zeros(size(X,1),1);
if isempty(L)
  W=weights(X);
  D=diag(W*ones(m,1));
  L=D-W;
end
L_ll=L(1:l,1:l);
L_lu=L(1:l,l+1:m);
L_ul=L_lu';
L_uu=L(l+1:m,l+1:m);
fig_handle=[];
if strcmpi(mode,'regularized')
  J=[diag(ones(l,1)), zeros(l,u); zeros(u,l), zeros(u,u)];
  f=(L+lambda*J)\[Y;zeros(u,1)];
  fig_handle=102;
end
if strcmpi(mode,'unregularized') 
  f(1:l)=Y;
  f(l+1:m)=-L_uu\L_ul*Y;
  fig_handle=101;
end

PLOT=0;
if PLOT
  figure(fig_handle)
  i_pos=f>0;
  i_neg=f<=0;
  i_pos_l=Y>0;
  i_pos_l=logical([i_pos_l;zeros(u,1)]);
  i_neg_l=Y<=0;
  i_neg_l=logical([i_neg_l;zeros(u,1)]);
  scatter(X(i_pos_l,1),X(i_pos_l,2),'sb','filled')
  hold on;
  scatter(X(i_neg_l,1),X(i_neg_l,2),'sr','filled')
  pause
  scatter(X(i_pos,1),X(i_pos,2),'b')
  scatter(X(i_neg,1),X(i_neg,2),'r')
  hold off;
  pause
end

function W=weights(X)
D=squareform(pdist(X));
% Estimate sigma
k=10;
sigma=0;
for i=1:size(D,1)
  Dis=sort(D(i,:));
  sigma=sigma+sum(Dis(1:k));
end
sigma=sigma/(k*size(D,1));
W=exp(-D.^2/(2*sigma^2));
%W_max=max(W(:));
%for i=1:size(W,1)
%  [Wi,si]=sort(W(i,:),'descend');
%  for j=1:25
%    weight=W(i,si(j))/W_max;
%    figure(25)
%    line([X(i,1),X(j,1)],[X(i,2),X(j,2)],'Color',1-[weight,weight, ...
%    	    weight]);
%    fprintf('Weight from [%.3f,%.3f] to [%.3f,%.3f]: %.4f, %.4f\n',X(i,1),X(i,2),X(si(j),1),X(si(j),2),W(i,si(j)),weight)
%    pause;
%  end
%end

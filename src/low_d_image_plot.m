%low_d_image_plot

data1=load('../butterflies1.mat','data');
data2=load('../bugs.mat','data');
data1=data1.data.images;
data2=data2.data.images;
d=numel(data1{1});
N1=numel(data1);
N2=numel(data2);
X1=zeros(N1,d);
X2=zeros(N2,d);
Y1=ones(N1,1);
Y2=-ones(N2,1);
for i=1:N1
  X1(i,:)=reshape(data1{i},1,d);
end
for i=1:N2
  X2(i,:)=reshape(data2{i},1,d);
end
Y=[Y1;Y2];
X=[X1;X2];

% Do PCA on data to visualize it.
[V,W,L]=princomp(X);
figure(24)
i_pos=Y>0;
i_neg=Y<=0;
W=70*W;
scatter(W(i_pos,1),W(i_pos,2),'b')
hold on;
scatter(W(i_neg,1),W(i_neg,2),'r')
p_display=0.35;
for i=1:N1
  I=data1{i};
  [nr,nc]=size(I);
  nr=floor(nr);
  nc=floor(nc);
  if rand<p_display
    h=imagesc([W(i,1)+nr W(i,1)-nr],[W(i,2)+nc,W(i,2)-nc],I);
    set(h,'AlphaData',0.75);
    colormap(gray)
    pause;
  end
end
for i=1:N2
  I=data2{i};
  [nr,nc]=size(I);
  nr=floor(nr);
  nc=floor(nc);
  if rand<p_display
    h=imagesc([W(i+N1,1)+nr W(i+N1,1)-nr],[W(i+N1,2)+nc,W(i+N1,2)-nc],I);
    set(h,'AlphaData',0.75);
    colormap(gray)
    pause;
  end
end

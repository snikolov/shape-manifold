function d=hausdorff_vector(A,B)
s=sqrt(numel(A));
d=zeros(size(B,1),1);
for i=1:numel(d)
  d(i)=hausdorff_image(reshape(A,s,s),reshape(B(i,:),s,s));
end

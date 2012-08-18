function d=hausdorff_image(Ia,Ib)
% Takes two binary images A and B and computes the hausdorff distance
% between them.

[i,j]=ind2sub(size(Ia),find(Ia==true));
A=[i,j];
[i,j]=ind2sub(size(Ib),find(Ib==true));
B=[i,j];
d=hausdorff(A,B);

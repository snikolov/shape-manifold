% image montage

load '../heads_bal';
n = 5;
m = 5;
images = data.images(1:n*m);
[r,c] = size(images{1});
I = zeros(r,c,1,n*m);
for i=1:n*m
  I(:,:,1,i) = images{i};
end
montage(I,'Size',[n,m])


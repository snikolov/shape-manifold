function K=kernel_mat(Xa,Xb)
D=slmetric_pw(Xa', Xb', 'eucdist');
sigma=mean(D(:));
K=exp(-D.^2/(2*sigma^2));

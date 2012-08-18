function K=kernel_mat(Xa,Xb)
D=slmetric_pw(Xa', Xb', 'eucdist');
sigma=mean(D(:))/3;
K=exp(-D.^2/(2*sigma^2));

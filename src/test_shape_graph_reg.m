% Test shape graph regularization

setnames={'butterflies_bal','fish_bal','heads_bal','dogs_bal'};
p_flips=[0];
p_labeleds=[0.05,0.10,0.25];
feature_types={'image','sdf'};
modes={'unregularized','regularized'};
sigma_weights=linspace(0.05,0.75,5);

%setnames={'fish','butterflies'};
%p_flips=[0];
%p_labeleds=[0.35];
%feature_types={'image'};
%modes={'unregularized'};
%sigma_weights=linspace(0.05,0.5,5);

outf = fopen('../results/graph_reg.txt', 'w')

n_trials=8;
errors=zeros(numel(feature_types), ...
    numel(setnames), ...
    numel(setnames), ...
    numel(sigma_weights), ...
    numel(modes), ...
    numel(p_flips), ...
    numel(p_labeleds), ...
    n_trials);
F1s=zeros(size(errors));

for ifeatures=1:numel(feature_types)
  feature_type=feature_types{ifeatures};
  for j=1:numel(setnames)
    setname1=setnames{j};
    dataset1=load(['../',setname1,'.mat'],'data');
    for k=j+1:numel(setnames)
      setname2=setnames{k};
      %fprintf('%s vs %s | %s features\n',setname1,setname2,feature_type);
      dataset2=load(['../',setname2,'.mat'],'data');
      if strcmpi(feature_type,'image')
        data1=dataset1.data.images;
        data2=dataset2.data.images;
      elseif strcmpi(feature_type,'sdf')
        data1=dataset1.data.sdfs;
        data2=dataset2.data.sdfs;
      else
        fprintf('Feature type %s not supported! Try \"sdf\" or \"image\".',feature_type);
      end
      d=numel(data1{1});
      N1=numel(data1);
      N2=numel(data2);
      N=N1+N2;
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
      
      for isigma=1:numel(sigma_weights)
        sigma_weight=sigma_weights(isigma);
        % Precompute Laplacian
        D=squareform(pdist(X));
        n_neighbors=N-1;
        sigma=0;
        for ri=1:size(D,1)
          Dis=sort(D(ri,:));
          sigma=sigma+sum(Dis(2:n_neighbors+1));
        end
        % Mean distance between positives and negatives
        muX1=mean(X1,1);
        muX2=mean(X2,1);
        sigma=sigma_weight*sigma/(n_neighbors*size(D,1));
        W=exp(-D.^2/(2*sigma^2));
        D=diag(W*ones(N,1));
        L=D-W;
 
        for imode=1:numel(modes)
          mode=modes{imode};
          for ipflip=1:numel(p_flips)
            p_flip=p_flips(ipflip);
            for iplabeled=1:numel(p_labeleds)
              p_labeled=p_labeleds(iplabeled);
              
              rng('default');
              
              for itrial=1:n_trials
                [f,error,F1]=shape_graph_reg(X,L,Y,p_flip,p_labeled,mode,feature_type,setname1,setname2);
                errors(ifeatures,j,k,isigma,imode,ipflip,iplabeled,itrial)=error;
                errors(ifeatures,k,j,isigma,imode,ipflip,iplabeled,itrial)=error;
                F1s(ifeatures,j,k,isigma,imode,ipflip,iplabeled,itrial)=F1;
                F1s(ifeatures,k,j,isigma,imode,ipflip,iplabeled,itrial)=F1;
              end
              fprintf(outf, '%s\t%s\t%s\t%.4f\t%s\t%.4f\t%.4f\t%.4f\t%.4f\n', ...
                  setname1, setname2, feature_types{ifeatures}, sigma_weights(isigma), modes{imode}, ... 
                  p_flips(ipflip), p_labeleds(iplabeled), ...
                  1-mean(errors(ifeatures,j,k,isigma,imode,ipflip,iplabeled,:)), ...
                  std(errors(ifeatures,j,k,isigma,imode,ipflip,iplabeled,:)));
                  
              % pause;
              
  %             subplot(3,2,(j-1)*numel(p_labeled)+k-1);
  %             imagesc(p_flips,p_labeleds,reshape(errors(ifeatures,j,k,1,:,:), ...
  %                 numel(p_flips),numel(p_labeleds)))
  %             ylabel('p_{flip}')
  %             xlabel('p_{labeled}')
  %             colorbar
  %             set(gca,'units','points');
  %             drawnow
  %             subplot(3,2,(j-1)*numel(p_labeled)+k);
  %             imagesc(p_flips,p_labeleds,reshape(errors(ifeatures,j,k,2,:,:), ...
  %                 numel(p_flips),numel(p_labeleds)))
  %             ylabel('p_{flip}')
  %             xlabel('p_{labeled}')
  %             colorbar
  %             set(gca,'units','points');
  %             drawnow
            end
  %           figure(54)
  %           hold on
  %           plot(reshape(errors(ifeatures,j,k,imode,ipflip,:),numel(p_labeleds),1),'-ks','LineWidth',2);
  %           title(sprintf('%s features, %s and %s, %s, p_{flip}=%.3f', ... 
  %               feature_types{ifeatures},setnames{j},setnames{k}, ...
  %               modes{imode},p_flips(ipflip)))
  %           xlabel('p_{labeled}');
  %           ylabel('error');
  %           drawnow
          end
  %         hold off
        end
      end
    end
  end
end
save('../errors_reg.mat','errors','F1s','sigma_weights','feature_types','modes','p_flips','p_labeleds','setnames');
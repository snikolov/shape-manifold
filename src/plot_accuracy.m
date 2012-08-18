% plot_accuracy
load('../errors.mat');

for j=1:numel(setnames)
  setname1=setnames{j};
  for k=j+1:numel(setnames)
    setname2=setnames{k};
    for iplabeled=1:numel(p_labeleds)
      means=zeros(1,numel(p_flips));
      stdevs=zeros(1,numel(p_flips));
      for ipflip=1:numel(p_flips)
        e=errors(1,j,k,1,ipflip,iplabeled,:);
        e=reshape(e,1,numel(e));
        means(ipflip)=mean(e);
        stdevs(ipflip)=std(e);
      end
      errorbar(p_flips,means,stdevs,'-rv','LineWidth',2);
      title(sprintf('p_labeled=%.3f, unregularized',p_labeleds(iplabeled)));
      hold on;
      pause;
      
      means=zeros(1,numel(p_flips));
      stdevs=zeros(1,numel(p_flips));
      for ipflip=1:numel(p_flips)
        e=errors(1,j,k,2,ipflip,iplabeled,:);
        e=reshape(e,1,numel(e));
        means(ipflip)=mean(e);
        stdevs(ipflip)=std(e);
      end
      errorbar(p_flips,means,stdevs,'-bs','LineWidth',2);
      title(sprintf('p_labeled=%.3f, unregularized',p_labeleds(iplabeled)));
      hold on;
      pause;
    end
    
    hold off;
  end
end

% Write out latex tables

load '../errors_lap_rls_pf35.mat';

f=fopen('../error_shape_reg.txt','w');

fprintf(f,'\\begin{table}\n');
fprintf(f,'\\tiny\n');
fprintf(f,'\\begin{center}\n');
fprintf(f,'\\begin{tabular}{l|l|l|cc|cc|cc|}\n');
fprintf(f,'& & & \\multicolumn{6}{c}{Results} \\\\ \n');
fprintf(f,'& & & \\multicolumn{6}{c}{Results} \\\\ \n');
fprintf(f,'  & & & \\multicolumn{2}{|c|}{$\\sigma=0.1625 \\bar{d}$}\n');
fprintf(f,'       & \\multicolumn{2}{|c|}{$\\sigma=0.2750 \\bar{d}$}\n');
fprintf(f,'       & \\multicolumn{2}{|c|}{$\\sigma=0.3875 \\bar{d}$}\\\\ \n');
fprintf(f,'& & & RLS & LapRLS & RLS. & LapRLS & RLS & LapRLS\\\\ \\hline \n');

for iflip=1:numel(p_flips)
  p_flip=p_flips(iflip);
  for ilabel=1:numel(p_labeleds)
    p_labeled=p_labeleds(ilabel);
    for isetname1=1:numel(setnames)
      setname1=setnames{isetname1};
      for isetname2=isetname1+1:numel(setnames)
        setname2=setnames{isetname2};
        fprintf(f,'\\multirow{4}{*}{%s vs. %s}\n',setname1,setname2);
        for ifeatures=1:numel(feature_types)
          feature_type=feature_types{ifeatures};
          % Accuracy
          fprintf(f,'%% errors: %s|%s feat:%s,pf:%.4f,pl:%.4f\n', ...
             setname1,setname2,feature_type,p_flip,p_labeled);
          fprintf(f,'& \\multirow{2}{*}{%s} & \\multirow{1}{*}{Accuracy}',feature_type);
          for isigma=1:numel(sigma_weights)
            sigma_weight=sigma_weights(isigma);
            for imode=1:numel(modes)
              mode=modes{imode};
              mu=1-mean(errors(ifeatures,isetname1,isetname2,isigma,imode,iflip,ilabel,:));
              stdev=std(errors(ifeatures,isetname1,isetname2,isigma,imode,iflip,ilabel,:));
              fprintf(f,'& %.2f$\\pm$%.2f',mu,stdev);
            end
          end
          fprintf(f,'\\\\ \n');
          % F1 score
          fprintf(f,'%% F1s: %s|%s feat:%s,pf:%.4f,pl:%.4f\n', ...
            setname1,setname2,feature_type,p_flip,p_labeled);
          fprintf(f,'& & \\multirow{1}{*}{F1}');
          for isigma=1:numel(sigma_weights)
            sigma_weight=sigma_weights(isigma);
            for imode=1:numel(modes)
              mode=modes{imode};
              mu=mean(F1s(ifeatures,isetname1,isetname2,isigma,imode,iflip,ilabel,:));
              stdev=std(F1s(ifeatures,isetname1,isetname2,isigma,imode,iflip,ilabel,:));
              fprintf(f,'& %.2f$\\pm$%.2f',mu,stdev);
            end
          end
          fprintf(f,'\\\\ \\cline{2-9} \n\n');
        end
      end
    end
  end
end
        
fprintf(f,'\\end{tabular}\n');
fprintf(f,'\\end{center}\n');
fprintf(f,'\\end{table}\n');

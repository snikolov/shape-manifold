function load_and_normalize(dataset_dir)

directories=dir(['../',dataset_dir]);
I={};
for j=3:numel(directories)
  files=dir(['../',dataset_dir,'/',directories(j).name]);
  % fprintf('%s\n',directories(j).name);
  for i=3:numel(files)
    % fprintf('%s\n',files(i).name);
    I{j-2,i-2}=imread(['../',dataset_dir,'/',directories(j).name, ...
        '/',files(i).name]);
  end
end

% Get max height and width.
% Determine center of mass of each image.
maxw=0;
maxh=0;
centroids={};
% orientations={};
for j=1:size(I,1)
  N=sum(1-cellfun(@isempty,I(j,:)));
  for i=1:N
    [n,m]=size(I{j,i});
    if n>maxh
      maxh=n;
    end
    if m>maxw
      maxw=m;
    end
    image_stats=regionprops(I{j,i},'Centroid','Orientation');
    centroids{j,i}=image_stats.Centroid;
    % orientations{i}=image_stats.Orientation;
  end
end

s=max(maxh,maxw);
% Center each image on a blank image of size max(maxh,maxw).
for j=1:size(I,1)
  N=sum(1-cellfun(@isempty,I(j,:)));
  for i=1:N
    centroid=centroids{j,i};
    cc=floor(centroid(1));
    cr=floor(centroid(2));
    fs2=floor(s/2);
    [n,m]=size(I{j,i});
    left=max(fs2-cc+1,1);
    right=min(fs2-cc+m,s);
    up=max(fs2-cr+1,1);
    down=min(fs2-cr+n,s);
    Ic=zeros(s,s);
    mcrop=right-left+1;
    ncrop=down-up+1;
    Ic(up:down,left:right)=I{j,i}(1:ncrop,1:mcrop);
    Ic=imresize(Ic,0.3)>0.1;
    I{j,i}=Ic;
    PLOT=0;
    if PLOT
      if (rand<0.75)
        imagesc(Ic);
        title(sprintf('%s',directories(j+2).name))
        drawnow;
        pause;
      end
    end
  end
end

% Save out each dataset
for j=1:size(I,1)
  N=sum(1-cellfun(@isempty,I(j,:)));
  data=struct;
  data.images=I(j,1:N);
  data.sdfs=cellfun(@mask2phi,I(j,1:N),'UniformOutput',0);
  save(['../',directories(j+2).name,'.mat'],'data');
end


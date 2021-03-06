%% MSCR distances computation
hh = waitbar(0,'Image features computation...');
for i=1:length(Blobs)
    
    %%---- MSE analysis
        mser    =   Blobs(i); 
        A = permute(mser.pvec, [3,2,1]);
        C = applycform(A, reg);
        colour = permute(C,[3,2,1]);
                        
        dataf(i).Mmvec=mser.mvec;
        dataf(i).Mpvec=colour;  

   
    waitbar(i/n_img,hh);

end
close(hh);


hh = waitbar(0,'Distances computation MSCR...');
for i = 1:length(dataf)
	
	Mmvec{1} = dataf(i).Mmvec(3,:);
	Mpvec{1} = dataf(i).Mpvec;
	
	num(1)=size(Mmvec{1},2);
	
	dist_y_n	= cell(length(permit_inds),1);
	dist_color_n= cell(length(permit_inds),1);
	
	for j = 1:length(dataf)
		
		if i == j
			
			final_dist_y(i,j)		= 0;
			final_dist_color(i,j)	= 0;
		else
			Mmvec{2} = dataf(j).Mmvec(3,:);
			Mpvec{2} = dataf(j).Mpvec;
			
			num(2)= size(Mmvec{2},2); %length(Mindeces{2});
			[thrash,max_ind(i,j)]= max([num(1),num(2)]);
			max_i = mod(max_ind(i,j),2)+1;%max_ind;
			min_i = max_ind(i,j);%mod(max_ind,2)+1;
			max_info = num(max_i);
			min_info = num(min_i);
			
			dist_y{j} = 1000*ones(min_info, max_info);
			dist_color{j} = 1000*ones(min_info, max_info);
			
			% distanze tutti i blob di i con tutti i blob di j
			for k=1:max_info
				for h=1:min_info
					
					dist_y{j}(h,k) = abs(Mmvec{max_i}(k)-Mmvec{min_i}(h));
					dist_color{j}(h,k) = sqrt(sum((Mpvec{max_i}(:,k)-Mpvec{min_i}(:,h)).^2));
					
				end
			end
			
			
			%% check outliers
			
			ref_y = min(dist_y{j}); me_ref_y = mean(ref_y); std_ref_y = std(ref_y);
			ref_color = min(dist_color{j}); me_ref_color = mean(ref_color); std_ref_color = std(ref_color);
			good = find((ref_y<(me_ref_y+3.5*std_ref_y))&(ref_color<(me_ref_color+3.5*std_ref_color)));
			
            if isempty(good)
                good = 1:max_info;
            end
            
			max_useful_info = length(good);
			dist_y2 = dist_y{j}(:,good);
			dist_color2 = dist_color{j}(:,good);
			
			%%normalize
			dist_y_n{j} = dist_y{j}./max(dist_y2(:));
			dist_color_n{j} = dist_color{j}./max(dist_color2(:));
			
			%%distance computation
			totdist_n = ( pyy*dist_y_n{j}(:,good)  + pcc*dist_color_n{j}(:,good) ) ;
			
			%%Minimization
			[min_dist,matching] = min(totdist_n);
			
			useful_i = sub2ind(size(totdist_n),[matching]',[1:max_useful_info]');
			final_dist_y(i,j)  = sum(dist_y2(useful_i))/max_useful_info;
			final_dist_color(i,j) = sum(dist_color2(useful_i))/max_useful_info;
		end
	end
	waitbar(i*j/length(dataf)^2,hh);
	clear dist_y;
	clear dist_color;
	clear dist_color_n;
	clear dist_y_n;
	
end
close(hh);


for i=1:length(dataf)
	final_dist_y(i,:) =  final_dist_y(i,:)./max(final_dist_y(i,:));
	final_dist_color(i,:) = final_dist_color(i,:)./max(final_dist_color(i,:));
	final_mscr_dist(i,:) = (pyy*final_dist_y(i,:) +  pcc*final_dist_color(i,:) ); % +  final_dist_hist(i,:);
    
end



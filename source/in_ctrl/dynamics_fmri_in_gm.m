%%========================================
%%========================================
%%
%% Keith Bush, PhD (2018)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%%========================================
%%========================================

%% Load in path data
load('proj.mat');

%% ----------------------------------------
%% Set-up Directory Structure for fMRI betas
if(proj.flag.clean_build)
    disp(['Removing ',proj.path.in_ctrl]);
    eval(['! rm -rf ',proj.path.in_ctrl]);
    disp(['Creating ',proj.path.in_ctrl]);
    eval(['! mkdir ',proj.path.in_ctrl]);
end

%% ----------------------------------------
%% Load labels;
v_label = load([proj.path.trg,'stim_v_labs.txt']);
a_label = load([proj.path.trg,'stim_a_labs.txt']);
label_id = load([proj.path.trg_in,'stim_ids.txt']); %note change
v_score = load([proj.path.trg,'stim_v_scores.txt']);
a_score = load([proj.path.trg,'stim_a_scores.txt']);

%% ----------------------------------------
%% load subjs
subjs = load_subjs(proj);

%% ----------------------------------------
%% Transform beta-series into affect series {v,a}
for i = 1:numel(subjs)

    %% extract subject info
    subj_study = subjs{i}.study;
    name = subjs{i}.name;
    id = subjs{i}.id;

    %% Load gray matter mask 
    gm_nii = load_nii([proj.path.gm_mask,subj_study,'.',name,'.gm.nii']);
    mask = double(gm_nii.img);
    brain_size=size(mask);
    mask = reshape(mask,brain_size(1)*brain_size(2)*brain_size(3),1);
    in_brain=find(mask==1);  

    %% Load beta-series
    path = [proj.path.fmri_in_beta,subj_study,'_',name,'_lss.nii'];
    base_nii = load_nii(path);
    brain_size = size(base_nii.img);

    %% Vectorize the base image
    base_img = vec_img_2d_nii(base_nii);
    base_img = reshape(base_img,brain_size(1)*brain_size(2)*brain_size(3),brain_size(4));

    %% Concatenate the MASKED base image
    subj_img = base_img(in_brain,:)';

    %% Concatenate all label/subj identifiers
    subj_id = [repmat(id,numel(label_id),1)];
    subj_i = [repmat(i,numel(label_id),1)];

    %% Perform quality
    qlty = check_gm_img_qlty(subj_img);

    if(qlty.ok)

        %% Initialize the prediction structure of this subject
        prds = struct();
        prds.v_hd = zeros(numel(label_id),1);
        prds.a_hd = zeros(numel(label_id),1);

        try

            % debug
            disp([subj_study,'_',name]);

            %% Load SVM models
            load([proj.path.mvpa_fmri_ex_gm_cls,subj_study,'_',name,'_v_model.mat']);
            load([proj.path.mvpa_fmri_ex_gm_cls,subj_study,'_',name,'_a_model.mat']);
            
            %% ----------------------------------------
            %% predict IN task using EX-based models
            for j=1:numel(label_id)
                
                %% valence
                [tst_predict,hd] = predict(v_model,subj_img(j,:));
                prds.v_hd(j) = hd(2);
                
                %% predict
                [tst_predict,hd] = predict(a_model,subj_img(j,:));
                prds.a_hd(j) = hd(2);
                
            end
            
            %% ----------------------------------------
            %% decompose predicted trajectories (& derivs)

            %% valence
            prds.v_dcmp = decompose_in(proj,label_id,prds.v_hd);

            %% arousal
            prds.a_dcmp = decompose_in(proj,label_id,prds.a_hd);

            disp('   -success');

            % % debug
            % figure(99)
            % plot(1:7,prds.v_dcmp.h(1,:));
            % hold on;
            % plot(1:7,prds.v_dcmp.err(1,:));
            % plot(2:6,prds.v_dcmp.dh(1,:));
            % plot(3:5,prds.v_dcmp.d2h(1,:));
            % hold off;              
            % drawnow
            
        catch
            % do nothing
        end

        %% Save out prediction structure
        save([proj.path.in_ctrl,subj_study,'_',name,'_prds.mat'],'prds');

    end

end

% figure(1);
% %%
% %% Plots control (stim versus mean feel)
% %%
% 
% set(gcf,'color','w');
% subplot(1,2,1);
% v_m_all = [];
% for i=1:numel(subjs)
% 
% 
%     scatter(v_stim(:,i),v_mu_ctrl(:,i));
%     hold on;
%     [b stat] = robustfit(v_stim(:,i),v_mu_ctrl(:,i));
%     v_m_all = [v_m_all,b(2)];
%     plot(sort(v_stim(:,i)),sort(v_stim(:,i))*b(2)+b(1));
% end
% xlim([-3,3]);
% ylim([-3,3]);
% hold off;
% 
% subplot(1,2,2);
% a_m_all = [];
% for i=1:numel(subjs)
%     scatter(a_stim(:,i),a_mu_ctrl(:,i));
%     hold on;
%     [b stat] = robustfit(a_stim(:,i),a_mu_ctrl(:,i));
%     a_m_all = [a_m_all,b(2)];
%     plot(sort(a_stim(:,i)),sort(a_stim(:,i))*b(2)+b(1));
% end
% xlim([-3,3]);
% ylim([-3,3]);
% hold off;
% 
% 
% % figure(2);
% %%
% %% Plots individual control trajs {V,A}
% %%
% subj_id = 1;
% set(gcf,'color','w');
% subplot(1,2,1);
% for j=subj_id:subj_id
%     v_feel_tmp = reshape(v_feel(:,j),Nfeel,numel(feel_ids)/Nfeel)';
%     v_all = [];    
%     for i=1:numel(in_ids)
%         v_traj = [v_stim(i,j)-v_stim(i,j),v_stim(i,j)-v_cue(i,j), ...
%                   V_stim(i,j)-v_feel_tmp(i,:),v_stim(i,j)-v_rest(i,j)];
% 
%         v_all = [v_all;v_traj];
%         plot(v_traj);
%         hold on;
%     end
%     plot(mean(v_all,1),'LineWidth',3);     
% end
% ylim([-5,5]);
% 
% subplot(1,2,2);
% for j=subj_id:subj_id
%     a_feel_tmp = reshape(a_feel(:,j),Nfeel,numel(feel_ids)/Nfeel)';
%     a_all = [];    
%     for i=1:numel(in_ids)
%         a_traj = [a_stim(i,j)-a_stim(i,j),a_stim(i,j)-a_cue(i,j), ...
%                   a_stim(i,j)-a_feel_tmp(i,:),a_stim(i,j)-a_rest(i,j)];
%         a_all = [a_all;a_traj];
%         plot(a_traj);
%         hold on;
%     end
%     plot(mean(a_all,1),'LineWidth',3);             
% end
% ylim([-5,5])
% 
% 
% figure(3);
% %%
% %% Plots individual mean and group mean control {V,A}
% %%
% set(gcf,'color','w');
% 
% sbj_nan = 12; %% THIS SUBJ HAS NAN IN RESULTS
% 
% subplot(1,2,1);
% v_grp_all = [];
% 
% for j=1:numel(subjs)
% 
%     if(j~=sbj_nan)
%         v_feel_tmp = reshape(v_feel(:,j),Nfeel,numel(feel_ids)/Nfeel)';
%         v_all = [];    
% 
%         for i=1:numel(in_ids)
%             v_traj = [v_stim(i,j)-v_stim(i,j),v_stim(i,j)-v_cue(i,j), ...
%                       v_stim(i,j)-v_feel_tmp(i,:),v_stim(i,j)-v_rest(i,j)];
%             
%             v_all = [v_all;v_traj];
%         end
%         v_grp_all = [v_grp_all;median(v_all,1)];
%         plot(median(v_all,1),'LineWidth',1);     
%         hold on;
%     end
% end
% plot(median(v_grp_all),'LineWidth',3)
% ylim([-1.5,1.5]);
% 
% subplot(1,2,2);
% a_grp_all = [];
% for j=1:numel(subjs)
%     if(j~=sbj_nan)
%         a_feel_tmp = reshape(a_feel(:,j),Nfeel,numel(feel_ids)/Nfeel)';
%         a_all = [];    
%         for i=1:numel(in_ids)
%             a_traj = [a_stim(i,j)-a_stim(i,j),a_stim(i,j)-a_cue(i,j), ...
%                       a_stim(i,j)-a_feel_tmp(i,:),a_stim(i,j)-a_rest(i,j)];
%             
%             a_all = [a_all;a_traj];
%         end
%         a_grp_all = [a_grp_all; median(a_all,1)];
%         plot(median(a_all,1),'LineWidth',1);     
%         hold on;
%     end
% end
% plot(median(a_grp_all),'LineWidth',3)
% ylim([-1.5,1.5]);
% 
% 
% figure(4)
% set(gcf,'color','w');
% 
% subplot(1,2,1);
% for j=1:numel(subjs)
% 
%     v_err_tmp = v_err(:,3:5,j);
%     v_2dh_tmp = v_2dh(:,:,j);
% 
%     x=[];
%     y=[];
% 
%     for k=1:size(v_2dh_tmp,1)
% 
%         %%Plot individual relationships
%         scatter(-v_err_tmp(k,:),v_2dh_tmp(k,:));
%         hold on;
% 
%         %%Combine data
%         x = [x,-v_err_tmp(k,:)];
%         y = [y,v_2dh_tmp(k,:)];
%         
%     end
% 
%     %%Fit and plot
%     [b stat] = robustfit(x,y);
%     plot(sort(x),b(2)*sort(x)+b(1));
%     xlim([-4,4]);
%     ylim([-2,2]);
%     
% end
% 
% subplot(1,2,2);
% for j=1:numel(subjs)
% 
%     a_err_tmp = a_err(:,3:5,j);
%     a_2dh_tmp = a_2dh(:,:,j);
% 
%     x=[];
%     y=[];
% 
%     for k=1:size(v_2dh_tmp,1)
% 
%         %%Plot individual relationships
%         scatter(-a_err_tmp(k,:),a_2dh_tmp(k,:));
%         hold on;
% 
%         %%Combine data
%         x = [x,-a_err_tmp(k,:)];
%         y = [y,a_2dh_tmp(k,:)];
%         
%     end
% 
%     %%Fit and plot
%     [b stat] = robustfit(x,y);
%     plot(sort(x),b(2)*sort(x)+b(1));
%     xlim([-4,4]);
%     ylim([-2,2]);
% 
% end




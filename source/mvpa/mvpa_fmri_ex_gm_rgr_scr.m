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

%% Initialize log section
logger(['************************************************'],proj.path.logfile);
logger(['Intra-subject LOOCV MVPA RGR GM Features -> SCRs'],proj.path.logfile);
logger(['************************************************'],proj.path.logfile);

%% Set-up Directory Structure for fMRI betas
if(proj.flag.clean_build)
    disp(['Removing ',proj.path.mvpa_fmri_ex_gm_rgr_scr]);
    eval(['! rm -rf ',proj.path.mvpa_fmri_ex_gm_rgr_scr]);
    disp(['Creating ',proj.path.mvpa_fmri_ex_gm_rgr_scr]);
    eval(['! mkdir ',proj.path.mvpa_fmri_ex_gm_rgr_scr]);
end

%% ----------------------------------------
%% Load labels;
label_id = load([proj.path.trg,'stim_ids.txt']);
v_score = load([proj.path.trg,'stim_v_scores.txt']);
a_score = load([proj.path.trg,'stim_a_scores.txt']);

%% ----------------------------------------
%% load subjs
subjs = load_subjs(proj);

%% ----------------------------------------
%% iterate over study subjects
for i = 1:numel(subjs)

    %% extract subject info
    subj_study = subjs{i}.study;
    name = subjs{i}.name;
    id = subjs{i}.id;

    %% debug
    logger([subj_study,':',name],proj.path.logfile);

    %% Load gray matter mask 
    gm_nii = load_nii([proj.path.gm_mask,subj_study,'.',name,'.gm.nii']);
    mask = double(gm_nii.img);
    brain_size=size(mask);
    mask = reshape(mask,brain_size(1)*brain_size(2)*brain_size(3),1);
    in_brain=find(mask==1);  

    %% Load beta-series
    base_nii = load_nii([proj.path.fmri_ex_beta,subj_study,'_',name,'_lss.nii']);
    brain_size = size(base_nii.img);
    
    %% Vectorize the base image
    base_img = vec_img_2d_nii(base_nii);
    base_img = reshape(base_img,brain_size(1)*brain_size(2)*brain_size(3),brain_size(4));

    %% Concatenate the MASKED base image
    all_img = base_img(in_brain,:)';
    
    %% Concatenate all label/subj identifiers
    subj_id = repmat(id,numel(v_label),1);
    subj_i = repmat(i,numel(v_label),1);
    
    %% Subselect extrinsic data
    ex_id = find(label_id==proj.param.ex_id);
    ex_img = all_img(ex_id,:);
    %    ex_subj_id = subj_id(ex_id,1);
    %    ex_v_label = v_label(ex_id,1);
    %    ex_a_label = a_label(ex_id,1);
    
    %% Peform quality check of generated features
    qlty = check_gm_img_qlty(ex_img);

    if(qlty.ok)

        %% ----------------------------------------
        %% Train HRV
        
        %% Load HRV values
        load([proj.path.scr_beta,subj_study,'_',name,'_ex_betas.mat']);

        %%Change name to handle missing HRV
        hrv_ex_img = ex_img;
        hrv_ex_betas = [ex_betas.ibi1;ex_betas.ibi2];
        
        %%Adjust training data to handle mising HRV
        if(isempty(ex_betas.ibi1)
            hrv_ex_img = ex_img(46:90,:); 
        end
        
        if(isempty(ex_betas.ibi2)
            hrv_ex_img = ex_img(1:45,:);  
        end

        %% ****************************************
        %% Remove hardcoding of the indices covered
        %% by runs 1 and 2 of the extrinsic stimuli
        %%
        %% TICKET
        %% ****************************************
        
        %% Fit model
        hrv_model = fitrsvm(hrv_ex_img,hrv_ex_betas,'KernelFunction',proj.param.mvpa_kernel);

        %% Save model
        save([proj.path.mvpa_frmi_ex_gm_rgr_scr,subj_study,'_',name,'_ex_gm_rgr_scr_model.mat']);

    end

end

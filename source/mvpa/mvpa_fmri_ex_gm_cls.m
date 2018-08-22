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
logger(['Intra-subject LOOCV MVPA of Gray Matter Features'],proj.path.logfile);
logger(['************************************************'],proj.path.logfile);

%% Set-up Directory Structure for fMRI betas
if(proj.flag.clean_build)
    disp(['Removing ',proj.path.mvpa.fmri_ex_gm_cls]);
    eval(['! rm -rf ',proj.path.mvpa.fmri_ex_gm_cls]);
    disp(['Creating ',proj.path.mvpa.fmri_ex_gm_cls]);
    eval(['! mkdir ',proj.path.mvpa.fmri_ex_gm_cls]);
end

%% ----------------------------------------
%% Load labels;
v_label = load([proj.path.trg.ex,'stim_v_labs.txt']);
a_label = load([proj.path.trg.ex,'stim_a_labs.txt']);
label_id = load([proj.path.trg.ex,'stim_ids.txt']);
v_score = load([proj.path.trg.ex,'stim_v_scores.txt']);
a_score = load([proj.path.trg.ex,'stim_a_scores.txt']);

%% ----------------------------------------
%% load subjs
subjs = load_subjs(proj);

%% ----------------------------------------
%% allocate storage
all_v_cls_acc = [];
all_a_cls_acc = [];

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
    gm_nii = load_nii([proj.path.mri.gm_mask,subj_study,'.',name,'.gm.nii']);
    mask = double(gm_nii.img);
    brain_size=size(mask);
    mask = reshape(mask,brain_size(1)*brain_size(2)*brain_size(3),1);
    in_brain=find(mask==1);  

    %% Load beta-series
    base_nii = load_nii([proj.path.betas.fmri_ex_beta,subj_study,'_',name,'_lss.nii']);
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
    ex_id = find(label_id==proj.param.trg.ex_id);
    ex_img = all_img(ex_id,:);
    ex_subj_id = subj_id(ex_id,1);
    ex_v_label = v_label(ex_id,1);
    ex_a_label = a_label(ex_id,1);

    %% Peform quality check of generated features
    qlty = check_gm_img_qlty(ex_img);

    if(qlty.ok)

        %% Initialize the prediction structure of this subject
        prds = struct();
        prds.v_cls_acc = [];
        prds.v_cls_hd = [];
        prds.a_cls_acc = [];
        prds.a_cls_hd = [];
        
        %% ----------------------------------------
        %% LOOCV extrinsic VALENCE examples
        for j=1:proj.param.mvpa.n_resamp
            
            %% Fit the data space
            [~,~,v_tst_hd,~,v_cls_stats] = classify_loocv(ex_img, ...
                                                          ex_v_label,ex_subj_id,id, proj.param.mvpa.kernel);
            
            %% Store results
            prds.v_cls_acc = [prds.v_cls_acc;cell2mat(v_cls_stats.tst_acc)];
            prds.v_cls_hd = [prds.v_cls_hd;v_tst_hd'];
            
        end

        % debug
        all_v_cls_acc = [all_v_cls_acc;mean(mean(prds.v_cls_acc,1))];
        logger(['  v acc: ',num2str(mean(mean(prds.v_cls_acc,2)))],proj.path.logfile);

        %% ----------------------------------------
        %% Construct & save a representative VALENCE model

        %% Balance positive and negative VALENCE examples
        v_pos_ids = find(ex_v_label==1);
        v_neg_ids = find(ex_v_label==-1);
        Npos = numel(v_pos_ids);
        Nneg = numel(v_neg_ids);
        
        if(Npos >= Nneg)
            Nsample = Nneg;
        else
            Nsample = Npos;
        end
        
        %% Randomly re-order and combined samples
        rnd_v_pos_ids = v_pos_ids(randsample(1:numel(v_pos_ids),Nsample));
        rnd_v_neg_ids = v_neg_ids(randsample(1:numel(v_neg_ids),Nsample));
        rnd_v_cmb_ids = [rnd_v_pos_ids,rnd_v_neg_ids];
        
        %% Fit classifier
        v_model = fitcsvm(ex_img(rnd_v_cmb_ids,:),ex_v_label(rnd_v_cmb_ids,1), ...
                          'KernelFunction',proj.param.mvpa.kernel);
        save([proj.path.mvpa.fmri_ex_gm_cls,subj_study,'_',name,'_v_model.mat'],'v_model');

        %% ----------------------------------------
        %% Classify extrinsic AROUSAL examples
        for j=1:proj.param.mvpa.n_resamp

            %% Fit the data space            
            [~,~,a_tst_hd,~,a_cls_stats] = classify_loocv(ex_img, ...
                                                          ex_a_label,ex_subj_id,id, proj.param.mvpa.kernel);
            
            %% Store results
            prds.a_cls_acc = [prds.a_cls_acc;cell2mat(a_cls_stats.tst_acc)];
            prds.a_cls_hd = [prds.a_cls_hd;a_tst_hd'];
            
        end

        %% ----------------------------------------
        %% Save out results
        save([proj.path.mvpa.fmri_ex_gm_cls,subj_study,'_',name,'_prds.mat'],'prds');

        % debug
        all_a_cls_acc = [all_a_cls_acc;mean(mean(prds.a_cls_acc,1))];
        logger(['  a acc: ',num2str(mean(mean(prds.a_cls_acc,2)))],proj.path.logfile);

        %% ----------------------------------------
        %% Construct & save a representative AROUSAL model

        %% Balance positive and negative VALENCE examples
        a_pos_ids = find(ex_a_label==1);
        a_neg_ids = find(ex_a_label==-1);
        Npos = numel(a_pos_ids);
        Nneg = numel(a_neg_ids);
        
        if(Npos >= Nneg)
            Nsample = Nneg;
        else
            Nsample = Npos;
        end
        
        %% Randomly re-order and combined samples
        rnd_a_pos_ids = a_pos_ids(randsample(1:numel(a_pos_ids),Nsample));
        rnd_a_neg_ids = a_neg_ids(randsample(1:numel(a_neg_ids),Nsample));
        rnd_a_cmb_ids = [rnd_a_pos_ids,rnd_a_neg_ids];
        
        %% Fit classifier
        a_model = fitcsvm(ex_img(rnd_a_cmb_ids,:),ex_a_label(rnd_a_cmb_ids,1), ...
                          'KernelFunction',proj.param.mvpa.kernel);
        save([proj.path.mvpa.fmri_ex_gm_cls,subj_study,'_',name,'_a_model.mat'],'a_model');

    end

end

% log summary results
[h p ci stat] = ttest(all_v_cls_acc);
logger(['grp v acc ci=[',num2str(ci(1)),',',num2str(ci(2)),['], ' ...
                    'p='],num2str(p)],proj.path.logfile);

[h p ci stat] = ttest(all_a_cls_acc);
logger(['grp a acc ci=[',num2str(ci(1)),',',num2str(ci(2)),['], ' ...
                    'p='],num2str(p)],proj.path.logfile);

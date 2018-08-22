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

%% Set-up Directory Structure for SCR
if(proj.flag.clean_build)
    disp(['Removing ',proj.path.physio.scr_clean]);
    eval(['! rm -rf ',proj.path.physio.scr_clean]);
    disp(['Creating ',proj.path.physio.scr_clean]);
    eval(['! mkdir ',proj.path.physio.scr_clean]);
end

%% Create the subjects to be analyzed
subjs = load_subjs(proj);
disp(['Processing SCR of ',num2str(numel(subjs)),' subjects']);

for i=1:numel(subjs)

    %% extract subject info
    subj_study = subjs{i}.study;
    subj_id = subjs{i}.id;
    name = subjs{i}.name;

    %% debug
    disp([subj_study,':',name]);

    %% Define input/outputs paths
    in_path = [proj.path.raw_data,subj_study,'/',proj.path.raw_physio,'/'];
    out_path = [proj.path.physio.scr_clean];

    %% ----------------------------------------
    %% Build Identify 1 SCR
    %% load scr
    try
        path = [in_path,subj_study,'_',name,'/',subj_study,'_',name,'_',proj.path.task.name_id1,'.mat'];
        physio_raw = load(path);
        
        %% process scr
        n_trs = proj.param.mri.n_trs_id1;
        scr = scr_preproc(proj,n_trs,physio_raw.data);
        
        %% save scr
        save([out_path,subj_study,'_',name,'_',proj.path.task.name_id1,'.mat'],'scr');

    catch
        disp(['Processing Error: SCR of Identify run 1: ',path]);
    end

    %% ----------------------------------------
    %% Build Identify 2 SCR
    try
        path = [in_path,subj_study,'_',name,'/',subj_study,'_',name,'_',proj.path.task.name_id2,'.mat'];
        physio_raw = load(path);
        
        %% process scr
        n_trs = proj.param.mri.n_trs_id2;
        scr = scr_preproc(proj,n_trs,physio_raw.data);
        
        %% save scr
        save([out_path,subj_study,'_',name,'_',proj.path.task.name_id2,'.mat'],'scr');
    catch
        disp(['Processing Error: SCR of Identify run 2: ',path]);
    end

    %% ----------------------------------------
    %% Build Rest SCR
    try
        path = [in_path,subj_study,'_',name,'/',subj_study,'_',name,'_',proj.path.task.name_rest,'.mat'];
        physio_raw = load(path);
        
        %% process scr
        n_trs = proj.param.mri.n_trs_rest;
        scr = scr_preproc(proj,n_trs,physio_raw.data);
        
        %% save scr
        save([out_path,subj_study,'_',name,'_',proj.path.task.name_rest,'.mat'],'scr');
    catch
        disp(['Processing Error: SCR of Rest: ',path]);
    end


end

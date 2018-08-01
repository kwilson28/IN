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
    disp(['Removing ',proj.path.fmri_clean]);
    eval(['! rm -rf ',proj.path.fmri_clean]);
    disp(['Creating ',proj.path.fmri_clean]);
    eval(['! mkdir ',proj.path.fmri_clean]);
end

%% Create the subjects to be analyzed (possible multiple studies)
subjs = load_subjs(proj);
disp(['Processing fMRI of ',num2str(numel(subjs)),' subjects']);

%% Preprocess fMRI of each subject in subjects list 
for i=1:numel(subjs)

    %% Get data from raw and formatted into the correct name convention
    dlmwrite([proj.path.code,'tmp/home_path.txt'],proj.path.home,'');
    dlmwrite([proj.path.code,'tmp/raw_path.txt'],proj.path.raw_data,'');
    dlmwrite([proj.path.code,'tmp/lib_path.txt'],proj.path.kablab,'');
    dlmwrite([proj.path.code,'tmp/project_name.txt'],proj.path.name,'');

    %% Get preprocessing params
    dlmwrite([proj.path.code,'tmp/tr.txt'],num2str(proj.param.TR),'');
    dlmwrite([proj.path.code,'tmp/slices.txt'],proj.param.slices,'');
    dlmwrite([proj.path.code,'tmp/slice_pattern.txt'],proj.param.slice_pattern,'');
    dlmwrite([proj.path.code,'tmp/do_anat.txt'],proj.param.do_anat,'');
    dlmwrite([proj.path.code,'tmp/do_epi.txt'],proj.param.do_epi,'');
    dlmwrite([proj.path.code,'tmp/tasks.txt'],proj.param.tasks,'');
    dlmwrite([proj.path.code,'tmp/scans.txt'],proj.param.scans,'');
    dlmwrite([proj.path.code,'tmp/rest_scans.txt'],proj.param.rest_scans,'');

    %% extract subject info
    subj_study = subjs{i}.study;
    name = subjs{i}.name;

    %% debug
    disp([subj_study,':',name]);

    %% Get data from raw and formatted into the correct name convention
    dlmwrite([proj.path.code,'tmp/study.txt'],subj_study,'');
    dlmwrite([proj.path.code,'tmp/subject.txt'],name,'');

    %% Do the preprocessing
    eval(['! ',proj.path.code,'source/preprocess/preprocess_fmri_afni ',proj.path.home,' ',proj.path.name]);

    %% Clean-up
    eval(['! rm ',proj.path.code,'tmp/*']);

end

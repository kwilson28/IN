%%========================================
%%========================================
%%
%% Keith Bush, PhD (2018)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%%========================================
%%========================================

%% ------------------------------------------------------------
%% Clean up matlab environment
matlab_reset;

tic

%% ------------------------------------------------------------
%% Link all source code
addpath(genpath('./source/'));

%% ------------------------------------------------------------
%% STEP 1: Initialize the projects directories and parameters.
init_project;

% %% ------------------------------------------------------------
% %% STEP 2: Clear and reconstruct the project data folder
% clean_project;
% 
% %% ------------------------------------------------------------
% %% STEP 3: Preprocess raw data (wrangling, filtering, formatting)
% 
% %%  fMRI data
% preprocess_fmri;
% preprocess_mask;
% % - preprocess_fd;
% 
% %% Physio data
% preprocess_scr; 
% - preprocess_hrv; 
% - preprocess_emg;
%  
% %% Cognitive data
% % - preprocess_cog;
% 
% %% ------------------------------------------------------------
% %% STEP 4: Format Extrinsic Stimuli Design
% format_ex_3dlss; 
% 
% %% ------------------------------------------------------------
% %% STEP 5: Calculate Extrinsic (EX) Stimuli Beta-Series
% 
% %% fMRI beta-series
% calc_fmri_ex_beta;
%  
% %% Physio beta-series
% calc_scr_ex_beta;
% - calc_emg_ex_beta;
% 
% %% ------------------------------------------------------------
% %% STEP 6: Conduct MVPA for Extrinsic Stimuli of Sys. I.D.
%  
% %% Classification of Affect Scores
% mvpa_fmri_ex_gs_cls % intra-subj Gram-Schmidt MVPA classification
%                     % performs performance estimation using LOOCV
%                     % basis for stimulus refitting (see below)
% 
% mvpa_fmri_ex_gm_cls % intra-subj whole-brain GM MVPA classifications
%                     % performs performance estimation using LOOCV
%                     % also constructs and saves single model for
%                     % application to IN formats
% 
% % ----------------------------------------
% % TICKET  Modify the above mvpa codes to save
% % out the basis function for project to low-dim
% % space.  Will use the inverse to project Haufe-transformed
% % hyperplanes back into GM space for viewing.
% 
% %% ------------------------------------------------------------
% %% STEP 7: Conduct MVPA for Secondary Measures
% %%% mvpa_fmri_ex_rgr_scr % (***unworking DRAFT***)
% 
% %% ------------------------------------------------------------ 
% %% STEP 8: Format project design for IN afni-based beta-series
% format_in_3dlss;
% 
% %% ------------------------------------------------------------
% %% STEP 9: Calcuate Intrinsic (IN) Stimuli Beta-Series
% 
% %% fMRI betas
% calc_fmri_in_beta;
% 
% %% Physio betas
% % TBD
% 
% %% ------------------------------------------------------------ 
% %% STEP 10: Compute IN Cognitive Dynamics
% dynamics_fmri_in_gm;
% 
% %% ------------------------------------------------------------ 
% %% STEP 11: Analysis of IN performance
% plot_er_skill_summary;
% 
% %% ------------------------------------------------------------ 
% %% STEP 12: Secondary Analysis of SCR (Scientific Reports paper)
% analyze_ex_scr;
% 
% %% ------------------------------------------------------------ 
% %% STEP 13: Hyperplane analysis
% % TBD

toc

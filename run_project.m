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
matlab_reset; % debug

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
% %% fMRI data
% preprocess_fmri;
% preprocess_mask;
% % - preprocess_fd;
% 
% %% Physio data
% preprocess_scr; 
% % - preprocess_emg;
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
% %% Physio betas
% calc_scr_ex_beta;
% calc_emg_ex_beta; TBD
%% calc_hrv_ex_beta; % bpm trajectories | neutral filtering
%%% calc_hrv_ex_bpm;  % bpm targets for mvpa

% %% fMRI betas
% calc_fmri_ex_beta;
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
% ----------------------------------------
% TICKET  Modify the above mvpa codes to save
% out the basis function for project to low-dim
% space.  Will use the inverse to project Haufe-transformed
% hyperplanes back into GM space for viewing.
%
% %% ------------------------------------------------------------
% %% STEP 7: Conduct MVPA for Secondary Measures
%
% mvpa_fmri_ex_rgr_scr % unworking DRAFT
% mvpa_fmri_ex_rgr_emg % TBD
%%% mvpa_fmri_ex_gm_rgr_hrv_inter_thresh % inter-subj Gray-matter
%%%                                      % regression.
%%% mvpa_fmri_ex_gm_rgr_hrv_inter_all    % inter-subj Gray-matter
%%%                                      % regression.

% %% ------------------------------------------------------------ 
% %% STEP 8: Format project design for IN afni-based beta-series
% format_in_3dlss
% 
% % %% ------------------------------------------------------------
% %% STEP 9: Calcuate Intrinsic (IN) Stimuli Beta-Series
% 
% %% Physio betas
% % TBD
% 
% %% fMRI betas
% calc_fmri_in_beta
% 
% %% ------------------------------------------------------------ 
% %% STEP 10: Compute IN Cognitive Dynamics
% dynamics_fmri_in_gm
% 
% %% ------------------------------------------------------------ 
% %% STEP 11: Analysis of IN performance
% plot_er_skill_summary % working DRAFT
% 

% %% ------------------------------------------------------------ 
% %% STEP 12: Hyperplane analysis
%%%haufe_ex_gm_hrv_mvpa_all_permute
haufe_ex_gm_hrv_mvpa_thresh_permute

% %% ------------------------------------------------------------ 
% %% STEP 13: Secondary Analysis of EX physiology (Kayla paper)
% SCR (Scienitific Reports paper)
% analyze_ex_scr % working DRAFT
% analyze_ex_emg % TBD
% analyze_ex_hrv_mvpa % working DRAFT


toc

% %% ************************************
% %% ************************************
% %% ****** TEST | RETEST PIPELINE ******
% %% ************************************
% %% ************************************
% %% *********** DATA CLUB? *************
% %% ************************************
% %% ************************************
% 
% %% ------------------------------------------------------------ 
% %% STEP 10: Model Control Mechanisms
% %% 
% %% matlab -nodesktop -nosplash -r "mvpa_gm_beta_ctrl_regress;exit"  ## mvpa predict IN/err control componentry
% %%        - ./utility/mvpa_gm_beta_ctrl_a_drv_regress.m
% %%        - ./utility/mvpa_gm_beta_ctrl_v_drv_regress.m
% %%        - ./utility/mvpa_gm_beta_ctrl_a_err_regress.m
% %%        - ./utility/mvpa_gm_beta_ctrl_v_err_regress.m
% %% 
% %% matlab -nodesktop -nosplash -r "analyze_gm_beta_ctrl_haufe;exit" ## create anatomical structure of IN/err cmptry
% %%             - ./utility/analyze_gm_beta_ctrl_drv_haufe.m
% %%        	    - ./utility/analyze_gm_beta_ctrl_err_haufe.m
% %% 
% 
% %% Key analysis (stim vs feel plot)
% % matlab -nodesktop -nosplash -r "analyze_gm_beta_ctrl;exit" ## GLMM of stim vs feel (V,A,SCR also err vs 2derr)
% 
% %% Key analysis (trajectory modeling)

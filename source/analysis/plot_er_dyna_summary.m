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
logger(['*************************************************'],proj.path.logfile);
logger(['Plotting "Feel" dynamics                         '],proj.path.logfile);
logger(['*************************************************'],proj.path.logfile);

%% ----------------------------------------
%% load subjs
subjs = load_subjs(proj);

figure(1)
set(gcf,'color','w');

%% ----------------------------------------
%% scatter the underlying stim and feel
mu_traj_v = [];
max_traj_dv = [];

for i = 1:numel(subjs)

    %% extract subject info
    subj_study = subjs{i}.study;
    name = subjs{i}.name;
    id = subjs{i}.id;

    % log analysis of subject
    logger([subj_study,'_',name],proj.path.logfile);

    try
        %% Load IN trajectory structures
        load([proj.path.ctrl.in_ctrl,subj_study,'_',name,'_prds.mat']);
    catch
        % do nothing
        logger(['  -Could not find load prds for: ',subj_study,'_',name],proj.path.logfile);
    end

    if(isfield(prds,'v_dcmp'))

        traj_v = prds.v_dcmp.h-prds.v_dcmp.h(:,1);
        mu_traj_v = [mu_traj_v;median(traj_v)];

    else
        disp(['  -Could not find v_dcmp for: ',subj_study,'_',name],proj.path.logfile);
    end

end

%% ----------------------------------------
%% overlay the individual VR skill plots
for i = 1:size(mu_traj_v,1)
    plot(1:size(mu_traj_v,2),mu_traj_v(i,:),'Color',proj.param.plot.dark_grey,'LineWidth',2);
    hold on;
end

%% ----------------------------------------
%% overlay VR goal
vseq = linspace(0,size(mu_traj_v,2));
plot(vseq,0*vseq,'k:','LineWidth',2)
hold on;

%% ----------------------------------------
%% overlay VR phases
vseq = linspace(-1,1);
plot(0*vseq+1,vseq,'k-','LineWidth',2)
hold on;

plot(0*vseq+2,vseq,'k-','LineWidth',2)
hold on;

plot(0*vseq+6,vseq,'k-','LineWidth',2)
hold on;

%% ----------------------------------------
%% format figure
xlim([0,size(mu_traj_v,2)]);
ylim([-1,1]);
hold off;
fig = gcf;
ax = fig.CurrentAxes;
ax.FontSize = proj.param.plot.axisLabelFontSize;

%% ----------------------------------------
%% explot hi-resolution figure
export_fig 'ER_v_dyna_summary.png' -r300  
eval(['! mv ',proj.path.code,'ER_v_dyna_summary.png ',proj.path.fig]);
% 
% %% ****************************************
% %% TICKET
% %% ****************************************
% %% Cannot figure out how to use -r<resolution> flag with the
% %% functional syntax form of the export_fig command, which is
% %% requiring me to to write to local directory and move (above)

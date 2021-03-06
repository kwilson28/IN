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
logger(['Plotting  Stim vs Feel figure                    '],proj.path.logfile);
logger(['*************************************************'],proj.path.logfile);

%% ----------------------------------------
%% load subjs
subjs = load_subjs(proj);

figure(1)
set(gcf,'color','w');

%% ----------------------------------------
%% scatter the underlying stim and feel
indv_b = [];
indv_sort_stim = [];

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

        %% extract stims and mean "feel"
        stim = prds.v_dcmp.stim;
        indv_sort_stim = [indv_sort_stim; sort(stim')];
        feel = mean(prds.v_dcmp.feel,2);

        %% scatter plot specific points        
        scatter(stim,feel,10,'MarkerFaceColor', ...
                proj.param.plot.white,'MarkerEdgeColor', ...
                proj.param.plot.light_grey);
        hold on;

        %% robust fit
        [b stat] = robustfit(stim,feel);
        indv_b = [indv_b;b'];
        
    else
        disp(['  -Could not find v_dcmp for: ',subj_study,'_',name],proj.path.logfile);
    end

end

%% ----------------------------------------
%% overlay the individual VR skill plots
for i = 1:size(indv_sort_stim,1)

    plot(indv_sort_stim(i,:),indv_sort_stim(i,:)*indv_b(i,2)+ ...
         indv_b(i,1),'Color',proj.param.plot.dark_grey,'LineWidth',2);
    hold on;

end

%% ----------------------------------------
%% overlay VR goal
vseq = linspace(-3,3);
plot(vseq,vseq,'k:','LineWidth',2)
hold on;

%% ----------------------------------------
%% overlay the group VR skill plot
plot(vseq,vseq*mean(indv_b(:,2))+mean(indv_b(:,1)),'r-','LineWidth',3);
hold off

%% ----------------------------------------
%% format figure
xlim([-3,3]);
ylim([-2,2]);
hold off;
fig = gcf;
ax = fig.CurrentAxes;
ax.FontSize = proj.param.plot.axisLabelFontSize;

%% ----------------------------------------
%% explot hi-resolution figure
export_fig 'ER_v_skill_summary.png' -r300  
eval(['! mv ',proj.path.code,'ER_v_skill_summary.png ',proj.path.fig]);

%% ****************************************
%% TICKET
%% ****************************************
%% Cannot figure out how to use -r<resolution> flag with the
%% functional syntax form of the export_fig command, which is
%% requiring me to to write to local directory and move (above)

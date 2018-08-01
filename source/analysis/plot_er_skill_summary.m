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

%% plot parameters
axisLabelFontSize = 18;
circleSize = 10;
white = [1,1,1];
light_grey = [.8,.8,.8];
dark_grey = [.6,.6,.6];

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

    % debug
    disp([subj_study,'_',name]);

    try
        %% Load IN trajectory structures
        load([proj.path.in_ctrl,subj_study,'_',name,'_prds.mat']);
    catch
        % do nothing
        disp(['Could not find load prds for: ',subj_study,'_',name]);
    end

    if(isfield(prds,'v_dcmp'))

        %% extract stims and mean "feel"
        stim = prds.v_dcmp.stim;
        indv_sort_stim = [indv_sort_stim; sort(stim')];
        feel = mean(prds.v_dcmp.feel,2);

        %% scatter plot specific points        
        scatter(stim,feel,10,'MarkerFaceColor',white,'MarkerEdgeColor',light_grey);
        hold on;

        %% robust fit
        [b stat] = robustfit(stim,feel);
        indv_b = [indv_b;b'];
        
    else
        disp(['Could not find v_dcmp for: ',subj_study,'_',name]);;
    end

end

%% ----------------------------------------
%% overlay the individual VR skill plots
for i = 1:size(indv_sort_stim,1)

    plot(indv_sort_stim(i,:),indv_sort_stim(i,:)*indv_b(i,2)+indv_b(i,1),'Color',dark_grey,'LineWidth',2);
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
ax.FontSize = axisLabelFontSize;

%% ----------------------------------------
%% explot hi-resolution figure
export_fig 'ER_v_skill_summary.png' -r300  
eval(['! mv ',proj.path.code,'ER_v_skill_summary.png ',proj.path.fig]);

%% ****************************************
%% TICKET
%% ****************************************
%% Cannot figure out how to use -r<resolution> flag with the
%% functional syntax form of the export_fig command

clear all; close all; clc;

type = 'array';

%load(['../Mat/score_Cropmodel_' type '_max_mean.mat']);
%load(['../Mat/score_Maxmodel_' type '_mean_mean.mat']);
%load(['../Mat/score_Maxmodel_' type '_max_mean.mat']);
%load(['../Mat/score_model_' type '_spatialprior.mat']);
load(['../Mat/score_model_' type '_max_mean.mat']);
%load(['../Mat/score_model_' type '_max_mean.mat']);
%load(['../Mat/score_model_' type '_spatialprior.mat']);
%load(['../Mat/score_model_' type '_mean_mean_spatialpriorR.mat']);

%load(['../Mat/score_infernet_' type '.mat']);
%load(['../Mat/score_model_' type '_max_max.mat']);

subjlistinference = {'subj02-ma'};

load(['../Mat/FixationPatchStore_' type '.mat']);
subjstore;
stimulistore;
patchstore;
PrevError;
AttentionNum = length(patchstore);
chosenStimuliNum = 0;
RandTimes = 20;

if strcmp(type, 'array')
    HumanNumFix = 5;
    NumStimuli = 600;
    ErrorNum = 4;
    subjlist = {'subj02-el','subj03-yu','subj05-je','subj07-pr','subj08-bo'}; %array
    NumAlgo = 5;
    AverageObjOnImage = 6;
elseif strcmp(type, 'naturaldesign')
    HumanNumFix = 30; %65 for waldo/wizzard/naturaldesign; 6 for array
    NumStimuli = 480;
    ErrorNum = 8;
    subjlist = {'subj02-az','subj03-el','subj04-ni','subj05-mi','subj06-st'}; %natural design
    NumAlgo = 5;
    AverageObjOnImage = 47;
else
    ErrorNum = 60;
    HumanNumFix = 60;
    NumStimuli = 134; %134 for waldo/wizzard; 480 for antural design; 600 for array
    subjlist = {'subj02-ni','subj03-al','subj04-vi','subj05-lq','subj06-az'}; %waldo/wizzard
    NumAlgo = 4;
end

printpostfix = '.pdf';
printmode = '-dpdf'; %-depsc
printoption = '-r200'; %'-fillpage'


% hb = figure;
% hold on;
markerlist = {'r','b','g','c','m'};
linewidth = 2;

plotstore_mean = nan(NumAlgo,ErrorNum);
plotstore_mse = nan(NumAlgo,ErrorNum);

%model
[B, inferencescore] = sort(scoremat,2);
inferencescore = inferencescore(:,end);
inferencescore_model = inferencescore;
for e = 1:ErrorNum
    
    avg = [];
    for s = 1:length(subjlist)
        gpind = find(patchstore == e & subjstore == s & stimulistore>chosenStimuliNum);
        avg = [avg; nanmean(inferencescore(gpind))];
        %avg = [avg; scoremat(gpind,:)];
    end
     
    plotstore_mean(1,e) = nanmean(avg);
    plotstore_mse(1,e) = nanstd(avg)/sqrt(length(~isnan(avg)));
end




%saliency
load(['../Mat/score_saliency_' type '.mat']);
[B, inferencescore] = sort(scoremat,2);
inferencescore = inferencescore(:,end);
inferencescore_saliency = inferencescore;
[h pval] = ttest2(inferencescore_model, inferencescore_saliency);
display('model vs saliency');
display(['pval = ' num2str(pval)]);
for e = 1:ErrorNum
    
    avg = [];
    for s = 1:length(subjlist)
        gpind = find(patchstore == e & subjstore == s & stimulistore>chosenStimuliNum);
        avg = [avg; nanmean(inferencescore(gpind))];
        %avg = [avg; scoremat(gpind,:)];
    end
     
    plotstore_mean(2,e) = nanmean(avg);
    plotstore_mse(2,e) = nanstd(avg)/sqrt(length(~isnan(avg)));
end


%pixelwise
load(['../Mat/score_pixelwise_' type '.mat']);
[B, inferencescore] = sort(scoremat,2);
inferencescore = inferencescore(:,end);
inferencescore_pixelwise = inferencescore;
[h pval] = ttest2(inferencescore_model, inferencescore_pixelwise);
display('model vs pixelwise');
display(['pval = ' num2str(pval)]);

for e = 1:ErrorNum
    
    avg = [];
    for s = 1:length(subjlist)
        gpind = find(patchstore == e & subjstore == s & stimulistore>chosenStimuliNum);
        avg = [avg; nanmean(inferencescore(gpind))];
        %avg = [avg; scoremat(gpind,:)];
    end
     
    plotstore_mean(3,e) = nanmean(avg);
    plotstore_mse(3,e) = nanstd(avg)/sqrt(length(~isnan(avg)));
end

%randweights
load(['../Mat/score_randweights_' type '.mat']);
[B, inferencescore] = sort(scoremat,2);
inferencescore = inferencescore(:,end);
inferencescore_randweights = inferencescore;
[h pval] = ttest2(inferencescore_model, inferencescore_randweights);
display('model vs saliency');
display(['pval = ' num2str(pval)]);


for e = 1:ErrorNum
    
    avg = [];
    for s = 1:length(subjlist)
        gpind = find(patchstore == e & subjstore == s & stimulistore>chosenStimuliNum);
        avg = [avg; nanmean(inferencescore(gpind))];
        %avg = [avg; scoremat(gpind,:)];
    end
     
    plotstore_mean(4,e) = nanmean(avg);
    plotstore_mse(4,e) = nanstd(avg)/sqrt(length(~isnan(avg)));
end

%chance for Array ONLY
if strcmp(type, 'array')
    inferencescore_chance = ones(length(inferencescore),1)*3;
    for e = 1:ErrorNum
        plotstore_mean(5,e) = (AverageObjOnImage + 1 -e)/2;
        plotstore_mse(5,e) = 0;
    end
else
    
%     for e = 1:ErrorNum
%         plotstore_mean(5,e) = (AverageObjOnImage + 1 -e)/2;
%         plotstore_mse(5,e) = 0;
%     end
    
    load(['../Mat/score_chance_' type '.mat']);
    [B, inferencescore] = sort(scoremat,2);
    inferencescore = inferencescore(:,end);
    inferencescore_chance = inferencescore;  
    for e = 1:ErrorNum
        
        avg = [];
        for s = 1:length(subjlist)
            avgtemp = [];
            for r = 1:RandTimes
                partscoremat = inferencescore( (AttentionNum*(r-1) + 1) : (AttentionNum*(r-1) + AttentionNum));
                gpind = find(patchstore == e & subjstore == s & stimulistore>chosenStimuliNum);
                avgtemp = [avgtemp; nanmean(partscoremat(gpind))];
                %avg = [avg; scoremat(gpind,:)];
            end
            avg = [avg; nanmean(avgtemp)];
        end
        
        plotstore_mean(5,e) = nanmean(avg);
        plotstore_mse(5,e) = nanstd(avg)/sqrt(length(~isnan(avg)));
    end     
            
end

%%humans
% humanavg = [];
% for s = 1:length(subjlistinference)
% 
%     load(['/home/mengmi/Proj/Proj_VS/HumanExp/githuman/Code/ProcessScanpath_inference/' subjlistinference{s} '_' type '.mat']);
%     humanavg = [humanavg; nanmean(scoremat,1)];
% end
% plotstore_mean(6,:) = mean(humanavg,1);
% plotstore_mse(6,:) = std(humanavg,[],1)/sqrt(length(subjlistinference));
plotstore_mean
standard = plotstore_mean(5,:);
for c = 1:size(plotstore_mean,2)
    cs = standard(c);
    plotstore_mean(:,c)=(cs - plotstore_mean(:,c))/cs;
end
plotstore_mean = plotstore_mean*100;
%plotstore_mean(find(plotstore_mean<0)) = 0;

if strcmp(type,'array')
    plotstore_mean(find(plotstore_mean<0)) = 0;
end

hb = figure;
hold on;
linewidth = 3;
errorbar([1:ErrorNum],plotstore_mean(1,:),plotstore_mse(1,:),'b', 'Linewidth', linewidth);
errorbar([1:ErrorNum],plotstore_mean(2,:),plotstore_mse(2,:),'r', 'Linewidth', linewidth);
errorbar([1:ErrorNum],plotstore_mean(3,:),plotstore_mse(3,:),'g', 'Linewidth', linewidth);
errorbar([1:ErrorNum],plotstore_mean(4,:),plotstore_mse(4,:),'m', 'Linewidth', linewidth);
errorbar([1:ErrorNum],plotstore_mean(5,:),plotstore_mse(5,:),'k', 'Linewidth', linewidth);
%errorbar([1:ErrorNum],plotstore_mean(6,:),plotstore_mse(5,:),'ko-', 'Linewidth', linewidth);

if strcmp(type,'array')
    %plotstore_mean(find(plotstore_mean<0)) = 0;
    set(gca,'xtick',1:5);
    legend({'InferNet','Saliency','TempMatch','Randweights','Chance'},'Location','northeast','Fontsize',15);
    ylim([-0.1 7]);
else 
    %legend({'model','saliency','pixelwise','randweights','chance'},'Location','northwest');
end

xlabel('Numbers of error fixations','FontSize', 20, 'Fontweight', 'bold');
ylabel('Relative performance (%)' ,'FontSize', 20, 'Fontweight', 'bold');
xlim([0.5 ErrorNum+0.5]);

display(['model performance:']);
plotstore_mean(1,:)

set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['../Figures/fig_' type '_GuessesSummary' printpostfix],printmode,printoption);

inferencescore_rest = [inferencescore_randweights; inferencescore_chance; inferencescore_pixelwise; inferencescore_saliency];
[h,pval,ci,stats] = ttest2(inferencescore_model,inferencescore_rest );
display('model vs all the rest');
display(['pval = ' num2str(pval)]);
display(['t = ' num2str(stats.tstat)]);
display(['df = ' num2str(stats.df)]);
    
[h,pval,ci,stats] = ttest2(inferencescore_pixelwise,inferencescore_chance );
display('pixelwise vs chance');
display(['pval = ' num2str(pval)]);    
display(['t = ' num2str(stats.tstat)]);
display(['df = ' num2str(stats.df)]);  
    

mean(plotstore_mean(1,:))
std(plotstore_mean(1,:))

plotstore_mean
    
    
    
    
    
    
    
    


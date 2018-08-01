clear all; close all; clc;
type = 'naturaldesign';
load(['../Mat/FixationPatchStore_naturaldesign.mat']);
typelist = {'layer','max_max','mean_max','mean_mean'};
LayerList = [5 10 17 23 24 30 31];
HumanNumFix = 30; %65 for waldo/wizzard/naturaldesign; 6 for array
NumStimuli = 480;
ErrorNum = 8;
subjlist = {'subj02-az','subj03-el','subj04-ni','subj05-mi','subj06-st'}; %natural design
AverageObjOnImage = 47;
chosenStimuliNum = 0;
NumAlgo = 13;
plotstore_mean = nan(NumAlgo,ErrorNum);
plotstore_mse = nan(NumAlgo,ErrorNum);

AttentionNum = length(patchstore);
RandTimes = 20;

markerlist = {'r','b','g','c','m','r*-','b*-','g*-','c*-','m*-','r^-','b^-'};

hb = figure;
hold on;

counter = 1;


%model

load(['../Mat/score_model_naturaldesign_max_mean.mat']);
[B, inferencescore] = sort(scoremat,2);
inferencescore = inferencescore(:,end);
for e = 1:ErrorNum
    
    avg = [];
    for s = 1:length(subjlist)
        gpind = find(patchstore == e & subjstore == s & stimulistore>chosenStimuliNum);
        avg = [avg; nanmean(inferencescore(gpind))];
        %avg = [avg; scoremat(gpind,:)];
    end
     
    plotstore_mean(counter,e) = nanmean(avg);
    plotstore_mse(counter,e) = nanstd(avg)/sqrt(length(~isnan(avg)));
    
end
display('model');
plotstore_mean(counter,:)
errorbar([1:ErrorNum],plotstore_mean(counter,:),plotstore_mse(counter,:),markerlist{counter});
counter =counter+1;

for t = 1:length(typelist)

    if strcmp(typelist{t}, 'layer')
        for l = 1:7
            load(['../Mat/score_ablated_naturaldesign_layer_' num2str(LayerList(l)) '.mat']);
            display(typelist{t});
            [B, inferencescore] = sort(scoremat,2);
            inferencescore = inferencescore(:,end);
            for e = 1:ErrorNum

                avg = [];
                for s = 1:length(subjlist)
                    gpind = find(patchstore == e & subjstore == s & stimulistore>chosenStimuliNum);
                    avg = [avg; nanmean(inferencescore(gpind))];
                    %avg = [avg; scoremat(gpind,:)];
                end

                plotstore_mean(counter,e) = nanmean(avg);
                plotstore_mse(counter,e) = nanstd(avg)/sqrt(length(~isnan(avg)));

            end
            display(['layer ' num2str(l)]);
            plotstore_mean(counter,:)
            errorbar([1:ErrorNum],plotstore_mean(counter,:),plotstore_mse(counter,:),markerlist{counter});
            %pause;
            counter =counter+1;
        end
    else
        load(['../Mat/score_ablated_naturaldesign_' typelist{t} '.mat']);
        display(typelist{t});
        [B, inferencescore] = sort(scoremat,2);
        inferencescore = inferencescore(:,end);
        for e = 1:ErrorNum

            avg = [];
            for s = 1:length(subjlist)
                gpind = find(patchstore == e & subjstore == s & stimulistore>chosenStimuliNum);
                avg = [avg; nanmean(inferencescore(gpind))];
                %avg = [avg; scoremat(gpind,:)];
            end

            plotstore_mean(counter,e) = nanmean(avg);
            plotstore_mse(counter,e) = nanstd(avg)/sqrt(length(~isnan(avg)));

        end
        display(typelist{t});
        plotstore_mean(counter,:)
        errorbar([1:ErrorNum],plotstore_mean(counter,:),plotstore_mse(counter,:),markerlist{counter});
        %pause;
        counter =counter+1;
    end

    
end

legend('model','layer5','layer10','layer17','layer23','layer24','layer30','layer31','max_max','mean_max','mean_mean');


  


load(['../Mat/score_infernet_naturaldesign.mat']);
chosenStimuliNum = 120;
[B, inferencescore] = sort(scoremat,2);
inferencescore = inferencescore(:,end);
for e = 1:ErrorNum

    avg = [];
    for s = 1:length(subjlist)
        gpind = find(patchstore == e & subjstore == s & stimulistore>chosenStimuliNum);
        avg = [avg; nanmean(inferencescore(gpind))];
        %avg = [avg; scoremat(gpind,:)];
    end

    plotstore_mean(counter,e) = nanmean(avg);
    plotstore_mse(counter,e) = nanstd(avg)/sqrt(length(~isnan(avg)));

end

plotstore_mean(12,:)

load(['../Mat/score_chance_' type '.mat']);
[B, inferencescore] = sort(scoremat,2);
inferencescore = inferencescore(:,end);
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

    plotstore_mean(13,e) = nanmean(avg);
    plotstore_mse(13,e) = nanstd(avg)/sqrt(length(~isnan(avg)));
end   

standard = plotstore_mean(13,:);
for c = 1:size(plotstore_mean,2)
    cs = standard(c);
    plotstore_mean(:,c)=(cs - plotstore_mean(:,c))/cs;
end
plotstore_mean = plotstore_mean*100;


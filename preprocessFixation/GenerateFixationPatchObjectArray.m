clear all; close all; clc;

printpostfix = '.eps';
printmode = '-depsc'; %-depsc
printoption = '-r200'; %'-fillpage'

fix = [27 158; 31 67; 121 19; 203 67; 196 156; 108  195];

type = 'array';

if strcmp(type, 'array')
    HumanNumFix = 6;
    NumStimuli = 600;
    subjlist = {'subj02-el','subj03-yu','subj05-je','subj07-pr','subj08-bo'}; %array
elseif strcmp(type, 'naturaldesign')
    HumanNumFix = 30; %65 for waldo/wizzard/naturaldesign; 6 for array
    NumStimuli = 480;
    subjlist = {'subj02-az','subj03-el','subj04-ni','subj05-mi','subj06-st'}; %natural design
else
    HumanNumFix = 80;
    NumStimuli = 134; %134 for waldo/wizzard; 480 for antural design; 600 for array
    subjlist = {'subj02-ni','subj03-al','subj04-vi','subj05-lq','subj06-az'}; %waldo/wizzard
end

prefix = '/home/mengmi/Proj/Proj_VS/HumanExp/githuman/';
ImageDir = ['/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/Human/FinalSelected/cate'];
load([prefix 'SubjectArray/' type '.mat']);
load([prefix 'SubjectArray/' type '_seq.mat']);
[B,seqInd] = sort(seq);

subjstore = [];
stimulistore = [];
patchstore = [];
PrevError = {};
%wrongind = [];

for i = 1: length(subjlist)
    load([prefix 'Code/ProcessScanpath_' type  '/' subjlist{i} '.mat']);
    if ~strcmp( 'array', type)
        TargetFound = FixData.TargetFound(:,:);
        TargetFound = TargetFound(seqInd,:);
    else
        TargetFound = scoremat;
    end
    
    load([prefix 'Code/subjects_array/' subjlist{i} '/subjperform.mat']);
    fixmat;    
    for j = 1: NumStimuli/2
        trial = MyData(j);
        trialfixseq = fixmat(j,:);
        trialfixseq(find(isnan(trialfixseq))) = [];
        if isempty(trialfixseq)
            %invalid human trial
            continue;
        end
        
        gtind = find(TargetFound(j,:) == 1);
        
        if isempty(gtind)
            %human cant find target
            selectind = length(trialfixseq);
        else
            if gtind == 1
                continue;
            else
                selectind = gtind - 1;
            end
        end
        
        preverror = [];
        binaryMap = zeros(224, 224);
        accumMap = zeros(224,224);
        for k = 1:selectind
            preverror = [preverror trialfixseq(k)];
            
            binaryMap( fix(trialfixseq(k),2), fix(trialfixseq(k),1) ) = 1;
            G = fspecial('gaussian',[200 200],20);            
            Ig = imfilter(binaryMap,G,'same');
            Ig = mat2gray(Ig);
            imwrite(Ig,['/media/mengmi/TOSHIBA2/Proj_IT/Datasets/ErrorFixationMap_array/subj_' num2str(i) '_stimuli_' num2str(j) '_patch_' num2str(k) '.jpg']);
        
            accumMap = accumMap + Ig;
            imwrite(mat2gray(accumMap),['/media/mengmi/TOSHIBA2/Proj_IT/Datasets/DurationErrorFixationMap_array/subj_' num2str(i) '_stimuli_' num2str(j) '_patch_' num2str(k) '.jpg']);
        
            
%             imshow(Ig);
%             pause;
            
            %sanityimg = imread(['/home/mengmi/Proj/Proj_VS/Datasets/Human/stimuli/array_' num2str(j) '.jpg']);
            img = imread([ImageDir num2str(trial.arraycate(trialfixseq(k))) '/img' num2str(trial.arrayimgnum(trialfixseq(k))) '.jpg']);
            Rsize = 224; %toggle between 28, and 224
            img = imresize(img,[Rsize Rsize]); %28, 224
            imwrite(img,['/media/mengmi/TOSHIBA2/Proj_IT/Datasets/FixationPatchArray_' num2str(Rsize) '/subj_' num2str(i) '_stimuli_' num2str(j) '_patch_' num2str(k) '.jpg']);
        
%             gttrialind = find(trial.targetcate == trial.arraycate);
%             if isempty(find(preverror == gttrialind))
%                 wrongind = [wrongind 0];
%             else
%                 wrongind = [wrongind 1];
%             end
%             
            subjstore = [subjstore i];
            stimulistore = [stimulistore j];
            patchstore = [patchstore k];
            PrevError = [PrevError preverror];
            display(['subj_' num2str(i) '_stimuli_' num2str(j) '_patch_' num2str(k) '.jpg']);
        end
        
    end
end
    
save(['../Mat/FixationPatchStore_' type '.mat'],'subjstore','stimulistore','patchstore','PrevError');
display('done');

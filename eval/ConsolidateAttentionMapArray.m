clear all; close all; clc;
type = 'array';
LayerList = [5 10 17 23 24 30 31];
load(['../Mat/FixationPatchStore_' type '.mat']);
subjstore;
stimulistore;
patchstore;
AttentionNum = length(patchstore);
w = 224;
h = 224;

for i = 1: AttentionNum
    
    subjind = subjstore(i);
    stimuliind = stimulistore(i);
    patchind = patchstore(i);
    display(['subj_' num2str(subjind) '_stimuli_' num2str(stimuliind) '_patch_' num2str(patchind) '.jpg']);
    
    wholeimg = zeros(length(LayerList),w, h);
    for l = 1: length(LayerList)
        MyLayer = LayerList(l);
        input = load(['/media/mengmi/TOSHIBA2/Proj_IT/results/PatchArrayAttentionMap/subj_' num2str(subjind) '_stimuli_' num2str( stimuliind ) '_patch_' num2str(patchind) '_layer_' num2str(MyLayer ) '.mat']);
        input = input.x;
        input = imresize(input, [w h]);

        wholeimg(l,:,:) = mat2gray(input);
    end
    
    wholeimgmax = squeeze(max(wholeimg,[],1));
    wholeimgmax = mat2gray(wholeimgmax);
    
    wholeimg = squeeze(mean(wholeimg,1));
    wholeimg = mat2gray(wholeimg);
%     imshow(wholeimg);
%     pause;
 


    imwrite(wholeimgmax,['/media/mengmi/TOSHIBA2/Proj_IT/results/PatchArrayAttentionMapIntegrated/MaxSubj_' num2str(subjind) '_stimuli_' num2str( stimuliind ) '_patch_' num2str(patchind) '.jpg']);

    imwrite(wholeimg,['/media/mengmi/TOSHIBA2/Proj_IT/results/PatchArrayAttentionMapIntegrated/subj_' num2str(subjind) '_stimuli_' num2str( stimuliind ) '_patch_' num2str(patchind) '.jpg']);
end




























clear all; close all; clc;
type = 'naturaldesign';
LayerList = [5 10 17 23 24 30 31];
load(['../Mat/FixationPatchStore_' type '.mat']);
subjstore;
stimulistore;
patchstore;
AttentionNum = length(patchstore);
w = 1024;
h = 1280;

for i = [1:AttentionNum] %[1:30: AttentionNum]
    
    subjind = subjstore(i);
    stimuliind = stimulistore(i);
    patchind = patchstore(i);
    display(['subj_' num2str(subjind) '_stimuli_' num2str(stimuliind) '_patch_' num2str(patchind) '.jpg']);
    
    wholeimg = zeros(length(LayerList),w, h);
%     for q = 1:30
%         
%         p = i + q - 1;
%         locxind = locxstore(p);
%         locyind = locystore(p);
%         sample = imread(['/media/mengmi/TOSHIBA2/Proj_IT/Datasets/croppednaturaldesign/img_id_' sprintf('%03d',stimuliind) '_' num2str(locxind) '_' num2str(locyind) '.jpg']);
%         
%         for l = 1: length(LayerList)
%             MyLayer = LayerList(l);
%             input = load(['/media/mengmi/TOSHIBA2/Proj_IT/results/PatchNaturalDesignAttentionMap/subj_' num2str(subjind) '_stimuli_' num2str( stimuliind ) '_patch_' num2str(patchind) '_locx_' num2str(locxind) '_locy_' num2str(locyind) '_MyLayer_' num2str(MyLayer ) '.mat']);
%             input = input.x;            
%             input = imresize(input,size(sample));
%             wholeimg(l,locxind: locxind+size(sample,1)-1, locyind: locyind+size(sample,2)-1) = input;
%         end
%     end

    for l = 1: length(LayerList)
        MyLayer = LayerList(l);
        input = load(['/media/mengmi/TOSHIBA2/Proj_IT/results/PatchNaturalDesignAttentionMap/subj_' num2str(subjind) '_stimuli_' num2str( stimuliind ) '_patch_' num2str(patchind) '_layer_' num2str(MyLayer ) '.mat']);
        input = input.x;
        input = imresize(input, [w h]);

        wholeimg(l,:,:) = mat2gray(input);
    end
    
    
%     for l = 1:length(LayerList)
%         wholeimg(l,:,:) = mat2gray(wholeimg(l,:,:));
%     end
    
    wholeimgmax = squeeze(max(wholeimg,[],1));
    wholeimgmax = mat2gray(wholeimgmax);

    wholeimg = squeeze(mean(wholeimg,1));
    wholeimg = mat2gray(wholeimg);
%     imshow(wholeimg);
%     pause;
    imwrite(wholeimgmax,['/media/mengmi/TOSHIBA2/Proj_IT/results/PatchNaturalDesignAttentionMapIntegrated/MaxSubj_' num2str(subjind) '_stimuli_' num2str( stimuliind ) '_patch_' num2str(patchind) '.jpg']);

    imwrite(wholeimg,['/media/mengmi/TOSHIBA2/Proj_IT/results/PatchNaturalDesignAttentionMapIntegrated/subj_' num2str(subjind) '_stimuli_' num2str( stimuliind ) '_patch_' num2str(patchind) '.jpg']);
end








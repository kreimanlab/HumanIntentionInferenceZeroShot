clear all; close all; clc;

totalmask = load(['/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/Human/saliencyMask/masktotal.mat']);
totalmask = totalmask.masktotal;

maskind = load(['/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/Human/saliencyMask/maskind.mat']);
maskind = maskind.maskind;

type = 'array';
LayerList = [5 10 17 23 24 30 31];
load(['../Mat/FixationPatchStore_' type '.mat']);
subjstore;
stimulistore;
patchstore;
AttentionNum = length(patchstore);
w = 224;
h = 224;
HumanNumFix = 6;
scoremat = zeros(AttentionNum,HumanNumFix-1);
%inferencenummat = [];

prefix = '/home/mengmi/Proj/Proj_VS/HumanExp/githuman/';
ImageDir = ['/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/Human/FinalSelected/cate'];
load([prefix 'SubjectArray/' type '.mat']);
load([prefix 'SubjectArray/' type '_seq.mat']);
[B,seqInd] = sort(seq);

for i = 1: AttentionNum
    
    display(['processing: ' num2str(i) ]);
    
    subjind = subjstore(i);
    stimuliind = stimulistore(i);
    patchind = patchstore(i);
    preverror = PrevError{i};
    trial = MyData(stimuliind);
    [gtind num] = find(  trial.arraycate == trial.targetcate);
    display(['subj_' num2str(subjind) '_stimuli_' num2str(stimuliind) '_patch_' num2str(patchind) '.jpg']);
    
    %sumwholeimg = zeros(size(totalmask));
    sumwholeimg = zeros(patchind,size(totalmask,1),size(totalmask,2));
    %consider all the information you had from all past error fixations
    for p = 1:patchind
        wholeimg = imread(['/media/mengmi/TOSHIBA2/Proj_IT/results/PatchArrayAttentionMapIntegrated/Maxsubj_' num2str(subjind) '_stimuli_' num2str( stimuliind ) '_patch_' num2str(p) '.jpg']);
        wholeimg = imresize(wholeimg, size(totalmask));
%         G = fspecial('gaussian',[300 300],50);            
%         Ig = imfilter(wholeimg,G,'same');
        wholeimg = mat2gray(wholeimg);
        sumwholeimg(p,:,:) =  wholeimg;
        %sumwholeimg = sumwholeimg + wholeimg;
    end
    sumwholeimg = double(sumwholeimg);
    sumwholeimg = mean(sumwholeimg,1);
    wholeimg = mat2gray(squeeze(sumwholeimg));
    
    %sumwholeimg = max(sumwholeimg,[],1);
    G = fspecial('gaussian',[300 300],50);            
    Ig = imfilter(wholeimg,G,'same');
    wholeimg = mat2gray(Ig);
    
    
%     imshow(wholeimg);
%     pause;
    
    %clean to six positions
    wholeimg  = wholeimg.*totalmask;
    wholeimg = mat2gray(wholeimg);
    
    %clean all previous error fixation positions
    for errorfixremove = 1:length(preverror)
        errorpos = preverror(errorfixremove);
        chosenmask = load(['/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/Human/saliencyMask/mask' num2str(errorpos) '.mat']);
        chosenmask = chosenmask.mask;
        wholeimg = wholeimg.*(1 - chosenmask);    
    end
    wholeimg = mat2gray(wholeimg);
    salimg = wholeimg;
    
    fixnum = 1;
    %start fixation prediction
    for j = 1:HumanNumFix
    
        if j ~= 1
            
            chosenmask = load(['/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/Human/saliencyMask/mask' num2str(chosenfix) '.mat']);
            chosenmask = chosenmask.mask;
            salimg = salimg.*(1 - chosenmask);
            salimg = mat2gray(salimg);
        end
        
%         Iori = imread(['/home/mengmi/Proj/Proj_VS/Datasets/Human/stimuli/array_' num2str(i) '.jpg']);
%         imshow(heatmap_overlay(Iori, salimg));
%         pause;
%         imshow(salimg);       
%         pause(0.01);

        [Y,idx] = max(salimg(:));
        [x y]= ind2sub(size(salimg),idx);

        
        chosenfix = maskind(x,y);
        
%         subplot(1,2,1);
%         imshow(uint8(salimg));
%         hold on;
%         plot(y,x,'r*');
%         hold off;
%         subplot(1,2,2);       
%         chosenmask = load(['/home/mengmi/Proj/Proj_VS/Datasets/Human/saliencyMask/mask' num2str(chosenfix) '.mat']);
%         chosenmask = chosenmask.mask;
%         imshow(chosenmask);
%         drawnow;
        
        if chosenfix == gtind
            scoremat(i,j) = 1;
            break;
        end
        fixnum = fixnum + 1;    
        
    end
    display(['find at: ' num2str(fixnum)]);
    %inferencenummat = [inferencenummat fixnum];
end


save(['../Mat/score_model_array_max_mean.mat'],'scoremat'); %300 50; %50 25
display('saved');










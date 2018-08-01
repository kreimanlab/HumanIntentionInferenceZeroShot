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

% fixnum==1 && stimuliind<=180 && patchind==1
% attentionnumber: 14; stimuli: 14; find at: 1
% attentionnumber: 15; stimuli: 15; find at: 1
% attentionnumber: 20; stimuli: 20; find at: 1
% attentionnumber: 64; stimuli: 39; find at: 1
% attentionnumber: 67; stimuli: 41; find at: 1
% attentionnumber: 70; stimuli: 42; find at: 1

% fixnum==2 && stimuliind<=180 && patchind==1
% attentionnumber: 8; stimuli: 10; find at: 2
% attentionnumber: 23; stimuli: 21; find at: 2
% attentionnumber: 26; stimuli: 22; find at: 2
% attentionnumber: 31; stimuli: 25; find at: 2
% attentionnumber: 34; stimuli: 26; find at: 2
% attentionnumber: 46; stimuli: 32; find at: 2
% attentionnumber: 58; stimuli: 36; find at: 2
% attentionnumber: 63; stimuli: 38; find at: 2

for i =  [13]%1:AttentionNum %[15 26 64 ] %1: AttentionNum %[26 34 63] %[15 64]
    
    %display(['processing: ' num2str(i) ]);
    
    subjind = subjstore(i);
    stimuliind = stimulistore(i);
    patchind = patchstore(i);
    preverror = PrevError{i};
    trial = MyData(stimuliind);
    [gtind num] = find(  trial.arraycate == trial.targetcate);
    %display(['subj_' num2str(subjind) '_stimuli_' num2str(stimuliind) '_patch_' num2str(patchind) '.jpg']);
    
    %sumwholeimg = zeros(size(totalmask));
    sumwholeimg = zeros(patchind,size(totalmask,1),size(totalmask,2));
    %consider all the information you had from all past error fixations
    for p = 1:patchind
        wholeimg = imread(['/media/mengmi/TOSHIBA2/Proj_IT/results/PatchArrayAttentionMapIntegrated/Maxsubj_' num2str(subjind) '_stimuli_' num2str( stimuliind ) '_patch_' num2str(p) '.jpg']);
        wholeimg = imresize(wholeimg, size(totalmask));
        imwrite(wholeimg,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/nfigure/array_wholeimg' num2str(i) '_' num2str(p) '.jpg']);
    
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
    
    
    Iori = imread(['/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/Human/stimuli/array_' num2str(stimuliind) '.jpg']);
    subplot(2,2,1);
    imshow(Iori);
    imwrite(Iori,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/nfigure/array_Iori' num2str(i) '.jpg']);
    title(['attentionnum: ' num2str(i) ]);
    heat = heatmap_overlay(Iori, wholeimg);
    imwrite(heat,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/nfigure/array_heatmap' num2str(i) '.jpg']);
    imwrite(wholeimg,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/nfigure/array_wholeimg' num2str(i) '.jpg']);
    subplot(2,2,2);
    imshow(heat);
    subplot(2,2,3);
    target = imread(['/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/Human/stimuli/target_' num2str(stimuliind) '.jpg']);
    imwrite(target,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/nfigure/array_target' num2str(i) '.jpg']);
    imshow(target); 
    display(['Attention number: '  num2str(i)]);
    display('error fixation seq');
    preverror
    %pause;
    
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
            chosenfix
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
        heat = heatmap_overlay(Iori, I);
        imwrite(heat,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/nfigure/array_salimg' num2str(i) '.jpg']);
    
    end
    
    if fixnum==3 && stimuliind<=180 && patchind==2
        display('===============================================================');
        display(['attentionnumber: ' num2str(i) '; stimuli: ' num2str(stimuliind) '; find at: ' num2str(fixnum)]);
    end
    %inferencenummat = [inferencenummat fixnum];
end

display('saved');
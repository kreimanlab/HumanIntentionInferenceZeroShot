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
HumanNumFix = 30;
receptiveSize = 150;
scoremat = zeros(AttentionNum,HumanNumFix);

prefix = '/home/mengmi/Proj/Proj_VS/HumanExp/githuman/';
load([prefix 'SubjectArray/' type '.mat']);
load([prefix 'SubjectArray/' type '_seq.mat']);
[B,seqInd] = sort(seq);

for i = [41 152 ]% [1: AttentionNum] %[152]
    
    display(['processing: ' num2str(i) ]);
    
    subjind = subjstore(i);
    stimuliind = stimulistore(i);
    patchind = patchstore(i);
    preverror = PrevError{i};
    
    path = ['/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/NaturalDataset/filtered/gt' num2str(stimuliind) '.jpg' ];
    gt = double(imread(path));
    %display(['subj_' num2str(subjind) '_stimuli_' num2str(stimuliind) '_patch_' num2str(patchind) '.jpg']);
    gt = gt(:,:,1);
    
%     %doing average across saliency maps
%     sumwholeimg = zeros(w,h);    
%     %consider all the information you had from all past error fixations
%     for p = 1:patchind
%         wholeimg = imread(['/media/mengmi/TOSHIBA2/Proj_IT/results/PatchNaturalDesignAttentionMapIntegrated/subj_' num2str(subjind) '_stimuli_' num2str( stimuliind ) '_patch_' num2str(p) '.jpg']);
%         wholeimg = imresize(wholeimg, [1024 1280]);
%         wholeimg = mat2gray(wholeimg);
%         sumwholeimg = sumwholeimg + wholeimg;
%     end
%     sumwholeimg = double(sumwholeimg);
%     wholeimg = mat2gray(sumwholeimg);
        
    %doing max across saliency maps
    %doing average across saliency maps
    sumwholeimg = zeros(patchind,w,h);    
    %consider all the information you had from all past error fixations
    for p = 1:patchind
        wholeimg = imread(['/media/mengmi/TOSHIBA2/Proj_IT/results/PatchNaturalDesignAttentionMapIntegrated/Maxsubj_' num2str(subjind) '_stimuli_' num2str( stimuliind ) '_patch_' num2str(p) '.jpg']);
        wholeimg = imresize(wholeimg, [1024 1280]);
        wholeimg = mat2gray(wholeimg);
        sumwholeimg(p,:,:) =  wholeimg;
    end
    sumwholeimg = double(sumwholeimg);
    sumwholeimg = mean(sumwholeimg,1);
    %sumwholeimg = max(sumwholeimg,[],1);
    wholeimg = mat2gray(squeeze(sumwholeimg));
    
%     G = fspecial('gaussian',[150 150],70);            
%     Ig = imfilter(wholeimg,G,'same');
%     wholeimg = mat2gray(Ig);
    
%     imshow(wholeimg);
%     pause;


    imgpath = ['/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/NaturalDataset/filtered/gray' sprintf('%03d',stimuliind) '.jpg'];
    targetpath = ['/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/NaturalDataset/filtered/targetgray' sprintf('%03d',stimuliind) '.jpg' ];
    target = imread(targetpath);
    Iori = imread(imgpath);
    Iori = imresize(Iori,[w h]);
    IIOR = Iori;    
    heat = heatmap_overlay(Iori, wholeimg);
    
    
    %clean all previous error fixation positions
    preverrorx = preverror(1,:);
    preverrory = preverror(2,:);
    for errorfixremove = 1:length(preverrorx)
        x = preverrorx(errorfixremove);
        y = preverrory(errorfixremove);
        
        if x<1
            warning('prob');
            x = 1;
        end
        if x>h
            warning('prob');
            x = h;
        end
        if y<1
            warning('prob');
            y = 1;
        end
        if y>w
            warning('prob');
            y = w;
        end

        fixatedPlace_leftx = x - receptiveSize/2 + 1;
        fixatedPlace_rightx = x + receptiveSize/2;
        fixatedPlace_lefty = y - receptiveSize/2 + 1;
        fixatedPlace_righty = y + receptiveSize/2;

        if fixatedPlace_leftx < 1
            fixatedPlace_leftx = 1;
        end
        if fixatedPlace_lefty < 1
            fixatedPlace_lefty = 1;
        end
        if fixatedPlace_rightx > size(gt,2)
            fixatedPlace_rightx = size(gt,2);
        end
        if fixatedPlace_righty > size(gt,1)
            fixatedPlace_righty = size(gt,1);
        end
        wholeimg(fixatedPlace_lefty:fixatedPlace_righty, fixatedPlace_leftx:fixatedPlace_rightx) = 0; 
        IIOR(fixatedPlace_lefty:fixatedPlace_righty, fixatedPlace_leftx:fixatedPlace_rightx) = 0; 
    end
    wholeimg = mat2gray(wholeimg);
    salimg = wholeimg;
    
    RGBhuman = Iori;
    for qq = 1: length(preverrorx)
        fixnumstr = {num2str(qq)};            
        RGBhuman = insertText(RGBhuman,[int32(preverrorx(qq)) int32(preverrory(qq))], fixnumstr,'BoxColor','y','TextColor','white','FontSize',70);
    end
    RGBhuman = imresize(RGBhuman, [480 640]);
    
        
    fixnum = 1;posx = []; posy = [];
    %start fixation prediction
    for j = 1:HumanNumFix
    
        [Y,idx] = max(salimg(:));
        [y x]= ind2sub(size(salimg),idx);
        
        posx = [posx; y];
        posy = [posy; x];
        
%         imshow(salimg);
%         hold on;
%         plot(x,y,'r*');
%         hold off;
%         pause(0.1);
%         drawnow;

        fixatedPlace_leftx = x - receptiveSize/2 + 1;
        fixatedPlace_rightx = x + receptiveSize/2;
        fixatedPlace_lefty = y - receptiveSize/2 + 1;
        fixatedPlace_righty = y + receptiveSize/2;

        if fixatedPlace_leftx < 1
            fixatedPlace_leftx = 1;
        end
        if fixatedPlace_lefty < 1
            fixatedPlace_lefty = 1;
        end
        if fixatedPlace_rightx > size(gt,2)
            fixatedPlace_rightx = size(gt,2);
        end
        if fixatedPlace_righty > size(gt,1)
            fixatedPlace_righty = size(gt,1);
        end
        
        
        
        fixatedPlace = gt(fixatedPlace_lefty:fixatedPlace_righty, fixatedPlace_leftx:fixatedPlace_rightx);
        
        if sum(sum(fixatedPlace)) > 0                 
            break;
        end
        fixnum = fixnum + 1;
        salimg(fixatedPlace_lefty:fixatedPlace_righty, fixatedPlace_leftx:fixatedPlace_rightx,:) = 0;

          
        
    end
    
    RGB = IIOR;
    for qq = 1: length(posx)
        fixnumstr = {num2str(qq)};            
        RGB = insertText(RGB,[int32(posy(qq)) int32(posx(qq))], fixnumstr,'BoxColor','r','TextColor','white','FontSize',70);
    end
    RGB = imresize(RGB, [480 640]);
    
    subplot(2,3,1);
    imshow(Iori);
    imwrite(Iori,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/Figures/naturaldesign_Iori' num2str(i) '.jpg']);
    title(i);
    subplot(2,3,2);
    imshow(RGB);
    imwrite(RGB,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/Figures/naturaldesign_guess' num2str(i) '.jpg']);
    %imshow(gt);
    subplot(2,3,3);
    imshow(target);
    imwrite(target,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/Figures/naturaldesign_target' num2str(i) '.jpg']);
    subplot(2,3,4);    
    imshow(heat);
    imwrite(heat,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/Figures/naturaldesign_heat' num2str(i) '.jpg']);
    subplot(2,3,5);
    imshow(RGBhuman);
    imwrite(RGBhuman,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/Figures/naturaldesign_human' num2str(i) '.jpg']);
    subplot(2,3,6);
    imshow(gt);
    imwrite(gt,['/media/mengmi/MimiDrive/Publications/NIPS_IT2018/Figures/naturaldesign_gt' num2str(i) '.jpg']);
    pause;
    
    if fixnum<=3 && fixnum>1 && patchind <= 3
        display(['attentionnumber: ' num2str(i) '; stimuli: ' num2str(stimuliind) '; find at: ' num2str(fixnum)]);
    end
        
end

display('saved');
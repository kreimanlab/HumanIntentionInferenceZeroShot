--
--  Copyright (c) 2016, Manuel Araoz
--  Copyright (c) 2016, Facebook, Inc.
--  All rights reserved.
--
--  This source code is licensed under the BSD-style license found in the
--  LICENSE file in the root directory of this source tree. An additional grant
--  of patent rights can be found in the PATENTS file in the same directory.
--
--  classifies an image using a trained model
--
-- Updated by Mengmi Zhang for visual search testing
-- Date: Aug, 5, 2017

require 'torch'
require 'paths'
require 'cudnn'
require 'cunn'
require 'image'
require 'loadcaffe'
local matio = require 'matio'
tds = require 'tds'

local t = require './transforms'
local imagenetLabel = require './imagenet'

-- Load the model
local cmodel = loadcaffe.load('../Models/caffevgg16/VGG_ILSVRC_16_layers_deploy.prototxt', '../Models/caffevgg16/VGG_ILSVRC_16_layers.caffemodel', 'nn')
--print(cmodel)

model_stimuli = nn.Sequential()

-- layers: numlayer, numtemplates, convsize
-- layers: 5, 64, 14
-- layers: 10, 128, 7
-- layers: 17, 256, 4
-- layers: 23, 512, 4
-- layers: 24, 512, 2
-- layers: 30, 512, 2
-- layers: 31, 512, 1

MyLayer = 31 
NumTemplates = 512  
ConvSize = 1
  
 
for i=1,MyLayer do --32        
	model_stimuli:add(cmodel:get(i))
end
model_stimuli = model_stimuli:cuda()
print(model_stimuli)

-- Evaluate mode
model_stimuli:evaluate()

model_target=model_stimuli:clone('weight','bias'):cuda()

-- Evaluate mode
model_stimuli:evaluate()
model_target:evaluate()

MMconv = nn.SpatialConvolution(NumTemplates,1,ConvSize,ConvSize,1,1,1,1):cuda()

--module = nn.SpatialConvolution(nInputPlane, nOutputPlane, kW, kH, [dW], [dH], [padW], [padH])

-- The model was trained with this input normalization
function preprocess(img)
  local mean_pixel = torch.FloatTensor({103.939, 116.779, 123.68})
  local perm = torch.LongTensor{3, 2, 1}
  img = img:index(1, perm):mul(256.0)
  mean_pixel = mean_pixel:view(3, 1, 1):expandAs(img)
  img:add(-1, mean_pixel)
  return img
end

trainbinlist = matio.load('/home/mengmi/Proj/Proj_IT/Mat/FixationPatchStore_array.mat')
subjstore = trainbinlist['subjstore']
stimulistore = trainbinlist['stimulistore']
patchstore = trainbinlist['patchstore']

TotalTrials = patchstore:size()
TotalTrials = TotalTrials[2] --number of trials required
targetsize = 28
stimulisize = 224

for i=1,TotalTrials do

   subjind = subjstore[1][i]
   stimuliind = stimulistore[1][i]
   patchind = patchstore[1][i]

   -- load the image as a RGB float tensor with values 0..1
   --imagename = string.format( "%08d", i )
   imagename_stimuli = '/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/Human/stimuli/array_' .. stimuliind .. '.jpg'
   imagename_target = '/media/mengmi/TOSHIBA2/Proj_IT/Datasets/FixationPatchArray_224/subj_' .. subjind .. '_stimuli_' .. stimuliind .. '_patch_' .. patchind .. '.jpg'
   
   local stimuli = image.load(imagename_stimuli, 1, 'float')   
   stimuli = torch.cat({stimuli, stimuli, stimuli}, 1)   
   stimuli = image.scale(stimuli, stimulisize, stimulisize)
   stimuli = preprocess(stimuli)

   local target = image.load(imagename_target, 1, 'float')   
   target = torch.cat({target, target, target}, 1)   
   target = image.scale(target, targetsize, targetsize)
   target = preprocess(target)

   -- View as mini-batch of size 1
   local batch_stimuli = stimuli:view(1, table.unpack(stimuli:size():totable()))
   local batch_target = target:view(1, table.unpack(target:size():totable()))

   -- Get the output of the softmax
   local output_stimuli = model_stimuli:forward(batch_stimuli:cuda()):squeeze()  
   local output_target = model_target:forward(batch_target:cuda())

   --savefile = '/home/mengmi/Desktop/target_map1_img2.mat'
   --matio.save(savefile,output_target:double())
   --savefile = '/home/mengmi/Desktop/stimuli_map1_img2.mat'
   --matio.save(savefile,output_stimuli:double())

   --print('target')
   --print(output_target:size())
   --print('stimuli')
   --print(output_stimuli:size())
   --size: 512 by 28 by 28; size: 512 by 4 by 4
   -- output of last fc layer
   --out = model.modules[ChosenLayer].output

   
   MMconv.weight = output_target
   --MMconv.bias = 0
   --print('MMconv weight')
   --print(MMconv.weight:size())
   --print('MMconv bias')
   --print(MMconv.bias)
   

   out = MMconv:forward(output_stimuli:view(1, table.unpack(output_stimuli:size():totable()))):squeeze()
   --print(out:size())

   -- Get the top 5 class indexes and probabilities
   --local probs, indexes = output:topk(N, true, true)

   print('trial#: ' .. i .. ' #layer: ' .. MyLayer)
   savefile = '/media/mengmi/TOSHIBA2/Proj_IT/results/PatchArrayAttentionMap/subj_' .. subjind .. '_stimuli_' .. stimuliind .. '_patch_' .. patchind .. '_layer_' .. MyLayer .. '.mat'
   matio.save(savefile,out:double())
   

end

os.exit()










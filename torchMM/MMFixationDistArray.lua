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
print(cmodel)

model_stimuli = nn.Sequential()
TotalLayer = 40
for i=1,TotalLayer do --total number of layers: 40       
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

criterion = nn.MSECriterion()
criterion = criterion:cuda()

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
targetsize = 224
stimulisize = 224
DistMat = torch.Tensor(TotalTrials,TotalLayer)
Rsize = 224

for i=1,TotalTrials do

   subjind = subjstore[1][i]
   stimuliind = stimulistore[1][i]
   patchind = patchstore[1][i]

   -- load the image as a RGB float tensor with values 0..1
   --imagename = string.format( "%08d", i )
   imagename_target = '/media/mengmi/TOSHIBABlue1/Proj_VS/Datasets/Human/stimuli/target_' .. stimuliind .. '.jpg'
   imagename_stimuli = '/media/mengmi/TOSHIBA2/Proj_IT/Datasets/FixationPatchArray_' .. Rsize .. '/subj_' .. subjind .. '_stimuli_' .. stimuliind .. '_patch_' .. patchind .. '.jpg'
   
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

   for l = 1,TotalLayer do
        
	loss = criterion:forward(model_stimuli.modules[l].output, model_target.modules[l].output)
        
	DistMat[i][l] = loss
        print('trial#: ' .. i .. ' layer#: ' .. l .. ' #loss: ' .. loss)
   end

   
   
   

end

savefile = '/home/mengmi/Proj/Proj_IT/Mat/distarray_' .. Rsize .. '.mat'
matio.save(savefile,DistMat:double())
print('done')
os.exit()










--[[
    Copyright (c) 2015-present, Facebook, Inc.
    All rights reserved.

    This source code is licensed under the BSD-style license found in the
    LICENSE file in the root directory of this source tree. An additional grant
    of patent rights can be found in the PATENTS file in the same directory.
]]--

-- Heavily moidifed by Carl to make it simpler

-- modified by Mengmi Zhang 


require 'torch'
require 'image'
tds = require 'tds'
torch.setdefaulttensortype('torch.FloatTensor')
local class = require('pl.class')

local dataset = torch.class('dataLoader')

-- this function reads in the data files
function dataset:__init(args)
  for k,v in pairs(args) do self[k] = v end

  assert(self.frameSize > 0)

  if self.filenamePad == nil then
    self.filenamePad = 8
  end

  -- read text file consisting of frame directories and counts of frames
  self.data = tds.Vec()
  self.datamask = tds.Vec()
  
  
  --print('reading ' .. args.data_list)
  
  for line in io.lines(args.data_list) do 
    local split = {}
    for k in string.gmatch(line, "%S+") do table.insert(split, k) end
    self.data:insert(split[1])
  end

  for line in io.lines(args.data_listmask) do 
    local split = {}
    for k in string.gmatch(line, "%S+") do table.insert(split, k) end
    self.datamask:insert(split[1])
  end

  

  

  print('found Mengmi: ' .. #self.data .. ' images')
  print('found Mengmi: ' .. #self.datamask .. ' masks')
  
  
end

function dataset:size()
  return #self.data
end

-- converts a table of samples (and corresponding labels) to a clean tensor
function dataset:tableToOutput(dataTable, maskTable)
   local data, scalarLabels, labels, maskdata

   --data
   local quantity = #dataTable
   assert(dataTable[1]:dim() == 4)
   data = torch.Tensor(quantity, 3, self.frameSize, self.fineSize, self.fineSize)
   for i=1,#dataTable do
      data[i]:copy(dataTable[i])
   end

   --mask
   local quantitymask = #maskTable
   assert(maskTable[1]:dim() == 4)
   maskdata = torch.Tensor(quantitymask, 1, self.frameSize, self.fineSizeMask, self.fineSizeMask)
   for i=1,#maskTable do
      maskdata[i]:copy(maskTable[i])
   end

   return data, maskdata
end

-- sampler, samples with replacement from the training set.
function dataset:sample(quantity)
   assert(quantity)
   local dataTable = {}
   local maskTable = {}
   
   for i=1,quantity do
      local idx = torch.random(1, #self.data)

      local maskdata_path = self.data_root .. '/' .. self.datamask[idx]
      local outmask = self:trainHookMengmiMask(maskdata_path)
      table.insert(maskTable, outmask)
      
      

      local data_path = self.data_root .. '/' .. self.data[idx]
      local out = self:trainHook(data_path)
      table.insert(dataTable, out)      

   end
   return self:tableToOutput(dataTable, maskTable)
end

-- gets data in a certain range
function dataset:get(start_idx,stop_idx)
   local dataTable = {}
   local maskTable = {}

   for idx=start_idx,stop_idx do

      local maskdata_path = self.data_root .. '/' .. self.datamask[idx]
      local outmask = self:trainHookMengmiMask(maskdata_path)
      table.insert(maskTable, outmask)

      

      local data_path = self.data_root .. '/' .. self.data[idx]
      local out = self:trainHook(data_path)
      table.insert(dataTable, out)        

   end
   return self:tableToOutput(dataTable, maskTable)

end

-- function to load the image, jitter it appropriately (random crops etc.)
function dataset:trainHook(path)
  collectgarbage()

  local oW = self.fineSize
  local oH = self.fineSize 
  local h1
  local w1

  local out = torch.zeros(3, self.frameSize, oW, oH)

  local ok,input = pcall(image.load, path, 3, 'float') 
  if not ok then
     print('warning: failed loading: ' .. path)
     return out  
  end
  input= image.scale(input, opt.fineSize, opt.fineSize)
  
  for fr=1,self.frameSize do
    input = self:preprocess(input)    
    out[{ {}, fr, {}, {} }]:copy(input)
  end 

  return out
end

-- function to load the image, jitter it appropriately (random crops etc.) but for 1 dim mask
function dataset:trainHookMengmiMask(path)
  collectgarbage()

  local oW = self.fineSizeMask
  local oH = self.fineSizeMask 
  local h1
  local w1

  local out = torch.zeros(1, self.frameSize, oW, oH)

  local ok,input = pcall(image.load, path, 1, 'float') 
  if not ok then
     print('warning: failed loading: ' .. path)
     return out
  end
  
  for fr=1,self.frameSize do
    out[{ {}, fr, {}, {} }]:copy(image.scale(input, opt.fineSizeMask, opt.fineSizeMask))
  end

  return out
end


function dataset:preprocess(img)
  local mean_rgb = torch.DoubleTensor({123.68, 116.779, 103.939})
  img = img * 256.0                                 -- change range to 0 and 255
  -- subtract mean
  for i=1,3 do
    img[{ i, {}, {} }]:add(-mean_rgb[i])
  end
  img = img:index(1, torch.LongTensor{3, 2, 1})
  return img
end

-- data.lua expects a variable called trainLoader
trainLoader = dataLoader(opt)

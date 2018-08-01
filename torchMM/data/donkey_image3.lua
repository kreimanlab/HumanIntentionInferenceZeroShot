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
  self.datalabel = tds.Vec()
  
  
  --print('reading ' .. args.data_list)
  
  for line in io.lines(args.data_list) do 
    local split = {}
    for k in string.gmatch(line, "%S+") do table.insert(split, k) end
    self.data:insert(split[1])
  end
  --print('done')
  for line in io.lines(args.data_listlabel) do 
    --local split = {}
    --for k in string.gmatch(line, "%S+") do table.insert(split, k) end
    --print(line)
    self.datalabel:insert(tonumber(line))
  end

  

  

  print('found Mengmi: ' .. #self.data .. ' images')
  print('found Mengmi: ' .. #self.datalabel .. ' masks')
  
  
end

function dataset:size()
  return #self.data
end

-- converts a table of samples (and corresponding labels) to a clean tensor
function dataset:tableToOutput(dataTable,labelTable)
   local data, scalarLabels, labels

   --data
   local quantity = #dataTable
   assert(dataTable[1]:dim() == 4)
   data = torch.Tensor(quantity, 3, self.frameSize, self.fineSize, self.fineSize)
   for i=1,#dataTable do
      data[i]:copy(dataTable[i])
   end

   --label
   local quantitymask = #labelTable   
   labels = torch.Tensor(quantitymask, 1)
   for i=1,#labelTable do
      labels[i]= labelTable[i]
   end

   return data, labels
end

-- sampler, samples with replacement from the training set.
function dataset:sample(quantity)
   assert(quantity)
   local dataTable = {}
   local labelTable = {}
   
   for i=1,quantity do
      local idx = torch.random(1, #self.data)
      local data_path = self.data_root .. '/' .. self.data[idx]
      local out = self:trainHook(data_path)
      table.insert(dataTable, out)      
      table.insert(labelTable, self.datalabel[idx])
   end
   return self:tableToOutput(dataTable,labelTable)
end

-- gets data in a certain range
function dataset:get(start_idx,stop_idx)
   local dataTable = {}
   local labelTable = {}

   for idx=start_idx,stop_idx do      

      local data_path = self.data_root .. '/' .. self.data[idx]
      local out = self:trainHook(data_path)
      table.insert(dataTable, out)        
      table.insert(labelTable, self.datalabel[idx])
   end
   return self:tableToOutput(dataTable,labelTable)

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

# What am I searching for?

Authors: Mengmi Zhang, Jiashi Feng, Joo Hwee Lim, Qi Zhao, and Gabriel Kreiman

This repository contains an implementation of a zero-shot deep learning model for inferring human intentions (what the human subject is searching for) based on fixation patterns. Our paper is currently under review.

An unofficial copy of our manuscript is [HERE](http://arxiv.org/abs/1807.11926).

## Project Description

Can we infer intentions and goals from a person's actions? As an example of this family of problems, we consider here whether it is possible to decipher what a person is searching for by decoding their eye movement behavior. We conducted two human psychophysics experiments on object arrays and natural images where we monitored subjects' eye movements while they were looking for a target object. Using as input the pattern of "error" fixations on non-target objects before the target was found, we developed a model (InferNet) whose goal was to infer what the target was. "Error" fixations share similar features with the sought target. The Infernet model uses a pre-trained 2D convolutional architecture to extract features from the error fixations and computes a 2D similarity map between the error fixation and all locations across the search image by modulating the search image via convolution across layers. InferNet consolidates the modulated response maps across layers via max pooling to keep track of the sub-patterns highly similar to features at error fixations and integrates these maps across all error fixations. InferNet successfully identifies the subject's goal and outperforms all the competitive null models, even without any object-specific training on the inference task. 

[![problemintro](img/Capture.JPG)](img/Capture.JPG)

## Pre-requisite

The code has been successfully tested on Ubuntu 14.04. GPU is highly recommended (6GB GPU memory at least). 

It requires the deep learning platform Torch7. Refer to [link](http://torch.ch/docs/getting-started.html) for installation.  

Matio package is required (save and load matlab arrays from Torch7). Refer to [link](https://github.com/soumith/matio-ffi.torch) for installation.

Loadcaffe package is required (load pre-trained caffe model to Torch7). Refer to [link](https://github.com/szagoruyko/loadcaffe) for installation.

Run the commands:
```
luarocks install image
luarocks install tds
```
Download our repository:
```
git clone https://github.com/kreimanlab/HumanIntentionInferenceZeroShot.git
```

Download the caffe VGG16 model from [HERE](https://drive.google.com/open?id=1AEJse0liaT8uJoLmImqhyJN2y2_6mDsJ) and place it in folder ```/Models/caffevgg16/```

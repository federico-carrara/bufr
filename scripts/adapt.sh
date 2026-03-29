#!/bin/bash

export CUDA_VISIBLE_DEVICES="0"

DATASET=MNIST-C

python adapt.py \   
    --data-root ./datasets/ \
    --output-dir ./ \
    --alg-config-dir ./configs/$DATASET/ \
    --data-config ./configs/$DATASET/dataset.yml \
    --alg-name fr \
    --seed 777 \
    --deterministic \
    --n-workers 4 \
    --pin-mem \
    --save-adapted-model

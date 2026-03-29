#!/bin/bash

export CUDA_VISIBLE_DEVICES="0"

DATASET=MNIST-C

python bufr.py \
    --data-root ./datasets/ \
    --output-dir ./ \
    --alg-configs-dir ./configs/$DATASET/ \
    --data-config ./configs/$DATASET/dataset.yml \
    --seed 777 \
    --deterministic \
    --n-workers 4 \
    --pin-mem \
    --save-adapted-model
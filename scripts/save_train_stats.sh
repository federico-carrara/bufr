#!/bin/bash

export CUDA_VISIBLE_DEVICES="0"

DATASET=MNIST-C

python save_train_stats.py \
    --data-root /group/jug/ruggiero/TTA/data \
    --output-dir /group/jug/ruggiero/TTA/results \
    --alg-config ./configs/$DATASET/save_train_stats.yml \
    --data-config ./configs/$DATASET/dataset.yml \
    --seed 777 \
    --deterministic \
    --n-workers 3 \
    --pin-mem

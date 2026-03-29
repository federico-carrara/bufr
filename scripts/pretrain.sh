#!/usr/bin/env bash

export CUDA_VISIBLE_DEVICES="0"

DATASET=MNIST-C

python pretrain.py \
    --data-root /group/jug/ruggiero/TTA/data \
    --output-dir /group/jug/ruggiero/TTA/results \
    --alg-config ./configs/$DATASET/pretrain.yml \
    --data-config ./configs/$DATASET/dataset.yml \
    --seed 777 \
    --test-accuracy \
    --deterministic \
    --n-workers 3 \
    --pin-mem \
    --wandb-project bufr_pretraining \


#!/bin/bash

export CUDA_VISIBLE_DEVICES="0"

DATASET=MNIST-C

python bufr.py \
    --data-root /group/jug/ruggiero/TTA/data/ \
    --output-dir /group/jug/ruggiero/TTA/results/ \
    --alg-config-dir ./configs/$DATASET/ \
    --data-config ./configs/$DATASET/dataset.yml \
    --seed 777 \
    --deterministic \
    --n-workers 3 \
    --pin-mem \
    --save-adapted-model
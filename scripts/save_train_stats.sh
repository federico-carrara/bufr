#!/bin/bash

export CUDA_VISIBLE_DEVICES="1"

python -m bufr.save_train_stats    --data-root ./datasets/ \
                              --output-dir ./ \
                              --alg-config ./configs/EMNIST-DA/save_train_stats.yml \
                              --data-config ./configs/EMNIST-DA/dataset.yml \
                              --seed 123 \
                              --deterministic \
                              --n-workers 4 \
                              --pin-mem

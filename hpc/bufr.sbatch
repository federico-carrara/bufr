#!/bin/bash
#SBATCH --job-name=bufr
#SBATCH --output=/group/jug/ruggiero/TTA/hpc_logs/bufr_%j.out
#SBATCH --error=/group/jug/ruggiero/TTA/hpc_logs/bufr_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64GB
#SBATCH --partition=gpuq
#SBATCH --gres=gpu:1
#SBATCH --time=01:00:00

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
#!/usr/bin/env bash
#SBATCH --job-name=pretrain
#SBATCH --output=logs/pretrain_%j.out
#SBATCH --error=logs/pretrain_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=24:00:00

python pretrain.py  --data-root ./datasets/ \
                    --output-dir ./ \
                    --alg-config ./configs/EMNIST-DA/pretrain.yml \
                    --data-config ./configs/EMNIST-DA/dataset.yml \
                    --seed 123 \
                    --test-accuracy \
                    --deterministic \
                    --n-workers 4 \
                    --pin-mem


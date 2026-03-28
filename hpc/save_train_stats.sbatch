#!/bin/bash
#SBATCH --job-name=save_train_stats
#SBATCH --output=logs/save_train_stats_%j.out
#SBATCH --error=logs/save_train_stats_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=24:00:00

python -m bufr.save_train_stats    --data-root ./datasets/ \
                              --output-dir ./ \
                              --alg-config ./configs/EMNIST-DA/save_train_stats.yml \
                              --data-config ./configs/EMNIST-DA/dataset.yml \
                              --seed 123 \
                              --deterministic \
                              --n-workers 4 \
                              --pin-mem

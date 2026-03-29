#!/bin/bash
#SBATCH --job-name=bufr_save_stats
#SBATCH --output=/group/jug/ruggiero/TTA/hpc_logs/save_train_stats_%j.out
#SBATCH --error=/group/jug/ruggiero/TTA/hpc_logs/save_train_stats_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64GB
#SBATCH --partition=gpuq
#SBATCH --gres=gpu:1
#SBATCH --time=01:00:00

python adapt.py     --data-root ./datasets/ \
                    --output-dir ./ \
                    --alg-configs-dir ./configs/EMNIST-DA/ \
                    --data-config ./configs/EMNIST-DA/dataset.yml \
                    --alg-name fr \
                    --seed 123 \
                    --deterministic \
                    --n-workers 4 \
                    --pin-mem

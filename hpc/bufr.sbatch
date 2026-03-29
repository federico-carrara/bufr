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

python bufr.py      --data-root ./datasets/ \
                    --output-dir ./ \
                    --alg-configs-dir ./configs/EMNIST-DA/ \
                    --data-config ./configs/EMNIST-DA/dataset.yml \
                    --seed 123 \
                    --deterministic \
                    --n-workers 4 \
                    --pin-mem
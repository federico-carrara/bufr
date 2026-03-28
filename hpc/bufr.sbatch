#!/bin/bash
#SBATCH --job-name=bufr
#SBATCH --output=logs/bufr_%j.out
#SBATCH --error=logs/bufr_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=24:00:00

python -m bufr.bufr      --data-root ./datasets/ \
                    --output-dir ./ \
                    --alg-configs-dir ./configs/EMNIST-DA/ \
                    --data-config ./configs/EMNIST-DA/dataset.yml \
                    --seed 123 \
                    --deterministic \
                    --n-workers 4 \
                    --pin-mem
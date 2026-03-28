#!/bin/bash
#SBATCH --job-name=adapt
#SBATCH --output=logs/adapt_%j.out
#SBATCH --error=logs/adapt_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=24:00:00

python -m bufr.adapt     --data-root ./datasets/ \
                    --output-dir ./ \
                    --alg-configs-dir ./configs/EMNIST-DA/ \
                    --data-config ./configs/EMNIST-DA/dataset.yml \
                    --alg-name fr \
                    --seed 123 \
                    --deterministic \
                    --n-workers 4 \
                    --pin-mem

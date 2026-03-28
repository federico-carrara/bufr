#!/usr/bin/env bash
#SBATCH --job-name=bufr-pretrain
#SBATCH --output=/group/jug/ruggiero/TTA/hpc_logs/pretrain_%j.out
#SBATCH --error=/group/jug/ruggiero/TTA/hpc_logs/pretrain_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpuq
#SBATCH --gres=gpu:1
#SBATCH --time=24:00:00


DATASET=MNIST-C

python pretrain.py  --data-root /group/jug/ruggiero/TTA/data \
                    --output-dir /group/jug/ruggiero/TTA/pretraining \
                    --alg-config ./configs/$DATASET/pretrain.yml \
                    --data-config ./configs/$DATASET/dataset.yml \
                    --seed 777 \
                    --test-accuracy \
                    --deterministic \
                    --n-workers 4 \
                    --pin-mem \
                    --wandb-project bufr_pretraining \


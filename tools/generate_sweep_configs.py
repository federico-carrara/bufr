#!/usr/bin/env python3
"""
Generate frozen sweep configuration snapshots from repo YAML configs.
"""

from __future__ import annotations

import argparse
import csv
import itertools
from copy import deepcopy
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import yaml


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate per-experiment YAML config snapshots for sweeps."
    )
    parser.add_argument(
        "--dataset-config-dir",
        required=True,
        help="Directory containing dataset.yml and task configs, e.g. configs/MNIST-C",
    )
    parser.add_argument(
        "--task-config",
        required=True,
        help="Task config filename inside the dataset config dir, e.g. save_train_stats.yml",
    )
    parser.add_argument(
        "--set",
        dest="overrides",
        action="append",
        default=[],
        help=(
            "Sweep override in the form key=value1,value2. "
            "Supports dotted keys for nested dictionaries."
        ),
    )
    parser.add_argument(
        "--output-root",
        default="sweeps",
        help="Root directory where generated sweep folders are written.",
    )
    parser.add_argument(
        "--prefix",
        default=None,
        help="Optional prefix inserted before dataset/task in the sweep folder name.",
    )
    return parser.parse_args()


def load_yaml(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    if not isinstance(data, dict):
        raise ValueError(f"Expected mapping at {path}, got {type(data).__name__}")
    return data


def parse_override(raw_override: str) -> tuple[str, list[Any]]:
    if "=" not in raw_override:
        raise ValueError(
            f"Malformed override '{raw_override}'. Expected format key=value1,value2"
        )

    key, raw_values = raw_override.split("=", 1)
    key = key.strip()
    if not key:
        raise ValueError(f"Malformed override '{raw_override}'. Key cannot be empty")
    if not raw_values.strip():
        raise ValueError(f"Malformed override '{raw_override}'. Value list cannot be empty")

    value_strs = [value.strip() for value in raw_values.split(",")]
    if any(value == "" for value in value_strs):
        raise ValueError(
            f"Malformed override '{raw_override}'. Empty values are not allowed"
        )

    values = [yaml.safe_load(value) for value in value_strs]
    return key, values


def get_nested_value(data: dict[str, Any], dotted_key: str) -> Any:
    current: Any = data
    traversed: list[str] = []
    for part in dotted_key.split("."):
        traversed.append(part)
        if not isinstance(current, dict) or part not in current:
            raise KeyError(
                f"Unknown override key '{dotted_key}' "
                f"(failed at '{'.'.join(traversed)}')"
            )
        current = current[part]
    return current


def set_nested_value(data: dict[str, Any], dotted_key: str, value: Any) -> None:
    current: Any = data
    parts = dotted_key.split(".")
    for part in parts[:-1]:
        current = current[part]
    current[parts[-1]] = value


def csv_value(value: Any) -> str:
    if isinstance(value, (dict, list)):
        return yaml.safe_dump(value, sort_keys=False).strip()
    return str(value)


def make_sweep_dir_name(dataset_dir: Path, task_config: str, prefix: str | None) -> str:
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    parts = [timestamp]
    if prefix:
        parts.append(prefix)
    parts.append(dataset_dir.name)
    parts.append(Path(task_config).stem)
    return "_".join(parts)


def main() -> None:
    args = parse_args()

    if not args.overrides:
        raise ValueError("At least one --set override is required to generate a sweep")

    dataset_config_dir = Path(args.dataset_config_dir).resolve()
    if not dataset_config_dir.is_dir():
        raise FileNotFoundError(f"Dataset config dir not found: {dataset_config_dir}")

    task_config_path = dataset_config_dir / args.task_config
    dataset_config_path = dataset_config_dir / "dataset.yml"

    if not task_config_path.is_file():
        raise FileNotFoundError(f"Task config not found: {task_config_path}")
    if not dataset_config_path.is_file():
        raise FileNotFoundError(f"Dataset config not found: {dataset_config_path}")

    base_task_config = load_yaml(task_config_path)
    dataset_config = load_yaml(dataset_config_path)

    parsed_overrides = [parse_override(raw_override) for raw_override in args.overrides]
    override_keys = [key for key, _ in parsed_overrides]
    if len(set(override_keys)) != len(override_keys):
        raise ValueError("Duplicate override keys are not allowed")

    # Fail fast on unknown keys before generating any files.
    for key, _ in parsed_overrides:
        get_nested_value(base_task_config, key)

    output_root = Path(args.output_root).resolve()
    sweep_dir = output_root / make_sweep_dir_name(dataset_config_dir, args.task_config, args.prefix)
    configs_dir = sweep_dir / "configs"
    configs_dir.mkdir(parents=True, exist_ok=False)

    with (sweep_dir / "dataset.yml").open("w", encoding="utf-8") as handle:
        yaml.safe_dump(dataset_config, handle, sort_keys=False)

    combinations = itertools.product(*(values for _, values in parsed_overrides))
    manifest_rows: list[dict[str, Any]] = []
    task_stem = Path(args.task_config).stem

    for index, combination in enumerate(combinations):
        config = deepcopy(base_task_config)
        combo_values = dict(zip(override_keys, combination))
        for key, value in combo_values.items():
            set_nested_value(config, key, value)

        config_rel_path = Path("configs") / f"{task_stem}_{index:03d}.yml"
        config_path = sweep_dir / config_rel_path
        with config_path.open("w", encoding="utf-8") as handle:
            yaml.safe_dump(config, handle, sort_keys=False)

        row = {
            "index": index,
            "config_path": str(config_rel_path),
            "dataset_config_path": "dataset.yml",
        }
        row.update(combo_values)
        manifest_rows.append(row)

    fieldnames = ["index", "config_path", "dataset_config_path", *override_keys]
    with (sweep_dir / "manifest.csv").open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        for row in manifest_rows:
            writer.writerow({key: csv_value(value) for key, value in row.items()})

    meta = {
        "created_at_utc": datetime.now(timezone.utc).isoformat(),
        "dataset_config_dir": str(dataset_config_dir),
        "dataset_config_path": str(dataset_config_path),
        "task_config_path": str(task_config_path),
        "output_root": str(output_root),
        "sweep_dir": str(sweep_dir),
        "override_keys": override_keys,
        "num_configs": len(manifest_rows),
    }
    with (sweep_dir / "meta.yml").open("w", encoding="utf-8") as handle:
        yaml.safe_dump(meta, handle, sort_keys=False)

    print(f"Created sweep in {sweep_dir}")
    print(f"Generated {len(manifest_rows)} configs from {task_config_path.name}")
    print("Override keys: " + ", ".join(override_keys))


if __name__ == "__main__":
    main()

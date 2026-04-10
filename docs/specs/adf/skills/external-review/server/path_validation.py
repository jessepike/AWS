"""Path validation for artifact file access."""

import os
from pathlib import Path


def validate_artifact_path(
    path: str,
    project_root: str,
    home_dir: str | None = None,
) -> str:
    """Validate artifact path is under project root or home directory.

    Returns resolved absolute path. Raises ValueError or FileNotFoundError.
    """
    if not os.path.isabs(path):
        raise ValueError(f"Path must be absolute: {path}")

    resolved = Path(path).resolve()
    project = Path(project_root).resolve()
    home = Path(home_dir).resolve() if home_dir else Path.home().resolve()

    if not resolved.is_relative_to(project) and not resolved.is_relative_to(home):
        raise ValueError(f"Path not under allowed directories: {path}")

    if not resolved.exists():
        raise FileNotFoundError(f"Artifact not found: {path}")

    return str(resolved)

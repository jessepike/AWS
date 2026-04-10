"""Tests for path validation — TDD."""

import pytest
from pathlib import Path

from path_validation import validate_artifact_path


class TestValidateArtifactPath:
    def test_path_under_project_root(self, tmp_path):
        artifact = tmp_path / "docs" / "brief.md"
        artifact.parent.mkdir(parents=True, exist_ok=True)
        artifact.write_text("content")
        result = validate_artifact_path(str(artifact), project_root=str(tmp_path))
        assert result == str(artifact)

    def test_path_under_home(self, tmp_path):
        artifact = tmp_path / "home" / "file.md"
        artifact.parent.mkdir(parents=True, exist_ok=True)
        artifact.write_text("content")
        result = validate_artifact_path(str(artifact), project_root="/nonexistent", home_dir=str(tmp_path / "home"))
        assert result == str(artifact)

    def test_rejects_path_outside_allowed(self, tmp_path):
        with pytest.raises(ValueError, match="not under allowed"):
            validate_artifact_path("/etc/passwd", project_root=str(tmp_path))

    def test_rejects_symlink_escape(self, tmp_path):
        """Symlink that resolves outside allowed dirs."""
        target = Path("/tmp/outside-target.md")
        link = tmp_path / "sneaky.md"
        try:
            link.symlink_to(target)
        except OSError:
            pytest.skip("Cannot create symlink")
        with pytest.raises(ValueError):
            validate_artifact_path(str(link), project_root=str(tmp_path))

    def test_rejects_traversal(self, tmp_path):
        with pytest.raises(ValueError):
            validate_artifact_path(str(tmp_path / ".." / ".." / "etc" / "passwd"), project_root=str(tmp_path))

    def test_file_not_found(self, tmp_path):
        with pytest.raises(FileNotFoundError):
            validate_artifact_path(str(tmp_path / "nonexistent.md"), project_root=str(tmp_path))

    def test_relative_path_rejected(self):
        with pytest.raises(ValueError, match="absolute"):
            validate_artifact_path("docs/brief.md", project_root="/tmp")

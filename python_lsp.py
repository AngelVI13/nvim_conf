"""Resolve the Ruff or ty executable for a Neovim Python buffer."""

import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tomllib

try:
    from packaging.requirements import InvalidRequirement, Requirement
    from packaging.version import Version
except ImportError:
    from pip._vendor.packaging.requirements import InvalidRequirement, Requirement
    from pip._vendor.packaging.version import Version


def requirements_file(path, seen, constraint=False):
    path = path.resolve()
    if path in seen:
        raise ValueError(f"Recursive requirements include: {path}")
    seen.add(path)
    lines = path.read_text().replace("\\\n", " ").splitlines()
    result = []
    for line in lines:
        line = re.split(r"\s+#", line.strip(), maxsplit=1)[0].strip()
        if not line or line.startswith("#"):
            continue
        parts = shlex.split(line)
        if parts[0] in ("-r", "--requirement", "-c", "--constraint"):
            if len(parts) != 2:
                raise ValueError(f"Invalid requirements include in {path}: {line}")
            is_constraint = constraint or parts[0] in ("-c", "--constraint")
            result.extend(requirements_file(path.parent / parts[1], seen, is_constraint))
        elif parts[0].startswith(("-r", "--requirement=", "-c", "--constraint=")):
            include = parts[0].split("=", 1)[1] if "=" in parts[0] else parts[0][2:]
            is_constraint = constraint or parts[0].startswith(("-c", "--constraint="))
            result.extend(requirements_file(path.parent / include, seen, is_constraint))
        elif not line.startswith("-"):
            result.append((re.split(r"\s+--", line, maxsplit=1)[0], "", constraint))
    seen.remove(path)
    return result


def project_requirements(path):
    requirements = []
    manifest = path / "pyproject.toml"
    has_project = False
    if manifest.is_file():
        with manifest.open("rb") as f:
            data = tomllib.load(f)
        project = data.get("project", {})
        groups = data.get("dependency-groups", {})
        uv = data.get("tool", {}).get("uv", {})
        has_project = bool(project or groups or uv.get("dev-dependencies"))
        requirements.extend((value, "", False) for value in project.get("dependencies", []))
        for extra, values in project.get("optional-dependencies", {}).items():
            requirements.extend((value, extra, False) for value in values)
        for values in groups.values():
            requirements.extend((value, "", False) for value in values if isinstance(value, str))
        requirements.extend((value, "", False) for value in uv.get("dev-dependencies", []))
    req_file = path / "requirements.txt"
    if req_file.is_file():
        has_project = True
        requirements.extend(requirements_file(req_file, set()))
    return has_project, requirements


def resolve(start, tool, fallback):
    directory = Path(start).resolve()
    if not directory.is_dir():
        directory = directory.parent
    root = directory
    requirements = []
    for parent in (directory, *directory.parents):
        has_project, found = project_requirements(parent)
        if has_project:
            root, requirements = parent, found
            break
        if (parent / ".git").exists():
            root = parent
            break

    matches = []
    constraints = []
    for text, extra, constraint in requirements:
        if not re.match(rf"(?i)^{re.escape(tool)}(?:\s|[<>=!~;\[@]|$)", text.strip()):
            continue
        try:
            req = Requirement(text)
        except InvalidRequirement as exc:
            raise ValueError(f"Invalid requirement {text!r}: {exc}") from exc
        if req.name.lower().replace("_", "-") == tool and (
            req.marker is None or req.marker.evaluate({"extra": extra})
        ):
            (constraints if constraint else matches).append(req)

    if not matches:
        executable = fallback / "bin" / tool
        if not os.access(executable, os.X_OK):
            raise ValueError(f"Pyenv Python 3.12 has no executable {tool}: {executable}")
        return root, executable

    env_root = root / ".venv"
    if not env_root.is_dir():
        raise ValueError(
            f"{tool} is declared in {root}, but no project .venv was found; "
            "sync the project dependencies"
        )
    executable = env_root / "bin" / tool
    if not os.access(executable, os.X_OK):
        raise ValueError(
            f"{tool} is declared in {root}, but {executable} is missing; "
            "sync the project dependencies"
        )
    result = subprocess.run([str(executable), "--version"], capture_output=True, text=True, check=True)
    version = Version(result.stdout.strip().split()[-1])
    for req in matches + constraints:
        if req.url or not req.specifier.contains(version, prereleases=True):
            raise ValueError(
                f"{executable} is version {version}, which cannot be verified against {req}; "
                "sync the project dependencies"
            )
    return root, executable


if __name__ == "__main__":
    try:
        root, executable = resolve(Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3]))
        print(json.dumps({"root": str(root), "executable": str(executable)}))
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        print(f"Python LSP: {exc}", file=sys.stderr)
        sys.exit(1)

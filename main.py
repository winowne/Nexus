import subprocess
from pathlib import Path


project_path = Path(__file__).resolve().parent

subprocess.run(["zsh", str(project_path / "installer.zsh")], check=True)
subprocess.run(["zsh", str(project_path / "nexus.plugin.zsh")], check=True)

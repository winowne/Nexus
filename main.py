import subprocess
import shutil
from pathlib import Path


project_path = Path(__file__).resolve().parent

#install zsh before running the zsh installer
if shutil.which("zsh") is None:
    print("zsh was not found. Installing zsh...")

    if shutil.which("apt-get") is not None:
        if shutil.which("sudo") is not None:
            subprocess.run(["sudo", "apt-get", "update"], check=True)
            subprocess.run(["sudo", "apt-get", "install", "-y", "zsh"], check=True)
        else:
            subprocess.run(["apt-get", "update"], check=True)
            subprocess.run(["apt-get", "install", "-y", "zsh"], check=True)
    elif shutil.which("pacman") is not None:
        if shutil.which("sudo") is not None:
            subprocess.run(["sudo", "pacman", "-S", "--needed", "--noconfirm", "zsh"], check=True)
        else:
            subprocess.run(["pacman", "-S", "--needed", "--noconfirm", "zsh"], check=True)
    elif shutil.which("dnf") is not None:
        if shutil.which("sudo") is not None:
            subprocess.run(["sudo", "dnf", "install", "-y", "zsh"], check=True)
        else:
            subprocess.run(["dnf", "install", "-y", "zsh"], check=True)
    else:
        raise RuntimeError("Could not find a supported package manager to install zsh")

subprocess.run(["zsh", str(project_path / "installer.zsh")], check=True)
subprocess.run(["zsh", str(project_path / "nexus.plugin.zsh")], check=True)

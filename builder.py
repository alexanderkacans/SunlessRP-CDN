import os
import shutil
import subprocess
import json
import time
from pathlib import Path

# ------------------------------
# Load settings.json
# ------------------------------

with open("settings.json", "r") as f:
    SETTINGS = json.load(f)

P = SETTINGS["paths"]
G = SETTINGS["git"]
C = SETTINGS["cdn"]
F = SETTINGS["fastdl"]
N = SETTINGS["normalization"]
FD = SETTINGS["folders"]
FIN = SETTINGS["finish"]

# ------------------------------
# Utility
# ------------------------------

def run(cmd):
    print(f"[RUN] {cmd}")
    return subprocess.run(cmd, shell=True).returncode

def detect_binary(path):
    try:
        with open(path, "rb") as f:
            chunk = f.read(4096)
            return b"\x00" in chunk
    except:
        return True

# ------------------------------
# Smart Normalization
# ------------------------------

def normalize_smart(root, mode):
    for path, dirs, files in os.walk(root):
        if ".git" in path:
            continue
        for file in files:
            full = os.path.join(path, file)
            if detect_binary(full):
                continue
            try:
                with open(full, "rb") as f:
                    data = f.read()
                if mode == "LF":
                    fixed = data.replace(b"\r\n", b"\n")
                else:
                    fixed = data.replace(b"\n", b"\r\n")
                if fixed != data:
                    with open(full, "wb") as f:
                        f.write(fixed)
                    print(f"[SMART] Fixed {mode} → {full}")
            except:
                pass

# ------------------------------
# Git LFS
# ------------------------------

def write_gitattributes():
    content = """
*.bsp filter=lfs diff=lfs merge=lfs -text
*.mdl filter=lfs diff=lfs merge=lfs -text
*.vtf filter=lfs diff=lfs merge=lfs -text
*.vmt filter=lfs diff=lfs merge=lfs -text
*.wav filter=lfs diff=lfs merge=lfs -text
*.mp3 filter=lfs diff=lfs merge=lfs -text
*.bz2 filter=lfs diff=lfs merge=lfs -text
*.dat filter=lfs diff=lfs merge=lfs -text
*.bin filter=lfs diff=lfs merge=lfs -text
"""
    with open(".gitattributes", "w") as f:
        f.write(content)
    print("[LFS] .gitattributes written")

def auto_lfs_track():
    patterns = [
        "*.bsp", "*.mdl", "*.vtf", "*.vmt",
        "*.wav", "*.mp3", "*.bz2", "*.dat", "*.bin"
    ]
    for p in patterns:
        run(f"git lfs track \"{p}\"")
    print("[LFS] Tracking patterns updated")

def auto_lfs_stage():
    run("git add .gitattributes")
    run("git add -u")
    print("[LFS] Staged LFS changes")

# ------------------------------
# Folder Creation
# ------------------------------

def ensure_folders():
    for key, folder in P.items():
        Path(folder).mkdir(parents=True, exist_ok=True)
    print("[FOLDERS] Ensured all folders from settings.json")

# ------------------------------
# CDN Cleaning
# ------------------------------

def clean_cdn():
    if not C["clean_before_build"]:
        print("[CLEAN] Skipped (disabled in settings.json)")
        return

    cdn = Path(P["cdn"])
    if not cdn.exists():
        print("[CLEAN] CDN folder missing, skipping")
        return

    for item in cdn.iterdir():
        if item.name == ".git" and G["preserve_git_folder_on_clean"]:
            continue
        if item.is_dir():
            shutil.rmtree(item)
        else:
            item.unlink()

    print("[CLEAN] CDN cleaned")

# ------------------------------
# Copy Addons
# ------------------------------

def copy_addons():
    src = Path(P["source_addons"])
    dst = Path(P["cdn_addons"])
    dst.mkdir(parents=True, exist_ok=True)

    if not src.exists():
        print("[COPY] No addons source folder, skipping")
        return

    for item in src.iterdir():
        target = dst / item.name
        if item.is_dir():
            shutil.copytree(item, target, dirs_exist_ok=True)
        else:
            shutil.copy(item, target)

    print("[COPY] Addons copied")

# ------------------------------
# Manifest
# ------------------------------

def generate_manifest():
    if not C["manifest"]["enabled"]:
        print("[MANIFEST] Skipped (disabled)")
        return

    manifest = {}
    for path, dirs, files in os.walk(P["cdn"]):
        for file in files:
            full = os.path.join(path, file)
            rel = os.path.relpath(full, P["cdn"])
            try:
                size = os.path.getsize(full)
            except OSError:
                size = 0
            manifest[rel] = size

    with open(os.path.join(P["cdn"], C["manifest"]["file"]), "w") as f:
        json.dump(manifest, f, indent=2)

    print("[MANIFEST] Generated")

# ------------------------------
# Version
# ------------------------------

def generate_version():
    if not C["version"]["enabled"]:
        print("[VERSION] Skipped (disabled)")
        return

    version = int(time.time())
    with open(os.path.join(P["cdn"], C["version"]["file"]), "w") as f:
        f.write(str(version))

    print(f"[VERSION] {version}")

# ------------------------------
# Empty Folder Cleanup
# ------------------------------

def delete_empty_folders():
    if not C["delete_empty_folders"]:
        print("[EMPTY] Skipped (disabled)")
        return

    removed = 0
    for path, dirs, files in os.walk(P["cdn"], topdown=False):
        if not dirs and not files:
            try:
                os.rmdir(path)
                removed += 1
            except:
                pass

    print(f"[EMPTY] Removed {removed} empty folders")

# ------------------------------
# FastDL Build
# ------------------------------

def build_fastdl():
    if not F["enabled"]:
        print("[FASTDL] Skipped (disabled)")
        return

    src = Path(P["source_garrysmod"])
    dst = Path(P["fastdl"])

    if not src.exists():
        print("[FASTDL] Source garrysmod missing")
        return

    for path, dirs, files in os.walk(src):
        for file in files:
            rel = os.path.relpath(os.path.join(path, file), src)
            target = dst / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy(os.path.join(path, file), target)

    print("[FASTDL] Build complete")

# ------------------------------
# Git Automation (Windows-safe)
# ------------------------------

def auto_git():
    if not G["auto_stage"] and not G["auto_commit"]:
        print("[GIT] Skipped (disabled)")
        return

    run("git add .")
    run("git commit -m \"Auto-update\"")

    if G["auto_stash_before_pull"]:
        run("git stash")

    result = subprocess.run("git rev-parse --abbrev-ref HEAD", shell=True, capture_output=True, text=True)
    branch = result.stdout.strip()

    print(f"[GIT] Current branch: {branch}")

    if G["auto_rebase"]:
        if run(f"git pull --rebase origin {branch}") != 0:
            if G["auto_rebase_abort_on_conflict"]:
                run("git rebase --abort")
            run(f"git pull origin {branch}")
    else:
        run(f"git pull origin {branch}")

    if G["auto_pop_stash"]:
        run("git stash pop")

    if G["push_normal_first"]:
        if run(f"git push origin {branch}") != 0 and G["push_force_if_needed"]:
            run(f"git push origin {branch} --force")

# ------------------------------
# Main
# ------------------------------

def main():
    print("===========================================")
    print(" SunlessRP CDN Builder — Starting")
    print("===========================================")

    write_gitattributes()
    auto_lfs_track()
    auto_lfs_stage()

    ensure_folders()
    clean_cdn()

    if N["apply_to_source"]:
        normalize_smart(P["source"], "LF")
    if N["apply_to_fastdl"]:
        normalize_smart(P["fastdl"], "LF")
    if N["apply_to_cdn"]:
        normalize_smart(P["cdn"], "CRLF")

    copy_addons()
    generate_manifest()
    generate_version()
    delete_empty_folders()
    build_fastdl()
    auto_git()

    if FIN["print_success_banner"]:
        print("===========================================")
        print(" SunlessRP CDN Build Complete — No Errors")
        print("===========================================")

if __name__ == "__main__":
    main()

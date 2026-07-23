import os
import shutil
import subprocess
import json
import time
from pathlib import Path
def run(cmd):
    print(f"[RUN] {cmd}")
    return subprocess.run(cmd, shell=True).returncode
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
def ensure_folders():
    required = [
        "source",
        "source/garrysmod",
        "source/garrysmod/addons",
        "source/garrysmod/lua/autorun/client",
        "cdn",
        "cdn/addons",
        "fastdl"
    ]
    for folder in required:
        Path(folder).mkdir(parents=True, exist_ok=True)
def clean_cdn():
    cdn = Path("cdn")
    for item in cdn.iterdir():
        if item.name == ".git":
            continue
        if item.is_dir():
            shutil.rmtree(item)
        else:
            item.unlink()
    print("[CLEAN] CDN cleaned")
def normalize_lf(root):
    for path, dirs, files in os.walk(root):
        for file in files:
            full = os.path.join(path, file)
            try:
                with open(full, "rb") as f:
                    data = f.read()
                data = data.replace(b"\r\n", b"\n")
                with open(full, "wb") as f:
                    f.write(data)
            except:
                pass
    print(f"[LF] Normalized LF in {root}")
def copy_addons():
    src = Path("source/garrysmod/addons")
    dst = Path("cdn/addons")
    for item in src.iterdir():
        target = dst / item.name
        if item.is_dir():
            shutil.copytree(item, target, dirs_exist_ok=True)
        else:
            shutil.copy(item, target)
    print("[COPY] Addons copied")
def generate_manifest():
    manifest = {}
    for path, dirs, files in os.walk("cdn"):
        for file in files:
            full = os.path.join(path, file)
            rel = os.path.relpath(full, "cdn")
            manifest[rel] = os.path.getsize(full)
    with open("cdn/manifest.json", "w") as f:
        json.dump(manifest, f, indent=2)
    print("[MANIFEST] Generated")
def generate_version():
    version = int(time.time())
    with open("cdn/version.txt", "w") as f:
        f.write(str(version))
    print(f"[VERSION] {version}")
def delete_empty_folders(root="cdn"):
    removed = 0
    for path, dirs, files in os.walk(root, topdown=False):
        if not dirs and not files:
            try:
                os.rmdir(path)
                removed += 1
            except:
                pass
    print(f"[EMPTY] Removed {removed} empty folders")
def build_fastdl():
    src = Path("source/garrysmod")
    dst = Path("fastdl")
    for path, dirs, files in os.walk(src):
        for file in files:
            rel = os.path.relpath(os.path.join(path, file), src)
            target = dst / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy(os.path.join(path, file), target)
    print("[FASTDL] Build complete")
def auto_git():
    run("git add .")
    run("git commit -m \"Auto-update\" || true")
    run("git stash")
    if run("git pull --rebase origin main") != 0:
        run("git rebase --abort")
        run("git pull origin main")
    run("git stash pop || true")
    if run("git push origin main") != 0:
        run("git push origin main --force")
def main():
    print("===========================================")
    print(" SunlessRP CDN Builder — Starting")
    print("===========================================")

    write_gitattributes()
    auto_lfs_track()
    auto_lfs_stage()

    ensure_folders()
    clean_cdn()
    normalize_lf("source")
    copy_addons()
    generate_manifest()
    generate_version()
    delete_empty_folders()
    build_fastdl()
    auto_git()

    print("===========================================")
    print(" SunlessRP CDN Build Complete — No Errors")
    print("===========================================")
if __name__ == "__main__":
    main()
import os
import shutil
import subprocess
import json
import time
import bz2
from pathlib import Path

CHUNK_SIZE = 100 * 1024 * 1024  # 100MB


# ---------------------------------------------------------
# Write .gitignore (bz2-only whitelist)
# ---------------------------------------------------------
def write_gitignore_bz2_only():
    content = """# Ignore EVERYTHING
*

# Allow folders
!*/

# Allow ONLY .bz2 files
!*.bz2
"""
    with open(".gitignore", "w") as f:
        f.write(content)
    print("[GITIGNORE] bz2-only whitelist written")


# ---------------------------------------------------------
# Write .gitattributes (safe LFS rules)
# ---------------------------------------------------------
def write_gitattributes():
    content = """*.bz2 filter=lfs diff=lfs -text
"""
    with open(".gitattributes", "w") as f:
        f.write(content)
    print("[GITATTRIBUTES] Written (safe LFS rules)")


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


# ---------------------------------------------------------
# Smart normalization
# ---------------------------------------------------------
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
                    print(f"[NORMALIZE] {mode} → {full}")
            except:
                pass


# ---------------------------------------------------------
# Load settings.json
# ---------------------------------------------------------
with open("settings.json", "r") as f:
    SETTINGS = json.load(f)

P = SETTINGS["paths"]
C = SETTINGS["cdn"]
F = SETTINGS["fastdl"]
N = SETTINGS["normalization"]
G = SETTINGS["git"]
FIN = SETTINGS["finish"]


# ---------------------------------------------------------
# Ensure folders exist
# ---------------------------------------------------------
def ensure_folders():
    for key, folder in P.items():
        Path(folder).mkdir(parents=True, exist_ok=True)
    print("[FOLDERS] Ensured")


# ---------------------------------------------------------
# Clean CDN
# ---------------------------------------------------------
def clean_cdn():
    if not C["clean_before_build"]:
        print("[CLEAN] Skipped")
        return

    cdn = Path(P["cdn"])
    if not cdn.exists():
        return

    for item in cdn.iterdir():
        if item.name == ".git":
            continue
        if item.is_dir():
            shutil.rmtree(item)
        else:
            item.unlink()

    print("[CLEAN] CDN wiped")


# ---------------------------------------------------------
# Copy addons (Lua only, to CDN)
# ---------------------------------------------------------
def copy_addons():
    src = Path(P["source_addons"])
    dst = Path(P["cdn_addons"])
    dst.mkdir(parents=True, exist_ok=True)

    if not src.exists():
        print("[ADDONS] No source addons")
        return

    for addon in src.iterdir():
        if not addon.is_dir():
            continue

        target_addon = dst / addon.name
        target_addon.mkdir(parents=True, exist_ok=True)

        lua_src = addon / "lua"
        if lua_src.exists():
            shutil.copytree(lua_src, target_addon / "lua", dirs_exist_ok=True)
            print(f"[ADDONS] Copied Lua for addon → {addon.name}")
        else:
            print(f"[ADDONS] No Lua folder for addon → {addon.name}")

    print("[ADDONS] Lua-only copy complete")


# ---------------------------------------------------------
# Build raw FastDL (assets only)
# ---------------------------------------------------------
VALID_FASTDL_ROOTS = [
    "materials",
    "models",
    "sound",
    "maps",
    "particles",
    "resource",
    "fonts"
]


def build_fastdl():
    if not F["enabled"]:
        print("[FASTDL] Disabled")
        return

    src_gm = Path(P["source_garrysmod"])
    dst_fastdl = Path(P["fastdl"])

    if not src_gm.exists():
        print("[FASTDL] Missing source/garrysmod")
        return

    print("[FASTDL] Building assets-only FastDL")

    for root in VALID_FASTDL_ROOTS:
        src_root = src_gm / root
        if not src_root.exists():
            continue

        for path, dirs, files in os.walk(src_root):
            for file in files:
                full_src = Path(path) / file
                rel = full_src.relative_to(src_gm)
                target = dst_fastdl / rel
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy(full_src, target)
                print(f"[FASTDL] {rel}")

    print("[FASTDL] Assets-only FastDL built")


# ---------------------------------------------------------
# Compress FastDL → bz2 (CDN only)
# ---------------------------------------------------------
def compress_fastdl_to_bz2():
    fastdl_root = Path(P["fastdl"])
    cdn_fastdl_root = Path(P["cdn"]) / "fastdl"
    cdn_fastdl_root.mkdir(parents=True, exist_ok=True)

    print("[BZ2] Compressing FastDL assets")

    for path, dirs, files in os.walk(fastdl_root):
        for file in files:
            full = Path(path) / file

            if full.suffix == ".bz2":
                continue

            try:
                with open(full, "rb") as f:
                    raw_data = f.read()

                compressed_data = bz2.compress(raw_data, compresslevel=9)

                rel = full.relative_to(fastdl_root)
                bz2_path = cdn_fastdl_root / (str(rel) + ".bz2")
                bz2_path.parent.mkdir(parents=True, exist_ok=True)

                with open(bz2_path, "wb") as f:
                    f.write(compressed_data)

                print(f"[BZ2] {bz2_path}")

            except Exception as e:
                print(f"[BZ2] ERROR {full}: {e}")

    print("[BZ2] Done")


# ---------------------------------------------------------
# Chunk large bz2 files
# ---------------------------------------------------------
def chunk_large_bz2():
    cdn_fastdl_root = Path(P["cdn"]) / "fastdl"

    print("[CHUNK] Checking bz2 files")

    for path, dirs, files in os.walk(cdn_fastdl_root):
        for file in files:
            full = Path(path) / file
            if not full.name.endswith(".bz2"):
                continue

            size = full.stat().st_size
            if size <= CHUNK_SIZE:
                continue

            print(f"[CHUNK] Chunking {full} ({size} bytes)")

            part_names = []
            with open(full, "rb") as f:
                index = 1
                while True:
                    chunk = f.read(CHUNK_SIZE)
                    if not chunk:
                        break
                    part_name = f"{full.name}.part{index}"
                    part_path = full.parent / part_name
                    with open(part_path, "wb") as pf:
                        pf.write(chunk)
                    part_names.append(part_name)
                    print(f"[CHUNK] Wrote {part_path}")
                    index += 1

            parts_file = full.parent / (full.name + ".parts")
            with open(parts_file, "w", newline="\n") as pf:
                pf.write(str(len(part_names)) + "\n")
                for name in part_names:
                    pf.write(name + "\n")

            print(f"[CHUNK] Parts file → {parts_file}")

            full.unlink()
            print(f"[CHUNK] Deleted original bz2 → {full}")

    print("[CHUNK] Complete")


# ---------------------------------------------------------
# Manifest
# ---------------------------------------------------------
def generate_manifest():
    if not C["manifest"]["enabled"]:
        print("[MANIFEST] Disabled")
        return

    manifest = {}
    for path, dirs, files in os.walk(P["cdn"]):
        for file in files:
            full = os.path.join(path, file)
            rel = os.path.relpath(full, P["cdn"])
            try:
                size = os.path.getsize(full)
            except:
                size = 0
            manifest[rel] = size

    with open(os.path.join(P["cdn"], C["manifest"]["file"]), "w") as f:
        json.dump(manifest, f, indent=2)

    print("[MANIFEST] Written")


# ---------------------------------------------------------
# Version
# ---------------------------------------------------------
def generate_version():
    if not C["version"]["enabled"]:
        print("[VERSION] Disabled")
        return

    version = int(time.time())
    with open(os.path.join(P["cdn"], C["version"]["file"]), "w") as f:
        f.write(str(version))

    print(f"[VERSION] {version}")


# ---------------------------------------------------------
# Delete empty folders
# ---------------------------------------------------------
def delete_empty_folders():
    if not C["delete_empty_folders"]:
        print("[EMPTY] Disabled")
        return

    removed = 0
    for path, dirs, files in os.walk(P["cdn"], topdown=False):
        if not dirs and not files:
            try:
                os.rmdir(path)
                removed += 1
            except:
                pass

    print(f"[EMPTY] Removed {removed} folders")


# ---------------------------------------------------------
# Git automation
# ---------------------------------------------------------
def auto_git():
    if not (G["auto_stage"] or G["auto_commit"] or G["auto_push"]):
        print("[GIT] Automation disabled")
        return

    if G["auto_stage"]:
        run("git add .")
    if G["auto_commit"]:
        run("git commit -m \"CDN Update\"")
    if G["auto_push"]:
        run("git push")


# ---------------------------------------------------------
# MAIN
# ---------------------------------------------------------
def main():
    print("===========================================")
    print(" SunlessRP CDN Builder — Starting")
    print("===========================================")

    write_gitignore_bz2_only()
    write_gitattributes()

    ensure_folders()
    clean_cdn()

    if N["apply_to_source"]:
        normalize_smart(P["source"], "LF")
    if N["apply_to_fastdl"]:
        normalize_smart(P["fastdl"], "CRLF")
    if N["apply_to_cdn"]:
        normalize_smart(P["cdn"], "CRLF")

    copy_addons()              # Lua-only to CDN/addons
    build_fastdl()             # assets-only FastDL
    compress_fastdl_to_bz2()   # FastDL → CDN/fastdl/*.bz2
    chunk_large_bz2()
    generate_manifest()
    generate_version()
    delete_empty_folders()
    auto_git()

    if FIN["print_success_banner"]:
        print("===========================================")
        print(" SunlessRP CDN Build Complete")
        print("===========================================")


if __name__ == "__main__":
    main()

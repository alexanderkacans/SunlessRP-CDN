import os
import shutil
import bz2
import json
import subprocess
from pathlib import Path

# ROOT PATHS
ROOT = Path(".")
SOURCE = ROOT / "source/garrysmod"
ADDONS = SOURCE / "addons"
FASTDL = ROOT / "fastdl"
CDN = ROOT / "cdn"
CDN_FASTDL = CDN / "fastdl"
CDN_ADDONS = CDN / "addons"

# SETTINGS
SETTINGS = json.load(open("settings.json", "r"))

# ASSET TARGETS FOR EXTRACTION
ASSET_TARGETS = {
    "materials": FASTDL / "materials",
    "models": FASTDL / "models",
    "sound": FASTDL / "sound",
    "maps": FASTDL / "maps",
    "particles": FASTDL / "particles",
    "resource": FASTDL / "resource",
    "fonts": FASTDL / "fonts"
}

def safe_copy(src, dst):
    dst.parent.mkdir(parents=True, exist_ok=True)
    if not dst.exists():
        shutil.copy2(src, dst)
        print(f"[COPY] {src} -> {dst}")
    else:
        print(f"[SKIP] Exists: {dst}")

def extract_assets():
    print("===========================================")
    print(" Extracting Assets From Addons → fastdl/")
    print("===========================================")

    if not ADDONS.exists():
        print("[ERROR] addons folder missing:", ADDONS)
        return

    for addon in ADDONS.iterdir():
        if not addon.is_dir():
            continue

        print(f"\n[ADDON] Scanning: {addon.name}")

        for asset_type, target_root in ASSET_TARGETS.items():
            asset_folder = addon / asset_type
            if not asset_folder.exists():
                continue

            print(f"[FOUND] {asset_type} in {addon.name}")

            for path, dirs, files in os.walk(asset_folder):
                for file in files:
                    src = Path(path) / file
                    rel = src.relative_to(asset_folder)
                    dst = target_root / rel
                    safe_copy(src, dst)

    print("\n[EXTRACT] Asset Extraction Complete")

def ensure_folders():
    FASTDL.mkdir(exist_ok=True)
    CDN.mkdir(exist_ok=True)
    CDN_FASTDL.mkdir(exist_ok=True)
    CDN_ADDONS.mkdir(exist_ok=True)

def clean_cdn():
    if CDN.exists():
        shutil.rmtree(CDN)
    CDN.mkdir()
    CDN_FASTDL.mkdir()
    CDN_ADDONS.mkdir()
    print("[CLEAN] CDN wiped")

def copy_lua():
    for addon in ADDONS.iterdir():
        lua_folder = addon / "lua"
        if lua_folder.exists():
            dst = CDN_ADDONS / addon.name / "lua"
            shutil.copytree(lua_folder, dst, dirs_exist_ok=True)
            print(f"[ADDONS] Copied Lua → {addon.name}")
        else:
            print(f"[ADDONS] No Lua folder → {addon.name}")
    print("[ADDONS] Lua copy complete")

def compress_bz2():
    for path, dirs, files in os.walk(FASTDL):
        for file in files:
            src = Path(path) / file
            rel = src.relative_to(FASTDL)
            dst = CDN_FASTDL / (str(rel) + ".bz2")
            dst.parent.mkdir(parents=True, exist_ok=True)

            with open(src, "rb") as f_in:
                with bz2.open(dst, "wb", compresslevel=9) as f_out:
                    f_out.write(f_in.read())

            print(f"[BZ2] {dst.name}")

    print("[BZ2] Compression complete")

def chunk_large_files():
    for path, dirs, files in os.walk(CDN_FASTDL):
        for file in files:
            src = Path(path) / file

            if src.stat().st_size > SETTINGS["chunk_size"]:
                part = 1
                with open(src, "rb") as f:
                    while True:
                        chunk = f.read(SETTINGS["chunk_size"])
                        if not chunk:
                            break
                        dst = src.with_suffix(f".part{part}")
                        with open(dst, "wb") as out:
                            out.write(chunk)
                        part += 1

                print(f"[CHUNK] {src.name}")

    print("[CHUNK] Chunking complete")

def remove_raw_files():
    removed = 0
    for path, dirs, files in os.walk(CDN_FASTDL):
        for file in files:
            src = Path(path) / file

            # Keep only .bz2 and .partX
            if not (src.suffix == ".bz2" or ".part" in src.name):
                src.unlink()
                removed += 1

    print(f"[CLEAN] Removed {removed} raw files (bz2-only CDN)")

def write_manifest():
    manifest = []
    for path, dirs, files in os.walk(CDN_FASTDL):
        for file in files:
            manifest.append(str(Path(path) / file))
    json.dump(manifest, open("cdn/manifest.json", "w"), indent=2)
    print("[MANIFEST] Written")

def write_version():
    version = SETTINGS["version_seed"] + 1
    SETTINGS["version_seed"] = version
    json.dump(SETTINGS, open("settings.json", "w"), indent=2)
    with open("cdn/version.txt", "w") as f:
        f.write(str(version))
    print(f"[VERSION] {version}")

def git_push():
    subprocess.run(["git", "add", "."], shell=True)
    subprocess.run(["git", "commit", "-m", "CDN Update"], shell=True)
    subprocess.run(["git", "push"], shell=True)
    print("[GIT] Push complete")

def main():
    print("===========================================")
    print(" SunlessRP CDN Builder — Starting")
    print("===========================================")

    ensure_folders()
    extract_assets()
    clean_cdn()
    copy_lua()
    compress_bz2()
    remove_raw_files()
    chunk_large_files()
    write_manifest()
    write_version()
    git_push()

    print("===========================================")
    print(" SunlessRP CDN Build Complete")
    print("===========================================")

if __name__ == "__main__":
    main()
import os
import shutil
import bz2
import json
import subprocess
from pathlib import Path

ROOT = Path(".")
SOURCE = ROOT / "source/garrysmod"
FASTDL = ROOT / "fastdl"
CDN = ROOT / "cdn"
CDN_FASTDL = CDN / "fastdl"
CDN_ADDONS = CDN / "addons"

SETTINGS = json.load(open("settings.json", "r"))

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
    addons = SOURCE / "addons"
    for addon in addons.iterdir():
        lua_folder = addon / "lua"
        if lua_folder.exists():
            dst = CDN_ADDONS / addon.name / "lua"
            shutil.copytree(lua_folder, dst, dirs_exist_ok=True)
            print(f"[ADDONS] Copied Lua for addon → {addon.name}")
        else:
            print(f"[ADDONS] No Lua folder for addon → {addon.name}")
    print("[ADDONS] Lua-only copy complete")

def build_fastdl():
    if not FASTDL.exists():
        print("[FASTDL] No assets found")
        return

    for path, dirs, files in os.walk(FASTDL):
        for file in files:
            src = Path(path) / file
            rel = src.relative_to(FASTDL)
            dst = CDN_FASTDL / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
    print("[FASTDL] Assets-only FastDL built")

def compress_bz2():
    for path, dirs, files in os.walk(CDN_FASTDL):
        for file in files:
            src = Path(path) / file
            if src.suffix == ".bz2":
                continue
            dst = src.with_suffix(src.suffix + ".bz2")
            with open(src, "rb") as f_in:
                with bz2.open(dst, "wb", compresslevel=9) as f_out:
                    f_out.write(f_in.read())
            print(f"[BZ2] {dst.name}")
    print("[BZ2] Done")

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
    print("[CHUNK] Complete")

def write_manifest():
    manifest = []
    for path, dirs, files in os.walk(CDN_FASTDL):
        for file in files:
            manifest.append(str(Path(path) / file))
    json.dump(manifest, open("cdn/manifest.json", "w"), indent=2)
    print("[MANIFEST] Written")

def write_version():
    version = SETTINGS["version_seed"]
    version += 1
    SETTINGS["version_seed"] = version
    json.dump(SETTINGS, open("settings.json", "w"), indent=2)
    with open("cdn/version.txt", "w") as f:
        f.write(str(version))
    print(f"[VERSION] {version}")

def git_push():
    subprocess.run(["git", "add", "."], shell=True)
    subprocess.run(["git", "commit", "-m", "CDN Update"], shell=True)
    subprocess.run(["git", "push"], shell=True)
    print("[RUN] git push")

def main():
    print("===========================================")
    print(" SunlessRP CDN Builder — Starting")
    print("===========================================")

    ensure_folders()
    clean_cdn()
    copy_lua()
    build_fastdl()
    compress_bz2()
    chunk_large_files()
    write_manifest()
    write_version()
    git_push()

    print("===========================================")
    print(" SunlessRP CDN Build Complete")
    print("===========================================")

if __name__ == "__main__":
    main()

-- SunlessRP CDN Chunk Reassembler + Gluapack-aware sync (client)

if not file then return end

local MANIFEST_PATH = "sunless_cdn_manifest.txt"
local OUTPUT_DIR = "sunless_cdn"

file.CreateDir(OUTPUT_DIR)

-- This is bumped automatically by your Gluapack auto-version tool
    LOCAL_PACK_VERSION = 2
local cdnVersion = nil

net.Receive("SunlessCDN_Version", function()
    cdnVersion = net.ReadUInt(32)
    LOCAL_PACK_VERSION = 2
end)

local function LoadManifest()
    if not file.Exists(MANIFEST_PATH, "GAME") then
        print("[SunlessCDN] No manifest on client.")
        return {}
    end

    local raw = file.Read(MANIFEST_PATH, "GAME")
    if not raw or raw == "" then return {} end

    local manifest = { version = 0 }

    for line in string.gmatch(raw, "[^\r\n]+") do
        if string.StartWith(line, "VERSION|") then
            local ver = tonumber(string.sub(line, 9))
            manifest.version = ver or 0
        else
            local base, count = string.match(line, "(.+)|(%d+)")
            if base and count then
                manifest[base] = tonumber(count)
            end
        end
    end

    return manifest
end

local function Reassemble(base, chunkCount)
    local data = ""

    for i = 1, chunkCount do
        local chunkPath = base .. ".part" .. i
        if file.Exists(chunkPath, "GAME") then
            local chunkData = file.Read(chunkPath, "GAME")
            if chunkData then
                data = data .. chunkData
            end
        else
            print("[SunlessCDN] Missing chunk:", chunkPath)
            return
        end
    end

    if #data > 0 then
        local safeName = string.gsub(base, "[/:]", "_")
        local outPath = OUTPUT_DIR .. "/" .. safeName
        file.Write(outPath, data)
        print("[SunlessCDN] Reassembled:", base, "->", outPath)
    end
end

local function ProcessManifest()
    local manifest = LoadManifest()
    if not manifest.version or manifest.version == 0 then
        print("[SunlessCDN] Manifest has no version.")
        return
    end

    if not cdnVersion then
        print("[SunlessCDN] No CDN version from server yet, skipping.")
        return
    end

    LOCAL_PACK_VERSION = 2
        print("[SunlessCDN] Version mismatch, skipping reassembly.")
        return
    end

    for base, count in pairs(manifest) do
        if base ~= "version" then
            Reassemble(base, count)
        end
    end
end

hook.Add("Initialize", "SunlessCDN_ReassembleOnInit", function()
    timer.Simple(3, ProcessManifest)
end)
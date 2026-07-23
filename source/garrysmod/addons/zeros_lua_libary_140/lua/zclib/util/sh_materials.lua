zclib = zclib or {}
zclib.Materials = zclib.Materials or {}
zclib.Materials.List = zclib.Materials.List or {}

function zclib.Materials.Add(index,mat)
    zclib.Materials.List[index] = mat
end

function zclib.Materials.Get(index)
    return zclib.Materials.List[index]
end

zclib.Materials.Add("blur",Material("pp/blurscreen"))
zclib.Materials.Add("highlight",Material("zerochain/zerolib/shader/zlib_highlight"))
zclib.Materials.Add("beam01",Material("zerochain/zerolib/cable/zlib_beam"))
zclib.Materials.Add("glow01",Material("zerochain/zerolib/sprites/zlib_glow01"))
zclib.Materials.Add("light_sprite",Material("sprites/light_ignorez"))

zclib.Materials.Add("close",Material("materials/zerochain/zerolib/ui/icon_close.png", "noclamp smooth"))
zclib.Materials.Add("radial_shadow",Material("materials/zerochain/zerolib/ui/radial_shadow.png", "noclamp smooth"))
zclib.Materials.Add("linear_gradient",Material("materials/zerochain/zerolib/ui/linear_gradient.png", "smooth"))
zclib.Materials.Add("linear_gradient_a",Material("materials/zerochain/zerolib/ui/linear_gradient_a.png", "smooth"))
zclib.Materials.Add("scanlines",Material("materials/zerochain/zerolib/ui/scanlines.png", "smooth"))
zclib.Materials.Add("item_bg",Material("materials/zerochain/zerolib/ui/item_bg.png", "smooth"))
zclib.Materials.Add("icon_box01",Material("materials/zerochain/zerolib/ui/icon_box01.png", "smooth"))
zclib.Materials.Add("icon_loading",Material("materials/zerochain/zerolib/ui/icon_loading.png", "smooth"))
zclib.Materials.Add("icon_E",Material("materials/zerochain/zerolib/ui/icon_E.png", "smooth"))
zclib.Materials.Add("icon_mouse_left",Material("materials/zerochain/zerolib/ui/icon_mouse_left.png", "smooth"))
zclib.Materials.Add("icon_mouse_right",Material("materials/zerochain/zerolib/ui/icon_mouse_right.png", "smooth"))
zclib.Materials.Add("icon_locked",Material("materials/zerochain/zerolib/ui/icon_locked.png", "smooth"))
zclib.Materials.Add("radial_invert_glow",Material("materials/zerochain/zerolib/ui/radial_invert_glow.png", "smooth"))

zclib.Materials.Add("grib_horizontal",Material("materials/zerochain/zerolib/ui/grib_horizontal.png", "smooth noclamp"))
zclib.Materials.Add("circle_thick",Material("materials/zerochain/zerolib/ui/circle_thick.png", "noclamp smooth"))
zclib.Materials.Add("square_glow",Material("materials/zerochain/zerolib/ui/square_glow.png", "smooth noclamp"))

zclib.Materials.Add("edit",Material("materials/zerochain/zerolib/ui/edit.png", "smooth"))
zclib.Materials.Add("delete",Material("materials/zerochain/zerolib/ui/delete.png", "smooth"))
zclib.Materials.Add("plus",Material("materials/zerochain/zerolib/ui/plus.png", "smooth"))
zclib.Materials.Add("save",Material("materials/zerochain/zerolib/ui/save.png", "smooth"))
zclib.Materials.Add("duplicate",Material("materials/zerochain/zerolib/ui/duplicate.png", "smooth"))
zclib.Materials.Add("clipboard",Material("materials/zerochain/zerolib/ui/clipboard.png", "smooth"))

zclib.Materials.Add("repair",Material("materials/zerochain/zerolib/ui/repair.png", "smooth"))
zclib.Materials.Add("move",Material("materials/zerochain/zerolib/ui/move.png", "smooth"))

zclib.Materials.Add("refresh",Material("materials/zerochain/zerolib/ui/refresh.png", "smooth"))
zclib.Materials.Add("bottomshadow",Material("materials/zerochain/zerolib/ui/bottomshadow.png", "smooth"))
zclib.Materials.Add("accept",Material("materials/zerochain/zerolib/ui/icon_accept.png", "smooth"))

zclib.Materials.Add("star01",Material("materials/zerochain/zerolib/ui/star01.png", "smooth"))
zclib.Materials.Add("icon_hot",Material("materials/zerochain/zerolib/ui/icon_hot.png", "smooth"))

zclib.Materials.Add("whitelist",Material("materials/zerochain/zerolib/ui/whitelist.png", "smooth"))
zclib.Materials.Add("appearance",Material("materials/zerochain/zerolib/ui/appearance.png", "smooth"))

zclib.Materials.Add("time",Material("materials/zerochain/zerolib/ui/icon_time.png", "smooth"))
zclib.Materials.Add("mass",Material("materials/zerochain/zerolib/ui/icon_mass.png", "smooth"))

zclib.Materials.Add("money",Material("materials/zerochain/zerolib/ui/money.png", "smooth"))
zclib.Materials.Add("knob",Material("materials/zerochain/zerolib/ui/knob.png", "smooth"))

zclib.Materials.Add("info",Material("materials/zerochain/zerolib/ui/icon_info.png", "smooth"))
zclib.Materials.Add("robot",Material("materials/zerochain/zerolib/ui/robot.png", "smooth"))

zclib.Materials.Add("switch",Material("materials/zerochain/zerolib/ui/switch.png", "smooth"))

zclib.Materials.Add("warnstripes",Material("materials/zerochain/zerolib/ui/warnstripes.png", "smooth"))
zclib.Materials.Add("warnstripes_white",Material("materials/zerochain/zerolib/ui/warnstripes_white.png", "smooth"))

zclib.Materials.Add("infopointer",Material("materials/zerochain/zerolib/ui/hud_infopointer.png", "noclamp smooth"))

zclib.Materials.Add("back",Material("materials/zerochain/zerolib/ui/icon_back.png", "noclamp smooth"))
zclib.Materials.Add("next",Material("materials/zerochain/zerolib/ui/icon_next.png", "noclamp smooth"))

zclib.Materials.Add("upgrade",Material("materials/zerochain/zerolib/ui/icon_upgrade.png", "noclamp smooth"))

zclib.Materials.Add("rank",Material("materials/zerochain/zerolib/ui/icon_rank.png", "noclamp smooth"))
zclib.Materials.Add("job",Material("materials/zerochain/zerolib/ui/icon_job.png", "noclamp smooth"))


zclib.Materials.Add("mute",Material("materials/zerochain/zerolib/ui/icon_mute.png", "noclamp smooth"))
zclib.Materials.Add("volume",Material("materials/zerochain/zerolib/ui/icon_volume.png", "noclamp smooth"))

zclib.Materials.Add("minus",Material("materials/zerochain/zerolib/ui/minus.png", "noclamp smooth"))
zclib.Materials.Add("drop",Material("materials/zerochain/zerolib/ui/icon_drop.png", "noclamp smooth"))

zclib.Materials.Add("image",Material("materials/zerochain/zerolib/ui/icon_image.png", "noclamp smooth"))

zclib.Materials.Add("minimize",Material("materials/zerochain/zerolib/ui/icon_window02.png", "noclamp smooth"))
zclib.Materials.Add("fullscreen",Material("materials/zerochain/zerolib/ui/icon_window01.png", "noclamp smooth"))

zclib.Materials.Add("random",Material("materials/zerochain/zerolib/ui/random.png", "noclamp smooth"))
zclib.Materials.Add("statistic",Material("materials/zerochain/zerolib/ui/statistic.png", "noclamp smooth"))
zclib.Materials.Add("random_style",Material("materials/zerochain/zerolib/ui/random_style.png", "noclamp smooth"))

zclib.Materials.Add("audio_play",Material("materials/zerochain/zerolib/ui/play.png", "noclamp smooth"))
zclib.Materials.Add("audio_stop",Material("materials/zerochain/zerolib/ui/stop.png", "noclamp smooth"))

zclib.Materials.Add("circle_512",Material("materials/zerochain/zerolib/ui/circle_512.png", "noclamp smooth"))
zclib.Materials.Add("circle_48",Material("materials/zerochain/zerolib/ui/circle_48.png", "noclamp smooth"))
zclib.Materials.Add("circle_32",Material("materials/zerochain/zerolib/ui/circle_32.png", "noclamp smooth"))

zclib.Materials.Add("share",Material("materials/zerochain/zerolib/ui/icon_share.png", "noclamp smooth"))
zclib.Materials.Add("contract",Material("materials/zerochain/zerolib/ui/contract.png", "noclamp smooth"))
zclib.Materials.Add("link",Material("materials/zerochain/zerolib/ui/link.png", "noclamp smooth"))

zclib.colors = zclib.colors or {}

zclib.colors["black_a25"] = Color(0, 0, 0, 25)
zclib.colors["black_a50"] = Color(0, 0, 0, 50)
zclib.colors["black_a100"] = Color(0, 0, 0, 100)
zclib.colors["black_a150"] = Color(0, 0, 0, 150)
zclib.colors["black_a200"] = Color(0, 0, 0, 200)

zclib.colors["white_a100"] = Color(255, 255, 255, 100)
zclib.colors["white_a50"] = Color(255, 255, 255, 50)

zclib.colors["white_a15"] = Color(255, 255, 255, 15)
zclib.colors["white_a5"] = Color(255, 255, 255, 5)
zclib.colors["white_a2"] = Color(255, 255, 255, 2)

zclib.colors["textentry"] = Color(149, 152, 154)

zclib.colors["ui00"] = Color(33, 37, 43)
zclib.colors["ui01"] = Color(40, 44, 52)
zclib.colors["ui02"] = Color(54, 59, 69)
zclib.colors["ui03"] = Color(85, 95, 112)
zclib.colors["ui04"] = Color(45, 48, 56)
zclib.colors["ui_highlight"] = Color(62, 68, 81)
zclib.colors["text01"] = Color(144, 150, 162)
zclib.colors["ui02_grey"] = Color(72, 72, 72)



zclib.colors["red01"] = Color(224, 108, 117)
zclib.colors["red02"] = Color(164, 59, 59)
zclib.colors["green01"] = Color(152, 195, 121)
zclib.colors["green01_dark"] = Color(41, 52, 40)

zclib.colors["orange01"] = Color(209, 154, 102)
zclib.colors["orange02"] = Color(209, 130, 102)

zclib.colors["yellow01"] = Color(209, 185, 102)

zclib.colors["blue01"] = Color(86, 182, 194)
zclib.colors["blue02"] = Color(86, 114, 194)
zclib.colors["gmod_blue"] = Color(18, 149, 241)

zclib.colors["zone_red01"] = Color(224, 108, 117,100)
zclib.colors["zone_green01"] = Color(152, 195, 121,100)
zclib.colors["zone_white"] = Color(255, 255, 255, 100)

zclib.colors["slot_normal"] = Color(61, 66, 75)
zclib.colors["slot_selected"] = Color(70, 75, 85)

// Sets up static colors if they dont exist yet
if color_red == nil then color_red =  Color(255,0,0,255) end
if color_green == nil then color_green =  Color(0,255,0,255) end
if color_blue == nil then color_blue =  Color(0,0,255,255) end



if color_white == nil then color_white =  Color(255,255,255,255) end
if color_black == nil then color_black =  Color(0,0,0,255) end

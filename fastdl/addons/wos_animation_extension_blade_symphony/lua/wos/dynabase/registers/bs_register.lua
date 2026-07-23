
wOS.DynaBase:RegisterSource({
    Name = "Blade Symphony Extension",
    Type =  WOS_DYNABASE.EXTENSION,
    Shared = "models/player/wiltos/anim_extension_bs.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountBS", function( gender )
    if gender != WOS_DYNABASE.SHARED then return end
    IncludeModel( "models/player/wiltos/anim_extension_bs.mdl" )
end )

wOS.DynaBase:RegisterSource({
    Name = "Riddick Anim Extension",
    Type =  WOS_DYNABASE.EXTENSION,
    Shared = "models/player/wiltos/anim_extension_riddick.mdl",
})

hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountRiddick", function( gender )
    if gender != WOS_DYNABASE.SHARED then return end
    IncludeModel( "models/player/wiltos/anim_extension_riddick.mdl" )
end )
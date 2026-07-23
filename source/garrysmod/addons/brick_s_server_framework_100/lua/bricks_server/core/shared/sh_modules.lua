BRICKS_SERVER.DLCMODULES = {}
function BRICKS_SERVER.Func.AddDLCModule( id, table )
    BRICKS_SERVER.DLCMODULES[id] = table
end

BRICKS_SERVER.Func.AddDLCModule( "essentials", {
    ScriptID = 7244,
    Name = "Brick's Essentials", 
    Color = Color( 64, 126, 187 ),
    Icon = "materials/bricks_server/essentials.png", 
    Link ="https://www.gmodstore.com/market/view/bricks-essentials", 
    Description = "An all-in-one system that includes: F4 menu, Inventory, Crafting, HUD, Levelling, Printers, Marketplace, Zones, Bosses, Boosters and more!" ,
    Modules = { "essentials" }
} )

BRICKS_SERVER.Func.AddDLCModule( "gangs", {
    ScriptID = 7319,
    Name = "Brick's Gangs", 
    Color = Color( 255, 57, 57 ),
    Icon = "materials/bricks_server/gangs.png", 
    Link ="https://www.gmodstore.com/market/view/brick-s-gangs-territories-associations-achievements-more", 
    Description = "A gang system that includes Upgrades, Territories, Storage, Ranks, Achievements, Leaderboards and more!" ,
    Modules = { "gangs" }
} )

BRICKS_SERVER.Func.AddDLCModule( "unboxing", {
    ScriptID = 7476,
    Name = "Brick's Unboxing", 
    Color = Color( 26, 188, 156 ),
    Icon = "materials/bricks_server/unboxing.png", 
    Link = "https://www.gmodstore.com/market/view/brick-s-unboxing",
    Description = "An unboxing system that includes Crates, Keys, Trading, Marketplace, Shop and more!" ,
    Modules = { "unboxing" }
} )

BRICKS_SERVER.Func.AddDLCModule( "coinflip", {
    Name = "Brick's Coinflip", 
    Color = Color( 46, 204, 113 ),
    Icon = "materials/bricks_server/coinflip_64.png", 
    Link = "https://www.gmodstore.com/market/view/brick-s-coinflip-flip-items-and-money",
    Description = "A coinflip script that allows players to gamble their money and items!" ,
    Modules = { "coinflip" }
} )
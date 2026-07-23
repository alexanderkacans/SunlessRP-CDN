if SERVER then
  SetGlobalString("pac_version", "e91097172e578cf134ad488263a8d4133abc38a3")
end
function _G.PAC_VERSION()
  return GetGlobalString("pac_version")
end
concommand.Add("pac_version", function()
  print(PAC_VERSION())
end)

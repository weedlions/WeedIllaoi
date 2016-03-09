--                     __________________
--  ___      _________________  /__  /__(_)____________
--  __ | /| / /  _ \  _ \  __  /__  /__  /_  __ \_  __ \
--  __ |/ |/ //  __/  __/ /_/ / _  / _  / / /_/ /  / / /
--  ____/|__/ \___/\___/\__,_/  /_/  /_/  \____//_/ /_/

local ts
local minman
local myHero = GetMyHero()
local currentPred = nil
local healactive = false
local Version = 0.002
local OrbWalkers = {}
local tents = {}
local tentscount = 1
local LoadedOrb = nil
local enemy
local targets
local spirit

if myHero.charName ~= "Illaoi" then return end

function VPredLoader()
  local LibPath = LIB_PATH.."VPrediction.lua"
  if not (FileExist(LibPath)) then
    local Host = "raw.githubusercontent.com"
    local Path = "/SidaBoL/Scripts/master/Common/VPrediction.lua"
    DownloadFile("https://"..Host..Path, LibPath, function () prntChat("VPrediction installed. Please press 2x F9") end)
    require "VPrediction"
    currentPred = VPrediction()
  else
    require "VPrediction"
    currentPred = VPrediction()
  end
end
AddLoadCallback(function() VPredLoader() end)

function OnLoad()

  if(myHero.charName == "Illaoi") then
    prntChat("Welcome to Weed Illaoi. Good Luck, Have Fun!")
    prntChat("Version "..Version.." loaded.")
  end

  minman = minionManager(MINION_ALL, 850)

  ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 900, DAMAGE_PHYSICAL, false, true)

  initMenu()
  InitOrbs()
  LoadOrb()

end

function initMenu()

  Config = scriptConfig("Weed Illaoi", "weedill")

  Config:addSubMenu("Combo Settings", "settComb")
  Config.settComb:addSubMenu("Q Settings", "Q")
  Config.settComb:addSubMenu("W Settings", "W")
  --Config.settComb:addSubMenu("E Settings", "E")
  Config.settComb:addSubMenu("R Settings", "R")
  Config.settComb.Q:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
  --Config.settComb.Q:addParam("useqsp", "Use on Spirit", SCRIPT_PARAM_ONOFF, true)
  Config.settComb.W:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
  Config.settComb.W:addParam("usewrange", "Use W only if out of AA Range", SCRIPT_PARAM_ONOFF, true)
  Config.settComb.W:addParam("usewtent", "Use W only if Tentacle in Range", SCRIPT_PARAM_ONOFF, true)
  Config.settComb.W:addParam("usewult", "Always use W if Ult is active @Override All", SCRIPT_PARAM_ONOFF, true)
  --Config.settComb.E:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
  Config.settComb.R:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
  Config.settComb.R:addParam("count", "Use R when X enemies hit", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)

  Config:addSubMenu("Harass Settings", "settHar")
  Config.settHar:addSubMenu("Q Settings", "Q")
  Config.settHar:addSubMenu("W Settings", "W")
  --Config.settHar:addSubMenu("E Settings", "E")
  Config.settHar:addSubMenu("R Settings", "R")
  Config.settHar.Q:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
  --Config.settHar.Q:addParam("useqsp", "Use on Spirit", SCRIPT_PARAM_ONOFF, true)
  Config.settHar.W:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
  Config.settHar.W:addParam("usewrange", "Use W only if out of AA Range", SCRIPT_PARAM_ONOFF, true)
  Config.settHar.W:addParam("usewtent", "Use W only if Tentacle in Range", SCRIPT_PARAM_ONOFF, true)
  Config.settHar.W:addParam("usewult", "Always use W if Ult is active @Override All", SCRIPT_PARAM_ONOFF, true)
  --Config.settHar.E:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
  Config.settHar.R:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
  Config.settHar.R:addParam("count", "Use R when X enemies hit", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)

  Config:addSubMenu("LaneClear Settings", "settLC")
  Config.settLC:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
  Config.settLC:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
  Config.settLC:addParam("usewtent", "Use W only if Tentacle in Range", SCRIPT_PARAM_ONOFF, true)

  Config:addSubMenu("Draw Settings", "settDraw")
  Config.settDraw:addParam("qrange", "Draw Q Range", SCRIPT_PARAM_ONOFF, false)
  Config.settDraw:addParam("wrange", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
  Config.settDraw:addParam("erange", "Draw E Range", SCRIPT_PARAM_ONOFF, false)
  Config.settDraw:addParam("wayp", "Draw Waypoints", SCRIPT_PARAM_ONOFF, true)
  Config.settDraw:addParam("tentrange", "Draw Passive Ranges", SCRIPT_PARAM_ONOFF, true)

  Config:addSubMenu("Auto Potion Settings", "settPot")
  Config.settPot:addParam("active", "Use Auto Potion", SCRIPT_PARAM_ONOFF, true)
  Config.settPot:addParam("hp", "Min % HP to Activate", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)

  Config:addSubMenu("HitChance Settings", "settHit")
  Config.settHit:addParam("Blank", "HitChance for Q", SCRIPT_PARAM_INFO, "")
  Config.settHit:addParam("qhit", "HitChance: Recommended = 2", SCRIPT_PARAM_SLICE, 2, 2, 4, 0)
  Config.settHit:addParam("Blank", "HitChance for E", SCRIPT_PARAM_INFO, "")
  Config.settHit:addParam("ehit", "HitChance: Recommended = 2", SCRIPT_PARAM_SLICE, 2, 2, 4, 0)
  Config.settHit:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
  Config.settHit:addParam("Blank", "Explanation", SCRIPT_PARAM_INFO, "")
  Config.settHit:addParam("Blank", "2 = High Hitchance", SCRIPT_PARAM_INFO, "")
  Config.settHit:addParam("Blank", "3 = Slowed Targets (~100%)", SCRIPT_PARAM_INFO, "")
  Config.settHit:addParam("Blank", "4 = Immobile Targets (~100%)", SCRIPT_PARAM_INFO, "")

end

function OnTick()

  ts:update()
  minman:update()

  checkTents()
  --checkSpirit()

  targets = GetTarget()
  --if ValidTarget(targets) then print(targets.charName) end

  --if spirit ~= nil then print(spirit:GetDistance(myHero.pos)) end

  if(getMode() == "Laneclear") then onLaneClear() end

  if(getMode() == "Lasthit") then onLastHit() end

  if(getMode() == "Combo") then onCombo() end

  if(getMode() == "Harass") then onHarass() end

end

function onCombo()

  if targets == nil then return end
  if targets.team == myHero.team and not targets.bTargetable and not targets.visible and targets.dead then print("dead") return end

  --Q--
  if Config.settComb.Q.useq and myHero:CanUseSpell(_Q) then
    if GetDistance(targets.pos) < 850 then
      local CastPosition = predict(targets, "Q")
      if(CastPosition ~= nil) then CastSpell(_Q, CastPosition.x, CastPosition.z) end
    --[[elseif spirit ~= nil then
      if spirit:GetDistance(myHero.pos) < 850 then
        local CastPosition = predict(spirit, "Q")
        if(CastPosition ~= nil) then CastSpell(_Q, CastPosition.x, CastPosition.z) end
      end]]--
    end
  end
  --Q--

  --W--
  if Config.settComb.W.usewtent and myHero:CanUseSpell(_W) and Config.settComb.W.usew then
    for i, tent in pairs(tents) do
      if tent:GetDistance(targets.pos) < 825 then
        if Config.settComb.W.usewrange then
          if GetDistance(targets.pos) < 350 and Config.settComb.W.usewult and checkR() then
            CastSpell(_W)
          elseif GetDistance(targets.pos) < 350 and GetDistance(targets.pos) > 125 then
            CastSpell(_W)
          end
        else
          if GetDistance(targets.pos) < 350 then
            CastSpell(_W)
          end
        end
      end
    end
  elseif myHero:CanUseSpell(_W) and Config.settComb.W.usew then
    if Config.settComb.W.usewrange then
      if GetDistance(targets.pos) < 350 and Config.settComb.W.usewult and checkR() then
        CastSpell(_W)
      elseif GetDistance(targets.pos) < 350 and GetDistance(targets.pos) > 125 then
        CastSpell(_W)
      end
    else
      if GetDistance(targets.pos) < 350 then
        CastSpell(_W)
      end
    end
  end
  --W--

  --E--
  --[[if Config.settComb.E.usee and myHero:CanUseSpell(_E) then
    if GetDistance(targets.pos) < 900 then
      local CastPosition = predict(targets, "E")
      if(CastPosition ~= nil) then CastSpell(_E, CastPosition.x, CastPosition.z) end
    end
  end]]--
  --E--

  --R--
  if Config.settComb.R.user and myHero:CanUseSpell(_R ) then
    local count = 0;
    for i=1, heroManager.iCount do
      local tenemy = heroManager:getHero(i)

      if GetDistance(tenemy.pos) < 475 and tenemy.team ~= myHero.team then
        count = count +1
      end
    end

    if count >= Config.settComb.R.count then CastSpell(_R) end
  end
  --R--

end

function onHarass()

  if targets == nil then return end
  if targets.team == myHero.team and not targets.bTargetable and not targets.visible and targets.dead then print("dead") return end

  --Q--
  if Config.settHar.Q.useq and myHero:CanUseSpell(_Q) then
    if GetDistance(targets.pos) < 850 then
      local CastPosition = predict(targets, "Q")
      if(CastPosition ~= nil) then CastSpell(_Q, CastPosition.x, CastPosition.z) end
    --[[elseif spirit ~= nil then
      if spirit:GetDistance(myHero.pos) < 850 then
        local CastPosition = predict(spirit, "Q")
        if(CastPosition ~= nil) then CastSpell(_Q, CastPosition.x, CastPosition.z) end
      end]]--
    end
  end
  --Q--

  --W--
  if Config.settHar.W.usewtent and myHero:CanUseSpell(_W) and Config.settHar.W.usew then
    for i, tent in pairs(tents) do
      if tent:GetDistance(targets.pos) < 825 then
        if Config.settHar.W.usewrange then
          if GetDistance(targets.pos) < 350 and Config.settHar.W.usewult and checkR() then
            CastSpell(_W)
          elseif GetDistance(targets.pos) < 350 and GetDistance(targets.pos) > 125 then
            CastSpell(_W)
          end
        else
          if GetDistance(targets.pos) < 350 then
            CastSpell(_W)
          end
        end
      end
    end
  elseif myHero:CanUseSpell(_W) and Config.settHar.W.usew then
    if Config.settHar.W.usewrange then
      if GetDistance(targets.pos) < 350 and Config.settHar.W.usewult and checkR() then
        CastSpell(_W)
      elseif GetDistance(targets.pos) < 350 and GetDistance(targets.pos) > 125 then
        CastSpell(_W)
      end
    else
      if GetDistance(targets.pos) < 350 then
        CastSpell(_W)
      end
    end
  end
  --W--

  --E--
  --[[if Config.settHar.E.usee and myHero:CanUseSpell(_E) then
    if GetDistance(targets.pos) < 900 then
      local CastPosition = predict(targets, "E")
      if(CastPosition ~= nil) then CastSpell(_E, CastPosition.x, CastPosition.z) end
    end
  end]]--
  --E--

  --R--
  if Config.settHar.R.user and myHero:CanUseSpell(_R) then
    local count = 0;
    for i=1, heroManager.iCount do
      local tenemy = heroManager:getHero(i)

      if GetDistance(tenemy.pos) < 475 and tenemy.team ~= myHero.team then
        count = count +1
      end
    end

    if count >= Config.settHar.R.count then CastSpell(_R) end
  end
  --R--

end

function onLaneClear()

  for i, minion in pairs(minman.objects) do
    if(minion.bTargetable and minion.valid and minion.team ~= myHero.team) then
      if Config.settLC.useq and myHero:CanUseSpell(_Q) then
        local CastPosition = predict(minion, "Q")
        if(CastPosition ~= nil) then CastSpell(_Q, CastPosition.x, CastPosition.z) end
      end
      
      if Config.settLC.usew and myHero:CanUseSpell(_W) then
        if Config.settLC.usewtent then
          for i, tent in pairs(tents) do
            if tent:GetDistance(minion.pos) < 825 and GetDistance(minion.pos) then
              CastSpell(_W)
            end
          end
        elseif GetDistance(minion.pos) < 350 then CastSpell(_W) end
      end
    end
  end

end

function onLastHit()



end

function OnDraw()

  if Config.settDraw.tentrange then
    for i, tent in pairs(tents) do
      DrawCircle(tent.x, tent.y, tent.z, 825, 0xffffff)
    end
  end

  if Config.settDraw.qrange then
    DrawCircle(myHero.x, myHero.y, myHero.z, 850, 0x111111)
  end

  if Config.settDraw.wrange then
    DrawCircle(myHero.x, myHero.y, myHero.z, 350, 0x111111)
  end

  if Config.settDraw.erange then
    DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0x111111)
  end

  if Config.settDraw.wayp then
    for i=1, heroManager.iCount do
      local enemy = heroManager:getHero(i)

      if enemy.team ~= myHero.team and not enemy.dead then
        currentPred:DrawSavedWaypoints(enemy, 1)
      end
    end
  end

  --[[for i, tent in pairs(tents) do
    DrawTextA(tent:GetDistance(myHero.pos),12,20,20*i+20)
  end]]--

end

function checkTents()

  for i, tent in pairs(tents) do
    if tent:GetDistance(myHero.pos) == 0 then
      table.remove(tents, i)
    elseif tent.dead then
      table.remove(tents, i)
    end
  end

end

function checkSpirit()

  if spirit == nil then return end

  if spirit:GetDistance(myHero.pos) == 0 then
    spirit = nil
  elseif spirit.dead then
    spirit = nil
  end

end

function predict(target, spell)

  if(spell == "Q") then
    local CastPosition, HitChance, Position = currentPred:GetLineCastPosition(target, 0.80, 75, 850, math.huge, myHero, false)
    if CastPosition and HitChance >= Config.settHit.qhit and GetDistance(CastPosition) < 820 then
      return CastPosition
    end
  elseif(spell == "E") then
    local CastPosition, HitChance, Position = currentPred:GetLineCastPosition(target, 0.1, 30, 900, 1500, myHero, true)
    if CastPosition and HitChance >= Config.settHit.ehit and GetDistance(CastPosition) < 870 then
      return CastPosition
    end
  else return nil
  end

end

function GetTarget()

  ts:update()
  return ts.target

end

function autoPotion()

  local hac = false

  for i = 1, myHero.buffCount do
    local tBuff = myHero:getBuff(i)
    if BuffIsValid(tBuff) then
      if(tBuff.name == "ItemMiniRegenPotion" or tBuff.name == "RegenerationPotion") then hac = true end
    end
  end

  if hac then healactive = true
  else healactive = false end

  if ((myHero.health/myHero.maxHealth)*100) < Config.settPot.hp and not healactive then
    CastItem("ItemMiniRegenPotion")
    CastItem("RegenerationPotion")
  end

end

function checkR()

  for i = 1, myHero.buffCount do
    local tBuff = myHero:getBuff(i)
    if BuffIsValid(tBuff) then
      if(tBuff.name == "IllaoiR") then return true end
    end
  end

  return false

end

function prntChat(message)

  PrintChat("<font color=\"#0B6121\"><b>--Weed Illaoi--</b></font> ".."<font color=\"#FFFFFF\"><b>"..message..".</b></font>")

end

function OnCreateObj(obj)
  if(obj.name == "Illaoi_Base_P_TentacleAvatarActive.troy") then
    table.insert(tents, obj)
  elseif(obj.name == "Illaoi_Base_P_TentacleAvatarDormant.troy") then
    for i, tent in pairs(tents) do
      if tent.networkID == obj.networkID then table.remove(tents, i) end
    end
  elseif(obj.name == "Illaoi_Base_E_Spirit.troy") then
    spirit = obj
  end
end



function InitOrbs()
  if _G.Reborn_Loaded or _G.Reborn_Initialised or _G.AutoCarry ~= nil then
    table.insert(OrbWalkers, "SAC")
  end
  if _G.MMA_IsLoaded then
    table.insert(OrbWalkers, "MMA")
  end
  if _G._Pewalk then
    table.insert(OrbWalkers, "Pewalk")
  end
  if FileExist(LIB_PATH .. "/Nebelwolfi's Orb Walker.lua") then
    table.insert(OrbWalkers, "NOW")
  end
  if FileExist(LIB_PATH .. "/Big Fat Orbwalker.lua") then
    table.insert(OrbWalkers, "Big Fat Walk")
  end
  if FileExist(LIB_PATH .. "/SOW.lua") then
    table.insert(OrbWalkers, "SOW")
  end
  if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
    table.insert(OrbWalkers, "SxOrbWalk")
  end
  if #OrbWalkers > 0 then
    Config:addSubMenu("Orbwalkers", "Orbwalkers")
    Config:addSubMenu("Keys", "Keys")
    Config.Orbwalkers:addParam("Orbwalker", "OrbWalker", SCRIPT_PARAM_LIST, 1, OrbWalkers)
    Config.Keys:addParam("info", "Detecting keys from: "..OrbWalkers[Config.Orbwalkers.Orbwalker], SCRIPT_PARAM_INFO, "")
    local OrbAlr = false
    Config.Orbwalkers:setCallback("Orbwalker", function(value)
      if OrbAlr then return end
      OrbAlr = true
      Menu.Orbwalkers:addParam("info", "Press F9 2x to load your selected Orbwalker.", SCRIPT_PARAM_INFO, "")
      prntChat("Press F9 2x to load your selected Orbwalker")
    end)
  end
end

function LoadOrb()
  if OrbWalkers[Config.Orbwalkers.Orbwalker] == "SAC" then
    LoadedOrb = "Sac"
    TIMETOSACLOAD = false
    DelayAction(function() TIMETOSACLOAD = true end,15)
  elseif OrbWalkers[Config.Orbwalkers.Orbwalker] == "MMA" then
    LoadedOrb = "Mma"
  elseif OrbWalkers[Config.Orbwalkers.Orbwalker] == "Pewalk" then
    LoadedOrb = "Pewalk"
  elseif OrbWalkers[Config.Orbwalkers.Orbwalker] == "NOW" then
    LoadedOrb = "Now"
    require "Nebelwolfi's Orb Walker"
    _G.NOWi = NebelwolfisOrbWalkerClass()
    Config.Orbwalkers:addSubMenu("NOW", "NOW")
    _G.NebelwolfisOrbWalkerClass(Config.Orbwalkers.NOW)
  elseif OrbWalkers[Config.Orbwalkers.Orbwalker] == "Big Fat Walk" then
    LoadedOrb = "Big"
    require "Big Fat Orbwalker"
  elseif OrbWalkers[Config.Orbwalkers.Orbwalker] == "SOW" then
    LoadedOrb = "Sow"
    require "SOW"
    Config.Orbwalkers:addSubMenu("SOW", "SOW")
    _G.SOWi = SOW(_G.VP)
    SOW:LoadToMenu(Config.Orbwalkers.SOW)
  elseif OrbWalkers[Config.Orbwalkers.Orbwalker] == "SxOrbWalk" then
    LoadedOrb = "SxOrbWalk"
    require "SxOrbWalk"
    Config.Orbwalkers:addSubMenu("SxOrbWalk", "SxOrbWalk")
    SxOrb:LoadToMenu(Config.Orbwalkers.SxOrbWalk)
  end
end

function getMode()
  if LoadedOrb == "Sac" and TIMETOSACLOAD then
    if _G.AutoCarry.Keys.AutoCarry then return "Combo" end
    if _G.AutoCarry.Keys.MixedMode then return "Harass" end
    if _G.AutoCarry.Keys.LaneClear then return "Laneclear" end
    if _G.AutoCarry.Keys.LastHit then return "Lasthit" end
  elseif LoadedOrb == "Mma" then
    if _G.MMA_IsOrbwalking() then return "Combo" end
    if _G.MMA_IsDualCarrying() then return "Harass" end
    if _G.MMA_IsLaneClearing() then return "Laneclear" end
    if _G.MMA_IsLastHitting() then return "Lasthit" end
  elseif LoadedOrb == "Pewalk" then
    if _G._Pewalk.GetActiveMode().Carry then return "Combo" end
    if _G._Pewalk.GetActiveMode().Mixed then return "Harass" end
    if _G._Pewalk.GetActiveMode().LaneClear then return "Laneclear" end
    if _G._Pewalk.GetActiveMode().Farm then return "Lasthit" end
  elseif LoadedOrb == "Now" then
    if _G.NOWi.Config.k.Combo then return "Combo" end
    if _G.NOWi.Config.k.Harass then return "Harass" end
    if _G.NOWi.Config.k.LaneClear then return "Laneclear" end
    if _G.NOWi.Config.k.LastHit then return "Lasthit" end
  elseif LoadedOrb == "Big" then
    if _G["BigFatOrb_Mode"] == "Combo" then return "Combo" end
    if _G["BigFatOrb_Mode"] == "Harass" then return "Harass" end
    if _G["BigFatOrb_Mode"] == "LaneClear" then return "Laneclear" end
    if _G["BigFatOrb_Mode"] == "LastHit" then return "Lasthit" end
  elseif LoadedOrb == "Sow" then
    if _G.SOWi.Menu.Mode0 then return "Combo" end
    if _G.SOWi.Menu.Mode1 then return "Harass" end
    if _G.SOWi.Menu.Mode2 then return "Laneclear" end
    if _G.SOWi.Menu.Mode3 then return "Lasthit" end
  elseif LoadedOrb == "SxOrbWalk" then
    if _G.SxOrb.isFight then return "Combo" end
    if _G.SxOrb.isHarass then return "Harass" end
    if _G.SxOrb.isLaneClear then return "Laneclear" end
    if _G.SxOrb.isLastHit then return "Lasthit" end
  end
end


local serveradress = "raw.githubusercontent.com"
local scriptadress = "/weedlions/WeedIllaoi/master"
local scriptname = "WeedIllaoi"
local adressfull = "http://"..serveradress..scriptadress.."/"..scriptname..".lua"
function CheckUpdates()
  local ServerVersionDATA = GetWebResult(serveradress , scriptadress.."/"..scriptname..".version")
  if ServerVersionDATA then
    local ServerVersion = tonumber(ServerVersionDATA)
    if ServerVersion then
      if ServerVersion > tonumber(Version) then
        prntChat("Updating, don't press F9")
        DownloadUpdate()
      else
        prntChat("You have the latest version")
      end
    else
      prntChat("An error occured, while updating")
    end
  else
    prntChat("Could not connect to update Server")
  end
end

function DownloadUpdate()
  DownloadFile(adressfull, SCRIPT_PATH..scriptname..".lua", function ()
    prntChat("Updated, press 2x F9")
  end)
end
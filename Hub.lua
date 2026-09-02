-- ========================================
-- WIZARD HUB | RAYFIELD – FULLY WORKING WITH WALLBANG
-- ========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")

-- ===== ЗАГРУЗКА RAYFIELD =====
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

-- ===== НАСТРОЙКИ =====
local Settings = {
    SilentAim = false,
    Wallbang = false,
    FovRadius = 250,
    AimSmoothness = 0.3,
    AimTargetPart = "Head",
    EspEnabled = false,
    ChamsEnabled = false,
    ChamsColor = Color3.fromRGB(0, 255, 255),
    AuraEnabled = false,
    AuraColor = Color3.fromRGB(255, 0, 255),
    AuraSelected = {},
    ModelChanger = false,
    ChinaHatEnabled = false,
    ChinaHatStyle = "Classic",
    ChinaHatColor = Color3.fromRGB(255, 0, 0),
    ChinaHatTransparency = 0.3,
    ChinaHatReflectance = 0.3,
    ChinaHatRadius = 1.2,
    ChinaHatHeight = 0.8,
    ChinaHatRainbow = false,
    ChinaHatRainbowSpeed = 5,
    ChinaHatSides = 16,
    TrailsEnabled = false,
    TrailsColor = Color3.fromRGB(255, 0, 255),
    TrailsWidth = 0.5,
    TrailsLifetime = 0.8,
    VignetteEnabled = false,
    VignetteColor = Color3.fromRGB(0, 0, 0),
    VignetteOpacity = 0.5,
    TexturePackEnabled = false,
    StretchEnabled = false,
    StretchFactor = 0.5,
    ShaderPreset = "Default",
    CustomWorldEnabled = false,
    AmbientColor = Color3.fromRGB(127, 127, 127),
    Brightness = 1,
    FogEnabled = false,
    FogColor = Color3.fromRGB(128, 128, 128),
    FogStart = 0,
    FogEnd = 100,
    AnimPack = "Elder",
    InfiniteJump = false,
    BHopEnabled = false,
    BHopSpeed = 50,
    NoClip = false,
    AntiFling = false,
    SpinbotEnabled = false,
    SpinbotSpeed = 5,
    AntiAimEnabled = false,
    AntiAFKEnabled = false,
    WalkSpeed = 16,
    JumpPower = 50,
    AutoFarmCoins = false,
    AutoGrabGun = false,
    AutoKillMurderer = false,
    AutoKillAll = false,
    HitboxExpander = false,
    HitboxSize = 20,
    TeleportToMurderer = false,
    TeleportToSheriff = false,
    TeleportToGun = false,
    TeleportGranny = false,
    SkinPistolEnabled = false,
    SkinPistolSelected = "Default",
    SkinKnifeEnabled = false,
    SkinKnifeSelected = "Default",
    ShootButtonEnabled = false,
}

-- ===== КЭШ =====
local Cache = {
    FovCircle = nil,
    AimConnection = nil,
    EspTexts = {},
    AuraParticles = {},
    AuraCache = {},
    ModelHandle = nil,
    ChinaHatDrawings = {},
    ChinaHatParts = {},
    ChinaHatConnection = nil,
    TrailAttachments = {},
    Vignette = nil,
    ChamsPartsList = {},
    TextureState = {},
    TextureVariantsBuilt = false,
    StretchConnection = nil,
    BHopActive = false,
    BHopConn = nil,
    BHopBV = nil,
    SpinbotActive = false,
    SpinbotConn = nil,
    AntiAimActive = false,
    AntiAimHrpPos = nil,
    AntiAimParts = {},
    afkConn = nil,
    SkinConnection = nil,
    ShootButton = nil,
    FarmConnection = nil,
    GrannyHouse = nil,
    OriginalLighting = {},
    HitboxOriginalSizes = {},
}

-- Сохраняем оригинальные настройки освещения
Cache.OriginalLighting = {
    TimeOfDay = Lighting.TimeOfDay,
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    FogColor = Lighting.FogColor,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
}

-- ========================================
-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====
-- ========================================

local function isMurderer(player)
    if not player then return false end
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    return (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
end

local function isSheriff(player)
    if not player then return false end
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    return (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or
           (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver")))
end

local function hasGunInHand()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and (child.Name:lower():find("gun") or child.Name:lower():find("revolver")) then
            return true
        end
    end
    return false
end

local function findSheriff()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isSheriff(player) then
            return player
        end
    end
    return nil
end

local function findMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isMurderer(player) then
            return player
        end
    end
    return nil
end

local function notify(title, text, duration)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = duration or 2,
    })
end

local function safeDisconnect(conn)
    if conn then pcall(function() conn:Disconnect() end) end
end

-- ========================================
-- ===== WALLBANG ХУКИ =====
-- ========================================

local oldRaycast = workspace.Raycast
local oldFindPartOnRay = workspace.FindPartOnRay
local oldFindPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList

workspace.Raycast = function(origin, direction, raycastParams)
    if Settings.Wallbang then
        local newParams = RaycastParams.new()
        newParams.FilterType = Enum.RaycastFilterType.Blacklist
        newParams.FilterDescendantsInstances = {LocalPlayer.Character}
        return oldRaycast(origin, direction, newParams)
    else
        return oldRaycast(origin, direction, raycastParams)
    end
end

workspace.FindPartOnRay = function(ray, ignoreList)
    if Settings.Wallbang then
        local newRay = Ray.new(ray.Origin, ray.Direction * 1000)
        local ignore = {LocalPlayer.Character}
        return oldFindPartOnRay(newRay, ignore)
    else
        return oldFindPartOnRay(ray, ignoreList)
    end
end

workspace.FindPartOnRayWithIgnoreList = function(ray, ignoreList)
    if Settings.Wallbang then
        local newRay = Ray.new(ray.Origin, ray.Direction * 1000)
        local ignore = {LocalPlayer.Character}
        return oldFindPartOnRayWithIgnoreList(newRay, ignore)
    else
        return oldFindPartOnRayWithIgnoreList(ray, ignoreList)
    end
end

-- ========================================
-- ===== SILENT AIM =====
-- ========================================

local function getClosestMurdererInFov()
    if not LocalPlayer.Character then return nil end
    if not hasGunInHand() then return nil end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestP, bestDist = nil, math.huge
    local ignoreList = {LocalPlayer.Character, workspace.CurrentCamera}

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not isMurderer(player) then continue end
        if not player.Character then continue end
        local targetPart = player.Character:FindFirstChild(Settings.AimTargetPart) or player.Character:FindFirstChild("Head")
        if not targetPart then continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        if not Settings.Wallbang then
            local origin = Camera.CFrame.Position
            local direction = (targetPart.Position - origin).Unit
            local ray = Ray.new(origin, direction * (targetPart.Position - origin).Magnitude)
            local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
            if hit and hit ~= targetPart then
                continue
            end
        end

        local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen or sp.Z < 0 then continue end
        local dist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
        if dist <= Settings.FovRadius and dist < bestDist then
            bestDist = dist
            bestP = player
        end
    end
    return bestP
end

local function updateAim()
    if not Settings.SilentAim then
        if Cache.AimConnection then
            safeDisconnect(Cache.AimConnection)
            Cache.AimConnection = nil
        end
        return
    end

    if Cache.AimConnection then return end

    Cache.AimConnection = RunService.RenderStepped:Connect(function()
        if not Settings.SilentAim then return end
        if not hasGunInHand() then return end

        local target = getClosestMurdererInFov()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.AimTargetPart) or target.Character:FindFirstChild("Head")
            if targetPart then
                local smoothFactor = 1 - Settings.AimSmoothness
                local currentCF = Camera.CFrame
                local targetCF = CFrame.lookAt(currentCF.Position, targetPart.Position)
                local newCF = currentCF:Lerp(targetCF, smoothFactor)
                Camera.CFrame = newCF
            end
        end
    end)
end

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and self == LocalPlayer:GetMouse() and key == "Hit" and Settings.SilentAim then
        local target = getClosestMurdererInFov()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.AimTargetPart) or target.Character:FindFirstChild("Head")
            if targetPart then
                return CFrame.new(targetPart.Position)
            end
        end
    end
    return oldIndex(self, key)
end)

-- FOV круг
local function createFovCircle()
    if Cache.FovCircle then pcall(function() Cache.FovCircle:Remove() end) end
    local c = Drawing.new("Circle")
    c.Radius = Settings.FovRadius
    c.Color = Color3.fromRGB(255, 255, 255)
    c.Thickness = 1.5
    c.Transparency = 0.4
    c.Filled = false
    c.Visible = false
    c.NumSides = 64
    Cache.FovCircle = c
end

local function updateFovCircle()
    if not Cache.FovCircle then createFovCircle() end
    local circle = Cache.FovCircle
    if not Settings.SilentAim then
        circle.Visible = false
        return
    end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    circle.Position = center
    circle.Radius = Settings.FovRadius
    circle.Visible = true
    circle.Color = Color3.fromRGB(255, 255, 255)
end

-- ========================================
-- ===== ESP =====
-- ========================================
local function updateRoleESP()
    for _, text in pairs(Cache.EspTexts) do pcall(function() text:Remove() end) end
    Cache.EspTexts = {}
    if not Settings.EspEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
        if not onScreen or sp.Z < 0 then continue end

        local role = "Innocent"
        local color = Color3.fromRGB(50, 150, 255)
        if isMurderer(player) then
            role = "Murderer"
            color = Color3.fromRGB(255, 50, 50)
        elseif isSheriff(player) then
            role = "Sheriff"
            color = Color3.fromRGB(50, 255, 50)
        end

        local text = Drawing.new("Text")
        text.Text = player.Name .. " [" .. role .. "]"
        text.Position = Vector2.new(sp.X, sp.Y)
        text.Size = 16
        text.Center = true
        text.Outline = true
        text.OutlineColor = Color3.fromRGB(0, 0, 0)
        text.Color = color
        text.Transparency = 1
        text.Visible = true
        table.insert(Cache.EspTexts, text)
    end
end

-- ========================================
-- ===== CHAMS =====
-- ========================================
local function cacheCharacterParts(player)
    if not player or not player.Character then return end
    local list = {}
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            list[part] = {ogMaterial = part.Material, ogColor = part.Color, ogTransparency = part.Transparency, ogCastShadow = part.CastShadow}
        end
    end
    Cache.ChamsPartsList[player.UserId] = list
end

local function applyChams(player)
    if not player or not player.Character then return end
    local char = player.Character
    if not Cache.ChamsPartsList[player.UserId] then cacheCharacterParts(player) end
    local chamsColor = Settings.ChamsColor
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if not Cache.ChamsPartsList[player.UserId] then Cache.ChamsPartsList[player.UserId] = {} end
            if not Cache.ChamsPartsList[player.UserId][part] then
                Cache.ChamsPartsList[player.UserId][part] = {ogMaterial = part.Material, ogColor = part.Color, ogTransparency = part.Transparency, ogCastShadow = part.CastShadow}
            end
            part.Material = Enum.Material.ForceField
            part.Color = chamsColor
            part.Transparency = 0.0
            part.CastShadow = false
        end
    end
end

local function removeChams(player)
    if not player or not player.Character then return end
    local char = player.Character
    local list = Cache.ChamsPartsList[player.UserId]
    if not list then return end
    for part, data in pairs(list) do
        if part and part.Parent then
            pcall(function()
                part.Material = data.ogMaterial
                part.Color = data.ogColor
                part.Transparency = data.ogTransparency
                part.CastShadow = data.ogCastShadow
            end)
        end
    end
    Cache.ChamsPartsList[player.UserId] = nil
end

local function clearAllChams()
    for userId, _ in pairs(Cache.ChamsPartsList) do
        local p = Players:GetPlayerByUserId(userId)
        if p then removeChams(p) end
    end
    Cache.ChamsPartsList = {}
end

local function updateChamsForAll()
    if Settings.ChamsEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            cacheCharacterParts(p)
            applyChams(p)
        end
    else
        clearAllChams()
    end
end

-- ========================================
-- ===== АУРА =====
-- ========================================
local AURA_IDS = {
    angel = "97658130917593",
    starlight = "134645216613107",
    heavenly = "139300897520961",
    ribbon = "132069507632161",
    sakura = "81755778619404",
    wind = "80694081850877",
    flow = "119913533725648",
    star = "73754563740680"
}
local AURA_ORDER = {"angel", "starlight", "heavenly", "ribbon", "sakura", "wind", "flow", "star"}

local function clearAura()
    for _, p in ipairs(Cache.AuraParticles) do pcall(function() p:Destroy() end) end
    Cache.AuraParticles = {}
end

local function loadAura(name)
    if Cache.AuraCache[name] then return Cache.AuraCache[name] end
    local id = AURA_IDS[name]
    if not id then return nil end
    local success, result = pcall(game.GetObjects, game, "rbxassetid://" .. id)
    if success and result and result[1] then
        Cache.AuraCache[name] = result[1]
        return result[1]
    end
    return nil
end

local function colorAura(model, color)
    local seq = ColorSequence.new(color)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("PointLight") then
            descendant.Color = color
        elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
            descendant.Color = seq
        end
    end
end

local function applyAura()
    clearAura()
    if not Settings.AuraEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, name in ipairs(AURA_ORDER) do
        if Settings.AuraSelected[name] then
            local aura_model = loadAura(name)
            if aura_model then
                colorAura(aura_model, Settings.AuraColor)
                local cloned = aura_model:Clone()
                for _, part in ipairs(cloned:GetChildren()) do
                    local target = char:FindFirstChild(part.Name)
                    if target and target:IsA("BasePart") then
                        for _, child in ipairs(part:GetChildren()) do
                            child.Parent = target
                            table.insert(Cache.AuraParticles, child)
                        end
                    end
                end
                cloned:Destroy()
            end
        end
    end
end

-- ========================================
-- ===== MODEL CHANGER =====
-- ========================================
local function applyModelChanger()
    if Cache.ModelHandle then
        pcall(function() Cache.ModelHandle:Destroy() end)
        Cache.ModelHandle = nil
    end

    if not Settings.ModelChanger then return end

    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local success, objects = pcall(game.GetObjects, game, "rbxassetid://138151705692565")
    if not success or not objects or #objects == 0 then
        notify("Model Changer", "Не удалось загрузить модель.", 2)
        return
    end

    local model = Instance.new("Model")
    model.Name = "WizardHubModelChanger"
    model.Parent = char

    local firstPart
    for _, object in ipairs(objects) do
        if object:IsA("BasePart") then
            local clone = object:Clone()
            clone.Anchored = false
            clone.CanCollide = false
            clone.CanTouch = false
            clone.CanQuery = false
            clone.Massless = true
            clone.Parent = model

            if not firstPart then
                firstPart = clone
            else
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = firstPart
                weld.Part1 = clone
                weld.Parent = firstPart
            end
        end
    end

    for _, object in ipairs(objects) do
        pcall(function() object:Destroy() end)
    end

    if not firstPart then
        model:Destroy()
        notify("Model Changer", "В ассете нет BasePart.", 2)
        return
    end

    firstPart.CFrame = root.CFrame

    local rootWeld = Instance.new("WeldConstraint")
    rootWeld.Part0 = root
    rootWeld.Part1 = firstPart
    rootWeld.Parent = firstPart

    Cache.ModelHandle = model
end

-- ========================================
-- ===== CHINA HAT =====
-- ========================================
local tau = math.pi * 2

local function createChinaHatDrawings()
    for i = 1, #Cache.ChinaHatDrawings do
        pcall(function()
            Cache.ChinaHatDrawings[i][1]:Remove()
            Cache.ChinaHatDrawings[i][2]:Remove()
        end)
    end
    Cache.ChinaHatDrawings = {}
    for i = 1, Settings.ChinaHatSides do
        Cache.ChinaHatDrawings[i] = {Drawing.new('Line'), Drawing.new('Triangle')}
        Cache.ChinaHatDrawings[i][1].ZIndex = 2
        Cache.ChinaHatDrawings[i][1].Thickness = 2
        Cache.ChinaHatDrawings[i][2].ZIndex = 1
        Cache.ChinaHatDrawings[i][2].Filled = true
    end
end

local function hatRemoveClassic()
    if Cache.ChinaHatParts[LocalPlayer.Character] then
        pcall(function() Cache.ChinaHatParts[LocalPlayer.Character]:Destroy() end)
        Cache.ChinaHatParts[LocalPlayer.Character] = nil
    end
end

local function hatAddClassic(char)
    task.wait(0.1)
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    hatRemoveClassic()
    local hat = Instance.new("Part")
    hat.Name = "ChineseHat"
    hat.Transparency = Settings.ChinaHatTransparency
    hat.Color = Settings.ChinaHatColor
    hat.Material = Enum.Material.Neon
    hat.CanCollide = false
    hat.Reflectance = Settings.ChinaHatReflectance
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(Settings.ChinaHatRadius, Settings.ChinaHatHeight, Settings.ChinaHatRadius)
    mesh.Parent = hat
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head
    weld.Part1 = hat
    weld.Parent = hat
    hat.CFrame = head.CFrame * CFrame.new(0, 1.1, 0)
    hat.Parent = char
    Cache.ChinaHatParts[char] = hat
end

local function hatUpdateClassic()
    for char, hat in pairs(Cache.ChinaHatParts) do
        if hat and hat.Parent and char == LocalPlayer.Character then
            hat.Transparency = Settings.ChinaHatTransparency
            hat.Reflectance = Settings.ChinaHatReflectance
            if Settings.ChinaHatRainbow then
                hat.Color = Color3.fromHSV(tick() % Settings.ChinaHatRainbowSpeed / Settings.ChinaHatRainbowSpeed, 1, 1)
            else
                hat.Color = Settings.ChinaHatColor
            end
            local mesh = hat:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                mesh.Scale = Vector3.new(Settings.ChinaHatRadius, Settings.ChinaHatHeight, Settings.ChinaHatRadius)
            end
        end
    end
end

local function hatUpdateDrawing()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local pass = Settings.ChinaHatEnabled
        and char
        and char:FindFirstChild("Head") ~= nil
        and humanoid
        and humanoid.Health > 0
        and (Camera.CFrame.Position - Camera.Focus.Position).Magnitude > 1
    for i = 1, #Cache.ChinaHatDrawings do
        local line, triangle = Cache.ChinaHatDrawings[i][1], Cache.ChinaHatDrawings[i][2]
        if pass then
            local color
            if Settings.ChinaHatRainbow then
                color = Color3.fromHSV((tick() % Settings.ChinaHatRainbowSpeed / Settings.ChinaHatRainbowSpeed - (i / #Cache.ChinaHatDrawings)) % 1, 0.5, 1)
            else
                color = Settings.ChinaHatColor
            end
            local pos = LocalPlayer.Character.Head.Position + Vector3.new(0, 0.75, 0)
            local topWorld = pos + Vector3.new(0, 0.75, 0)
            local last, next = (i / Settings.ChinaHatSides) * tau, ((i + 1) / Settings.ChinaHatSides) * tau
            local lastWorld = pos + (Vector3.new(math.cos(last), 0, math.sin(last)) * Settings.ChinaHatRadius)
            local nextWorld = pos + (Vector3.new(math.cos(next), 0, math.sin(next)) * Settings.ChinaHatRadius)
            local lastScreen = Camera:WorldToViewportPoint(lastWorld)
            local nextScreen = Camera:WorldToViewportPoint(nextWorld)
            local topScreen = Camera:WorldToViewportPoint(topWorld)
            line.From = Vector2.new(lastScreen.X, lastScreen.Y)
            line.To = Vector2.new(nextScreen.X, nextScreen.Y)
            line.Color = color
            line.Transparency = 1 - Settings.ChinaHatTransparency
            line.Visible = true
            triangle.PointA = Vector2.new(topScreen.X, topScreen.Y)
            triangle.PointB = line.From
            triangle.PointC = line.To
            triangle.Color = color
            triangle.Transparency = 0.35
            triangle.Visible = true
        else
            line.Visible = false
            triangle.Visible = false
        end
    end
end

local function toggleChinaHat(value)
    Settings.ChinaHatEnabled = value
    if value then
        createChinaHatDrawings()
        if Settings.ChinaHatStyle == "Classic" and LocalPlayer.Character then
            hatAddClassic(LocalPlayer.Character)
        end
        if Cache.ChinaHatConnection then safeDisconnect(Cache.ChinaHatConnection) end
        Cache.ChinaHatConnection = RunService.Heartbeat:Connect(function()
            if Settings.ChinaHatStyle == "Classic" then
                hatUpdateClassic()
            else
                hatUpdateDrawing()
            end
        end)
        notify("China Hat", "Включен (" .. Settings.ChinaHatStyle .. ")", 2)
    else
        hatRemoveClassic()
        for i = 1, #Cache.ChinaHatDrawings do
            pcall(function()
                Cache.ChinaHatDrawings[i][1].Visible = false
                Cache.ChinaHatDrawings[i][2].Visible = false
            end)
        end
        if Cache.ChinaHatConnection then
            safeDisconnect(Cache.ChinaHatConnection)
            Cache.ChinaHatConnection = nil
        end
        notify("China Hat", "Выключен", 2)
    end
end

local function hatChangeStyle(value)
    local wasEnabled = Settings.ChinaHatEnabled
    Settings.ChinaHatStyle = value
    if wasEnabled then
        toggleChinaHat(false)
        task.wait(0.1)
        toggleChinaHat(true)
    end
    notify("China Hat", "Стиль: " .. value, 2)
end

-- ========================================
-- ===== TRAILS =====
-- ========================================
local function createLocalPlayerTrail()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if Cache.TrailAttachments.trail then
        pcall(function() Cache.TrailAttachments.trail:Destroy() end)
    end
    if Cache.TrailAttachments.att1 then pcall(function() Cache.TrailAttachments.att1:Destroy() end) end
    if Cache.TrailAttachments.att2 then pcall(function() Cache.TrailAttachments.att2:Destroy() end) end
    Cache.TrailAttachments = {}

    if not Settings.TrailsEnabled then return end

    local att1 = Instance.new("Attachment")
    att1.Position = Vector3.new(-1, 0, 0)
    att1.Parent = hrp
    local att2 = Instance.new("Attachment")
    att2.Position = Vector3.new(1, 0, 0)
    att2.Parent = hrp

    local trail = Instance.new("Trail")
    trail.Attachment0 = att1
    trail.Attachment1 = att2
    trail.Lifetime = Settings.TrailsLifetime
    trail.MinLength = 0
    trail.FaceCamera = true
    trail.LightEmission = 1
    trail.LightInfluence = 0
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Color = ColorSequence.new(Settings.TrailsColor)
    trail.Width = Settings.TrailsWidth
    trail.Parent = hrp

    Cache.TrailAttachments = {trail = trail, att1 = att1, att2 = att2}
end

local function updateTrailColor()
    if Cache.TrailAttachments.trail then
        Cache.TrailAttachments.trail.Color = ColorSequence.new(Settings.TrailsColor)
        Cache.TrailAttachments.trail.Width = Settings.TrailsWidth
        Cache.TrailAttachments.trail.Lifetime = Settings.TrailsLifetime
    end
end

local function removeLocalPlayerTrail()
    if Cache.TrailAttachments.trail then pcall(function() Cache.TrailAttachments.trail:Destroy() end) end
    if Cache.TrailAttachments.att1 then pcall(function() Cache.TrailAttachments.att1:Destroy() end) end
    if Cache.TrailAttachments.att2 then pcall(function() Cache.TrailAttachments.att2:Destroy() end) end
    Cache.TrailAttachments = {}
end

local function toggleTrails(value)
    Settings.TrailsEnabled = value
    if value then
        createLocalPlayerTrail()
        notify("Trails", "Включены", 2)
    else
        removeLocalPlayerTrail()
        notify("Trails", "Выключены", 2)
    end
end

-- ========================================
-- ===== VIGNETTE =====
-- ========================================
local function createVignette()
    if Cache.Vignette then
        pcall(function() Cache.Vignette.Frame:Destroy() end)
        Cache.Vignette = nil
    end
    if not Settings.VignetteEnabled then return end

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        playerGui = LocalPlayer:WaitForChild("PlayerGui")
        if not playerGui then return end
    end

    local frame = Instance.new("Frame")
    frame.Name = "Vignette"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 999
    frame.Parent = playerGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 0
    gradient.Offset = Vector2.new(0, 0)
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 1 - Settings.VignetteOpacity),
        NumberSequenceKeypoint.new(1, 1),
    })
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Settings.VignetteColor),
        ColorSequenceKeypoint.new(1, Settings.VignetteColor),
    })
    gradient.Parent = frame

    Cache.Vignette = {
        Frame = frame,
        Gradient = gradient,
        Corner = corner,
    }
end

local function updateVignette()
    if not Cache.Vignette then
        createVignette()
        return
    end

    local frame = Cache.Vignette.Frame
    local gradient = Cache.Vignette.Gradient
    if frame and gradient then
        local colorSeq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Settings.VignetteColor),
            ColorSequenceKeypoint.new(1, Settings.VignetteColor),
        })
        gradient.Color = colorSeq

        local opacity = Settings.VignetteOpacity
        local transparencySeq = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 1 - opacity),
            NumberSequenceKeypoint.new(1, 1),
        })
        gradient.Transparency = transparencySeq
    end
end

local function toggleVignette(value)
    Settings.VignetteEnabled = value
    if value then
        createVignette()
        notify("Vignette", "Включена", 2)
    else
        if Cache.Vignette then
            pcall(function() Cache.Vignette.Frame:Destroy() end)
            Cache.Vignette = nil
        end
        notify("Vignette", "Выключена", 2)
    end
end

-- ========================================
-- ===== SHADERS & CUSTOM WORLD =====
-- ========================================
local function applyCustomWorld()
    if not Settings.CustomWorldEnabled then
        pcall(function()
            Lighting.Ambient = Cache.OriginalLighting.Ambient
            Lighting.Brightness = Cache.OriginalLighting.Brightness
            Lighting.FogColor = Cache.OriginalLighting.FogColor
            Lighting.FogEnd = Cache.OriginalLighting.FogEnd
            Lighting.FogStart = Cache.OriginalLighting.FogStart
        end)
        return
    end

    pcall(function()
        Lighting.Ambient = Settings.AmbientColor
        Lighting.Brightness = Settings.Brightness
        if Settings.FogEnabled then
            Lighting.FogColor = Settings.FogColor
            Lighting.FogEnd = Settings.FogEnd
            Lighting.FogStart = Settings.FogStart
        else
            Lighting.FogColor = Cache.OriginalLighting.FogColor
            Lighting.FogEnd = Cache.OriginalLighting.FogEnd
            Lighting.FogStart = Cache.OriginalLighting.FogStart
        end
    end)
end

local SHADER_PRESETS = {
    Default = { TimeOfDay = "12:00:00", Ambient = Color3.fromRGB(127, 127, 127), Brightness = 1, ColorShift_Top = Color3.fromRGB(0, 0, 0), ColorShift_Bottom = Color3.fromRGB(0, 0, 0) },
    Morning = { TimeOfDay = "08:00:00", Ambient = Color3.fromRGB(180, 160, 130), Brightness = 2.5, ColorShift_Top = Color3.fromRGB(200, 200, 255), ColorShift_Bottom = Color3.fromRGB(255, 200, 150) },
    Evening = { TimeOfDay = "18:30:00", Ambient = Color3.fromRGB(80, 60, 50), Brightness = 1.8, ColorShift_Top = Color3.fromRGB(200, 100, 50), ColorShift_Bottom = Color3.fromRGB(100, 50, 30) },
    Night = { TimeOfDay = "00:00:00", Ambient = Color3.fromRGB(20, 20, 30), Brightness = 0.3, ColorShift_Top = Color3.fromRGB(20, 30, 80), ColorShift_Bottom = Color3.fromRGB(10, 10, 20) },
    Sunset = { TimeOfDay = "19:30:00", Ambient = Color3.fromRGB(100, 50, 20), Brightness = 1.5, ColorShift_Top = Color3.fromRGB(255, 100, 50), ColorShift_Bottom = Color3.fromRGB(150, 50, 20) },
    Sunrise = { TimeOfDay = "06:00:00", Ambient = Color3.fromRGB(150, 100, 80), Brightness = 2.0, ColorShift_Top = Color3.fromRGB(255, 150, 100), ColorShift_Bottom = Color3.fromRGB(200, 100, 80) },
    ["Neon Night"] = { TimeOfDay = "00:00:00", Ambient = Color3.fromRGB(30, 0, 50), Brightness = 0.5, ColorShift_Top = Color3.fromRGB(150, 0, 255), ColorShift_Bottom = Color3.fromRGB(0, 255, 255) },
}

local function applyShaderPreset(presetName)
    if not presetName or presetName == "" then presetName = "Default" end
    local preset = SHADER_PRESETS[presetName]
    if not preset then return end
    pcall(function()
        Lighting.TimeOfDay = preset.TimeOfDay
        Lighting.Ambient = preset.Ambient
        Lighting.Brightness = preset.Brightness
        Lighting.ColorShift_Top = preset.ColorShift_Top
        Lighting.ColorShift_Bottom = preset.ColorShift_Bottom
        Settings.ShaderPreset = presetName
        Settings.CustomWorldEnabled = false
    end)
end

-- ========================================
-- ===== ANIMATIONS =====
-- ========================================
local ANIM_PACKS = {
    ["Adidas Sports"] = {WalkAnim = 18537392113, RunAnim = 18537384940, JumpAnim = 18537380791, FallAnim = 18537367238, SwimIdle = 18537387180, Swim = 18537389531, Animation1 = 18537376492, Animation2 = 18537371272, ClimbAnim = 18537363391},
    ["Adidas Community"] = {WalkAnim = 122150855457006, RunAnim = 82598234841035, JumpAnim = 75290611992385, FallAnim = 98600215928904, SwimIdle = 109346520324160, Swim = 133308483266208, Animation1 = 122257458498464, Animation2 = 102357151005774, ClimbAnim = 88763136693023},
    ["Adidas Aura"] = {WalkAnim = 83842218823011, RunAnim = 118320322718866, JumpAnim = 109996626521204, FallAnim = 95603166884636, SwimIdle = 94922130551805, Swim = 134530128383903, Animation1 = 110211186840347, Animation2 = 114191137265065, ClimbAnim = 97824616490448},
    ["Wicked Popular"] = {WalkAnim = 92072849924640, RunAnim = 72301599441680, JumpAnim = 104325245285198, FallAnim = 121152442762481, Animation1 = 118832222982049, ClimbAnim = 131326830509784, SwimIdle = 113199415118199, Swim = 99384245425157, Animation2 = 76049494037641},
    Elder = {WalkAnim = 10921111375, RunAnim = 10921104374, JumpAnim = 10921107367, FallAnim = 10921105765, SwimIdle = 10921110146, Swim = 10921108971, ClimbAnim = 10921100400, Animation1 = 10921101664, Animation2 = 10921102574},
    Zombie = {WalkAnim = 10921355261, RunAnim = 616163682, JumpAnim = 10921351278, FallAnim = 10921350320, SwimIdle = 10921353442, Swim = 10921352344, Animation1 = 10921344533, Animation2 = 10921345304, ClimbAnim = 10921343576},
    Mage = {WalkAnim = 10921152678, RunAnim = 10921148209, JumpAnim = 10921149743, FallAnim = 10921148939, SwimIdle = 10921151661, Swim = 10921150788, ClimbAnim = 10921143404, Animation1 = 10921144709, Animation2 = 10921145797},
    ["Catwalk Glam"] = {WalkAnim = 109168724482748, RunAnim = 81024476153754, JumpAnim = 116936326516985, FallAnim = 92294537340807, SwimIdle = 98854111361360, Swim = 134591743181628, ClimbAnim = 119377220967554, Animation1 = 133806214992291, Animation2 = 94970088341563},
    Astronaut = {WalkAnim = 10921046031, RunAnim = 10921039308, JumpAnim = 10921042494, FallAnim = 10921040576, SwimIdle = 10921045006, Swim = 10921044000, ClimbAnim = 10921032124, Animation1 = 10921034824, Animation2 = 10921036806},
    ["Wicked 'Dancing Through Life'"] = {WalkAnim = 73718308412641, RunAnim = 135515454877967, JumpAnim = 78508480717326, FallAnim = 78147885297412, SwimIdle = 129183123083281, Swim = 110657013921774, ClimbAnim = 129447497744818, Animation1 = 92849173543269, Animation2 = 132238900951109},
    Werewolf = {WalkAnim = 10921342074, RunAnim = 10921336997, JumpAnim = nil, FallAnim = 10921337907, SwimIdle = 10921341319, Swim = 10921340419, ClimbAnim = 10921329322, Animation1 = 10921330408, Animation2 = 10921333667},
    Superhero = {WalkAnim = 10921298616, RunAnim = 10921291831, JumpAnim = 10921294559, FallAnim = 10921293373, SwimIdle = 10921297391, Swim = 10921295495, ClimbAnim = 10921286911, Animation1 = 10921288909, Animation2 = 10921290167},
    Toy = {WalkAnim = 10921312010, RunAnim = 10921306285, JumpAnim = 10921308158, FallAnim = 10921307241, SwimIdle = 10921310341, Swim = 10921309319, ClimbAnim = 10921300839, Animation1 = 10921301576, Animation2 = nil},
    ["No Boundaries"] = {WalkAnim = 18747074203, RunAnim = 18747070484, JumpAnim = 18747069148, FallAnim = 18747062535, SwimIdle = 18747071682, Swim = 18747073181, ClimbAnim = 18747060903, Animation1 = 18747067405, Animation2 = 18747063918},
    NFL = {WalkAnim = 110358958299415, RunAnim = 117333533048078, JumpAnim = 119846112151352, FallAnim = 129773241321032, SwimIdle = 79090109939093, Swim = 132697394189921, ClimbAnim = 134630013742019, Animation1 = 92080889861410, Animation2 = 74451233229259},
    ["Amazon Unboxed"] = {WalkAnim = 90478085024465, RunAnim = 134824450619865, JumpAnim = 121454505477205, FallAnim = 94788218468396, SwimIdle = 129126268464847, Swim = 105962919001086, ClimbAnim = 121145883950231, Animation1 = 98281136301627, Animation2 = nil},
    Vampire = {WalkAnim = 10921326949, RunAnim = 10921320299, JumpAnim = 10921322186, FallAnim = 10921321317, SwimIdle = 10921325443, Swim = 10921324408, ClimbAnim = 10921314188, Animation1 = 10921315373, Animation2 = nil},
    Ninja = {Run = 656118852, Walk = 656121766, Jump = 656117878, Fall = 656115606, Swim = 656119721, SwimIdle = 656121397, Climb = 656114359, Idle = {656117400, 656118341, 886742569}},
    Robot = {Run = 616091570, Walk = 616095330, Jump = 616090535, Fall = 616087089, Swim = 616092998, SwimIdle = 616094091, Climb = 616086039, Idle = {616088211, 616089559, 885531463}},
    Levitation = {Run = 616010382, Walk = 616013216, Jump = 616008936, Fall = 616005863, Swim = 616011509, SwimIdle = 616012453, Climb = 616003713, Idle = {616006778, 616008087, 886862142}},
    Stylish = {Run = 616140816, Walk = 616146177, Jump = 616139451, Fall = 616134815, Swim = 616143378, SwimIdle = 616144772, Climb = 616133594, Idle = {616136790, 616138447, 886888594}},
    Bubbly = {Run = 910025107, Walk = 910034870, Jump = 910016857, Fall = 910001910, Swim = 910028158, SwimIdle = 910030921, Climb = 909997997, Idle = {910004836, 910009958, 1018536639}},
    Cartoon = {Run = 742638842, Walk = 742640026, Jump = 742637942, Fall = 742637151, Swim = 742639220, SwimIdle = 742639812, Climb = 742636889, Idle = {742637544, 742638445, 885477856}},
}

local ANIM_PACK_NAMES = {}
for name in pairs(ANIM_PACKS) do table.insert(ANIM_PACK_NAMES, name) end
table.sort(ANIM_PACK_NAMES)

local function applyAnimPack(packName)
    local pack = ANIM_PACKS[packName]
    if not pack then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local animate = char:FindFirstChild("Animate")
    if not animate then return false end

    local function setAnim(obj, id)
        if obj and id then obj.AnimationId = "rbxassetid://" .. tostring(id) end
    end

    local function ensureAnim(folder, name)
        if not folder then return nil end
        local a = folder:FindFirstChild(name)
        if not a then
            a = Instance.new("Animation")
            a.Name = name
            a.Parent = folder
        end
        return a
    end

    local runObj = ensureAnim(animate:FindFirstChild("run"), "RunAnim")
    local walkObj = ensureAnim(animate:FindFirstChild("walk"), "WalkAnim")
    local jumpObj = ensureAnim(animate:FindFirstChild("jump"), "JumpAnim")
    local fallObj = ensureAnim(animate:FindFirstChild("fall"), "FallAnim")
    local climbObj = ensureAnim(animate:FindFirstChild("climb"), "ClimbAnim")
    local swimObj = ensureAnim(animate:FindFirstChild("swim"), "Swim")
    local swimIdleObj = ensureAnim(animate:FindFirstChild("swimidle"), "SwimIdle")
    local idleFolder = animate:FindFirstChild("idle")

    setAnim(walkObj, pack.WalkAnim or pack.Walk)
    setAnim(runObj, pack.RunAnim or pack.Run)
    setAnim(jumpObj, pack.JumpAnim or pack.Jump)
    setAnim(fallObj, pack.FallAnim or pack.Fall)
    setAnim(climbObj, pack.ClimbAnim or pack.Climb)
    setAnim(swimObj, pack.Swim)
    setAnim(swimIdleObj, pack.SwimIdle or pack.Swim)

    if idleFolder then
        local a1 = idleFolder:FindFirstChild("Animation1")
        local a2 = idleFolder:FindFirstChild("Animation2")
        if pack.Animation1 then setAnim(a1, pack.Animation1) end
        if pack.Animation2 then setAnim(a2, pack.Animation2) end
        if pack.Idle then
            if a1 and pack.Idle[1] then setAnim(a1, pack.Idle[1]) end
            if a2 and pack.Idle[2] then setAnim(a2, pack.Idle[2] or pack.Idle[1]) end
        end
    end

    animate.Disabled = true
    task.wait(0.06)
    animate.Disabled = false
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Landed)
            task.wait(0.03)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
    Settings.AnimPack = packName
    return true
end

-- ========================================
-- ===== ОСТАЛЬНЫЕ ФУНКЦИИ =====
-- ========================================

-- ANTI-FLING
local function applyAntiFling()
    if Settings.AntiFling then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            if not char then continue end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            if not char then continue end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.1)
        if Settings.AntiFling then
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

-- BHOP
local function stopBHop()
    Cache.BHopActive = false
    safeDisconnect(Cache.BHopConn)
    Cache.BHopConn = nil
    if Cache.BHopBV then pcall(function() Cache.BHopBV:Destroy() end) end
    Cache.BHopBV = nil
end

local function startBHop()
    if not LocalPlayer.Character then return end
    if Cache.BHopActive then stopBHop() end
    local char = LocalPlayer.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    Cache.BHopActive = true
    Cache.BHopBV = Instance.new("BodyVelocity")
    Cache.BHopBV.MaxForce = Vector3.new(1e5, 0, 1e5)
    Cache.BHopBV.Velocity = Vector3.new(0, 0, 0)
    Cache.BHopBV.Parent = hrp
    local lastJump = 0
    Cache.BHopConn = RunService.Stepped:Connect(function()
        if not Cache.BHopActive then
            stopBHop()
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        if not Cache.BHopBV or not Cache.BHopBV.Parent then
            Cache.BHopBV = Instance.new("BodyVelocity")
            Cache.BHopBV.MaxForce = Vector3.new(1e5, 0, 1e5)
            Cache.BHopBV.Velocity = Vector3.new(0, 0, 0)
            Cache.BHopBV.Parent = hrp
        end
        local moveDir = hum.MoveDirection
        local isMoving = moveDir.Magnitude > 0.1
        local state = hum:GetState()
        local onGround = (state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.RunningNoPhysics)
        if isMoving then
            local horizontal = Vector3.new(moveDir.X, 0, moveDir.Z)
            if horizontal.Magnitude > 0.01 then
                Cache.BHopBV.Velocity = horizontal.Unit * Settings.BHopSpeed
            end
            if onGround and tick() - lastJump > 0.15 then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                lastJump = tick()
            end
        else
            Cache.BHopBV.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    notify("BHop", "Включен", 2)
end

local function toggleBHop(value)
    Settings.BHopEnabled = value
    if value then startBHop() else stopBHop() end
end

-- SPINBOT
local function startSpinbot()
    if Cache.SpinbotActive then return end
    Cache.SpinbotActive = true
    if Cache.SpinbotConn then safeDisconnect(Cache.SpinbotConn) end
    Cache.SpinbotConn = RunService.RenderStepped:Connect(function()
        if not Settings.SpinbotEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local angle = math.rad(Settings.SpinbotSpeed)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, angle, 0)
    end)
    notify("Spinbot", "Включен", 2)
end

local function stopSpinbot()
    if Cache.SpinbotConn then
        safeDisconnect(Cache.SpinbotConn)
        Cache.SpinbotConn = nil
    end
    Cache.SpinbotActive = false
    notify("Spinbot", "Выключен", 2)
end

local function toggleSpinbot(value)
    Settings.SpinbotEnabled = value
    if value then startSpinbot() else stopSpinbot() end
end

-- ANTI-AIM
local function startAntiAim()
    if Cache.AntiAimActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    Cache.AntiAimHrpPos = hrp.Position
    hum.PlatformStand = true

    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part ~= hrp then
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bp.P = 1e5
            bp.Position = part.Position
            bp.Parent = part

            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.P = 1e5
            bg.CFrame = part.CFrame
            bg.Parent = part

            table.insert(Cache.AntiAimParts, {part = part, bp = bp, bg = bg})
        end
    end

    hrp.CFrame = CFrame.new(hrp.Position.X, -1000, hrp.Position.Z)
    hrp.CanCollide = false

    Cache.AntiAimActive = true
    notify("Anti-Aim", "Хитбокс под землёй", 2)
end

local function stopAntiAim()
    if not Cache.AntiAimActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    for _, data in ipairs(Cache.AntiAimParts) do
        if data.bp then data.bp:Destroy() end
        if data.bg then data.bg:Destroy() end
    end
    Cache.AntiAimParts = {}

    if hrp and Cache.AntiAimHrpPos then
        hrp.CFrame = CFrame.new(Cache.AntiAimHrpPos)
        hrp.CanCollide = true
    end

    if hum then hum.PlatformStand = false end

    Cache.AntiAimActive = false
    notify("Anti-Aim", "Выключен", 2)
end

local function toggleAntiAim(value)
    Settings.AntiAimEnabled = value
    if value then startAntiAim() else stopAntiAim() end
end

-- ANTI-AFK
local function setupAntiAFK()
    safeDisconnect(Cache.afkConn)
    Cache.afkConn = nil
    if not Settings.AntiAFKEnabled then return end
    local last = 0
    Cache.afkConn = RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character then return end
        local now = tick()
        if now - last > 60 then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Jump = true
                last = now
            end
        end
    end)
end

-- AUTO FARM COINS
local function startAutoFarm()
    if Cache.FarmConnection then Cache.FarmConnection:Disconnect(); Cache.FarmConnection = nil end
    if not Settings.AutoFarmCoins then return end
    Cache.FarmConnection = RunService.RenderStepped:Connect(function()
        if not Settings.AutoFarmCoins then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local closestCoin = nil
        local closestDist = math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("beach") or obj.Name:lower():find("ball")) then
                if obj.Parent and not obj.Parent:IsA("Tool") then
                    local dist = (hrp.Position - obj.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestCoin = obj
                    end
                end
            end
        end
        if closestCoin and closestDist < 100 then
            hrp.CFrame = CFrame.new(closestCoin.Position + Vector3.new(0, 1, 0))
            task.wait(0.05)
        end
    end)
end

-- AUTO GRAB GUN
local grabbingGun = false
local function autoGrabGun()
    if grabbingGun then return end
    if not Settings.AutoGrabGun then return end
    if not LocalPlayer.Character then return end
    if isMurderer(LocalPlayer) then return end
    if isSheriff(LocalPlayer) then
        notify("Grab Gun", "У тебя уже есть пушка!", 2)
        return
    end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local gunDrop = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("DroppedGun", true)
    if not gunDrop then
        notify("Grab Gun", "Пушки нет на карте!", 2)
        return
    end
    local handle = gunDrop:FindFirstChild("Handle", true) or gunDrop:FindFirstChildOfClass("Part", true) or gunDrop
    if not handle then return end
    grabbingGun = true
    local originalCFrame = hrp.CFrame
    local targetCFrame = handle:IsA("Model") and handle:GetPivot() or handle.CFrame
    hrp.CFrame = targetCFrame * CFrame.new(0, -1, 0)
    if firetouchinterest then
        pcall(function()
            firetouchinterest(hrp, handle, 0)
            task.wait(0.02)
            firetouchinterest(hrp, handle, 1)
        end)
    end
    task.wait(0.15)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        hrp.CFrame = originalCFrame
    end
    task.wait(0.1)
    if isSheriff(LocalPlayer) then
        notify("Grab Gun", "Пушка подобрана!", 2)
    else
        notify("Grab Gun", "Не удалось подобрать пушку!", 2)
    end
    grabbingGun = false
end

-- AUTO KILL MURDERER
local function autoKillMurderer()
    if not Settings.AutoKillMurderer then return end
    if not isSheriff(LocalPlayer) then
        notify("Kill Murderer", "Ты не шериф!", 2)
        return
    end
    local murderer = findMurderer()
    if not murderer or not murderer.Character then
        notify("Kill Murderer", "Убийца не найден!", 2)
        return
    end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local mHrp = murderer.Character:FindFirstChild("HumanoidRootPart")
    if mHrp then
        hrp.CFrame = mHrp.CFrame * CFrame.new(0, 0, 5)
        task.wait(0.1)
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, mHrp.Position)
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, 0, true)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, 0, false)
        end
        notify("Kill Murderer", "Убийца уничтожен!", 2)
    end
end

-- KILL ALL
local function killAll()
    if not Settings.AutoKillAll then return end
    if not isMurderer(LocalPlayer) then
        notify("Kill All", "Ты не убийца!", 2)
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local originalCF = hrp.CFrame

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not targetHrp then continue end

        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2)
        task.wait(0.02)

        VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, 0, true)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, 0, false)

        hrp.CFrame = originalCF
    end

    notify("Kill All", "Все убиты!", 2)
end

-- TELEPORTS
local function teleportToMurderer()
    if not Settings.TeleportToMurderer then return end
    local murderer = findMurderer()
    if not murderer or not murderer.Character then
        notify("Teleport", "Убийца не найден!", 2)
        return
    end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local mHrp = murderer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and mHrp then
        hrp.CFrame = mHrp.CFrame * CFrame.new(0, 0, 3)
        notify("Teleport", "Телепорт к убийце!", 1)
    end
end

local function teleportToSheriff()
    if not Settings.TeleportToSheriff then return end
    local sheriff = findSheriff()
    if not sheriff or not sheriff.Character then
        notify("Teleport", "Шериф не найден!", 2)
        return
    end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local sHrp = sheriff.Character:FindFirstChild("HumanoidRootPart")
    if hrp and sHrp then
        hrp.CFrame = sHrp.CFrame * CFrame.new(0, 0, 3)
        notify("Teleport", "Телепорт к шерифу!", 1)
    end
end

local function teleportToGun()
    if not Settings.TeleportToGun then return end
    local gun = workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("DroppedGun", true)
    if not gun then
        notify("Teleport", "Пушки нет на карте!", 2)
        return
    end
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = gun:IsA("Model") and gun:GetPivot().Position or gun.Position
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 1, 0))
        notify("Teleport", "Телепорт к пушке!", 1)
    end
end

local function spawnGrannyHouse()
    if Cache.GrannyHouse then
        pcall(function() Cache.GrannyHouse:Destroy() end)
        Cache.GrannyHouse = nil
    end

    local success, models = pcall(game.GetObjects, game, "rbxassetid://7060020967")
    if not success or not models or #models == 0 then
        notify("Granny House", "Не удалось загрузить дом!", 2)
        return nil
    end

    local house = models[1]
    house.Parent = workspace
    pcall(function()
        house:PivotTo(CFrame.new(0, 80, 0))
    end)
    Cache.GrannyHouse = house
    return house
end

local function teleportToGranny()
    if not Settings.TeleportGranny then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local house = Cache.GrannyHouse
    if not house or not house.Parent then
        house = spawnGrannyHouse()
        if not house then return end
    end

    local cf = house:GetPivot()
    hrp.CFrame = cf * CFrame.new(0, 2, 0)
    notify("Granny House", "Добро пожаловать в дом Гренни!", 2)
end

-- HITBOX EXPANDER
local function setupHitboxExpander()
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsA("BasePart") then
            if Settings.HitboxExpander then
                if not Cache.HitboxOriginalSizes[hrp] then
                    Cache.HitboxOriginalSizes[hrp] = hrp.Size
                end

                pcall(function()
                    hrp.Size = Vector3.new(
                        Settings.HitboxSize,
                        Settings.HitboxSize,
                        math.max(1, Settings.HitboxSize / 2)
                    )
                end)
            elseif Cache.HitboxOriginalSizes[hrp] then
                local original = Cache.HitboxOriginalSizes[hrp]
                pcall(function() hrp.Size = original end)
                Cache.HitboxOriginalSizes[hrp] = nil
            end
        end
    end
end
-- NO CLIP
local function setupNoClip()
    if not Settings.NoClip then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- INFINITE JUMP
local function toggleInfiniteJump(state)
    Settings.InfiniteJump = state
    if state then
        LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
end

-- ========================================
-- ===== SKIN CHANGER =====
-- ========================================
local SKIN_PISTOL = {["Default"] = nil, ["Evergun"] = 15906729064, ["GingerScope"] = 15836475747}
local SKIN_KNIFE = {["Default"] = nil, ["Bat"] = 15971830968}
local PISTOL_SKIN_NAMES = {}
for name in pairs(SKIN_PISTOL) do table.insert(PISTOL_SKIN_NAMES, name) end
table.sort(PISTOL_SKIN_NAMES)
local KNIFE_SKIN_NAMES = {}
for name in pairs(SKIN_KNIFE) do table.insert(KNIFE_SKIN_NAMES, name) end
table.sort(KNIFE_SKIN_NAMES)

local function applySkinToPart(part, assetId)
    if not part or not part:IsA("BasePart") or not assetId then return end

    local success, objects = pcall(game.GetObjects, game, "rbxassetid://" .. tostring(assetId))
    if not success or not objects or #objects == 0 then return end

    local sourcePart
    for _, obj in ipairs(objects) do
        if obj:IsA("BasePart") then
            sourcePart = obj
            break
        end
    end

    if not sourcePart then
        for _, obj in ipairs(objects) do
            pcall(function() obj:Destroy() end)
        end
        return
    end

    pcall(function()
        part.Size = sourcePart.Size
        part.Material = sourcePart.Material
        part.Color = sourcePart.Color
        part.Transparency = sourcePart.Transparency

        if part:IsA("MeshPart") and sourcePart:IsA("MeshPart") then
            part.MeshId = sourcePart.MeshId
            part.TextureID = sourcePart.TextureID
        end

        local sourceMesh = sourcePart:FindFirstChildOfClass("SpecialMesh")
        if sourceMesh then
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if not mesh then
                mesh = sourceMesh:Clone()
                mesh.Parent = part
            else
                mesh.MeshId = sourceMesh.MeshId
                mesh.TextureId = sourceMesh.TextureId
                mesh.Scale = sourceMesh.Scale
                mesh.Offset = sourceMesh.Offset
            end
        end
    end)

    for _, obj in ipairs(objects) do
        pcall(function() obj:Destroy() end)
    end
end

local function refreshWeaponSkins()
    local char = LocalPlayer.Character
    if not char then return end

    for _, descendant in ipairs(char:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant:FindFirstChildOfClass("SpecialMesh") then
            local name = descendant.Name:lower()
            local isWeapon = name:find("gun") or name:find("revolver") or name:find("knife") or name:find("handle")
            if isWeapon then
                local isPistol = name:find("gun") or name:find("revolver")
                local isKnife = name:find("knife")
                local assetId = nil
                if isPistol and Settings.SkinPistolEnabled then
                    assetId = SKIN_PISTOL[Settings.SkinPistolSelected]
                elseif isKnife and Settings.SkinKnifeEnabled then
                    assetId = SKIN_KNIFE[Settings.SkinKnifeSelected]
                end
                if assetId then
                    applySkinToPart(descendant, assetId)
                end
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") then
                local handle = child:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    local name = child.Name:lower()
                    local isPistol = name:find("gun") or name:find("revolver")
                    local isKnife = name:find("knife")
                    local assetId = nil
                    if isPistol and Settings.SkinPistolEnabled then
                        assetId = SKIN_PISTOL[Settings.SkinPistolSelected]
                    elseif isKnife and Settings.SkinKnifeEnabled then
                        assetId = SKIN_KNIFE[Settings.SkinKnifeSelected]
                    end
                    if assetId then
                        applySkinToPart(handle, assetId)
                    end
                end
            end
        end
    end
end

local function setupSkinWatcher()
    if Cache.SkinConnection then safeDisconnect(Cache.SkinConnection); Cache.SkinConnection = nil end
    if not Settings.SkinPistolEnabled and not Settings.SkinKnifeEnabled then return end
    Cache.SkinConnection = RunService.Heartbeat:Connect(function()
        refreshWeaponSkins()
    end)
    refreshWeaponSkins()
end

local function toggleSkinPistol(value)
    Settings.SkinPistolEnabled = value
    if value then setupSkinWatcher() else setupSkinWatcher() end
    notify("Pistol Skin", value and "Включен" or "Выключен", 2)
end

local function toggleSkinKnife(value)
    Settings.SkinKnifeEnabled = value
    if value then setupSkinWatcher() else setupSkinWatcher() end
    notify("Knife Skin", value and "Включен" or "Выключен", 2)
end

local function changePistolSkin(skinName)
    Settings.SkinPistolSelected = skinName
    if Settings.SkinPistolEnabled then
        refreshWeaponSkins()
        notify("Pistol Skin", "Изменён на " .. skinName, 2)
    end
end

local function changeKnifeSkin(skinName)
    Settings.SkinKnifeSelected = skinName
    if Settings.SkinKnifeEnabled then
        refreshWeaponSkins()
        notify("Knife Skin", "Изменён на " .. skinName, 2)
    end
end

-- ========================================
-- ===== SHOOT BUTTON =====
-- ========================================
local function createShootButton()
    if Cache.ShootButton then pcall(function() Cache.ShootButton:Destroy() end); Cache.ShootButton = nil end
    if not Settings.ShootButtonEnabled then return end

    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if not playerGui then
        task.wait(0.5)
        playerGui = LocalPlayer:WaitForChild("PlayerGui")
        if not playerGui then return end
    end

    local btn = Instance.new("ImageButton")
    btn.Name = "ShootMurderButton"
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0.85, -35, 0.5, -35)
    btn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    btn.BackgroundTransparency = 0.2
    btn.Image = "rbxassetid://10723415054"
    btn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    btn.ImageTransparency = 0.1
    btn.ZIndex = 999
    btn.Parent = playerGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.4, 0)
    label.Position = UDim2.new(0, 0, 0.6, 0)
    label.BackgroundTransparency = 1
    label.Text = "🔫"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 20
    label.Font = Enum.Font.GothamBold
    label.ZIndex = 1000
    label.Parent = btn

    local dragging = false
    local dragStart = nil
    local dragOffset = nil

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            dragOffset = Vector2.new(btn.Position.X.Offset, btn.Position.Y.Offset)
            btn.ZIndex = 1001
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            btn.ZIndex = 999
        end
    end)

    btn.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = math.clamp(dragOffset.X + delta.X, 0, playerGui.AbsoluteSize.X - 70)
            local newY = math.clamp(dragOffset.Y + delta.Y, 0, playerGui.AbsoluteSize.Y - 70)
            btn.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    local function shootSheriff()
        if not LocalPlayer.Character then return end
        local sheriff = findSheriff()
        if not sheriff or not sheriff.Character then
            notify("Shoot Murder", "Шериф не найден!", 2)
            return
        end

        local targetPart = sheriff.Character:FindFirstChild(Settings.AimTargetPart) or sheriff.Character:FindFirstChild("Head")
        if not targetPart then
            notify("Shoot Murder", "Цель не найдена!", 2)
            return
        end

        if not Settings.Wallbang then
            local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, sheriff.Character}
                local result = workspace:Raycast(myHRP.Position, targetPart.Position - myHRP.Position, raycastParams)
                if result then
                    notify("Shoot Murder", "Шериф за стеной! (Wallbang выключен)", 2)
                    return
                end
            end
        end

        local smoothFactor = 1 - Settings.AimSmoothness
        local currentCF = Camera.CFrame
        local targetCF = CFrame.lookAt(currentCF.Position, targetPart.Position)
        local newCF = currentCF:Lerp(targetCF, smoothFactor)
        Camera.CFrame = newCF

        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, 0, true)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, 0, false)

        notify("Shoot Murder", "Выстрел в шерифа!", 1)
    end

    btn.MouseButton1Click:Connect(shootSheriff)

    Cache.ShootButton = btn
    notify("Shoot Button", "Кнопка создана! Перетащите её.", 2)
end

local function toggleShootButton(value)
    Settings.ShootButtonEnabled = value
    if value then
        createShootButton()
    else
        if Cache.ShootButton then
            pcall(function() Cache.ShootButton:Destroy() end)
            Cache.ShootButton = nil
        end
        notify("Shoot Button", "Выключен", 2)
    end
end

-- ========================================
-- ===== TEXTURE PACK =====
-- ========================================
local TEXTURE_VARIANTS = {
    Brick = {BaseMaterial = Enum.Material.Brick, Texture = 'rbxassetid://10777285622'},
    Concrete = {BaseMaterial = Enum.Material.Concrete, Texture = 'rbxassetid://15622710576'},
    CorrodedMetal = {BaseMaterial = Enum.Material.CorrodedMetal, Texture = 'rbxassetid://78612695839404'},
    Grass = {BaseMaterial = Enum.Material.Grass, Texture = 'rbxassetid://9267183930'},
    Metal = {BaseMaterial = Enum.Material.Metal, Texture = 'rbxassetid://121650613091353'},
    Sand = {BaseMaterial = Enum.Material.Sand, Texture = 'rbxassetid://12624140843'},
    Slate = {BaseMaterial = Enum.Material.Slate, Texture = 'rbxassetid://8676746437'},
    Wood = {BaseMaterial = Enum.Material.Wood, Texture = 'rbxassetid://3258599312'},
    WoodPlanks = {BaseMaterial = Enum.Material.WoodPlanks, Texture = 'rbxassetid://8676581022'},
}
local TEXTURE_VARIANT_BY_MATERIAL = {
    [Enum.Material.Brick] = 'Brick',
    [Enum.Material.Concrete] = 'Concrete',
    [Enum.Material.CorrodedMetal] = 'CorrodedMetal',
    [Enum.Material.Grass] = 'Grass',
    [Enum.Material.Metal] = 'Metal',
    [Enum.Material.Sand] = 'Sand',
    [Enum.Material.Slate] = 'Slate',
    [Enum.Material.Wood] = 'Wood',
    [Enum.Material.WoodPlanks] = 'WoodPlanks',
}
local function ensureTextureVariants()
    if Cache.TextureVariantsBuilt then return end
    for name, data in pairs(TEXTURE_VARIANTS) do
        local variant = MaterialService:FindFirstChild(name)
        if not variant then
            variant = Instance.new('MaterialVariant')
            variant.Name = name
            variant.Parent = MaterialService
        end
        pcall(function()
            variant.BaseMaterial = data.BaseMaterial
            variant.ColorMap = data.Texture
            variant.MetalnessMap = data.Texture
            variant.NormalMap = data.Texture
            variant.RoughnessMap = data.Texture
            variant.MaterialPattern = Enum.MaterialPattern.Regular
            variant.StudsPerTile = 5
        end)
    end
    Cache.TextureVariantsBuilt = true
end
local function rememberTexturePart(part)
    if not Cache.TextureState[part] then
        Cache.TextureState[part] = {Color = part.Color, Material = part.Material, MaterialVariant = part.MaterialVariant}
    end
    return Cache.TextureState[part]
end
local function shouldSkipTexturePart(part)
    if not part:IsDescendantOf(workspace) then return true end
    if part.Name == 'LarpticWeather' or part.Name == 'Part' then return true end
    local parent = part.Parent
    if parent and (parent:IsA('Tool') or parent:IsA('Accessory')) then return true end
    local model = part:FindFirstAncestorOfClass('Model')
    if model and game.Players:GetPlayerFromCharacter(model) then return true end
    return false
end
local function applyTexturePack()
    if not Settings.TexturePackEnabled then return end
    ensureTextureVariants()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA('BasePart') and not shouldSkipTexturePart(obj) then
            rememberTexturePart(obj)
            local variantName = TEXTURE_VARIANT_BY_MATERIAL[obj.Material]
            if variantName then
                pcall(function() obj.MaterialVariant = variantName end)
            end
        end
    end
end
local function clearTexturePack()
    for part, state in pairs(Cache.TextureState) do
        if part and part.Parent and state then
            pcall(function()
                part.Color = state.Color
                part.Material = state.Material
                part.MaterialVariant = state.MaterialVariant or ''
            end)
        end
    end
    Cache.TextureState = {}
    for name, _ in pairs(TEXTURE_VARIANTS) do
        local variant = MaterialService:FindFirstChild(name)
        if variant and variant:IsA('MaterialVariant') then
            pcall(function() variant:Destroy() end)
        end
    end
    Cache.TextureVariantsBuilt = false
end
local function toggleTexturePack(value)
    Settings.TexturePackEnabled = value
    if value then
        applyTexturePack()
        notify("Texture Pack", "Включен", 2)
    else
        clearTexturePack()
        notify("Texture Pack", "Выключен", 2)
    end
end

-- STRETCH
local function applyStretch(state)
    Settings.StretchEnabled = state
    if not state then
        if Cache.StretchConnection then
            pcall(function() Cache.StretchConnection:Disconnect() end)
            Cache.StretchConnection = nil
        end
        pcall(function()
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame
        end)
        return
    end
    if not Cache.StretchConnection then
        Cache.StretchConnection = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            if camera then
                camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, Settings.StretchFactor, 0, 0, 0, 1)
            end
        end)
    end
end
local function toggleStretch(value)
    Settings.StretchEnabled = value
    applyStretch(value)
    notify("Stretch", value and "Включен (" .. Settings.StretchFactor .. ")" or "Выключен", 2)
end

-- ========================================
-- ===== GUI (RAYFIELD) =====
-- ========================================
local Window = Rayfield:CreateWindow({
    Name = "Wizard Hub",
    LoadingTitle = "Wizard Hub Loading...",
    LoadingSubtitle = "by MonoDev (FINAL FIXED)",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "WizardHub",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvite",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Aimbot Tab
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
AimbotTab:CreateToggle({
    Name = "Silent Aim (follow murderer, only with gun)",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function(Value)
        Settings.SilentAim = Value
        if Value then updateAim() else if Cache.AimConnection then safeDisconnect(Cache.AimConnection); Cache.AimConnection = nil end end
    end,
})
AimbotTab:CreateToggle({
    Name = "Wallbang (shoot through walls)",
    CurrentValue = false,
    Flag = "Wallbang",
    Callback = function(Value)
        Settings.Wallbang = Value
    end,
})
AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 250,
    Flag = "FovRadius",
    Callback = function(Value)
        Settings.FovRadius = Value
        if Cache.FovCircle then Cache.FovCircle.Radius = Value end
    end,
})
AimbotTab:CreateSlider({
    Name = "Smoothness (0 = instant, 1 = smooth)",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.3,
    Flag = "AimSmoothness",
    Callback = function(Value) Settings.AimSmoothness = Value end,
})
AimbotTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    CurrentOption = {"Head"},
    Flag = "AimTargetPart",
    Callback = function(Option) Settings.AimTargetPart = Option[1] or "Head" end,
})

-- Visuals Tab
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
VisualsTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "EspEnabled",
    Callback = function(Value) Settings.EspEnabled = Value end,
})
VisualsTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Flag = "ChamsEnabled",
    Callback = function(Value)
        Settings.ChamsEnabled = Value
        updateChamsForAll()
    end,
})
VisualsTab:CreateColorPicker({
    Name = "Chams Color",
    Color = Color3.fromRGB(0, 255, 255),
    Flag = "ChamsColor",
    Callback = function(Value)
        Settings.ChamsColor = Value
        if Settings.ChamsEnabled then updateChamsForAll() end
    end,
})
VisualsTab:CreateToggle({
    Name = "Texture Pack",
    CurrentValue = false,
    Flag = "TexturePackEnabled",
    Callback = function(Value) toggleTexturePack(Value) end,
})
VisualsTab:CreateToggle({
    Name = "Stretch",
    CurrentValue = false,
    Flag = "StretchEnabled",
    Callback = function(Value) toggleStretch(Value) end,
})
VisualsTab:CreateSlider({
    Name = "Stretch Factor",
    Range = {0.1, 2.0},
    Increment = 0.05,
    Suffix = "x",
    CurrentValue = 0.5,
    Flag = "StretchFactor",
    Callback = function(Value)
        Settings.StretchFactor = Value
        if Settings.StretchEnabled then applyStretch(true) end
    end,
})
VisualsTab:CreateToggle({
    Name = "China Hat",
    CurrentValue = false,
    Flag = "ChinaHatEnabled",
    Callback = function(Value) toggleChinaHat(Value) end,
})
VisualsTab:CreateDropdown({
    Name = "China Hat Style",
    Options = {"Classic", "Drawing"},
    CurrentOption = {Settings.ChinaHatStyle},
    Flag = "ChinaHatStyle",
    Callback = function(Option) hatChangeStyle(Option[1] or "Classic") end,
})
VisualsTab:CreateColorPicker({
    Name = "China Hat Color",
    Color = Settings.ChinaHatColor,
    Flag = "ChinaHatColor",
    Callback = function(Value) Settings.ChinaHatColor = Value end,
})
VisualsTab:CreateSlider({
    Name = "Hat Transparency",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.3,
    Flag = "ChinaHatTransparency",
    Callback = function(Value) Settings.ChinaHatTransparency = Value end,
})
VisualsTab:CreateSlider({
    Name = "Hat Reflectance",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.3,
    Flag = "ChinaHatReflectance",
    Callback = function(Value) Settings.ChinaHatReflectance = Value end,
})
VisualsTab:CreateSlider({
    Name = "Hat Radius",
    Range = {0.5, 3},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 1.2,
    Flag = "ChinaHatRadius",
    Callback = function(Value) Settings.ChinaHatRadius = Value end,
})
VisualsTab:CreateSlider({
    Name = "Hat Height",
    Range = {0.3, 2},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 0.8,
    Flag = "ChinaHatHeight",
    Callback = function(Value) Settings.ChinaHatHeight = Value end,
})
VisualsTab:CreateToggle({
    Name = "Rainbow Hat",
    CurrentValue = false,
    Flag = "ChinaHatRainbow",
    Callback = function(Value) Settings.ChinaHatRainbow = Value end,
})
VisualsTab:CreateSlider({
    Name = "Rainbow Speed",
    Range = {1, 20},
    Increment = 1,
    Suffix = "",
    CurrentValue = 5,
    Flag = "ChinaHatRainbowSpeed",
    Callback = function(Value) Settings.ChinaHatRainbowSpeed = Value end,
})
VisualsTab:CreateToggle({
    Name = "Aura",
    CurrentValue = false,
    Flag = "Aura",
    Callback = function(Value)
        Settings.AuraEnabled = Value
        if Value then applyAura() else clearAura() end
    end,
})
VisualsTab:CreateColorPicker({
    Name = "Aura Color",
    Color = Color3.fromRGB(255, 0, 255),
    Flag = "AuraColor",
    Callback = function(Value)
        Settings.AuraColor = Value
        if Settings.AuraEnabled then applyAura() end
    end,
})
local AuraDropdown = VisualsTab:CreateDropdown({
    Name = "Select Aura",
    Options = AURA_ORDER,
    CurrentOption = {"angel"},
    MultipleOptions = true,
    Flag = "AuraSelect",
    Callback = function(Option)
        for _, name in ipairs(AURA_ORDER) do
            Settings.AuraSelected[name] = false
        end
        for _, name in ipairs(Option) do
            Settings.AuraSelected[name] = true
        end
        if Settings.AuraEnabled then applyAura() end
    end,
})
VisualsTab:CreateToggle({
    Name = "Model Changer (Tung)",
    CurrentValue = false,
    Flag = "ModelChanger",
    Callback = function(Value)
        Settings.ModelChanger = Value
        pcall(applyModelChanger)
    end,
})
VisualsTab:CreateLabel("Animations")
local AnimDropdown = VisualsTab:CreateDropdown({
    Name = "Select Animation Pack",
    Options = ANIM_PACK_NAMES,
    CurrentOption = {Settings.AnimPack},
    Flag = "AnimPack",
    Callback = function(Option)
        local pack = Option[1] or "Elder"
        pcall(applyAnimPack, pack)
    end,
})
VisualsTab:CreateLabel("Shaders")
local ShaderNames = {"Default", "Morning", "Evening", "Night", "Sunset", "Sunrise", "Neon Night"}
local ShaderDropdown = VisualsTab:CreateDropdown({
    Name = "Shader Preset",
    Options = ShaderNames,
    CurrentOption = {Settings.ShaderPreset},
    Flag = "ShaderPreset",
    Callback = function(Option)
        local preset = Option[1] or "Default"
        Settings.CustomWorldEnabled = false
        applyShaderPreset(preset)
    end,
})

-- Custom World Tab
local WorldTab = Window:CreateTab("Custom World", 4483362458)
WorldTab:CreateToggle({
    Name = "Enable Custom World",
    CurrentValue = false,
    Flag = "CustomWorldEnabled",
    Callback = function(Value)
        Settings.CustomWorldEnabled = Value
        applyCustomWorld()
    end,
})
WorldTab:CreateColorPicker({
    Name = "Ambient Color",
    Color = Color3.fromRGB(127, 127, 127),
    Flag = "AmbientColor",
    Callback = function(Value)
        Settings.AmbientColor = Value
        if Settings.CustomWorldEnabled then applyCustomWorld() end
    end,
})
WorldTab:CreateSlider({
    Name = "Brightness",
    Range = {0, 10},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 1,
    Flag = "Brightness",
    Callback = function(Value)
        Settings.Brightness = Value
        if Settings.CustomWorldEnabled then applyCustomWorld() end
    end,
})
WorldTab:CreateToggle({
    Name = "Enable Fog",
    CurrentValue = false,
    Flag = "FogEnabled",
    Callback = function(Value)
        Settings.FogEnabled = Value
        if Settings.CustomWorldEnabled then applyCustomWorld() end
    end,
})
WorldTab:CreateColorPicker({
    Name = "Fog Color",
    Color = Color3.fromRGB(128, 128, 128),
    Flag = "FogColor",
    Callback = function(Value)
        Settings.FogColor = Value
        if Settings.CustomWorldEnabled and Settings.FogEnabled then applyCustomWorld() end
    end,
})
WorldTab:CreateSlider({
    Name = "Fog Start",
    Range = {0, 500},
    Increment = 1,
    Suffix = "",
    CurrentValue = 0,
    Flag = "FogStart",
    Callback = function(Value)
        Settings.FogStart = Value
        if Settings.CustomWorldEnabled and Settings.FogEnabled then applyCustomWorld() end
    end,
})
WorldTab:CreateSlider({
    Name = "Fog End",
    Range = {0, 1000},
    Increment = 1,
    Suffix = "",
    CurrentValue = 100,
    Flag = "FogEnd",
    Callback = function(Value)
        Settings.FogEnd = Value
        if Settings.CustomWorldEnabled and Settings.FogEnabled then applyCustomWorld() end
    end,
})

-- Trails in Visuals
VisualsTab:CreateLabel("=== Trails ===")
VisualsTab:CreateToggle({
    Name = "Trails",
    CurrentValue = false,
    Flag = "TrailsEnabled",
    Callback = function(Value) toggleTrails(Value) end,
})
VisualsTab:CreateColorPicker({
    Name = "Trails Color",
    Color = Color3.fromRGB(255, 0, 255),
    Flag = "TrailsColor",
    Callback = function(Value)
        Settings.TrailsColor = Value
        updateTrailColor()
    end,
})
VisualsTab:CreateSlider({
    Name = "Trails Width",
    Range = {0.1, 2},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.5,
    Flag = "TrailsWidth",
    Callback = function(Value)
        Settings.TrailsWidth = Value
        updateTrailColor()
    end,
})
VisualsTab:CreateSlider({
    Name = "Trails Lifetime",
    Range = {0.2, 2},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0.8,
    Flag = "TrailsLifetime",
    Callback = function(Value)
        Settings.TrailsLifetime = Value
        updateTrailColor()
    end,
})

-- Vignette in Visuals
VisualsTab:CreateLabel("=== Vignette ===")
VisualsTab:CreateToggle({
    Name = "Vignette",
    CurrentValue = false,
    Flag = "VignetteEnabled",
    Callback = function(Value) toggleVignette(Value) end,
})
VisualsTab:CreateColorPicker({
    Name = "Vignette Color",
    Color = Color3.fromRGB(0, 0, 0),
    Flag = "VignetteColor",
    Callback = function(Value)
        Settings.VignetteColor = Value
        updateVignette()
    end,
})
VisualsTab:CreateSlider({
    Name = "Vignette Opacity",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.5,
    Flag = "VignetteOpacity",
    Callback = function(Value)
        Settings.VignetteOpacity = Value
        updateVignette()
    end,
})

-- Skin Changer
VisualsTab:CreateLabel("=== Skin Changer ===")
VisualsTab:CreateToggle({
    Name = "Pistol Skin",
    CurrentValue = false,
    Flag = "SkinPistolEnabled",
    Callback = function(Value) toggleSkinPistol(Value) end,
})
local PistolSkinDropdown = VisualsTab:CreateDropdown({
    Name = "Pistol Skin Select",
    Options = PISTOL_SKIN_NAMES,
    CurrentOption = {Settings.SkinPistolSelected},
    Flag = "SkinPistolSelected",
    Callback = function(Option) changePistolSkin(Option[1] or "Default") end,
})
VisualsTab:CreateToggle({
    Name = "Knife Skin",
    CurrentValue = false,
    Flag = "SkinKnifeEnabled",
    Callback = function(Value) toggleSkinKnife(Value) end,
})
local KnifeSkinDropdown = VisualsTab:CreateDropdown({
    Name = "Knife Skin Select",
    Options = KNIFE_SKIN_NAMES,
    CurrentOption = {Settings.SkinKnifeSelected},
    Flag = "SkinKnifeSelected",
    Callback = function(Option) changeKnifeSkin(Option[1] or "Default") end,
})

-- Shoot Button
VisualsTab:CreateLabel("=== Shoot Button ===")
VisualsTab:CreateToggle({
    Name = "Shoot Murder Button",
    CurrentValue = false,
    Flag = "ShootButtonEnabled",
    Callback = function(Value) toggleShootButton(Value) end,
})

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateToggle({
    Name = "Auto Farm Coins",
    CurrentValue = false,
    Flag = "AutoFarmCoins",
    Callback = function(Value)
        Settings.AutoFarmCoins = Value
        if Value then startAutoFarm() else if Cache.FarmConnection then Cache.FarmConnection:Disconnect(); Cache.FarmConnection = nil end end
    end,
})
CombatTab:CreateToggle({
    Name = "Auto Grab Gun",
    CurrentValue = false,
    Flag = "AutoGrabGun",
    Callback = function(Value)
        Settings.AutoGrabGun = Value
        if Value then autoGrabGun() end
    end,
})
CombatTab:CreateButton({
    Name = "Grab Gun Now",
    Callback = function() autoGrabGun() end,
})
CombatTab:CreateToggle({
    Name = "Auto Kill Murderer",
    CurrentValue = false,
    Flag = "AutoKillMurderer",
    Callback = function(Value)
        Settings.AutoKillMurderer = Value
        if Value then autoKillMurderer() end
    end,
})
CombatTab:CreateToggle({
    Name = "Kill All (Murderer Only)",
    CurrentValue = false,
    Flag = "AutoKillAll",
    Callback = function(Value)
        Settings.AutoKillAll = Value
        if Value then killAll() end
    end,
})
CombatTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Flag = "HitboxExpander",
    Callback = function(Value)
        Settings.HitboxExpander = Value
        setupHitboxExpander()
    end,
})
CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {5, 50},
    Increment = 1,
    Suffix = "",
    CurrentValue = 20,
    Flag = "HitboxSize",
    Callback = function(Value)
        Settings.HitboxSize = Value
        if Settings.HitboxExpander then setupHitboxExpander() end
    end,
})

-- Teleports Tab
local TeleportsTab = Window:CreateTab("Teleports", 4483362458)
TeleportsTab:CreateButton({
    Name = "Teleport to Murderer",
    Callback = function()
        Settings.TeleportToMurderer = true
        teleportToMurderer()
        Settings.TeleportToMurderer = false
    end,
})
TeleportsTab:CreateButton({
    Name = "Teleport to Sheriff",
    Callback = function()
        Settings.TeleportToSheriff = true
        teleportToSheriff()
        Settings.TeleportToSheriff = false
    end,
})
TeleportsTab:CreateButton({
    Name = "Teleport to Gun",
    Callback = function()
        Settings.TeleportToGun = true
        teleportToGun()
        Settings.TeleportToGun = false
    end,
})
TeleportsTab:CreateButton({
    Name = "Leave to Granny's House",
    Callback = function()
        Settings.TeleportGranny = true
        teleportToGranny()
        Settings.TeleportGranny = false
    end,
})

-- Movement Tab
local MovementTab = Window:CreateTab("Movement", 4483362458)
MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        toggleInfiniteJump(Value)
    end,
})
MovementTab:CreateToggle({
    Name = "BHop",
    CurrentValue = false,
    Flag = "BHopEnabled",
    Callback = function(Value) toggleBHop(Value) end,
})
MovementTab:CreateSlider({
    Name = "BHop Speed",
    Range = {30, 150},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "BHopSpeed",
    Callback = function(Value) Settings.BHopSpeed = Value end,
})
MovementTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        Settings.NoClip = Value
        setupNoClip()
    end,
})
MovementTab:CreateToggle({
    Name = "Anti-Fling (disable collision with other players)",
    CurrentValue = false,
    Flag = "AntiFling",
    Callback = function(Value)
        Settings.AntiFling = Value
        applyAntiFling()
    end,
})
MovementTab:CreateToggle({
    Name = "Spinbot",
    CurrentValue = false,
    Flag = "SpinbotEnabled",
    Callback = function(Value) toggleSpinbot(Value) end,
})
MovementTab:CreateSlider({
    Name = "Spinbot Speed",
    Range = {1, 20},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 5,
    Flag = "SpinbotSpeed",
    Callback = function(Value) Settings.SpinbotSpeed = Value end,
})
MovementTab:CreateToggle({
    Name = "Anti-Aim",
    CurrentValue = false,
    Flag = "AntiAimEnabled",
    Callback = function(Value) toggleAntiAim(Value) end,
})
MovementTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFKEnabled",
    Callback = function(Value)
        Settings.AntiAFKEnabled = Value
        setupAntiAFK()
    end,
})
MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Settings.WalkSpeed = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})
MovementTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    Suffix = "",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        Settings.JumpPower = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end,
})

-- ========================================
-- ===== ЛУПЫ =====
-- ========================================
RunService.RenderStepped:Connect(function()
    updateRoleESP()
    if Settings.NoClip then setupNoClip() end
    if Settings.SilentAim then updateFovCircle() elseif Cache.FovCircle then Cache.FovCircle.Visible = false end
    if Settings.CustomWorldEnabled then applyCustomWorld() end
end)

RunService.Heartbeat:Connect(function()
    if Settings.TrailsEnabled then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not Cache.TrailAttachments.trail or not Cache.TrailAttachments.trail.Parent then
                    createLocalPlayerTrail()
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.2)
        if Settings.AntiFling then
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        if Settings.ChamsEnabled then
            cacheCharacterParts(player)
            applyChams(player)
        end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Settings.AuraEnabled then applyAura() end
    if Settings.ModelChanger then applyModelChanger() end
    if Settings.AnimPack ~= "" then pcall(applyAnimPack, Settings.AnimPack) end
    if Settings.NoClip then setupNoClip() end
    if Settings.HitboxExpander then setupHitboxExpander() end
    if Settings.AntiFling then applyAntiFling() end
    if Settings.TexturePackEnabled then applyTexturePack() end
    if Settings.ChinaHatEnabled then toggleChinaHat(true) end
    if Settings.StretchEnabled then applyStretch(true) end
    if Settings.SkinPistolEnabled or Settings.SkinKnifeEnabled then setupSkinWatcher() end
    if Settings.ShootButtonEnabled then createShootButton() end
    if Settings.SilentAim then updateAim() end
    if Settings.CustomWorldEnabled then applyCustomWorld() end
    if Settings.TrailsEnabled then createLocalPlayerTrail() end
    if Settings.VignetteEnabled then createVignette() end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower
    end
    if Settings.AutoFarmCoins then startAutoFarm() end
    if Settings.BHopEnabled then startBHop() end
    if Settings.ChamsEnabled then updateChamsForAll() end
    if Settings.ShaderPreset and Settings.ShaderPreset ~= "Default" then applyShaderPreset(Settings.ShaderPreset) end
    if Settings.SpinbotEnabled then startSpinbot() end
    if Settings.AntiAimEnabled then startAntiAim() end
    if Settings.AntiAFKEnabled then setupAntiAFK() end
    if not Cache.FovCircle then createFovCircle() end
end)

-- Инициализация
createFovCircle()
if Settings.ChamsEnabled then updateChamsForAll() end
if Settings.BHopEnabled then startBHop() end
if Settings.ShaderPreset and Settings.ShaderPreset ~= "Default" then applyShaderPreset(Settings.ShaderPreset) end
if Settings.TexturePackEnabled then applyTexturePack() end
if Settings.ChinaHatEnabled then toggleChinaHat(true) end
if Settings.StretchEnabled then applyStretch(true) end
if Settings.SpinbotEnabled then startSpinbot() end
if Settings.AntiAimEnabled then startAntiAim() end
if Settings.AntiAFKEnabled then setupAntiAFK() end
if Settings.SkinPistolEnabled or Settings.SkinKnifeEnabled then setupSkinWatcher() end
if Settings.ShootButtonEnabled then createShootButton() end
if Settings.SilentAim then updateAim() end
if Settings.CustomWorldEnabled then applyCustomWorld() end
if Settings.AntiFling then applyAntiFling() end
if Settings.TrailsEnabled then createLocalPlayerTrail() end
if Settings.VignetteEnabled then createVignette() end

print("Wizard Hub loaded successfully!")

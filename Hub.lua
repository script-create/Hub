--[[
    Violence District Hub (6locc Logic)
    Портировано на Compkiller UI
    Открытие: Left Alt
]]

-- ============================================
--  ЗАГРУЗКА БИБЛИОТЕКИ
-- ============================================

local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))()
if not Compkiller then
    warn("Failed to load Compkiller library!")
    return
end

-- ============================================
--  КОНФИГ МЕНЕДЖЕР
-- ============================================

local ConfigManager = Compkiller:ConfigManager({
    Directory = "VD-6locc",
    Config = "Settings"
})

-- ============================================
--  ЗАГРУЗОЧНЫЙ ЭКРАН
-- ============================================

Compkiller:Loader("rbxassetid://120245531583106", 1.5).yield()

-- ============================================
--  СОЗДАНИЕ ОКНА
-- ============================================

local MenuKey = "LeftAlt"

local Window = Compkiller.new({
    Name = "6LOCC VD",
    Keybind = MenuKey,
    Logo = "rbxassetid://120245531583106",
    Scale = Compkiller.Scale.Window,
    TextSize = 15,
})

-- ============================================
--  НАСТРОЙКИ ПОЛЬЗОВАТЕЛЯ
-- ============================================

local UserSettings = Window.UserSettings:Create()

UserSettings:AddColorPicker({
    Name = "Цвет меню",
    Default = Compkiller.Colors.Highlight,
    Callback = function(f)
        Compkiller.Colors.Highlight = f
        Compkiller:RefreshCurrentColor()
    end,
})

UserSettings:AddKeybind({
    Name = "Клавиша меню",
    Default = MenuKey,
    Callback = function(f)
        MenuKey = f
        Window:SetMenuKey(MenuKey)
    end,
})

UserSettings:AddDropdown({
    Name = "Тема",
    Values = {"Default", "Dark Green", "Dark Blue", "Purple Rose", "Skeet"},
    Default = "Default",
    Callback = function(f)
        Compkiller:SetTheme(f)
    end,
})

-- ============================================
--  ВОДЯНОЙ ЗНАК
-- ============================================

local Watermark = Window:Watermark()

Watermark:AddText({
    Icon = "user",
    Text = "6LOCC VD",
})

Watermark:AddText({
    Icon = "clock",
    Text = Compkiller:GetDate(),
})

local Time = Watermark:AddText({
    Icon = "timer",
    Text = "TIME",
})

task.spawn(function()
    while true do
        task.wait()
        Time:SetText(Compkiller:GetTimeNow())
    end
end)

Watermark:AddText({
    Icon = "server",
    Text = Compkiller.Version,
})

-- ============================================
--  ГЛОБАЛЬНЫЕ НАСТРОЙКИ
-- ============================================

_G.Settings = _G.Settings or {}

-- ============================================
--  ВКЛАДКИ GUI
-- ============================================

-- Категория: ESP
Window:DrawCategory({ Name = "ESP" })

local EspTab = Window:DrawTab({
    Name = "ESP",
    Icon = "eye",
    EnableScrolling = true
})

-- Секция: Мастер
local EspMaster = EspTab:DrawSection({
    Name = "Мастер",
    Position = "left"
})

EspMaster:AddToggle({
    Name = "Мастер ESP",
    Flag = "MasterESP",
    Default = false,
    Callback = function(v)
        _G.Settings.MasterESP = v
    end,
})

-- Секция: Игроки
local EspPlayers = EspTab:DrawSection({
    Name = "Игроки",
    Position = "right"
})

EspPlayers:AddToggle({
    Name = "Отслеживание убийцы",
    Flag = "KillerESP",
    Default = false,
    Callback = function(v)
        _G.Settings.KillerESP = _G.Settings.KillerESP or {}
        _G.Settings.KillerESP.Enabled = v
    end,
})

local KillerOpt = EspPlayers:AddOption()
KillerOpt:AddToggle({
    Name = "Подсветка",
    Flag = "KillerESP_Aura",
    Default = true,
    Callback = function(v)
        _G.Settings.KillerESP = _G.Settings.KillerESP or {}
        _G.Settings.KillerESP.Aura = v
    end,
})
KillerOpt:AddToggle({
    Name = "Дистанция",
    Flag = "KillerESP_Distance",
    Default = true,
    Callback = function(v)
        _G.Settings.KillerESP = _G.Settings.KillerESP or {}
        _G.Settings.KillerESP.Distance = v
    end,
})

EspPlayers:AddToggle({
    Name = "Отслеживание выживших",
    Flag = "SurvivorESP",
    Default = false,
    Callback = function(v)
        _G.Settings.SurvivorESP = _G.Settings.SurvivorESP or {}
        _G.Settings.SurvivorESP.Enabled = v
    end,
})

local SurvivorOpt = EspPlayers:AddOption()
SurvivorOpt:AddToggle({
    Name = "Подсветка",
    Flag = "SurvivorESP_Aura",
    Default = true,
    Callback = function(v)
        _G.Settings.SurvivorESP = _G.Settings.SurvivorESP or {}
        _G.Settings.SurvivorESP.Aura = v
    end,
})
SurvivorOpt:AddToggle({
    Name = "Здоровье",
    Flag = "SurvivorESP_Health",
    Default = true,
    Callback = function(v)
        _G.Settings.SurvivorESP = _G.Settings.SurvivorESP or {}
        _G.Settings.SurvivorESP.HealthState = v
    end,
})

-- Секция: Объекты
local EspObjects = EspTab:DrawSection({
    Name = "Объекты",
    Position = "left"
})

EspObjects:AddToggle({
    Name = "Генераторы",
    Flag = "GeneratorESP",
    Default = false,
    Callback = function(v)
        _G.Settings.GeneratorESP = _G.Settings.GeneratorESP or {}
        _G.Settings.GeneratorESP.Enabled = v
    end,
})

local GenOpt = EspObjects:AddOption()
GenOpt:AddToggle({
    Name = "Прогресс",
    Flag = "GeneratorESP_Progress",
    Default = true,
    Callback = function(v)
        _G.Settings.GeneratorESP = _G.Settings.GeneratorESP or {}
        _G.Settings.GeneratorESP.ShowProgress = v
    end,
})
GenOpt:AddToggle({
    Name = "ETA",
    Flag = "GeneratorESP_ETA",
    Default = true,
    Callback = function(v)
        _G.Settings.GeneratorESP = _G.Settings.GeneratorESP or {}
        _G.Settings.GeneratorESP.ShowETA = v
    end,
})

EspObjects:AddToggle({
    Name = "Крюки",
    Flag = "HookESP",
    Default = false,
    Callback = function(v)
        _G.Settings.HookESP = _G.Settings.HookESP or {}
        _G.Settings.HookESP.Enabled = v
    end,
})

EspObjects:AddToggle({
    Name = "Паллеты",
    Flag = "PalletESP",
    Default = false,
    Callback = function(v)
        _G.Settings.PalletESP = _G.Settings.PalletESP or {}
        _G.Settings.PalletESP.Enabled = v
    end,
})

EspObjects:AddToggle({
    Name = "Окна",
    Flag = "VaultESP",
    Default = false,
    Callback = function(v)
        _G.Settings.VaultESP = _G.Settings.VaultESP or {}
        _G.Settings.VaultESP.Enabled = v
    end,
})

-- Секция: Настройки
local EspSettings = EspTab:DrawSection({
    Name = "Настройки",
    Position = "right"
})

EspSettings:AddDropdown({
    Name = "Стиль ESP",
    Values = {"Old", "Standard", "Compact", "Minimal"},
    Default = "Standard",
    Flag = "ESPStyle",
    Callback = function(v)
        _G.Settings.ESPStyle = v
    end,
})

EspSettings:AddToggle({
    Name = "Трейсеры",
    Flag = "ESPTracers",
    Default = false,
    Callback = function(v)
        _G.Settings.ESPTracers = v
    end,
})

-- ============================================
-- Категория: Фарм
-- ============================================

Window:DrawCategory({ Name = "Фарм" })

local FarmTab = Window:DrawTab({
    Name = "Фарм",
    Icon = "farm",
    EnableScrolling = true
})

local FarmMain = FarmTab:DrawSection({
    Name = "Автофарм",
    Position = "left"
})

FarmMain:AddToggle({
    Name = "Автофарм выжившего",
    Flag = "AutoSurvivorFarm",
    Default = false,
    Callback = function(v)
        _G.Settings.AutoFarmSurvivor = v
    end,
})

FarmMain:AddToggle({
    Name = "Автофарм убийцы",
    Flag = "AutoKillerFarm",
    Default = false,
    Callback = function(v)
        _G.Settings.AutoFarmKiller = v
    end,
})

FarmMain:AddButton({
    Name = "Мгновенный побег",
    Callback = function()
        print("Instant Escape")
    end,
})

local FarmSkill = FarmTab:DrawSection({
    Name = "Скиллчеки",
    Position = "right"
})

FarmSkill:AddToggle({
    Name = "Авто-скиллчек",
    Flag = "AutoSkillCheck",
    Default = false,
    Callback = function(v)
        _G.Settings.AutoSkillCheck = v
    end,
})

FarmSkill:AddDropdown({
    Name = "Режим",
    Values = {"Perfect", "Normal", "Hybrid"},
    Default = "Perfect",
    Flag = "SkillCheckMode",
    Callback = function(v)
        _G.Settings.SkillCheckMode = v
    end,
})

-- ============================================
-- Категория: Модификаторы
-- ============================================

Window:DrawCategory({ Name = "Модификаторы" })

local ModTab = Window:DrawTab({
    Name = "Моды",
    Icon = "tune",
    EnableScrolling = true
})

local ModSpeed = ModTab:DrawSection({
    Name = "Скорость",
    Position = "left"
})

ModSpeed:AddToggle({
    Name = "Буст скорости",
    Flag = "SpeedBoost",
    Default = false,
    Callback = function(v)
        _G.Settings.SpeedBoostEnabled = v
    end,
})

ModSpeed:AddSlider({
    Name = "Множитель скорости",
    Min = 1.0,
    Max = 3.0,
    Default = 1.5,
    Round = 1,
    Flag = "SpeedMultiplier",
    Callback = function(v)
        _G.Settings.SpeedBoost = v
    end,
})

local ModMovement = ModTab:DrawSection({
    Name = "Движение",
    Position = "right"
})

ModMovement:AddToggle({
    Name = "Авто-лунная походка",
    Flag = "AutoMoonwalk",
    Default = false,
    Callback = function(v)
        _G.Settings.AutoMoonwalk = v
    end,
})

ModMovement:AddToggle({
    Name = "Ноклип окон/паллет",
    Flag = "NoclipVaultsPallets",
    Default = false,
    Callback = function(v)
        _G.Settings.NoclipVaultsPallets = v
    end,
})

local ModHeal = ModTab:DrawSection({
    Name = "Лечение",
    Position = "left"
})

ModHeal:AddToggle({
    Name = "Мгновенное лечение",
    Flag = "InstantHeal",
    Default = false,
    Callback = function(v)
        _G.Settings.InstantHeal = v
    end,
})

-- ============================================
-- Категория: Бой
-- ============================================

Window:DrawCategory({ Name = "Бой" })

local CombatTab = Window:DrawTab({
    Name = "Бой",
    Icon = "sword",
    EnableScrolling = true
})

local CombatParry = CombatTab:DrawSection({
    Name = "Автопарри",
    Position = "left"
})

CombatParry:AddToggle({
    Name = "Автопарри",
    Flag = "AutoParry",
    Default = false,
    Callback = function(v)
        _G.Settings.AutoParry = v
    end,
})

CombatParry:AddSlider({
    Name = "Дальность",
    Min = 6,
    Max = 25,
    Default = 14,
    Round = 0,
    Flag = "ParryRange",
    Callback = function(v)
        _G.Settings.ParryRange = v
    end,
})

local CombatAimbot = CombatTab:DrawSection({
    Name = "Аимбот",
    Position = "right"
})

CombatAimbot:AddToggle({
    Name = "Аимбот (общий)",
    Flag = "GeneralAimbot",
    Default = false,
    Callback = function(v)
        _G.Settings.AimAssist = _G.Settings.AimAssist or {}
        _G.Settings.AimAssist.Enabled = v
    end,
})

-- ============================================
-- Категория: Оружие
-- ============================================

Window:DrawCategory({ Name = "Оружие" })

local WeaponTab = Window:DrawTab({
    Name = "Оружие",
    Icon = "sword",
    EnableScrolling = true
})

local RevSection = WeaponTab:DrawSection({
    Name = "Револьвер",
    Position = "left"
})

RevSection:AddToggle({
    Name = "Автофарм револьвером",
    Flag = "RevolverAutofarm",
    Default = false,
    Callback = function(v)
        _G.Settings.RevolverAutofarm = v
    end,
})

RevSection:AddToggle({
    Name = "Аимбот револьвера",
    Flag = "RevolverAimbot",
    Default = false,
    Callback = function(v)
        _G.Settings.RevolverAimbot = _G.Settings.RevolverAimbot or {}
        _G.Settings.RevolverAimbot.Enabled = v
    end,
})

local VeilSection = WeaponTab:DrawSection({
    Name = "Вейл",
    Position = "right"
})

VeilSection:AddToggle({
    Name = "Траектория копья",
    Flag = "SpearTrajectory",
    Default = false,
    Callback = function(v)
        _G.Settings.SpearTrajectory = v
    end,
})

VeilSection:AddToggle({
    Name = "Аимбот копья",
    Flag = "SpearAimbot",
    Default = false,
    Callback = function(v)
        _G.Settings.SpearAimbot = _G.Settings.SpearAimbot or {}
        _G.Settings.SpearAimbot.Enabled = v
    end,
})

-- ============================================
-- Категория: Убийцы
-- ============================================

Window:DrawCategory({ Name = "Убийцы" })

local KillerTab = Window:DrawTab({
    Name = "Убийцы",
    Icon = "skull",
    EnableScrolling = true
})

local MaskedSection = KillerTab:DrawSection({
    Name = "MASKED",
    Position = "left"
})

MaskedSection:AddDropdown({
    Name = "Бафф",
    Values = {"Richter", "Alex", "Brandon", "Rabbit", "Cobra", "Tony", "Normal"},
    Default = "Normal",
    Flag = "MaskedBuff",
    Callback = function(v)
        _G.Settings.Masked = _G.Settings.Masked or {}
        _G.Settings.Masked.CurrentBuff = v
    end,
})

local StalkerSection = KillerTab:DrawSection({
    Name = "STALKER",
    Position = "right"
})

StalkerSection:AddToggle({
    Name = "Нет перезарядки",
    Flag = "StalkerNoCooldown",
    Default = false,
    Callback = function(v)
        _G.Settings.Stalker = _G.Settings.Stalker or {}
        _G.Settings.Stalker.NoCooldown = v
    end,
})

-- ============================================
-- Категория: Визуалы
-- ============================================

Window:DrawCategory({ Name = "Визуалы" })

local VisualTab = Window:DrawTab({
    Name = "Визуал",
    Icon = "palette",
    EnableScrolling = true
})

local VisGraphics = VisualTab:DrawSection({
    Name = "Графика",
    Position = "left"
})

VisGraphics:AddToggle({
    Name = "RTX Graphics",
    Flag = "RTXGraphics",
    Default = false,
    Callback = function(v)
        _G.Settings.RTXGraphics = v
    end,
})

VisGraphics:AddToggle({
    Name = "Глубина резкости",
    Flag = "CinematicDOF",
    Default = false,
    Callback = function(v)
        _G.Settings.CinematicDOF = v
    end,
})

VisGraphics:AddDropdown({
    Name = "Визуальный пресет",
    Values = {"Default", "Vibrant", "Daylight", "Cyberpunk", "Sunset", "Moonlight"},
    Default = "Default",
    Flag = "VisualPreset",
    Callback = function(v)
        _G.Settings.VisualPreset = v
    end,
})

local VisEffects = VisualTab:DrawSection({
    Name = "Эффекты",
    Position = "right"
})

VisEffects:AddToggle({
    Name = "Full Bright",
    Flag = "FullBright",
    Default = false,
    Callback = function(v)
        _G.Settings.FullBright = v
    end,
})

VisEffects:AddToggle({
    Name = "No Fog",
    Flag = "NoFog",
    Default = false,
    Callback = function(v)
        _G.Settings.NoFog = v
    end,
})

local VisCrosshair = VisualTab:DrawSection({
    Name = "Прицел",
    Position = "left"
})

VisCrosshair:AddToggle({
    Name = "Прицел",
    Flag = "Crosshair",
    Default = false,
    Callback = function(v)
        _G.Settings.ShowCrosshair = v
    end,
})

VisCrosshair:AddDropdown({
    Name = "Стиль",
    Values = {"Classic", "Dot", "Circle"},
    Default = "Classic",
    Flag = "CrosshairStyle",
    Callback = function(v)
        _G.Settings.CrosshairStyle = v
    end,
})

local VisNetwork = VisualTab:DrawSection({
    Name = "Сеть",
    Position = "right"
})

VisNetwork:AddToggle({
    Name = "Fake Lag",
    Flag = "FakeLag",
    Default = false,
    Callback = function(v)
        _G.Settings.FakeLag = v
    end,
})

VisNetwork:AddSlider({
    Name = "Задержка",
    Min = 50,
    Max = 500,
    Default = 200,
    Round = 0,
    Flag = "FakeLagMs",
    Callback = function(v)
        _G.Settings.FakeLagMs = v
    end,
})

-- ============================================
-- Категория: Конфиги
-- ============================================

Window:DrawCategory({ Name = "Конфиг" })

local ConfigTab = Window:DrawTab({
    Name = "Конфиг",
    Icon = "folder",
    Type = "Single",
    EnableScrolling = true
})

local ConfigSection = ConfigTab:DrawSection({
    Name = "Управление",
    Position = "left"
})

ConfigSection:AddButton({
    Name = "Сохранить конфиг",
    Callback = function()
        if writefile then
            local json = game:GetService("HttpService"):JSONEncode(_G.Settings)
            writefile("VD_Config.json", json)
            print("Config saved!")
        end
    end,
})

ConfigSection:AddButton({
    Name = "Загрузить конфиг",
    Callback = function()
        if isfile and isfile("VD_Config.json") then
            local json = readfile("VD_Config.json")
            _G.Settings = game:GetService("HttpService"):JSONDecode(json)
            print("Config loaded!")
        end
    end,
})

ConfigSection:AddButton({
    Name = "Сбросить настройки",
    Callback = function()
        _G.Settings = {}
        print("Settings reset!")
    end,
})

ConfigSection:AddButton({
    Name = "Выгрузить скрипт",
    Callback = function()
        Window:Destroy()
        print("Script unloaded!")
    end,
})

-- ============================================
--  ФОНОВАЯ ЛОГИКА
-- ============================================

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

task.spawn(function()
    while true do
        task.wait(0.5)
        
        local lp = Players.LocalPlayer
        local char = lp and lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        -- Speed Boost
        if _G.Settings.SpeedBoostEnabled and hum then
            hum.WalkSpeed = 16 * (_G.Settings.SpeedBoost or 1.5)
        end
        
        -- Auto Moonwalk
        if _G.Settings.AutoMoonwalk and root and hum then
            local cam = workspace.CurrentCamera
            if cam then
                hum.AutoRotate = false
                local look = cam.CFrame.LookVector
                local angle = math.atan2(look.X, look.Z)
                local sway = math.sin(tick() * 14) * 0.65
                root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, angle + sway, 0)
            end
        end
        
        -- Noclip
        if _G.Settings.NoclipVaultsPallets and char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        
        -- No Fog
        if _G.Settings.NoFog then
            Lighting.FogStart = 999999
            Lighting.FogEnd = 999999
        end
        
        -- Full Bright
        if _G.Settings.FullBright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.GlobalShadows = false
        end
        
        -- Instant Heal
        if _G.Settings.InstantHeal and hum then
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
    end
end)

-- ============================================
--  КЛАВИШИ
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = input.KeyCode
    if not key then return end
    
    if key == Enum.KeyCode.K then
        if Window.Visible then
            Window:Hide()
        else
            Window:Show()
        end
    end
end)

print("6locc VD Hub loaded! Press K to open menu.")

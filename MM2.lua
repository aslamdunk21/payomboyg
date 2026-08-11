repeat wait() until game:IsLoaded()task.wait(10) 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "PayomboyZ",
        Text = "โหลดสคริปต์สำเร็จ! เปิด UI ด้วย RightControl",
        Icon = "rbxassetid://6034287525",
        Duration = 5
    })
end)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "PayomboyZ",
    SubTitle = "MM2",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Rose", -- ใช้ธีม Rose (สีแดง/ชมพูเข้ม) เป็นค่าเริ่มต้น
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "ฟาร์มหลัก", Icon = "home" }),
    Char = Window:AddTab({ Title = "ตัวละคร", Icon = "user" }),
    Misc = Window:AddTab({ Title = "เบ็ดเตล็ด", Icon = "zap" }),
    Settings = Window:AddTab({ Title = "ตั้งค่า UI", Icon = "settings" })
}

local Options = Fluent.Options

local _G_Config = {
    AutoFarm = false,
    AutoClaim = false,
    Noclip = false,
    Speed = 90,
    Target = 40,
    Dwell = 2,
    BoostFPS = false,
    BlackScreen = false,
    AntiAFK = false
}

local isRunning = true

-- ==========================================
-- หน้าต่าง "ฟาร์มหลัก"
-- ==========================================
Tabs.Main:AddToggle("AutoFarmToggle", {Title = "เก็บเหรียญอัตโนมัติ", Default = false}):OnChanged(function(Value)
    _G_Config.AutoFarm = Value
end)

Tabs.Main:AddToggle("AutoClaimToggle", {Title = "สุ่มกล่องอัตโนมัติ", Default = false}):OnChanged(function(Value)
    _G_Config.AutoClaim = Value
end)

Tabs.Main:AddSlider("TargetSlider", {
    Title = "เป้าหมายเหรียญก่อนรีเซ็ต",
    Description = "จำนวนเหรียญที่จะให้รีเซ็ตตัวละครเมื่อเก็บครบ",
    Default = 40,
    Min = 10,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        _G_Config.Target = Value
    end
})

Tabs.Main:AddSlider("SpeedSlider", {
    Title = "ความเร็วในการฟาร์ม",
    Description = "ความเร็วในการวาร์ปไปเก็บเหรียญ",
    Default = 90,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        _G_Config.Speed = Value
    end
})

Tabs.Main:AddSlider("DwellSlider", {
    Title = "เวลาดีเลย์ต่อการเก็บ",
    Description = "ระยะเวลารอ (วินาที) หลังเก็บเหรียญ",
    Default = 2,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        _G_Config.Dwell = Value
    end
})

-- ==========================================
-- หน้าต่าง "ตัวละคร"
-- ==========================================
Tabs.Char:AddToggle("NoclipToggle", {Title = "ทะลุกำแพง (Noclip)", Default = false}):OnChanged(function(Value)
    _G_Config.Noclip = Value
end)

-- ==========================================
-- หน้าต่าง "เบ็ดเตล็ด"
-- ==========================================
Tabs.Misc:AddToggle("AntiAFKToggle", {Title = "กันหลุด (Anti-AFK)", Default = false}):OnChanged(function(Value)
    _G_Config.AntiAFK = Value
    if Value then
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            if _G_Config.AntiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end)
    end
end)

local originalLightingSettings = {}
local lightingSet = false

Tabs.Misc:AddToggle("BoostFPSToggle", {
    Title = "เพิ่ม FPS (ลดแสงและเงา)", 
    Description = "ปิดเงาเพื่อให้ลื่นขึ้น (กดปิดแล้วกลับมาเป็นปกติ)", 
    Default = false
}):OnChanged(function(Value)
    _G_Config.BoostFPS = Value
    local Lighting = game:GetService("Lighting")
    if Value then
        if not lightingSet then
            originalLightingSettings.GlobalShadows = Lighting.GlobalShadows
            originalLightingSettings.FogEnd = Lighting.FogEnd
            originalLightingSettings.ShadowSoftness = Lighting.ShadowSoftness
            lightingSet = true
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.ShadowSoftness = 0
        pcall(function() setfpscap(30) end)
    else
        if lightingSet then
            Lighting.GlobalShadows = originalLightingSettings.GlobalShadows
            Lighting.FogEnd = originalLightingSettings.FogEnd
            Lighting.ShadowSoftness = originalLightingSettings.ShadowSoftness
        end
        pcall(function() setfpscap(60) end)
    end
end)

local renderingEnabled = true
local blackScreenGui = nil

local function toggleBlackScreen(Value)
    if Value then
        if not blackScreenGui then
            blackScreenGui = Instance.new("ScreenGui")
            blackScreenGui.Name = "BlackScreenPayomboyZ"
            blackScreenGui.IgnoreGuiInset = true
            blackScreenGui.ResetOnSpawn = false
            blackScreenGui.DisplayOrder = 9999
            
            local frame = Instance.new("Frame")
            frame.BackgroundColor3 = Color3.new(0, 0, 0)
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.Parent = blackScreenGui
            
            pcall(function()
                blackScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            end)
        end
        blackScreenGui.Enabled = true
        renderingEnabled = false
        pcall(function() RunService:Set3dRenderingEnabled(false) end)
    else
        if blackScreenGui then
            blackScreenGui.Enabled = false
        end
        renderingEnabled = true
        pcall(function() RunService:Set3dRenderingEnabled(true) end)
    end
end

Tabs.Misc:AddToggle("BlackScreenToggle", {
    Title = "โหมดจอดำ (ประหยัดพลังงาน)", 
    Description = "ทำให้จอดำสนิท แต่สคริปต์ยังทำงานปกติ", 
    Default = false
}):OnChanged(function(Value)
    _G_Config.BlackScreen = Value
    toggleBlackScreen(Value)
end)

_G_Config.WebhookURL = ""
Tabs.Misc:AddInput("WebhookURL", {
    Title = "Discord Webhook URL",
    Default = "",
    Placeholder = "ใส่ URL เพื่อรับการแจ้งเตือน...",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        _G_Config.WebhookURL = Value
    end
})

local function sendWebhook(msg)
    if _G_Config.WebhookURL and _G_Config.WebhookURL ~= "" then
        pcall(function()
            local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
            if request then
                request({
                    Url = _G_Config.WebhookURL,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = game:GetService("HttpService"):JSONEncode({
                        ["content"] = "",
                        ["embeds"] = {{
                            ["title"] = "PayomboyZ - แจ้งเตือน",
                            ["description"] = msg,
                            ["color"] = tonumber(0xFF0000)
                        }}
                    })
                })
            end
        end)
    end
end

Tabs.Misc:AddButton({
    Title = "ทดสอบส่ง Webhook",
    Description = "ส่งข้อความทดสอบไปยัง Discord",
    Callback = function()
        sendWebhook("ทดสอบการเชื่อมต่อ Webhook จาก PayomboyZ สำเร็จ!")
        Fluent:Notify({Title = "Webhook", Content = "ส่งข้อความทดสอบแล้ว", Duration = 3})
    end
})

-- ==========================================
-- หน้าต่าง "ตั้งค่า UI"
-- ==========================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("PayomboyZ_MM2")
SaveManager:SetFolder("PayomboyZ_MM2/Configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "PayomboyZ",
    Content = "ตั้งค่า UI สมบูรณ์",
    Duration = 3
})

SaveManager:LoadAutoloadConfig()

-- ==========================================
-- ฟังก์ชันการทำงานพื้นหลัง (Backend)
-- ==========================================

RunService.Stepped:Connect(function()
    if _G_Config.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end
end)

local function isRoundActive()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local char = LocalPlayer.Character
    if not pg or not pg:FindFirstChild("MainGUI") or not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    
    local gameUI = pg.MainGUI:FindFirstChild("Game")
    local spectateUI = pg.MainGUI:FindFirstChild("Spectate")
    
    if not gameUI or not gameUI.Visible then return false end
    if spectateUI and spectateUI.Visible then return false end
    
    local lobby = workspace:FindFirstChild("Lobby")
    if lobby then
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local ignoreList = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then table.insert(ignoreList, p.Character) end
        end
        rayParams.FilterDescendantsInstances = ignoreList
        
        local hrp = char.HumanoidRootPart
        local rayResult = workspace:Raycast(hrp.Position, Vector3.new(0, -1000, 0), rayParams)
        if rayResult and rayResult.Instance then
            if rayResult.Instance:IsDescendantOf(lobby) then
                return false
            end
        end
    end
    return true
end

local function safeTween(hrp, targetCFrame)
    if not hrp then return end
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    local timeToReach = dist / _G_Config.Speed
    if timeToReach < 0.1 then timeToReach = 0.1 end
    
    hrp.Anchored = true
    local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    
    hrp.Anchored = false
    hrp.Velocity = Vector3.new(0, 0, 0)
end

local function checkBagFull()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    local mainGUI = pg:FindFirstChild("MainGUI")
    if not mainGUI then return false end
    local gameUI = mainGUI:FindFirstChild("Game")
    if not gameUI then return false end
    local coinBags = gameUI:FindFirstChild("CoinBags")
    if not coinBags then return false end
    local container = coinBags:FindFirstChild("Container")
    if not container then return false end
    local coin = container:FindFirstChild("Coin")
    if not coin then return false end
    local fullLabel = coin:FindFirstChild("Full")
    if fullLabel and fullLabel.Visible then
        return true
    end
    local currencyFrame = coin:FindFirstChild("CurrencyFrame")
    if currencyFrame then
        local icon = currencyFrame:FindFirstChild("Icon")
        if icon then
            local coinsText = icon:FindFirstChild("Coins")
            if coinsText and coinsText:IsA("TextLabel") then
                local num = tonumber(string.match(coinsText.Text, "%d+"))
                if num and num >= _G_Config.Target then
                    return true
                end
            end
        end
    end
    
    return false
end

local function resetCharacter()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.Health = 0 end 
        char:BreakJoints() 
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(0, -50000, 0)
        end
    end
end

local function checkBagFullAction()
    if checkBagFull() then
        sendWebhook("เป้าหมายครบแล้ว! กำลังรีเซ็ตตัวละครเพื่อรับเหรียญ 💰")
        resetCharacter()
        return true
    end
    return false
end

local function autoCollectCoins()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local coinContainer = nil
    for _, mapFolder in pairs(workspace:GetChildren()) do
        local cc = mapFolder:FindFirstChild("CoinContainer")
        if cc then coinContainer = cc break end
    end
    if not coinContainer then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "CoinContainer" then coinContainer = v break end
        end
    end
    
    local coins = {}
    if coinContainer then
        for _, v in pairs(coinContainer:GetDescendants()) do
            if string.find(string.lower(v.Name), "coin") then
                if v:IsA("BasePart") and v.Transparency < 1 then
                    table.insert(coins, v)
                elseif v:IsA("Model") and v.PrimaryPart then
                    table.insert(coins, v.PrimaryPart)
                end
            end
        end
    end
    
    while #coins > 0 do
        if not isRunning or not isRoundActive() or not _G_Config.AutoFarm then break end
        
        if checkBagFullAction() then return end
        
        local closestCoin = nil
        local closestDist = math.huge
        local closestIndex = nil
        
        for i, coin in ipairs(coins) do
            if coin and coin.Parent and coin.Transparency < 1 then
                local dist = (hrp.Position - coin.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestCoin = coin
                    closestIndex = i
                end
            end
        end
        
        if not closestCoin then break end
        table.remove(coins, closestIndex)
        
        local coin = closestCoin
        if coin and coin.Parent and coin.Transparency < 1 then
            local targetPos = CFrame.new(coin.Position + Vector3.new(0, 3.5, 0))
            safeTween(hrp, targetPos)
            
            if firetouchinterest then
                firetouchinterest(hrp, coin, 0)
                firetouchinterest(hrp, coin, 1)
            end
            task.wait(_G_Config.Dwell)
            
            if checkBagFullAction() then return end
        end
    end
end

task.spawn(function()
    while isRunning do
        if isRoundActive() then
            if checkBagFullAction() then
                task.wait(2)
            else
                autoCollectCoins()
            end
        else
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Anchored = false
            end
            task.wait(1)
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local shop = remotes:FindFirstChild("Shop")
        if shop then
            local openCrate = shop:FindFirstChild("OpenCrate")
            if openCrate then
                while isRunning do
                    if _G_Config.AutoClaim then
                        task.spawn(function()
                            pcall(function()
                                openCrate:InvokeServer("Summer2026Box", "MysteryBox", "SummerKey2026")
                            end)
                        end)

                        task.spawn(function()
                            pcall(function()
                                openCrate:InvokeServer("MysteryBox2", "MysteryBox", "Coins")
                            end)
                        end)
                    end
                    task.wait(1.5) 
                end
            end
        end
    end
end)

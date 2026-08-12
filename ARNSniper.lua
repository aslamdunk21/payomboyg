local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- ==========================================
-- การตั้งค่า (Settings)
-- ==========================================
local Settings = {
    ESPEnabled = false,
    ShowNames = true,
    ShowDistance = true,
    TeamCheck = true,  -- ซ่อน ESP ของทีมเดียวกัน
    MaxDistance = 1000, -- ระยะสูงสุดที่จะแสดง tracer (studs)
    FPSBoost = false,
    HitboxExpander = false,
    HighlightESP = false,
    AimbotEnabled = false,
    ShowFOV = false,
    FOVRadius = 150
}

-- ==========================================
-- สร้าง UI หลัก
-- ==========================================์
-- ลบ UI เก่าถ้ามีอยู่แล้ว (ป้องกันซ้ำซ้อนเมื่อ execute หลายครั้ง)
local oldUI = (game:GetService("CoreGui") or player.PlayerGui):FindFirstChild("PayomboyZ")
if oldUI then oldUI:Destroy() end

local oldESP = (game:GetService("CoreGui") or player.PlayerGui):FindFirstChild("ESP_Tracers")
if oldESP then oldESP:Destroy() end

local UI = Instance.new("ScreenGui")
UI.Name = "PayomboyZ"
UI.ResetOnSpawn = false
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
UI.Parent = success and coreGui or player:WaitForChild("PlayerGui")

-- ==========================================
-- สร้าง Frame หลัก
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 270)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = UI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- เส้นขอบสีสวย
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 80, 80)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- ==========================================
-- แถบชื่อ (Title Bar)
-- ==========================================
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 42)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.BorderSizePixel = 0
Title.Text = "🎯 PayomboyZ | Sniper Arena"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitlePadding = Instance.new("UIPadding")
TitlePadding.PaddingLeft = UDim.new(0, 15)
TitlePadding.Parent = Title

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- ต่อพื้นหลังแถบชื่อไม่ให้มีมุมล่างโค้ง
local TitleExtension = Instance.new("Frame")
TitleExtension.Size = UDim2.new(1, 0, 0, 10)
TitleExtension.Position = UDim2.new(0, 0, 1, -10)
TitleExtension.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleExtension.BorderSizePixel = 0
TitleExtension.Parent = Title

-- ==========================================
-- ปุ่มปิด (X) และ ปุ่มย่อ (-)
-- ==========================================
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -73, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = MainFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Name = "StatsLabel"
StatsLabel.Size = UDim2.new(0, 130, 0, 30)
StatsLabel.Position = UDim2.new(1, -210, 0, 6)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: -- | Ping: -- ms"
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextSize = 12
StatsLabel.TextXAlignment = Enum.TextXAlignment.Right
StatsLabel.Parent = MainFrame

-- ==========================================
-- กรอบเนื้อหา (Content)
-- ==========================================
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.CellSize = UDim2.new(0, 185, 0, 38)
UIGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.Parent = Content

-- ==========================================
-- ฟังก์ชันสร้างปุ่ม Toggle
-- ==========================================
local function createToggle(name, text, defaultValue, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 185, 0, 38)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(80, 30, 30)
    btn.Text = text .. "\n" .. (defaultValue and "✅ เปิด" or "❌ ปิด")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local state = defaultValue
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. "\n" .. (state and "✅ เปิด" or "❌ ปิด")
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(80, 30, 30)
        callback(state)
    end)
    return btn
end

-- ==========================================
-- สร้าง ESP Gui ก่อน (ต้อง declare ก่อนใช้)
-- ==========================================
local tracerGui = Instance.new("ScreenGui")
tracerGui.Name = "ESP_Tracers"
tracerGui.ResetOnSpawn = false
tracerGui.IgnoreGuiInset = true
tracerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
tracerGui.Parent = UI.Parent

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "PayomFOV"
FOVGui.ResetOnSpawn = false
FOVGui.IgnoreGuiInset = true
FOVGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FOVGui.Parent = UI.Parent

local FOVFrame = Instance.new("Frame")
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Size = UDim2.new(0, Settings.FOVRadius * 2, 0, Settings.FOVRadius * 2)
FOVFrame.Visible = Settings.ShowFOV
local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(0.5, 0)
FOVCorner.Parent = FOVFrame
local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVFrame
FOVFrame.Parent = FOVGui

local tracers = {}    -- เก็บ Frame ของ tracer แต่ละคน
local espLabels = {}  -- เก็บ Label ชื่อ+ระยะทาง

-- ==========================================
-- ฟังก์ชัน ESP: สร้าง / ลบ tracer
-- ==========================================
local function createTracer(targetPlayer)
    if targetPlayer == player then return end
    if tracers[targetPlayer] then return end -- ป้องกัน duplicate

    -- เส้น Tracer
    local line = Instance.new("Frame")
    line.Name = targetPlayer.Name .. "_Tracer"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    line.BorderSizePixel = 0
    line.Visible = false
    line.ZIndex = 5
    line.Parent = tracerGui
    tracers[targetPlayer] = line

    -- ป้ายชื่อ + ระยะทาง
    local label = Instance.new("TextLabel")
    label.Name = targetPlayer.Name .. "_Label"
    label.Size = UDim2.new(0, 150, 0, 35)
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.BackgroundTransparency = 0.4
    label.BorderSizePixel = 0
    label.Text = targetPlayer.Name .. "\n0 studs"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 11
    label.Font = Enum.Font.GothamSemibold
    label.Visible = false
    label.ZIndex = 6
    label.Parent = tracerGui
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 4)
    espLabels[targetPlayer] = label
end

local function removeTracer(targetPlayer)
    if tracers[targetPlayer] then
        tracers[targetPlayer]:Destroy()
        tracers[targetPlayer] = nil
    end
    if espLabels[targetPlayer] then
        espLabels[targetPlayer]:Destroy()
        espLabels[targetPlayer] = nil
    end
end

-- สร้าง tracer สำหรับผู้เล่นที่อยู่ในเกมแล้ว
for _, p in ipairs(Players:GetPlayers()) do
    createTracer(p)
end
Players.PlayerAdded:Connect(createTracer)
Players.PlayerRemoving:Connect(removeTracer)

-- ==========================================
-- สร้างปุ่ม Toggle บน UI
-- ==========================================
createToggle("ESPToggle", "🔍 ESP Tracers", Settings.ESPEnabled, function(state)
    Settings.ESPEnabled = state
    if not state then
        -- ซ่อน tracer และ label ทั้งหมดเมื่อปิด
        for _, line in pairs(tracers) do
            line.Visible = false
        end
        for _, label in pairs(espLabels) do
            label.Visible = false
        end
    end
end)

createToggle("TeamCheckToggle", "🤝 ซ่อนทีมเดียวกัน", Settings.TeamCheck, function(state)
    Settings.TeamCheck = state
end)

local function toggleFPSBoost(state)
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    
    if state then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
        end
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") and not v:IsA("Terrain") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end)
        end
        pcall(function()
            if getgenv and getgenv().setfpscap then
                getgenv().setfpscap(999)
            elseif setfpscap then
                setfpscap(999)
            end
        end)
    else
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        pcall(function()
            if getgenv and getgenv().setfpscap then
                getgenv().setfpscap(60)
            elseif setfpscap then
                setfpscap(60)
            end
        end)
    end
end

createToggle("FPSBoostToggle", "🚀 FPS Boost", Settings.FPSBoost, function(state)
    Settings.FPSBoost = state
    toggleFPSBoost(state)
end)

createToggle("HitboxToggle", "🎯 ขยายเป้า (Hitbox)", Settings.HitboxExpander, function(state)
    Settings.HitboxExpander = state
end)

createToggle("HighlightToggle", "✨ มองทะลุ (Highlight)", Settings.HighlightESP, function(state)
    Settings.HighlightESP = state
end)

createToggle("AimbotToggle", "🔫 ล็อคหัว (Aimbot)", Settings.AimbotEnabled, function(state)
    Settings.AimbotEnabled = state
end)

createToggle("FOVToggle", "⭕ แสดงวงกลม FOV", Settings.ShowFOV, function(state)
    Settings.ShowFOV = state
    if FOVFrame then FOVFrame.Visible = state end
end)

-- ==========================================
-- ปุ่ม Minimize และ Close
-- ==========================================
local isMinimized = false
local originalSize = MainFrame.Size

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 420, 0, 42)
        TitleExtension.Visible = false
        Content.Visible = false
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = originalSize
        TitleExtension.Visible = true
        Content.Visible = true
        MinimizeBtn.Text = "−"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- ทำลาย ESP gui ก่อน แล้วค่อยทำลาย UI หลัก
    if tracerGui and tracerGui.Parent then
        tracerGui:Destroy()
    end
    if FOVGui and FOVGui.Parent then
        FOVGui:Destroy()
    end
    UI:Destroy()
end)

-- ==========================================
-- ฟังก์ชันช่วย: ตรวจสอบทีม (รองรับระบบทีมทุกรูปแบบของเกม)
-- ==========================================
local function isSameTeam(targetPlayer)
    if not Settings.TeamCheck then return false end
    if not targetPlayer then return false end
    
    -- 1. เช็คจาก Roblox Team Standard
    if player.Team and targetPlayer.Team then
        if player.Neutral or targetPlayer.Neutral then return false end
        if player.Team.Name == "Neutral" or targetPlayer.Team.Name == "Neutral" then return false end
        if player.Team == targetPlayer.Team then return true end
    end
    
    -- 2. เช็คจาก TeamColor Standard
    if player.TeamColor and targetPlayer.TeamColor and player.TeamColor == targetPlayer.TeamColor then
        if player.TeamColor.Name ~= "White" and player.TeamColor.Name ~= "Medium stone grey" then
            return true
        end
    end

    -- 3. เช็คจาก Custom Team Attribute / Leaderstats ในตัวละครหรือผู้เล่น
    local myTeamVal = player:FindFirstChild("Team") or (player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Team"))
    local targetTeamVal = targetPlayer:FindFirstChild("Team") or (targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Team"))
    if myTeamVal and targetTeamVal and myTeamVal.Value == targetTeamVal.Value and tostring(myTeamVal.Value) ~= "" then
        return true
    end

    return false
end

-- ==========================================
-- ฟังก์ชันช่วย: คำนวณสีตามระยะทาง
-- ==========================================
local function getColorByDistance(dist)
    if dist < 100 then
        return Color3.fromRGB(255, 50, 50)   -- แดง = ใกล้มาก (อันตราย)
    elseif dist < 300 then
        return Color3.fromRGB(255, 165, 0)   -- ส้ม = ใกล้
    elseif dist < 600 then
        return Color3.fromRGB(255, 255, 50)  -- เหลือง = กลาง
    else
        return Color3.fromRGB(50, 200, 50)   -- เขียว = ไกล
    end
end

-- ==========================================
-- ลูปทำงานเบื้องหลัง: Hitbox & Highlight
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                pcall(function()
                    local char = p.Character
                    if not char then return end
                    
                    -- 1. จัดการ Highlight ESP (มองทะลุเรืองแสง)
                    local hl = char:FindFirstChild("PayomHighlight")
                    if Settings.HighlightESP and not (Settings.TeamCheck and isSameTeam(p)) then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "PayomHighlight"
                                hl.FillColor = Color3.fromRGB(255, 50, 50)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.6
                                hl.OutlineTransparency = 0.2
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = char
                            end
                        else
                            if hl then hl:Destroy() end
                        end
                    else
                        if hl then hl:Destroy() end
                    end

                    -- 2. จัดการ Hitbox Expander (ขยายเป้ายิง)
                    if Settings.HitboxExpander and not isSameTeam(p) then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            for _, partName in ipairs({"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}) do
                                local part = char:FindFirstChild(partName)
                                if part and part:IsA("BasePart") then
                                    if not part:FindFirstChild("OrigSize") then
                                        local origSize = Instance.new("Vector3Value")
                                        origSize.Name = "OrigSize"
                                        origSize.Value = part.Size
                                        origSize.Parent = part
                                    end
                                    part.Size = Vector3.new(20, 20, 20)
                                    part.Transparency = 0.96
                                    part.Color = Color3.fromRGB(0, 170, 255)
                                    part.Material = Enum.Material.SmoothPlastic
                                    part.CanCollide = false
                                end
                            end
                        end
                    else
                        for _, partName in ipairs({"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}) do
                            local part = char:FindFirstChild(partName)
                            if part and part:IsA("BasePart") and part:FindFirstChild("OrigSize") then
                                part.Size = part.OrigSize.Value
                                if part.Name == "HumanoidRootPart" then
                                    part.Transparency = 1
                                else
                                    part.Transparency = 0
                                end
                            end
                        end
                    end
                end)
            end
        end
    end
end)

-- ==========================================
-- RenderStepped Loop: อัปเดต ESP ทุก frame
-- ==========================================
local lastTime = tick()
local frameCount = 0
local aimbotting = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        aimbotting = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        aimbotting = false
    end
end)

local function getClosestPlayerToCenter()
    local closestPlayer = nil
    local shortestDistance = Settings.FOVRadius
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            if isSameTeam(p) then continue end
            local char = p.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                local rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                if rootPart then
                    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local screenPos = Vector2.new(vector.X, vector.Y)
                        local dist = (screenPos - centerPos).Magnitude
                        
                        -- หากเปิดขยาย Hitbox ให้คำนวณรัศมีกล่อง 20x20x20 บนหน้าจอ 2D
                        if Settings.HitboxExpander and rootPart.Name == "HumanoidRootPart" then
                            local estimatedRadius2D = (rootPart.Size.X * 12) / math.max(1, vector.Z)
                            dist = math.max(0, dist - estimatedRadius2D)
                        end

                        if dist < shortestDistance then
                            shortestDistance = dist
                            closestPlayer = p
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if Settings.ShowFOV and FOVFrame then
        FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    end
    
    if Settings.AimbotEnabled and aimbotting then
        local target = getClosestPlayerToCenter()
        if target and target.Character then
            local aimTarget = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Head")
            if aimTarget then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimTarget.Position)
            end
        end
    end

    frameCount = frameCount + 1
    if tick() - lastTime >= 1 then
        local fps = frameCount
        local ping = 0
        pcall(function()
            local networkPing = player:GetNetworkPing()
            if networkPing then
                ping = math.floor(networkPing * 1000)
            else
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end
        end)
        if StatsLabel then
            StatsLabel.Text = string.format("FPS: %d | Ping: %d ms", fps, ping)
        end
        frameCount = 0
        lastTime = tick()
    end

    if not Settings.ESPEnabled then return end

    local myCharacter = player.Character
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

    -- อัปเดต ESP รายคนโดยอิงจาก Players:GetPlayers() สดๆ เสมอ
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer == player then continue end

        -- ป้องกัน missing tracer/label ถ้าพึ่งเข้ามา
        if not tracers[targetPlayer] or not espLabels[targetPlayer] then
            createTracer(targetPlayer)
        end

        local line = tracers[targetPlayer]
        local label = espLabels[targetPlayer]
        if not line or not label then continue end

        -- ตรวจสอบ Team Check
        if isSameTeam(targetPlayer) then
            line.Visible = false
            label.Visible = false
            continue
        end

        local character = targetPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if character and rootPart and humanoid and humanoid.Health > 0 then
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            -- คำนวณระยะทางจริงในโลก 3D
            local worldDist = myRoot and (rootPart.Position - myRoot.Position).Magnitude or 0

            -- ซ่อนถ้าเกินระยะที่กำหนด
            if worldDist > Settings.MaxDistance then
                line.Visible = false
                label.Visible = false
                continue
            end

            if onScreen then
                local startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                local endPos = Vector2.new(vector.X, vector.Y)

                local distance2D = (endPos - startPos).Magnitude
                local center = (startPos + endPos) / 2
                local angle = math.deg(math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X))
                local tracerColor = getColorByDistance(worldDist)

                -- อัปเดต tracer line
                line.Position = UDim2.new(0, center.X, 0, center.Y)
                line.Size = UDim2.new(0, distance2D, 0, 2)
                line.Rotation = angle
                line.BackgroundColor3 = tracerColor
                line.Visible = true

                -- อัปเดต label ชื่อ + ระยะทาง
                label.Position = UDim2.new(0, vector.X, 0, vector.Y - 5)
                label.Text = targetPlayer.Name .. "\n" .. math.floor(worldDist) .. " studs"
                label.TextColor3 = tracerColor
                label.Visible = true
            else
                line.Visible = false
                label.Visible = false
            end
        else
            line.Visible = false
            label.Visible = false
        end
    end
end)

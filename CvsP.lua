-- ======================================================================================
-- [[ PAYOMBOYZ HUB - OBSIDIAN GLASSMORPHIC 2 UI ENGINE ]]
-- Map: คาปิบาร่า vs ต้นไม้ (Capybara vs Trees)
-- Features: Auto Buy Eggs, Auto Place Eggs, Auto Buy Gears, Auto Buy Merchant,
--           Auto Hatch, Auto Equip Best, Auto Boss, Auto Sell All, Dynamic Dropdown Update
-- ======================================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Remotes & Modules
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local modules = ReplicatedStorage:WaitForChild("Modules")

local shopDataModule = require(modules:WaitForChild("ShopData"))
local bossDataModule = require(modules:WaitForChild("BossData"))

local buyItemRemote = remotes:WaitForChild("BuyItem")
local requestPersonalStockRemote = remotes:WaitForChild("RequestPersonalStock")
local buyMerchantItemRemote = remotes:WaitForChild("BuyMerchantItem")
local requestMerchantStockRemote = remotes:WaitForChild("RequestMerchantStock")
local hatchRemote = remotes:WaitForChild("Hatch")
local equipBestPlantsRemote = remotes:WaitForChild("EquipBestPlants")
local summonBossRemote = remotes:WaitForChild("SummonBoss")
local sellRemote = remotes:WaitForChild("Sell")
local placeEggRemote = remotes:FindFirstChild("Place") or remotes:FindFirstChild("PlaceEgg") or remotes:FindFirstChild("PlaceItem") or remotes:FindFirstChild("UseItem")

-----------------------------------------------------------------------------------------
-- 🎨 COLOR PALETTE SPECIFICATION (Obsidian Glassmorphic 2 Theme)
-----------------------------------------------------------------------------------------
local COLORS = {
    backdrop = Color3.fromRGB(12, 5, 8),
    shell = Color3.fromRGB(20, 10, 14),
    glass = Color3.fromRGB(32, 14, 20),
    glassDeep = Color3.fromRGB(25, 11, 16),
    glassRaised = Color3.fromRGB(48, 18, 28),
    userPanel = Color3.fromRGB(28, 12, 18),
    surface = Color3.fromRGB(42, 18, 26),
    surfaceRaised = Color3.fromRGB(58, 24, 34),
    surfaceHover = Color3.fromRGB(78, 30, 44),
    surfacePressed = Color3.fromRGB(34, 14, 20),
    input = Color3.fromRGB(20, 9, 13),
    inputFocus = Color3.fromRGB(36, 14, 22),
    divider = Color3.fromRGB(140, 40, 60),
    primary = Color3.fromRGB(255, 45, 85),
    primaryHover = Color3.fromRGB(255, 75, 110),
    primaryPressed = Color3.fromRGB(210, 30, 65),
    secondary = Color3.fromRGB(52, 18, 28),
    text = Color3.fromRGB(255, 255, 255),
    textMuted = Color3.fromRGB(242, 218, 228),
    textFaint = Color3.fromRGB(210, 168, 182),
    cyan = Color3.fromRGB(255, 55, 85),
    success = Color3.fromRGB(46, 224, 140),
    warning = Color3.fromRGB(255, 185, 70),
    danger = Color3.fromRGB(255, 60, 60),
    disabled = Color3.fromRGB(50, 25, 32),
}

local ObsidianGlassEngine = { Options = {} }

-- UI Sound Effect Helper
local function playClickSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6895079853"
        sound.Volume = 0.3
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
end

local customAvatarAsset = nil
local function loadCustomAvatarImage()
    if customAvatarAsset then return customAvatarAsset end
    local avatarUrl = "https://raw.githubusercontent.com/aslamdunk7/paypmboygang/main/543199739_2812856088914181_3062917809445648175_n.jpg"
    local fileName = "payomboyz_avatar.jpg"
    
    pcall(function()
        if typeof(writefile) == "function" and (typeof(getcustomasset) == "function" or typeof(getsynasset) == "function") then
            local getAsset = getcustomasset or getsynasset
            local isFileExist = (typeof(isfile) == "function" and isfile(fileName))
            if not isFileExist then
                local imageBytes = game:HttpGet(avatarUrl)
                if imageBytes and #imageBytes > 0 then
                    writefile(fileName, imageBytes)
                end
            end
            if typeof(isfile) == "function" and isfile(fileName) then
                customAvatarAsset = getAsset(fileName)
            end
        end
    end)

    if not customAvatarAsset then
        customAvatarAsset = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    end
    return customAvatarAsset
end

-- TOAST NOTIFICATION ENGINE
function ObsidianGlassEngine:Notify(cfg)
    pcall(function()
        local title = cfg.Title or "System"
        local content = cfg.Content or cfg.Desc or ""
        local duration = cfg.Duration or 4
        
        local parentGui = (typeof(gethui) == "function") and gethui() or CoreGui
        local notifHolder = parentGui:FindFirstChild("ObsidianGlass_NotifHolder")
        if not notifHolder then
            notifHolder = Instance.new("ScreenGui")
            notifHolder.Name = "ObsidianGlass_NotifHolder"
            notifHolder.ResetOnSpawn = false
            notifHolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            notifHolder.Parent = parentGui
        end
        
        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(0, 300, 0, 65)
        toast.Position = UDim2.new(1, 20, 1, -85)
        toast.BackgroundColor3 = COLORS.glass
        toast.BackgroundTransparency = 0.15
        toast.BorderSizePixel = 0
        toast.Parent = notifHolder
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = toast
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = COLORS.cyan
        stroke.Thickness = 1.5
        stroke.Parent = toast
        
        local tTitle = Instance.new("TextLabel")
        tTitle.Size = UDim2.new(1, -20, 0, 22)
        tTitle.Position = UDim2.new(0, 10, 0, 6)
        tTitle.BackgroundTransparency = 1
        tTitle.Text = title
        tTitle.TextColor3 = COLORS.cyan
        tTitle.Font = Enum.Font.GothamBold
        tTitle.TextSize = 13
        tTitle.TextXAlignment = Enum.TextXAlignment.Left
        tTitle.Parent = toast
        
        local tDesc = Instance.new("TextLabel")
        tDesc.Size = UDim2.new(1, -20, 0, 32)
        tDesc.Position = UDim2.new(0, 10, 0, 26)
        tDesc.BackgroundTransparency = 1
        tDesc.Text = content
        tDesc.TextColor3 = COLORS.text
        tDesc.Font = Enum.Font.Gotham
        tDesc.TextSize = 11
        tDesc.TextWrapped = true
        tDesc.TextXAlignment = Enum.TextXAlignment.Left
        tDesc.Parent = toast
        
        playClickSound()
        TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(1, -320, 1, -85) }):Play()
        task.delay(duration, function()
            if toast and toast.Parent then
                local tw = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = UDim2.new(1, 20, 1, -85) })
                tw:Play()
                tw.Completed:Connect(function() toast:Destroy() end)
            end
        end)
    end)
end

-- MAIN WINDOW ENGINE
function ObsidianGlassEngine:CreateWindow(cfg)
    local parentGui = (typeof(gethui) == "function") and gethui() or CoreGui
    if parentGui:FindFirstChild("ObsidianGlass2_UI") then
        parentGui.ObsidianGlass2_UI:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ObsidianGlass2_UI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 99999
    gui.Parent = parentGui

    local uiScale = Instance.new("UIScale")
    
    -- 📱 AUTOMATIC MOBILE RESPONSIVE SCALING ENGINE
    local camera = workspace.CurrentCamera
    local function updateScale()
        if camera and camera.ViewportSize then
            local vp = camera.ViewportSize
            local targetWidth, targetHeight = 920, 600
            local scaleX = (vp.X - 24) / targetWidth
            local scaleY = (vp.Y - 24) / targetHeight
            local calcScale = math.clamp(math.min(scaleX, scaleY), 0.45, 1.0)
            uiScale.Scale = calcScale
        end
    end
    updateScale()
    if camera then
        camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end
    uiScale.Parent = gui

    local shell = Instance.new("Frame")
    shell.Name = "MainShell"
    shell.Size = UDim2.fromOffset(920, 600)
    shell.AnchorPoint = Vector2.new(0.5, 0.5)
    shell.Position = UDim2.new(0.5, 0, 0.5, 0)
    shell.BackgroundColor3 = COLORS.shell
    shell.BackgroundTransparency = 0.20
    shell.BorderSizePixel = 0
    shell.ClipsDescendants = true
    shell.Parent = gui

    local shellCorner = Instance.new("UICorner")
    shellCorner.CornerRadius = UDim.new(0, 18)
    shellCorner.Parent = shell

    local shellStroke = Instance.new("UIStroke")
    shellStroke.Color = COLORS.cyan
    shellStroke.Thickness = 1.5
    shellStroke.Transparency = 0.3
    shellStroke.Parent = shell

    -- PARTICLES ANIMATION LAYER
    local snowLayer = Instance.new("Frame")
    snowLayer.Name = "SnowLayer"
    snowLayer.Size = UDim2.fromScale(1, 1)
    snowLayer.BackgroundTransparency = 1
    snowLayer.ZIndex = 2
    snowLayer.Parent = shell

    task.spawn(function()
        local dots = {}
        for i = 1, 35 do
            local dot = Instance.new("Frame")
            dot.Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4))
            dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
            dot.BackgroundColor3 = Color3.fromRGB(220, 240, 255)
            dot.BackgroundTransparency = math.random(30, 70) / 100
            dot.BorderSizePixel = 0
            dot.Parent = snowLayer

            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(1, 0)
            dCorner.Parent = dot

            dots[#dots + 1] = {
                frame = dot,
                speed = math.random(15, 40) / 10000,
                drift = math.random(-10, 10) / 10000,
                pos = dot.Position.Y.Scale
            }
        end

        while task.wait(0.03) do
            if not gui or not gui.Parent then break end
            for _, data in ipairs(dots) do
                data.pos = data.pos + data.speed
                if data.pos > 1.05 then data.pos = -0.05 end
                local newX = (data.frame.Position.X.Scale + data.drift) % 1.0
                data.frame.Position = UDim2.new(newX, 0, data.pos, 0)
            end
        end
    end)

    -- DRAGGABLE TOGGLE CAPSULE WITH SNOW, IMAGE & METRICS (FPS/PING)
    local toggleCapsule = Instance.new("Frame")
    toggleCapsule.Name = "ObsidianToggleCapsule"
    toggleCapsule.Size = UDim2.fromOffset(230, 58)
    toggleCapsule.Position = UDim2.new(0, 15, 0.5, -29)
    toggleCapsule.BackgroundColor3 = COLORS.shell
    toggleCapsule.BackgroundTransparency = 0.18
    toggleCapsule.BorderSizePixel = 0
    toggleCapsule.ClipsDescendants = true
    toggleCapsule.ZIndex = 99999
    toggleCapsule.Parent = gui

    local tcCorner = Instance.new("UICorner")
    tcCorner.CornerRadius = UDim.new(0, 16)
    tcCorner.Parent = toggleCapsule

    local tcStroke = Instance.new("UIStroke")
    tcStroke.Color = COLORS.cyan
    tcStroke.Thickness = 1.5
    tcStroke.Transparency = 0.2
    tcStroke.Parent = toggleCapsule

    local capsuleSnowLayer = Instance.new("Frame")
    capsuleSnowLayer.Name = "CapsuleSnowLayer"
    capsuleSnowLayer.Size = UDim2.fromScale(1, 1)
    capsuleSnowLayer.BackgroundTransparency = 1
    capsuleSnowLayer.ZIndex = 1
    capsuleSnowLayer.Parent = toggleCapsule

    task.spawn(function()
        local dots = {}
        for i = 1, 12 do
            local dot = Instance.new("Frame")
            dot.Size = UDim2.fromOffset(math.random(2, 3), math.random(2, 3))
            dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
            dot.BackgroundColor3 = Color3.fromRGB(220, 240, 255)
            dot.BackgroundTransparency = math.random(30, 70) / 100
            dot.BorderSizePixel = 0
            dot.ZIndex = 1
            dot.Parent = capsuleSnowLayer

            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(1, 0)
            dCorner.Parent = dot

            dots[#dots + 1] = {
                frame = dot,
                speed = math.random(15, 35) / 10000,
                drift = math.random(-10, 10) / 10000,
                pos = dot.Position.Y.Scale
            }
        end

        while task.wait(0.03) do
            if not gui or not gui.Parent or not toggleCapsule or not toggleCapsule.Parent then break end
            for _, data in ipairs(dots) do
                data.pos = data.pos + data.speed
                if data.pos > 1.05 then data.pos = -0.05 end
                local newX = (data.frame.Position.X.Scale + data.drift) % 1.0
                data.frame.Position = UDim2.new(newX, 0, data.pos, 0)
            end
        end
    end)

    local capAvatarFrame = Instance.new("Frame")
    capAvatarFrame.Size = UDim2.fromOffset(42, 42)
    capAvatarFrame.Position = UDim2.new(0, 8, 0.5, -21)
    capAvatarFrame.BackgroundColor3 = COLORS.glassDeep
    capAvatarFrame.BorderSizePixel = 0
    capAvatarFrame.ZIndex = 3
    capAvatarFrame.Parent = toggleCapsule

    local caCorner = Instance.new("UICorner")
    caCorner.CornerRadius = UDim.new(1, 0)
    caCorner.Parent = capAvatarFrame

    local caStroke = Instance.new("UIStroke")
    caStroke.Color = COLORS.primary
    caStroke.Thickness = 1.5
    caStroke.Parent = capAvatarFrame

    local capAvatarImg = Instance.new("ImageLabel")
    capAvatarImg.Size = UDim2.fromScale(1, 1)
    capAvatarImg.BackgroundTransparency = 1
    capAvatarImg.Image = loadCustomAvatarImage()
    capAvatarImg.ZIndex = 4
    capAvatarImg.Parent = capAvatarFrame

    local caiCorner = Instance.new("UICorner")
    caiCorner.CornerRadius = UDim.new(1, 0)
    caiCorner.Parent = capAvatarImg

    local capUserLabel = Instance.new("TextLabel")
    capUserLabel.Size = UDim2.new(1, -58, 0, 18)
    capUserLabel.Position = UDim2.new(0, 56, 0, 10)
    capUserLabel.BackgroundTransparency = 1
    capUserLabel.Text = "@" .. LocalPlayer.Name
    capUserLabel.TextColor3 = COLORS.text
    capUserLabel.Font = Enum.Font.GothamBold
    capUserLabel.TextSize = 12
    capUserLabel.TextXAlignment = Enum.TextXAlignment.Left
    capUserLabel.ZIndex = 3
    capUserLabel.Parent = toggleCapsule

    local capMetricsLabel = Instance.new("TextLabel")
    capMetricsLabel.Size = UDim2.new(1, -58, 0, 16)
    capMetricsLabel.Position = UDim2.new(0, 56, 0, 28)
    capMetricsLabel.BackgroundTransparency = 1
    capMetricsLabel.Text = "⚡ 60 FPS  •  📡 0 ms"
    capMetricsLabel.TextColor3 = COLORS.cyan
    capMetricsLabel.Font = Enum.Font.GothamBold
    capMetricsLabel.TextSize = 10
    capMetricsLabel.TextXAlignment = Enum.TextXAlignment.Left
    capMetricsLabel.ZIndex = 3
    capMetricsLabel.Parent = toggleCapsule

    task.spawn(function()
        local frameCount = 0
        local lastFpsTime = tick()
        local fpsVal = 60

        local renderConn
        renderConn = RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            local now = tick()
            if now - lastFpsTime >= 1 then
                fpsVal = frameCount
                frameCount = 0
                lastFpsTime = now
            end
        end)

        while task.wait(0.8) do
            if not gui or not gui.Parent or not toggleCapsule or not toggleCapsule.Parent then
                if renderConn then renderConn:Disconnect() end
                break
            end
            local pingVal = 0
            pcall(function() pingVal = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            capMetricsLabel.Text = string.format("⚡ %d FPS  •  📡 %d ms", fpsVal, pingVal)
        end
    end)

    local capBtn = Instance.new("TextButton")
    capBtn.Size = UDim2.fromScale(1, 1)
    capBtn.BackgroundTransparency = 1
    capBtn.Text = ""
    capBtn.ZIndex = 10
    capBtn.Parent = toggleCapsule

    local tDragging, tDragInput, tDragStart, tStartPos
    local hasDragged = false

    capBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tDragging = true
            hasDragged = false
            tDragStart = input.Position
            tStartPos = toggleCapsule.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    tDragging = false
                end
            end)
        end
    end)

    capBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            tDragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == tDragInput and tDragging then
            local delta = input.Position - tDragStart
            if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
                hasDragged = true
            end
            toggleCapsule.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
        end
    end)

    capBtn.MouseButton1Click:Connect(function()
        if not hasDragged then
            playClickSound()
            shell.Visible = not shell.Visible
        end
    end)

    -- KEYBIND TOGGLE (KEY [K] / [LeftControl])
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.LeftControl then
            shell.Visible = not shell.Visible
        end
    end)

    -- LEFT SIDEBAR (USER PROFILE & NAVIGATION)
    local userPanel = Instance.new("Frame")
    userPanel.Name = "UserPanel"
    userPanel.Size = UDim2.new(0, 240, 1, 0)
    userPanel.BackgroundColor3 = COLORS.userPanel
    userPanel.BackgroundTransparency = 0.20
    userPanel.BorderSizePixel = 0
    userPanel.ZIndex = 5
    userPanel.Parent = shell

    local userDiv = Instance.new("Frame")
    userDiv.Size = UDim2.new(0, 1, 1, 0)
    userDiv.Position = UDim2.new(1, -1, 0, 0)
    userDiv.BackgroundColor3 = COLORS.glassRaised
    userDiv.BorderSizePixel = 0
    userDiv.ZIndex = 10
    userDiv.Parent = userPanel

    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.fromOffset(44, 44)
    avatarFrame.Position = UDim2.new(0, 14, 0, 14)
    avatarFrame.BackgroundColor3 = COLORS.glassDeep
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 10
    avatarFrame.Parent = userPanel

    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0)
    avCorner.Parent = avatarFrame

    local avStroke = Instance.new("UIStroke")
    avStroke.Color = COLORS.cyan
    avStroke.Thickness = 1.5
    avStroke.Parent = avatarFrame

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.fromScale(1, 1)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = loadCustomAvatarImage()
    avatarImg.ZIndex = 11
    avatarImg.Parent = avatarFrame

    local avImgCorner = Instance.new("UICorner")
    avImgCorner.CornerRadius = UDim.new(1, 0)
    avImgCorner.Parent = avatarImg

    local onlineDot = Instance.new("Frame")
    onlineDot.Size = UDim2.fromOffset(10, 10)
    onlineDot.Position = UDim2.new(1, -8, 1, -8)
    onlineDot.BackgroundColor3 = COLORS.success
    onlineDot.BorderSizePixel = 0
    onlineDot.ZIndex = 12
    onlineDot.Parent = avatarFrame

    local onlineCorner = Instance.new("UICorner")
    onlineCorner.CornerRadius = UDim.new(1, 0)
    onlineCorner.Parent = onlineDot

    local displayNameLabel = Instance.new("TextLabel")
    displayNameLabel.Size = UDim2.new(1, -75, 0, 18)
    displayNameLabel.Position = UDim2.new(0, 66, 0, 15)
    displayNameLabel.BackgroundTransparency = 1
    displayNameLabel.Text = LocalPlayer.DisplayName
    displayNameLabel.TextColor3 = COLORS.text
    displayNameLabel.Font = Enum.Font.GothamBold
    displayNameLabel.TextSize = 13
    displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    displayNameLabel.ZIndex = 10
    displayNameLabel.Parent = userPanel

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(1, -75, 0, 14)
    usernameLabel.Position = UDim2.new(0, 66, 0, 33)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "@" .. LocalPlayer.Name
    usernameLabel.TextColor3 = COLORS.textMuted
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextSize = 10
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.ZIndex = 10
    usernameLabel.Parent = userPanel

    local metricsBox = Instance.new("Frame")
    metricsBox.Size = UDim2.new(1, -28, 0, 24)
    metricsBox.Position = UDim2.new(0, 14, 0, 64)
    metricsBox.BackgroundColor3 = COLORS.glassDeep
    metricsBox.BorderSizePixel = 0
    metricsBox.ZIndex = 10
    metricsBox.Parent = userPanel

    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 6)
    mCorner.Parent = metricsBox

    local metricsLabel = Instance.new("TextLabel")
    metricsLabel.Size = UDim2.fromScale(1, 1)
    metricsLabel.BackgroundTransparency = 1
    metricsLabel.Text = "⏱️ 00:00  •  📡 0 ms"
    metricsLabel.TextColor3 = COLORS.cyan
    metricsLabel.Font = Enum.Font.GothamBold
    metricsLabel.TextSize = 10
    metricsLabel.ZIndex = 11
    metricsLabel.Parent = metricsBox

    task.spawn(function()
        local startTime = os.time()
        while task.wait(1) do
            if not gui or not gui.Parent then break end
            local elapsed = os.time() - startTime
            local mins = math.floor(elapsed / 60)
            local secs = elapsed % 60
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            metricsLabel.Text = string.format("⏱️ %02d:%02d  •  📡 %d ms", mins, secs, ping)
        end
    end)

    local sideDiv = Instance.new("Frame")
    sideDiv.Size = UDim2.new(1, -28, 0, 1)
    sideDiv.Position = UDim2.new(0, 14, 0, 96)
    sideDiv.BackgroundColor3 = COLORS.glassRaised
    sideDiv.BorderSizePixel = 0
    sideDiv.ZIndex = 10
    sideDiv.Parent = userPanel

    local navHeader = Instance.new("TextLabel")
    navHeader.Size = UDim2.new(1, -28, 0, 18)
    navHeader.Position = UDim2.new(0, 16, 0, 104)
    navHeader.BackgroundTransparency = 1
    navHeader.Text = "SYSTEM MODULES / หมวดหมู่"
    navHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    navHeader.Font = Enum.Font.GothamBold
    navHeader.TextSize = 11
    navHeader.TextXAlignment = Enum.TextXAlignment.Left
    navHeader.ZIndex = 10
    navHeader.Parent = userPanel

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "VerticalTabScroll"
    tabScroll.Size = UDim2.new(1, -20, 1, -178)
    tabScroll.Position = UDim2.new(0, 10, 0, 126)
    tabScroll.BackgroundTransparency = 1
    tabScroll.ScrollBarThickness = 3
    tabScroll.ScrollBarImageColor3 = COLORS.cyan
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.ZIndex = 10
    tabScroll.Parent = userPanel

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabScroll

    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabScroll.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
    end)

    local statusCard = Instance.new("Frame")
    statusCard.Size = UDim2.new(1, -24, 0, 36)
    statusCard.Position = UDim2.new(0, 12, 1, -44)
    statusCard.BackgroundColor3 = COLORS.glassDeep
    statusCard.BorderSizePixel = 0
    statusCard.ZIndex = 10
    statusCard.Parent = userPanel

    local stCorner = Instance.new("UICorner")
    stCorner.CornerRadius = UDim.new(0, 8)
    stCorner.Parent = statusCard

    local stTitle = Instance.new("TextLabel")
    stTitle.Size = UDim2.fromScale(1, 1)
    stTitle.BackgroundTransparency = 1
    stTitle.Text = "✅ Connected & Active"
    stTitle.TextColor3 = COLORS.success
    stTitle.Font = Enum.Font.GothamBold
    stTitle.TextSize = 12
    stTitle.Parent = statusCard

    -- RIGHT MAIN PANEL
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(1, -240, 1, 0)
    mainPanel.Position = UDim2.new(0, 240, 0, 0)
    mainPanel.BackgroundTransparency = 1
    mainPanel.ZIndex = 5
    mainPanel.Parent = shell

    local headerBar = Instance.new("Frame")
    headerBar.Size = UDim2.new(1, 0, 0, 48)
    headerBar.BackgroundTransparency = 1
    headerBar.Parent = mainPanel

    local mainTitle = Instance.new("TextLabel")
    mainTitle.Size = UDim2.new(0, 300, 0, 22)
    mainTitle.Position = UDim2.new(0, 20, 0, 8)
    mainTitle.BackgroundTransparency = 1
    mainTitle.Text = cfg.Title or "PayomboyZ HUB"
    mainTitle.TextColor3 = COLORS.text
    mainTitle.Font = Enum.Font.GothamBold
    mainTitle.TextSize = 18
    mainTitle.TextXAlignment = Enum.TextXAlignment.Left
    mainTitle.Parent = headerBar

    local mainSubTitle = Instance.new("TextLabel")
    mainSubTitle.Size = UDim2.new(0, 350, 0, 16)
    mainSubTitle.Position = UDim2.new(0, 20, 0, 28)
    mainSubTitle.BackgroundTransparency = 1
    mainSubTitle.Text = cfg.SubTitle or "คาปิบาร่า vs ต้นไม้"
    mainSubTitle.TextColor3 = COLORS.textMuted
    mainSubTitle.Font = Enum.Font.Gotham
    mainSubTitle.TextSize = 11
    mainSubTitle.TextXAlignment = Enum.TextXAlignment.Left
    mainSubTitle.Parent = headerBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(28, 28)
    closeBtn.Position = UDim2.new(1, -38, 0, 10)
    closeBtn.BackgroundColor3 = COLORS.glass
    closeBtn.BackgroundTransparency = 0.20
    closeBtn.Text = "X"
    closeBtn.TextColor3 = COLORS.textMuted
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = headerBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        playClickSound()
        shell.Visible = not shell.Visible
    end)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(28, 28)
    minBtn.Position = UDim2.new(1, -72, 0, 10)
    minBtn.BackgroundColor3 = COLORS.glass
    minBtn.BackgroundTransparency = 0.20
    minBtn.Text = "─"
    minBtn.TextColor3 = COLORS.textMuted
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 13
    minBtn.Parent = headerBar

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minBtn

    minBtn.MouseButton1Click:Connect(function()
        playClickSound()
        shell.Visible = not shell.Visible
    end)

    local dragging, dragInput, dragStart, startPos
    headerBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = shell.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    headerBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            shell.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local serviceBanner = Instance.new("Frame")
    serviceBanner.Size = UDim2.new(1, -40, 0, 65)
    serviceBanner.Position = UDim2.new(0, 20, 0, 48)
    serviceBanner.BackgroundColor3 = COLORS.glassDeep
    serviceBanner.BackgroundTransparency = 0.18
    serviceBanner.BorderSizePixel = 0
    serviceBanner.Parent = mainPanel

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 10)
    sCorner.Parent = serviceBanner

    local sStroke = Instance.new("UIStroke")
    sStroke.Color = COLORS.glassRaised
    sStroke.Thickness = 1
    sStroke.Parent = serviceBanner

    local sBadge = Instance.new("TextLabel")
    sBadge.Size = UDim2.new(0, 120, 0, 16)
    sBadge.Position = UDim2.new(0, 14, 0, 10)
    sBadge.BackgroundTransparency = 1
    sBadge.Text = "ACTIVE SERVICE"
    sBadge.TextColor3 = COLORS.success
    sBadge.Font = Enum.Font.GothamBold
    sBadge.TextSize = 10
    sBadge.TextXAlignment = Enum.TextXAlignment.Left
    sBadge.Parent = serviceBanner

    local sTitle = Instance.new("TextLabel")
    sTitle.Size = UDim2.new(0, 250, 0, 20)
    sTitle.Position = UDim2.new(0, 14, 0, 26)
    sTitle.BackgroundTransparency = 1
    sTitle.Text = cfg.Title or "PayomboyZ HUB"
    sTitle.TextColor3 = COLORS.text
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextSize = 14
    sTitle.TextXAlignment = Enum.TextXAlignment.Left
    sTitle.Parent = serviceBanner

    local sSub = Instance.new("TextLabel")
    sSub.Size = UDim2.new(0, 250, 0, 14)
    sSub.Position = UDim2.new(0, 14, 0, 44)
    sSub.BackgroundTransparency = 1
    sSub.Text = "Verified client delivery • Premium Automation"
    sSub.TextColor3 = COLORS.textMuted
    sSub.Font = Enum.Font.Gotham
    sSub.TextSize = 10
    sSub.TextXAlignment = Enum.TextXAlignment.Left
    sSub.Parent = serviceBanner

    local vBadge = Instance.new("Frame")
    vBadge.Size = UDim2.fromOffset(150, 32)
    vBadge.Position = UDim2.new(1, -160, 0.5, -16)
    vBadge.BackgroundColor3 = COLORS.userPanel
    vBadge.BackgroundTransparency = 0.20
    vBadge.BorderSizePixel = 0
    vBadge.Parent = serviceBanner

    local vCorner = Instance.new("UICorner")
    vCorner.CornerRadius = UDim.new(0, 8)
    vCorner.Parent = vBadge

    local vStroke = Instance.new("UIStroke")
    vStroke.Color = COLORS.success
    vStroke.Thickness = 1
    vStroke.Parent = vBadge

    local vText = Instance.new("TextLabel")
    vText.Size = UDim2.fromScale(1, 1)
    vText.BackgroundTransparency = 1
    vText.Text = "🛡️ SYSTEM VERIFIED"
    vText.TextColor3 = COLORS.success
    vText.Font = Enum.Font.GothamBold
    vText.TextSize = 10
    vText.Parent = vBadge

    local pagesFolder = Instance.new("Frame")
    pagesFolder.Name = "PagesFolder"
    pagesFolder.Size = UDim2.new(1, -40, 1, -128)
    pagesFolder.Position = UDim2.new(0, 20, 0, 120)
    pagesFolder.BackgroundTransparency = 1
    pagesFolder.Parent = mainPanel

    local WindowObj = { Tabs = {}, CurrentTab = nil }

    function WindowObj:AddTab(tabCfg)
        local tabTitle = tabCfg.Title or "Tab"
        local tabIndex = #WindowObj.Tabs + 1

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -6, 0, 40)
        tabBtn.Position = UDim2.new(0, 3, 0, 0)
        tabBtn.BackgroundColor3 = (tabIndex == 1) and COLORS.primary or Color3.fromRGB(38, 16, 24)
        tabBtn.BackgroundTransparency = (tabIndex == 1) and 0.15 or 0.22
        tabBtn.Text = "    " .. tabTitle
        tabBtn.TextColor3 = (tabIndex == 1) and Color3.fromRGB(255, 255, 255) or COLORS.textMuted
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 14
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 12
        tabBtn.Parent = tabScroll

        local tbCorner = Instance.new("UICorner")
        tbCorner.CornerRadius = UDim.new(0, 8)
        tbCorner.Parent = tabBtn

        local tbStroke = Instance.new("UIStroke")
        tbStroke.Color = (tabIndex == 1) and COLORS.primary or Color3.fromRGB(70, 30, 45)
        tbStroke.Thickness = 1
        tbStroke.Transparency = (tabIndex == 1) and 0 or 0.3
        tbStroke.Parent = tabBtn

        local activeIndicator = Instance.new("Frame")
        activeIndicator.Size = UDim2.new(0, 4, 0, 20)
        activeIndicator.Position = UDim2.new(0, 4, 0.5, -10)
        activeIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        activeIndicator.BorderSizePixel = 0
        activeIndicator.Visible = (tabIndex == 1)
        activeIndicator.Parent = tabBtn

        local indCorner = Instance.new("UICorner")
        indCorner.CornerRadius = UDim.new(1, 0)
        indCorner.Parent = activeIndicator

        local pageScroll = Instance.new("ScrollingFrame")
        pageScroll.Name = "Page_" .. tabTitle
        pageScroll.Size = UDim2.fromScale(1, 1)
        pageScroll.BackgroundTransparency = 1
        pageScroll.ScrollBarThickness = 4
        pageScroll.ScrollBarImageColor3 = COLORS.primary
        pageScroll.Visible = (tabIndex == 1)
        pageScroll.Parent = pagesFolder

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = pageScroll

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
        end)

        local function activateTab()
            playClickSound()
            for _, t in ipairs(WindowObj.Tabs) do
                t.btn.BackgroundColor3 = Color3.fromRGB(38, 16, 24)
                t.btn.BackgroundTransparency = 0.22
                t.btn.TextColor3 = COLORS.textMuted
                t.stroke.Color = Color3.fromRGB(70, 30, 45)
                t.stroke.Transparency = 0.3
                if t.indicator then t.indicator.Visible = false end
                t.page.Visible = false
            end
            tabBtn.BackgroundColor3 = COLORS.primary
            tabBtn.BackgroundTransparency = 0.15
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tbStroke.Color = COLORS.primary
            tbStroke.Transparency = 0
            activeIndicator.Visible = true
            pageScroll.Visible = true
        end

        tabBtn.MouseButton1Click:Connect(activateTab)

        local TabObj = {
            btn = tabBtn,
            stroke = tbStroke,
            indicator = activeIndicator,
            page = pageScroll,
            Select = activateTab
        }

        -- TOGGLE WIDGET
        function TabObj:AddToggle(id, tCfg)
            local title = tCfg.Title or id
            local desc = tCfg.Desc or tCfg.Description or ""
            local defaultVal = (tCfg.Default ~= nil) and tCfg.Default or false

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, desc ~= "" and 55 or 44)
            frame.BackgroundColor3 = COLORS.glassDeep
            frame.BackgroundTransparency = 0.18
            frame.BorderSizePixel = 0
            frame.Parent = pageScroll

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 8)
            fCorner.Parent = frame

            local fStroke = Instance.new("UIStroke")
            fStroke.Color = COLORS.surface
            fStroke.Thickness = 1
            fStroke.Parent = frame

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -70, 0, 22)
            lbl.Position = UDim2.new(0, 12, 0, desc ~= "" and 8 or 11)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = COLORS.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            if desc ~= "" then
                local dLbl = Instance.new("TextLabel")
                dLbl.Size = UDim2.new(1, -70, 0, 18)
                dLbl.Position = UDim2.new(0, 12, 0, 30)
                dLbl.BackgroundTransparency = 1
                dLbl.Text = desc
                dLbl.TextColor3 = COLORS.textMuted
                dLbl.Font = Enum.Font.Gotham
                dLbl.TextSize = 11
                dLbl.TextXAlignment = Enum.TextXAlignment.Left
                dLbl.Parent = frame
            end

            local switch = Instance.new("TextButton")
            switch.Size = UDim2.fromOffset(46, 24)
            switch.Position = UDim2.new(1, -56, 0.5, -12)
            switch.BackgroundColor3 = defaultVal and COLORS.cyan or COLORS.surface
            switch.Text = ""
            switch.Parent = frame

            local swCorner = Instance.new("UICorner")
            swCorner.CornerRadius = UDim.new(1, 0)
            swCorner.Parent = switch

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(20, 20)
            knob.Position = defaultVal and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            knob.BackgroundColor3 = COLORS.text
            knob.BorderSizePixel = 0
            knob.Parent = switch

            local kCorner = Instance.new("UICorner")
            kCorner.CornerRadius = UDim.new(1, 0)
            kCorner.Parent = knob

            local OptionObj = {
                Value = defaultVal,
                Callback = tCfg.Callback or function() end,
                ChangedCallbacks = {}
            }

            local function updateToggle(val)
                playClickSound()
                OptionObj.Value = val
                switch.BackgroundColor3 = val and COLORS.cyan or COLORS.surface
                knob.Position = val and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                pcall(function() OptionObj.Callback(val) end)
                for _, cb in ipairs(OptionObj.ChangedCallbacks) do pcall(function() cb(val) end) end
            end

            function OptionObj:OnChanged(cb) table.insert(OptionObj.ChangedCallbacks, cb) end
            function OptionObj:SetValue(val) updateToggle(val == true) end

            switch.MouseButton1Click:Connect(function() updateToggle(not OptionObj.Value) end)
            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        -- SLIDER WIDGET
        function TabObj:AddSlider(id, sCfg)
            local title = sCfg.Title or id
            local minVal = sCfg.Min or 0
            local maxVal = sCfg.Max or 100
            local defaultVal = sCfg.Default or minVal

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 52)
            frame.BackgroundColor3 = COLORS.glassDeep
            frame.BackgroundTransparency = 0.18
            frame.BorderSizePixel = 0
            frame.Parent = pageScroll

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 8)
            fCorner.Parent = frame

            local fStroke = Instance.new("UIStroke")
            fStroke.Color = COLORS.surface
            fStroke.Thickness = 1
            fStroke.Parent = frame

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.7, 0, 0, 22)
            lbl.Position = UDim2.new(0, 12, 0, 6)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = COLORS.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0.3, -12, 0, 22)
            valLbl.Position = UDim2.new(0.7, 0, 0, 6)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(defaultVal)
            valLbl.TextColor3 = COLORS.cyan
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 14
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = frame

            local bar = Instance.new("TextButton")
            bar.Size = UDim2.new(1, -24, 0, 8)
            bar.Position = UDim2.new(0, 12, 0, 34)
            bar.BackgroundColor3 = COLORS.surface
            bar.Text = ""
            bar.Parent = frame

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(1, 0)
            bCorner.Parent = bar

            local fill = Instance.new("Frame")
            local pct = (defaultVal - minVal) / math.max(maxVal - minVal, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            fill.BackgroundColor3 = COLORS.cyan
            fill.BorderSizePixel = 0
            fill.Parent = bar

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill

            local OptionObj = {
                Value = defaultVal,
                Callback = sCfg.Callback or function() end,
                ChangedCallbacks = {}
            }

            local function updateSlider(val)
                val = math.clamp(val, minVal, maxVal)
                if sCfg.Rounding then val = math.floor(val * (10 ^ sCfg.Rounding) + 0.5) / (10 ^ sCfg.Rounding) else val = math.floor(val + 0.5) end
                OptionObj.Value = val
                valLbl.Text = tostring(val)
                local newPct = (val - minVal) / math.max(maxVal - minVal, 1)
                fill.Size = UDim2.new(newPct, 0, 1, 0)
                pcall(function() OptionObj.Callback(val) end)
                for _, cb in ipairs(OptionObj.ChangedCallbacks) do pcall(function() cb(val) end) end
            end

            function OptionObj:OnChanged(cb) table.insert(OptionObj.ChangedCallbacks, cb) end
            function OptionObj:SetValue(val) updateSlider(val) end

            local isDragging = false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    local relX = input.Position.X - bar.AbsolutePosition.X
                    updateSlider(minVal + (relX / bar.AbsoluteSize.X) * (maxVal - minVal))
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local relX = input.Position.X - bar.AbsolutePosition.X
                    updateSlider(minVal + (relX / bar.AbsoluteSize.X) * (maxVal - minVal))
                end
            end)

            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        -- DROPDOWN WIDGET WITH POPUP OVERLAY & DYNAMIC SETVALUES
        function TabObj:AddDropdown(id, dCfg)
            local title = dCfg.Title or id
            local values = dCfg.Values or {}
            local defaultVal = dCfg.Value or dCfg.Default or (values[1] or "")
            if type(defaultVal) == "number" then defaultVal = values[defaultVal] or "" end
            local isMulti = dCfg.Multi == true

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 52)
            frame.BackgroundColor3 = COLORS.glassDeep
            frame.BackgroundTransparency = 0.18
            frame.BorderSizePixel = 0
            frame.Parent = pageScroll

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 8)
            fCorner.Parent = frame

            local fStroke = Instance.new("UIStroke")
            fStroke.Color = COLORS.surfaceRaised
            fStroke.Thickness = 1
            fStroke.Parent = frame

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.5, 0, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = COLORS.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            local dBtn = Instance.new("TextButton")
            dBtn.Size = UDim2.new(0.46, 0, 0, 34)
            dBtn.Position = UDim2.new(0.52, 0, 0.5, -17)
            dBtn.BackgroundColor3 = COLORS.surface
            dBtn.BackgroundTransparency = 0.20

            local function formatValText(val)
                if type(val) == "table" then
                    if #val == 0 then return "[ กดเพื่อเลือกรายการ ]" end
                    return table.concat(val, ", ")
                end
                return tostring(val)
            end

            dBtn.Text = formatValText(defaultVal)
            dBtn.TextColor3 = COLORS.text
            dBtn.Font = Enum.Font.GothamBold
            dBtn.TextSize = 13
            dBtn.TextTruncate = Enum.TextTruncate.AtEnd
            dBtn.Parent = frame

            local dbCorner = Instance.new("UICorner")
            dbCorner.CornerRadius = UDim.new(0, 6)
            dbCorner.Parent = dBtn

            local dbStroke = Instance.new("UIStroke")
            dbStroke.Color = COLORS.cyan
            dbStroke.Thickness = 1
            dbStroke.Transparency = 0.4
            dbStroke.Parent = dBtn

            local OptionObj = {
                Value = defaultVal,
                Values = values,
                Callback = dCfg.Callback or function() end,
                ChangedCallbacks = {}
            }

            local function updateDropdown(val)
                OptionObj.Value = val
                dBtn.Text = formatValText(val)
                pcall(function() OptionObj.Callback(val) end)
                for _, cb in ipairs(OptionObj.ChangedCallbacks) do pcall(function() cb(val) end) end
            end

            function OptionObj:OnChanged(cb) table.insert(OptionObj.ChangedCallbacks, cb) end
            function OptionObj:SetValue(val) updateDropdown(val) end
            function OptionObj:SetValues(newVals)
                OptionObj.Values = newVals
                -- Refresh default selection if current value is invalid
                if type(newVals) == "table" and #newVals > 0 then
                    if type(OptionObj.Value) == "string" and not table.find(newVals, OptionObj.Value) then
                        updateDropdown(newVals[1])
                    end
                end
            end

            dBtn.MouseButton1Click:Connect(function()
                playClickSound()
                local gui = shell.Parent
                if not gui then return end

                local existingModal = gui:FindFirstChild("DropdownModalOverlay")
                if existingModal then
                    local isSameDropdown = (existingModal:GetAttribute("DropdownId") == id)
                    existingModal:Destroy()
                    if isSameDropdown then
                        return
                    end
                end

                local modalOverlay = Instance.new("Frame")
                modalOverlay.Name = "DropdownModalOverlay"
                modalOverlay:SetAttribute("DropdownId", id)
                modalOverlay.Size = UDim2.fromScale(1, 1)
                modalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                modalOverlay.BackgroundTransparency = 0.55
                modalOverlay.ZIndex = 999999
                modalOverlay.Parent = gui

                local bgDismissBtn = Instance.new("TextButton")
                bgDismissBtn.Size = UDim2.fromScale(1, 1)
                bgDismissBtn.BackgroundTransparency = 1
                bgDismissBtn.Text = ""
                bgDismissBtn.ZIndex = 999999
                bgDismissBtn.Parent = modalOverlay

                local modalFrame = Instance.new("Frame")
                modalFrame.Size = UDim2.fromOffset(380, 440)
                modalFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                modalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                modalFrame.BackgroundColor3 = COLORS.shell
                modalFrame.BackgroundTransparency = 0.15
                modalFrame.BorderSizePixel = 0
                modalFrame.ZIndex = 1000000
                modalFrame.Parent = modalOverlay

                local mCorner = Instance.new("UICorner")
                mCorner.CornerRadius = UDim.new(0, 14)
                mCorner.Parent = modalFrame

                local mStroke = Instance.new("UIStroke")
                mStroke.Color = COLORS.primary
                mStroke.Thickness = 2
                mStroke.Parent = modalFrame

                local mHeader = Instance.new("TextLabel")
                mHeader.Size = UDim2.new(1, -50, 0, 24)
                mHeader.Position = UDim2.new(0, 16, 0, 14)
                mHeader.BackgroundTransparency = 1
                mHeader.Text = "📌 " .. title
                mHeader.TextColor3 = COLORS.text
                mHeader.Font = Enum.Font.GothamBold
                mHeader.TextSize = 15
                mHeader.TextXAlignment = Enum.TextXAlignment.Left
                mHeader.ZIndex = 1000001
                mHeader.Parent = modalFrame

                local mSub = Instance.new("TextLabel")
                mSub.Size = UDim2.new(1, -50, 0, 18)
                mSub.Position = UDim2.new(0, 16, 0, 38)
                mSub.BackgroundTransparency = 1
                mSub.Text = isMulti and "คำแนะนำ: คลิกเลือก/ยกเลิกได้หลายรายการ" or "คำแนะนำ: คลิก 1 รายการเพื่อเลือก"
                mSub.TextColor3 = COLORS.textMuted
                mSub.Font = Enum.Font.Gotham
                mSub.TextSize = 11
                mSub.TextXAlignment = Enum.TextXAlignment.Left
                mSub.ZIndex = 1000001
                mSub.Parent = modalFrame

                local closeModBtn = Instance.new("TextButton")
                closeModBtn.Size = UDim2.fromOffset(26, 26)
                closeModBtn.Position = UDim2.new(1, -36, 0, 14)
                closeModBtn.BackgroundColor3 = COLORS.glass
                closeModBtn.Text = "✕"
                closeModBtn.TextColor3 = COLORS.textMuted
                closeModBtn.Font = Enum.Font.GothamBold
                closeModBtn.TextSize = 13
                closeModBtn.ZIndex = 1000002
                closeModBtn.Parent = modalFrame

                local cmCorner = Instance.new("UICorner")
                cmCorner.CornerRadius = UDim.new(0, 6)
                cmCorner.Parent = closeModBtn

                closeModBtn.MouseButton1Click:Connect(function()
                    playClickSound()
                    modalOverlay:Destroy()
                end)

                bgDismissBtn.MouseButton1Click:Connect(function() modalOverlay:Destroy() end)

                local optScroll = Instance.new("ScrollingFrame")
                optScroll.Size = UDim2.new(1, -28, 1, -124)
                optScroll.Position = UDim2.new(0, 14, 0, 64)
                optScroll.BackgroundTransparency = 1
                optScroll.ScrollBarThickness = 4
                optScroll.ScrollBarImageColor3 = COLORS.primary
                optScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                optScroll.ZIndex = 1000001
                optScroll.Parent = modalFrame

                local optLayout = Instance.new("UIListLayout")
                optLayout.Padding = UDim.new(0, 5)
                optLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optLayout.Parent = optScroll

                optLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    optScroll.CanvasSize = UDim2.new(0, 0, 0, optLayout.AbsoluteContentSize.Y + 10)
                end)

                local currentSelected = {}
                if isMulti then
                    if type(OptionObj.Value) == "table" then
                        for _, v in ipairs(OptionObj.Value) do table.insert(currentSelected, v) end
                    end
                else
                    table.insert(currentSelected, OptionObj.Value)
                end

                local optionButtons = {}
                local function renderOptions()
                    for _, btnObj in ipairs(optionButtons) do btnObj:Destroy() end
                    optionButtons = {}

                    local currentValues = (type(OptionObj.Values) == "function" and OptionObj.Values()) or OptionObj.Values or values
                    if type(currentValues) ~= "table" then currentValues = {} end

                    for _, optVal in ipairs(currentValues) do
                        local isSelected = isMulti and (table.find(currentSelected, optVal) ~= nil) or (currentSelected[1] == optVal)

                        local itemBtn = Instance.new("TextButton")
                        itemBtn.Size = UDim2.new(1, -6, 0, 38)
                        itemBtn.BackgroundColor3 = isSelected and COLORS.primary or COLORS.glassDeep
                        itemBtn.BackgroundTransparency = isSelected and 0.1 or 0.2
                        itemBtn.Text = (isSelected and "   ✓  " or "       ") .. tostring(optVal)
                        itemBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or COLORS.text
                        itemBtn.Font = Enum.Font.GothamBold
                        itemBtn.TextSize = 13
                        itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                        itemBtn.ZIndex = 1000002
                        itemBtn.Parent = optScroll

                        local ibCorner = Instance.new("UICorner")
                        ibCorner.CornerRadius = UDim.new(0, 8)
                        ibCorner.Parent = itemBtn

                        local ibStroke = Instance.new("UIStroke")
                        ibStroke.Color = isSelected and COLORS.primary or COLORS.surfaceRaised
                        ibStroke.Thickness = 1
                        ibStroke.Parent = itemBtn

                        itemBtn.MouseButton1Click:Connect(function()
                            playClickSound()
                            if isMulti then
                                local foundIdx = table.find(currentSelected, optVal)
                                if foundIdx then table.remove(currentSelected, foundIdx) else table.insert(currentSelected, optVal) end
                                updateDropdown(currentSelected)
                                renderOptions()
                            else
                                currentSelected = { optVal }
                                updateDropdown(optVal)
                                modalOverlay:Destroy()
                            end
                        end)

                        table.insert(optionButtons, itemBtn)
                    end
                end

                renderOptions()

                local confirmBtn = Instance.new("TextButton")
                confirmBtn.Size = UDim2.new(1, -28, 0, 40)
                confirmBtn.Position = UDim2.new(0, 14, 1, -50)
                confirmBtn.BackgroundColor3 = COLORS.primary
                confirmBtn.BackgroundTransparency = 0.15
                confirmBtn.Text = "✓ ตกลง / ยืนยันการเลือก (Confirm)"
                confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                confirmBtn.Font = Enum.Font.GothamBold
                confirmBtn.TextSize = 13
                confirmBtn.ZIndex = 10001
                confirmBtn.Parent = modalFrame

                local cfCorner = Instance.new("UICorner")
                cfCorner.CornerRadius = UDim.new(0, 8)
                cfCorner.Parent = confirmBtn

                confirmBtn.MouseButton1Click:Connect(function()
                    playClickSound()
                    if isMulti then updateDropdown(currentSelected) end
                    modalOverlay:Destroy()
                end)
            end)

            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        -- BUTTON WIDGET
        function TabObj:AddButton(bCfg)
            local title = bCfg.Title or bCfg.Text or "Button"
            local cb = bCfg.Callback or function() end

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 40)
            btn.BackgroundColor3 = COLORS.surfaceRaised
            btn.BackgroundTransparency = 0.18
            btn.Text = title
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.Parent = pageScroll

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 8)
            bCorner.Parent = btn

            local bStroke = Instance.new("UIStroke")
            bStroke.Color = COLORS.primary
            bStroke.Thickness = 1
            bStroke.Parent = btn

            btn.MouseButton1Click:Connect(function()
                playClickSound()
                pcall(cb)
            end)
            return btn
        end

        -- INPUT WIDGET
        function TabObj:AddInput(id, iCfg)
            local title = iCfg.Title or id
            local defaultVal = iCfg.Default or ""

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 48)
            frame.BackgroundColor3 = COLORS.glassDeep
            frame.BackgroundTransparency = 0.18
            frame.BorderSizePixel = 0
            frame.Parent = pageScroll

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 8)
            fCorner.Parent = frame

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.5, 0, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = COLORS.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(0.45, 0, 0, 30)
            box.Position = UDim2.new(0.52, 0, 0.5, -15)
            box.BackgroundColor3 = COLORS.input
            box.BackgroundTransparency = 0.20
            box.Text = tostring(defaultVal)
            box.TextColor3 = COLORS.cyan
            box.Font = Enum.Font.Gotham
            box.TextSize = 13
            box.Parent = frame

            local bxCorner = Instance.new("UICorner")
            bxCorner.CornerRadius = UDim.new(0, 6)
            bxCorner.Parent = box

            local OptionObj = {
                Value = defaultVal,
                Callback = iCfg.Callback or function() end,
                ChangedCallbacks = {}
            }

            box.FocusLost:Connect(function()
                OptionObj.Value = box.Text
                pcall(function() OptionObj.Callback(box.Text) end)
                for _, cb in ipairs(OptionObj.ChangedCallbacks) do pcall(function() cb(box.Text) end) end
            end)

            function OptionObj:OnChanged(cb) table.insert(OptionObj.ChangedCallbacks, cb) end
            function OptionObj:SetValue(val) box.Text = tostring(val); OptionObj.Value = tostring(val) end

            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        -- SECTION HEADER WIDGET
        function TabObj:AddSection(title)
            local sec = Instance.new("TextLabel")
            sec.Size = UDim2.new(1, -10, 0, 30)
            sec.BackgroundTransparency = 1
            sec.Text = "──  " .. title .. "  ──"
            sec.TextColor3 = COLORS.cyan
            sec.Font = Enum.Font.GothamBold
            sec.TextSize = 14
            sec.Parent = pageScroll
            return sec
        end

        -- PARAGRAPH WIDGET
        function TabObj:AddParagraph(pCfg)
            local title = pCfg.Title or ""
            local desc = pCfg.Desc or pCfg.Content or ""

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 54)
            frame.BackgroundColor3 = COLORS.glassDeep
            frame.BackgroundTransparency = 0.18
            frame.BorderSizePixel = 0
            frame.Parent = pageScroll

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 8)
            fCorner.Parent = frame

            local pTitle = Instance.new("TextLabel")
            pTitle.Size = UDim2.new(1, -20, 0, 22)
            pTitle.Position = UDim2.new(0, 10, 0, 6)
            pTitle.BackgroundTransparency = 1
            pTitle.Text = title
            pTitle.TextColor3 = COLORS.text
            pTitle.Font = Enum.Font.GothamBold
            pTitle.TextSize = 13
            pTitle.TextXAlignment = Enum.TextXAlignment.Left
            pTitle.Parent = frame

            local pDesc = Instance.new("TextLabel")
            pDesc.Size = UDim2.new(1, -20, 0, 24)
            pDesc.Position = UDim2.new(0, 10, 0, 26)
            pDesc.BackgroundTransparency = 1
            pDesc.Text = desc
            pDesc.TextColor3 = COLORS.textMuted
            pDesc.Font = Enum.Font.Gotham
            pDesc.TextSize = 11
            pDesc.TextWrapped = true
            pDesc.TextXAlignment = Enum.TextXAlignment.Left
            pDesc.Parent = frame
            return frame
        end

        table.insert(WindowObj.Tabs, TabObj)
        return TabObj
    end

    function WindowObj:SelectTab(idx)
        if WindowObj.Tabs[idx] then
            WindowObj.Tabs[idx]:Select()
        end
    end

    return WindowObj
end

-------------------------------------------------------------------------
-- INITIALIZE WINDOW & TABS
-------------------------------------------------------------------------
local Window = ObsidianGlassEngine:CreateWindow({
    Title = "PayomboyZ HUB",
    SubTitle = "คาปิบาร่า vs ต้นไม้"
})

-------------------------------------------------------------------------
-- 1. SHOP TAB (ร้านค้า & การวางไข่)
-------------------------------------------------------------------------
local shopTab = Window:AddTab({ Title = "ร้านค้า (Shop)" })

local eggNamesList = {}
if shopDataModule and shopDataModule.ShopOrders and shopDataModule.ShopOrders.EggShop then
    for _, eggName in ipairs(shopDataModule.ShopOrders.EggShop) do
        table.insert(eggNamesList, eggName)
    end
end

local selectedEgg = eggNamesList[1] or ""
local eggDropdown = shopTab:AddDropdown("SelectEgg", {
    Title = "เลือกไข่คาปิบาร่า (Egg Level/Tier)",
    Description = "เลือกไข่ที่ต้องการให้บอทซื้อและวางอัตโนมัติ",
    Values = eggNamesList,
    Default = 1,
})
local lastEggStockCheck = 0
local cachedEggStock = 0

eggDropdown:OnChanged(function(Value)
    selectedEgg = Value
    lastEggStockCheck = 0
end)

-- AUTO BUY EGG
getgenv().autoBuyEggsEnabled = false
local buyEggToggle = shopTab:AddToggle("AutoBuyEgg", {
    Title = "เปิดออโต้ซื้อไข่ (Auto Buy Egg)",
    Description = "บอทจะทำการซื้อไข่ที่เลือกไว้อัตโนมัติ",
    Default = false
})
buyEggToggle:OnChanged(function(Value)
    getgenv().autoBuyEggsEnabled = Value
end)

-- AUTO PLACE EGG (ออโต้วางไข่)
getgenv().autoPlaceEggsEnabled = false
local placeEggToggle = shopTab:AddToggle("AutoPlaceEgg", {
    Title = "เปิดออโต้วางไข่ (Auto Place Egg)",
    Description = "วางไข่ที่เลือกจาก Auto Buy ลงในแมพ/แปลงเพาะอัตโนมัติ",
    Default = false
})
placeEggToggle:OnChanged(function(Value)
    getgenv().autoPlaceEggsEnabled = Value
end)

-- REFRESH DROPDOWNS BUTTON (ปุ่มรีเฟรชรายการตัวละคร/ไข่ใหม่)
shopTab:AddButton({
    Title = "🔄 รีเฟรชรายการตัวละคร/ไข่ใหม่ (Refresh Dropdowns)",
    Callback = function()
        pcall(function()
            local updated = false
            
            -- Refresh Egg List
            if shopDataModule and shopDataModule.ShopOrders and shopDataModule.ShopOrders.EggShop then
                local newEggList = {}
                for _, eggName in ipairs(shopDataModule.ShopOrders.EggShop) do
                    table.insert(newEggList, eggName)
                end
                eggDropdown:SetValues(newEggList)
                updated = true
            end

            -- Refresh Gear List
            if shopDataModule and shopDataModule.ShopOrders and shopDataModule.ShopOrders.GearShop then
                local newGearList = {}
                for _, gearName in ipairs(shopDataModule.ShopOrders.GearShop) do
                    table.insert(newGearList, gearName)
                end
                if ObsidianGlassEngine.Options["SelectGear"] then
                    ObsidianGlassEngine.Options["SelectGear"]:SetValues(newGearList)
                end
            end

            if updated then
                ObsidianGlassEngine:Notify({ Title = "ระบบ Auto-Update", Content = "อัปเดตรายการตัวละคร/ไข่ใหม่ใน Dropdown เรียบร้อยแล้ว! 🚀", Duration = 3 })
            end
        end)
    end
})

-- GEAR SHOP
shopTab:AddParagraph({
    Title = "ระบบอุปกรณ์ (Gears)",
    Content = "หมวดหมู่การซื้ออุปกรณ์อัตโนมัติ"
})

local gearNamesList = {}
if shopDataModule and shopDataModule.ShopOrders and shopDataModule.ShopOrders.GearShop then
    for _, gearName in ipairs(shopDataModule.ShopOrders.GearShop) do
        table.insert(gearNamesList, gearName)
    end
end

local selectedGear = gearNamesList[1] or ""
local gearDropdown = shopTab:AddDropdown("SelectGear", {
    Title = "เลือกอุปกรณ์",
    Description = "เลือกอุปกรณ์ที่ต้องการให้บอทซื้อ",
    Values = gearNamesList,
    Default = 1,
})
local lastGearStockCheck = 0
local cachedGearStock = 0

gearDropdown:OnChanged(function(Value)
    selectedGear = Value
    lastGearStockCheck = 0
end)

getgenv().autoBuyGearsEnabled = false
local buyGearToggle = shopTab:AddToggle("AutoBuyGear", {
    Title = "เปิดออโต้ซื้ออุปกรณ์",
    Description = "บอทจะทำการซื้ออุปกรณ์ที่เลือกไว้อัตโนมัติ",
    Default = false
})
buyGearToggle:OnChanged(function(Value)
    getgenv().autoBuyGearsEnabled = Value
end)

-- TRAVELING MERCHANT
shopTab:AddParagraph({
    Title = "พ่อค้าเร่ (Traveling Merchant)",
    Content = "หมวดหมู่การซื้อของจากพ่อค้าเร่"
})

local merchantItemsList = {}
if shopDataModule and shopDataModule.TravelingMerchantPool then
    for _, merchantType in ipairs(shopDataModule.TravelingMerchantPool) do
        if shopDataModule.ShopOrders and shopDataModule.ShopOrders[merchantType] then
            for _, itemName in ipairs(shopDataModule.ShopOrders[merchantType]) do
                table.insert(merchantItemsList, itemName)
            end
        end
    end
end

local selectedMerchant = merchantItemsList[1] or ""
local merchantDropdown = shopTab:AddDropdown("SelectMerchant", {
    Title = "เลือกของพ่อค้าเร่",
    Description = "เลือกไอเทมจากพ่อค้าที่ต้องการซื้อ",
    Values = merchantItemsList,
    Default = 1,
})
local lastMerchantStockCheck = 0
local cachedMerchantStock = 0

merchantDropdown:OnChanged(function(Value)
    selectedMerchant = Value
    lastMerchantStockCheck = 0
end)

getgenv().autoBuyMerchantEnabled = false
local buyMerchantToggle = shopTab:AddToggle("AutoBuyMerchant", {
    Title = "เปิดออโต้ซื้อของพ่อค้าเร่",
    Description = "บอทจะทำการซื้อของพ่อค้าเร่อัตโนมัติ",
    Default = false
})
buyMerchantToggle:OnChanged(function(Value)
    getgenv().autoBuyMerchantEnabled = Value
end)

-------------------------------------------------------------------------
-- 2. AUTO TAB (ฟาร์ม)
-------------------------------------------------------------------------
local autoTab = Window:AddTab({ Title = "ฟาร์ม (Auto)" })

getgenv().autoHatchEnabled = false
local hatchToggle = autoTab:AddToggle("AutoHatch", {
    Title = "ออโต้ฟักไข่ (Auto Hatch)",
    Description = "ฟักไข่ทั้งหมดที่พร้อมฟักแล้วแบบอัตโนมัติ",
    Default = false
})
hatchToggle:OnChanged(function(Value)
    getgenv().autoHatchEnabled = Value
end)

getgenv().autoEquipBestEnabled = false
local equipToggle = autoTab:AddToggle("AutoEquip", {
    Title = "ออโต้ใส่ตัวดีสุด (Auto Equip Best)",
    Description = "ระบบจะคำนวณและสวมใส่ตัวละครที่ดีที่สุดให้",
    Default = false
})
equipToggle:OnChanged(function(Value)
    getgenv().autoEquipBestEnabled = Value
end)

-------------------------------------------------------------------------
-- 3. BOSS TAB (บอส)
-------------------------------------------------------------------------
local bossTab = Window:AddTab({ Title = "บอส (Boss)" })

local bossNamesList = {}
if bossDataModule and bossDataModule.BossList then
    for _, bossName in ipairs(bossDataModule.BossList) do
        table.insert(bossNamesList, bossName)
    end
end

local selectedBoss = bossNamesList[1] or ""
local bossDropdown = bossTab:AddDropdown("SelectBoss", {
    Title = "เลือกบอส",
    Description = "เลือกบอสที่ต้องการให้บอทเรียกออกมา",
    Values = bossNamesList,
    Default = 1,
})
bossDropdown:OnChanged(function(Value)
    selectedBoss = Value
end)

local spawnInterval = 60
local bossSlider = bossTab:AddSlider("BossSlider", {
    Title = "ความถี่ในการเรียกบอส (วินาที)",
    Description = "ระยะห่างในการเรียกบอสแต่ละรอบ",
    Default = 60,
    Min = 1,
    Max = 300,
    Rounding = 0,
})
bossSlider:OnChanged(function(Value)
    spawnInterval = Value
end)

getgenv().autoSpawnBossEnabled = false
local bossToggle = bossTab:AddToggle("AutoBoss", {
    Title = "ออโต้เรียกบอส (Auto Spawn Boss)",
    Description = "ระบบจะทำการเรียกบอสที่เลือกไว้อัตโนมัติ",
    Default = false
})
bossToggle:OnChanged(function(Value)
    getgenv().autoSpawnBossEnabled = Value
end)

-------------------------------------------------------------------------
-- 4. SELL TAB (ขาย)
-------------------------------------------------------------------------
local sellTab = Window:AddTab({ Title = "ขาย (Sell)" })

sellTab:AddParagraph({
    Title = "ระบบขายอัตโนมัติ",
    Content = "จะทำการขายต้นไม้/พืชทั้งหมดแบบ Bulk Sell"
})

getgenv().autoSellAllEnabled = false
local sellToggle = sellTab:AddToggle("AutoSell", {
    Title = "ออโต้ขายทั้งหมด (Auto Sell All)",
    Description = "ขายพืช/ต้นไม้ทั้งหมดในกระเป๋าทันที",
    Default = false
})
sellToggle:OnChanged(function(Value)
    getgenv().autoSellAllEnabled = Value
end)

-------------------------------------------------------------------------
-- 5. SETTINGS TAB (ตั้งค่า)
-------------------------------------------------------------------------
local settingsTab = Window:AddTab({ Title = "ตั้งค่า (Settings)" })

settingsTab:AddParagraph({
    Title = "PayomboyZ HUB Configuration",
    Content = "จัดการระบบแจ้งเตือนและบันทึกการตั้งค่าของคุณ"
})

local webhookUrl = ""
local webhookInput = settingsTab:AddInput("WebhookURL", {
    Title = "Discord Webhook URL",
    Description = "ใส่ลิงก์ Webhook สำหรับแจ้งเตือน",
    Default = "",
})
webhookInput:OnChanged(function(Value)
    webhookUrl = Value
end)

settingsTab:AddButton({
    Title = "ทดสอบส่ง Webhook (Test Webhook)",
    Callback = function()
        if webhookUrl ~= "" then
            local data = {
                ["content"] = "",
                ["embeds"] = {{
                    ["title"] = "PayomboyZ HUB",
                    ["description"] = "การเชื่อมต่อ Webhook สำเร็จแล้ว! 🚀",
                    ["type"] = "rich",
                    ["color"] = tonumber(0xFF3C3C),
                }}
            }
            pcall(function()
                local request = http_request or request or HttpPost
                if request then
                    request({
                        Url = webhookUrl,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = HttpService:JSONEncode(data)
                    })
                end
            end)
            ObsidianGlassEngine:Notify({ Title = "Webhook", Content = "ส่งข้อความทดสอบสำเร็จ", Duration = 3 })
        else
            ObsidianGlassEngine:Notify({ Title = "Webhook", Content = "กรุณาใส่ลิงก์ Webhook ก่อน!", Duration = 3 })
        end
    end
})

settingsTab:AddButton({
    Title = "บันทึกการตั้งค่า (Save Config)",
    Callback = function()
        ObsidianGlassEngine:Notify({ Title = "ระบบ Config", Content = "บันทึกการตั้งค่าสำเร็จ (จำลอง)", Duration = 3 })
    end
})

-------------------------------------------------------------------------
-- 🔄 BACKGROUND TASKS & AUTOMATION LOOPS
-------------------------------------------------------------------------

-- 1. AUTO BUY EGG LOOP
task.spawn(function()
    while task.wait(1) do
        if getgenv().autoBuyEggsEnabled and selectedEgg ~= "" then
            pcall(function()
                if tick() - lastEggStockCheck > 10 then
                    local totalStock, usedStock = requestPersonalStockRemote:InvokeServer()
                    if totalStock and usedStock then
                        cachedEggStock = math.max(0, (totalStock[selectedEgg] or 0) - (usedStock[selectedEgg] or 0))
                    end
                    lastEggStockCheck = tick()
                end

                if cachedEggStock > 0 then
                    buyItemRemote:FireServer(selectedEgg)
                    cachedEggStock = cachedEggStock - 1
                end
            end)
        end
    end
end)

-- 2. AUTO PLACE EGG LOOP (ออโต้วางไข่ตามระดับไข่ที่เลือก)
task.spawn(function()
    while task.wait(2) do
        if getgenv().autoPlaceEggsEnabled and selectedEgg ~= "" then
            pcall(function()
                if placeEggRemote then
                    placeEggRemote:FireServer(selectedEgg)
                else
                    buyItemRemote:FireServer("Place", selectedEgg)
                end
            end)
        end
    end
end)

-- 3. AUTO BUY GEAR LOOP
task.spawn(function()
    while task.wait(1) do
        if getgenv().autoBuyGearsEnabled and selectedGear ~= "" then
            pcall(function()
                if tick() - lastGearStockCheck > 10 then
                    local totalStock, usedStock = requestPersonalStockRemote:InvokeServer()
                    if totalStock and usedStock then
                        cachedGearStock = math.max(0, (totalStock[selectedGear] or 0) - (usedStock[selectedGear] or 0))
                    end
                    lastGearStockCheck = tick()
                end

                if cachedGearStock > 0 then
                    buyItemRemote:FireServer(selectedGear)
                    cachedGearStock = cachedGearStock - 1
                end
            end)
        end
    end
end)

-- 4. AUTO BUY MERCHANT LOOP
task.spawn(function()
    while task.wait(1) do
        if getgenv().autoBuyMerchantEnabled and selectedMerchant ~= "" then
            pcall(function()
                if tick() - lastMerchantStockCheck > 10 then
                    local merchantName, totalStock, usedStock = requestMerchantStockRemote:InvokeServer()
                    if totalStock and usedStock then
                        cachedMerchantStock = math.max(0, (totalStock[selectedMerchant] or 0) - (usedStock[selectedMerchant] or 0))
                    end
                    lastMerchantStockCheck = tick()
                end

                if cachedMerchantStock > 0 then
                    buyMerchantItemRemote:FireServer(selectedMerchant)
                    cachedMerchantStock = cachedMerchantStock - 1
                end
            end)
        end
    end
end)

-- 5. AUTO EQUIP BEST PLANTS LOOP
task.spawn(function()
    while task.wait(60) do
        if getgenv().autoEquipBestEnabled then
            pcall(function()
                equipBestPlantsRemote:FireServer()
            end)
        end
    end
end)

-- 6. AUTO HATCH EGG LOOP
task.spawn(function()
    while task.wait(2) do
        if getgenv().autoHatchEnabled then
            pcall(function()
                local worldFolder = workspace:FindFirstChild("World")
                local mapFolder = worldFolder and worldFolder:FindFirstChild("Map")
                local placedItemsFolder = mapFolder and mapFolder:FindFirstChild("PlacedItems")
                local placedItemsServer = placedItemsFolder and placedItemsFolder:FindFirstChild("Server")
                
                if placedItemsServer then
                    for _, itemModel in ipairs(placedItemsServer:GetChildren()) do
                        if itemModel:IsA("Model") then
                            local serverConfiguration = itemModel:FindFirstChild("ServerConfiguration")
                            if serverConfiguration then
                                local typeValue = serverConfiguration:FindFirstChild("Type")
                                local hatchPercentageValue = serverConfiguration:FindFirstChild("HatchPercentage")
                                
                                if typeValue and typeValue.Value == "Egg" and hatchPercentageValue and hatchPercentageValue.Value >= 100 then
                                    hatchRemote:FireServer(itemModel.Name)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 7. AUTO SPAWN BOSS LOOP
task.spawn(function()
    while task.wait(1) do
        if getgenv().autoSpawnBossEnabled and selectedBoss ~= "" then
            pcall(function()
                summonBossRemote:InvokeServer("Summon", selectedBoss)
            end)
            task.wait(math.max(0, spawnInterval - 1))
        end
    end
end)

-- 8. AUTO SELL ALL LOOP
task.spawn(function()
    while task.wait(5) do
        if getgenv().autoSellAllEnabled then
            pcall(function()
                sellRemote:FireServer("bulkSell", "Plant")
            end)
        end
    end
end)

-- 9. DYNAMIC AUTO-UPDATE DROPDOWNS SCANNER LOOP (ตรวจสอบตัวละคร/ไข่ใหม่ทุก 5 วินาที)
task.spawn(function()
    local lastEggCount = #eggNamesList
    while task.wait(5) do
        pcall(function()
            if shopDataModule and shopDataModule.ShopOrders and shopDataModule.ShopOrders.EggShop then
                local currentEggList = shopDataModule.ShopOrders.EggShop
                if #currentEggList ~= lastEggCount then
                    local newEggList = {}
                    for _, eggName in ipairs(currentEggList) do
                        table.insert(newEggList, eggName)
                    end
                    eggDropdown:SetValues(newEggList)
                    lastEggCount = #currentEggList
                    ObsidianGlassEngine:Notify({
                        Title = "Auto-Update Dropdown",
                        Content = string.format("ตรวจพบไข่/ตัวละครใหม่! อัปเดตรายการเป็น %d รายการแล้ว", #newEggList),
                        Duration = 4
                    })
                end
            end
        end)
    end
end)

-------------------------------------------------------------------------
-- FINALIZE & STARTUP NOTIFICATION
-------------------------------------------------------------------------
Window:SelectTab(1)
ObsidianGlassEngine:Notify({
    Title = "PayomboyZ HUB",
    Content = "รันสคริปต์ Obsidian Glassmorphic 2 สำเร็จ! ขอให้สนุกครับ 🚀",
    Duration = 5
})

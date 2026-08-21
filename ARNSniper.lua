-- ======================================================================================
-- [[ PAYOMBOYZ HUB - SNIPER ARENA ROBLOX ]]
-- UI Engine: Obsidian Glassmorphic 2 (Compact Window Edition)
-- Standard Spec & Design System derived from Obsidain_Glassmophic2.txt
-- Integrated: Logout System Engine (logout copy.txt)
-- ======================================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local Camera = workspace.CurrentCamera
local player = LocalPlayer

-- ==========================================
-- ⚙️ SETTINGS CONFIGURATION
-- ==========================================
local Settings = {
    ESPEnabled = false,
    ShowNames = true,
    ShowDistance = true,
    TeamCheck = true,
    MaxDistance = 1000,
    FPSBoost = false,
    HitboxExpander = false,
    HighlightESP = false,
    AimbotEnabled = false,
    ShowFOV = false,
    FOVRadius = 150,
    Noclip = false,
    FastRespawn = false,
    InfiniteJump = false
}

-- ==========================================
-- 🎨 OBSIDIAN GLASS 2 COLOR PALETTE
-- ==========================================
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

-- Forward declaration of global state holders
local tracers = {}
local espLabels = {}
local toggleFPSBoost

-- ==========================================
-- 🔊 UI SOUND HELPERS & NOTIFICATION ENGINE
-- ==========================================
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

local function notify(title, content, duration)
    pcall(function()
        duration = duration or 3
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
        toast.Size = UDim2.new(0, 280, 0, 60)
        toast.Position = UDim2.new(1, 20, 1, -80)
        toast.BackgroundColor3 = COLORS.glass
        toast.BackgroundTransparency = 0.15
        toast.BorderSizePixel = 0
        toast.ZIndex = 999999
        toast.Parent = notifHolder
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = toast
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = COLORS.cyan
        stroke.Thickness = 1.5
        stroke.Parent = toast
        
        local tTitle = Instance.new("TextLabel")
        tTitle.Size = UDim2.new(1, -20, 0, 20)
        tTitle.Position = UDim2.new(0, 10, 0, 6)
        tTitle.BackgroundTransparency = 1
        tTitle.Text = title
        tTitle.TextColor3 = COLORS.cyan
        tTitle.Font = Enum.Font.GothamBold
        tTitle.TextSize = 13
        tTitle.TextXAlignment = Enum.TextXAlignment.Left
        tTitle.Parent = toast
        
        local tDesc = Instance.new("TextLabel")
        tDesc.Size = UDim2.new(1, -20, 0, 28)
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
        TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(1, -300, 1, -80) }):Play()
        task.delay(duration, function()
            if toast and toast.Parent then
                local tw = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = UDim2.new(1, 20, 1, -80) })
                tw:Play()
                tw.Completed:Connect(function() toast:Destroy() end)
            end
        end)
    end)
end

-- Avatar Loader Helper
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

-- ==========================================
-- 🔑 LOGOUT & KEY CLEARING & SCRIPT TERMINATION
-- ==========================================
local function performLogoutKeyClear()
    pcall(function()
        local filesToDelete = {
            "PayomboyZ_LuarmorKey.txt",
            "PayomboyZ_VVIPKey.txt",
            "PayomboyZ_SavedKey.txt"
        }
        if LuarmorConfig and type(LuarmorConfig) == "table" and LuarmorConfig.SavedKeyFile then
            table.insert(filesToDelete, LuarmorConfig.SavedKeyFile)
        end

        local del = (type(delfile) == "function" and delfile) or (type(deletefile) == "function" and deletefile)
        for _, file in ipairs(filesToDelete) do
            pcall(function()
                if isfile and isfile(file) then
                    if del then
                        del(file)
                    elseif type(writefile) == "function" then
                        writefile(file, "")
                    end
                end
            end)
        end
    end)

    pcall(function()
        if getgenv then
            getgenv().script_key = nil
            getgenv().PayomboyZ_InputKey = nil
            getgenv().PayomboyZ_LoggedOut = true
        end
        if getrenv then pcall(function() getrenv().script_key = nil end) end
        if getfenv then pcall(function() getfenv().script_key = nil end) end
        if _G then _G.script_key = nil end
        if shared then shared.script_key = nil end
        script_key = nil
    end)
end

local function stopAllScriptOperations()
    pcall(function()
        Settings.ESPEnabled = false
        Settings.TeamCheck = true
        Settings.FPSBoost = false
        Settings.HitboxExpander = false
        Settings.HighlightESP = false
        Settings.AimbotEnabled = false
        Settings.ShowFOV = false
        Settings.Noclip = false
        Settings.FastRespawn = false
        Settings.InfiniteJump = false

        if toggleFPSBoost then
            pcall(function() toggleFPSBoost(false) end)
        end

        for _, line in pairs(tracers) do pcall(function() line:Destroy() end) end
        for _, label in pairs(espLabels) do pcall(function() label:Destroy() end) end
        tracers = {}
        espLabels = {}

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hl = p.Character:FindFirstChild("PayomHighlight")
                if hl then pcall(function() hl:Destroy() end) end
                for _, partName in ipairs({"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}) do
                    local part = p.Character:FindFirstChild(partName)
                    if part and part:IsA("BasePart") and part:FindFirstChild("OrigSize") then
                        part.Size = part.OrigSize.Value
                        if part.Name == "HumanoidRootPart" then part.Transparency = 1 else part.Transparency = 0 end
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 🗑️ CLEANUP PREVIOUS INSTANCES
-- ==========================================
local parentGui = (typeof(gethui) == "function") and gethui() or CoreGui
if parentGui:FindFirstChild("PayomboyZ_CompactUI") then
    parentGui.PayomboyZ_CompactUI:Destroy()
end
if parentGui:FindFirstChild("PayomboyZ") then
    parentGui.PayomboyZ:Destroy()
end
if parentGui:FindFirstChild("ESP_Tracers") then
    parentGui.ESP_Tracers:Destroy()
end
if parentGui:FindFirstChild("PayomFOV") then
    parentGui.PayomFOV:Destroy()
end

-- ==========================================
-- 🖥️ CREATE COMPACT OBSIDIAN GLASS MAIN UI
-- ==========================================
local gui = Instance.new("ScreenGui")
gui.Name = "PayomboyZ_CompactUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 99999
gui.Parent = parentGui

local uiScale = Instance.new("UIScale")
local function updateScale()
    if Camera and Camera.ViewportSize then
        local vp = Camera.ViewportSize
        local targetWidth, targetHeight = 480, 520
        local scaleX = (vp.X - 20) / targetWidth
        local scaleY = (vp.Y - 20) / targetHeight
        uiScale.Scale = math.clamp(math.min(scaleX, scaleY), 0.55, 1.0)
    end
end
updateScale()
if Camera then
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
uiScale.Parent = gui

-- Main Shell (Compact Size: 480 x 520)
local shell = Instance.new("Frame")
shell.Name = "MainShell"
shell.Size = UDim2.fromOffset(480, 520)
shell.AnchorPoint = Vector2.new(0.5, 0.5)
shell.Position = UDim2.new(0.5, 0, 0.5, 0)
shell.BackgroundColor3 = COLORS.shell
shell.BackgroundTransparency = 0.18
shell.BorderSizePixel = 0
shell.ClipsDescendants = true
shell.Parent = gui

local shellCorner = Instance.new("UICorner")
shellCorner.CornerRadius = UDim.new(0, 16)
shellCorner.Parent = shell

local shellStroke = Instance.new("UIStroke")
shellStroke.Color = COLORS.cyan
shellStroke.Thickness = 1.5
shellStroke.Transparency = 0.3
shellStroke.Parent = shell

-- Particle Snow Layer
local snowLayer = Instance.new("Frame")
snowLayer.Name = "SnowLayer"
snowLayer.Size = UDim2.fromScale(1, 1)
snowLayer.BackgroundTransparency = 1
snowLayer.ZIndex = 2
snowLayer.Parent = shell

task.spawn(function()
    local dots = {}
    for i = 1, 20 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(math.random(2, 3), math.random(2, 3))
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
            speed = math.random(15, 35) / 10000,
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

-- Top Header Bar
local headerBar = Instance.new("Frame")
headerBar.Name = "HeaderBar"
headerBar.Size = UDim2.new(1, 0, 0, 44)
headerBar.BackgroundColor3 = COLORS.glassDeep
headerBar.BackgroundTransparency = 0.3
headerBar.BorderSizePixel = 0
headerBar.ZIndex = 10
headerBar.Parent = shell

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = headerBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -90, 0, 20)
titleLabel.Position = UDim2.new(0, 14, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎯 PayomboyZ | Sniper Arena"
titleLabel.TextColor3 = COLORS.text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 11
titleLabel.Parent = headerBar

local subTitleLabel = Instance.new("TextLabel")
subTitleLabel.Size = UDim2.new(1, -90, 0, 14)
subTitleLabel.Position = UDim2.new(0, 14, 0, 24)
subTitleLabel.BackgroundTransparency = 1
subTitleLabel.Text = "Obsidian Glassmorphic Compact Edition"
subTitleLabel.TextColor3 = COLORS.textMuted
subTitleLabel.Font = Enum.Font.Gotham
subTitleLabel.TextSize = 10
subTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subTitleLabel.ZIndex = 11
subTitleLabel.Parent = headerBar

-- Close & Minimize Buttons
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(26, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 9)
closeBtn.BackgroundColor3 = COLORS.glass
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "✕"
closeBtn.TextColor3 = COLORS.textMuted
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.ZIndex = 12
closeBtn.Parent = headerBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    playClickSound()
    shell.Visible = not shell.Visible
end)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(26, 26)
minBtn.Position = UDim2.new(1, -66, 0, 9)
minBtn.BackgroundColor3 = COLORS.glass
minBtn.BackgroundTransparency = 0.2
minBtn.Text = "─"
minBtn.TextColor3 = COLORS.textMuted
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 12
minBtn.ZIndex = 12
minBtn.Parent = headerBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

minBtn.MouseButton1Click:Connect(function()
    playClickSound()
    shell.Visible = not shell.Visible
end)

-- Dragging Engine for Compact Main Window
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

-- User Profile & Live Metrics Sub-Header
local profileBar = Instance.new("Frame")
profileBar.Size = UDim2.new(1, -24, 0, 42)
profileBar.Position = UDim2.new(0, 12, 0, 52)
profileBar.BackgroundColor3 = COLORS.userPanel
profileBar.BackgroundTransparency = 0.25
profileBar.BorderSizePixel = 0
profileBar.ZIndex = 10
profileBar.Parent = shell
Instance.new("UICorner", profileBar).CornerRadius = UDim.new(0, 10)

local avFrame = Instance.new("Frame")
avFrame.Size = UDim2.fromOffset(32, 32)
avFrame.Position = UDim2.new(0, 6, 0.5, -16)
avFrame.BackgroundColor3 = COLORS.glassDeep
avFrame.ZIndex = 11
avFrame.Parent = profileBar
Instance.new("UICorner", avFrame).CornerRadius = UDim.new(1, 0)
local avStroke = Instance.new("UIStroke")
avStroke.Color = COLORS.cyan
avStroke.Thickness = 1.2
avStroke.Parent = avFrame

local avImg = Instance.new("ImageLabel")
avImg.Size = UDim2.fromScale(1, 1)
avImg.BackgroundTransparency = 1
avImg.Image = loadCustomAvatarImage()
avImg.ZIndex = 12
avImg.Parent = avFrame
Instance.new("UICorner", avImg).CornerRadius = UDim.new(1, 0)

local nameLbl = Instance.new("TextLabel")
nameLbl.Size = UDim2.new(1, -125, 0, 16)
nameLbl.Position = UDim2.new(0, 44, 0, 4)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")"
nameLbl.TextColor3 = COLORS.text
nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextSize = 11
nameLbl.TextXAlignment = Enum.TextXAlignment.Left
nameLbl.ZIndex = 11
nameLbl.Parent = profileBar

local metricsLbl = Instance.new("TextLabel")
metricsLbl.Size = UDim2.new(1, -125, 0, 14)
metricsLbl.Position = UDim2.new(0, 44, 0, 20)
metricsLbl.BackgroundTransparency = 1
metricsLbl.Text = "⏱️ 00:00  •  ⚡ 60 FPS  •  📡 0 ms"
metricsLbl.TextColor3 = COLORS.cyan
metricsLbl.Font = Enum.Font.GothamBold
metricsLbl.TextSize = 9.5
metricsLbl.TextXAlignment = Enum.TextXAlignment.Left
metricsLbl.ZIndex = 11
metricsLbl.Parent = profileBar

-- 🔘 LOGOUT BUTTON IN PROFILE BAR
local logoutBtn = Instance.new("TextButton")
logoutBtn.Name = "LogoutButton"
logoutBtn.Size = UDim2.fromOffset(62, 24)
logoutBtn.Position = UDim2.new(1, -70, 0.5, -12)
logoutBtn.BackgroundColor3 = COLORS.surfacePressed
logoutBtn.BackgroundTransparency = 0.20
logoutBtn.Text = "Log out"
logoutBtn.TextColor3 = COLORS.danger
logoutBtn.Font = Enum.Font.GothamBold
logoutBtn.TextSize = 11
logoutBtn.ZIndex = 12
logoutBtn.Parent = profileBar

local loCorner = Instance.new("UICorner")
loCorner.CornerRadius = UDim.new(0, 6)
loCorner.Parent = logoutBtn

local loStroke = Instance.new("UIStroke")
loStroke.Color = COLORS.danger
loStroke.Thickness = 1
loStroke.Transparency = 0.4
loStroke.Parent = logoutBtn

logoutBtn.MouseEnter:Connect(function()
    TweenService:Create(logoutBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = COLORS.danger,
        BackgroundTransparency = 0.15
    }):Play()
    TweenService:Create(loStroke, TweenInfo.new(0.2), {
        Transparency = 0
    }):Play()
    logoutBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

logoutBtn.MouseLeave:Connect(function()
    TweenService:Create(logoutBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = COLORS.surfacePressed,
        BackgroundTransparency = 0.20
    }):Play()
    TweenService:Create(loStroke, TweenInfo.new(0.2), {
        Transparency = 0.4
    }):Play()
    logoutBtn.TextColor3 = COLORS.danger
end)

logoutBtn.MouseButton1Click:Connect(function()
    playClickSound()
    stopAllScriptOperations()
    performLogoutKeyClear()
    
    pcall(function()
        local parentGui = (typeof(gethui) == "function") and gethui() or CoreGui
        local tracerG = parentGui:FindFirstChild("ESP_Tracers")
        local fovG = parentGui:FindFirstChild("PayomFOV")
        local notifH = parentGui:FindFirstChild("ObsidianGlass_NotifHolder")
        if tracerG then tracerG:Destroy() end
        if fovG then fovG:Destroy() end
        if notifH then notifH:Destroy() end
    end)

    if gui and gui.Parent then
        gui:Destroy()
    end

    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/aslamdunk7/paypmboygang/refs/heads/main/Start"))()
    end)
end)

-- Realtime timer / FPS / Ping updater
task.spawn(function()
    local startTime = os.time()
    local frameCount = 0
    local lastFpsTime = tick()
    local fpsVal = 60

    local conn = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastFpsTime >= 1 then
            fpsVal = frameCount
            frameCount = 0
            lastFpsTime = now
        end
    end)

    while task.wait(0.8) do
        if not gui or not gui.Parent then
            if conn then conn:Disconnect() end
            break
        end
        local elapsed = os.time() - startTime
        local mins = math.floor(elapsed / 60)
        local secs = elapsed % 60
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        metricsLbl.Text = string.format("⏱️ %02d:%02d  •  ⚡ %d FPS  •  📡 %d ms", mins, secs, fpsVal, ping)
    end
end)

-- Main Scroll Container for Toggles & Controls
local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Name = "ContentScroll"
contentScroll.Size = UDim2.new(1, -20, 1, -104)
contentScroll.Position = UDim2.new(0, 10, 0, 98)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 3
contentScroll.ScrollBarImageColor3 = COLORS.cyan
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.ZIndex = 10
contentScroll.Parent = shell

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 222, 0, 52)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 8)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = contentScroll

gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 12)
end)

-- Helper to Create Obsidian Glass Toggle Cards
local function createObsidianToggle(name, iconText, titleText, descText, defaultValue, callback)
    local card = Instance.new("Frame")
    card.Name = name .. "_Card"
    card.Size = UDim2.new(0, 222, 0, 52)
    card.BackgroundColor3 = defaultValue and COLORS.glassRaised or COLORS.glassDeep
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.ZIndex = 11
    card.Parent = contentScroll

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = defaultValue and COLORS.cyan or COLORS.surfaceHover
    cardStroke.Thickness = 1.2
    cardStroke.Transparency = defaultValue and 0.2 or 0.6
    cardStroke.Parent = card

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.fromOffset(26, 26)
    iconLabel.Position = UDim2.new(0, 8, 0.5, -13)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = iconText
    iconLabel.TextSize = 16
    iconLabel.ZIndex = 12
    iconLabel.Parent = card

    local tTitle = Instance.new("TextLabel")
    tTitle.Size = UDim2.new(1, -78, 0, 16)
    tTitle.Position = UDim2.new(0, 36, 0, 8)
    tTitle.BackgroundTransparency = 1
    tTitle.Text = titleText
    tTitle.TextColor3 = COLORS.text
    tTitle.Font = Enum.Font.GothamBold
    tTitle.TextSize = 12
    tTitle.TextXAlignment = Enum.TextXAlignment.Left
    tTitle.ZIndex = 12
    tTitle.Parent = card

    local tDesc = Instance.new("TextLabel")
    tDesc.Size = UDim2.new(1, -78, 0, 14)
    tDesc.Position = UDim2.new(0, 36, 0, 26)
    tDesc.BackgroundTransparency = 1
    tDesc.Text = descText
    tDesc.TextColor3 = COLORS.textMuted
    tDesc.Font = Enum.Font.Gotham
    tDesc.TextSize = 9.5
    tDesc.TextXAlignment = Enum.TextXAlignment.Left
    tDesc.ZIndex = 12
    tDesc.Parent = card

    -- Status Pill Switch (ON / OFF)
    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(36, 18)
    pill.Position = UDim2.new(1, -42, 0.5, -9)
    pill.BackgroundColor3 = defaultValue and COLORS.primary or COLORS.surface
    pill.ZIndex = 12
    pill.Parent = card
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local pillKnob = Instance.new("Frame")
    pillKnob.Size = UDim2.fromOffset(14, 14)
    pillKnob.Position = defaultValue and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    pillKnob.BackgroundColor3 = COLORS.text
    pillKnob.ZIndex = 13
    pillKnob.Parent = pill
    Instance.new("UICorner", pillKnob).CornerRadius = UDim.new(1, 0)

    local state = defaultValue
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 15
    btn.Parent = card

    btn.MouseButton1Click:Connect(function()
        state = not state
        playClickSound()
        
        TweenService:Create(card, TweenInfo.new(0.2), {
            BackgroundColor3 = state and COLORS.glassRaised or COLORS.glassDeep
        }):Play()
        TweenService:Create(cardStroke, TweenInfo.new(0.2), {
            Color = state and COLORS.cyan or COLORS.surfaceHover,
            Transparency = state and 0.2 or 0.6
        }):Play()
        TweenService:Create(pill, TweenInfo.new(0.2), {
            BackgroundColor3 = state and COLORS.primary or COLORS.surface
        }):Play()
        TweenService:Create(pillKnob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()

        notify(titleText, state and "เปิดใช้งานฟังก์ชันแล้ว" or "ปิดการใช้งานแล้ว", 2.5)
        callback(state)
    end)

    return card
end

-- ==========================================
-- 💎 DRAGGABLE TOGGLE CAPSULE WITH METRICS
-- ==========================================
local toggleCapsule = Instance.new("Frame")
toggleCapsule.Name = "ObsidianToggleCapsule"
toggleCapsule.Size = UDim2.fromOffset(220, 56)
toggleCapsule.Position = UDim2.new(0, 15, 0.5, -28)
toggleCapsule.BackgroundColor3 = COLORS.shell
toggleCapsule.BackgroundTransparency = 0.18
toggleCapsule.BorderSizePixel = 0
toggleCapsule.ClipsDescendants = true
toggleCapsule.ZIndex = 99999
toggleCapsule.Parent = gui

Instance.new("UICorner", toggleCapsule).CornerRadius = UDim.new(0, 16)
local tcStroke = Instance.new("UIStroke")
tcStroke.Color = COLORS.cyan
tcStroke.Thickness = 1.5
tcStroke.Transparency = 0.2
tcStroke.Parent = toggleCapsule

-- Capsule Snow Particles
local capsuleSnowLayer = Instance.new("Frame")
capsuleSnowLayer.Size = UDim2.fromScale(1, 1)
capsuleSnowLayer.BackgroundTransparency = 1
capsuleSnowLayer.ZIndex = 1
capsuleSnowLayer.Parent = toggleCapsule

task.spawn(function()
    local dots = {}
    for i = 1, 10 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(math.random(2, 3), math.random(2, 3))
        dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
        dot.BackgroundColor3 = Color3.fromRGB(220, 240, 255)
        dot.BackgroundTransparency = math.random(30, 70) / 100
        dot.BorderSizePixel = 0
        dot.ZIndex = 1
        dot.Parent = capsuleSnowLayer

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

local capAvFrame = Instance.new("Frame")
capAvFrame.Size = UDim2.fromOffset(40, 40)
capAvFrame.Position = UDim2.new(0, 8, 0.5, -20)
capAvFrame.BackgroundColor3 = COLORS.glassDeep
capAvFrame.ZIndex = 3
capAvFrame.Parent = toggleCapsule
Instance.new("UICorner", capAvFrame).CornerRadius = UDim.new(1, 0)

local capAvStroke = Instance.new("UIStroke")
capAvStroke.Color = COLORS.primary
capAvStroke.Thickness = 1.5
capAvStroke.Parent = capAvFrame

local capAvImg = Instance.new("ImageLabel")
capAvImg.Size = UDim2.fromScale(1, 1)
capAvImg.BackgroundTransparency = 1
capAvImg.Image = loadCustomAvatarImage()
capAvImg.ZIndex = 4
capAvImg.Parent = capAvFrame
Instance.new("UICorner", capAvImg).CornerRadius = UDim.new(1, 0)

local capUserLbl = Instance.new("TextLabel")
capUserLbl.Size = UDim2.new(1, -56, 0, 16)
capUserLbl.Position = UDim2.new(0, 54, 0, 10)
capUserLbl.BackgroundTransparency = 1
capUserLbl.Text = "@" .. LocalPlayer.Name
capUserLbl.TextColor3 = COLORS.text
capUserLbl.Font = Enum.Font.GothamBold
capUserLbl.TextSize = 11.5
capUserLbl.TextXAlignment = Enum.TextXAlignment.Left
capUserLbl.ZIndex = 3
capUserLbl.Parent = toggleCapsule

local capMetricsLbl = Instance.new("TextLabel")
capMetricsLbl.Size = UDim2.new(1, -56, 0, 14)
capMetricsLbl.Position = UDim2.new(0, 54, 0, 27)
capMetricsLbl.BackgroundTransparency = 1
capMetricsLbl.Text = "⚡ 60 FPS  •  📡 0 ms"
capMetricsLbl.TextColor3 = COLORS.cyan
capMetricsLbl.Font = Enum.Font.GothamBold
capMetricsLbl.TextSize = 9.5
capMetricsLbl.TextXAlignment = Enum.TextXAlignment.Left
capMetricsLbl.ZIndex = 3
capMetricsLbl.Parent = toggleCapsule

task.spawn(function()
    local frameCount = 0
    local lastFpsTime = tick()
    local fpsVal = 60

    local renderConn = RunService.RenderStepped:Connect(function()
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
        capMetricsLbl.Text = string.format("⚡ %d FPS  •  📡 %d ms", fpsVal, pingVal)
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

-- Keybind Toggle (K or RightControl)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.RightControl then
        shell.Visible = not shell.Visible
    end
end)

-- ==========================================
-- 🎯 CREATING FEATURE TOGGLES (10 MODULES)
-- ==========================================
createObsidianToggle("AimbotToggle", "🎯", "Aimbot Lock", "ล็อคเป้าอัตโนมัติ", Settings.AimbotEnabled, function(state)
    Settings.AimbotEnabled = state
end)

createObsidianToggle("ESPToggle", "🔍", "ESP Tracers", "วาดเส้นชี้ตำแหน่งศัตรู", Settings.ESPEnabled, function(state)
    Settings.ESPEnabled = state
    if not state then
        for _, line in pairs(tracers) do line.Visible = false end
        for _, label in pairs(espLabels) do label.Visible = false end
    end
end)

createObsidianToggle("TeamCheckToggle", "🛡️", "Team Check", "ซ่อนตำแหน่งผู้เล่นทีมเดียวกัน", Settings.TeamCheck, function(state)
    Settings.TeamCheck = state
end)

createObsidianToggle("HighlightToggle", "👁️", "Highlight ESP", "มองทะลุกำแพงเรืองแสง", Settings.HighlightESP, function(state)
    Settings.HighlightESP = state
end)

createObsidianToggle("HitboxToggle", "📦", "Hitbox Expander", "ขยายขนาดตัวศัตรูให้ยิงง่ายขึ้น", Settings.HitboxExpander, function(state)
    Settings.HitboxExpander = state
end)

createObsidianToggle("FOVToggle", "⭕", "Show FOV", "แสดงวงกลมขอบเขตการล็อคเป้า", Settings.ShowFOV, function(state)
    Settings.ShowFOV = state
    if FOVFrame then FOVFrame.Visible = state end
end)

createObsidianToggle("FPSBoostToggle", "🚀", "FPS Boost", "ลดกราฟิกเพื่อเพิ่มความลื่นไหล", Settings.FPSBoost, function(state)
    Settings.FPSBoost = state
    toggleFPSBoost(state)
end)

createObsidianToggle("NoclipToggle", "🧱", "Noclip", "เดินทะลุกำแพงและสิ่งกีดขวาง", Settings.Noclip, function(state)
    Settings.Noclip = state
end)

createObsidianToggle("FastRespawnToggle", "⚡", "Fast Respawn 0s", "เกิดใหม่ทันทีโดยไม่รอเวลา", Settings.FastRespawn, function(state)
    Settings.FastRespawn = state
end)

createObsidianToggle("InfJumpToggle", "🦘", "Infinite Jump", "กระโดดกลางอากาศได้ไม่จำกัด", Settings.InfiniteJump, function(state)
    Settings.InfiniteJump = state
end)

-- ==========================================
-- 🎯 ESP GUI & FOV GUI INITIALIZATION
-- ==========================================
local tracerGui = Instance.new("ScreenGui")
tracerGui.Name = "ESP_Tracers"
tracerGui.ResetOnSpawn = false
tracerGui.IgnoreGuiInset = true
tracerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
tracerGui.Parent = parentGui

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "PayomFOV"
FOVGui.ResetOnSpawn = false
FOVGui.IgnoreGuiInset = true
FOVGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FOVGui.Parent = parentGui

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
FOVStroke.Color = COLORS.cyan
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVFrame
FOVFrame.Parent = FOVGui

local function createTracer(targetPlayer)
    if targetPlayer == player then return end
    if tracers[targetPlayer] then return end

    local line = Instance.new("Frame")
    line.Name = targetPlayer.Name .. "_Tracer"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = COLORS.primary
    line.BorderSizePixel = 0
    line.Visible = false
    line.ZIndex = 5
    line.Parent = tracerGui
    tracers[targetPlayer] = line

    local label = Instance.new("TextLabel")
    label.Name = targetPlayer.Name .. "_Label"
    label.Size = UDim2.new(0, 140, 0, 32)
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.BackgroundColor3 = COLORS.glassDeep
    label.BackgroundTransparency = 0.25
    label.BorderSizePixel = 0
    label.Text = targetPlayer.Name .. "\n0 studs"
    label.TextColor3 = COLORS.text
    label.TextSize = 10.5
    label.Font = Enum.Font.GothamSemibold
    label.Visible = false
    label.ZIndex = 6
    label.Parent = tracerGui
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
    local lStroke = Instance.new("UIStroke")
    lStroke.Color = COLORS.cyan
    lStroke.Thickness = 1
    lStroke.Parent = label
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

local function getCharacter(targetPlayer)
    if not targetPlayer then return nil end
    if targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid") then
        return targetPlayer.Character
    end
    local charByName = workspace:FindFirstChild(targetPlayer.Name)
    if charByName and charByName:FindFirstChildOfClass("Humanoid") then
        return charByName
    end
    for _, folderName in ipairs({"Characters", "Players", "Entities"}) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            local c = folder:FindFirstChild(targetPlayer.Name)
            if c and c:FindFirstChildOfClass("Humanoid") then
                return c
            end
        end
    end
    return nil
end

local function bindPlayerEvents(targetPlayer)
    if targetPlayer == player then return end
    createTracer(targetPlayer)
    targetPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        createTracer(targetPlayer)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    bindPlayerEvents(p)
end
Players.PlayerAdded:Connect(bindPlayerEvents)
Players.PlayerRemoving:Connect(removeTracer)

-- FPS Boost Function Logic Implementation
function toggleFPSBoost(state)
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

-- Team Check Logic
local function isSameTeam(targetPlayer)
    if not Settings.TeamCheck then return false end
    if not targetPlayer or targetPlayer == player then return true end
    
    if player.Team ~= nil and targetPlayer.Team ~= nil then
        if player.Team == targetPlayer.Team then
            local teamName = tostring(player.Team.Name):lower()
            if not string.find(teamName, "neutral") and not string.find(teamName, "ffa") and not string.find(teamName, "free") then
                return true
            end
        end
    end
    
    if player.TeamColor and targetPlayer.TeamColor and player.TeamColor == targetPlayer.TeamColor then
        local colorName = tostring(player.TeamColor.Name):lower()
        if not string.find(colorName, "white") and not string.find(colorName, "grey") and not string.find(colorName, "gray") then
            return true
        end
    end

    local myTeamVal = player:FindFirstChild("Team") or (player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Team"))
    local targetTeamVal = targetPlayer:FindFirstChild("Team") or (targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Team"))
    if myTeamVal and targetTeamVal and myTeamVal.Value == targetTeamVal.Value and tostring(myTeamVal.Value) ~= "" and tostring(myTeamVal.Value) ~= "0" then
        return true
    end

    local myChar = player.Character
    local targetChar = targetPlayer.Character
    if myChar and targetChar then
        local myCharTeam = myChar:FindFirstChild("Team") or myChar:FindFirstChild("TeamColor")
        local targetCharTeam = targetChar:FindFirstChild("Team") or targetChar:FindFirstChild("TeamColor")
        if myCharTeam and targetCharTeam and myCharTeam.Value == targetCharTeam.Value then
            return true
        end
    end

    return false
end

-- Distance Color Matrix
local function getColorByDistance(dist)
    if dist < 100 then
        return COLORS.danger
    elseif dist < 300 then
        return COLORS.warning
    elseif dist < 600 then
        return Color3.fromRGB(255, 255, 100)
    else
        return COLORS.success
    end
end

-- Infinite Jump Listener
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Fast Respawn Listener
player.CharacterAdded:Connect(function(char)
    if Settings.FastRespawn then
        task.spawn(function()
            local humanoid = char:WaitForChild("Humanoid", 3)
            if humanoid then
                humanoid.Died:Connect(function()
                    if Settings.FastRespawn then
                        player:LoadCharacter()
                    end
                end)
            end
        end)
    end
end)

-- Background Task Loop: Highlight & Hitbox
task.spawn(function()
    while task.wait(0.1) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                pcall(function()
                    local char = getCharacter(p)
                    if not char then return end
                    
                    local hl = char:FindFirstChild("PayomHighlight")
                    if Settings.HighlightESP and not (Settings.TeamCheck and isSameTeam(p)) then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "PayomHighlight"
                                hl.FillColor = COLORS.primary
                                hl.OutlineColor = COLORS.text
                                hl.FillTransparency = 0.5
                                hl.OutlineTransparency = 0.1
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = char
                            end
                        else
                            if hl then hl:Destroy() end
                        end
                    else
                        if hl then hl:Destroy() end
                    end

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
                                    part.Transparency = 0.95
                                    part.Color = COLORS.cyan
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

-- Stepped Loop: Noclip
RunService.Stepped:Connect(function()
    pcall(function()
        local char = player.Character
        if char and Settings.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- Target Locking & Closest Player Finder
local function getClosestPlayerToCenter()
    local closestPlayer = nil
    local shortestDistance = Settings.FOVRadius
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            if isSameTeam(p) then continue end
            local char = getCharacter(p)
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    for _, partName in ipairs({"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Head"}) do
                        local part = char:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then
                            local vector, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local screenPos = Vector2.new(vector.X, vector.Y)
                                local dist = (screenPos - centerPos).Magnitude
                                
                                if Settings.HitboxExpander then
                                    local radius2D = (part.Size.X * 0.5 * Camera.ViewportSize.Y) / (2 * math.tan(math.rad(Camera.FieldOfView * 0.5)) * math.max(1, vector.Z))
                                    dist = math.max(0, dist - radius2D)
                                end

                                if dist <= Settings.FOVRadius and dist < shortestDistance then
                                    shortestDistance = dist
                                    closestPlayer = p
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- RenderStepped Main Automation & ESP Renderer
RunService.RenderStepped:Connect(function()
    if Settings.ShowFOV and FOVFrame then
        FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    end
    
    local target = getClosestPlayerToCenter()
    local currentLockedTarget = target

    if Settings.AimbotEnabled and target and target.Character then
        local aimTarget = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
        if aimTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimTarget.Position)
        end
    end

    if not Settings.ESPEnabled then return end

    local myCharacter = getCharacter(player)
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

    for targetPlayer, _ in pairs(tracers) do
        if not targetPlayer or not targetPlayer.Parent then
            removeTracer(targetPlayer)
        end
    end

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer == player then continue end

        if not tracers[targetPlayer] or not espLabels[targetPlayer] then
            createTracer(targetPlayer)
        end

        local line = tracers[targetPlayer]
        local label = espLabels[targetPlayer]
        if not line or not label then continue end

        if isSameTeam(targetPlayer) then
            line.Visible = false
            label.Visible = false
            continue
        end

        local character = getCharacter(targetPlayer)
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if character and rootPart and humanoid and humanoid.Health > 0 then
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local worldDist = myRoot and (rootPart.Position - myRoot.Position).Magnitude or 0

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
                
                local isTargeted = (targetPlayer == currentLockedTarget and Settings.AimbotEnabled)
                local tracerColor = isTargeted and COLORS.cyan or getColorByDistance(worldDist)
                local lineThickness = isTargeted and 3 or 2

                line.Position = UDim2.new(0, center.X, 0, center.Y)
                line.Size = UDim2.new(0, distance2D, 0, lineThickness)
                line.Rotation = angle
                line.BackgroundColor3 = tracerColor
                line.Visible = true

                local statusText = isTargeted and " 🎯 [LOCKED]" or ""
                label.Position = UDim2.new(0, vector.X, 0, vector.Y - 5)
                label.Text = string.format("%s%s\n%d studs", targetPlayer.Name, statusText, math.floor(worldDist))
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

notify("PayomboyZ Hub", "โหลดระบบ Obsidian Glass Compact + Logout สำเร็จแล้ว!", 4)

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
while not player do task.wait(0.1); player = Players.LocalPlayer end
local playerGui = player:WaitForChild("PlayerGui", 10) or player.PlayerGui

-- ======================================================================================
-- [[ OBSIDIAN GLASSMORPHIC 2 UI ENGINE - MASTER SPECIFICATION & INTEGRATION ]]
-- ======================================================================================

local LocalPlayer = player

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
local Fluent = ObsidianGlassEngine
local Options = ObsidianGlassEngine.Options

local function playClickSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://6895079853"
        sound.Volume = 0.3
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
end

local customAvatarAsset = nil
local isDownloadingAvatar = false

local function loadCustomAvatarImage()
    if customAvatarAsset then return customAvatarAsset end
    local avatarUrl = "https://raw.githubusercontent.com/aslamdunk7/paypmboygang/main/543199739_2812856088914181_3062917809445648175_n.jpg"
    local fileName = "payomboyz_avatar.jpg"
    
    pcall(function()
        if typeof(isfile) == "function" and isfile(fileName) then
            if typeof(getcustomasset) == "function" or typeof(getsynasset) == "function" then
                local getAsset = getcustomasset or getsynasset
                customAvatarAsset = getAsset(fileName)
            end
        end
    end)

    if not customAvatarAsset and not isDownloadingAvatar then
        isDownloadingAvatar = true
        task.spawn(function()
            pcall(function()
                if typeof(writefile) == "function" and (typeof(getcustomasset) == "function" or typeof(getsynasset) == "function") then
                    local getAsset = getcustomasset or getsynasset
                    local imageBytes = game:HttpGet(avatarUrl)
                    if imageBytes and #imageBytes > 0 then
                        writefile(fileName, imageBytes)
                        if typeof(isfile) == "function" and isfile(fileName) then
                            customAvatarAsset = getAsset(fileName)
                        end
                    end
                end
            end)
            isDownloadingAvatar = false
        end)
    end

    if not customAvatarAsset then
        customAvatarAsset = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    end
    return customAvatarAsset
end

-- ============================================================================
-- 🔴 LOGOUT & CREDENTIAL CLEARING ENGINE
-- ============================================================================
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
    if _G.GakuranCleanup then pcall(_G.GakuranCleanup) end
    if _G.ScriptCleanup then pcall(_G.ScriptCleanup) end
    if _G.PayomboyZCleanup then pcall(_G.PayomboyZCleanup) end

    if ObsidianGlassEngine and ObsidianGlassEngine.Options then
        for _, option in pairs(ObsidianGlassEngine.Options) do
            if type(option) == "table" and option.SetValue then
                pcall(function() option:SetValue(false) end)
            end
        end
    end
end

function ObsidianGlassEngine:Notify(cfg)
    pcall(function()
        local title = cfg.Title or "System"
        local content = cfg.Content or ""
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
        game:GetService("TweenService"):Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(1, -320, 1, -85) }):Play()
        task.delay(duration, function()
            if toast and toast.Parent then
                local tw = game:GetService("TweenService"):Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = UDim2.new(1, 20, 1, -85) })
                tw:Play()
                tw.Completed:Connect(function() toast:Destroy() end)
            end
        end)
    end)
end

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
    uiScale.Scale = 1.0
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

    -- 💎 UNIVERSAL DRAGGABLE TOGGLE CAPSULE WITH SNOW, IMAGE & METRICS (FPS/PING)
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

    -- ❄️ MINI SNOW LAYER INSIDE TOGGLE CAPSULE
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

    -- 🖼️ AVATAR IMAGE BOX (CUSTOM GITHUB LOGO / AVATAR)
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

    -- 👤 USERNAME & ⚡ METRICS (FPS & PING)
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

    -- 🔄 REALTIME FPS & PING UPDATE LOOP FOR TOGGLE CAPSULE
    task.spawn(function()
        local frameCount = 0
        local lastFpsTime = tick()
        local fpsVal = 60

        local RunService = game:GetService("RunService")
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

    -- 🖱️ CLICKABLE BUTTON & DRAGGABLE HANDLER
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

    -- ⌨️ KEYBIND TOGGLE (KEY [K] / [RightControl])
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.RightControl then
            shell.Visible = not shell.Visible
        end
    end)

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
    displayNameLabel.Size = UDim2.new(1, -145, 0, 18)
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
    usernameLabel.Size = UDim2.new(1, -145, 0, 14)
    usernameLabel.Position = UDim2.new(0, 66, 0, 33)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "@" .. LocalPlayer.Name
    usernameLabel.TextColor3 = COLORS.textMuted
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextSize = 10
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.ZIndex = 10
    usernameLabel.Parent = userPanel

    -- 🔴 LOG OUT BUTTON (Obsidian Glassmorphic Style)
    local logoutBtn = Instance.new("TextButton")
    logoutBtn.Name = "LogoutButton"
    logoutBtn.Size = UDim2.fromOffset(62, 24)
    logoutBtn.Position = UDim2.new(1, -74, 0, 20)
    logoutBtn.BackgroundColor3 = COLORS.surfacePressed
    logoutBtn.BackgroundTransparency = 0.20
    logoutBtn.Text = "Log out"
    logoutBtn.TextColor3 = COLORS.danger
    logoutBtn.Font = Enum.Font.GothamBold
    logoutBtn.TextSize = 11
    logoutBtn.ZIndex = 12
    logoutBtn.Parent = userPanel

    local loCorner = Instance.new("UICorner")
    loCorner.CornerRadius = UDim.new(0, 6)
    loCorner.Parent = logoutBtn

    local loStroke = Instance.new("UIStroke")
    loStroke.Color = COLORS.danger
    loStroke.Thickness = 1
    loStroke.Transparency = 0.4
    loStroke.Parent = logoutBtn

    logoutBtn.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(logoutBtn, TweenInfo.new(0.2), { BackgroundColor3 = COLORS.danger, BackgroundTransparency = 0.15 }):Play()
        game:GetService("TweenService"):Create(loStroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
        logoutBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    logoutBtn.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(logoutBtn, TweenInfo.new(0.2), { BackgroundColor3 = COLORS.surfacePressed, BackgroundTransparency = 0.20 }):Play()
        game:GetService("TweenService"):Create(loStroke, TweenInfo.new(0.2), { Transparency = 0.4 }):Play()
        logoutBtn.TextColor3 = COLORS.danger
    end)

    logoutBtn.MouseButton1Click:Connect(function()
        playClickSound()
        stopAllScriptOperations()
        performLogoutKeyClear()
        if gui then pcall(function() gui:Destroy() end) end
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/aslamdunk7/paypmboygang/refs/heads/main/Start"))()
        end)
    end)

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
    mainTitle.Text = cfg.Title or "Obsidian Glass Hub"
    mainTitle.TextColor3 = COLORS.text
    mainTitle.Font = Enum.Font.GothamBold
    mainTitle.TextSize = 18
    mainTitle.TextXAlignment = Enum.TextXAlignment.Left
    mainTitle.Parent = headerBar

    local mainSubTitle = Instance.new("TextLabel")
    mainSubTitle.Size = UDim2.new(0, 350, 0, 16)
    mainSubTitle.Position = UDim2.new(0, 20, 0, 28)
    mainSubTitle.BackgroundTransparency = 1
    mainSubTitle.Text = cfg.SubTitle or "Obsidian Glassmorphic 2 Engine"
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
    sTitle.Size = UDim2.new(1, -160, 0, 22)
    sTitle.Position = UDim2.new(0, 14, 0, 30)
    sTitle.BackgroundTransparency = 1
    sTitle.Text = "PayomboyZ HUB • Anime Roll to Fight Edition"
    sTitle.TextColor3 = COLORS.text
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextSize = 14
    sTitle.TextXAlignment = Enum.TextXAlignment.Left
    sTitle.Parent = serviceBanner

    local sVer = Instance.new("TextLabel")
    sVer.Size = UDim2.new(0, 100, 0, 20)
    sVer.Position = UDim2.new(1, -114, 0, 22)
    sVer.BackgroundTransparency = 1
    sVer.Text = "v2.5 OBSIDIAN"
    sVer.TextColor3 = COLORS.cyan
    sVer.Font = Enum.Font.GothamBold
    sVer.TextSize = 11
    sVer.TextXAlignment = Enum.TextXAlignment.Right
    sVer.Parent = serviceBanner

    local pagesFolder = Instance.new("Folder")
    pagesFolder.Name = "Pages"
    pagesFolder.Parent = mainPanel

    local WindowObj = { Tabs = {} }

    function WindowObj:AddTab(tabCfg)
        local tabTitle = tabCfg.Title or "Tab"
        local tabIndex = #WindowObj.Tabs + 1

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -6, 0, 42)
        tabBtn.Position = UDim2.new(0, 3, 0, 0)
        tabBtn.BackgroundColor3 = (tabIndex == 1) and COLORS.primary or Color3.fromRGB(38, 16, 24)
        tabBtn.BackgroundTransparency = (tabIndex == 1) and 0.15 or 0.20
        tabBtn.Text = tabTitle
        tabBtn.TextColor3 = (tabIndex == 1) and Color3.fromRGB(255, 255, 255) or COLORS.textMuted
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 14
        tabBtn.ZIndex = 12
        tabBtn.Parent = tabScroll

        local tbCorner = Instance.new("UICorner")
        tbCorner.CornerRadius = UDim.new(0, 10)
        tbCorner.Parent = tabBtn

        local tbStroke = Instance.new("UIStroke")
        tbStroke.Color = (tabIndex == 1) and COLORS.primary or Color3.fromRGB(70, 30, 45)
        tbStroke.Thickness = 1.5
        tbStroke.Transparency = (tabIndex == 1) and 0 or 0.3
        tbStroke.Parent = tabBtn

        local activeIndicator = Instance.new("Frame")
        activeIndicator.Size = UDim2.new(0, 4, 0, 22)
        activeIndicator.Position = UDim2.new(0, 4, 0.5, -11)
        activeIndicator.BackgroundColor3 = COLORS.cyan
        activeIndicator.BorderSizePixel = 0
        activeIndicator.Visible = (tabIndex == 1)
        activeIndicator.ZIndex = 13
        activeIndicator.Parent = tabBtn

        local indCorner = Instance.new("UICorner")
        indCorner.CornerRadius = UDim.new(0, 2)
        indCorner.Parent = activeIndicator

        local pageScroll = Instance.new("ScrollingFrame")
        pageScroll.Name = "Page_" .. tabTitle
        pageScroll.Size = UDim2.new(1, -40, 1, -125)
        pageScroll.Position = UDim2.new(0, 20, 0, 120)
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
                t.btn.BackgroundTransparency = 0.20
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
                local descLbl = Instance.new("TextLabel")
                descLbl.Size = UDim2.new(1, -70, 0, 16)
                descLbl.Position = UDim2.new(0, 12, 0, 30)
                descLbl.BackgroundTransparency = 1
                descLbl.Text = desc
                descLbl.TextColor3 = COLORS.textMuted
                descLbl.Font = Enum.Font.Gotham
                descLbl.TextSize = 11
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Parent = frame
            end

            local toggleTrack = Instance.new("Frame")
            toggleTrack.Size = UDim2.fromOffset(44, 24)
            toggleTrack.Position = UDim2.new(1, -54, 0.5, -12)
            toggleTrack.BackgroundColor3 = defaultVal and COLORS.primary or COLORS.surface
            toggleTrack.BackgroundTransparency = 0.18
            toggleTrack.BorderSizePixel = 0
            toggleTrack.Parent = frame

            local tCorner = Instance.new("UICorner")
            tCorner.CornerRadius = UDim.new(1, 0)
            tCorner.Parent = toggleTrack

            local toggleKnob = Instance.new("Frame")
            toggleKnob.Size = UDim2.fromOffset(18, 18)
            toggleKnob.Position = defaultVal and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            toggleKnob.BackgroundColor3 = COLORS.text
            toggleKnob.BorderSizePixel = 0
            toggleKnob.Parent = toggleTrack

            local kCorner = Instance.new("UICorner")
            kCorner.CornerRadius = UDim.new(1, 0)
            kCorner.Parent = toggleKnob

            local OptionObj = { Value = defaultVal, ChangedCallbacks = {} }

            local function updateToggle(val)
                OptionObj.Value = val
                game:GetService("TweenService"):Create(toggleTrack, TweenInfo.new(0.2), { BackgroundColor3 = val and COLORS.primary or COLORS.surface }):Play()
                game:GetService("TweenService"):Create(toggleKnob, TweenInfo.new(0.2), { Position = val and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }):Play()
                for _, cb in ipairs(OptionObj.ChangedCallbacks) do
                    task.spawn(cb, val)
                end
            end

            function OptionObj:OnChanged(cb)
                table.insert(OptionObj.ChangedCallbacks, cb)
                return { Disconnect = function() table.remove(OptionObj.ChangedCallbacks, table.find(OptionObj.ChangedCallbacks, cb)) end }
            end

            function OptionObj:SetValue(val)
                updateToggle(val)
            end

            local hitBtn = Instance.new("TextButton")
            hitBtn.Size = UDim2.fromScale(1, 1)
            hitBtn.BackgroundTransparency = 1
            hitBtn.Text = ""
            hitBtn.Parent = frame

            hitBtn.MouseButton1Click:Connect(function()
                playClickSound()
                updateToggle(not OptionObj.Value)
            end)

            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        function TabObj:AddSlider(id, sCfg)
            local title = sCfg.Title or id
            local desc = sCfg.Desc or sCfg.Description or ""
            local min = sCfg.Min or 0
            local max = sCfg.Max or 100
            local defaultVal = sCfg.Default or min

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, desc ~= "" and 65 or 55)
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
            lbl.Size = UDim2.new(1, -120, 0, 22)
            lbl.Position = UDim2.new(0, 12, 0, 6)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = COLORS.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0, 100, 0, 22)
            valLbl.Position = UDim2.new(1, -112, 0, 6)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(defaultVal)
            valLbl.TextColor3 = COLORS.cyan
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 13
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = frame

            if desc ~= "" then
                local descLbl = Instance.new("TextLabel")
                descLbl.Size = UDim2.new(1, -20, 0, 16)
                descLbl.Position = UDim2.new(0, 12, 0, 26)
                descLbl.BackgroundTransparency = 1
                descLbl.Text = desc
                descLbl.TextColor3 = COLORS.textMuted
                descLbl.Font = Enum.Font.Gotham
                descLbl.TextSize = 11
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Parent = frame
            end

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -24, 0, 8)
            track.Position = UDim2.new(0, 12, 1, -16)
            track.BackgroundColor3 = COLORS.surface
            track.BackgroundTransparency = 0.18
            track.BorderSizePixel = 0
            track.Parent = frame

            local trCorner = Instance.new("UICorner")
            trCorner.CornerRadius = UDim.new(1, 0)
            trCorner.Parent = track

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(math.clamp((defaultVal - min) / (max - min), 0, 1), 0, 1, 0)
            fill.BackgroundColor3 = COLORS.primary
            fill.BorderSizePixel = 0
            fill.Parent = track

            local flCorner = Instance.new("UICorner")
            flCorner.CornerRadius = UDim.new(1, 0)
            flCorner.Parent = fill

            local OptionObj = { Value = defaultVal, ChangedCallbacks = {} }

            local function updateSlider(val)
                val = math.clamp(val, min, max)
                OptionObj.Value = val
                valLbl.Text = (sCfg.Rounding and sCfg.Rounding > 0) and string.format("%." .. tostring(sCfg.Rounding) .. "f", val) or tostring(math.floor(val))
                fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                for _, cb in ipairs(OptionObj.ChangedCallbacks) do
                    task.spawn(cb, val)
                end
            end

            function OptionObj:OnChanged(cb)
                table.insert(OptionObj.ChangedCallbacks, cb)
                return { Disconnect = function() table.remove(OptionObj.ChangedCallbacks, table.find(OptionObj.ChangedCallbacks, cb)) end }
            end

            function OptionObj:SetValue(val)
                updateSlider(val)
            end

            local isDragging = false
            local function move(input)
                local pos = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                local newFraction = math.clamp(pos, 0, 1)
                local val = min + (max - min) * newFraction
                updateSlider(val)
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    playClickSound()
                    move(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    move(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)

            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        function TabObj:AddDropdown(id, dCfg)
            if type(id) == "table" and not dCfg then
                dCfg = id
                id = dCfg.Id or dCfg.Title or "Dropdown"
            end
            local title = dCfg.Title or id
            local desc = dCfg.Desc or dCfg.Description or ""
            local values = dCfg.Values or {}
            local isMulti = dCfg.Multi or false
            local defaultVal = dCfg.Default or (isMulti and {} or (values[1] or ""))

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, desc ~= "" and 60 or 48)
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
            lbl.Size = UDim2.new(1, -200, 0, 22)
            lbl.Position = UDim2.new(0, 12, 0, desc ~= "" and 6 or 13)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = COLORS.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            if desc ~= "" then
                local descLbl = Instance.new("TextLabel")
                descLbl.Size = UDim2.new(1, -200, 0, 16)
                descLbl.Position = UDim2.new(0, 12, 0, 28)
                descLbl.BackgroundTransparency = 1
                descLbl.Text = desc
                descLbl.TextColor3 = COLORS.textMuted
                descLbl.Font = Enum.Font.Gotham
                descLbl.TextSize = 11
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Parent = frame
            end

            local dropBtn = Instance.new("TextButton")
            dropBtn.Size = UDim2.new(0, 170, 0, 32)
            dropBtn.Position = UDim2.new(1, -182, 0.5, -16)
            dropBtn.BackgroundColor3 = COLORS.input
            dropBtn.BackgroundTransparency = 0.20
            dropBtn.Text = ""
            dropBtn.Parent = frame

            local dbCorner = Instance.new("UICorner")
            dbCorner.CornerRadius = UDim.new(0, 6)
            dbCorner.Parent = dropBtn

            local dbStroke = Instance.new("UIStroke")
            dbStroke.Color = COLORS.surfaceRaised
            dbStroke.Thickness = 1
            dbStroke.Parent = dropBtn

            local dropText = Instance.new("TextLabel")
            dropText.Size = UDim2.new(1, -28, 1, 0)
            dropText.Position = UDim2.new(0, 10, 0, 0)
            dropText.BackgroundTransparency = 1
            dropText.TextColor3 = COLORS.text
            dropText.Font = Enum.Font.GothamBold
            dropText.TextSize = 13
            dropText.TextXAlignment = Enum.TextXAlignment.Left
            dropText.TextTruncate = Enum.TextTruncate.AtEnd
            dropText.Parent = dropBtn

            local dropIcon = Instance.new("TextLabel")
            dropIcon.Size = UDim2.new(0, 20, 1, 0)
            dropIcon.Position = UDim2.new(1, -24, 0, 0)
            dropIcon.BackgroundTransparency = 1
            dropIcon.Text = "▼"
            dropIcon.TextColor3 = COLORS.primary
            dropIcon.Font = Enum.Font.GothamBold
            dropIcon.TextSize = 10
            dropIcon.Parent = dropBtn

            local OptionObj = { Value = defaultVal, Values = values, ChangedCallbacks = {} }

            local function formatValText(val)
                if isMulti then
                    local selectedList = {}
                    if type(val) == "table" then
                        for k, v in pairs(val) do
                            if v == true then table.insert(selectedList, tostring(k)) end
                        end
                    end
                    if #selectedList == 0 then return "None Selected" end
                    return table.concat(selectedList, ", ")
                else
                    return tostring(val ~= "" and val or "Select Item")
                end
            end

            local function updateDropdown(val)
                OptionObj.Value = val
                dropText.Text = formatValText(val)
                for _, cb in ipairs(OptionObj.ChangedCallbacks) do
                    task.spawn(cb, val)
                end
            end

            dropText.Text = formatValText(defaultVal)

            function OptionObj:OnChanged(cb)
                table.insert(OptionObj.ChangedCallbacks, cb)
                return { Disconnect = function() table.remove(OptionObj.ChangedCallbacks, table.find(OptionObj.ChangedCallbacks, cb)) end }
            end

            function OptionObj:SetValue(val)
                updateDropdown(val)
            end

            function OptionObj:SetValues(newVals)
                OptionObj.Values = newVals
                values = newVals
                if not isMulti and #newVals > 0 then
                    dropText.Text = formatValText(OptionObj.Value)
                end
            end

            dropBtn.MouseButton1Click:Connect(function()
                playClickSound()
                
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
                modalOverlay.BackgroundTransparency = 0.45
                modalOverlay.ZIndex = 999999
                modalOverlay.Parent = gui

                local bgDismissBtn = Instance.new("TextButton")
                bgDismissBtn.Name = "BgDismiss"
                bgDismissBtn.Size = UDim2.fromScale(1, 1)
                bgDismissBtn.BackgroundTransparency = 1
                bgDismissBtn.Text = ""
                bgDismissBtn.ZIndex = 999999
                bgDismissBtn.Parent = modalOverlay
                bgDismissBtn.MouseButton1Click:Connect(function()
                    playClickSound()
                    modalOverlay:Destroy()
                end)

                local modalFrame = Instance.new("Frame")
                modalFrame.Size = UDim2.fromOffset(360, 420)
                modalFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                modalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                modalFrame.BackgroundColor3 = COLORS.shell
                modalFrame.BackgroundTransparency = 0.15
                modalFrame.BorderSizePixel = 0
                modalFrame.ZIndex = 1000000
                modalFrame.Parent = modalOverlay

                local mfCorner = Instance.new("UICorner")
                mfCorner.CornerRadius = UDim.new(0, 16)
                mfCorner.Parent = modalFrame

                local mfStroke = Instance.new("UIStroke")
                mfStroke.Color = COLORS.cyan
                mfStroke.Thickness = 1.5
                mfStroke.Parent = modalFrame

                local mTitle = Instance.new("TextLabel")
                mTitle.Size = UDim2.new(1, -60, 0, 36)
                mTitle.Position = UDim2.new(0, 16, 0, 8)
                mTitle.BackgroundTransparency = 1
                mTitle.Text = title
                mTitle.TextColor3 = COLORS.text
                mTitle.Font = Enum.Font.GothamBold
                mTitle.TextSize = 15
                mTitle.TextXAlignment = Enum.TextXAlignment.Left
                mTitle.ZIndex = 1000001
                mTitle.Parent = modalFrame

                local closeBtn = Instance.new("TextButton")
                closeBtn.Size = UDim2.fromOffset(28, 28)
                closeBtn.Position = UDim2.new(1, -36, 0, 12)
                closeBtn.BackgroundColor3 = COLORS.glass
                closeBtn.BackgroundTransparency = 0.20
                closeBtn.Text = "X"
                closeBtn.TextColor3 = COLORS.textMuted
                closeBtn.Font = Enum.Font.GothamBold
                closeBtn.TextSize = 13
                closeBtn.ZIndex = 1000001
                closeBtn.Parent = modalFrame

                local cCorner = Instance.new("UICorner")
                cCorner.CornerRadius = UDim.new(0, 8)
                cCorner.Parent = closeBtn

                closeBtn.MouseButton1Click:Connect(function()
                    playClickSound()
                    modalOverlay:Destroy()
                end)

                -- 🔍 REAL-TIME DROPDOWN SEARCH INPUT BAR
                local searchBox = Instance.new("TextBox")
                searchBox.Name = "DropdownSearchBox"
                searchBox.Size = UDim2.new(1, -24, 0, 32)
                searchBox.Position = UDim2.new(0, 12, 0, 46)
                searchBox.BackgroundColor3 = COLORS.input
                searchBox.BackgroundTransparency = 0.20
                searchBox.PlaceholderText = "🔍 ค้นหา (Search)..."
                searchBox.PlaceholderColor3 = COLORS.textMuted
                searchBox.Text = ""
                searchBox.TextColor3 = COLORS.cyan
                searchBox.Font = Enum.Font.GothamBold
                searchBox.TextSize = 12
                searchBox.ClearTextOnFocus = false
                searchBox.ZIndex = 1000001
                searchBox.Parent = modalFrame

                local sbCorner = Instance.new("UICorner")
                sbCorner.CornerRadius = UDim.new(0, 8)
                sbCorner.Parent = searchBox

                local sbStroke = Instance.new("UIStroke")
                sbStroke.Color = COLORS.surfaceRaised
                sbStroke.Thickness = 1
                sbStroke.Parent = searchBox

                local itemScroll = Instance.new("ScrollingFrame")
                itemScroll.Size = UDim2.new(1, -24, 1, -92)
                itemScroll.Position = UDim2.new(0, 12, 0, 84)
                itemScroll.BackgroundTransparency = 1
                itemScroll.ScrollBarThickness = 4
                itemScroll.ScrollBarImageColor3 = COLORS.cyan
                itemScroll.ZIndex = 1000001
                itemScroll.Parent = modalFrame

                local iLayout = Instance.new("UIListLayout")
                iLayout.Padding = UDim.new(0, 6)
                iLayout.SortOrder = Enum.SortOrder.LayoutOrder
                iLayout.Parent = itemScroll

                iLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    itemScroll.CanvasSize = UDim2.new(0, 0, 0, iLayout.AbsoluteContentSize.Y + 10)
                end)

                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local query = searchBox.Text:lower():match("^%s*(.-)%s*$") or ""
                    for _, child in ipairs(itemScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            local rawName = child:GetAttribute("ItemName") or ""
                            if query == "" or rawName:lower():find(query, 1, true) then
                                child.Visible = true
                            else
                                child.Visible = false
                            end
                        end
                    end
                end)

                local currentValues = (type(OptionObj.Values) == "function" and OptionObj.Values()) or OptionObj.Values or values
                if type(currentValues) ~= "table" then currentValues = {} end

                for _, itemVal in ipairs(currentValues) do
                    local itemStr = tostring(itemVal)
                    local isSelected = false
                    if isMulti then
                        isSelected = (type(OptionObj.Value) == "table" and OptionObj.Value[itemStr] == true)
                    else
                        isSelected = (OptionObj.Value == itemStr)
                    end

                    local itemBtn = Instance.new("TextButton")
                    itemBtn.Name = "Item_" .. itemStr
                    itemBtn:SetAttribute("ItemName", itemStr)
                    itemBtn.Size = UDim2.new(1, -8, 0, 36)
                    itemBtn.BackgroundColor3 = isSelected and COLORS.primary or COLORS.glassDeep
                    itemBtn.BackgroundTransparency = 0.18
                    itemBtn.Text = (isMulti and (isSelected and "  [✓] " or "  [  ] ") or "  • ") .. itemStr
                    itemBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or COLORS.text
                    itemBtn.Font = Enum.Font.GothamBold
                    itemBtn.TextSize = 13
                    itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                    itemBtn.ZIndex = 1000002
                    itemBtn.Parent = itemScroll

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
                            if type(OptionObj.Value) ~= "table" then OptionObj.Value = {} end
                            OptionObj.Value[itemStr] = not OptionObj.Value[itemStr]
                            updateDropdown(OptionObj.Value)
                            isSelected = OptionObj.Value[itemStr]
                            itemBtn.BackgroundColor3 = isSelected and COLORS.primary or COLORS.glassDeep
                            itemBtn.Text = (isSelected and "  [✓] " or "  [  ] ") .. itemStr
                            ibStroke.Color = isSelected and COLORS.primary or COLORS.surfaceRaised
                        else
                            updateDropdown(itemStr)
                            modalOverlay:Destroy()
                        end
                    end)
                end
            end)

            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        function TabObj:AddButton(bCfg)
            local title = bCfg.Title or "Button"
            local desc = bCfg.Desc or bCfg.Description or ""
            local cb = bCfg.Callback or function() end

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, desc ~= "" and 54 or 42)
            btn.BackgroundColor3 = COLORS.surfaceRaised
            btn.BackgroundTransparency = 0.18
            btn.Text = ""
            btn.Parent = pageScroll

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 8)
            bCorner.Parent = btn

            local bStroke = Instance.new("UIStroke")
            bStroke.Color = COLORS.primary
            bStroke.Thickness = 1.5
            bStroke.Parent = btn

            local bTitle = Instance.new("TextLabel")
            bTitle.Size = UDim2.new(1, -24, 0, 22)
            bTitle.Position = UDim2.new(0, 12, 0, desc ~= "" and 6 or 10)
            bTitle.BackgroundTransparency = 1
            bTitle.Text = title
            bTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            bTitle.Font = Enum.Font.GothamBold
            bTitle.TextSize = 14
            bTitle.TextXAlignment = Enum.TextXAlignment.Left
            bTitle.Parent = btn

            if desc ~= "" then
                local bDesc = Instance.new("TextLabel")
                bDesc.Size = UDim2.new(1, -24, 0, 18)
                bDesc.Position = UDim2.new(0, 12, 0, 26)
                bDesc.BackgroundTransparency = 1
                bDesc.Text = desc
                bDesc.TextColor3 = COLORS.textMuted
                bDesc.Font = Enum.Font.Gotham
                bDesc.TextSize = 11
                bDesc.TextXAlignment = Enum.TextXAlignment.Left
                bDesc.Parent = btn
            end

            btn.MouseButton1Click:Connect(function()
                playClickSound()
                task.spawn(cb)
            end)
            return btn
        end

        function TabObj:AddInput(id, iCfg)
            local title = iCfg.Title or id
            local desc = iCfg.Desc or iCfg.Description or ""
            local defaultVal = iCfg.Default or ""
            local placeholder = iCfg.Placeholder or "Type here..."

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, desc ~= "" and 60 or 48)
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
            lbl.Size = UDim2.new(1, -200, 0, 22)
            lbl.Position = UDim2.new(0, 12, 0, desc ~= "" and 6 or 13)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = COLORS.text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            if desc ~= "" then
                local descLbl = Instance.new("TextLabel")
                descLbl.Size = UDim2.new(1, -200, 0, 16)
                descLbl.Position = UDim2.new(0, 12, 0, 28)
                descLbl.BackgroundTransparency = 1
                descLbl.Text = desc
                descLbl.TextColor3 = COLORS.textMuted
                descLbl.Font = Enum.Font.Gotham
                descLbl.TextSize = 11
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Parent = frame
            end

            local inputBox = Instance.new("TextBox")
            inputBox.Size = UDim2.new(0, 170, 0, 32)
            inputBox.Position = UDim2.new(1, -182, 0.5, -16)
            inputBox.BackgroundColor3 = COLORS.input
            inputBox.BackgroundTransparency = 0.20
            inputBox.Text = defaultVal
            inputBox.PlaceholderText = placeholder
            inputBox.TextColor3 = COLORS.cyan
            inputBox.Font = Enum.Font.GothamBold
            inputBox.TextSize = 13
            inputBox.ClearTextOnFocus = false
            inputBox.Parent = frame

            local ibCorner = Instance.new("UICorner")
            ibCorner.CornerRadius = UDim.new(0, 6)
            ibCorner.Parent = inputBox

            local ibStroke = Instance.new("UIStroke")
            ibStroke.Color = COLORS.surfaceRaised
            ibStroke.Thickness = 1
            ibStroke.Parent = inputBox

            local OptionObj = { Value = defaultVal, ChangedCallbacks = {} }

            local function updateInput(val)
                OptionObj.Value = val
                inputBox.Text = val
                for _, cb in ipairs(OptionObj.ChangedCallbacks) do
                    task.spawn(cb, val)
                end
            end

            function OptionObj:OnChanged(cb)
                table.insert(OptionObj.ChangedCallbacks, cb)
                return { Disconnect = function() table.remove(OptionObj.ChangedCallbacks, table.find(OptionObj.ChangedCallbacks, cb)) end }
            end

            function OptionObj:SetValue(val)
                updateInput(val)
            end

            inputBox.FocusLost:Connect(function()
                updateInput(inputBox.Text)
            end)

            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

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

        function TabObj:AddParagraph(pCfg)
            local title = pCfg.Title or ""
            local desc = pCfg.Desc or pCfg.Description or ""

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
        if WindowObj.Tabs[idx] and WindowObj.Tabs[idx].Select then
            WindowObj.Tabs[idx].Select()
        end
    end

    function WindowObj:Minimize()
        playClickSound()
        shell.Visible = not shell.Visible
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.K then
            playClickSound()
            shell.Visible = not shell.Visible
        elseif input.KeyCode == Enum.KeyCode.F then
            playClickSound()
            uiScale.Scale = (uiScale.Scale == 1.0) and 0.85 or 1.0
        end
    end)

    return WindowObj
end

-- Fallback Mocks for legacy Fluent SaveManager / InterfaceManager calls
local SaveManager = {
    SetLibrary = function() end,
    IgnoreThemeSettings = function() end,
    SetIgnoreIndexes = function() end,
    SetFolder = function() end,
    BuildConfigSection = function() end,
    LoadAutoloadConfig = function() end,
    Save = function() end,
    Load = function() end,
}

local InterfaceManager = {
    SetLibrary = function() end,
    SetFolder = function() end,
    BuildInterfaceSection = function() end,
}

-- Logout & Credential functions defined in upper scope above CreateWindow

-- Kaitun AFK engine removed as requested

local Window = ObsidianGlassEngine:CreateWindow({
    Title = "Roll Anime to Fight! ⚔️",
    SubTitle = "by PayomboyZ HUB",
})

local Tabs = {
    Main = Window:AddTab({ Title = "หน้าหลัก", Icon = "home" }),
    AutoPlacement = Window:AddTab({ Title = "ออโต้วางยูนิต (Auto Play)", Icon = "sword" }),
    Tower = Window:AddTab({ Title = "ออโต้ทาวเวอร์ (Auto Tower)", Icon = "shield" }),
    Clone = Window:AddTab({ Title = "เครื่องโคลน (Clone Machine)", Icon = "copy" }),
    Trait = Window:AddTab({ Title = "ปรับแต่ง Trait (Trait Machine)", Icon = "sparkles" }),
    AutoSell = Window:AddTab({ Title = "ออโต้ขายยูนิต (Auto Sell)", Icon = "trash-2" }),
    Misc = Window:AddTab({ Title = "ฟังชั่นอื่นๆ (Misc)", Icon = "grid" }),
    Upgrade = Window:AddTab({ Title = "อัปเกรด (Upgrade)", Icon = "trending-up" }),
    Settings = Window:AddTab({ Title = "ตั้งค่า", Icon = "settings" })
}

local Options = ObsidianGlassEngine.Options
local isUiInitialized = false


player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local CharacterFallbackValues = {
    "Zoro", "Krillin", "Luffy", "Ussop", "Itadori", "Maki",
    "Goku", "Sakura", "Mob", "Junwoo", "Tanjiro", "Shinra",
}

local RarityFallbackValues = {
    "Common", "Rare", "Epic", "Legendary", "Mythic", "God", "Secret", "Limited",
}

local MutationFallbackValues = {
    "Normal", "Gold", "Diamond", "Demon", "Destroyer",
    "Hollow", "Slayer", "Cursed", "Astronaut",
}

local function getModule(...)
    local current = ReplicatedStorage
    for _, name in ipairs({ ... }) do
        current = current and current:FindFirstChild(name)
    end
    if current and current:IsA("ModuleScript") then
        return current
    end
    return nil
end

local function safeFindPath(root, ...)
    local current = root
    for _, name in ipairs({...}) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

-- Latency-Managed Remote Invocation Queue (Prevents network queue overflows & client freezes)
local remoteQueue = {}
local isProcessingQueue = false
local MIN_REMOTE_INTERVAL = 0.08
local MAX_REMOTE_QUEUE_SIZE = 20

local function safeFireRemote(remote, ...)
    if not remote then return end
    local args = { ... }
    if #remoteQueue >= MAX_REMOTE_QUEUE_SIZE then
        table.remove(remoteQueue, 1) -- Drop oldest remote to keep queue fast and prevent high ping
    end
    table.insert(remoteQueue, { remote = remote, args = args })

    if not isProcessingQueue then
        isProcessingQueue = true
        task.spawn(function()
            while #remoteQueue > 0 do
                local item = table.remove(remoteQueue, 1)
                if item and item.remote and item.remote.Parent then
                    pcall(function()
                        item.remote:FireServer(unpack(item.args))
                    end)
                end
                task.wait(MIN_REMOTE_INTERVAL)
            end
            isProcessingQueue = false
        end)
    end
end

local function findPrompt(root)
    if not root then return nil end
    local head = root:FindFirstChild("Head")
    local buyUI = head and head:FindFirstChild("BuyUI") or root:FindFirstChild("BuyUI")
    if buyUI then
        local prompt = buyUI:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then return prompt end
    end
    local preferredNames = { "BuyPrompt", "PlacementPrompt", "RollPrompt", "GiftPrompt", "ProximityPrompt", "Prox", "Prompt" }
    for _, name in ipairs(preferredNames) do
        local inst = root:FindFirstChild(name)
        if inst and inst:IsA("ProximityPrompt") then return inst end
    end
    return root:FindFirstChildWhichIsA("ProximityPrompt")
end

local function firePrompt(prompt)
    if not prompt then return false end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 999999
        if prompt.Enabled == false then prompt.Enabled = true end
    end)
    return pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt, 1)
            fireproximityprompt(prompt)
        end
    end)
end

local cachedPlot = nil
local function getPlotOwner(plot)
    if not plot then return nil end
    return plot:GetAttribute("OwnerUserId")
        or plot:GetAttribute("OwnerId")
        or plot:GetAttribute("Owner")
        or plot:GetAttribute("OwnerName")
        or plot:GetAttribute("Player")
        or plot:GetAttribute("UserId")
end

local function getBestPlot()
    if cachedPlot and cachedPlot.Parent then return cachedPlot end
    local plotsFolder = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("PlotsFolder")
    if not plotsFolder then return nil end

    local myUserId = player.UserId
    local myName = player.Name:lower()

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local ownerAttr = getPlotOwner(plot)
        if ownerAttr then
            local strOwner = tostring(ownerAttr):lower()
            if strOwner == tostring(myUserId) or strOwner == myName then
                cachedPlot = plot
                return plot
            end
        end

        local ownerObj = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player") or plot:FindFirstChild("OwnerUserId")
        if ownerObj then
            if ownerObj:IsA("ObjectValue") and ownerObj.Value == player then
                cachedPlot = plot
                return plot
            elseif ownerObj:IsA("StringValue") or ownerObj:IsA("IntValue") then
                local strVal = tostring(ownerObj.Value):lower()
                if strVal == tostring(myUserId) or strVal == myName then
                    cachedPlot = plot
                    return plot
                end
            end
        end
    end

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local minDist = math.huge
        local closestPlot = nil
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            local ok, pivot = pcall(function() return plot:GetPivot() end)
            if ok and pivot then
                local dist = (hrp.Position - pivot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closestPlot = plot
                end
            end
        end
        if closestPlot and minDist < 300 then
            cachedPlot = closestPlot
            return closestPlot
        end
    end

    local allPlots = plotsFolder:GetChildren()
    if #allPlots == 1 then
        cachedPlot = allPlots[1]
        return allPlots[1]
    end

    return cachedPlot
end

local function triggerEquipBest()
    pcall(function()
        local mainUi = safeFindPath(playerGui, "MainUI")
        local animesFrame = safeFindPath(playerGui, "MainUI", "Frames", "Animes")
                            or (mainUi and mainUi:FindFirstChild("Animes", true))
        local wasVisible = animesFrame and animesFrame.Visible or false

        local equipBestBtn = safeFindPath(playerGui, "MainUI", "Frames", "Animes", "Frame", "Main", "Buttons", "EquipBest", "Button")
                           or safeFindPath(playerGui, "MainUI", "Frames", "Animes", "Frame", "Main", "Buttons", "EquipBest")
                           or (mainUi and mainUi:FindFirstChild("EquipBest", true))

        if equipBestBtn then
            local btn = equipBestBtn:IsA("GuiButton") and equipBestBtn or equipBestBtn:FindFirstChildWhichIsA("GuiButton", true) or equipBestBtn
            if firesignal then
                pcall(function() firesignal(btn.MouseButton1Click) end)
                pcall(function() firesignal(btn.MouseButton1Down) end)
                pcall(function() firesignal(btn.MouseButton1Up) end)
                if btn:IsA("GuiButton") and btn.Activated then
                    pcall(function() firesignal(btn.Activated) end)
                end
            end
            if firebutton then
                pcall(function() firebutton(btn) end)
            end
        end

        task.delay(0.3, function()
            pcall(function()
                if animesFrame then
                    animesFrame.Visible = wasVisible
                end
            end)
        end)
    end)
end

local function stopFight()
    pcall(function()
        local fightStartRemote = safeFindPath(ReplicatedStorage, "Remotes", "Fight", "Start")
        if fightStartRemote then
            safeFireRemote(fightStartRemote, "Stop")
        end
    end)
    pcall(function()
        local mainUi = safeFindPath(playerGui, "MainUI")
        local stopBtn = safeFindPath(playerGui, "MainUI", "UITop", "Top", "Main", "Start", "Start")
                     or safeFindPath(playerGui, "MainUI", "UITop", "Top", "Main", "Start")
                     or (mainUi and mainUi:FindFirstChild("Start", true))
        if stopBtn then
            local btn = stopBtn:IsA("GuiButton") and stopBtn or stopBtn:FindFirstChildWhichIsA("GuiButton", true) or stopBtn
            if firesignal then
                pcall(function() firesignal(btn.MouseButton1Click) end)
                if btn:IsA("GuiButton") and btn.Activated then
                    pcall(function() firesignal(btn.Activated) end)
                end
            end
            if firebutton then
                pcall(function() firebutton(btn) end)
            end
        end
    end)
end

local isEquippingBest = false
local lastEquipBestTime = 0

local function runEquipBestSequence()
    if isEquippingBest then return end
    isEquippingBest = true
    lastEquipBestTime = tick()

    task.spawn(function()
        local doStart = Options and Options.AutoStartFight and Options.AutoStartFight.Value
        local doAutoPlay = Options and Options.AutoPlayMode and Options.AutoPlayMode.Value
        local fightStartRemote = safeFindPath(ReplicatedStorage, "Remotes", "Fight", "Start")

        -- Step 1: Stop fight first so units can be swapped safely
        stopFight()
        task.wait(0.6)

        -- Step 2: Trigger Equip Best
        triggerEquipBest()
        task.wait(0.8)

        -- Step 3: Restart fight if Auto Start or Auto Play enabled
        if (doStart or doAutoPlay) and fightStartRemote then
            if doStart then
                safeFireRemote(fightStartRemote, "Start")
                task.wait(0.3)
            end
            if doAutoPlay then
                safeFireRemote(fightStartRemote, "AutoPlay")
            end
        end

        isEquippingBest = false
    end)
end

local function selectHotbarSlot(slotIndex)
    if not slotIndex or slotIndex < 1 or slotIndex > 8 then return end

    pcall(function()
        local hotbar = safeFindPath(playerGui, "MainUI", "Hotbar") or safeFindPath(playerGui, "Hotbar")
        if hotbar then
            local slots = {}
            for _, child in ipairs(hotbar:GetChildren()) do
                if child:IsA("Frame") or child:IsA("GuiButton") or child:IsA("ImageButton") then
                    table.insert(slots, child)
                end
            end
            table.sort(slots, function(a, b)
                local numA = tonumber(a.Name:match("%d+")) or 99
                local numB = tonumber(b.Name:match("%d+")) or 99
                return numA < numB
            end)
            local targetUiSlot = slots[slotIndex]
            if targetUiSlot then
                local btn = targetUiSlot:FindFirstChildWhichIsA("GuiButton", true) or targetUiSlot
                if btn and btn:IsA("GuiButton") then
                    if firesignal then
                        pcall(function() firesignal(btn.MouseButton1Click) end)
                        pcall(function() firesignal(btn.MouseButton1Down) end)
                        pcall(function() firesignal(btn.MouseButton1Up) end)
                    elseif firebutton then
                        pcall(function() firebutton(btn) end)
                    end
                end
            end
        end
    end)

    pcall(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")
        local keyEnum = Enum.KeyCode["Key" .. tostring(slotIndex)]
        if keyEnum and VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, keyEnum, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, keyEnum, false, game)
        end
    end)
    task.wait(0.1)
end

local function equipUnitTool(tool)
    if not tool then return false end
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not humanoid then return false end

    if tool.Parent == char then
        return true
    end

    pcall(function()
        humanoid:EquipTool(tool)
    end)
    task.wait(0.15)

    if tool.Parent ~= char then
        pcall(function()
            tool.Parent = char
        end)
    end
    return tool.Parent == char
end

local function teleportToCloneMachine()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp then return false end

    local ppPart = safeFindPath(workspace, "Machines", "Clone", "PP")

    if not ppPart then
        local cloneMachine = safeFindPath(workspace, "Machines", "Clone")
                          or workspace:FindFirstChild("Clone", true)
        if cloneMachine then
            ppPart = cloneMachine:FindFirstChild("PP")
                  or cloneMachine:FindFirstChild("Tube1")
                  or cloneMachine.PrimaryPart
                  or cloneMachine:FindFirstChildWhichIsA("BasePart", true)
        end
    end

    if not ppPart then
        local machinesFolder = workspace:FindFirstChild("Machines")
        if machinesFolder then
            for _, m in ipairs(machinesFolder:GetChildren()) do
                if m.Name:lower():find("clone") then
                    ppPart = m:FindFirstChild("PP") or m:FindFirstChildWhichIsA("BasePart", true)
                    if ppPart then break end
                end
            end
        end
    end

    if ppPart and ppPart:IsA("BasePart") then
        pcall(function()
            hrp.CFrame = ppPart.CFrame * CFrame.new(0, 3, 3)
        end)
        return true
    end

    return false
end

local function getGameWave()
    local waveVal = player:FindFirstChild("leaderstats") and (player.leaderstats:FindFirstChild("🚩 Waves") or player.leaderstats:FindFirstChild("Waves") or player.leaderstats:FindFirstChild("Wave"))
    if waveVal and waveVal.Value then
        return tonumber(waveVal.Value) or 1
    end

    local waveLabel = safeFindPath(playerGui, "MainUI", "UITop", "Top", "Main", "Wave", "Frame", "TextLabel")
                   or safeFindPath(playerGui, "MainUI", "UITop", "Top", "Main", "Wave", "TextLabel")
    if waveLabel and waveLabel.Text then
        local num = waveLabel.Text:match("%d+")
        if num then return tonumber(num) end
    end

    local myPlot = getBestPlot()
    if myPlot then
        local attrWave = myPlot:GetAttribute("Wave") or myPlot:GetAttribute("CurrentWave")
        if attrWave then return tonumber(attrWave) end
    end

    return 1
end

local function getOwnInventoryUnitObjects()
    local unitList = {}
    local seen = {}

    pcall(function()
        -- 1. Direct DataService client check (Primary source of truth)
        local ok, dataServiceModule = pcall(function()
            local ds = safeFindPath(ReplicatedStorage, "Data", "DataService")
            return ds and require(ds)
        end)

        if ok and dataServiceModule and dataServiceModule.client then
            local categories = {"Inventory", "Equipped", "Cloning", "Evolution"}
            for _, cat in ipairs(categories) do
                local list = dataServiceModule.client:get(cat)
                if type(list) == "table" then
                    for _, uData in pairs(list) do
                        if type(uData) == "table" then
                            local uuid = tostring(uData.UUID or uData.CharacterId or uData.Id or "")
                            local name = tostring(uData.Name or uData.CharacterName or uData.Title or "")
                            if name ~= "" and uuid ~= "" and not seen[uuid] then
                                seen[uuid] = true
                                table.insert(unitList, {
                                    UUID = uuid,
                                    Name = name,
                                    DisplayName = name .. " [" .. uuid:sub(1, 8) .. "]",
                                    Trait = uData.Trait or uData.CurrentTrait or "None",
                                    RawData = uData,
                                })
                            end
                        end
                    end
                end
            end
        end

        -- 2. Fallback check Backpack & Character Tools
        local function checkTools(container)
            if not container then return end
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local uuid = item:GetAttribute("UUID") or item:GetAttribute("Id") or item.Name
                    local name = item.Name
                    if not seen[uuid] then
                        seen[uuid] = true
                        table.insert(unitList, {
                            UUID = uuid,
                            Name = name,
                            DisplayName = name .. " [" .. tostring(uuid):sub(1, 8) .. "]",
                            Trait = item:GetAttribute("Trait") or "None",
                            ToolInstance = item,
                        })
                    end
                end
            end
        end

        checkTools(player:FindFirstChild("Backpack"))
        checkTools(player.Character)
    end)

    return unitList
end

local function getOwnInventoryUnits()
    local unitObjects = getOwnInventoryUnitObjects()
    local unitDisplayNames = {}
    for _, u in ipairs(unitObjects) do
        table.insert(unitDisplayNames, u.DisplayName)
    end
    table.sort(unitDisplayNames)

    if #unitDisplayNames == 0 then
        for _, name in ipairs(CharacterFallbackValues) do
            table.insert(unitDisplayNames, name)
        end
    end
    return unitDisplayNames
end

local function sortedValues(set)
    local values = {}
    for value in pairs(set) do
        table.insert(values, value)
    end
    table.sort(values)
    return values
end

local function sortRarities(set)
    local values = {}
    for value in pairs(set) do
        table.insert(values, value)
    end

    local rankMap = {}
    for index, rarity in ipairs(RarityFallbackValues) do
        rankMap[rarity:lower()] = index
    end

    table.sort(values, function(a, b)
        local rankA = rankMap[tostring(a):lower()] or 999
        local rankB = rankMap[tostring(b):lower()] or 999
        if rankA ~= rankB then
            return rankA < rankB
        end
        return tostring(a) < tostring(b)
    end)

    return values
end

local function getRarityValues()
    local values = {}
    local module = getModule("Modules", "Characters", "CharactersInfo")

    if module then
        local ok, data = pcall(require, module)
        local characters = ok and type(data) == "table" and (data.Characters or data)

        if type(characters) == "table" then
            for _, character in pairs(characters) do
                if type(character) == "table" and character.Rarity ~= nil then
                    values[tostring(character.Rarity)] = true
                end
            end
        end
    end

    if not next(values) then
        for _, rarity in ipairs(RarityFallbackValues) do
            values[rarity] = true
        end
    end

    return sortRarities(values)
end

local function addWorkspaceModelName(model, values)
    if not model then return end
    local name = model.Name
    if name and name ~= "" then
        values[name:gsub("<.->", ""):match("^%s*(.-)%s*$")] = true
    end

    local head = model:FindFirstChild("Head")
    local buyUI = head and head:FindFirstChild("BuyUI") or model:FindFirstChild("BuyUI")
    if buyUI then
        local frame = buyUI:FindFirstChild("Frame")
        local nameFrame = frame and frame:FindFirstChild("Name") or buyUI:FindFirstChild("Name")
        local label = nameFrame and (nameFrame:FindFirstChild("TextLabel") or nameFrame:FindFirstChildWhichIsA("TextLabel"))
        if label and label.Text and label.Text ~= "" then
            local cleanName = label.Text:gsub("<.->", ""):match("^%s*(.-)%s*$")
            if cleanName and cleanName ~= "" then
                values[cleanName] = true
            end
        end
    end
end

local function getCharacterValues()
    local values = {}

    local function addName(name)
        if name ~= nil then
            name = tostring(name):gsub("<.->", ""):match("^%s*(.-)%s*$")
            if name and name ~= "" then
                values[name] = true
            end
        end
    end

    for _, name in ipairs(CharacterFallbackValues) do
        addName(name)
    end

    local module = getModule("Modules", "Characters", "CharactersInfo")
    if module then
        local ok, data = pcall(require, module)
        local characters = ok and type(data) == "table" and (data.Characters or data)

        if type(characters) == "table" then
            for key, character in pairs(characters) do
                if type(character) == "table" then
                    addName(character.Name or key)
                    addName(character.DisplayName)
                    addName(character.Display)
                else
                    addName(key)
                end
            end
        end
    end

    return sortedValues(values)
end

local function getMutationValues()
    local values = {}
    local module = getModule("Modules", "Shared", "MutationInfo")

    if module then
        local ok, data = pcall(require, module)
        local mutations = ok and type(data) == "table" and (data.Mutations or data)

        if type(mutations) == "table" then
            for mutationName, mutationData in pairs(mutations) do
                local name = tostring(mutationName)
                local damage = 0

                if type(mutationData) == "table" then
                    name = tostring(mutationData.Name or mutationName)
                    damage = tonumber(mutationData.Damage) or 0
                end

                values[name] = {
                    Name = name,
                    Damage = damage,
                }
            end
        end
    end

    if not next(values) then
        for index, mutation in ipairs(MutationFallbackValues) do
            values[mutation] = {
                Name = mutation,
                Damage = index - 1,
            }
        end
    end

    values.Normal = values.Normal or {
        Name = "Normal",
        Damage = -math.huge,
    }

    local ordered = {}
    for _, mutation in pairs(values) do
        table.insert(ordered, mutation)
    end

    table.sort(ordered, function(a, b)
        if a.Damage ~= b.Damage then
            return a.Damage < b.Damage
        end
        return a.Name < b.Name
    end)

    local orderedValues = {}
    for _, mutation in ipairs(ordered) do
        table.insert(orderedValues, mutation.Name)
    end

    return orderedValues
end

local RarityValues = getRarityValues()
local CharacterValues = getCharacterValues()
local MutationValues = getMutationValues()

local targetConfig = {}

local function buildTargetConfig()
    local config = {}
    local added = {}

    local function addTarget(mode, targetValue, mutation)
        local key = tostring(mode) .. "\31" .. tostring(targetValue):lower() .. "\31" .. tostring(mutation):lower()
        if not added[key] then
            added[key] = true
            table.insert(config, {
                Mode = mode,
                Value = targetValue,
                Mutation = mutation,
            })
        end
    end

    local function collectSelectedValues(selectedValues, allowedValues)
        local list = {}
        if type(selectedValues) == "table" then
            -- 1. Dictionary format: { ["Mythic"] = true, ["God"] = false }
            for _, value in ipairs(allowedValues) do
                if selectedValues[value] == true then
                    table.insert(list, value)
                end
            end
            -- 2. Case-insensitive dictionary check & Array format: { "Mythic", "God" }
            for k, v in pairs(selectedValues) do
                if type(k) == "number" and type(v) == "string" and v ~= "" then
                    if not table.find(list, v) then
                        table.insert(list, v)
                    end
                elseif type(k) == "string" and v == true then
                    if not table.find(list, k) then
                        table.insert(list, k)
                    end
                end
            end
        end
        return list
    end

    local function addSelectedTargets(mode, selectedValues, selectedMutations)
        local sourceValues = (mode == "Rarity") and RarityValues or CharacterValues
        local selectedList = collectSelectedValues(selectedValues, sourceValues)
        if #selectedList == 0 then
            return
        end

        local mutations = {}
        if type(selectedMutations) == "table" then
            for _, mutation in ipairs(MutationValues) do
                if selectedMutations[mutation] == true then
                    table.insert(mutations, mutation)
                end
            end
            for k, v in pairs(selectedMutations) do
                if type(k) == "number" and type(v) == "string" and v ~= "" then
                    if not table.find(mutations, v) then
                        table.insert(mutations, v)
                    end
                elseif type(k) == "string" and v == true then
                    if not table.find(mutations, k) then
                        table.insert(mutations, k)
                    end
                end
            end
        end

        if #mutations == 0 then
            mutations = { "Normal" }
        end

        for _, value in ipairs(selectedList) do
            for _, mutation in ipairs(mutations) do
                addTarget(mode, value, mutation)
            end
        end
    end

    if Options.Rarities1 and Options.Mutations1 then
        addSelectedTargets("Rarity", Options.Rarities1.Value, Options.Mutations1.Value)
    end
    if Options.Rarities2 and Options.Mutations2 then
        addSelectedTargets("Rarity", Options.Rarities2.Value, Options.Mutations2.Value)
    end
    if Options.Names3 and Options.Mutations3 then
        addSelectedTargets("Name", Options.Names3.Value, Options.Mutations3.Value)
    end
    if Options.Names4 and Options.Mutations4 then
        addSelectedTargets("Name", Options.Names4.Value, Options.Mutations4.Value)
    end

    return config
end

local function rebuildTargetLookup()
    targetConfig = buildTargetConfig()
end

local function scanAndExecuteAutoSell()
    local selectedRarities = (Options.SellRarities and Options.SellRarities.Value) or {}
    local activeRaritySet = {}
    local hasSelectedRarity = false

    if type(selectedRarities) == "table" then
        for rarityKey, isSelected in pairs(selectedRarities) do
            if isSelected == true or (type(rarityKey) == "number" and isSelected) then
                local rName = (type(rarityKey) == "string" and rarityKey or tostring(isSelected))
                rName = rName:gsub("<.->", ""):match("^%s*(.-)%s*$")
                if rName and rName ~= "" then
                    local lowerName = rName:lower()
                    -- MANDATORY SAFETY GUARD: Never allow Secret or Limited to be auto-sold!
                    if lowerName ~= "secret" and lowerName ~= "limited" then
                        activeRaritySet[lowerName] = true
                        hasSelectedRarity = true
                    end
                end
            end
        end
    end

    -- If no valid rarity is selected in dropdown, DO NOT SEND ANY SELL REQUESTS AT ALL!
    if not hasSelectedRarity then
        return 0
    end

    local sellRemote = safeFindPath(ReplicatedStorage, "Remotes", "Characters", "Sell")
                    or safeFindPath(ReplicatedStorage, "Remotes", "Sell")
                    or ReplicatedStorage:FindFirstChild("Sell", true)

    local function getUnitRarity(unitName, inst)
        if inst then
            local attr = inst:GetAttribute("Rarity") or inst:GetAttribute("UnitRarity") or inst:GetAttribute("Tier")
            if attr and tostring(attr) ~= "" then return tostring(attr) end
        end
        if unitName then
            local cleanName = tostring(unitName):gsub("<.->", ""):match("^%s*(.-)%s*$")
            local module = getModule("Modules", "Characters", "CharactersInfo")
            if module then
                local ok, data = pcall(require, module)
                local characters = ok and type(data) == "table" and (data.Characters or data)
                if type(characters) == "table" then
                    local info = characters[cleanName]
                    if type(info) == "table" and info.Rarity then
                        return tostring(info.Rarity)
                    end
                    for k, v in pairs(characters) do
                        if tostring(k):lower() == cleanName:lower() and type(v) == "table" and v.Rarity then
                            return tostring(v.Rarity)
                        end
                    end
                end
            end
        end
        return nil
    end

    local function isUnitLocked(inst)
        if not inst then return false end
        if inst:GetAttribute("Locked") == true or inst:GetAttribute("Lock") == true or inst:GetAttribute("IsLocked") == true then
            return true
        end
        local lockImg = inst:FindFirstChild("Locked", true) or inst:FindFirstChild("LockButton", true)
        if lockImg and lockImg:IsA("GuiObject") and lockImg.Visible then
            return true
        end
        return false
    end

    local function getUnitUUID(inst)
        if not inst then return nil end
        for _, attrName in ipairs({"UUID", "Id", "UID", "UnitUUID", "CharacterUUID", "uid", "uuid"}) do
            local val = inst:GetAttribute(attrName)
            if val and type(val) == "string" and #val > 10 then
                return val
            end
        end
        for _, childName in ipairs({"UUID", "Id", "UID", "UnitUUID", "CharacterUUID", "uid", "uuid"}) do
            local child = inst:FindFirstChild(childName)
            if child and child:IsA("StringValue") and #child.Value > 10 then
                return child.Value
            end
        end
        if type(inst.Name) == "string" and inst.Name:match("%x+-%x+-%x+-%x+-%x+") then
            return inst.Name
        end
        return nil
    end

    local sellUUIDs = {}

    -- Primary: Query DataService Inventory directly for exact unit data & rarity
    pcall(function()
        local dsModule = safeFindPath(ReplicatedStorage, "Data", "DataService")
        local ds = dsModule and require(dsModule)
        if ds and ds.client then
            local inv = ds.client:get("Inventory")
            if type(inv) == "table" then
                for _, uData in pairs(inv) do
                    if type(uData) == "table" then
                        local isLocked = (uData.Locked == true or uData.IsLocked == true or uData.Lock == true)
                        local isEquipped = (uData.Equipped == true or uData.IsEquipped == true)
                        local uuid = tostring(uData.UUID or uData.CharacterId or uData.Id or "")
                        local unitName = tostring(uData.Name or uData.CharacterName or uData.Title or "")
                        local rarity = tostring(uData.Rarity or uData.Tier or getUnitRarity(unitName, nil) or "")

                        if not isLocked and not isEquipped and uuid ~= "" and rarity ~= "" then
                            local lowerR = rarity:lower()
                            if lowerR ~= "secret" and lowerR ~= "limited" and activeRaritySet[lowerR] then
                                table.insert(sellUUIDs, uuid)
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Fallback GUI / Backpack scan if DataService was not available or returned no items
    if #sellUUIDs == 0 then
        local seenUUIDs = {}
        local invSlots = safeFindPath(playerGui, "MainUI", "Frames", "Animes", "Frame", "Main", "ScrollingFrame")
                      or safeFindPath(playerGui, "MainUI", "Frames", "Animes", "Frame", "Main", "InventorySlots")

        if invSlots then
            for _, slot in ipairs(invSlots:GetChildren()) do
                if slot:IsA("Frame") or slot:IsA("GuiObject") then
                    if slot.Name == "Template" or slot.Name:find("Layout") then continue end
                    if isUnitLocked(slot) then continue end

                    local eqLabel = slot:FindFirstChild("Equipped", true) or slot:GetAttribute("Equipped")
                    if eqLabel == true or (eqLabel and eqLabel:IsA("GuiObject") and eqLabel.Visible) then
                        continue
                    end

                    local nameLabel = safeFindPath(slot, "Frame", "Info", "AnimeName")
                                   or slot:FindFirstChild("AnimeName", true)
                                   or slot:FindFirstChild("Title", true)
                                   or slot:FindFirstChild("UnitName", true)
                    local unitName = nameLabel and nameLabel.Text or slot.Name
                    local rarity = getUnitRarity(unitName, slot)

                    if rarity then
                        local lowerR = rarity:lower()
                        if lowerR ~= "secret" and lowerR ~= "limited" and activeRaritySet[lowerR] then
                            local uuid = getUnitUUID(slot)
                            if uuid and not seenUUIDs[uuid] then
                                seenUUIDs[uuid] = true
                                table.insert(sellUUIDs, uuid)
                            end
                        end
                    end
                end
            end
        end

        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Parent ~= player.Character then
                    if not isUnitLocked(tool) then
                        local rarity = getUnitRarity(tool.Name, tool)
                        if rarity then
                            local lowerR = rarity:lower()
                            if lowerR ~= "secret" and lowerR ~= "limited" and activeRaritySet[lowerR] then
                                local uuid = getUnitUUID(tool)
                                if uuid and not seenUUIDs[uuid] then
                                    seenUUIDs[uuid] = true
                                    table.insert(sellUUIDs, uuid)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if #sellUUIDs == 0 then
        return 0
    end

    -- Step 1: Remove units from Hotbar if they are currently set in hotbar slots
    local updateHotbarRemote = safeFindPath(ReplicatedStorage, "Remotes", "Characters", "UpdateInventory")
    if updateHotbarRemote then
        for _, uuid in ipairs(sellUUIDs) do
            pcall(function()
                safeFireRemote(updateHotbarRemote, "ToggleHotbar", uuid)
            end)
        end
    end

    -- Step 2: Execute Sell Remote (Format: FireServer({ uuid1, uuid2, ... }))
    local sellRemote = safeFindPath(ReplicatedStorage, "Remotes", "Characters", "Sell")
                    or safeFindPath(ReplicatedStorage, "Remotes", "Sell")
                    or ReplicatedStorage:FindFirstChild("Sell", true)

    if sellRemote then
        safeFireRemote(sellRemote, sellUUIDs)
    end

    return #sellUUIDs
end

-- ===== FLUENT UI COMPONENTS =====

Tabs.Main:AddSection("ระบบออโต้หลัก (Main Auto)")

local AutoBuyPlot = Tabs.Main:AddToggle("AutoBuyPlot", {
    Title = "Auto Roll/Buy",
    Description = "ออโต้โรลและซื้อ",
    Default = false,
})

local RollDelaySlider = Tabs.Main:AddSlider("RollDelay", {
    Title = "Roll Delay",
    Description = "ดีเลย์การสุ่ม (วินาที) [ค่าเริ่มต้น 2 วินาที]",
    Default = 2.0,
    Min = 0.5,
    Max = 10.0,
    Rounding = 1,
})

Tabs.Main:AddSection("Select Unit Type Rarity")

local Rarities1 = Tabs.Main:AddDropdown("Rarities1", {
    Title = "Rarity 1",
    Description = "เลือกระดับที่ต้องการ 1",
    Values = RarityValues,
    Multi = true,
    Default = {},
})

local Mutations1 = Tabs.Main:AddDropdown("Mutations1", {
    Title = "Mutation 1",
    Description = "เลือกบัพที่ต้องการ 1",
    Values = MutationValues,
    Multi = true,
    Default = {},
})

local Rarities2 = Tabs.Main:AddDropdown("Rarities2", {
    Title = "Rarity 2",
    Description = "เลือกระดับที่ต้องการ 2",
    Values = RarityValues,
    Multi = true,
    Default = {},
})

local Mutations2 = Tabs.Main:AddDropdown("Mutations2", {
    Title = "Mutation 2",
    Description = "เลือกบัพที่ต้องการ 2",
    Values = MutationValues,
    Multi = true,
    Default = {},
})

Tabs.Main:AddSection("Select Unit Type Name")

local Names3 = Tabs.Main:AddDropdown("Names3", {
    Title = "Name 1",
    Description = "เลือกชื่อที่ต้องการ 1",
    Values = CharacterValues,
    Multi = true,
    Default = {},
})

local Mutations3 = Tabs.Main:AddDropdown("Mutations3", {
    Title = "Mutation 1",
    Description = "เลือกบัพที่ต้องการ 1",
    Values = MutationValues,
    Multi = true,
    Default = {},
})

local Names4 = Tabs.Main:AddDropdown("Names4", {
    Title = "Name 2",
    Description = "เลือกชื่อที่ต้องการ 2",
    Values = CharacterValues,
    Multi = true,
    Default = {},
})

local Mutations4 = Tabs.Main:AddDropdown("Mutations4", {
    Title = "Mutation 2",
    Description = "เลือกบัพที่ต้องการ 2",
    Values = MutationValues,
    Multi = true,
    Default = {},
})

Rarities1:OnChanged(rebuildTargetLookup)
Mutations1:OnChanged(rebuildTargetLookup)
Rarities2:OnChanged(rebuildTargetLookup)
Mutations2:OnChanged(rebuildTargetLookup)
Names3:OnChanged(rebuildTargetLookup)
Mutations3:OnChanged(rebuildTargetLookup)
Names4:OnChanged(rebuildTargetLookup)
Mutations4:OnChanged(rebuildTargetLookup)
rebuildTargetLookup()

Tabs.Misc:AddSection("ฟังชั่นอื่นๆ (Misc)")

local AutoSpinWheel = Tabs.Misc:AddToggle("AutoSpinWheel", {
    Title = "Auto Spin Wheel",
    Description = "ออโต้วงล้อ",
    Default = false,
})

local AutoClaimBattlepass = Tabs.Misc:AddToggle("AutoClaimBattlepass", {
    Title = "Auto Claim Battlepass (Free)",
    Description = "ออโต้เคลมแบทเทิลพาส (ฟรี)",
    Default = false,
})

local AutoClaimPremiumBattlepass = Tabs.Misc:AddToggle("AutoClaimPremiumBattlepass", {
    Title = "Auto Claim Battlepass (Premium)",
    Description = "ออโต้เคลมแบทเทิลพาส (พรีเมียม)",
    Default = false,
})

Tabs.AutoSell:AddSection("ระบบออโต้ขายยูนิต (Auto Sell Units)")

local AutoSellToggle = Tabs.AutoSell:AddToggle("AutoSellToggle", {
    Title = "Auto Sell Units",
    Description = "เปิดระบบออโต้ขายยูนิตตามระดับ Rarity ที่เลือกอัตโนมัติ",
    Default = false,
})

local SellRarities = Tabs.AutoSell:AddDropdown("SellRarities", {
    Title = "เลือก Rarity ที่ต้องการขาย (Auto Sell Rarities)",
    Description = "เลือกยูนิตระดับ Rarity ที่ต้องการให้ขายทิ้ง (ไม่เลือก = ไม่ขาย)",
    Values = RarityValues,
    Multi = true,
    Default = {},
})

local AutoSellDelaySlider = Tabs.AutoSell:AddSlider("AutoSellDelay", {
    Title = "Auto Sell Delay",
    Description = "ระยะเวลาดีเลย์การตรวจเช็คเพื่อขาย (วินาที)",
    Default = 2.0,
    Min = 0.5,
    Max = 10.0,
    Rounding = 1,
})

Tabs.AutoSell:AddButton({
    Title = "กดขายยูนิตตาม Rarity ทันที (Sell Selected Rarities Now)",
    Description = "สั่งให้ระบบตรวจเช็คกระเป๋าและสั่งขายยูนิตตาม Rarity ที่เลือกทันที 1 ครั้ง",
    Callback = function()
        local count = scanAndExecuteAutoSell()
        Fluent:Notify({
            Title = "Auto Sell Units",
            Content = "ตรวจเช็คกระเป๋าและสั่งขายเรียบร้อยแล้ว (" .. tostring(count) .. " ตัว)! 💰",
            Duration = 4
        })
    end
})

Tabs.AutoSell:AddButton({
    Title = "เปิด/ปิด โหมดขายยูนิตในหน้าจอ (Toggle UI Sell Mode)",
    Description = "เปิดหรือปิดสถานะ Select Animes to Sell ในหน้าจอกระเป๋าของเกมโดยตรง",
    Callback = function()
        pcall(function()
            local animesFrame = safeFindPath(playerGui, "MainUI", "Frames", "Animes")
                             or safeFindPath(playerGui, "MainUI", "Frames", "Animes", "Frame")
            if animesFrame then
                for _, desc in ipairs(animesFrame:GetDescendants()) do
                    if (desc:IsA("ImageButton") or desc:IsA("TextButton")) and desc.Visible then
                        local n = desc.Name:lower()
                        if n:find("sell") or n:find("dollar") or n:find("toggle") then
                            if firesignal then firesignal(desc.MouseButton1Click)
                            elseif firebutton then firebutton(desc) end
                            break
                        end
                    end
                end
            end
        end)
    end
})

Tabs.Upgrade:AddSection("ระบบออโต้อัปเกรด (Auto Upgrade)")

local AutoUpgradeGold = Tabs.Upgrade:AddToggle("AutoUpgradeGold", {
    Title = "Auto Upgrade Gold",
    Description = "ออโต้อัปเกรดเพิ่มเงิน (Gold Upgrade)",
    Default = false,
})

local AutoUpgradeLuck = Tabs.Upgrade:AddToggle("AutoUpgradeLuck", {
    Title = "Auto Upgrade Luck",
    Description = "ออโต้อัปเกรดเพิ่มดวง (Luck Upgrade)",
    Default = false,
})

local AutoUpgradeSlots = Tabs.Upgrade:AddToggle("AutoUpgradeSlots", {
    Title = "Auto Upgrade Slots",
    Description = "ออโต้อัปเกรดเพิ่มช่องวางยูนิต (Slot Upgrade)",
    Default = false,
})

local AutoUpgradeInventory = Tabs.Upgrade:AddToggle("AutoUpgradeInventory", {
    Title = "Auto Upgrade Inventory",
    Description = "ออโต้อัปเกรดเพิ่มความจุกระเป๋า (Inventory Upgrade)",
    Default = false,
})

local AutoUpgradeAll = Tabs.Upgrade:AddToggle("AutoUpgradeAll", {
    Title = "Auto Upgrade All",
    Description = "ออโต้อัปเกรดทั้งหมดทุกรายการ",
    Default = false,
})

local UpgradeDelaySlider = Tabs.Upgrade:AddSlider("UpgradeDelay", {
    Title = "Upgrade Delay",
    Description = "ดีเลย์การตรวจเช็คอัปเกรด (วินาที)",
    Default = 6.0,
    Min = 2.0,
    Max = 15.0,
    Rounding = 1,
})

Tabs.AutoPlacement:AddSection("ระบบออโต้วางยูนิต & Auto Play")

local AutoSlotPlacement = Tabs.AutoPlacement:AddToggle("AutoSlotPlacement", {
    Title = "Auto Equip Best Units",
    Description = "ออโต้กด Equip Best เมื่อจบรอบ หรือทุกๆ 3 นาที (หยุดสู้แล้วเริ่มใหม่ให้)",
    Default = false,
})

AutoSlotPlacement:OnChanged(function(enabled)
    if not isUiInitialized then return end
    if enabled then
        runEquipBestSequence()
        Fluent:Notify({
            Title = "Auto Equip Best Units",
            Content = "หยุดสู้ -> กด Equip Best -> เริ่มสู้ใหม่ให้อัตโนมัติ! ⚔️",
            Duration = 3
        })
    end
end)

local AutoStartFight = Tabs.AutoPlacement:AddToggle("AutoStartFight", {
    Title = "Auto Start Fight",
    Description = "ออโต้เริ่มต่อสู้เมื่อจบแต่ละรอบ",
    Default = false,
})

AutoStartFight:OnChanged(function(enabled)
    if not isUiInitialized then return end
    if enabled then
        pcall(function()
            local fightStartRemote = safeFindPath(ReplicatedStorage, "Remotes", "Fight", "Start")
            if fightStartRemote then fightStartRemote:FireServer("Start") end
        end)
        Fluent:Notify({
            Title = "Auto Start Fight",
            Content = "เปิด Auto Start Fight เรียบร้อย ⚔️",
            Duration = 2
        })
    else
        stopFight()
        Fluent:Notify({
            Title = "Auto Start Fight",
            Content = "ปิด Auto Start Fight และสั่งหยุดการต่อสู้เรียบร้อย 🛑",
            Duration = 2
        })
    end
end)

local AutoPlayMode = Tabs.AutoPlacement:AddToggle("AutoPlayMode", {
    Title = "Auto Play Mode",
    Description = "ออโต้เปิดโหมด Auto Play ในเกม",
    Default = false,
})

AutoPlayMode:OnChanged(function(enabled)
    if not isUiInitialized then return end
    if enabled then
        pcall(function()
            local fightStartRemote = safeFindPath(ReplicatedStorage, "Remotes", "Fight", "Start")
            if fightStartRemote then fightStartRemote:FireServer("AutoPlay") end
        end)
        Fluent:Notify({
            Title = "Auto Play Mode",
            Content = "เปิดโหมด Auto Play เรียบร้อย 🎮",
            Duration = 2
        })
    else
        stopFight()
        Fluent:Notify({
            Title = "Auto Play Mode",
            Content = "ปิด Auto Play Mode และสั่งหยุดการต่อสู้เรียบร้อย 🛑",
            Duration = 2
        })
    end
end)

Tabs.AutoPlacement:AddButton({
    Title = "กดใช้ Equip Best ทันที (Equip Best Now)",
    Description = "กดใช้คำสั่ง Equip Best ใส่ยูนิตที่ดีที่สุดทันที 1 ครั้ง",
    Callback = function()
        triggerEquipBest()
        Fluent:Notify({
            Title = "Auto Equip Best",
            Content = "ส่งคำสั่ง Equip Best เรียบร้อยแล้ว! ⚔️",
            Duration = 3
        })
    end
})

Tabs.AutoPlacement:AddButton({
    Title = "หยุดการต่อสู้ทันที (Stop Fight Now)",
    Description = "ส่งคำสั่ง Stop เพื่อหยุดการต่อสู้ในเกมทันที",
    Callback = function()
        stopFight()
        Fluent:Notify({
            Title = "Auto Play",
            Content = "ส่งคำสั่งหยุดการต่อสู้ (Stop) เรียบร้อยแล้ว! 🛑",
            Duration = 3
        })
    end
})

Tabs.Tower:AddSection("ระบบออโต้ทาวเวอร์ (Auto Tower System)")

local AutoJoinTower = Tabs.Tower:AddToggle("AutoJoinTower", {
    Title = "Auto Join Tower",
    Description = "ออโต้ส่งคำสั่งเข้าทาวเวอร์ (Join Tower) อัตโนมัติ",
    Default = false,
})

Tabs.Tower:AddButton({
    Title = "เข้าทาวเวอร์ทันที (Join Tower Now)",
    Description = "ส่งคำสั่งเข้าทาวเวอร์ทันที 1 ครั้ง",
    Callback = function()
        local towerRemote = safeFindPath(ReplicatedStorage, "Remotes", "JoinTower")
        if towerRemote then
            pcall(function() towerRemote:FireServer() end)
            Fluent:Notify({
                Title = "Auto Tower",
                Content = "ส่งคำสั่ง Join Tower เรียบร้อยแล้ว! 🏰",
                Duration = 3
            })
        end
    end
})

Tabs.Tower:AddSection("ระบบซื้อตั๋วทาวเวอร์อัตโนมัติ (Auto Buy Infinite Ticket)")

local AutoBuyTicket = Tabs.Tower:AddToggle("AutoBuyTicket", {
    Title = "Auto Buy Infinite Ticket",
    Description = "ออโต้เช็คและสั่งซื้อตั๋ว Infinite Ticket หากจำนวนตั๋วในตัวน้อยกว่าขั้นต่ำที่กำหนด",
    Default = false,
})

local TicketMinThreshold = Tabs.Tower:AddDropdown("TicketMinThreshold", {
    Title = "จำนวนตั๋วขั้นต่ำที่ต้องการให้มีในตัว (Minimum Ticket Amount)",
    Description = "หากตั๋ว Infinite Ticket ในตัวน้อยกว่าจำนวนนี้ ระบบจะสั่งซื้อตั๋วเพิ่มให้อัตโนมัติ",
    Values = {"1", "3", "5", "10", "20", "50", "100"},
    Default = "5",
})

Tabs.Tower:AddButton({
    Title = "ซื้อตั๋วทาวเวอร์ 1 ใบ (Buy 1 Ticket Now)",
    Description = "ส่งคำสั่งซื้อตั๋ว Infinite Ticket 1 ใบ ทันที",
    Callback = function()
        local talkRemote = safeFindPath(ReplicatedStorage, "Remotes", "NPCEvents", "TalkTickets")
        if talkRemote then
            safeFireRemote(talkRemote, "BuyOne")
            Fluent:Notify({
                Title = "Infinite Ticket",
                Content = "ส่งคำสั่งซื้อตั๋ว 1 ใบ เรียบร้อยแล้ว! 🎫",
                Duration = 3
            })
        end
    end
})

Tabs.Clone:AddSection("ระบบเครื่องโคลนยูนิต (Clone Machine System)")

local initialUnits = getOwnInventoryUnits()

local function equipAndSelectCloneUnit(selectedDisplayName)
    if not selectedDisplayName or selectedDisplayName == "" then return end

    pcall(function()
        local unitObj = nil
        local unitUUID = nil
        local allObjects = getOwnInventoryUnitObjects()

        for _, u in ipairs(allObjects) do
            if u.DisplayName == selectedDisplayName or u.Name == selectedDisplayName then
                unitObj = u
                unitUUID = u.UUID
                break
            end
        end

        -- 1. Hold / Equip tool in player's hands
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local backpack = player:FindFirstChild("Backpack")

        if humanoid then
            local toolToEquip = nil
            if unitObj and unitObj.ToolInstance then
                toolToEquip = unitObj.ToolInstance
            elseif backpack then
                local baseName = selectedDisplayName:gsub("%s*%[[^%]]+%]","")
                toolToEquip = backpack:FindFirstChild(baseName) or backpack:FindFirstChild(selectedDisplayName)
            end

            if toolToEquip and toolToEquip:IsA("Tool") and toolToEquip.Parent ~= char then
                humanoid:EquipTool(toolToEquip)
            end
        end

        -- 2. Notify Game Remote of selected unit for Clone Machine
        local cloneRemote = safeFindPath(ReplicatedStorage, "Remotes", "CloneRemotes", "Request")
                         or safeFindPath(ReplicatedStorage, "Remotes", "Clone", "Request")

        if cloneRemote and unitUUID then
            safeFireRemote(cloneRemote, "Select", { UUID = unitUUID, CharacterId = unitUUID })
            safeFireRemote(cloneRemote, "Start", { UUID = unitUUID, CharacterId = unitUUID })
            safeFireRemote(cloneRemote, "Equip", { UUID = unitUUID, CharacterId = unitUUID })
            safeFireRemote(cloneRemote, "SetUnit", { UUID = unitUUID, CharacterId = unitUUID })
        end
    end)
end

local SelectCloneUnit = Tabs.Clone:AddDropdown("SelectCloneUnit", {
    Title = "เลือกยูนิตที่จะโคลน (Select Clone Unit)",
    Description = "เลือกตัวละครจากในกระเป๋าของคุณเท่านั้น",
    Values = initialUnits,
    Default = initialUnits[1] or "",
})

SelectCloneUnit:OnChanged(function(selected)
    equipAndSelectCloneUnit(selected)
end)

Tabs.Clone:AddButton({
    Title = "รีเฟรชรายชื่อยูนิตในกระเป๋า (Refresh Inventory Units)",
    Description = "อัปเดตรายชื่อตัวละครที่มีอยู่ในกระเป๋าจริง",
    Callback = function()
        local currentUnits = getOwnInventoryUnits()
        SelectCloneUnit:SetValues(currentUnits)
        if #currentUnits > 0 then
            SelectCloneUnit:SetValue(currentUnits[1])
        end
    end
})

local AutoClone = Tabs.Clone:AddToggle("AutoClone", {
    Title = "Auto Clone Machine",
    Description = "ออโต้โคลนตัวละครที่เลือกอัตโนมัติเมื่อเครื่องพร้อม",
    Default = false,
})

local AutoCloneHalfTime = Tabs.Clone:AddToggle("AutoCloneHalfTime", {
    Title = "Auto -50% Time",
    Description = "ออโต้กดปุ่มลดเวลาโคลนลง 50% อัตโนมัติ",
    Default = false,
})

Tabs.Clone:AddButton({
    Title = "วาร์ปไปเครื่องโคลน (Teleport to Clone Machine)",
    Description = "วาร์ปตัวละครไปยังหน้าเครื่องโคลนยูนิตทันที",
    Callback = function()
        local ok = teleportToCloneMachine()
        if ok then
            Fluent:Notify({
                Title = "เครื่องโคลน (Clone Machine)",
                Content = "วาร์ปไปหน้าเครื่องโคลนสำเร็จ! ✨",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "แจ้งเตือน",
                Content = "ไม่พบตำแหน่งเครื่องโคลนยูนิต!",
                Duration = 3
            })
        end
    end
})

Tabs.Trait:AddSection("ระบบสุ่ม & ล็อค Trait (Trait Machine)")

local TraitValues = {
    "Viking", "Cursed", "Superior", "Ghost", "Cloner",
    "Reaper", "Entrepreneur", "Royal", "Lethal", "Juggernaut",
    "Deadeye", "Powerful", "Rush", "Deadly", "Strong", "Swift"
}

local initialTraitUnits = getOwnInventoryUnits()

local function equipAndSelectTraitUnit(selectedDisplayName)
    if not selectedDisplayName or selectedDisplayName == "" then return end

    pcall(function()
        local unitObj = nil
        local unitUUID = nil
        local allObjects = getOwnInventoryUnitObjects()

        for _, u in ipairs(allObjects) do
            if u.DisplayName == selectedDisplayName or u.Name == selectedDisplayName then
                unitObj = u
                unitUUID = u.UUID
                break
            end
        end

        -- 1. Hold / Equip tool in player's hands
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local backpack = player:FindFirstChild("Backpack")

        if humanoid then
            local toolToEquip = nil
            if unitObj and unitObj.ToolInstance then
                toolToEquip = unitObj.ToolInstance
            elseif backpack then
                local baseName = selectedDisplayName:gsub("%s*%[[^%]]+%]","")
                toolToEquip = backpack:FindFirstChild(baseName) or backpack:FindFirstChild(selectedDisplayName)
            end

            if toolToEquip and toolToEquip:IsA("Tool") and toolToEquip.Parent ~= char then
                humanoid:EquipTool(toolToEquip)
            end
        end

        -- 2. Notify Game Remote of selected unit
        local traitRemote = safeFindPath(ReplicatedStorage, "Remotes", "Trait", "Request")
                         or safeFindPath(ReplicatedStorage, "Remotes", "Trait", "Roll")
                         or safeFindPath(ReplicatedStorage, "Remotes", "Trait", "Select")

        if traitRemote and unitUUID then
            safeFireRemote(traitRemote, "Select", { UUID = unitUUID })
            safeFireRemote(traitRemote, "Equip", { UUID = unitUUID })
            safeFireRemote(traitRemote, "Change", { UUID = unitUUID })
            safeFireRemote(traitRemote, "SetUnit", { UUID = unitUUID })
        end
    end)
end

local SelectTraitUnit = Tabs.Trait:AddDropdown("SelectTraitUnit", {
    Title = "เลือกตัวละครจากกระเป๋า (Select Trait Unit)",
    Description = "เลือกตัวละครจากในกระเป๋าเพื่อสุ่ม Trait",
    Values = initialTraitUnits,
    Default = initialTraitUnits[1] or "",
})

SelectTraitUnit:OnChanged(function(selected)
    equipAndSelectTraitUnit(selected)
end)

Tabs.Trait:AddButton({
    Title = "รีเฟรชรายชื่อยูนิตในกระเป๋า (Refresh Inventory Units)",
    Description = "อัปเดตรายชื่อตัวละครที่มีอยู่ในกระเป๋าจริง",
    Callback = function()
        local currentUnits = getOwnInventoryUnits()
        SelectTraitUnit:SetValues(currentUnits)
        if #currentUnits > 0 then
            SelectTraitUnit:SetValue(currentUnits[1])
        end
        Fluent:Notify({
            Title = "Trait Machine",
            Content = "อัปเดตรายชื่อตัวละครเรียบร้อย (" .. tostring(#currentUnits) .. " ตัว)",
            Duration = 3
        })
    end
})

Tabs.Trait:AddSection("ตั้งค่า Trait ที่ต้องการล็อค/เป้าหมาย (Target Trait Locks)")

local TargetTraitLocks = Tabs.Trait:AddDropdown("TargetTraitLocks", {
    Title = "เลือก Trait ที่ต้องการล็อค (Select Target Trait Locks)",
    Description = "เลือก Trait ที่ต้องการ (เมื่อสุ่มได้แล้วจะหยุดสุ่มให้อัตโนมัติ)",
    Values = TraitValues,
    Multi = true,
    Default = {},
})

TargetTraitLocks:OnChanged(function(selected)
    if not isUiInitialized then return end
    pcall(function()
        local settingsRemote = safeFindPath(ReplicatedStorage, "Remotes", "Settings")
        if settingsRemote and type(selected) == "table" then
            for traitName, isSelected in pairs(selected) do
                if isSelected then
                    safeFireRemote(settingsRemote, "TraitLock", traitName)
                end
            end
        end
    end)
end)

local AutoRollTrait = Tabs.Trait:AddToggle("AutoRollTrait", {
    Title = "Auto Roll Trait Machine",
    Description = "ออโต้สุ่ม Trait สำหรับตัวละครที่เลือก (จะหยุดเมื่อได้ Trait ที่ล็อค)",
    Default = false,
})

AutoRollTrait:OnChanged(function(enabled)
    if enabled then
        pcall(function()
            local machine = safeFindPath(workspace, "Machines", "Trait")
                         or safeFindPath(workspace, "Machines", "Traits")
                         or workspace:FindFirstChild("Trait", true)
                         or workspace:FindFirstChild("Traits", true)
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if machine and hrp then
                local targetCFrame = machine:IsA("Model") and machine:GetPivot() or (machine:IsA("BasePart") and machine.CFrame or CFrame.new(machine.Position))
                hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
                Fluent:Notify({
                    Title = "Trait Machine",
                    Content = "วาร์ปไปหน้าเครื่อง Trait Machine เรียบร้อย! ✨",
                    Duration = 3
                })
            end
        end)
    end
end)

local TraitRollDelay = Tabs.Trait:AddSlider("TraitRollDelay", {
    Title = "ความเร็วในการสุ่ม (Roll Delay)",
    Description = "ดีเลย์การกดสุ่ม Trait (วินาที)",
    Default = 0.5,
    Min = 0.2,
    Max = 3.0,
    Rounding = 1,
})

Tabs.Trait:AddButton({
    Title = "วาร์ปไปเครื่อง Trait Machine (Teleport)",
    Description = "วาร์ปตัวละครไปยังหน้าเครื่องสุ่ม Trait ทันที",
    Callback = function()
        pcall(function()
            local machine = safeFindPath(workspace, "Machines", "Trait")
                         or safeFindPath(workspace, "Machines", "Traits")
                         or workspace:FindFirstChild("Trait", true)
                         or workspace:FindFirstChild("Traits", true)
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if machine and hrp then
                local targetCFrame = machine:IsA("Model") and machine:GetPivot() or (machine:IsA("BasePart") and machine.CFrame or CFrame.new(machine.Position))
                hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
                Fluent:Notify({
                    Title = "Trait Machine",
                    Content = "วาร์ปไปหน้าเครื่อง Trait Machine สำเร็จ! ✨",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "แจ้งเตือน",
                    Content = "ไม่พบตำแหน่งเครื่อง Trait Machine ในแมพ!",
                    Duration = 3
                })
            end
        end)
    end
})

Tabs.Settings:AddSection("การควบคุม & ปุ่มคีย์ลัด (Controls & Hotkeys)")

Tabs.Settings:AddParagraph({
    Title = "⌨️ ปุ่มคีย์ลัดในเกม (Keyboard Shortcuts)",
    Description = "• กด [ K ] : เพื่อซ่อน / แสดง หน้าต่างเมนูสคริปต์ (Toggle UI Window)\n• กด [ F ] : เพื่อสลับขนาดหน้าต่าง UI ระหว่าง 85% กับ 100%",
})

Tabs.Settings:AddSection("ระบบปรับขนาดหน้าจอ UI (UI Scaling)")

local UIScaleSlider = Tabs.Settings:AddSlider("UIScaleSlider", {
    Title = "ปรับขนาดหน้าต่าง UI (UI Scale)",
    Description = "ปรับย่อ/ขยายขนาดเมนูหลักตามความต้องการ",
    Default = 1.0,
    Min = 0.7,
    Max = 1.2,
    Rounding = 2,
})

UIScaleSlider:OnChanged(function(val)
    if uiScale then
        uiScale.Scale = tonumber(val) or 1.0
    end
end)

Tabs.Settings:AddSection("ระบบเซิร์ฟเวอร์ & การเชื่อมต่อ (Server Options)")

Tabs.Settings:AddButton({
    Title = "รีเซิร์ฟเวอร์เดิม (Rejoin Current Server)",
    Description = "โหลดกลับเข้าเซิร์ฟเวอร์เดิมใหม่อัตโนมัติ",
    Callback = function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end)
    end
})

Tabs.Settings:AddButton({
    Title = "ย้ายเซิร์ฟเวอร์ใหม่ (Server Hop)",
    Description = "ค้นหาและย้ายไปยังเซิร์ฟเวอร์อื่นทันที",
    Callback = function()
        pcall(function()
            local raw = game:HttpGet("https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/0?sortOrder=Asc&limit=100")
            local data = HttpService:JSONDecode(raw)
            if data and data.data then
                for _, s in ipairs(data.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player)
                        break
                    end
                end
            end
        end)
    end
})

Tabs.Settings:AddSection("ระบบ Anti-AFK & ความปลอดภัย (Security)")

Tabs.Settings:AddParagraph({
    Title = "🛡️ ระบบป้องกันหลุด AFK (Anti-AFK Active)",
    Description = "ระบบจับการเคลื่อนไหวอัตโนมัติ ป้องกันเกมเตะออกเมื่อเปิดทิ้งไว้นานกว่า 20 นาที",
})

Tabs.Settings:AddSection("ข้อมูลสคริปต์ (Script Information)")

Tabs.Settings:AddParagraph({
    Title = "Roll Anime to Fight! ⚔️ (PayomboyZ HUB)",
    Description = "• Version: v2.5 OBSIDIAN\n• UI Engine: Obsidian Glassmorphic 2 Engine\n• Developer: PayomboyZ HUB Studio",
})

Window:SelectTab(1)
rebuildTargetLookup()

task.delay(0.5, function()
    isUiInitialized = true
end)

Fluent:Notify({
    Title = "PayomboyZ HUB",
    Content = "โหลด Obsidian Glassmorphic 2 UI สำเร็จแล้ว! ❤️",
    Duration = 5
})

-- ===== BACKGROUND AUTOMATION THREADS (NON-BLOCKING & THROTTLED) =====

local function parseMoney(text)
    text = tostring(text or ""):lower()
    if text:find("free", 1, true) then return 0 end
    local numberText, suffix = text:match("([%d,%.]+)%s*([kmbtq]?)")
    if not numberText then return nil end
    local value = tonumber((numberText:gsub(",", "")))
    if not value then return nil end
    local scale = { k = 1e3, m = 1e6, b = 1e9, t = 1e12, q = 1e15 }
    return value * (scale[suffix] or 1)
end

local cashLabel = nil
local lastCashSearch = 0
local function readCash()
    if not cashLabel or not cashLabel.Parent then
        if tick() - lastCashSearch > 5 then
            lastCashSearch = tick()
            cashLabel = safeFindPath(playerGui, "MainUI", "UILeft", "TopButtons", "Cash", "CashLabel")
                     or safeFindPath(playerGui, "MainUI", "TopButtons", "Cash", "CashLabel")
                     or safeFindPath(playerGui, "MainUI", "UILeft", "Cash", "CashLabel")
                     or safeFindPath(playerGui, "MainUI", "CashLabel")
                     or safeFindPath(playerGui, "CashLabel")
        end
    end
    if cashLabel and cashLabel:IsA("TextLabel") then
        local val = parseMoney(cashLabel.Text)
        if val then return val end
    end
    return math.huge
end

local function parseStatValue(text)
    if not text then return 0 end
    text = tostring(text):gsub("<.->", ""):gsub(",", "")
    local num = text:match("([%d%.]+)")
    return tonumber(num) or 0
end

local function getUnitPower(model)
    if not model then return 0 end

    -- 1. Direct attributes check
    local atk = model:GetAttribute("Attack") or model:GetAttribute("Atk") or model:GetAttribute("Damage")
    local def = model:GetAttribute("Defense") or model:GetAttribute("Def")
    local hp = model:GetAttribute("Health") or model:GetAttribute("Hp") or model:GetAttribute("HP")
    local power = model:GetAttribute("Power") or model:GetAttribute("StatPower")

    if power and tonumber(power) then return tonumber(power) end

    if atk and tonumber(atk) then
        local nAtk = tonumber(atk) or 0
        local nDef = tonumber(def) or 1
        local nHp = tonumber(hp) or 1
        return nAtk * (nDef > 0 and nDef or 1) * (nHp > 0 and nHp or 1)
    end

    -- 2. Check Head.PlaceUI
    local head = model:FindFirstChild("Head")
    local placeUI = head and head:FindFirstChild("PlaceUI")
    if placeUI then
        local buffs = placeUI:FindFirstChild("Buffs") or placeUI:FindFirstChild("Frame")
        local atkFrame = buffs and (buffs:FindFirstChild("Attack") or buffs:FindFirstChild("Atk"))
        local atkText = atkFrame and atkFrame:FindFirstChild("Text") and atkFrame.Text.Text

        local defFrame = buffs and (buffs:FindFirstChild("Defense") or buffs:FindFirstChild("Def"))
        local defText = defFrame and defFrame:FindFirstChild("Text") and defFrame.Text.Text

        local hpFrame = placeUI:FindFirstChild("HPBar", true)
        local hpText = hpFrame and hpFrame:FindFirstChild("TextLabel") and hpFrame.TextLabel.Text

        local nAtk = parseStatValue(atkText)
        local nDef = parseStatValue(defText)
        if nDef <= 0 then nDef = 1 end
        local nHp = parseStatValue(hpText)
        if nHp <= 0 then nHp = 1 end

        if nAtk > 0 then
            return nAtk * nDef * nHp
        end
    end

    -- 3. Fallback to Tool / Model name
    return 100
end

local function isGamePlaying(plot)
    -- 1. Check UI Button (Most Direct Indicator: "STOP" vs "START")
    local startFrame = safeFindPath(playerGui, "MainUI", "UITop", "Top", "Main", "Start")
    if startFrame then
        local textLabel = safeFindPath(startFrame, "Frame", "TextLabel")
                       or startFrame:FindFirstChild("TextLabel", true)
        if textLabel and textLabel.Text and textLabel.Text ~= "" then
            local txt = textLabel.Text:upper()
            if txt:find("STOP") or txt:find("PAUSE") then
                return true
            elseif txt:find("START") or txt:find("PLAY") then
                return false
            end
        end
        local redGradient = safeFindPath(startFrame, "Frame", "Color", "Red")
                         or startFrame:FindFirstChild("Red", true)
        if redGradient and redGradient:IsA("UIGradient") and redGradient.Enabled then
            return true
        end
    end

    -- 2. Check Plot Attributes & Enemies
    if plot then
        local playing = plot:GetAttribute("Playing") or plot:GetAttribute("Fighting") or plot:GetAttribute("InBattle") or plot:GetAttribute("State")
        if playing == true or playing == "Fighting" or playing == "Playing" or playing == "InBattle" then
            return true
        end

        local enemiesFolder = plot:FindFirstChild("EnemiesSlots") or plot:FindFirstChild("Enemies")
        if enemiesFolder then
            for _, child in ipairs(enemiesFolder:GetChildren()) do
                if child:FindFirstChild("Character") or child:FindFirstChildWhichIsA("Humanoid") then
                    return true
                end
            end
        end
    end

    return false
end

-- Dedicated PlayEnd & Round State Event Watcher
task.spawn(function()
    task.wait(1)
    local startFrame = safeFindPath(playerGui, "MainUI", "UITop", "Top", "Main", "Start")
    local textLabel = startFrame and (safeFindPath(startFrame, "Frame", "TextLabel") or startFrame:FindFirstChild("TextLabel", true))

    if textLabel then
        textLabel:GetPropertyChangedSignal("Text"):Connect(function()
            local txt = textLabel.Text:upper()
            -- When text changes to START/PLAY, it indicates PlayEnd (round finished / lost / won)
            if txt:find("START") or txt:find("PLAY") then
                if isUiInitialized and Options and Options.AutoSlotPlacement and Options.AutoSlotPlacement.Value then
                    task.delay(0.3, function()
                        runEquipBestSequence()
                    end)
                end
            end
        end)
    end

    -- Remote Event PlayEnd Listener
    local fightStartRemote = safeFindPath(ReplicatedStorage, "Remotes", "Fight", "Start")
    if fightStartRemote and fightStartRemote:IsA("RemoteEvent") then
        pcall(function()
            fightStartRemote.OnClientEvent:Connect(function(action, ...)
                if action == "End" or action == "PlayEnd" or action == "Stop" or action == "Win" or action == "Defeat" then
                    if isUiInitialized and Options and Options.AutoSlotPlacement and Options.AutoSlotPlacement.Value then
                        task.delay(0.3, function()
                            runEquipBestSequence()
                        end)
                    end
                end
            end)
        end)
    end
end)

-- Helper function to check current Infinite Ticket count from inventory
local function getInfiniteTicketCount()
    local ticketCount = 0
    pcall(function()
        -- 1. Direct DataService client check (Primary source of truth)
        local ok, dataServiceModule = pcall(function()
            local ds = safeFindPath(ReplicatedStorage, "Data", "DataService")
            return ds and require(ds)
        end)

        if ok and dataServiceModule and dataServiceModule.client then
            local items = dataServiceModule.client:get("Items")
            if type(items) == "table" then
                for _, itemData in pairs(items) do
                    if type(itemData) == "table" then
                        local itemName = tostring(itemData.Name or itemData.Title or "")
                        if itemName:lower():find("infinite") or itemName:lower():find("ticket") then
                            local amt = tonumber(itemData.amount or itemData.Amount or itemData.Quantity or itemData.Quanity) or 1
                            ticketCount += amt
                        end
                    end
                end
            end
        end

        -- 2. Fallback check Backpack
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item.Name:lower():find("infinite") or item.Name:lower():find("ticket") then
                    local count = item:GetAttribute("Amount") or item:GetAttribute("Count") or tonumber(item.Name:match("%d+")) or 1
                    ticketCount = math.max(ticketCount, count)
                end
            end
        end

        -- 3. Fallback check Inventory GUI (Items Frame)
        local itemSlots = safeFindPath(playerGui, "MainUI", "Frames", "Items", "Frame", "Main", "ScrollingFrame")
                       or safeFindPath(playerGui, "MainUI", "Frames", "Items", "ScrollingFrame")
        if itemSlots then
            for _, slot in ipairs(itemSlots:GetChildren()) do
                if slot:IsA("GuiObject") then
                    local nameLabel = safeFindPath(slot, "ItemName") or safeFindPath(slot, "Frame", "Info", "ItemName") or slot:FindFirstChild("Name")
                    if nameLabel and nameLabel:IsA("TextLabel") and nameLabel.Text:lower():find("infinite") then
                        local amountLabel = safeFindPath(slot, "Amount") or safeFindPath(slot, "Frame", "Amount") or slot:FindFirstChild("TextLabel")
                        if amountLabel and amountLabel:IsA("TextLabel") then
                            local num = tonumber(amountLabel.Text:match("%d+"))
                            if num then ticketCount = math.max(ticketCount, num) end
                        end
                    end
                end
            end
        end
    end)
    return ticketCount
end

-- Throttled Auto Tower & Auto Buy Ticket Thread
task.spawn(function()
    task.wait(1.0)
    local lastTicketCheck = 0
    local lastJoinTower = 0

    while task.wait(1.5) do
        local currentPlaceId = game.PlaceId
        local isLobby = (currentPlaceId == 107653945083776)

        -- 1. Auto Join Tower (Only in Lobby Map, with 10s cooldown to prevent Error 279 rate limit disconnects)
        local doTower = Options.AutoJoinTower and Options.AutoJoinTower.Value
        if doTower and isLobby and (tick() - lastJoinTower > 10) then
            local joinTowerRemote = safeFindPath(ReplicatedStorage, "Remotes", "JoinTower")
            if joinTowerRemote then
                lastJoinTower = tick()
                safeFireRemote(joinTowerRemote)
            end
        end

        -- 2. Auto Buy Infinite Ticket (Only in Lobby Map, spaced safely to prevent disconnect)
        local doBuyTicket = Options.AutoBuyTicket and Options.AutoBuyTicket.Value
        if doBuyTicket and isLobby and (tick() - lastTicketCheck > 4) then
            lastTicketCheck = tick()
            local minThreshold = tonumber(Options.TicketMinThreshold and Options.TicketMinThreshold.Value) or 5
            local currentTickets = getInfiniteTicketCount()

            if currentTickets < minThreshold then
                local needed = minThreshold - currentTickets
                local talkRemote = safeFindPath(ReplicatedStorage, "Remotes", "NPCEvents", "TalkTickets")

                if talkRemote then
                    while needed > 0 do
                        if needed >= 5 then
                            safeFireRemote(talkRemote, "BuyFive")
                            needed -= 5
                        elseif needed >= 3 then
                            safeFireRemote(talkRemote, "BuyThree")
                            needed -= 3
                        else
                            safeFireRemote(talkRemote, "BuyOne")
                            needed -= 1
                        end
                        task.wait(0.6)
                    end
                end
            end
        end
    end
end)

-- Throttled Auto Placement & Fight Start Thread (Equip Best & Auto Start logic)
task.spawn(function()
    local lastWave = 1
    local wasPlaying = false

    while task.wait(1.0) do
        local doStart = Options.AutoStartFight and Options.AutoStartFight.Value
        local doAutoPlay = Options.AutoPlayMode and Options.AutoPlayMode.Value
        local doPlace = Options.AutoSlotPlacement and Options.AutoSlotPlacement.Value

        if not (doStart or doAutoPlay or doPlace) then
            continue
        end

        local fightStartRemote = safeFindPath(ReplicatedStorage, "Remotes", "Fight", "Start")
        local myPlot = getBestPlot()
        local currentWave = getGameWave()
        local playing = myPlot and isGamePlaying(myPlot) or false

        -- Detect Round end conditions:
        local waveResetTo1 = (lastWave > 1 and currentWave == 1)
        local roundEnded = (wasPlaying and not playing) or waveResetTo1
        wasPlaying = playing
        lastWave = currentWave

        -- Timer condition for Equip Best: 3 minutes (180 seconds)
        local timeSinceLastEquip = tick() - lastEquipBestTime
        local is3MinutesPassed = (lastEquipBestTime > 0 and timeSinceLastEquip >= 180)

        if doPlace and not isEquippingBest and (roundEnded or is3MinutesPassed) then
            runEquipBestSequence()
        elseif roundEnded and not isEquippingBest and doStart then
            if fightStartRemote then
                safeFireRemote(fightStartRemote, "Start")
            end
        end
    end
end)



-- Helper to check if Clone Machine is currently busy cloning a unit
local function isCloneMachineBusy()
    local busy = false
    -- 1. Check DataService client "Cloning" state
    pcall(function()
        local dsModule = safeFindPath(ReplicatedStorage, "Data", "DataService")
        local ds = dsModule and require(dsModule)
        if ds and ds.client then
            local cloning = ds.client:get("Cloning")
            if type(cloning) == "table" and (cloning.UUID or cloning.Id or cloning.CharacterId or cloning.Time) then
                busy = true
            end
        end
    end)
    if busy then return true end

    -- 2. Check workspace Machine attributes & TextLabels
    pcall(function()
        local cloneMachine = safeFindPath(workspace, "Machines", "Clone")
                          or safeFindPath(workspace, "Machines", "Cloning")
                          or workspace:FindFirstChild("Clone", true)
        if cloneMachine then
            if cloneMachine:GetAttribute("Cloning") == true 
            or cloneMachine:GetAttribute("IsCloning") == true 
            or cloneMachine:GetAttribute("Busy") == true then
                busy = true
                return
            end

            for _, desc in ipairs(cloneMachine:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text then
                    local txt = desc.Text:lower()
                    if txt:find(":") or txt:find("cloning") or txt:find("remaining") then
                        if txt:match("%d+:%d+") or txt:match("%d+s") then
                            busy = true
                            return
                        end
                    end
                end
            end
        end
    end)
    if busy then return true end

    -- 3. Check UI TextLabels
    pcall(function()
        local cloneFrame = safeFindPath(playerGui, "MainUI", "Frames", "Clone")
        if cloneFrame then
            local timeLabel = safeFindPath(cloneFrame, "Frame", "Main", "Timer")
                           or safeFindPath(cloneFrame, "Frame", "Main", "Time")
                           or cloneFrame:FindFirstChild("Timer", true)
            if timeLabel and timeLabel:IsA("TextLabel") and timeLabel.Text then
                if timeLabel.Text:match("%d+:%d+") or timeLabel.Text:lower():find("cloning") then
                    busy = true
                    return
                end
            end
        end
    end)

    return busy
end

-- Direct Remote Auto Clone Machine Thread (No Walking / Teleport Required)
task.spawn(function()
    local lastCloneAttempt = 0

    while task.wait(3.0) do
        local doClone = Options.AutoClone and Options.AutoClone.Value
        local doHalfTime = Options.AutoCloneHalfTime and Options.AutoCloneHalfTime.Value
        local selectedUnitName = Options.SelectCloneUnit and Options.SelectCloneUnit.Value

        if not (doClone or doHalfTime) then continue end

        local cloneRemote = safeFindPath(ReplicatedStorage, "Remotes", "CloneRemotes", "Request")
                         or safeFindPath(ReplicatedStorage, "Remotes", "Clone", "Request")
                         or safeFindPath(ReplicatedStorage, "Remotes", "Clone", "Start")

        -- Check HalfTime reduction if active
        if doHalfTime then
            if cloneRemote then
                safeFireRemote(cloneRemote, "HalfTime")
                safeFireRemote(cloneRemote, "TimerHalf")
            end
            local cloneFrame = safeFindPath(playerGui, "MainUI", "Frames", "Clone", "Frame", "Main")
            if cloneFrame then
                local halfBtn = safeFindPath(cloneFrame, "Buttons", "TimerHalf", "Button")
                             or safeFindPath(cloneFrame, "Buttons", "TimerHalf")
                if halfBtn then
                    pcall(function()
                        if firesignal then firesignal(halfBtn.MouseButton1Click)
                        elseif firebutton then firebutton(halfBtn) end
                    end)
                end
            end
        end

        -- Check if clone machine is already busy/running
        if isCloneMachineBusy() then
            continue
        end

        -- Clone Machine is idle! Fire clone start remote ONCE
        if doClone and selectedUnitName and (tick() - lastCloneAttempt > 5) then
            local targetUUID = nil
            local allObjects = getOwnInventoryUnitObjects()
            for _, uObj in ipairs(allObjects) do
                if uObj.DisplayName == selectedUnitName or uObj.Name == selectedUnitName then
                    targetUUID = uObj.UUID
                    break
                end
            end

            if targetUUID then
                lastCloneAttempt = tick()
                if cloneRemote then
                    safeFireRemote(cloneRemote, "Start", {
                        UUID = targetUUID,
                        CharacterId = targetUUID
                    })
                    safeFireRemote(cloneRemote, "Start", targetUUID)
                end

                -- Also click UI button if open
                local cloneFrame = safeFindPath(playerGui, "MainUI", "Frames", "Clone", "Frame", "Main")
                if cloneFrame then
                    local cloneBtn = safeFindPath(cloneFrame, "Buttons", "Clone", "Button")
                                  or safeFindPath(cloneFrame, "Buttons", "Clone")
                    if cloneBtn then
                        pcall(function()
                            if firesignal then firesignal(cloneBtn.MouseButton1Click)
                            elseif firebutton then firebutton(cloneBtn) end
                        end)
                    end
                end
            end
        end
    end
end)

-- Direct Remote Auto Trait Machine Thread (No Walking / Teleport Required)
task.spawn(function()
    while task.wait(0.4) do
        local doRoll = Options.AutoRollTrait and Options.AutoRollTrait.Value
        if not doRoll then continue end

        local selectedDisplayName = Options.SelectTraitUnit and Options.SelectTraitUnit.Value
        local delayVal = (Options.TraitRollDelay and Options.TraitRollDelay.Value) or 0.5

        -- Find target unit object & UUID from inventory directly
        local targetUnitObj = nil
        local targetUUID = nil

        if selectedDisplayName then
            local allObjects = getOwnInventoryUnitObjects()
            for _, uObj in ipairs(allObjects) do
                if uObj.DisplayName == selectedDisplayName or uObj.Name == selectedDisplayName then
                    targetUnitObj = uObj
                    targetUUID = uObj.UUID
                    break
                end
            end
        end

        -- Check current trait of unit to see if target lock is reached
        local targetLocks = (Options.TargetTraitLocks and Options.TargetTraitLocks.Value) or {}
        if targetUnitObj then
            local currentTrait = targetUnitObj.Trait
            if (not currentTrait or currentTrait == "None") and targetUnitObj.ToolInstance then
                currentTrait = targetUnitObj.ToolInstance:GetAttribute("Trait") or targetUnitObj.ToolInstance:GetAttribute("CurrentTrait")
            end

            local isMatched = false
            if currentTrait and currentTrait ~= "None" then
                if type(targetLocks) == "table" then
                    if targetLocks[currentTrait] == true or table.find(targetLocks, currentTrait) then
                        isMatched = true
                    end
                elseif targetLocks == currentTrait then
                    isMatched = true
                end
            end

            if isMatched then
                -- Target Trait matched! Stop auto roll & notify user
                pcall(function()
                    AutoRollTrait:SetValue(false)
                    Fluent:Notify({
                        Title = "Trait Machine Success! 🎉",
                        Content = "ได้รับ Trait ล็อคเป้าหมาย: " .. tostring(currentTrait) .. " ให้กับ " .. tostring(selectedDisplayName) .. " เรียบร้อยแล้ว!",
                        Duration = 8
                    })
                end)
                continue
            end
        end

        -- Direct Remote Fire (No physical interaction needed)
        local traitRemote = safeFindPath(ReplicatedStorage, "Remotes", "Trait", "Request")
                         or safeFindPath(ReplicatedStorage, "Remotes", "Trait", "Roll")
                         or safeFindPath(ReplicatedStorage, "Remotes", "TraitRemotes", "Request")
        if traitRemote then
            if targetUUID then
                safeFireRemote(traitRemote, "Roll", { UUID = targetUUID, CharacterId = targetUUID })
                safeFireRemote(traitRemote, "Roll", targetUUID)
            elseif targetUnitObj and targetUnitObj.ToolInstance then
                safeFireRemote(traitRemote, "Roll", targetUnitObj.ToolInstance)
            else
                safeFireRemote(traitRemote, "Roll")
            end
        end

        -- Also click ROLL button in UI if open
        pcall(function()
            local mainUi = safeFindPath(playerGui, "MainUI")
            local rollBtn = safeFindPath(playerGui, "MainUI", "Frames", "Traits", "Frame", "Main", "Buttons", "Roll", "Button")
                         or safeFindPath(playerGui, "MainUI", "Frames", "Traits", "Frame", "Main", "Buttons", "Roll")
                         or (mainUi and mainUi:FindFirstChild("Roll", true))
            if rollBtn then
                local clickable = rollBtn:IsA("GuiButton") and rollBtn or rollBtn:FindFirstChildWhichIsA("GuiButton", true) or rollBtn
                if firesignal then
                    pcall(function() firesignal(clickable.Activated) end)
                    pcall(function() firesignal(clickable.MouseButton1Click) end)
                end
                if firebutton then
                    pcall(function() firebutton(clickable) end)
                end
            end
        end)

        task.wait(delayVal)
    end
end)

task.spawn(function()
    local function valuesSignature(values) return table.concat(values, "\31") end
    local raritySignature = valuesSignature(RarityValues)
    local mutationSignature = valuesSignature(MutationValues)

    while task.wait(120) do
        local latestRarities = getRarityValues()
        local latestMutations = getMutationValues()
        local latestRaritySignature = valuesSignature(latestRarities)
        local latestMutationSignature = valuesSignature(latestMutations)

        if latestRaritySignature ~= raritySignature then
            raritySignature = latestRaritySignature
            RarityValues = latestRarities
            pcall(function()
                if Rarities1 then Rarities1:SetValues(RarityValues) end
                if Rarities2 then Rarities2:SetValues(RarityValues) end
                if SellRarities then SellRarities:SetValues(RarityValues) end
            end)
            rebuildTargetLookup()
        end

        if latestMutationSignature ~= mutationSignature then
            mutationSignature = latestMutationSignature
            MutationValues = latestMutations
            pcall(function()
                if Mutations1 then Mutations1:SetValues(MutationValues) end
                if Mutations2 then Mutations2:SetValues(MutationValues) end
                if Mutations3 then Mutations3:SetValues(MutationValues) end
                if Mutations4 then Mutations4:SetValues(MutationValues) end
            end)
            rebuildTargetLookup()
        end
    end
end)

-- Throttled Auto Spin Wheel
task.spawn(function()
    task.wait(1.5)
    while task.wait(1.5) do
        if not Options.AutoSpinWheel or not Options.AutoSpinWheel.Value then continue end

        local label = safeFindPath(playerGui, "MainUI", "Frames", "SpinWheel", "Content", "Buttons", "Spin", "Label")
        local remote = safeFindPath(ReplicatedStorage, "Remotes", "SpinWheel", "Spin")

        if label and remote then
            local text = label.Text or ""
            local count = tonumber(text:match("%((%d+)%)")) or 0
            if count > 0 then
                safeFireRemote(remote, "Spin")
                task.wait(2.5)
            end
        end
    end
end)

-- Throttled Auto Claim Battlepass (Free)
task.spawn(function()
    while task.wait(10) do
        if not Options.AutoClaimBattlepass or not Options.AutoClaimBattlepass.Value then continue end

        local rewards = safeFindPath(playerGui, "MainUI", "Frames", "Battlepass", "Frame", "Main", "Battlepass", "ScrollingFrame", "Content", "Rewards")
        local remote = safeFindPath(ReplicatedStorage, "Modules", "Battlepass", "Claim")

        if rewards and remote then
            local index = 0
            for _, reward in ipairs(rewards:GetChildren()) do
                if reward.Name == "BattlepassReward" then
                    index += 1
                    local free = reward:FindFirstChild("Free")
                    if free then
                        local locked = free:FindFirstChild("Locked")
                        local checked = free:FindFirstChild("Checked")
                        if locked and checked and locked:IsA("GuiObject") and checked:IsA("GuiObject") then
                            if locked.Visible == false and checked.Visible == false then
                                safeFireRemote(remote, index, "Free")
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Throttled Auto Claim Battlepass (Premium)
task.spawn(function()
    while task.wait(10) do
        if not Options.AutoClaimPremiumBattlepass or not Options.AutoClaimPremiumBattlepass.Value then continue end

        local rewards = safeFindPath(playerGui, "MainUI", "Frames", "Battlepass", "Frame", "Main", "Battlepass", "ScrollingFrame", "Content", "Rewards")
        local remote = safeFindPath(ReplicatedStorage, "Modules", "Battlepass", "Claim")

        if rewards and remote then
            local index = 0
            for _, reward in ipairs(rewards:GetChildren()) do
                if reward.Name == "BattlepassReward" then
                    index += 1
                    local premium = reward:FindFirstChild("Premium")
                    if premium then
                        local locked = premium:FindFirstChild("Locked")
                        local checked = premium:FindFirstChild("Checked")
                        if locked and checked and locked:IsA("GuiObject") and checked:IsA("GuiObject") then
                            if locked.Visible == false and checked.Visible == false then
                                safeFireRemote(remote, index, "Premium")
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Smart & Throttled Auto Upgrade (Gold, Luck, Slots, Inventory)
task.spawn(function()
    local upgradeRemote = nil

    local function getUpgradeRemote()
        if upgradeRemote and upgradeRemote.Parent then return upgradeRemote end
        upgradeRemote = safeFindPath(ReplicatedStorage, "Remotes", "Upgrade")
                     or ReplicatedStorage:FindFirstChild("Upgrade", true)
        return upgradeRemote
    end

    local function getUpgradePrice(category)
        local frame = safeFindPath(playerGui, "MainUI", "Frames", "Upgrade", "Frame", "Main", category)
        if frame then
            local textLabel = safeFindPath(frame, "Buttons", "Gold", "Frame", "TextLabel")
                           or safeFindPath(frame, "Buttons", "Gold", "TextLabel")
                           or frame:FindFirstChild("TextLabel", true)
            if textLabel and textLabel:IsA("TextLabel") then
                return parseMoney(textLabel.Text)
            end
        end
        return nil
    end

    while true do
        local delayTime = (Options.UpgradeDelay and tonumber(Options.UpgradeDelay.Value)) or 6.0
        task.wait(delayTime)

        local remote = getUpgradeRemote()
        if not remote then continue end

        local doGold = (Options.AutoUpgradeGold and Options.AutoUpgradeGold.Value) or (Options.AutoUpgradeAll and Options.AutoUpgradeAll.Value)
        local doLuck = (Options.AutoUpgradeLuck and Options.AutoUpgradeLuck.Value) or (Options.AutoUpgradeAll and Options.AutoUpgradeAll.Value)
        local doSlots = (Options.AutoUpgradeSlots and Options.AutoUpgradeSlots.Value) or (Options.AutoUpgradeAll and Options.AutoUpgradeAll.Value)
        local doInv = (Options.AutoUpgradeInventory and Options.AutoUpgradeInventory.Value) or (Options.AutoUpgradeAll and Options.AutoUpgradeAll.Value)

        if not (doGold or doLuck or doSlots or doInv) then continue end

        local currentCash = readCash()

        local categories = {
            { name = "Gold", enabled = doGold },
            { name = "Luck", enabled = doLuck },
            { name = "Slots", enabled = doSlots },
            { name = "Inventory", enabled = doInv },
        }

        for _, cat in ipairs(categories) do
            if cat.enabled then
                local price = getUpgradePrice(cat.name)
                -- Only fire remote if player actually has enough cash (or price is unreadable)
                if not price or currentCash >= price then
                    safeFireRemote(remote, "Gold", cat.name)
                    task.wait(0.5)
                    currentCash = readCash()
                end
            end
        end
    end
end)

-- Optimized & Throttled Auto Roll / Buy System
task.spawn(function()
    player.CharacterAdded:Connect(function(newChar)
        character = newChar
    end)

    local state = { buying = false, hasBoughtThisRoll = false }

    local function parseMoney(text)
        if not text then return 0 end
        local str = tostring(text):gsub("<.->", ""):gsub("%$", ""):gsub(",", ""):match("^%s*(.-)%s*$") or ""
        local numStr, suffix = str:match("([%d%.]+)%s*([KkMmBbTtQq]?)")
        if not numStr then return 0 end
        local num = tonumber(numStr) or 0
        if suffix then
            local s = suffix:upper()
            if s == "K" then num = num * 1000
            elseif s == "M" then num = num * 1000000
            elseif s == "B" then num = num * 1000000000
            elseif s == "T" then num = num * 1000000000000
            elseif s == "Q" then num = num * 1000000000000000
            end
        end
        return num
    end

    local function readCash()
        local cashAmount = math.huge -- Default math.huge so reading failures never block buying
        pcall(function()
            local dsModule = safeFindPath(ReplicatedStorage, "Data", "DataService")
            local ds = dsModule and require(dsModule)
            if ds and ds.client then
                local gold = ds.client:get("Gold") or ds.client:get("Yen") or ds.client:get("Cash") or ds.client:get("Coins")
                if type(gold) == "number" then
                    cashAmount = gold
                    return
                end
            end

            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                for _, name in ipairs({"Gold", "Yen", "Cash", "Coins", "Money", "💰 Gold"}) do
                    local val = leaderstats:FindFirstChild(name)
                    if val and val.Value then
                        cashAmount = tonumber(val.Value) or cashAmount
                        return
                    end
                end
            end

            local goldLabel = safeFindPath(playerGui, "MainUI", "UITop", "Top", "Main", "Gold", "Frame", "TextLabel")
                           or safeFindPath(playerGui, "MainUI", "UITop", "Top", "Main", "Gold", "TextLabel")
                           or safeFindPath(playerGui, "MainUI", "GoldText")
            if goldLabel and goldLabel:IsA("TextLabel") then
                cashAmount = parseMoney(goldLabel.Text)
                return
            end
        end)
        return cashAmount
    end

    local function firePrompt(prompt)
        if not prompt then return false end
        return pcall(function()
            if prompt:IsA("ProximityPrompt") then
                pcall(function()
                    prompt.HoldDuration = 0
                    prompt.RequiresLineOfSight = false
                    prompt.MaxActivationDistance = 9999999
                    if prompt.Enabled == false then prompt.Enabled = true end
                end)
                if fireproximityprompt then
                    fireproximityprompt(prompt, 0)
                    fireproximityprompt(prompt, 1)
                    fireproximityprompt(prompt)
                end
                pcall(function()
                    if prompt.InputHoldBegin then
                        prompt:InputHoldBegin()
                        task.wait(0.05)
                        prompt:InputHoldEnd()
                    end
                end)
            end
        end)
    end

    local function findPrompt(root)
        if not root then return nil end
        local buyUI = root:FindFirstChild("BuyUI", true)
        if buyUI then
            local prompt = buyUI:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then return prompt end
        end

        local preferredPromptNames = {
            "BuyPrompt",
            "PlacementPrompt",
            "RollPrompt",
            "GiftPrompt",
            "ProximityPrompt",
            "Prox",
            "Prompt",
        }

        for _, name in ipairs(preferredPromptNames) do
            local inst = root:FindFirstChild(name, true)
            if inst and inst:IsA("ProximityPrompt") then
                return inst
            end
        end

        return root:FindFirstChildWhichIsA("ProximityPrompt", true)
    end

    local function normalizeKey(value)
        return tostring(value or ""):lower():gsub("%s+", "")
    end

    local function getModelMutation(model)
        local ok, mutation = pcall(function() return model:GetAttribute("Mutation") end)
        if not ok or mutation == nil or tostring(mutation) == "" then
            return "Normal"
        end
        return mutation
    end

    local function getRarityLabel(model)
        local head = model:FindFirstChild("Head")
        local buyUI = head and head:FindFirstChild("BuyUI") or model:FindFirstChild("BuyUI", true)
        if buyUI then
            local frame = buyUI:FindFirstChild("Frame")
            local chance = frame and frame:FindFirstChild("Chance")
            local label = chance and chance:FindFirstChild("TextLabel")
                       or buyUI:FindFirstChildWhichIsA("TextLabel", true)
            if label then return label end
        end
        return nil
    end

    local function getModelRarity(model)
        local label = getRarityLabel(model)
        local rarity = label and tostring(label.Text or ""):gsub("<.->", ""):match("^%s*(.-)%s*$") or ""
        if rarity == "" then return nil end
        return rarity:match("^(%S+)") or rarity
    end

    local function getCharacterNameLabel(model)
        local head = model:FindFirstChild("Head")
        local buyUI = head and head:FindFirstChild("BuyUI") or model:FindFirstChild("BuyUI", true)
        if buyUI then
            local frame = buyUI:FindFirstChild("Frame")
            local nameFrame = frame and frame:FindFirstChild("Name")
            local label = nameFrame and nameFrame:FindFirstChild("TextLabel")
                       or buyUI:FindFirstChildWhichIsA("TextLabel", true)
            if label then return label end
        end
        return nil
    end

    local function getModelCharacterName(model)
        local label = getCharacterNameLabel(model)
        local characterName = label and tostring(label.Text or ""):gsub("<.->", ""):match("^%s*(.-)%s*$") or tostring(model.Name or "")
        if characterName == "" then return nil end
        return characterName
    end

    local function getModelCharacterNameAliases(model)
        local aliases = {}
        local added = {}
        local function addAlias(name)
            if name ~= nil then
                name = tostring(name):gsub("<.->", ""):match("^%s*(.-)%s*$")
                if name and name ~= "" then
                    local key = normalizeKey(name)
                    if not added[key] then
                        added[key] = true
                        table.insert(aliases, name)
                    end
                end
            end
        end
        addAlias(getModelCharacterName(model))
        addAlias(model.Name)
        return aliases
    end

    local function hasAttackAttribute(model)
        local ok, attack = pcall(function() return model:GetAttribute("Attack") end)
        return ok and attack ~= nil
    end

    local function isBoughtCharacterModel(model, scanRoot)
        if not model then return false end

        -- Guard: If model has BuyUI or any ProximityPrompt, it is NOT bought yet!
        local buyUI = model:FindFirstChild("BuyUI", true)
        local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
        if buyUI or prompt then
            return false
        end

        local current = model
        while current and current ~= scanRoot do
            if current:IsA("Model") and hasAttackAttribute(current) then
                return true
            end
            current = current.Parent
        end
        return false
    end

    local RarityRanks = {
        common = 1,
        uncommon = 2,
        rare = 3,
        epic = 4,
        legendary = 5,
        mythic = 6,
        god = 7,
        secret = 8,
        limited = 9,
    }

    local function getRarityScore(model)
        local rarityText = getModelRarity(model) or ""
        local lowerRarity = rarityText:lower()

        for key, rank in pairs(RarityRanks) do
            if lowerRarity:find(key, 1, true) then
                return rank * 1000000
            end
        end

        local chanceStr = rarityText:match("/([%d,%.]+)")
        if chanceStr then
            local num = tonumber((chanceStr:gsub(",", "")))
            if num then return num end
        end

        return 0
    end

    local function getTargetIndex(model)
        local nameAliases = getModelCharacterNameAliases(model)
        local rarity = getModelRarity(model)
        local mutation = getModelMutation(model)
        if not mutation then mutation = "Normal" end

        local normalizedMutation = normalizeKey(mutation)
        local normalizedRarity = rarity and normalizeKey(rarity) or nil
        local normalizedNames = {}

        for _, alias in ipairs(nameAliases) do
            normalizedNames[normalizeKey(alias)] = alias
        end

        if type(targetConfig) == "table" and #targetConfig > 0 then
            for index, config in ipairs(targetConfig) do
                if normalizeKey(config.Mutation) == normalizedMutation then
                    if config.Mode == "Rarity" and normalizedRarity and normalizeKey(config.Value) == normalizedRarity then
                        return index, rarity, mutation, "Rarity"
                    end

                    local matchedName = normalizedNames[normalizeKey(config.Value)]
                    if config.Mode == "Name" and matchedName then
                        return index, matchedName, mutation, "Name"
                    end
                end
            end
            return nil
        end

        -- FALLBACK: When no specific targets are selected in UI (#targetConfig == 0), buy best/most expensive unit
        local score = getRarityScore(model)
        return (1000000000 - score), rarity or "Unknown", mutation, "Best"
    end

    local function getPriceLabel(model)
        local head = model:FindFirstChild("Head")
        local buyUI = head and head:FindFirstChild("BuyUI") or model:FindFirstChild("BuyUI", true)
        if buyUI then
            local frame = buyUI:FindFirstChild("Frame")
            local price = frame and frame:FindFirstChild("Price")
            local label = price and price:FindFirstChild("TextLabel") or price and price:FindFirstChildWhichIsA("TextLabel", true)
            if label and label:IsA("TextLabel") then return label end
        end

        local fallbackBuyUI = model:FindFirstChild("BuyUI", true)
        if fallbackBuyUI then
            local price = fallbackBuyUI:FindFirstChild("Price", true)
            if price then
                local label = price:FindFirstChildWhichIsA("TextLabel", true)
                if label then return label end
            end
        end
        return nil
    end

    local function getRollPrompt(plot)
        local roll = plot:FindFirstChild("Roll")
        local button = roll and roll:FindFirstChild("RollButton")
        local buttonPart = button and button:FindFirstChild("Button")
        local prompt = buttonPart and buttonPart:FindFirstChild("RollPrompt")

        if prompt and prompt:IsA("ProximityPrompt") then
            return prompt
        end

        return plot:FindFirstChild("RollPrompt", true) or plot:FindFirstChildWhichIsA("ProximityPrompt", true)
    end

    local function getBuyCandidates(plot)
        local candidates = {}
        if not plot then return candidates end
        local scanRoots = { plot:FindFirstChild("Characters"), plot:FindFirstChild("Units"), plot }

        for _, scanRoot in ipairs(scanRoots) do
            if not scanRoot then continue end
            for _, inst in ipairs(scanRoot:GetChildren()) do
                if inst:IsA("Model") then
                    local prompt = findPrompt(inst)
                    local buyUI = inst:FindFirstChild("BuyUI", true)

                    if not prompt and not buyUI then continue end

                    if isBoughtCharacterModel(inst, scanRoot) then
                        continue
                    end

                    prompt = prompt or (buyUI and (buyUI:FindFirstChildWhichIsA("ProximityPrompt", true) or findPrompt(buyUI)))
                    if not prompt then continue end

                    local targetIndex, characterName, mutation = getTargetIndex(inst)
                    if not targetIndex then continue end

                    local priceLabel = getPriceLabel(inst)
                    local price = priceLabel and parseMoney(priceLabel.Text) or 0

                    table.insert(candidates, {
                        model = inst,
                        characterName = characterName or inst.Name,
                        mutation = mutation or "Normal",
                        targetIndex = targetIndex,
                        price = price,
                        priceLabel = priceLabel,
                        prompt = prompt,
                    })
                end
            end
            if #candidates > 0 then break end
        end

        table.sort(candidates, function(a, b)
            if a.targetIndex ~= b.targetIndex then
                return a.targetIndex < b.targetIndex
            end
            return a.price > b.price
        end)

        return candidates
    end

    state.hasBoughtThisRoll = false

    while true do
        local delayTime = (Options.RollDelay and tonumber(Options.RollDelay.Value)) or 2.7
        if delayTime < 0.5 then delayTime = 0.5 end

        if not Options.AutoBuyPlot or not Options.AutoBuyPlot.Value then
            task.wait(0.5)
            continue
        end

        local myPlot = getBestPlot()
        if not myPlot then
            task.wait(1.0)
            continue
        end

        local cycleStartTime = tick()
        local boughtOrBlocked = false

        if not state.buying then
            local candidates = getBuyCandidates(myPlot)
            local cash = readCash() or 0

            for _, candidate in ipairs(candidates) do
                if cash < candidate.price then
                    boughtOrBlocked = true
                    break
                end

                state.buying = true
                firePrompt(candidate.prompt)
                task.wait(0.75)
                state.buying = false
                boughtOrBlocked = true
                break
            end
        end

        if not state.buying and not boughtOrBlocked then
            local rollPrompt = getRollPrompt(myPlot)
            if rollPrompt then
                firePrompt(rollPrompt)
            end
        end

        local elapsed = tick() - cycleStartTime
        local sleepTime = delayTime - elapsed
        if sleepTime > 0 then
            task.wait(sleepTime)
        else
            task.wait(0.5)
        end
    end
end)

-- ===== THROTTLED AUTO SELL UNITS THREAD =====
task.spawn(function()
    while true do
        local delayVal = (Options.AutoSellDelay and tonumber(Options.AutoSellDelay.Value)) or 2.0
        task.wait(delayVal)

        if Options.AutoSellToggle and Options.AutoSellToggle.Value == true then
            pcall(scanAndExecuteAutoSell)
        end
    end
end)

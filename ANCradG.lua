-- [[ PayomboyZ - Anime Card Farm Script (Obsidian Glassmorphic 2 Engine Master Edition) ]]
-- Theme: Obsidian Glassmorphic 2 (FlowAuth Aesthetics with Left User Profile Panel)
-- Controls: [K] Toggle UI Visibility | [RightControl] Toggle UI | Mobile Floating Capsule Button

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")

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
    primary = Color3.fromRGB(255, 45, 85),          -- Crimson Red Accent
    primaryHover = Color3.fromRGB(255, 75, 110),
    primaryPressed = Color3.fromRGB(210, 30, 65),
    secondary = Color3.fromRGB(52, 18, 28),
    text = Color3.fromRGB(255, 255, 255),             -- Pure Crisp White for maximum contrast
    textMuted = Color3.fromRGB(242, 218, 228),        -- High contrast soft white-pink
    textFaint = Color3.fromRGB(210, 168, 182),        -- Clear readable pink-grey
    cyan = Color3.fromRGB(255, 55, 85),              -- Main Red Accent
    success = Color3.fromRGB(46, 224, 140),         -- Emerald Green
    warning = Color3.fromRGB(255, 185, 70),
    danger = Color3.fromRGB(255, 60, 60),
    disabled = Color3.fromRGB(50, 25, 32),
}

local ObsidianGlassEngine = { Options = {} }
local Fluent = ObsidianGlassEngine

-- ✨ FEATURE: UI Sound Effect Helper
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

-- [ระบบลบไฟล์คีย์ และล้างค่าตัวแปรในระบบ]
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

-- [ฟังก์ชันหยุดการทำงานของสคริปต์ทั้งหมด (Stop All Active Script Threads & Connections)]
local function stopAllScriptOperations()
    if _G.GakuranCleanup then pcall(_G.GakuranCleanup) end
    if _G.ScriptCleanup then pcall(_G.ScriptCleanup) end
    if _G.PayomboyZCleanup then pcall(_G.PayomboyZCleanup) end
    if deactivateAntiAfk then pcall(deactivateAntiAfk) end
    getgenv().AntiAfkState = false

    if ObsidianGlassEngine and ObsidianGlassEngine.Options then
        for _, option in pairs(ObsidianGlassEngine.Options) do
            if type(option) == "table" and option.SetValue then
                pcall(function() option:SetValue(false) end)
            end
        end
    end
end

-- 🖼️ NON-BLOCKING ASYNC AVATAR IMAGE LOADER (ป้องกัน UI ค้างบนมือถือ/UGPhone)
local customAvatarAsset = nil
local isAvatarLoading = false

local function loadCustomAvatarImage(targetImageLabel)
    local defaultThumb = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    if customAvatarAsset then
        if targetImageLabel then targetImageLabel.Image = customAvatarAsset end
        return customAvatarAsset
    end

    if targetImageLabel then targetImageLabel.Image = defaultThumb end

    if not isAvatarLoading then
        isAvatarLoading = true
        task.spawn(function()
            local avatarUrl = "https://raw.githubusercontent.com/aslamdunk7/paypmboygang/main/543199739_2812856088914181_3062917809445648175_n.jpg"
            local fileName = "payomboyz_avatar.jpg"
            
            pcall(function()
                if typeof(writefile) == "function" and (typeof(getcustomasset) == "function" or typeof(getsynasset) == "function") then
                    local getAsset = getcustomasset or getsynasset
                    local isFileExist = (typeof(isfile) == "function" and isfile(fileName))
                    if not isFileExist and typeof(game.HttpGet) == "function" then
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
                customAvatarAsset = defaultThumb
            end

            if targetImageLabel and targetImageLabel.Parent then
                targetImageLabel.Image = customAvatarAsset
            end
        end)
    end
    return defaultThumb
end

-- 🔔 TOAST NOTIFICATION ENGINE
function ObsidianGlassEngine:Notify(cfg)
    pcall(function()
        local title = cfg.Title or "PayomboyZ"
        local content = cfg.Content or ""
        local duration = cfg.Duration or 4
        
        local parentGui = (typeof(gethui) == "function") and gethui() or CoreGui
        local notifHolder = parentGui:FindFirstChild("PayomboyZ_NotifHolder")
        if not notifHolder then
            notifHolder = Instance.new("ScreenGui")
            notifHolder.Name = "PayomboyZ_NotifHolder"
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

-- 🖼️ MAIN WINDOW ENGINE
function ObsidianGlassEngine:CreateWindow(cfg)
    local parentGui = (typeof(gethui) == "function") and gethui() or CoreGui
    if parentGui:FindFirstChild("PayomboyZ_ObsidianGlassUI") then
        parentGui.PayomboyZ_ObsidianGlassUI:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "PayomboyZ_ObsidianGlassUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 99999
    gui.Parent = parentGui

    local uiScale = Instance.new("UIScale")
    
    -- 📱 AUTOMATIC MOBILE RESPONSIVE SCALING ENGINE (HANDLES CAMERA REASSIGNMENT)
    local function updateScale()
        pcall(function()
            local camera = workspace.CurrentCamera
            if camera and camera.ViewportSize and camera.ViewportSize.X > 0 and camera.ViewportSize.Y > 0 then
                local vp = camera.ViewportSize
                local targetWidth, targetHeight = 920, 600
                local scaleX = (vp.X - 40) / targetWidth
                local scaleY = (vp.Y - 40) / targetHeight
                local calcScale = math.clamp(math.min(scaleX, scaleY), 0.35, 0.85)
                uiScale.Scale = calcScale
            end
        end)
    end
    updateScale()

    pcall(function()
        if workspace.CurrentCamera then
            workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        end
        workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            if workspace.CurrentCamera then
                updateScale()
                workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
            end
        end)
    end)
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

    -- ❄️ OPTIMIZED SNOW PARTICLES ANIMATION LAYER (PAUSES WHEN HIDDEN / LOW MOBILE IMPACT)
    local snowLayer = Instance.new("Frame")
    snowLayer.Name = "SnowLayer"
    snowLayer.Size = UDim2.fromScale(1, 1)
    snowLayer.BackgroundTransparency = 1
    snowLayer.ZIndex = 2
    snowLayer.Parent = shell

    task.spawn(function()
        local isTouch = UserInputService.TouchEnabled
        -- [OPT] ลดจำนวน dot ลงครึ่งนึงเพื่อลด CPU load
        local dotCount = isTouch and 8 or 15
        local dots = {}
        for i = 1, dotCount do
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

        -- [OPT] เพิ่ม sleep interval ให้นานขึ้น (0.08s mobile, 0.06s PC) ลด CPU spike
        local sleepInterval = isTouch and 0.10 or 0.06
        while task.wait(sleepInterval) do
            if not gui or not gui.Parent then break end
            if shell and shell.Visible then
                for _, data in ipairs(dots) do
                    data.pos = data.pos + data.speed
                    if data.pos > 1.05 then data.pos = -0.05 end
                    local newX = (data.frame.Position.X.Scale + data.drift) % 1.0
                    data.frame.Position = UDim2.new(newX, 0, data.pos, 0)
                end
            end
        end
    end)

    -- 💎 UNIVERSAL DRAGGABLE TOGGLE CAPSULE WITH AVATAR, USERNAME & METRICS (FPS/PING)
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
        -- [OPT] ลด capsule snow dots เหลือ 4 ใบ
        local dots = {}
        for i = 1, 4 do
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

        -- [OPT] เพิ่ม interval เป็น 0.10s
        while task.wait(0.10) do
            if not gui or not gui.Parent or not toggleCapsule or not toggleCapsule.Parent then break end
            for _, data in ipairs(dots) do
                data.pos = data.pos + data.speed
                if data.pos > 1.05 then data.pos = -0.05 end
                local newX = (data.frame.Position.X.Scale + data.drift) % 1.0
                data.frame.Position = UDim2.new(newX, 0, data.pos, 0)
            end
        end
    end)

    -- 🖼️ AVATAR IMAGE BOX
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
    capAvatarImg.ZIndex = 4
    capAvatarImg.Parent = capAvatarFrame
    loadCustomAvatarImage(capAvatarImg)

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
    -- [OPT] ใช้ Heartbeat นับ frame แทน RenderStepped (ลด overhead), อัปเดต label ทุก 2s
    task.spawn(function()
        local frameCount = 0
        local lastFpsTime = tick()
        local fpsVal = 60

        local heartbeatConn
        heartbeatConn = RunService.Heartbeat:Connect(function()
            frameCount = frameCount + 1
            local now = tick()
            if now - lastFpsTime >= 1 then
                fpsVal = frameCount
                frameCount = 0
                lastFpsTime = now
            end
        end)

        while task.wait(2) do
            if not gui or not gui.Parent or not toggleCapsule or not toggleCapsule.Parent then
                if heartbeatConn then heartbeatConn:Disconnect() end
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
            playClickSound()
            shell.Visible = not shell.Visible
        end
    end)

    -- 👤 LEFT COLUMN: SIDEBAR (USER INFO & VERTICAL TAB NAVIGATION)
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

    -- Profile Header
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
    avatarImg.ZIndex = 11
    avatarImg.Parent = avatarFrame
    loadCustomAvatarImage(avatarImg)

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

    -- 🔴 LOGOUT BUTTON (ข้างชื่อผู้ใช้ใน UserPanel Sidebar)
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
        TweenService:Create(logoutBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.danger,
            BackgroundTransparency = 0.15
        }):Play()
        TweenService:Create(loStroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
        logoutBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    logoutBtn.MouseLeave:Connect(function()
        TweenService:Create(logoutBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.surfacePressed,
            BackgroundTransparency = 0.20
        }):Play()
        TweenService:Create(loStroke, TweenInfo.new(0.2), { Transparency = 0.4 }):Play()
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

    -- Compact Session & Ping Metrics Bar
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
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            metricsLabel.Text = string.format("⏱️ %02d:%02d  •  📡 %d ms", mins, secs, ping)
        end
    end)

    -- Divider
    local sideDiv = Instance.new("Frame")
    sideDiv.Size = UDim2.new(1, -28, 0, 1)
    sideDiv.Position = UDim2.new(0, 14, 0, 96)
    sideDiv.BackgroundColor3 = COLORS.glassRaised
    sideDiv.BorderSizePixel = 0
    sideDiv.ZIndex = 10
    sideDiv.Parent = userPanel

    -- Section Label: MODULES
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

    -- Vertical Tab Scroll Container
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

    -- Status Connected Badge at bottom left
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
    stTitle.Text = "✅ Connected to PayomboyZ"
    stTitle.TextColor3 = COLORS.success
    stTitle.Font = Enum.Font.GothamBold
    stTitle.TextSize = 12
    stTitle.Parent = statusCard

    -- 🖥️ RIGHT COLUMN: MAIN HUB PANEL
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(1, -240, 1, 0)
    mainPanel.Position = UDim2.new(0, 240, 0, 0)
    mainPanel.BackgroundTransparency = 1
    mainPanel.ZIndex = 5
    mainPanel.Parent = shell

    -- Header Bar
    local headerBar = Instance.new("Frame")
    headerBar.Size = UDim2.new(1, 0, 0, 48)
    headerBar.BackgroundTransparency = 1
    headerBar.Parent = mainPanel

    local mainTitle = Instance.new("TextLabel")
    mainTitle.Size = UDim2.new(0, 300, 0, 22)
    mainTitle.Position = UDim2.new(0, 20, 0, 8)
    mainTitle.BackgroundTransparency = 1
    mainTitle.Text = cfg.Title or "PayomboyZ Hub"
    mainTitle.TextColor3 = COLORS.text
    mainTitle.Font = Enum.Font.GothamBold
    mainTitle.TextSize = 18
    mainTitle.TextXAlignment = Enum.TextXAlignment.Left
    mainTitle.Parent = headerBar

    local mainSubTitle = Instance.new("TextLabel")
    mainSubTitle.Size = UDim2.new(0, 350, 0, 16)
    mainSubTitle.Position = UDim2.new(0, 20, 0, 28)
    mainSubTitle.BackgroundTransparency = 1
    mainSubTitle.Text = cfg.SubTitle or "โดย Dexq | Obsidian Glassmorphic 2 Engine"
    mainSubTitle.TextColor3 = COLORS.textMuted
    mainSubTitle.Font = Enum.Font.Gotham
    mainSubTitle.TextSize = 11
    mainSubTitle.TextXAlignment = Enum.TextXAlignment.Left
    mainSubTitle.Parent = headerBar

    -- Minimize & Close Buttons
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

    -- Window Dragging Handler
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

    -- Active Service Banner
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
    sTitle.Text = "PayomboyZ Studios"
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
    vText.Text = "🛡️ PAYOMBOYZ VERIFIED"
    vText.TextColor3 = COLORS.success
    vText.Font = Enum.Font.GothamBold
    vText.TextSize = 10
    vText.Parent = vBadge

    -- Content Pages Folder
    local pagesFolder = Instance.new("Frame")
    pagesFolder.Name = "PagesFolder"
    pagesFolder.Size = UDim2.new(1, -40, 1, -128)
    pagesFolder.Position = UDim2.new(0, 20, 0, 120)
    pagesFolder.BackgroundTransparency = 1
    pagesFolder.Parent = mainPanel

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil,
        Minimized = false
    }

    function WindowObj:Minimize()
        playClickSound()
        shell.Visible = not shell.Visible
    end

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
        pageScroll.Active = true
        pageScroll.ScrollingDirection = Enum.ScrollingDirection.Y
        pageScroll.ScrollBarThickness = 5
        pageScroll.ScrollBarImageColor3 = COLORS.primary
        pageScroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        pageScroll.ElasticBehavior = Enum.ElasticBehavior.Always
        pageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        pageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        pageScroll.Visible = (tabIndex == 1)
        pageScroll.Parent = pagesFolder

        local pagePadding = Instance.new("UIPadding")
        pagePadding.PaddingBottom = UDim.new(0, 80)
        pagePadding.PaddingTop = UDim.new(0, 4)
        pagePadding.PaddingLeft = UDim.new(0, 2)
        pagePadding.PaddingRight = UDim.new(0, 6)
        pagePadding.Parent = pageScroll

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = pageScroll

        local function updatePageCanvas()
            if pageScroll and pageLayout then
                pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 160)
            end
        end
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatePageCanvas)

        -- Mobile Touch Drag Scrolling Handler for Tab Content Pages (Touch Only - PC uses native mouse wheel)
        local isPageDragging = false
        local pageTouchStartY = 0
        local pageStartCanvasY = 0

        local function onPageTouchBegan(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                isPageDragging = false
                pageTouchStartY = input.Position.Y
                pageStartCanvasY = pageScroll.CanvasPosition.Y
            end
        end

        local function onPageTouchChanged(input)
            if pageTouchStartY > 0 and input.UserInputType == Enum.UserInputType.Touch then
                local deltaY = input.Position.Y - pageTouchStartY
                if math.abs(deltaY) > 4 then
                    isPageDragging = true
                end
                if isPageDragging then
                    local currentScale = (uiScale and uiScale.Scale > 0) and uiScale.Scale or 1
                    local scaledDeltaY = deltaY / currentScale
                    local maxCanvasY = math.max(0, (pageLayout.AbsoluteContentSize.Y + 160) - pageScroll.AbsoluteWindowSize.Y)
                    pageScroll.CanvasPosition = Vector2.new(0, math.clamp(pageStartCanvasY - scaledDeltaY, 0, maxCanvasY))
                end
            end
        end

        local function onPageTouchEnded(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                pageTouchStartY = 0
                task.delay(0.05, function()
                    isPageDragging = false
                end)
            end
        end

        pageScroll.InputBegan:Connect(onPageTouchBegan)
        pageScroll.InputChanged:Connect(onPageTouchChanged)
        pageScroll.InputEnded:Connect(onPageTouchEnded)

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
            local desc = tCfg.Desc or ""
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

            function OptionObj:OnChanged(cb)
                table.insert(OptionObj.ChangedCallbacks, cb)
            end

            function OptionObj:SetValue(val)
                updateToggle(val == true)
            end

            switch.MouseButton1Click:Connect(function()
                updateToggle(not OptionObj.Value)
            end)

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

            function OptionObj:OnChanged(cb)
                table.insert(OptionObj.ChangedCallbacks, cb)
            end

            function OptionObj:SetValue(val)
                updateSlider(val)
            end

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

        -- 📋 DROPDOWN WIDGET WITH FULLY RESPONSIVE MOBILE MODAL OVERLAY (SCROLLS TO THE END!)
        function TabObj:AddDropdown(id, dCfg)
            local title = dCfg.Title or id
            local values = dCfg.Values or {}
            local isMulti = dCfg.Multi == true
            local defaultVal = dCfg.Default
            if defaultVal == nil then
                defaultVal = dCfg.Value or (isMulti and {} or (values[1] or ""))
            end

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

            local function getSelectedList(val)
                local list = {}
                if type(val) == "table" then
                    for k, v in pairs(val) do
                        if type(k) == "number" then
                            if type(v) == "string" and v ~= "" and not table.find(list, v) then
                                table.insert(list, v)
                            end
                        elseif (v == true or type(v) == "table") and type(k) == "string" and k ~= "" and not table.find(list, k) then
                            table.insert(list, k)
                        end
                    end
                elseif type(val) == "string" and val ~= "" then
                    table.insert(list, val)
                end
                return list
            end

            local function formatValText(val)
                if type(val) == "table" then
                    local list = getSelectedList(val)
                    if #list == 0 then return "[ กดเพื่อเลือกรายการ ]" end
                    return table.concat(list, ", ")
                elseif type(val) == "string" and val ~= "" then
                    return val
                end
                return "[ กดเพื่อเลือกรายการ ]"
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

            function OptionObj:OnChanged(cb)
                table.insert(OptionObj.ChangedCallbacks, cb)
                pcall(function() cb(OptionObj.Value) end)
            end

            function OptionObj:SetValue(val)
                updateDropdown(val)
            end

            function OptionObj:SetValues(newVals)
                OptionObj.Values = newVals
            end

            -- POPUP OVERLAY MODAL FOR SELECTION (MOBILE TOUCH OPTIMIZED & FULLY SCROLLABLE TO END)
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
                modalOverlay.BackgroundTransparency = 0.70
                modalOverlay.Active = true
                modalOverlay.ZIndex = 999999
                modalOverlay.Parent = gui

                local bgDismissBtn = Instance.new("TextButton")
                bgDismissBtn.Size = UDim2.fromScale(1, 1)
                bgDismissBtn.BackgroundTransparency = 1
                bgDismissBtn.Text = ""
                bgDismissBtn.ZIndex = 999999
                bgDismissBtn.Parent = modalOverlay

                local cameraVP = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
                -- คำนวณ effective scale จาก viewport จริงเพื่อปรับขนาด modal บนมือถือ
                local _modalTargetW, _modalTargetH = 920, 600
                local _scaleX = (cameraVP.X - 40) / _modalTargetW
                local _scaleY = (cameraVP.Y - 40) / _modalTargetH
                local _effectiveScale = math.clamp(math.min(_scaleX, _scaleY), 0.35, 0.85)
                -- ใช้ viewport โดยตรง (modal ไม่ถูก scale โดย UIScale ของ shell)
                local maxModalH = math.clamp(cameraVP.Y * 0.75, 280, 520)
                local maxModalW = math.min(700, cameraVP.X - 20)

                local modalFrame = Instance.new("Frame")
                modalFrame.Size = UDim2.fromOffset(maxModalW, maxModalH)
                modalFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                modalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                modalFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 29)
                modalFrame.BackgroundTransparency = 0
                modalFrame.BorderSizePixel = 0
                modalFrame.ClipsDescendants = true
                modalFrame.ZIndex = 1000000
                modalFrame.Parent = modalOverlay

                local mCorner = Instance.new("UICorner")
                mCorner.CornerRadius = UDim.new(0, 14)
                mCorner.Parent = modalFrame

                local mStroke = Instance.new("UIStroke")
                mStroke.Color = COLORS.primary
                mStroke.Thickness = 2
                mStroke.Parent = modalFrame

                -- Header
                local mHeader = Instance.new("TextLabel")
                mHeader.Size = UDim2.new(1, -50, 0, 22)
                mHeader.Position = UDim2.new(0, 16, 0, 10)
                mHeader.BackgroundTransparency = 1
                mHeader.Text = "📌 " .. title
                mHeader.TextColor3 = COLORS.text
                mHeader.Font = Enum.Font.GothamBold
                mHeader.TextSize = 15
                mHeader.TextXAlignment = Enum.TextXAlignment.Left
                mHeader.ZIndex = 1000001
                mHeader.Parent = modalFrame

                local mSub = Instance.new("TextLabel")
                mSub.Size = UDim2.new(1, -50, 0, 16)
                mSub.Position = UDim2.new(0, 16, 0, 32)
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
                closeModBtn.Position = UDim2.new(1, -36, 0, 10)
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

                bgDismissBtn.MouseButton1Click:Connect(function()
                    modalOverlay:Destroy()
                end)

                -- 🔍 SEARCH FILTER INPUT BOX
                local searchFrame = Instance.new("Frame")
                searchFrame.Size = UDim2.new(1, -28, 0, 32)
                searchFrame.Position = UDim2.new(0, 14, 0, 52)
                searchFrame.BackgroundColor3 = COLORS.glassDeep
                searchFrame.BorderSizePixel = 0
                searchFrame.ZIndex = 1000001
                searchFrame.Parent = modalFrame

                local sfCorner = Instance.new("UICorner")
                sfCorner.CornerRadius = UDim.new(0, 8)
                sfCorner.Parent = searchFrame

                local sfStroke = Instance.new("UIStroke")
                sfStroke.Color = COLORS.surfaceRaised
                sfStroke.Thickness = 1
                sfStroke.Parent = searchFrame

                local searchBox = Instance.new("TextBox")
                searchBox.Size = UDim2.new(1, -16, 1, 0)
                searchBox.Position = UDim2.new(0, 10, 0, 0)
                searchBox.BackgroundTransparency = 1
                searchBox.PlaceholderText = "🔍 ค้นหารายการ..."
                searchBox.PlaceholderColor3 = COLORS.textFaint
                searchBox.Text = ""
                searchBox.TextColor3 = COLORS.text
                searchBox.Font = Enum.Font.Gotham
                searchBox.TextSize = 12
                searchBox.TextXAlignment = Enum.TextXAlignment.Left
                searchBox.ZIndex = 1000002
                searchBox.Parent = searchFrame

                -- 📜 OPTION SCROLL CONTAINER (MAXIMIZED HEIGHT & GENEROUS BOTTOM PADDING)
                local optScroll = Instance.new("ScrollingFrame")
                optScroll.Size = UDim2.new(1, -28, 1, -96)
                optScroll.Position = UDim2.new(0, 14, 0, 90)
                optScroll.BackgroundTransparency = 1
                optScroll.Active = true
                optScroll.ScrollingDirection = Enum.ScrollingDirection.Y
                optScroll.ScrollBarThickness = 6
                optScroll.ScrollBarImageColor3 = COLORS.primary
                optScroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
                optScroll.ElasticBehavior = Enum.ElasticBehavior.Always
                optScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                optScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                optScroll.ClipsDescendants = true
                optScroll.ZIndex = 1000001
                optScroll.Parent = modalFrame

                local optPadding = Instance.new("UIPadding")
                optPadding.PaddingBottom = UDim.new(0, 20)
                optPadding.PaddingTop = UDim.new(0, 2)
                optPadding.PaddingLeft = UDim.new(0, 2)
                optPadding.PaddingRight = UDim.new(0, 4)
                optPadding.Parent = optScroll

                local optLayout = Instance.new("UIListLayout")
                optLayout.Padding = UDim.new(0, 5)
                optLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optLayout.Parent = optScroll

                local optionButtons = {}

                local function updateModalCanvas()
                    if optScroll and optLayout then
                        local itemsCount = #optionButtons
                        local computedH = (itemsCount > 0) and (itemsCount * 43 + 80) or (optLayout.AbsoluteContentSize.Y + 80)
                        local finalH = math.max(computedH, optLayout.AbsoluteContentSize.Y + 80)
                        optScroll.CanvasSize = UDim2.new(0, 0, 0, finalH)
                    end
                end
                optLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateModalCanvas)

                -- Mobile & Touch Drag Scrolling Handler (Touch Only - PC uses native mouse wheel & scrollbar)
                local isTouchDragging = false
                local touchStartY = 0
                local startCanvasY = 0

                local function onTouchBegan(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        isTouchDragging = false
                        touchStartY = input.Position.Y
                        startCanvasY = optScroll.CanvasPosition.Y
                    end
                end

                local function onTouchChanged(input)
                    if touchStartY > 0 and input.UserInputType == Enum.UserInputType.Touch then
                        local deltaY = input.Position.Y - touchStartY
                        if math.abs(deltaY) > 4 then
                            isTouchDragging = true
                        end
                        if isTouchDragging then
                            local currentScale = _effectiveScale or 1
                            local scaledDeltaY = deltaY / currentScale
                            local itemsCount = #optionButtons
                            local totalH = (itemsCount > 0) and (itemsCount * 43 + 80) or (optLayout.AbsoluteContentSize.Y + 80)
                            local maxCanvasY = math.max(0, totalH - optScroll.AbsoluteWindowSize.Y)
                            optScroll.CanvasPosition = Vector2.new(0, math.clamp(startCanvasY - scaledDeltaY, 0, maxCanvasY))
                        end
                    end
                end

                local function onTouchEnded(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        touchStartY = 0
                        task.delay(0.05, function()
                            isTouchDragging = false
                        end)
                    end
                end

                optScroll.InputBegan:Connect(onTouchBegan)
                optScroll.InputChanged:Connect(onTouchChanged)
                optScroll.InputEnded:Connect(onTouchEnded)

                local currentSelected = {}
                if isMulti then
                    currentSelected = getSelectedList(OptionObj.Value)
                else
                    if type(OptionObj.Value) == "string" and OptionObj.Value ~= "" then
                        table.insert(currentSelected, OptionObj.Value)
                    elseif type(OptionObj.Value) == "table" then
                        local list = getSelectedList(OptionObj.Value)
                        if #list > 0 then table.insert(currentSelected, list[1]) end
                    end
                end

                optionButtons = {}
                local function renderOptions(filterText)
                    filterText = filterText and string.lower(string.gsub(filterText, "^%s*(.-)%s*$", "%1")) or ""
                    for _, btnObj in ipairs(optionButtons) do btnObj:Destroy() end
                    optionButtons = {}

                    local currentValues = (type(OptionObj.Values) == "function" and OptionObj.Values()) or OptionObj.Values or values
                    if type(currentValues) ~= "table" then currentValues = {} end

                    for _, optVal in ipairs(currentValues) do
                        local valStr = tostring(optVal)
                        if filterText == "" or string.find(string.lower(valStr), filterText, 1, true) then
                            local isSelected = isMulti and (table.find(currentSelected, optVal) ~= nil) or (currentSelected[1] == optVal)

                            local itemBtn = Instance.new("TextButton")
                            itemBtn.Size = UDim2.new(1, -6, 0, 38)
                            itemBtn.BackgroundColor3 = isSelected and COLORS.primary or COLORS.glassDeep
                            itemBtn.BackgroundTransparency = isSelected and 0.1 or 0.2
                            itemBtn.Text = (isSelected and "   ✓  " or "       ") .. valStr
                            itemBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or COLORS.text
                            itemBtn.Font = Enum.Font.GothamBold
                            itemBtn.TextSize = 11.5
                            itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                            itemBtn.TextTruncate = Enum.TextTruncate.AtEnd
                            itemBtn.AutoButtonColor = false
                            itemBtn.Active = false
                            itemBtn.ZIndex = 1000002
                            itemBtn.Parent = optScroll

                            local ibCorner = Instance.new("UICorner")
                            ibCorner.CornerRadius = UDim.new(0, 8)
                            ibCorner.Parent = itemBtn

                            local ibStroke = Instance.new("UIStroke")
                            ibStroke.Color = isSelected and COLORS.primary or COLORS.surfaceRaised
                            ibStroke.Thickness = 1
                            ibStroke.Parent = itemBtn

                            itemBtn.InputBegan:Connect(onTouchBegan)
                            itemBtn.InputChanged:Connect(onTouchChanged)
                            itemBtn.InputEnded:Connect(onTouchEnded)

                            itemBtn.MouseButton1Click:Connect(function()
                                if isTouchDragging then return end
                                playClickSound()
                                if isMulti then
                                    local foundIdx = table.find(currentSelected, optVal)
                                    if foundIdx then
                                        table.remove(currentSelected, foundIdx)
                                    else
                                        table.insert(currentSelected, optVal)
                                    end
                                    updateDropdown(currentSelected)
                                    renderOptions(searchBox.Text)
                                else
                                    currentSelected = { optVal }
                                    updateDropdown(optVal)
                                    modalOverlay:Destroy()
                                end
                            end)

                            table.insert(optionButtons, itemBtn)
                        end
                    end

                    task.defer(updateModalCanvas)
                end

                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    optScroll.CanvasPosition = Vector2.new(0, 0)
                    renderOptions(searchBox.Text)
                end)

                renderOptions("")
            end)

            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        -- BUTTON WIDGET
        function TabObj:AddButton(bCfg)
            local title = bCfg.Title or "Button"
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

            function OptionObj:OnChanged(cb)
                table.insert(OptionObj.ChangedCallbacks, cb)
            end

            function OptionObj:SetValue(val)
                box.Text = tostring(val)
                OptionObj.Value = tostring(val)
            end

            ObsidianGlassEngine.Options[id] = OptionObj
            return OptionObj
        end

        -- SECTION WIDGET
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
            local desc = pCfg.Desc or ""

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
            pTitle.TextColor3 = COLORS.cyan
            pTitle.Font = Enum.Font.GothamBold
            pTitle.TextSize = 14
            pTitle.TextXAlignment = Enum.TextXAlignment.Left
            pTitle.Parent = frame

            local pDesc = Instance.new("TextLabel")
            pDesc.Size = UDim2.new(1, -20, 0, 26)
            pDesc.Position = UDim2.new(0, 10, 0, 26)
            pDesc.BackgroundTransparency = 1
            pDesc.Text = desc
            pDesc.TextColor3 = COLORS.text
            pDesc.Font = Enum.Font.Gotham
            pDesc.TextSize = 12
            pDesc.TextXAlignment = Enum.TextXAlignment.Left
            pDesc.Parent = frame

            local ParaObj = {}
            function ParaObj:SetTitle(t) pTitle.Text = t end
            function ParaObj:SetDesc(d) pDesc.Text = d end
            return ParaObj
        end

        table.insert(WindowObj.Tabs, TabObj)
        return TabObj
    end

    function WindowObj:SelectTab(idx)
        if WindowObj.Tabs[idx] and WindowObj.Tabs[idx].Select then
            WindowObj.Tabs[idx].Select()
        end
    end

    return WindowObj
end

local isMobileDevice = UserInputService.TouchEnabled or not UserInputService.KeyboardEnabled
local Window = ObsidianGlassEngine:CreateWindow({
    Title = "PayomboyZ Hub",
    SubTitle = "โดย Dexq | Obsidian Glassmorphic 2 Engine",
    MinimizeKey = Enum.KeyCode.K
})

local Tabs = {
    Main = Window:AddTab({ Title = "หลัก", Icon = "home" }),
    Manage = Window:AddTab({ Title = "จัดการระบบ", Icon = "layout-grid" }),
    Reroll = Window:AddTab({ Title = "รีโรล", Icon = "refresh-cw" }),
    Potion = Window:AddTab({ Title = "น้ำยา", Icon = "flask-conical" }),
    Raid = Window:AddTab({ Title = "เรด & ทาวเวอร์", Icon = "swords" }),
    Trade = Window:AddTab({ Title = "แลกเปลี่ยน", Icon = "arrow-left-right" }),
    FPS = Window:AddTab({ Title = "ลด FPS", Icon = "monitor" }),
    Dashboard = Window:AddTab({ Title = "แดชบอร์ด & ตั้งค่า", Icon = "sliders" })
}

local Options = ObsidianGlassEngine.Options

---------------------------------------------------------
-- CONSTANTS & FOLDER COMPATIBILITY
---------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local GuiService = game:GetService("GuiService")

-- Auto Dismiss Robux & Unaffordable Purchase Prompts
local function dismissPurchasePrompt()
    pcall(function()
        GuiService:CloseInspectMenu()
    end)
    pcall(function()
        local purchaseApp = CoreGui:FindFirstChild("PurchasePromptApp") or (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("PurchasePromptApp"))
        if purchaseApp then
            for _, v in ipairs(purchaseApp:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("ImageButton") then
                    local name = string.lower(v.Name)
                    local text = v:IsA("TextButton") and string.lower(v.Text) or ""
                    if name:find("cancel") or name:find("close") or text:find("cancel") or text:find("ยกเลิก") or text:find("ปิด") or v.Name == "CloseButton" or v.Name == "ErrorDismissButton" or v.Name == "ButtonContainer" then
                        if getconnections then
                            for _, c in ipairs(getconnections(v.MouseButton1Click)) do pcall(function() c:Fire() end) end
                            for _, c in ipairs(getconnections(v.Activated)) do pcall(function() c:Fire() end) end
                        end
                    end
                end
            end
        end
    end)
end

local function rejectCurrentPromptCards()
    -- แค่ปิด Robux prompt อย่างเดียว ไม่ reject การ์ดทุกใบบนสายพาน
    -- (instantBuyLoop จะ reject เฉพาะการ์ดที่ fail ซ้ำๆ เองอยู่แล้ว)
    dismissPurchasePrompt()
end

pcall(function()
    MarketplaceService.PromptPurchaseRequested:Connect(function() task.wait(0.05) rejectCurrentPromptCards() end)
    MarketplaceService.PromptProductPurchaseRequested:Connect(function() task.wait(0.05) rejectCurrentPromptCards() end)
    MarketplaceService.PromptGamePassPurchaseRequested:Connect(function() task.wait(0.05) rejectCurrentPromptCards() end)
    MarketplaceService.PromptBundlePurchaseRequested:Connect(function() task.wait(0.05) rejectCurrentPromptCards() end)
end)

-- Folder compatibility with older script configs
local ConfigFolders = {"Dexq_AnimeCardFarm", "PayomboyZ_Config"}
for _, folderName in ipairs(ConfigFolders) do
    if isfolder and not isfolder(folderName) then pcall(makefolder, folderName) end
end
local PrimaryFolder = "Dexq_AnimeCardFarm"

local MainConfigPath = PrimaryFolder .. "/_MainConfig.json"
local ConfigData = { Autoload = "" }

local function SaveMainConfig()
    if writefile then
        pcall(function() writefile(MainConfigPath, HttpService:JSONEncode(ConfigData)) end)
    end
end

local function LoadMainConfig()
    for _, folderName in ipairs(ConfigFolders) do
        local path = folderName .. "/_MainConfig.json"
        if isfile and isfile(path) then
            local st, res = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
            if st and type(res) == "table" and res.Autoload and res.Autoload ~= "" then
                ConfigData = res
                return
            end
        end
    end
end
LoadMainConfig()

local function LoadSavedWebhook()
    for _, folderName in ipairs(ConfigFolders) do
        local path = folderName .. "/Webhook.txt"
        if isfile and isfile(path) then
            local st, content = pcall(readfile, path)
            if st and content and content ~= "" then
                return string.match(content, "^%s*(.-)%s*$") or content
            end
        end
    end
    return ""
end

getgenv().SelectedRarities = getgenv().SelectedRarities or {}
getgenv().SelectedMutations = getgenv().SelectedMutations or {}
getgenv().PromptCooldowns = getgenv().PromptCooldowns or {}
getgenv().CardFolder = getgenv().CardFolder or nil
getgenv().DiscordWebhook = (getgenv().DiscordWebhook and getgenv().DiscordWebhook ~= "") and getgenv().DiscordWebhook or LoadSavedWebhook()
getgenv().AutoCarryDelay = getgenv().AutoCarryDelay or 5
getgenv().RerollSpeed = getgenv().RerollSpeed or 0.05
getgenv().SelectedTraits = getgenv().SelectedTraits or {}
getgenv().SelectedRanks = getgenv().SelectedRanks or {}
getgenv().SelectedTradeCards = getgenv().SelectedTradeCards or {}
getgenv().SelectedTradePlayer = getgenv().SelectedTradePlayer or ""
getgenv().BossRaidDifficulty = getgenv().BossRaidDifficulty or "NIGHTMARE"

local RaritiesList = {
    "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret",
    "Divine", "Transcendent", "Shadow", "Emperor", "Demon", "Manga", "Celestial",
    "Heavenly", "Corrupted", "Striker", "Sacred", "Paradox", "Founder", "Evolved",
    "Magic", "Oni", "Chaos", "Ruin", "Reborn", "Beast", "Nordic", "Hunter",
    "Soul", "Swordsman", "Gamer", "Revenge", "Chainsaw", "Eternity", "Academy",
    "Dynasty", "Grail", "Conquest", "Blaze", "Devour", "Raven", "Arcane", "Nightfall",
    "Smash", "Emblem", "Dunk", "Chrono", "Blossom", "Zenith"
}

local MutationsList = {
    "Normal", "Golden", "Diamond", "Venomous", "Rainbow", "Sakura", "Candy",
    "Blessed", "Radioactive", "Glitch", "Starfallen", "Admin", "Unknown", "Nullstar", "Limited", "Event"
}

local TraitsList = {
    "Fortune I", "Vigor I", "Strength I",
    "Fortune II", "Vigor II", "Strength II",
    "Fortune III", "Vigor III", "Strength III",
    "Assassin", "Berserk", "Tank",
    "Rich", "Emperor", "Phoenix", "Almighty", "Sovereign"
}

local RankList = {"F", "E", "D", "C", "B", "A", "S", "SS", "SR", "UR", "LR"}
local knownRankList = {"LR", "UR", "SR", "SSS+", "SS+", "SS", "S", "A", "B", "C", "D", "E", "F"}
local knownTraitList = {
    "Sovereign", "Almighty", "Phoenix", "Emperor", "Rich",
    "Assassin", "Berserk", "Tank",
    "Fortune III", "Vigor III", "Strength III",
    "Fortune II", "Vigor II", "Strength II",
    "Fortune I", "Vigor I", "Strength I"
}

-- Safe UI button trigger
local function fireButton(btn)
    if not btn then return end
    pcall(function()
        local fired = false
        if btn.Parent and btn.Parent:IsA("ProximityPrompt") then return end
        if getconnections then
            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() fired = true end
            for _, c in ipairs(getconnections(btn.MouseButton1Down)) do c:Fire() fired = true end
            for _, c in ipairs(getconnections(btn.MouseButton1Up)) do c:Fire() fired = true end
            for _, c in ipairs(getconnections(btn.Activated)) do c:Fire() fired = true end
        end
        if not fired then
            local vim = game:GetService("VirtualInputManager")
            local absPos = btn.AbsolutePosition
            local absSize = btn.AbsoluteSize
            local center = absPos + (absSize / 2)
            vim:SendMouseButtonEvent(center.X, center.Y + 36, 0, true, game, 1)
            task.wait(0.1)
            vim:SendMouseButtonEvent(center.X, center.Y + 36, 0, false, game, 1)
        end
    end)
end

-- Check if an object is a Pack/Box Card
local function isPackCard(obj)
    if not obj then return false end
    if obj:GetAttribute("BoxValue") ~= nil 
        or obj:GetAttribute("IsPack") == true 
        or obj:GetAttribute("PackName") ~= nil
    then
        return true
    end
    
    local name = string.lower(obj.Name or "")
    local templateAttr = obj:GetAttribute("TemplateName")
    local template = templateAttr and string.lower(tostring(templateAttr)) or ""
    local cardNameAttr = obj:GetAttribute("CardName")
    local cardName = cardNameAttr and string.lower(tostring(cardNameAttr)) or ""
    
    local keywords = {"pack", "แพ็ค", "แพ็ก", "box", "กล่อง", "bag", "ถุง", "chest", "หีบ"}
    for _, kw in ipairs(keywords) do
        if string.find(name, kw) or (template ~= "" and string.find(template, kw)) or (cardName ~= "" and string.find(cardName, kw)) then
            return true
        end
    end

    local isPackByText = false
    pcall(function()
        for _, descendant in ipairs(obj:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                local txt = string.lower(descendant.Text or "")
                for _, kw in ipairs(keywords) do
                    if string.find(txt, kw) then
                        isPackByText = true
                        break
                    end
                end
            end
            if isPackByText then break end
        end
    end)
    return isPackByText
end

local function isBossOrRaidCard(obj)
    if not obj then return false end
    
    pcall(function()
        if obj:GetAttribute("IsBoss") == true 
            or obj:GetAttribute("IsBossCard") == true
            or obj:GetAttribute("IsBossTicket") == true
            or obj:GetAttribute("IsRaid") == true
            or obj:GetAttribute("IsRaidCard") == true
            or obj:GetAttribute("IsRaidTicket") == true
            or obj:GetAttribute("BossValue") ~= nil
            or obj:GetAttribute("RaidValue") ~= nil
        then
            return true
        end
        local cType = obj:GetAttribute("CardType") or obj:GetAttribute("TicketType") or obj:GetAttribute("Type")
        if cType and (string.find(string.lower(tostring(cType)), "boss") or string.find(string.lower(tostring(cType)), "raid") or string.find(string.lower(tostring(cType)), "ticket")) then
            return true
        end
    end)

    local name = string.lower(obj.Name or "")
    local templateAttr = obj:GetAttribute("TemplateName")
    local template = templateAttr and string.lower(tostring(templateAttr)) or ""
    local cardNameAttr = obj:GetAttribute("CardName")
    local cardName = cardNameAttr and string.lower(tostring(cardNameAttr)) or ""
    
    local keywords = {"boss ticket", "raid ticket", "bossticket", "raidticket", "บัตรบอส", "บัตรเรด", "บัตร บอส", "บัตร เรด", "บอสการ์ด", "เรดการ์ด", "boss card", "raid card", "boss", "raid", "ticket", "ตั๋ว", "บัตร"}
    for _, kw in ipairs(keywords) do
        if string.find(name, kw) or (template ~= "" and string.find(template, kw)) or (cardName ~= "" and string.find(cardName, kw)) then
            return true
        end
    end

    local isBossRaid = false
    pcall(function()
        for _, descendant in ipairs(obj:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                local txt = string.lower(descendant.Text or "")
                for _, kw in ipairs(keywords) do
                    if string.find(txt, kw) then
                        isBossRaid = true
                        break
                    end
                end
            end
            if isBossRaid then break end
        end
    end)
    return isBossRaid
end

local function getCardRank(item)
    if not item then return "None" end
    local attr = item:GetAttribute("Rank") 
        or item:GetAttribute("CardRank") 
        or item:GetAttribute("Grade") 
        or item:GetAttribute("CardGrade") 
        or item:GetAttribute("Rarity") 
        or item:GetAttribute("CardRarity")
        or item:GetAttribute("Tier")
        or item:GetAttribute("CashBoost")
    if attr and tostring(attr) ~= "" and tostring(attr) ~= "nil" then return tostring(attr) end

    for _, childName in ipairs({"Rank", "Grade", "CardRank", "CardGrade", "Rarity", "Tier"}) do
        local valObj = item:FindFirstChild(childName)
        if valObj then
            if valObj:IsA("StringValue") and valObj.Value ~= "" then
                return valObj.Value
            elseif valObj:IsA("TextLabel") and valObj.Text ~= "" then
                return valObj.Text
            end
        end
    end

    for _, txtObj in ipairs(item:GetDescendants()) do
        if txtObj:IsA("TextLabel") and txtObj.Text then
            local cleanTxt = string.upper(string.gsub(txtObj.Text, "<[^>]+>", ""))
            cleanTxt = string.match(cleanTxt, "^%s*(.-)%s*$") or ""
            for _, r in ipairs(knownRankList) do
                local escapedR = string.gsub(r, "%+", "%%+")
                if string.match(cleanTxt, "^" .. escapedR .. "$")
                    or string.match(cleanTxt, "^" .. escapedR .. "[^%w%+%.]")
                    or string.match(cleanTxt, "[^%w%+%.]" .. escapedR .. "[^%w%+%.]")
                    or string.match(cleanTxt, "[^%w%+%.]" .. escapedR .. "$")
                then
                    return r
                end
            end
        end
    end
    return "None"
end

local function getCardTrait(item)
    if not item then return "None" end
    local attr = item:GetAttribute("Trait") 
        or item:GetAttribute("CardTrait") 
        or item:GetAttribute("MutationTrait")
    if attr and tostring(attr) ~= "" and tostring(attr) ~= "nil" then return tostring(attr) end

    for _, childName in ipairs({"Trait", "CardTrait"}) do
        local valObj = item:FindFirstChild(childName)
        if valObj then
            if valObj:IsA("StringValue") and valObj.Value ~= "" then
                return valObj.Value
            elseif valObj:IsA("TextLabel") and valObj.Text ~= "" then
                return valObj.Text
            end
        end
    end

    for _, txtObj in ipairs(item:GetDescendants()) do
        if txtObj:IsA("TextLabel") and txtObj.Text then
            local cleanTxt = string.gsub(txtObj.Text, "<[^>]+>", "")
            for _, t in ipairs(knownTraitList) do
                if string.find(string.lower(cleanTxt), string.lower(t)) then
                    return t
                end
            end
        end
    end
    return "None"
end

local function getCardMutation(item)
    if not item then return "Normal" end
    local attr = item:GetAttribute("CardMutation") or item:GetAttribute("Mutation")
    if attr and tostring(attr) ~= "" and tostring(attr) ~= "nil" then return tostring(attr) end

    for _, childName in ipairs({"Mutation", "CardMutation"}) do
        local valObj = item:FindFirstChild(childName)
        if valObj then
            if valObj:IsA("StringValue") and valObj.Value ~= "" then
                return valObj.Value
            elseif valObj:IsA("TextLabel") and valObj.Text ~= "" then
                return valObj.Text
            end
        end
    end
    return "Normal"
end

local function findCardByUUID(uuid)
    if not uuid or uuid == "" then return nil end
    local function checkFolder(folder)
        if not folder then return nil end
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Tool") then
                local cId = item:GetAttribute("UUID") or item:GetAttribute("Id") or item:GetAttribute("CardId")
                if tostring(cId) == tostring(uuid) then
                    return item
                end
            end
        end
        return nil
    end
    local tool = checkFolder(LocalPlayer:FindFirstChild("Backpack"))
    if not tool and LocalPlayer.Character then
        tool = checkFolder(LocalPlayer.Character)
    end
    return tool
end

-- Unified Single Player Finder Function (Fuzzy Matching)
local function findTargetPlayer(nameStr)
    if not nameStr or nameStr == "" or nameStr == "ไม่มีผู้เล่นอื่น" then return nil end
    local cleanName = string.lower(tostring(nameStr))
    for _, p in ipairs(Players:GetPlayers()) do
        if string.lower(p.Name) == cleanName or string.lower(p.DisplayName) == cleanName then
            return p
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), cleanName, 1, true) or string.find(string.lower(p.DisplayName), cleanName, 1, true) then
            return p
        end
    end
    return nil
end

local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then table.insert(names, "ไม่มีผู้เล่นอื่น") end
    return names
end

local function findPlayerPlot()
    local plotNum = LocalPlayer:FindFirstChild("PlotNumber") and LocalPlayer.PlotNumber.Value or 0
    if plotNum ~= 0 then
        local plotFolder = workspace:FindFirstChild("MAP")
            and workspace.MAP:FindFirstChild("Plots")
            and workspace.MAP.Plots:FindFirstChild(tostring(plotNum))
        if plotFolder then return plotFolder end
    end
    local plots = workspace:FindFirstChild("MAP") and workspace.MAP:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:GetAttribute("Owner") == LocalPlayer.Name or plot.Name == LocalPlayer.Name or plot.Name == tostring(plotNum) then
                return plot
            end
        end
    end
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("Folder") or desc:IsA("Model") then
            if desc.Name == LocalPlayer.Name or desc:GetAttribute("Owner") == LocalPlayer.Name then
                local plotsFolder = desc:FindFirstAncestor("Plots")
                if plotsFolder then return desc end
            end
        end
    end
    return nil
end

local function getSpawnPackClickDetector()
    local plotFolder = findPlayerPlot()
    if plotFolder and plotFolder:FindFirstChild("Plot_N0") then
        for _, v in ipairs(plotFolder.Plot_N0:GetDescendants()) do
            if v:IsA("ClickDetector") and v.Parent and v.Parent.Name == "ButtonPart" then
                return v
            end
        end
    end
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ClickDetector") and desc.Parent and desc.Parent.Name == "ButtonPart" and desc.Parent.Parent and desc.Parent.Parent.Name == "Plot_N0" then
            return desc
        end
    end
    if plotFolder then
        for _, v in ipairs(plotFolder:GetDescendants()) do
            if v:IsA("ClickDetector") then return v end
        end
    end
    return nil
end

local function findCardFolder()
    local plot = findPlayerPlot()
    if plot then
        for _, desc in ipairs(plot:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                local model = desc:FindFirstAncestorOfClass("Model")
                if model and model:GetAttribute("IgnoreTutoBeam") ~= nil then
                    getgenv().CardFolder = model.Parent
                    return true
                end
            end
        end
    end
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local model = desc:FindFirstAncestorOfClass("Model")
            if model and model:GetAttribute("IgnoreTutoBeam") ~= nil then
                getgenv().CardFolder = model.Parent
                return true
            end
        end
    end
    return false
end

local function GetAllInventorySummary()
    local inventory = {}
    local function scanFolder(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Tool") then
                local rarityAttr = item:GetAttribute("Rarity") or item:GetAttribute("CardGrade")
                local cardNameAttr = item:GetAttribute("CardName")
                local groupKey = rarityAttr or cardNameAttr or item.Name
                if not item:GetAttribute("Rarity") and item:FindFirstChild("Rarity") and item.Rarity:IsA("StringValue") then
                    groupKey = item.Rarity.Value
                end
                local mutation = item:GetAttribute("Mutation") or item:GetAttribute("CardMutation") or "Normal"
                if not item:GetAttribute("Mutation") and item:FindFirstChild("Mutation") and item.Mutation:IsA("StringValue") then
                    mutation = item.Mutation.Value
                end
                if not string.find(string.lower(item.Name), "box") and groupKey ~= "Box" then
                    if not inventory[groupKey] then inventory[groupKey] = {} end
                    if not inventory[groupKey][mutation] then inventory[groupKey][mutation] = 0 end
                    inventory[groupKey][mutation] = inventory[groupKey][mutation] + 1
                end
            end
        end
    end
    pcall(function()
        scanFolder(LocalPlayer:FindFirstChild("Backpack"))
        if LocalPlayer.Character then scanFolder(LocalPlayer.Character) end
    end)
    local resultLines = {}
    for key, mutations in pairs(inventory) do
        local mutStrings = {}
        for mut, count in pairs(mutations) do
            table.insert(mutStrings, mut .. " x" .. tostring(count))
        end
        table.insert(resultLines, tostring(key) .. ": " .. table.concat(mutStrings, " | "))
    end
    if #resultLines > 0 then
        local fullText = table.concat(resultLines, "\n")
        return (string.len(fullText) > 1000) and (string.sub(fullText, 1, 1000) .. "...") or fullText
    else
        return "None"
    end
end

local function SendWebhook(url, rarity, mutation)
    if not url or url == "" then return end
    url = string.match(url, "^%s*(.-)%s*$") or url
    if not string.find(url, "http") then return end

    local req = (syn and syn.request) 
             or (http and http.request) 
             or http_request 
             or (fluxus and fluxus.request) 
             or request 
             or (krnl and krnl.request) 
             or (delta and delta.request)

    if not req then return end

    local timeStr = os.date("%H:%M:%S")
    Runtime.boughtLog = Runtime.boughtLog or {}
    table.insert(Runtime.boughtLog, 1, string.format("[%s] %s [%s]", timeStr, tostring(rarity), tostring(mutation)))
    if #Runtime.boughtLog > 10 then table.remove(Runtime.boughtLog, 11) end

    local recentBoughtText = table.concat(Runtime.boughtLog, "\n")
    if recentBoughtText == "" then recentBoughtText = "ไม่มีประวัติล่าสุด" end

    local data = {
        ["content"] = "",
        ["embeds"] = {
            {
                ["title"] = "🎉 ซื้อการ์ดสำเร็จ (Card Bought)!",
                ["description"] = "ซื้อการ์ดตรงตามเงื่อนไขเรียบร้อยแล้ว",
                ["type"] = "rich",
                ["color"] = 65484,
                ["fields"] = {
                    { ["name"] = "ความหายาก (Rarity)", ["value"] = tostring(rarity), ["inline"] = true },
                    { ["name"] = "กลายพันธุ์ (Mutation)", ["value"] = tostring(mutation), ["inline"] = true },
                    { ["name"] = "📜 ประวัติการซื้อการ์ดล่าสุด (Recent Bought)", ["value"] = recentBoughtText, ["inline"] = false },
                },
                ["timestamp"] = DateTime.now():ToIsoDate(),
            },
        },
    }
    pcall(function()
        req({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data),
        })
    end)
end

local function SendRerollWebhook(rerollType, cardName, resultValue)
    local url = getgenv().DiscordWebhook
    if not url or url == "" then return end
    url = string.match(url, "^%s*(.-)%s*$") or url
    if not string.find(url, "http") then return end

    local req = (syn and syn.request) 
             or (http and http.request) 
             or http_request 
             or (fluxus and fluxus.request) 
             or request 
             or (krnl and krnl.request) 
             or (delta and delta.request)

    if not req then return end

    local timeStr = os.date("%H:%M:%S")
    Runtime.rerollSuccessLog = Runtime.rerollSuccessLog or {}
    local entryStr = string.format("[%s] [%s] %s -> %s", timeStr, string.upper(rerollType), tostring(cardName), tostring(resultValue))
    table.insert(Runtime.rerollSuccessLog, 1, entryStr)
    if #Runtime.rerollSuccessLog > 10 then table.remove(Runtime.rerollSuccessLog, 11) end

    local historyText = table.concat(Runtime.rerollSuccessLog, "\n")
    if historyText == "" then historyText = "ไม่มีประวัติล่าสุด" end

    local data = {
        ["content"] = "",
        ["embeds"] = {
            {
                ["title"] = "🎯 รีโรลสำเร็จ (Reroll Success)!",
                ["description"] = "การ์ดได้รับการสุ่มตามเป้าหมายที่เลือกเรียบร้อยแล้ว",
                ["type"] = "rich",
                ["color"] = 16750848,
                ["fields"] = {
                    { ["name"] = "ประเภท (Type)", ["value"] = tostring(rerollType), ["inline"] = true },
                    { ["name"] = "ชื่อการ์ด (Card)", ["value"] = tostring(cardName), ["inline"] = true },
                    { ["name"] = "ผลลัพธ์ (Result)", ["value"] = tostring(resultValue), ["inline"] = true },
                    { ["name"] = "📜 ประวัติการรีโรลสำเร็จย้อนหลัง (Reroll History)", ["value"] = historyText, ["inline"] = false },
                },
                ["timestamp"] = DateTime.now():ToIsoDate(),
            },
        },
    }
    pcall(function()
        req({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data),
        })
    end)
end

----------------------------------------------------------------
-- 🛡️ ADVANCED FAILSAFE ANTI-AFK ENGINE
----------------------------------------------------------------
getgenv().AntiAfkState = getgenv().AntiAfkState or false
getgenv().AntiAfkActive = getgenv().AntiAfkActive or false

local antiAfkConn = nil
local antiAfkThreadActive = false

local function activateAntiAfk()
    getgenv().AntiAfkActive = true

    -- 1. Event listener hook on LocalPlayer.Idled
    if not antiAfkConn then
        pcall(function()
            antiAfkConn = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                    VirtualUser:Button2Down(Vector2.new(0, 0))
                    task.wait(0.1)
                    VirtualUser:Button2Up(Vector2.new(0, 0))
                end)
            end)
        end)
    end

    -- 2. Periodic Active Keep-Alive Loop (Runs every 45s to prevent 20-min Roblox disconnect)
    if not antiAfkThreadActive then
        antiAfkThreadActive = true
        task.spawn(function()
            while getgenv().AntiAfkActive or getgenv().AntiAfkState or (getgenv().AFK_Obj and getgenv().AFK_Obj.on) do
                task.wait(45)
                if not (getgenv().AntiAfkActive or getgenv().AntiAfkState or (getgenv().AFK_Obj and getgenv().AFK_Obj.on)) then break end

                -- Method A: VirtualUser input simulation
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(100, 100))
                    VirtualUser:Button2Down(Vector2.new(100, 100))
                    task.wait(0.05)
                    VirtualUser:Button2Up(Vector2.new(100, 100))
                end)

                -- Method B: VirtualInputManager keypress simulation
                pcall(function()
                    local vim = game:GetService("VirtualInputManager")
                    if vim then
                        vim:SendKeyEvent(true, Enum.KeyCode.Unknown, false, game)
                        task.wait(0.05)
                        vim:SendKeyEvent(false, Enum.KeyCode.Unknown, false, game)
                    end
                end)

                -- Method C: Camera micro-nudge
                pcall(function()
                    local cam = workspace.CurrentCamera
                    if cam then
                        cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.01), 0)
                        task.wait(0.05)
                        cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(-0.01), 0)
                    end
                end)
            end
            antiAfkThreadActive = false
        end)
    end
end

local function deactivateAntiAfk()
    getgenv().AntiAfkActive = false
    if antiAfkConn then
        pcall(function() antiAfkConn:Disconnect() end)
        antiAfkConn = nil
    end
end

----------------------------------------------------------------
-- AFK Mode Overlay ("ไก่ตัน") System Engine
----------------------------------------------------------------
getgenv().AFKRuntime = getgenv().AFKRuntime or {
    log = {},
    traitLog = {},
    rankLog = {},
    beltLog = {},
    stats = { bought = 0, secret = 0 },
    afkOn = false,
    afkGui = nil
}
local Runtime = getgenv().AFKRuntime

local afkPushTraitLog
local afkPushRankLog

local function logLine(kind, text)
    if not text then return end
    local timeStr = os.date("%H:%M:%S")
    local lineText = ("[%s] [%s] %s"):format(timeStr, string.upper(kind), text)
    table.insert(Runtime.log, 1, lineText)
    if #Runtime.log > 40 then
        table.remove(Runtime.log, 41)
    end

    local kLower = string.lower(kind or "")
    local tLower = string.lower(text or "")
    if kLower:find("trait") or tLower:find("trait") or tLower:find("ไตรท์") then
        Runtime.traitLog = Runtime.traitLog or {}
        table.insert(Runtime.traitLog, 1, lineText)
        if #Runtime.traitLog > 20 then table.remove(Runtime.traitLog, 21) end
        if afkPushTraitLog then pcall(afkPushTraitLog, lineText) end
    elseif kLower:find("rank") or tLower:find("rank") or tLower:find("แรงค์") then
        Runtime.rankLog = Runtime.rankLog or {}
        table.insert(Runtime.rankLog, 1, lineText)
        if #Runtime.rankLog > 20 then table.remove(Runtime.rankLog, 21) end
        if afkPushRankLog then pcall(afkPushRankLog, lineText) end
    end

    if getgenv().AFK_Obj then
        getgenv().AFK_Obj.logDirty = true
    end
end

local AFK_MAX_LOGS     = 40
local AFK_MAX_BELT     = 30
local AFK_MAX_CARDS    = 60
local AFK_FPS_CAP      = 10

local AFK_COLOR = {
    bg        = Color3.fromRGB(0, 0, 0),
    panel     = Color3.fromRGB(24, 24, 28),
    raised    = Color3.fromRGB(36, 36, 42),
    separator = Color3.fromRGB(56, 56, 64),
    label     = Color3.fromRGB(255, 255, 255),
    label2    = Color3.fromRGB(160, 160, 170),
    label3    = Color3.fromRGB(110, 110, 120),
    blue      = Color3.fromRGB(10, 132, 255),
    green     = Color3.fromRGB(48, 209, 88),
    red       = Color3.fromRGB(255, 69, 58),
    orange    = Color3.fromRGB(255, 159, 10),
    yellow    = Color3.fromRGB(255, 214, 10),
    teal      = Color3.fromRGB(100, 210, 255),
    purple    = Color3.fromRGB(191, 90, 242),
}

local AFK_RARITY_COLOR = {
    Common       = Color3.fromRGB(160, 160, 170),
    Uncommon     = Color3.fromRGB(48, 209, 88),
    Rare         = Color3.fromRGB(10, 132, 255),
    Epic         = Color3.fromRGB(191, 90, 242),
    Legendary    = Color3.fromRGB(255, 159, 10),
    Mythic       = Color3.fromRGB(255, 55, 95),
    Divine       = Color3.fromRGB(100, 210, 255),
    Secret       = Color3.fromRGB(255, 214, 10),
    Godly        = Color3.fromRGB(255, 105, 180),
    Transcendent = Color3.fromRGB(175, 238, 238),
    Cosmic       = Color3.fromRGB(94, 92, 230),
    Eternal      = Color3.fromRGB(255, 69, 58),
}

local AFK_TOUCH = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Kill zombie pump connections from previous script runs
pcall(function()
    if getgenv().AFK_PumpConn then
        getgenv().AFK_PumpConn:Disconnect()
        getgenv().AFK_PumpConn = nil
    end
    -- Force-close leftover ANIME_AFK GUIs from previous runs
    local containers = {game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui")}
    if gethui then table.insert(containers, gethui()) end
    for _, parent in ipairs(containers) do
        if parent then
            for _, child in ipairs(parent:GetChildren()) do
                if child.Name == "ANIME_AFK" or child.Name == "PayomboyZ_AFK" or child.Name == "PayomboyZ_Restore3DBtn" then
                    child:Destroy()
                end
            end
        end
    end
end)

local AFK = {
    on          = false,
    gui         = nil,
    conns       = {},
    startAt     = 0,
    lastSec     = -1,
    wantShow    = false,
    wantHide    = false,
    logDirty    = false,
    beltDirty   = false,
    invDirty    = false,
    pool        = {},
    poolHead    = 0,
    beltRows    = {},
    invRows     = {},
    prevFps     = nil,
    prev3D      = nil,
    prevQuality = nil,
    stat        = {},
    logList     = nil,
    beltList    = nil,
    invList     = nil,
}
getgenv().AFK_Obj = AFK

local function afkCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = parent
    return c
end

local function afkStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or AFK_COLOR.separator
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function afkPad(parent, all)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, all)
    p.PaddingBottom = UDim.new(0, all)
    p.PaddingLeft   = UDim.new(0, all)
    p.PaddingRight  = UDim.new(0, all)
    p.Parent = parent
    return p
end

local function afkText(parent, props)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.RichText = false
    t.Font = props.font or Enum.Font.Gotham
    t.TextSize = props.size or 13
    t.TextColor3 = props.color or AFK_COLOR.label
    t.TextXAlignment = props.align or Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.Text = props.text or ""
    t.Size = props.sizeUDim or UDim2.new(1, 0, 1, 0)
    if props.pos then t.Position = props.pos end
    if props.truncate then t.TextTruncate = Enum.TextTruncate.AtEnd end
    t.Parent = parent
    return t
end

local function afkCard(parent, props)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = props.color or AFK_COLOR.panel
    f.BorderSizePixel = 0
    f.Size = props.size or UDim2.new(1, 0, 1, 0)
    if props.pos then f.Position = props.pos end
    if props.anchor then f.AnchorPoint = props.anchor end
    afkCorner(f, props.radius or 14)
    if props.stroke ~= false then afkStroke(f, AFK_COLOR.separator, 1, 0.35) end
    f.Parent = parent
    return f
end

local function afkClock(sec)
    sec = math.max(0, math.floor(sec))
    return ("%02d:%02d:%02d"):format(math.floor(sec / 3600), math.floor(sec % 3600 / 60), sec % 60)
end

local function formatNumber(n)
    if not n or type(n) ~= "number" then return tostring(n or 0) end
    if n >= 1e12 then return string.format("%.2fT", n / 1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.2fK", n / 1e3)
    else return tostring(math.floor(n)) end
end

local function getPlayerMoney()
    local amount = nil
    pcall(function()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            for _, v in ipairs(ls:GetChildren()) do
                if v:IsA("ValueBase") then
                    local name = string.lower(v.Name)
                    if name:find("money") or name:find("yen") or name:find("cash") or name:find("coins") or name:find("gold") then
                        amount = v.Value
                        break
                    end
                end
            end
            if not amount and ls:FindFirstChildOfClass("ValueBase") then
                amount = ls:FindFirstChildOfClass("ValueBase").Value
            end
        end
        if not amount then
            for _, childName in ipairs({"Data", "PlayerData", "Values", "leaderstats"}) do
                local folder = LocalPlayer:FindFirstChild(childName)
                if folder then
                    for _, v in ipairs(folder:GetChildren()) do
                        if v:IsA("ValueBase") then
                            local name = string.lower(v.Name)
                            if name:find("money") or name:find("yen") or name:find("cash") or name:find("coins") then
                                amount = v.Value
                                break
                            end
                        end
                    end
                end
                if amount then break end
            end
        end
    end)

    if amount and type(amount) == "number" then
        return formatNumber(amount)
    elseif amount then
        return tostring(amount)
    end

    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, v in ipairs(playerGui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible and v.Text then
                    local txt = v.Text
                    if (txt:find("¥") or txt:find("%$") or txt:find("Yen")) and string.match(txt, "%d+") then
                        amount = txt
                        break
                    end
                end
            end
        end
    end)

    return amount or "0"
end

local function getTowerAndBossStatus()
    local towerStatus = "ไม่ได้ลงหอคอย"
    local bossStatus = ""
    
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, v in ipairs(playerGui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Text and v.Visible then
                    local clean = string.gsub(v.Text, "<[^>]+>", "")
                    local floorNum = string.match(clean, "[Ff][Ll][Oo][Oo][Rr]%s*(%d+)") or string.match(clean, "ชั้นที่%s*(%d+)")
                    if floorNum then
                        towerStatus = "กำลังลงชั้นที่ " .. floorNum
                        break
                    end
                end
            end
        end
        
        if towerStatus == "ไม่ได้ลงหอคอย" then
            if getgenv().AutoReplayToggled or getgenv().AutoTower then
                towerStatus = "กำลังดำเนินการ..."
            end
        end
        
        local isBossTime = isBossTimeWindow and isBossTimeWindow() or false
        local bossDone = hasFoughtBossThisHour and hasFoughtBossThisHour() or false
        if getgenv().AutoReplayToggledBoss then
            bossStatus = "⚔️ กำลังสู้บอส!"
        elseif isBossTime and not bossDone then
            bossStatus = "⚡ บอสเปิดอยู่!"
        else
            local now = os.date("*t")
            local remMin = 59 - now.min
            local remSec = 59 - now.sec
            
            local dynamicTimer = ""
            if playerGui then
                for _, v in ipairs(playerGui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible and v.Text then
                        local clean = string.gsub(v.Text, "<[^>]+>", "")
                        local lower = string.lower(clean)
                        if lower:find("boss") or lower:find("บอส") then
                            local tm = string.match(clean, "%d+:%d+") or string.match(clean, "%d+%s*m")
                            if tm then
                                dynamicTimer = tm
                                break
                            end
                        end
                    end
                end
            end

            if dynamicTimer ~= "" then
                bossStatus = "เกิดใน " .. dynamicTimer
            elseif remMin == 0 and remSec < 10 then
                bossStatus = "⚡ บอสเปิดอยู่!"
            else
                bossStatus = string.format("เกิดใน %02d:%02d นาที", remMin, remSec)
            end
        end
    end)
    
    return towerStatus, bossStatus
end

local function afkEnterLowPower()
    pcall(function()
        if getfpscap then AFK.prevFps = getfpscap() end
        if setfpscap then pcall(function() setfpscap(AFK_FPS_CAP) end) end
    end)
    pcall(function()
        AFK.prevQuality = settings().Rendering.QualityLevel
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    -- NOTE: ไม่ใช้ Set3dRenderingEnabled(false) ที่นี่ เพราะมันทำให้ UI พัง/จอดำ
    -- การปิด 3D Rendering อยู่ใน FPS Tab > โหมดจอขาว เท่านั้น
end

local function afkExitLowPower()
    pcall(function()
        if setfpscap then pcall(function() setfpscap((AFK.prevFps and AFK.prevFps > 0) and AFK.prevFps or 240) end) end
    end)
    pcall(function()
        if AFK.prevQuality then settings().Rendering.QualityLevel = AFK.prevQuality end
    end)
    pcall(function()
        if RunService and RunService.Set3dRenderingEnabled then
            RunService:Set3dRenderingEnabled(true)
        end
    end)
    AFK.prevFps, AFK.prevQuality, AFK.prev3D = nil, nil, nil
end

local function afkPushLog(text)
    if not AFK.on or not AFK.logList or not text then return end
    AFK.poolHead = AFK.poolHead % AFK_MAX_LOGS + 1
    local row = AFK.pool[AFK.poolHead]
    if not row then return end
    row.Text = text
    row.Visible = true
    for i = 1, AFK_MAX_LOGS do
        local r = AFK.pool[i]
        if r and r.Visible then
            r.LayoutOrder = (AFK.poolHead - i) % AFK_MAX_LOGS
        end
    end
end

local AFK_MAX_TRAIT = 20
local AFK_MAX_RANK  = 20

afkPushTraitLog = function(text)
    if not AFK.on or not AFK.traitPool or not text then return end
    AFK.traitHead = (AFK.traitHead or 0) % AFK_MAX_TRAIT + 1
    local row = AFK.traitPool[AFK.traitHead]
    if not row then return end
    row.Text = text
    row.Visible = true
    for i = 1, AFK_MAX_TRAIT do
        local r = AFK.traitPool[i]
        if r and r.Visible then
            r.LayoutOrder = ((AFK.traitHead or 0) - i) % AFK_MAX_TRAIT
        end
    end
end

afkPushRankLog = function(text)
    if not AFK.on or not AFK.rankPool or not text then return end
    AFK.rankHead = (AFK.rankHead or 0) % AFK_MAX_RANK + 1
    local row = AFK.rankPool[AFK.rankHead]
    if not row then return end
    row.Text = text
    row.Visible = true
    for i = 1, AFK_MAX_RANK do
        local r = AFK.rankPool[i]
        if r and r.Visible then
            r.LayoutOrder = ((AFK.rankHead or 0) - i) % AFK_MAX_RANK
        end
    end
end

local function afkSeedLogs()
    for i = 1, AFK_MAX_LOGS do
        local r = AFK.pool[i]
        if r then r.Visible = false end
    end
    AFK.poolHead = 0
    for i = math.min(#Runtime.log, AFK_MAX_LOGS), 1, -1 do
        afkPushLog(Runtime.log[i])
    end

    if AFK.traitPool then
        for i = 1, AFK_MAX_TRAIT do
            local r = AFK.traitPool[i]
            if r then r.Visible = false end
        end
        AFK.traitHead = 0
        local tLogs = Runtime.traitLog or {}
        if #tLogs == 0 then
            afkPushTraitLog("[" .. os.date("%H:%M:%S") .. "] [TRAIT] รอระบบสุ่ม/รี Trait...")
        else
            for i = math.min(#tLogs, AFK_MAX_TRAIT), 1, -1 do
                afkPushTraitLog(tLogs[i])
            end
        end
    end

    if AFK.rankPool then
        for i = 1, AFK_MAX_RANK do
            local r = AFK.rankPool[i]
            if r then r.Visible = false end
        end
        AFK.rankHead = 0
        local rLogs = Runtime.rankLog or {}
        if #rLogs == 0 then
            afkPushRankLog("[" .. os.date("%H:%M:%S") .. "] [RANK] รอระบบสุ่ม/รี Rank...")
        else
            for i = math.min(#rLogs, AFK_MAX_RANK), 1, -1 do
                afkPushRankLog(rLogs[i])
            end
        end
    end
end

local function getCardImage(obj)
    if not obj then return "" end
    local foundImg = ""
    pcall(function()
        for _, attrName in ipairs({"Image", "Texture", "Icon", "CardImage", "Thumbnail", "AssetId", "CardIcon"}) do
            local val = obj:GetAttribute(attrName)
            if val and tostring(val) ~= "" then
                local str = tostring(val)
                if string.find(str, "rbxassetid://") or string.find(str, "http") then
                    foundImg = str
                    return
                elseif tonumber(str) then
                    foundImg = "rbxassetid://" .. str
                    return
                end
            end
        end
    end)
    if foundImg ~= "" then return foundImg end

    if obj:IsA("Tool") then
        pcall(function()
            if obj.TextureId and obj.TextureId ~= "" then
                foundImg = obj.TextureId
            end
        end)
        if foundImg ~= "" then return foundImg end
    end

    pcall(function()
        local imgObj = obj:FindFirstChildWhichIsA("ImageLabel", true) or obj:FindFirstChildWhichIsA("ImageButton", true)
        if imgObj and imgObj.Image and imgObj.Image ~= "" then
            foundImg = imgObj.Image
        end
    end)
    if foundImg ~= "" then return foundImg end

    pcall(function()
        local decal = obj:FindFirstChildWhichIsA("Decal", true) or obj:FindFirstChildWhichIsA("Texture", true)
        if decal and decal.Texture and decal.Texture ~= "" then
            foundImg = decal.Texture
        end
    end)
    if foundImg ~= "" then return foundImg end

    pcall(function()
        local mesh = obj:FindFirstChildWhichIsA("MeshPart", true) or obj:FindFirstChildWhichIsA("SpecialMesh", true)
        if mesh then
            if mesh:IsA("MeshPart") and mesh.TextureID ~= "" then
                foundImg = mesh.TextureID
            elseif mesh:IsA("SpecialMesh") and mesh.TextureId ~= "" then
                foundImg = mesh.TextureId
            end
        end
    end)
    if foundImg ~= "" then return foundImg end

    return "rbxassetid://10723415903"
end

local function getCardModelRarityAndMutation(model)
    if not model then return "Common", "Normal" end
    local rName = ""
    local mName = ""
    pcall(function()
        rName = model:GetAttribute("Rarity") or model:GetAttribute("CardRarity") or model:GetAttribute("TemplateName") or ""
        mName = model:GetAttribute("Mutation") or model:GetAttribute("CardMutation") or ""
        
        if rName == "" then
            local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                local txt = prompt.ActionText .. " " .. prompt.ObjectText
                for _, r in ipairs(RaritiesList or {}) do
                    if string.find(string.lower(txt), string.lower(r)) then
                        rName = r
                        break
                    end
                end
            end
        end
    end)
    return (rName ~= "" and rName or model.Name), (mName ~= "" and mName or "Normal")
end

local function afkPaintBelt()
    if not AFK.on or not AFK.beltList then return end
    if not getgenv().CardFolder then findCardFolder() end
    if not getgenv().CardFolder then return end

    Runtime.beltLog = Runtime.beltLog or {}

    -- Scan active models in workspace card folder and push to history feed
    for _, m in ipairs(getgenv().CardFolder:GetChildren()) do
        if m:IsA("Model") and m:GetAttribute("IgnoreTutoBeam") ~= nil then
            if not m:GetAttribute("LoggedBeltScan") then
                m:SetAttribute("LoggedBeltScan", true)
                local rName, mName = getCardModelRarityAndMutation(m)
                local isRejected = m:GetAttribute("Rejected") == true
                local isRobux = false

                local prompt = m:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    local pTxt = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Name):lower()
                    if pTxt:find("robux") or pTxt:find("r%$") or prompt:GetAttribute("IsRobux") or m:GetAttribute("IsRobux") then
                        isRobux = true
                    end
                end

                local img = getCardImage(m)
                local entry = {
                    name = rName ~= "" and rName or m.Name,
                    mutation = mName ~= "" and mName or "Normal",
                    rarity = rName,
                    img = img,
                    isRobux = isRobux,
                    isRejected = isRejected,
                    model = m,
                    time = os.date("%H:%M:%S")
                }
                table.insert(Runtime.beltLog, 1, entry)
                if #Runtime.beltLog > 30 then
                    table.remove(Runtime.beltLog, 31)
                end

                -- SCAN logs removed from main history log per user request (only BUY, TOWER, and RAID logged)
            end
        end
    end

    -- Render historical belt scan feed into AFK.beltRows
    local logs = Runtime.beltLog or {}
    local slots = #AFK.beltRows
    local shown = math.min(#logs, slots)

    for i = 1, shown do
        local data = logs[i]
        local row = AFK.beltRows[i]

        local isRejected = data.isRejected
        local isBought = false
        if data.model and data.model.Parent then
            if data.model:GetAttribute("Rejected") then isRejected = true end
            if data.model:GetAttribute("LoggedBuy") then isBought = true end
        end

        local col = AFK_RARITY_COLOR[data.rarity] or AFK_COLOR.label
        row.CardTitle.Text = data.name .. (data.mutation ~= "" and (" [" .. data.mutation .. "]") or "")
        row.CardTitle.TextColor3 = col

        if row:FindFirstChild("CardIcon") then
            row.CardIcon.Image = (data.img and data.img ~= "") and data.img or "rbxassetid://10723415903"
        end

        if data.isRobux then
            row.StatusBadge.Text = "💎 Robux"
            row.StatusBadge.TextColor3 = AFK_COLOR.purple
        elseif isBought then
            row.StatusBadge.Text = "✅ ซื้อแล้ว"
            row.StatusBadge.TextColor3 = AFK_COLOR.green
        elseif isRejected then
            row.StatusBadge.Text = "❌ ข้าม"
            row.StatusBadge.TextColor3 = AFK_COLOR.red
        else
            row.StatusBadge.Text = "🎯 ผ่านสายพาน (" .. (data.time or "") .. ")"
            row.StatusBadge.TextColor3 = AFK_COLOR.orange
        end

        row.Visible = true
    end

    for i = shown + 1, slots do
        AFK.beltRows[i].Visible = false
    end
end

local function afkPaintInventory()
    if not AFK.on or not AFK.invList then return end
    local items = {}
    
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then table.insert(items, t) end end end
    if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(items, t) end end end

    local slots = #AFK.invRows
    local shown = math.min(#items, slots)

    for i = 1, shown do
        local tool = items[i]
        local row = AFK.invRows[i]
        local rName = getCardRank(tool)
        local mName = getCardMutation(tool)

        local col = AFK_RARITY_COLOR[rName] or AFK_COLOR.label2
        row.ItemName.Text = tool.Name
        row.ItemDetails.Text = ("Rank: %s | Mut: %s"):format(rName ~= "" and rName or "None", mName ~= "" and mName or "Normal")
        row.ItemDetails.TextColor3 = col

        if row:FindFirstChild("CardIcon") then
            local tImg = getCardImage(tool)
            row.CardIcon.Image = tImg
        end

        row.Visible = true
    end

    for i = shown + 1, slots do
        AFK.invRows[i].Visible = false
    end
end

local function afkPump()
    if AFK.wantShow then
        AFK.wantShow = false
        if AFK.gui then AFK.gui.Enabled = true end
        afkEnterLowPower()
    end
    if AFK.wantHide then
        AFK.wantHide = false
        if AFK.gui then AFK.gui.Enabled = false end
        afkExitLowPower()
    end

    if not AFK.on then return end

    if AFK.logDirty then
        AFK.logDirty = false
        afkPushLog(Runtime.log[1])
    end

    local sec = math.floor(os.clock() - AFK.startAt)
    if sec == AFK.lastSec then return end
    AFK.lastSec = sec

    local s = AFK.stat
    if s.bought then s.bought.Text = tostring(Runtime.stats.bought or 0) end
    if s.money  then s.money.Text  = getPlayerMoney() end
    if s.time   then s.time.Text   = afkClock(sec) end

    local tStatus, bStatus = getTowerAndBossStatus()
    if s.tower  then s.tower.Text  = tStatus end
    if s.boss   then s.boss.Text   = bStatus end

    pcall(afkPaintBelt)
    if sec % 3 == 0 then pcall(afkPaintInventory) end
end

local afkClose

local function afkBuild()
    pcall(function()
        if RunService and RunService.Set3dRenderingEnabled then
            RunService:Set3dRenderingEnabled(true)
        end
    end)
    pcall(function()
        if Runtime.afkGui then Runtime.afkGui:Destroy() end
        if AFK.gui then AFK.gui:Destroy() end
    end)
    pcall(function()
        local containers = {game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui")}
        if gethui then table.insert(containers, gethui()) end
        for _, parent in ipairs(containers) do
            if parent then
                for _, child in ipairs(parent:GetChildren()) do
                    if child.Name == "ANIME_AFK" or child.Name == "PayomboyZ_AFK" then
                        child:Destroy()
                    end
                end
            end
        end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "ANIME_AFK"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Enabled = false  -- ตั้ง disabled ทันทีตั้งแต่เริ่มสร้าง

    local parented = false
    pcall(function()
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
        parented = gui.Parent ~= nil
    end)
    if not parented then
        pcall(function() if gethui then gui.Parent = gethui() parented = true end end)
    end
    if not parented then
        pcall(function() gui.Parent = game:GetService("CoreGui") end)
    end

    local root = Instance.new("Frame")
    root.Name = "Root"
    root.BackgroundColor3 = AFK_COLOR.bg
    root.BorderSizePixel = 0
    root.Size = UDim2.fromScale(1, 1)
    root.Parent = gui


    local scale = Instance.new("UIScale")
    scale.Scale = AFK_TOUCH and 0.85 or 1.0
    scale.Parent = root

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Size = UDim2.fromScale(1, 1)
    body.ZIndex = 10
    body.Parent = root
    afkPad(body, 16)

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 44)
    header.Parent = body

    afkText(header, {
        text = "🌙 โหมด AFK (ไก่ตัน)", font = Enum.Font.GothamBold, size = 24,
        sizeUDim = UDim2.new(1, -200, 0, 28), pos = UDim2.fromOffset(0, 0),
    })
    afkText(header, {
        text = "Anime Card Auto Farming & Monitoring Dashboard", font = Enum.Font.Gotham, size = 11, color = AFK_COLOR.label3,
        sizeUDim = UDim2.new(1, -200, 0, 14), pos = UDim2.fromOffset(2, 28),
    })

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.Position = UDim2.new(1, 0, 0, 4)
    closeBtn.Size = UDim2.fromOffset(150, 36)
    closeBtn.BackgroundColor3 = AFK_COLOR.panel
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = true
    closeBtn.Font = Enum.Font.GothamMedium
    closeBtn.TextSize = 13
    closeBtn.TextColor3 = AFK_COLOR.red
    closeBtn.Text = "❌ ปิดโหมด AFK"
    closeBtn.Parent = header
    afkCorner(closeBtn, 10)
    afkStroke(closeBtn, AFK_COLOR.red, 1, 0.5)

    -- 5 Stat Cards Header Row
    local stats = Instance.new("Frame")
    stats.Name = "Stats"
    stats.BackgroundTransparency = 1
    stats.Position = UDim2.fromOffset(0, 52)
    stats.Size = UDim2.new(1, 0, 0, 64)
    stats.Parent = body

    local statLayout = Instance.new("UIListLayout")
    statLayout.FillDirection = Enum.FillDirection.Horizontal
    statLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statLayout.Padding = UDim.new(0, 8)
    statLayout.Parent = stats

    local function statCard(order, caption, value, color)
        local card = afkCard(stats, {
            size = UDim2.new(0.2, -7, 1, 0), radius = 12,
        })
        card.LayoutOrder = order
        afkText(card, {
            text = caption, font = Enum.Font.Gotham, size = 10, color = AFK_COLOR.label3,
            sizeUDim = UDim2.new(1, -16, 0, 12), pos = UDim2.fromOffset(10, 8),
        })
        local val = afkText(card, {
            text = value, font = Enum.Font.GothamBold, size = 16, color = color or AFK_COLOR.label,
            sizeUDim = UDim2.new(1, -16, 0, 34), pos = UDim2.fromOffset(10, 22), truncate = true,
        })
        return val
    end

    AFK.stat.bought = statCard(1, "📦 ซื้อการ์ดแล้ว", "0", AFK_COLOR.green)
    AFK.stat.money  = statCard(2, "💰 เงินในปัจจุบัน", "0", AFK_COLOR.yellow)
    AFK.stat.tower  = statCard(3, "🏰 หอคอย", "ไม่ได้ลง", AFK_COLOR.teal)
    AFK.stat.boss   = statCard(4, "🐉 บอสเรด", "เกิดใน 00:00", AFK_COLOR.orange)
    AFK.stat.time   = statCard(5, "⏱️ เวลา AFK", "00:00:00", AFK_COLOR.label)

    -- 3 Columns Layout
    local topOffset = 126
    local columns = Instance.new("Frame")
    columns.Name = "Columns"
    columns.BackgroundTransparency = 1
    columns.Position = UDim2.fromOffset(0, topOffset)
    columns.Size = UDim2.new(1, 0, 1, -topOffset)
    columns.Parent = body

    local function panel(order, widthScale, xScale, xOffset, title)
        local p = afkCard(columns, {
            size = UDim2.new(widthScale, -8, 1, 0),
            pos  = UDim2.new(xScale, xOffset, 0, 0),
            radius = 14,
        })
        p.LayoutOrder = order

        afkText(p, {
            text = title, font = Enum.Font.GothamMedium, size = 12, color = AFK_COLOR.label2,
            sizeUDim = UDim2.new(1, -24, 0, 16), pos = UDim2.fromOffset(12, 10),
        })

        local line = Instance.new("Frame")
        line.BackgroundColor3 = AFK_COLOR.separator
        line.BackgroundTransparency = 0.4
        line.BorderSizePixel = 0
        line.Position = UDim2.fromOffset(12, 30)
        line.Size = UDim2.new(1, -24, 0, 1)
        line.Parent = p

        local scroll = Instance.new("ScrollingFrame")
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.Position = UDim2.fromOffset(10, 36)
        scroll.Size = UDim2.new(1, -20, 1, -44)
        scroll.ScrollBarThickness = 2
        scroll.ScrollBarImageColor3 = AFK_COLOR.separator
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.new()
        scroll.Parent = p

        return p, scroll
    end

    local _, logScroll = panel(1, 0.33, 0, 0, "📜 ประวัติการทำงาน")

    -- Column 2 Container (Divided into 3 sub-panels)
    local col2 = Instance.new("Frame")
    col2.Name = "Col2Container"
    col2.BackgroundTransparency = 1
    col2.Position = UDim2.new(0.33, 4, 0, 0)
    col2.Size = UDim2.new(0.35, -8, 1, 0)
    col2.Parent = columns

    local col2Layout = Instance.new("UIListLayout")
    col2Layout.SortOrder = Enum.SortOrder.LayoutOrder
    col2Layout.Padding = UDim.new(0, 6)
    col2Layout.Parent = col2

    local function subPanel(order, heightScale, yOffset, title)
        local p = afkCard(col2, {
            size = UDim2.new(1, 0, heightScale, yOffset),
            radius = 12,
        })
        p.LayoutOrder = order

        afkText(p, {
            text = title, font = Enum.Font.GothamMedium, size = 11, color = AFK_COLOR.label2,
            sizeUDim = UDim2.new(1, -20, 0, 14), pos = UDim2.fromOffset(10, 6),
        })

        local line = Instance.new("Frame")
        line.BackgroundColor3 = AFK_COLOR.separator
        line.BackgroundTransparency = 0.4
        line.BorderSizePixel = 0
        line.Position = UDim2.fromOffset(10, 22)
        line.Size = UDim2.new(1, -20, 0, 1)
        line.Parent = p

        local scroll = Instance.new("ScrollingFrame")
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.Position = UDim2.fromOffset(8, 26)
        scroll.Size = UDim2.new(1, -16, 1, -30)
        scroll.ScrollBarThickness = 2
        scroll.ScrollBarImageColor3 = AFK_COLOR.separator
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.new()
        scroll.Parent = p

        return p, scroll
    end

    local _, beltScroll  = subPanel(1, 0.38, -4, "🎯 สแกนสายพานการ์ด")
    local _, traitScroll = subPanel(2, 0.31, -4, "🔮 สถานะการรี Trait")
    local _, rankScroll  = subPanel(3, 0.31, -4, "⭐ สถานะการรี Rank")

    local invPanel, invScroll = panel(3, 0.32, 0.68, 8, "🎒 การ์ดในกระเป๋า")

    local invRefreshBtn = Instance.new("TextButton")
    invRefreshBtn.Name = "RefreshInvBtn"
    invRefreshBtn.AnchorPoint = Vector2.new(1, 0)
    invRefreshBtn.Position = UDim2.new(1, -10, 0, 5)
    invRefreshBtn.Size = UDim2.fromOffset(75, 20)
    invRefreshBtn.BackgroundColor3 = AFK_COLOR.raised
    invRefreshBtn.BorderSizePixel = 0
    invRefreshBtn.Font = Enum.Font.GothamMedium
    invRefreshBtn.TextSize = 10
    invRefreshBtn.TextColor3 = AFK_COLOR.teal
    invRefreshBtn.Text = "🔄 รีเฟรช"
    invRefreshBtn.Parent = invPanel
    afkCorner(invRefreshBtn, 6)
    afkStroke(invRefreshBtn, AFK_COLOR.teal, 1, 0.5)

    invRefreshBtn.MouseButton1Click:Connect(function()
        pcall(afkPaintInventory)
        logLine("afk", "🔄 รีเฟรชรายการการ์ดในกระเป๋าเรียบร้อย")
    end)

    AFK.logList, AFK.beltList, AFK.invList = logScroll, beltScroll, invScroll

    -- Log Pool
    local logLayout = Instance.new("UIListLayout")
    logLayout.SortOrder = Enum.SortOrder.LayoutOrder
    logLayout.Padding = UDim.new(0, 4)
    logLayout.Parent = logScroll

    for i = 1, AFK_MAX_LOGS do
        local row = Instance.new("TextLabel")
        row.Name = "Log" .. i
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, -4, 0, 16)
        row.Font = Enum.Font.Code
        row.TextSize = 11
        row.TextColor3 = AFK_COLOR.label2
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.TextTruncate = Enum.TextTruncate.AtEnd
        row.Visible = false
        row.Text = ""
        row.Parent = logScroll
        AFK.pool[i] = row
    end

    -- Belt Pool
    local beltLayout = Instance.new("UIListLayout")
    beltLayout.SortOrder = Enum.SortOrder.LayoutOrder
    beltLayout.Padding = UDim.new(0, 4)
    beltLayout.Parent = beltScroll

    for i = 1, AFK_MAX_BELT do
        local row = Instance.new("Frame")
        row.Name = "Belt" .. i
        row.BackgroundColor3 = AFK_COLOR.raised
        row.Size = UDim2.new(1, 0, 0, 34)
        row.Visible = false
        afkCorner(row, 6)

        local icon = Instance.new("ImageLabel")
        icon.Name = "CardIcon"
        icon.Size = UDim2.fromOffset(26, 26)
        icon.Position = UDim2.fromOffset(4, 4)
        icon.BackgroundColor3 = AFK_COLOR.bg
        icon.BackgroundTransparency = 0.2
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Parent = row
        afkCorner(icon, 6)

        local t = afkText(row, {
            text = "", font = Enum.Font.GothamMedium, size = 11, truncate = true,
            sizeUDim = UDim2.new(0.68, -34, 1, 0), pos = UDim2.fromOffset(34, 0),
        })
        t.Name = "CardTitle"

        local st = afkText(row, {
            text = "", font = Enum.Font.GothamBold, size = 10, align = Enum.TextXAlignment.Right,
            sizeUDim = UDim2.new(0.32, -8, 1, 0), pos = UDim2.new(0.68, 0, 0, 0),
        })
        st.Name = "StatusBadge"

        row.Parent = beltScroll
        AFK.beltRows[i] = row
    end

    -- Trait Log Pool
    AFK.traitPool = {}
    local traitLayout = Instance.new("UIListLayout")
    traitLayout.SortOrder = Enum.SortOrder.LayoutOrder
    traitLayout.Padding = UDim.new(0, 3)
    traitLayout.Parent = traitScroll

    for i = 1, AFK_MAX_TRAIT do
        local row = Instance.new("TextLabel")
        row.Name = "TraitLog" .. i
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, -4, 0, 16)
        row.Font = Enum.Font.Code
        row.TextSize = 10
        row.TextColor3 = AFK_COLOR.purple
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.TextTruncate = Enum.TextTruncate.AtEnd
        row.Visible = false
        row.Text = ""
        row.Parent = traitScroll
        AFK.traitPool[i] = row
    end

    -- Rank Log Pool
    AFK.rankPool = {}
    local rankLayout = Instance.new("UIListLayout")
    rankLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rankLayout.Padding = UDim.new(0, 3)
    rankLayout.Parent = rankScroll

    for i = 1, AFK_MAX_RANK do
        local row = Instance.new("TextLabel")
        row.Name = "RankLog" .. i
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, -4, 0, 16)
        row.Font = Enum.Font.Code
        row.TextSize = 10
        row.TextColor3 = AFK_COLOR.yellow
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.TextTruncate = Enum.TextTruncate.AtEnd
        row.Visible = false
        row.Text = ""
        row.Parent = rankScroll
        AFK.rankPool[i] = row
    end

    -- Inventory Pool
    local invLayout = Instance.new("UIListLayout")
    invLayout.SortOrder = Enum.SortOrder.LayoutOrder
    invLayout.Padding = UDim.new(0, 4)
    invLayout.Parent = invScroll

    for i = 1, AFK_MAX_CARDS do
        local row = Instance.new("Frame")
        row.Name = "Inv" .. i
        row.BackgroundColor3 = AFK_COLOR.raised
        row.Size = UDim2.new(1, 0, 0, 34)
        row.Visible = false
        afkCorner(row, 6)

        local icon = Instance.new("ImageLabel")
        icon.Name = "CardIcon"
        icon.Size = UDim2.fromOffset(26, 26)
        icon.Position = UDim2.fromOffset(4, 4)
        icon.BackgroundColor3 = AFK_COLOR.bg
        icon.BackgroundTransparency = 0.2
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Parent = row
        afkCorner(icon, 6)

        local nm = afkText(row, {
            text = "", font = Enum.Font.GothamMedium, size = 11, truncate = true,
            sizeUDim = UDim2.new(0.55, -34, 1, 0), pos = UDim2.fromOffset(34, 0),
        })
        nm.Name = "ItemName"

        local dt = afkText(row, {
            text = "", font = Enum.Font.Gotham, size = 10, align = Enum.TextXAlignment.Right, truncate = true,
            sizeUDim = UDim2.new(0.45, -8, 1, 0), pos = UDim2.new(0.55, 0, 0, 0),
        })
        dt.Name = "ItemDetails"

        row.Parent = invScroll
        AFK.invRows[i] = row
    end

    closeBtn.MouseButton1Click:Connect(function()
        afkClose()
    end)

    AFK.gui = gui
    Runtime.afkGui = gui
end

local function afkOpen()
    AFK.on = true
    AFK.startAt = os.clock()
    AFK.lastSec = -1
    AFK.wantShow = true
    if AFK.gui then AFK.gui.Enabled = true end
    afkEnterLowPower()
    afkSeedLogs()
    
    -- 🛡️ Automatically activate Anti-AFK Engine when entering AFK Mode
    activateAntiAfk()
    if Options and Options.AntiAfkState then
        pcall(function() Options.AntiAfkState:SetValue(true) end)
    end

    logLine("afk", "เปิดใช้งานโหมด AFK (ไก่ตัน) เรียบร้อย")
    logLine("afk", "🛡️ เปิดใช้งานระบบป้องกันหลุด (Anti-AFK) อัตโนมัติ")
end

afkClose = function()
    AFK.on = false
    AFK.wantHide = true
    if AFK.gui then AFK.gui.Enabled = false end
    afkExitLowPower()
    
    if not getgenv().AntiAfkState then
        deactivateAntiAfk()
    end
    
    -- ล้างประวัติ Log และเคลียร์ Memory ใน UI Pool เพื่อไม่ให้หนักเครื่อง
    pcall(function()
        Runtime.log = {}
        Runtime.traitLog = {}
        Runtime.rankLog = {}
        Runtime.beltLog = {}
        
        AFK.poolHead = 0
        AFK.traitHead = 0
        AFK.rankHead = 0
        
        if AFK.pool then
            for i = 1, #AFK.pool do
                local r = AFK.pool[i]
                if r then r.Visible = false; r.Text = "" end
            end
        end
        if AFK.traitPool then
            for i = 1, #AFK.traitPool do
                local r = AFK.traitPool[i]
                if r then r.Visible = false; r.Text = "" end
            end
        end
        if AFK.rankPool then
            for i = 1, #AFK.rankPool do
                local r = AFK.rankPool[i]
                if r then r.Visible = false; r.Text = "" end
            end
        end
        if AFK.beltRows then
            for i = 1, #AFK.beltRows do
                local r = AFK.beltRows[i]
                if r then r.Visible = false end
            end
        end
        if AFK.invRows then
            for i = 1, #AFK.invRows do
                local r = AFK.invRows[i]
                if r then r.Visible = false end
            end
        end
        
        getgenv().PromptCooldowns = {}
        getgenv().NotifiedCards = {}
    end)
    
    if Options and Options.AFKModeToggle then
        pcall(function() Options.AFKModeToggle:SetValue(false) end)
    end
    if Fluent and Fluent.Notify then
        Fluent:Notify({ Title = "โหมด AFK", Content = "ปิดโหมด AFK แล้ว — ล้างประวัติ Log และคืนค่าปกติเรียบร้อย", Duration = 3 })
    end
end

afkBuild()
-- Force-disable และ reset สถานะ AFK ทั้งหมด ป้องกัน loadConfig หรือ pump เก่าเปิดขึ้นมาเอง
AFK.on = false
AFK.wantShow = false
AFK.wantHide = false
if AFK.gui then AFK.gui.Enabled = false end

if AFK.conns.pump then AFK.conns.pump:Disconnect() end
-- [OPT] Throttle afkPump: รัน max 10 ครั้ง/วินาที แทน 60 ครั้ง/วินาที
local _afkPumpLast = 0
AFK.conns.pump = RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - _afkPumpLast < 0.10 then return end
    _afkPumpLast = now
    pcall(afkPump)
end)
getgenv().AFK_PumpConn = AFK.conns.pump  -- เก็บไว้เพื่อ disconnect ตอน re-run

---------------------------------------------------------
-- 1. MAIN TAB (หลัก)
---------------------------------------------------------
local AFKToggle = Tabs.Main:AddToggle("AFKModeToggle", { Title = "🌙 เปิดโหมด AFK (ไก่ตัน)", Default = false })
AFKToggle:OnChanged(function(state)
    if state then
        afkOpen()
    else
        afkClose()
    end
end)

Tabs.Main:AddButton({
    Title = "🚀 เปิดหน้าต่างโหมด AFK ทันที (Full Screen)",
    Callback = function()
        if Options and Options.AFKModeToggle then
            Options.AFKModeToggle:SetValue(true)
        else
            afkOpen()
        end
    end
})

Tabs.Main:AddButton({
    Title = "📋 คัดลอกรายการช่องเก็บของ",
    Description = "คัดลอกข้อมูลการ์ดในกระเป๋าลง Clipboard",
    Callback = function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local char = LocalPlayer.Character
        local items = {}
        local function checkItem(t)
            if t:IsA("Tool") then
                local cardName = t:GetAttribute("CardName")
                if cardName then
                    local mutation = tostring(t:GetAttribute("CardMutation") or "Normal")
                    local grade = tostring(t:GetAttribute("CardGrade") or "N/A")
                    local level = tonumber(t:GetAttribute("CardLevel")) or 1
                    table.insert(items, string.format("[Card] %s | Lvl: %d | Mutation: %s | Grade: %s", cardName, level, mutation, grade))
                    return
                end
                local packName = t:GetAttribute("TemplateName")
                if packName then
                    local mutation = tostring(t:GetAttribute("Mutation") or "Normal")
                    local rarity = tostring(t:GetAttribute("Rarity") or "N/A")
                    table.insert(items, string.format("[Pack] %s | Rarity: %s | Mutation: %s", packName, rarity, mutation))
                    return
                end
                table.insert(items, string.format("[Item] %s", t.Name))
            end
        end
        if backpack then for _, t in ipairs(backpack:GetChildren()) do checkItem(t) end end
        if char then for _, t in ipairs(char:GetChildren()) do checkItem(t) end end
        
        if #items > 0 then
            local resultText = "Inventory Summary:\n" .. table.concat(items, "\n")
            if setclipboard then
                setclipboard(resultText)
                Fluent:Notify({ Title = "ช่องเก็บของ", Content = "คัดลอกสำเร็จลง Clipboard!", Duration = 3 })
            else
                Fluent:Notify({ Title = "ข้อผิดพลาด", Content = "ตัวรันไม่รองรับ setclipboard!", Duration = 3 })
            end
        else
            Fluent:Notify({ Title = "ช่องเก็บของ", Content = "ช่องเก็บของว่างเปล่า!", Duration = 3 })
        end
    end
})

local AutoSpawnToggle = Tabs.Main:AddToggle("AutoSpawnPack", { Title = "🎲 สุ่มแพ็กอัตโนมัติ", Default = false })
AutoSpawnToggle:OnChanged(function(state)
    getgenv().AutoSpawnPack = state
    if state then
        task.spawn(function()
            local cd = nil
            local retryCount = 0
            while getgenv().AutoSpawnPack do
                if not cd or not cd.Parent then
                    cd = getSpawnPackClickDetector()
                end
                if not cd then
                    retryCount = retryCount + 1
                    if retryCount > 15 then
                        Fluent:Notify({ Title = "ข้อผิดพลาด", Content = "ไม่พบปุ่มสุ่มแพ็กใน Plot!", Duration = 3 })
                        getgenv().AutoSpawnPack = false
                        AutoSpawnToggle:SetValue(false)
                        return
                    end
                    task.wait(1)
                    continue
                end
                retryCount = 0
                if not getgenv().CardFolder then findCardFolder() end
                local activeCards = 0
                if getgenv().CardFolder then
                    for _, model in ipairs(getgenv().CardFolder:GetChildren()) do
                        if model:IsA("Model") and model:GetAttribute("IgnoreTutoBeam") ~= nil and model:FindFirstChildWhichIsA("ProximityPrompt", true) then
                            if getgenv().AutoBuyCards and model:GetAttribute("Rejected") then continue end
                            activeCards = activeCards + 1
                        end
                    end
                end
                pcall(fireclickdetector, cd)
                local userDelay = tonumber(getgenv().AutoSpawnDelay) or 0.01
                if activeCards >= 3 then
                    task.wait(math.max(userDelay, 0.12))
                else
                    task.wait(userDelay)
                end
            end
        end)
    end
end)

getgenv().AutoSpawnDelay = getgenv().AutoSpawnDelay or 0.01
local AutoSpawnSlider = Tabs.Main:AddSlider("AutoSpawnDelay", {
    Title = "⏱️ ความเร็วการสุ่มแพ็ก (วินาที)",
    Description = "ปรับระยะเวลารอระหว่างการกดสุ่มแพ็กแต่ละรอบ",
    Default = 0.01,
    Min = 0,
    Max = 2,
    Rounding = 2
})
AutoSpawnSlider:OnChanged(function(Value)
    getgenv().AutoSpawnDelay = Value
end)

local RarityDropdown = Tabs.Main:AddDropdown("SelectedRarities", {
    Title = "✨ เลือกความหายากที่ต้องการซื้อ",
    Values = RaritiesList,
    Multi = true,
    Default = {}
})
RarityDropdown:OnChanged(function(Value)
    getgenv().SelectedRarities = {}
    if type(Value) == "table" then
        for k, v in pairs(Value) do
            if type(k) == "number" then
                getgenv().SelectedRarities[string.lower(tostring(v))] = true
            elseif v == true then
                getgenv().SelectedRarities[string.lower(tostring(k))] = true
            end
        end
    end
end)

local MutationDropdown = Tabs.Main:AddDropdown("SelectedMutations", {
    Title = "🧬 เลือกกลายพันธุ์ที่ต้องการซื้อ",
    Values = MutationsList,
    Multi = true,
    Default = {}
})
MutationDropdown:OnChanged(function(Value)
    getgenv().SelectedMutations = {}
    if type(Value) == "table" then
        for k, v in pairs(Value) do
            if type(k) == "number" then
                getgenv().SelectedMutations[string.lower(tostring(v))] = true
            elseif v == true then
                getgenv().SelectedMutations[string.lower(tostring(k))] = true
            end
        end
    end
end)

---------------------------------------------------------
-- 🔄 LIVE DROPDOWN AUTO-SCANNER (Rarity & Mutation)
-- สแกน CardFolder อัตโนมัติ: ดึง Rarity/Mutation ใหม่จากสายพาน
-- Dev อัพ Pack ใหม่ → dropdown อัพเดทเองไม่ต้องมาแก้โค้ด
---------------------------------------------------------
do
    local _liveDropdownKnownRarities = {}   -- set ของ rarity ที่รู้จักแล้ว (lowercase)
    local _liveDropdownKnownMutations = {}  -- set ของ mutation ที่รู้จักแล้ว (lowercase)
    local _liveDropdownRarityList = {}      -- ordered list สำหรับ dropdown
    local _liveDropdownMutationList = {}    -- ordered list สำหรับ dropdown

    -- seed จาก hardcoded list เดิม ไม่ให้หาย
    for _, r in ipairs(RaritiesList) do
        local k = string.lower(r)
        if not _liveDropdownKnownRarities[k] then
            _liveDropdownKnownRarities[k] = true
            table.insert(_liveDropdownRarityList, r)
        end
    end
    for _, m in ipairs(MutationsList) do
        local k = string.lower(m)
        if not _liveDropdownKnownMutations[k] then
            _liveDropdownKnownMutations[k] = true
            table.insert(_liveDropdownMutationList, m)
        end
    end

    -- ฟังก์ชันดึง Rarity/Mutation จาก model บนสายพาน (ใช้ตรรกะเดียวกับ getCardModelRarityAndMutation)
    local function _liveExtractRarityMutation(model)
        if not model or not model:IsA("Model") then return nil, nil end
        -- ตรวจสอบว่าเป็นการ์ดจริง (ไม่ใช่ Pack, Boss, Ticket)
        if model:GetAttribute("IgnoreTutoBeam") == nil then return nil, nil end

        local rarity = model:GetAttribute("Rarity") or model:GetAttribute("CardGrade")
            or model:GetAttribute("Grade") or model:GetAttribute("CardRarity")
        local mutation = model:GetAttribute("Mutation") or model:GetAttribute("CardMutation")

        rarity = rarity and tostring(rarity) or ""
        mutation = mutation and tostring(mutation) or ""

        -- fallback: สแกน TextLabel ถ้า attribute ว่าง
        if rarity == "" or rarity == "nil" then
            for _, childName in ipairs({"Rarity", "CardGrade", "Grade", "CardRarity", "RarityLabel"}) do
                local obj = model:FindFirstChild(childName, true)
                if obj then
                    if obj:IsA("StringValue") and obj.Value ~= "" then
                        rarity = obj.Value; break
                    elseif (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text ~= "" then
                        local cl = string.match(string.gsub(obj.Text, "<[^>]+>", ""), "^%s*(.-)%s*$") or ""
                        if cl ~= "" and cl ~= "Label" then rarity = cl; break end
                    end
                end
            end
        end
        if mutation == "" or mutation == "nil" then
            for _, childName in ipairs({"Mutation", "CardMutation", "MutationLabel"}) do
                local obj = model:FindFirstChild(childName, true)
                if obj then
                    if obj:IsA("StringValue") and obj.Value ~= "" then
                        mutation = obj.Value; break
                    elseif (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text ~= "" then
                        local cl = string.match(string.gsub(obj.Text, "<[^>]+>", ""), "^%s*(.-)%s*$") or ""
                        if cl ~= "" and cl ~= "Label" then mutation = cl; break end
                    end
                end
            end
        end

        -- sanitize: ต้องเป็น string ที่มีตัวอักษร ไม่ใช่ตัวเลขล้วน/ว่าง
        rarity = (rarity ~= "" and rarity ~= "nil" and not tonumber(rarity)) and rarity or nil
        mutation = (mutation ~= "" and mutation ~= "nil" and not tonumber(mutation)) and mutation or nil
        return rarity, mutation
    end

    -- merge ค่าใหม่เข้า list และอัพ dropdown ถ้ามีของใหม่
    local function _liveDropdownTryAdd(model)
        local rarity, mutation = _liveExtractRarityMutation(model)
        local changed = false

        if rarity then
            local key = string.lower(rarity)
            -- กรอง noise: ต้องมีความยาว 2-40 ตัวอักษร ไม่มีตัวเลข ไม่มีอักขระพิเศษ
            if #key >= 2 and #key <= 40 and not string.match(key, "[%d%$%%#@!&%*%(%)%+%=]") then
                if not _liveDropdownKnownRarities[key] then
                    _liveDropdownKnownRarities[key] = true
                    -- Capitalize first letter เพื่อให้สวยงาม
                    local displayRarity = string.upper(string.sub(rarity, 1, 1)) .. string.sub(rarity, 2)
                    table.insert(_liveDropdownRarityList, displayRarity)
                    changed = true
                end
            end
        end

        if mutation then
            local key = string.lower(mutation)
            if #key >= 2 and #key <= 40 and not string.match(key, "[%d%$%%#@!&%*%(%)%+%=]") and key ~= "normal" then
                if not _liveDropdownKnownMutations[key] then
                    _liveDropdownKnownMutations[key] = true
                    local displayMut = string.upper(string.sub(mutation, 1, 1)) .. string.sub(mutation, 2)
                    table.insert(_liveDropdownMutationList, displayMut)
                    changed = true
                end
            end
        end

        return changed
    end

    -- อัพเดท dropdown UI (SetValues) — ทำใน task.defer เพื่อไม่ block main loop
    local _liveDropdownUpdatePending = false
    local function _liveDropdownFlushUpdate()
        if _liveDropdownUpdatePending then return end
        _liveDropdownUpdatePending = true
        task.defer(function()
            _liveDropdownUpdatePending = false
            pcall(function()
                if RarityDropdown and RarityDropdown.SetValues then
                    RarityDropdown:SetValues(_liveDropdownRarityList)
                end
            end)
            pcall(function()
                if MutationDropdown and MutationDropdown.SetValues then
                    MutationDropdown:SetValues(_liveDropdownMutationList)
                end
            end)
        end)
    end

    -- Background watcher: เช็ค CardFolder ทุก 8 วินาที หาของใหม่
    task.spawn(function()
        -- รอ script init เสร็จก่อน
        task.wait(5)
        local _lastFullScanTick = 0

        while true do
            task.wait(8)
            pcall(function()
                -- ถ้า CardFolder ยังไม่มี ลองหา
                if not getgenv().CardFolder or not getgenv().CardFolder.Parent then
                    findCardFolder()
                end
                local folder = getgenv().CardFolder
                if not folder then return end

                local anyNew = false
                local now = tick()

                -- Full scan ทุก 60 วินาที หรือเมื่อ scan ครั้งแรก
                if now - _lastFullScanTick >= 60 then
                    _lastFullScanTick = now
                    for _, model in ipairs(folder:GetChildren()) do
                        if _liveDropdownTryAdd(model) then anyNew = true end
                    end
                end

                -- ฟัง ChildAdded สำหรับการ์ดที่เพิ่งเข้าสายพาน (เชื่อมต่อเพียงครั้งเดียว)
                if not getgenv()._liveDropdownFolderConn or not getgenv()._liveDropdownFolderConnValid then
                    getgenv()._liveDropdownFolderConnValid = true
                    local connFolder = folder
                    getgenv()._liveDropdownFolderConn = connFolder.ChildAdded:Connect(function(child)
                        pcall(function()
                            task.wait(0.2)  -- รอ attribute โหลด
                            if _liveDropdownTryAdd(child) then
                                _liveDropdownFlushUpdate()
                            end
                        end)
                    end)
                    -- disconnect เมื่อ folder หาย
                    connFolder.AncestryChanged:Connect(function()
                        if not connFolder.Parent then
                            getgenv()._liveDropdownFolderConnValid = false
                            pcall(function()
                                if getgenv()._liveDropdownFolderConn then
                                    getgenv()._liveDropdownFolderConn:Disconnect()
                                end
                            end)
                        end
                    end)
                end

                if anyNew then _liveDropdownFlushUpdate() end
            end)
        end
    end)

    -- สแกนทันทีเมื่อกดปุ่ม Manual scan
    Tabs.Main:AddButton({
        Title = "🔍 สแกน Rarity/Mutation จากสายพานทันที",
        Description = "อัพเดท dropdown รายการ Rarity และ Mutation ตามการ์ดจริงในเกมตอนนี้",
        Callback = function()
            task.spawn(function()
                if not getgenv().CardFolder or not getgenv().CardFolder.Parent then
                    findCardFolder()
                end
                local folder = getgenv().CardFolder
                local found = 0
                if folder then
                    for _, model in ipairs(folder:GetChildren()) do
                        if _liveDropdownTryAdd(model) then found = found + 1 end
                    end
                    _liveDropdownFlushUpdate()
                end
                Fluent:Notify({
                    Title = "สแกน Dropdown",
                    Content = found > 0
                        and ("พบ Rarity/Mutation ใหม่ " .. tostring(found) .. " รายการ! อัพเดท dropdown แล้ว")
                        or "ไม่พบ Rarity/Mutation ใหม่ (ครบแล้ว)",
                    Duration = 3
                })
            end)
        end
    })
end
---------------------------------------------------------

local function getCardModelRarityAndMutation(model)
    if not model then return "", "Normal" end

    local rarity = model:GetAttribute("Rarity") or model:GetAttribute("CardGrade") or model:GetAttribute("Grade") or model:GetAttribute("CardRarity")
    local mutation = model:GetAttribute("Mutation") or model:GetAttribute("CardMutation")

    rarity = rarity and tostring(rarity) or ""
    mutation = mutation and tostring(mutation) or "Normal"

    if rarity == "" or rarity == "nil" then
        for _, childName in ipairs({"Rarity", "CardGrade", "Grade", "CardRarity", "RarityLabel"}) do
            local obj = model:FindFirstChild(childName, true)
            if obj then
                if obj:IsA("StringValue") and obj.Value ~= "" then
                    rarity = obj.Value
                    break
                elseif (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text ~= "" then
                    local cl = string.gsub(obj.Text, "<[^>]+>", "")
                    cl = string.match(cl, "^%s*(.-)%s*$") or ""
                    if cl ~= "" and cl ~= "Label" then
                        rarity = cl
                        break
                    end
                end
            end
        end
    end

    if mutation == "" or mutation == "Normal" or mutation == "nil" then
        for _, childName in ipairs({"Mutation", "CardMutation", "MutationLabel"}) do
            local obj = model:FindFirstChild(childName, true)
            if obj then
                if obj:IsA("StringValue") and obj.Value ~= "" then
                    mutation = obj.Value
                    break
                elseif (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text ~= "" then
                    local cl = string.gsub(obj.Text, "<[^>]+>", "")
                    cl = string.match(cl, "^%s*(.-)%s*$") or ""
                    if cl ~= "" and cl ~= "Label" then
                        mutation = cl
                        break
                    end
                end
            end
        end
    end

    if rarity == "" then
        for _, desc in ipairs(model:GetDescendants()) do
            if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Text then
                local cl = string.lower(string.gsub(desc.Text, "<[^>]+>", ""))
                for _, rName in ipairs(RaritiesList or {"common", "uncommon", "rare", "epic", "legendary", "mythical", "secret", "godly", "admin", "grail", "blaze", "conquest", "devour"}) do
                    if cl:find(string.lower(rName)) then
                        rarity = rName
                        break
                    end
                end
                if rarity ~= "" then break end
            end
        end
    end

    return rarity, mutation
end

-- Heartbeat High-Frequency Instant Buy Loop (Unthrottled Zero-Delay Remote Trigger)
local function instantBuyLoop()
    if not getgenv().AutoBuyCards then return end
    if not getgenv().CardFolder then findCardFolder() end
    if not getgenv().CardFolder then return end

    for _, model in ipairs(getgenv().CardFolder:GetChildren()) do
        if not model:IsA("Model") or model:GetAttribute("IgnoreTutoBeam") == nil then continue end
        if model:GetAttribute("Rejected") == true then continue end

        local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not prompt then continue end
        
        -- Filter out Robux prompts
        local promptTxt = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Name):lower()
        if promptTxt:find("robux") or promptTxt:find("r%$") or prompt:GetAttribute("IsRobux") or model:GetAttribute("IsRobux") then
            model:SetAttribute("Rejected", true)
            continue
        end

        local firstSeen = model:GetAttribute("FirstSeen")
        if not firstSeen then
            model:SetAttribute("FirstSeen", tick())
            firstSeen = tick()
        end

        local buyAttempts = tonumber(model:GetAttribute("BuyAttempts")) or 0
        if buyAttempts >= 40 or (tick() - firstSeen > 25) then
            model:SetAttribute("Rejected", true)
            continue
        end

        local cardRarity, cardMutation = getCardModelRarityAndMutation(model)
        local cardRarityLower = string.lower(cardRarity or "")
        local cardMutLower = string.lower(cardMutation or "")
        local modelNameLower = string.lower(model.Name or "")
        local templateNameLower = string.lower(tostring(model:GetAttribute("TemplateName") or model:GetAttribute("CardName") or ""))

        local hasRaritiesSelected = (getgenv().SelectedRarities and next(getgenv().SelectedRarities) ~= nil)
        local hasMutationsSelected = (getgenv().SelectedMutations and next(getgenv().SelectedMutations) ~= nil)

        local matchRarity = not hasRaritiesSelected
        if hasRaritiesSelected then
            if cardRarityLower ~= "" and getgenv().SelectedRarities[cardRarityLower] == true then
                matchRarity = true
            else
                for selRarity, _ in pairs(getgenv().SelectedRarities or {}) do
                    if selRarity ~= "" then
                        if (cardRarityLower ~= "" and cardRarityLower:find(selRarity, 1, true))
                           or selRarity:find(cardRarityLower, 1, true)
                           or modelNameLower:find(selRarity, 1, true)
                           or templateNameLower:find(selRarity, 1, true) then
                            matchRarity = true
                            break
                        end
                    end
                end
            end
        end

        local matchMutation = not hasMutationsSelected
        if hasMutationsSelected then
            if cardMutLower ~= "" and getgenv().SelectedMutations[cardMutLower] == true then
                matchMutation = true
            else
                for selMut, _ in pairs(getgenv().SelectedMutations or {}) do
                    if selMut ~= "" then
                        if (cardMutLower ~= "" and cardMutLower:find(selMut, 1, true))
                           or selMut:find(cardMutLower, 1, true) then
                            matchMutation = true
                            break
                        end
                    end
                end
            end
        end

        if not hasRaritiesSelected and not hasMutationsSelected then
            matchRarity = true
            matchMutation = true
        end

        if matchRarity and matchMutation then
            local now = tick()
            if not getgenv().PromptCooldowns[prompt] or now - getgenv().PromptCooldowns[prompt] >= 0.01 then
                getgenv().PromptCooldowns[prompt] = now
                model:SetAttribute("BuyAttempts", buyAttempts + 1)
                pcall(function()
                    prompt.RequiresLineOfSight = false
                    prompt.MaxActivationDistance = 99999
                    fireproximityprompt(prompt)
                    task.defer(function() fireproximityprompt(prompt) end)
                    if getconnections then
                        for _, conn in ipairs(getconnections(prompt.Triggered)) do pcall(function() conn:Fire(LocalPlayer) end) end
                    end
                end)

                -- Update AFK Stats & Log (Only once per card model)
                if not model:GetAttribute("LoggedBuy") then
                    model:SetAttribute("LoggedBuy", true)
                    if getgenv().AFKRuntime and getgenv().AFKRuntime.stats then
                        getgenv().AFKRuntime.stats.bought = (getgenv().AFKRuntime.stats.bought or 0) + 1
                        local rLow = cardRarityLower
                        if rLow:find("zenith") or rLow:find("secret") or rLow:find("divine") or rLow:find("godly") or rLow:find("cosmic") or rLow:find("eternal") or rLow:find("transcendent") then
                            getgenv().AFKRuntime.stats.secret = (getgenv().AFKRuntime.stats.secret or 0) + 1
                        end
                    end
                    if logLine then
                        local pName = cardRarity ~= "" and cardRarity or model.Name
                        logLine("buy", ("ซื้อสำเร็จ: %s [%s]"):format(pName, cardMutation ~= "" and cardMutation or "Normal"))
                    end
                end

                if getgenv().DiscordWebhook and getgenv().DiscordWebhook ~= "" then
                    if not getgenv().NotifiedCards then getgenv().NotifiedCards = {} end
                    if not getgenv().NotifiedCards[prompt] then
                        getgenv().NotifiedCards[prompt] = true
                        task.spawn(function()
                            SendWebhook(getgenv().DiscordWebhook, cardRarity ~= "" and cardRarity or "Card", cardMutation)
                        end)
                    end
                end
            end
        else
            local scanCount = (tonumber(model:GetAttribute("ScanAttempts")) or 0) + 1
            model:SetAttribute("ScanAttempts", scanCount)
            if scanCount >= 4 then
                model:SetAttribute("Rejected", true)
            end
        end
    end
end

if getgenv().BruteForceLoop then getgenv().BruteForceLoop:Disconnect() end
getgenv().BruteForceLoop = RunService.Heartbeat:Connect(instantBuyLoop)

local AutoBuyToggle = Tabs.Main:AddToggle("AutoBuyCards", { Title = "⚡ ซื้อการ์ดที่เลือกทันที (Auto Buy)", Default = false })
AutoBuyToggle:OnChanged(function(state)
    getgenv().AutoBuyCards = state
end)


local AutoCarryToggle = Tabs.Main:AddToggle("AutoCarry", { Title = "💰 เก็บเงินอัตโนมัติ (Carry)", Default = false })
AutoCarryToggle:OnChanged(function(state)
    getgenv().AutoCarry = state
    if state then
        task.spawn(function()
            while getgenv().AutoCarry do
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local searchArea = findPlayerPlot() or workspace
                
                for _, prompt in ipairs(searchArea:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local txt = (prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Name):lower()
                        local fullTxt = prompt.ActionText .. " " .. prompt.ObjectText .. " " .. prompt.Name
                        if txt:find("carry") or txt:find("collect") or txt:find("cash") or fullTxt:find("พก") or fullTxt:find("เก็บ") then
                            pcall(function()
                                local targetPos
                                if prompt.Parent:IsA("BasePart") then
                                    targetPos = prompt.Parent.Position
                                elseif prompt.Parent:IsA("Attachment") then
                                    targetPos = prompt.Parent.WorldPosition
                                elseif prompt.Parent:IsA("Model") and prompt.Parent.PrimaryPart then
                                    targetPos = prompt.Parent.PrimaryPart.Position
                                end
                                local originalCFrame
                                if hrp and targetPos then
                                    originalCFrame = hrp.CFrame
                                    hrp.CFrame = CFrame.new(targetPos) + Vector3.new(0, 3, 0)
                                    task.wait(0.2)
                                end
                                prompt.RequiresLineOfSight = false
                                prompt.MaxActivationDistance = 99999
                                fireproximityprompt(prompt)
                                task.wait(0.1)
                                if originalCFrame and hrp then hrp.CFrame = originalCFrame end
                            end)
                        end
                    end
                end
                
                local delayTime = tonumber(getgenv().AutoCarryDelay) or 5
                if delayTime < 1 then delayTime = 1 end
                local elapsed = 0
                while getgenv().AutoCarry and elapsed < (delayTime * 60) do
                    task.wait(1)
                    elapsed = elapsed + 1
                end
                task.wait(1)
            end
        end)
    end
end)

local AutoCarrySlider = Tabs.Main:AddSlider("AutoCarryDelay", {
    Title = "⏳ หน่วงเวลาเก็บเงิน (นาที)",
    Description = "รอบเวลารอในการเก็บเงินอัตโนมัติ",
    Default = 5,
    Min = 1,
    Max = 30,
    Rounding = 0
})
AutoCarrySlider:OnChanged(function(Value)
    getgenv().AutoCarryDelay = Value
end)

local AutoSellBoxToggle = Tabs.Main:AddToggle("AutoSellBox", { Title = "📦 ขายกล่องอัตโนมัติ", Default = false })
AutoSellBoxToggle:OnChanged(function(state)
    getgenv().AutoSellBox = state
    if state then
        task.spawn(function()
            while getgenv().AutoSellBox do
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local boxTool = nil
                
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and (tool:GetAttribute("BoxValue") ~= nil or tool.Name:find("Box")) then
                            boxTool = tool
                            break
                        end
                    end
                end
                if boxTool and character and character:FindFirstChild("Humanoid") then
                    character.Humanoid:EquipTool(boxTool)
                    task.wait(0.2)
                end
                
                local isEquipped = false
                if character then
                    for _, tool in ipairs(character:GetChildren()) do
                        if tool:IsA("Tool") and (tool:GetAttribute("BoxValue") ~= nil or tool.Name:find("Box")) then
                            isEquipped = true
                            break
                        end
                    end
                end
                
                if isEquipped and hrp then
                    local plotFolder = findPlayerPlot()
                    if plotFolder and plotFolder:FindFirstChild("Plot_N0") and plotFolder.Plot_N0:FindFirstChild("SellPart") then
                        local sellPart = plotFolder.Plot_N0.SellPart
                        local prompt = sellPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            pcall(function()
                                local originalCFrame = hrp.CFrame
                                hrp.CFrame = sellPart.CFrame + Vector3.new(0, 3, 0)
                                task.wait(0.3)
                                prompt.RequiresLineOfSight = false
                                local timeout = 0
                                while character:FindFirstChildWhichIsA("Tool") and timeout < 30 do
                                    fireproximityprompt(prompt)
                                    task.wait(0.1)
                                    timeout = timeout + 1
                                end
                                if hrp then hrp.CFrame = originalCFrame end
                            end)
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

local AntiAfkToggle = Tabs.Main:AddToggle("AntiAfkState", { Title = "🛡️ ป้องกันหลุด (Anti AFK)", Default = false })
AntiAfkToggle:OnChanged(function(state)
    getgenv().AntiAfkState = state
    if state then
        activateAntiAfk()
    else
        if not (getgenv().AFK_Obj and getgenv().AFK_Obj.on) then
            deactivateAntiAfk()
        end
    end
end)

---------------------------------------------------------
-- 2. REROLL TAB (รีโรล)
---------------------------------------------------------
local TraitsList = {
    "Fortune I", "Vigor I", "Strength I", "Fortune II", "Vigor II", "Strength II",
    "Fortune III", "Vigor III", "Strength III", "Assassin", "Berserk", "Tank",
    "Rich", "Emperor", "Phoenix", "Almighty", "Sovereign"
}

local RerollCardsDropdown, RankCardsDropdown

local function GetInventoryCardsForReroll()
    local inventory = {}
    local function scanFolder(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Tool") then
                local isPack = false
                pcall(function() isPack = isPackCard(item) end)
                local isBossRaid = false
                pcall(function() isBossRaid = isBossOrRaidCard and isBossOrRaidCard(item) end)

                if not isPack and not isBossRaid then
                    local cardName = item:GetAttribute("CardName") or item:GetAttribute("TemplateName") or item.Name
                    local mutation = getCardMutation(item)
                    local trait = getCardTrait(item)
                    local uid = item.Name
                    local rank = getCardRank(item)
                    local display = string.format("[%s] %s | Rnk: %s | Trt: %s", mutation, cardName, rank, trait)
                    local key = display .. " (" .. string.sub(uid, 1, 4) .. ")"
                    inventory[key] = item
                end
            end
        end
    end
    pcall(function()
        scanFolder(LocalPlayer:FindFirstChild("Backpack"))
        if LocalPlayer.Character then scanFolder(LocalPlayer.Character) end
    end)
    
    local list = {}
    getgenv().RerollInventoryMap = inventory
    for key, _ in pairs(inventory) do
        table.insert(list, key)
    end
    if #list == 0 then table.insert(list, "No cards found") end
    return list
end

getgenv().RerollSpeed = getgenv().RerollSpeed or 0.05
Tabs.Reroll:AddSection("🔄 ตั้งค่าความเร็วการรีโรล")

local RerollSpeedSlider = Tabs.Reroll:AddSlider("RerollSpeed", {
    Title = "⏱️ หน่วงเวลาในการรีโรล (วินาที)",
    Description = "ปรับระยะเวลารอระหว่างการยิงรีโมทในแต่ละรอบ",
    Default = 0.05,
    Min = 0.01,
    Max = 5.0,
    Rounding = 2,
    Callback = function(Value)
        getgenv().RerollSpeed = tonumber(Value) or 0.05
    end
})

Tabs.Reroll:AddSection("🔄 ระบบรีเฟรชการ์ด (Reroll Card List)")

Tabs.Reroll:AddButton({
    Title = "🔄 รีเฟรชรายการการ์ดในกระเป๋า (Trait & Rank)",
    Callback = function()
        local freshCards = GetInventoryCardsForReroll()
        if RerollCardsDropdown then RerollCardsDropdown:SetValues(freshCards) end
        if RankCardsDropdown then RankCardsDropdown:SetValues(freshCards) end
        Fluent:Notify({ Title = "Reroll System", Content = "รีเฟรชรายการการ์ดกระเป๋าสำหรับ Trait & Rank แล้ว!", Duration = 3 })
    end
})

Tabs.Reroll:AddSection("🎯 ตั้งค่า Trait Reroll")

getgenv().SelectedTraits = {}
local TraitDropdown = Tabs.Reroll:AddDropdown("SelectedTraits", {
    Title = "เลือก Trait ที่ต้องการหยุด (Traits Reroll)",
    Values = TraitsList,
    Multi = true,
    Default = {}
})
TraitDropdown:OnChanged(function(Value)
    getgenv().SelectedTraits = {}
    if type(Value) == "table" then
        for k, v in pairs(Value) do
            if type(k) == "number" then
                getgenv().SelectedTraits[string.lower(tostring(v))] = true
            else
                if v then
                    getgenv().SelectedTraits[string.lower(tostring(k))] = true
                end
            end
        end
    end
end)

getgenv().SelectedRerollCardKeys = {}
RerollCardsDropdown = Tabs.Reroll:AddDropdown("SelectedRerollCard", {
    Title = "เลือกการ์ดที่ต้องการรีโรล Trait (เลือกได้หลายใบ)",
    Values = GetInventoryCardsForReroll(),
    Multi = true,
    Default = {}
})
RerollCardsDropdown:OnChanged(function(Value)
    getgenv().SelectedRerollCardKeys = {}
    if type(Value) == "table" then
        for k, v in pairs(Value) do
            if type(k) == "number" then
                table.insert(getgenv().SelectedRerollCardKeys, tostring(v))
            elseif v then
                table.insert(getgenv().SelectedRerollCardKeys, tostring(k))
            end
        end
    elseif type(Value) == "string" and Value ~= "No cards found" then
        table.insert(getgenv().SelectedRerollCardKeys, Value)
    end
end)

-- Cache matching remotes for Trait & Rank Reroll to avoid high ping / CPU spikes
local CachedTraitRemotesList = nil
local function getCachedTraitRemotes()
    if CachedTraitRemotesList then return CachedTraitRemotesList end
    local list = {}
    local rs = game:GetService("ReplicatedStorage")
    for _, obj in ipairs(rs:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = string.lower(obj.Name)
            if string.find(name, "roll") or string.find(name, "trait") then
                table.insert(list, obj)
            end
        end
    end
    CachedTraitRemotesList = list
    return list
end

local CachedRankRemotesList = nil
local function getCachedRankRemotes()
    if CachedRankRemotesList then return CachedRankRemotesList end
    local list = {}
    local keywords = {"rank", "ranking", "upgrade", "stat", "boost", "cashboost", "cardroll", "rollcard", "rerollcard", "grade"}
    local rs = game:GetService("ReplicatedStorage")
    for _, obj in ipairs(rs:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = string.lower(obj.Name)
            for _, kw in ipairs(keywords) do
                if string.find(name, kw) then
                    table.insert(list, obj)
                    break
                end
            end
        end
    end
    CachedRankRemotesList = list
    return list
end

-- Helper logger for Trait & Rank reroll status in AFK dashboard (Deduplicated)
local lastTraitLogMsg = ""
local function logTraitRoll(msg, force)
    if not force and msg == lastTraitLogMsg then
        return -- Avoid duplicate logging
    end
    lastTraitLogMsg = msg
    local timestamp = os.date("%H:%M:%S")
    local logText = string.format("[%s] [TRAIT] %s", timestamp, msg)
    Runtime.traitLog = Runtime.traitLog or {}
    table.insert(Runtime.traitLog, 1, logText)
    if #Runtime.traitLog > 30 then table.remove(Runtime.traitLog, 31) end
    if afkPushTraitLog then
        pcall(function() afkPushTraitLog(logText) end)
    end
end

local lastRankLogMsg = ""
local function logRankRoll(msg, force)
    if not force and msg == lastRankLogMsg then
        return -- Avoid duplicate logging
    end
    lastRankLogMsg = msg
    local timestamp = os.date("%H:%M:%S")
    local logText = string.format("[%s] [RANK] %s", timestamp, msg)
    Runtime.rankLog = Runtime.rankLog or {}
    table.insert(Runtime.rankLog, 1, logText)
    if #Runtime.rankLog > 30 then table.remove(Runtime.rankLog, 31) end
    if afkPushRankLog then
        pcall(function() afkPushRankLog(logText) end)
    end
end

getgenv().AutoReroll = false
local AutoRerollToggle = Tabs.Reroll:AddToggle("AutoRerollTrait", { Title = "🔥 รีโรล Trait อัตโนมัติ", Default = false })
AutoRerollToggle:OnChanged(function(state)
    getgenv().AutoReroll = state
    if state then
        lastTraitLogMsg = ""
        logTraitRoll("เริ่มระบบสุ่ม/รี Trait อัตโนมัติ...", true)
        task.spawn(function()
            getgenv().NotifiedRerollStart = nil
            
            local cardKeys = getgenv().SelectedRerollCardKeys or {}
            if #cardKeys == 0 then
                logTraitRoll("❌ กรุณาเลือกการ์ดที่ต้องการรีโรลอย่างน้อย 1 ใบ!", true)
                Fluent:Notify({ Title = "Auto Reroll", Content = "กรุณาเลือกการ์ดอย่างน้อย 1 ใบ", Duration = 3 })
                getgenv().AutoReroll = false
                if Options and Options.AutoRerollTrait then Options.AutoRerollTrait:SetValue(false) end
                return
            end

            for index, cardKey in ipairs(cardKeys) do
                if not getgenv().AutoReroll then break end

                local cardTool = getgenv().RerollInventoryMap and getgenv().RerollInventoryMap[cardKey]
                if not (cardTool and cardTool.Parent) then
                    logTraitRoll(string.format("⚠️ ข้ามการ์ด [%d/%d]: ไม่พบการ์ดในกระเป๋าแล้ว", index, #cardKeys), true)
                    continue
                end

                local cardName = cardTool:GetAttribute("CardName") or cardTool:GetAttribute("TemplateName") or cardTool.Name
                logTraitRoll(string.format("📌 เริ่มรีการ์ด [%d/%d]: %s", index, #cardKeys, cardName), true)

                local finishedThisCard = false
                while getgenv().AutoReroll and not finishedThisCard do
                    if getgenv().PauseReroll or getgenv().PauseRerollForSpawn then
                        pcall(function()
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("Humanoid") then
                                char.Humanoid:UnequipTools()
                            end
                        end)
                        task.wait(0.5)
                        continue
                    end

                    if not (cardTool and cardTool.Parent) then
                        logTraitRoll(string.format("❌ การ์ด %s หายจากกระเป๋า -> เปลี่ยนไปรีใบถัดไป", cardName), true)
                        break
                    end

                    local currentTrait = getCardTrait(cardTool)

                    local hasSelected = false
                    for trait, _ in pairs(getgenv().SelectedTraits or {}) do
                        if string.find(string.lower(currentTrait), string.lower(trait)) then
                            hasSelected = true
                            break
                        end
                    end

                    if hasSelected then
                        logTraitRoll(string.format("🎯 สำเร็จ [%d/%d]! %s ได้รับ Trait: %s -> เปลี่ยนไปรีใบถัดไป", index, #cardKeys, cardName, currentTrait), true)
                        Fluent:Notify({ Title = "Auto Reroll", Content = ("%s ได้รับ Trait: %s แล้ว!"):format(cardName, currentTrait), Duration = 4 })
                        task.spawn(function() SendRerollWebhook("Trait", cardName, currentTrait) end)
                        finishedThisCard = true
                        break
                    end

                    logTraitRoll(string.format("[%d/%d] รี Trait (%s) -> ปัจจุบัน: %s", index, #cardKeys, cardName, currentTrait ~= "" and currentTrait or "None"))

                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") and cardTool.Parent ~= char then
                            char.Humanoid:EquipTool(cardTool)
                            task.wait(0.2)
                        end
                    end)

                    local cId = cardTool:GetAttribute("UUID") or cardTool:GetAttribute("Id") or cardTool:GetAttribute("CardId") or cardTool.Name

                    if not getgenv().NotifiedRerollStart then
                        Fluent:Notify({ Title = "Auto Reroll", Content = "กำลังรีโรล Trait อัตโนมัติ...", Duration = 3 })
                        getgenv().NotifiedRerollStart = true
                    end

                    local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                    local TraitRollRE = Remotes and Remotes:FindFirstChild("TraitRollRE")

                    if TraitRollRE and TraitRollRE:IsA("RemoteEvent") then
                        pcall(function() TraitRollRE:FireServer("Select", cardTool) end)
                        pcall(function() TraitRollRE:FireServer("Equip", cardTool) end)
                        pcall(function() TraitRollRE:FireServer("Insert", cardTool) end)
                        pcall(function() TraitRollRE:FireServer("Select", {Tool = cardTool}) end)

                        local rollArgs = {
                            cardTool,
                            { Tool = cardTool },
                            { Card = cardTool },
                            cId,
                            { UUID = cId },
                            { Id = cId },
                            "Roll",
                            "Reroll"
                        }

                        for _, arg in ipairs(rollArgs) do
                            pcall(function() TraitRollRE:FireServer(arg) end)
                            pcall(function() TraitRollRE:FireServer("Roll", arg) end)
                            pcall(function() TraitRollRE:FireServer("Reroll", arg) end)
                            pcall(function() TraitRollRE:FireServer(arg, "Roll") end)
                        end

                        pcall(function() TraitRollRE:FireServer({Kind = "Roll", Tool = cardTool}) end)
                        pcall(function() TraitRollRE:FireServer({Action = "Roll", Tool = cardTool}) end)
                        pcall(function() TraitRollRE:FireServer({Command = "Roll", Tool = cardTool}) end)
                        pcall(function() TraitRollRE:FireServer({Type = "Roll", Tool = cardTool}) end)
                        pcall(function() TraitRollRE:FireServer("RollTrait", {Tool = cardTool}) end)
                        pcall(function() TraitRollRE:FireServer("RollResult", {Tool = cardTool}) end)
                        pcall(function() TraitRollRE:FireServer("Roll", {Tool = cardTool, Currency = "Gems"}) end)
                    end

                    local function fireAllTrait(id)
                        local argsToTry = {
                            id, cardTool, { Card = id }, { UUID = id }, { Tool = cardTool }
                        }
                        local traitRemotes = getCachedTraitRemotes()
                        for _, obj in ipairs(traitRemotes) do
                            if obj:IsA("RemoteEvent") then
                                for _, arg in ipairs(argsToTry) do
                                    pcall(function() obj:FireServer(arg) end)
                                end
                            end
                        end
                    end
                    fireAllTrait(cId)

                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if playerGui then
                        for _, v in ipairs(playerGui:GetDescendants()) do
                            if v:IsA("TextButton") or v:IsA("ImageButton") then
                                local text = ""
                                if v:IsA("TextButton") then text = string.upper(v.Text)
                                elseif v:FindFirstChildWhichIsA("TextLabel") then text = string.upper(v:FindFirstChildWhichIsA("TextLabel").Text) end

                                if text == "ROLL" or text == "REROLL" or text == "SPIN" then
                                    if v.Visible or (v.Parent and v.Parent.Visible) then
                                        if getconnections then
                                            for _, conn in ipairs(getconnections(v.MouseButton1Click)) do pcall(function() conn:Fire() end) end
                                            for _, conn in ipairs(getconnections(v.Activated)) do pcall(function() conn:Fire() end) end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    task.wait(math.max(0.01, tonumber(getgenv().RerollSpeed) or 0.05))
                end
            end

            if getgenv().AutoReroll then
                logTraitRoll("🎉 สำเร็จ! รีโรล Trait ครบทุกใบที่เลือกแล้ว", true)
                Fluent:Notify({ Title = "Auto Reroll", Content = "รีโรล Trait ครบทุกใบที่เลือกเรียบร้อยแล้ว!", Duration = 5 })
                getgenv().AutoReroll = false
                if Options and Options.AutoRerollTrait then Options.AutoRerollTrait:SetValue(false) end
            else
                logTraitRoll("🛑 ปิดการสุ่ม/รี Trait แล้ว", true)
            end
        end)
    else
        logTraitRoll("🛑 ปิดการสุ่ม/รี Trait แล้ว", true)
    end
end)

Tabs.Reroll:AddSection("🌟 ตั้งค่า Rank Reroll")

local RankList = {"F", "E", "D", "C", "B", "A", "S", "SS", "SR", "UR", "LR"}

getgenv().SelectedRanks = {}
local RankDropdown = Tabs.Reroll:AddDropdown("SelectedRanks", {
    Title = "เลือก Rank ที่ต้องการหยุด (Rank Reroll)",
    Values = RankList,
    Multi = true,
    Default = {}
})
RankDropdown:OnChanged(function(Value)
    getgenv().SelectedRanks = {}
    if type(Value) == "table" then
        for k, v in pairs(Value) do
            if type(k) == "number" then
                getgenv().SelectedRanks[string.lower(tostring(v))] = true
            else
                if v then
                    getgenv().SelectedRanks[string.lower(tostring(k))] = true
                end
            end
        end
    end
end)

getgenv().SelectedRankCardKeys = {}
RankCardsDropdown = Tabs.Reroll:AddDropdown("SelectedRankCard", {
    Title = "เลือกการ์ดที่ต้องการรีโรล Rank (เลือกได้หลายใบ)",
    Values = GetInventoryCardsForReroll(),
    Multi = true,
    Default = {}
})
RankCardsDropdown:OnChanged(function(Value)
    getgenv().SelectedRankCardKeys = {}
    if type(Value) == "table" then
        for k, v in pairs(Value) do
            if type(k) == "number" then
                table.insert(getgenv().SelectedRankCardKeys, tostring(v))
            elseif v then
                table.insert(getgenv().SelectedRankCardKeys, tostring(k))
            end
        end
    elseif type(Value) == "string" and Value ~= "No cards found" then
        table.insert(getgenv().SelectedRankCardKeys, Value)
    end
end)

getgenv().AutoRankReroll = false
local AutoRankRerollToggle = Tabs.Reroll:AddToggle("AutoRerollRank", { Title = "💥 รีโรล Rank อัตโนมัติ", Default = false })
AutoRankRerollToggle:OnChanged(function(state)
    getgenv().AutoRankReroll = state
    if state then
        lastRankLogMsg = ""
        logRankRoll("เริ่มระบบสุ่ม/รี Rank อัตโนมัติ...", true)
        task.spawn(function()
            getgenv().NotifiedRankRerollStart = nil
            
            local cardKeys = getgenv().SelectedRankCardKeys or {}
            if #cardKeys == 0 then
                logRankRoll("❌ กรุณาเลือกการ์ดที่ต้องการรีโรลอย่างน้อย 1 ใบ!", true)
                Fluent:Notify({ Title = "Auto Rank", Content = "กรุณาเลือกการ์ดอย่างน้อย 1 ใบ", Duration = 3 })
                getgenv().AutoRankReroll = false
                if Options and Options.AutoRerollRank then Options.AutoRerollRank:SetValue(false) end
                return
            end

            for index, cardKey in ipairs(cardKeys) do
                if not getgenv().AutoRankReroll then break end

                local cardTool = getgenv().RerollInventoryMap and getgenv().RerollInventoryMap[cardKey]
                if not (cardTool and cardTool.Parent) then
                    logRankRoll(string.format("⚠️ ข้ามการ์ด [%d/%d]: ไม่พบการ์ดในกระเป๋าแล้ว", index, #cardKeys), true)
                    continue
                end

                local cardName = cardTool:GetAttribute("CardName") or cardTool:GetAttribute("TemplateName") or cardTool.Name
                logRankRoll(string.format("📌 เริ่มรีการ์ด [%d/%d]: %s", index, #cardKeys, cardName), true)

                local finishedThisCard = false
                while getgenv().AutoRankReroll and not finishedThisCard do
                    if getgenv().PauseReroll or getgenv().PauseRerollForSpawn then
                        pcall(function()
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("Humanoid") then
                                char.Humanoid:UnequipTools()
                            end
                        end)
                        task.wait(0.5)
                        continue
                    end

                    if not (cardTool and cardTool.Parent) then
                        logRankRoll(string.format("❌ การ์ด %s หายจากกระเป๋า -> เปลี่ยนไปรีใบถัดไป", cardName), true)
                        break
                    end

                    local currentRank = getCardRank(cardTool)

                    local hasSelected = false
                    for rank, _ in pairs(getgenv().SelectedRanks or {}) do
                        if string.lower(currentRank) == string.lower(rank) then
                            hasSelected = true
                            break
                        end
                    end

                    if hasSelected then
                        logRankRoll(string.format("🎯 สำเร็จ [%d/%d]! %s ได้รับ Rank: %s -> เปลี่ยนไปรีใบถัดไป", index, #cardKeys, cardName, currentRank), true)
                        Fluent:Notify({ Title = "Auto Rank", Content = ("%s ได้รับ Rank: %s แล้ว!"):format(cardName, currentRank), Duration = 4 })
                        task.spawn(function() SendRerollWebhook("Rank", cardName, currentRank) end)
                        finishedThisCard = true
                        break
                    end

                    logRankRoll(string.format("[%d/%d] รี Rank (%s) -> ปัจจุบัน: %s", index, #cardKeys, cardName, currentRank ~= "" and currentRank or "None"))

                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") and cardTool.Parent ~= char then
                            char.Humanoid:EquipTool(cardTool)
                            task.wait(0.2)
                        end
                    end)

                    local cId = cardTool:GetAttribute("UUID") or cardTool:GetAttribute("Id") or cardTool:GetAttribute("CardId") or cardTool.Name

                    if not getgenv().NotifiedRankRerollStart then
                        Fluent:Notify({ Title = "Auto Rank", Content = "กำลังรีโรล Rank อัตโนมัติ...", Duration = 3 })
                        getgenv().NotifiedRankRerollStart = true
                    end

                    local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                    local RankRollRE = Remotes and (Remotes:FindFirstChild("GradeRollRE") or Remotes:FindFirstChild("RankRollRE") or Remotes:FindFirstChild("RollRankRE") or Remotes:FindFirstChild("RankRE") or Remotes:FindFirstChild("CardRankingRE") or Remotes:FindFirstChild("RankRerollRE") or Remotes:FindFirstChild("Rank"))

                    if RankRollRE and RankRollRE:IsA("RemoteEvent") then
                        pcall(function() RankRollRE:FireServer("Select", cardTool) end)
                        pcall(function() RankRollRE:FireServer("Equip", cardTool) end)
                        pcall(function() RankRollRE:FireServer("Insert", cardTool) end)
                        pcall(function() RankRollRE:FireServer("Select", {Tool = cardTool}) end)

                        local rollArgs = {
                            cardTool,
                            { Tool = cardTool },
                            { Card = cardTool },
                            cId,
                            { UUID = cId },
                            { Id = cId },
                            "Roll",
                            "Reroll",
                            "Rank",
                            "Grade"
                        }

                        for _, arg in ipairs(rollArgs) do
                            pcall(function() RankRollRE:FireServer(arg) end)
                            pcall(function() RankRollRE:FireServer("Roll", arg) end)
                            pcall(function() RankRollRE:FireServer("Rank", arg) end)
                            pcall(function() RankRollRE:FireServer("Grade", arg) end)
                            pcall(function() RankRollRE:FireServer(arg, "Roll") end)
                            pcall(function() RankRollRE:FireServer(arg, "Rank") end)
                            pcall(function() RankRollRE:FireServer(arg, "Grade") end)
                        end

                        pcall(function() RankRollRE:FireServer({Kind = "Roll", Tool = cardTool}) end)
                        pcall(function() RankRollRE:FireServer({Action = "Roll", Tool = cardTool}) end)
                        pcall(function() RankRollRE:FireServer({Command = "Roll", Tool = cardTool}) end)
                        pcall(function() RankRollRE:FireServer({Type = "Roll", Tool = cardTool}) end)
                        pcall(function() RankRollRE:FireServer({Kind = "Rank", Tool = cardTool}) end)
                        pcall(function() RankRollRE:FireServer({Action = "Rank", Tool = cardTool}) end)
                        pcall(function() RankRollRE:FireServer({Kind = "Grade", Tool = cardTool}) end)
                        pcall(function() RankRollRE:FireServer({Action = "Grade", Tool = cardTool}) end)
                        pcall(function() RankRollRE:FireServer("RollRank", {Tool = cardTool}) end)
                        pcall(function() RankRollRE:FireServer("RollGrade", {Tool = cardTool}) end)
                        pcall(function() RankRollRE:FireServer("RollResult", {Tool = cardTool}) end)
                        pcall(function() RankRollRE:FireServer("Roll", {Tool = cardTool, Currency = "Gems"}) end)
                        pcall(function() RankRollRE:FireServer("Rank", {Tool = cardTool, Currency = "Gems"}) end)
                        pcall(function() RankRollRE:FireServer("Grade", {Tool = cardTool, Currency = "Gems"}) end)
                    end

                    local function fireAllRank(id)
                        local argsToTry = {
                            id, cardTool, { Card = id }, { UUID = id }, { Tool = cardTool }
                        }
                        local rankRemotes = getCachedRankRemotes()
                        for _, obj in ipairs(rankRemotes) do
                            if obj:IsA("RemoteEvent") then
                                for _, arg in ipairs(argsToTry) do
                                    pcall(function() obj:FireServer(arg) end)
                                    pcall(function() obj:FireServer("Roll", arg) end)
                                    pcall(function() obj:FireServer("Rank", arg) end)
                                end
                            elseif obj:IsA("RemoteFunction") then
                                for _, arg in ipairs(argsToTry) do
                                    task.spawn(function() pcall(function() obj:InvokeServer(arg) end) end)
                                    task.spawn(function() pcall(function() obj:InvokeServer("Roll", arg) end) end)
                                    task.spawn(function() pcall(function() obj:InvokeServer("Rank", arg) end) end)
                                end
                            end
                        end
                    end
                    fireAllRank(cId)

                    task.wait(math.max(0.01, tonumber(getgenv().RerollSpeed) or 0.05))
                end
            end

            if getgenv().AutoRankReroll then
                logRankRoll("🎉 สำเร็จ! รีโรล Rank ครบทุกใบที่เลือกแล้ว", true)
                Fluent:Notify({ Title = "Auto Rank", Content = "รีโรล Rank ครบทุกใบที่เลือกเรียบร้อยแล้ว!", Duration = 5 })
                getgenv().AutoRankReroll = false
                if Options and Options.AutoRerollRank then Options.AutoRerollRank:SetValue(false) end
            else
                logRankRoll("🛑 ปิดการสุ่ม/รี Rank แล้ว", true)
            end
        end)
    else
        logRankRoll("🛑 ปิดการสุ่ม/รี Rank แล้ว", true)
    end
end)

local RerollSpeedSlider2 = Tabs.Reroll:AddSlider("RerollSpeed2", {
    Title = "⚡ ความเร็วในการรีโรล (วินาที)",
    Default = 0.4,
    Min = 0.1,
    Max = 3.0,
    Rounding = 1
})
RerollSpeedSlider2:OnChanged(function(val)
    getgenv().RerollSpeed = val
end)

---------------------------------------------------------
-- 3. POTION TAB (น้ำยา)
---------------------------------------------------------
local function isBoostActive(boostName)
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return true end
    local InfoGui = PlayerGui:FindFirstChild("InfoGui")
    if not InfoGui then return true end
    local Boost = InfoGui:FindFirstChild("Boost")
    if not Boost then return true end
    local BoostFrame = Boost:FindFirstChild(boostName)
    if not BoostFrame or not BoostFrame.Visible then return false end

    for _, v in ipairs(BoostFrame:GetDescendants()) do
        if v:IsA("TextLabel") and (v.Text == "00:00:00" or v.Text == "00:00") then
            return false
        end
    end
    return true
end

local function getPotionAmount(potionId)
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return 0 end
    local GuiMid = PlayerGui:FindFirstChild("GuiMid")
    if not GuiMid then return 0 end
    local Items = GuiMid:FindFirstChild("Items")
    if not Items then return 0 end
    local ItemsFrame = Items:FindFirstChild("ItemsFrame")
    if not ItemsFrame then return 0 end
    local ScrollingFrameItems = ItemsFrame:FindFirstChild("ScrollingFrameItems")
    if not ScrollingFrameItems then return 0 end
    local ObjectFrame = ScrollingFrameItems:FindFirstChild("ObjectFrame_" .. potionId)
    if not ObjectFrame or not ObjectFrame.Visible then return 0 end
    local ObjectButton = ObjectFrame:FindFirstChild("ObjectButton")
    if not ObjectButton then return 0 end
    local Quantity = ObjectButton:FindFirstChild("Quantity")
    if not Quantity or not Quantity:IsA("TextLabel") then return 0 end
    local amountStr = Quantity.Text:gsub("x", "")
    return tonumber(amountStr) or 0
end

local function setupPotionToggle(title, titleTH, boostName, itemIdPrefix)
    local genvName = "AutoUse" .. title
    getgenv()[genvName] = false
    local PotionToggle = Tabs.Potion:AddToggle(genvName, { Title = "🧪 ใช้น้ำยา" .. titleTH .. "อัตโนมัติ", Default = false })
    PotionToggle:OnChanged(function(state)
        getgenv()[genvName] = state
        if state then
            task.spawn(function()
                local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
                local ItemsRE = Remotes and Remotes:WaitForChild("ItemsRE", 5)
                if not ItemsRE then return end
                while getgenv()[genvName] do
                    if not isBoostActive(boostName) then
                        local amt1 = getPotionAmount(itemIdPrefix .. "1")
                        local amt2 = getPotionAmount(itemIdPrefix .. "2")
                        local amt3 = getPotionAmount(itemIdPrefix .. "3")
                        Fluent:Notify({
                            Title = "กระเป๋าน้ำยา " .. titleTH,
                            Content = string.format("คงเหลือ III: %d | II: %d | I: %d", amt3, amt2, amt1),
                            Duration = 3
                        })
                        if amt3 > 0 then
                            ItemsRE:FireServer("UseItem", { ItemId = itemIdPrefix .. "3", Amount = math.min(5, amt3) })
                        elseif amt2 > 0 then
                            ItemsRE:FireServer("UseItem", { ItemId = itemIdPrefix .. "2", Amount = math.min(5, amt2) })
                        elseif amt1 > 0 then
                            ItemsRE:FireServer("UseItem", { ItemId = itemIdPrefix .. "1", Amount = math.min(5, amt1) })
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end)
end

setupPotionToggle("Luck", "โชค", "PotionLuck", "LuckPotion")
setupPotionToggle("Cash", "เงิน", "PotionCash", "CashPotion")
setupPotionToggle("Mutation", "กลายพันธุ์", "PotionMutation", "MutationPotion")
setupPotionToggle("Production", "ผลผลิต", "PotionProduction", "ProductionPotion")

---------------------------------------------------------
-- HELPER FUNCTIONS FOR CARD VALUE & RARITY SCORING
---------------------------------------------------------
local RarityTiers = {
    ["admin"] = 100000, ["แอดมิน"] = 100000,
    ["godly"] = 50000, ["ก๊อดลี่"] = 50000, ["กอดลี่"] = 50000,
    ["secret"] = 10000, ["ซีเคร็ท"] = 10000, ["ซีเครท"] = 10000,
    ["mythical"] = 9000, ["มิทิคอล"] = 9000,
    ["legendary"] = 8000, ["เลเจนดารี่"] = 8000,
    ["epic"] = 7000, ["เอพิก"] = 7000,
    ["rare"] = 6000, ["แรร์"] = 6000,
    ["uncommon"] = 5000, ["อันคอมมอน"] = 5000,
    ["common"] = 4000, ["คอมมอน"] = 4000,
}

local function parseSuffixValue(txt)
    if not txt then return 0 end
    local numStr, suffix = string.match(string.upper(txt), "([%d%.]+)%s*([A-Z]+)")
    if numStr then
        local num = tonumber(numStr) or 0
        local mult = 1
        if suffix == "DD" then mult = 1e39
        elseif suffix == "UD" then mult = 1e36
        elseif suffix == "DC" then mult = 1e33
        elseif suffix == "NO" then mult = 1e30
        elseif suffix == "OC" then mult = 1e27
        elseif suffix == "SP" then mult = 1e24
        elseif suffix == "SX" then mult = 1e21
        elseif suffix == "QI" then mult = 1e18
        elseif suffix == "QA" then mult = 1e15
        elseif suffix == "T" then mult = 1e12
        elseif suffix == "B" then mult = 1e9
        elseif suffix == "M" then mult = 1e6
        elseif suffix == "K" then mult = 1e3
        end
        return num * mult
    end
    local nOnly = tonumber(string.match(txt, "[%d%.]+"))
    return nOnly or 0
end

Tabs.Manage:AddSection("🗑️ จัดการกระเป๋า (Inventory Balancing) ⚠️ **ห้ามเปิดพร้อมรีโรล**")
local InvBalToggle = Tabs.Manage:AddToggle("InvBalState", { 
    Title = "เคลียร์แพ็คขยะอัตโนมัติเมื่อกระเป๋าเต็ม (ขายเฉพาะ Pack Card) ⚠️ [ห้ามเปิดพร้อมรีโรล]", 
    Description = "⚠️ **ห้ามเปิดพร้อมรีโรล** (เพื่อป้องกันการยิงรีโมทขายแพ็กชนกับระบบรีโรล)", 
    Default = false 
})
local MinRarityDrop = Tabs.Manage:AddDropdown("MinRarityKeep", {
    Title = "ระดับแพ็คขั้นต่ำที่ต้องการเก็บไว้",
    Values = RaritiesList,
    Multi = false,
    Default = "Rare"
})

local function getToolRarity(item)
    if not item then return "Common" end
    local r = item:GetAttribute("Rarity") 
        or item:GetAttribute("CardRarity") 
        or item:GetAttribute("PackRarity")
        or item:GetAttribute("CardGrade")
        or item:GetAttribute("Grade")
        or item:GetAttribute("TemplateName")
        or item:GetAttribute("CardName")
    if r and tostring(r) ~= "" and tostring(r) ~= "nil" then return tostring(r) end

    for _, childName in ipairs({"Rarity", "CardRarity", "PackRarity", "Grade", "CardGrade", "TemplateName", "CardName"}) do
        local valObj = item:FindFirstChild(childName)
        if valObj then
            if valObj:IsA("StringValue") and valObj.Value ~= "" then
                return valObj.Value
            elseif valObj:IsA("TextLabel") and valObj.Text ~= "" then
                return valObj.Text
            end
        end
    end

    local cleanItemName = string.lower(item.Name or "")
    for _, rName in ipairs(RaritiesList or {}) do
        local lowerR = string.lower(rName)
        if cleanItemName:find(lowerR, 1, true) then
            return rName
        end
    end

    for _, txtObj in ipairs(item:GetDescendants()) do
        if (txtObj:IsA("TextLabel") or txtObj:IsA("TextButton")) and txtObj.Text then
            local cleanTxt = string.lower(string.gsub(txtObj.Text, "<[^>]+>", ""))
            for _, rName in ipairs(RaritiesList or {}) do
                if string.find(cleanTxt, string.lower(rName), 1, true) then
                    return rName
                end
            end
        end
    end
    return "Common"
end

local function getRarityIndex(rarityStr)
    if not rarityStr or rarityStr == "" or rarityStr == "None" then return 1 end
    local lowerR = string.lower(tostring(rarityStr))
    for i, rName in ipairs(RaritiesList) do
        local lowerName = string.lower(rName)
        if lowerName == lowerR or string.find(lowerR, lowerName, 1, true) then
            return i
        end
    end
    return 99
end

InvBalToggle:OnChanged(function(state)
    getgenv().InventoryBalancing = state
    if state then
        if getgenv().AutoReroll or getgenv().AutoRankReroll then
            Fluent:Notify({ Title = "คำเตือนระบบ", Content = "⚠️ ห้ามเปิดโหมดเคลียร์ขยะพร้อมกับโหมดรีโรล! เพื่อป้องกันปิงสูงและข้อผิดพลาด", Duration = 5 })
        end
        task.spawn(function()
            while getgenv().InventoryBalancing do
                pcall(function()
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    local char = LocalPlayer.Character
                    local items = {}
                    if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then table.insert(items, t) end end end
                    if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(items, t) end end end
                    
                    if #items > 0 then
                        local selectedKeep = MinRarityDrop.Value or "Rare"
                        local threshold = getRarityIndex(selectedKeep)
                        if threshold == 99 then threshold = 3 end
                        
                        local trashCards = {}
                        
                        for _, t in ipairs(items) do
                            -- Strict Protection: ONLY sell Pack Cards (isPackCard == true)
                            -- NEVER sell actual character cards or boss/raid cards!
                            local isPack = false
                            pcall(function() isPack = isPackCard(t) end)
                            if not isPack then
                                continue
                            end

                            local isBossRaid = false
                            pcall(function() isBossRaid = isBossOrRaidCard and isBossOrRaidCard(t) end)
                            if isBossRaid then
                                continue
                            end
                            
                            local rarity = getToolRarity(t)
                            local rIdx = getRarityIndex(rarity)
                            
                            if rIdx == 99 then
                                local upName = string.upper(t.Name)
                                for idx, rName in ipairs(RaritiesList) do
                                    if string.find(upName, string.upper(rName), 1, true) then
                                        rIdx = idx
                                        break
                                    end
                                end
                            end
                            
                            if rIdx < threshold then
                                table.insert(trashCards, t)
                            end
                        end
                        
                        if #trashCards > 0 and char and char:FindFirstChild("Humanoid") then
                            for _, t in ipairs(trashCards) do
                                pcall(function()
                                    char.Humanoid:EquipTool(t)
                                    task.wait(0.15)
                                    local rem = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                                    if rem then
                                        if rem:FindFirstChild("SellRE") then
                                            rem.SellRE:FireServer("SellHand")
                                            rem.SellRE:FireServer("Sell", t)
                                            rem.SellRE:FireServer(t)
                                        end
                                        if rem:FindFirstChild("Sell") then
                                            rem.Sell:FireServer(t)
                                        end
                                    end
                                    task.wait(0.15)
                                    if t and t.Parent then t:Destroy() end
                                end)
                            end
                            pcall(function() logLine("sell", string.format("🗑️ เคลียร์แพ็คขยะเรียบร้อย (%d ใบ)", #trashCards)) end)
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

Tabs.Manage:AddSection("🧠 ระบบแท่นอัจฉริยะ (Smart Base)")
local function GetInventoryPackCards()
    local packs = {}
    local function scanFolder(folder)
        if not folder then return end
        for _, t in ipairs(folder:GetChildren()) do
            if t:IsA("Tool") and isPackCard(t) then
                local packName = tostring(t:GetAttribute("CardName") or t:GetAttribute("TemplateName") or t.Name)
                packs[packName] = true
            end
        end
    end
    pcall(function()
        scanFolder(LocalPlayer:FindFirstChild("Backpack"))
        if LocalPlayer.Character then scanFolder(LocalPlayer.Character) end
    end)
    local list = {}
    for k, _ in pairs(packs) do table.insert(list, k) end
    if #list == 0 then table.insert(list, "No pack cards found") end
    table.sort(list)
    return list
end

getgenv().SelectedSmartBasePacks = {}
local SmartBasePackRanks = Tabs.Manage:AddDropdown("SmartBasePackRanks", {
    Title = "เลือกแพ็คที่จะวาง (ตามที่มีในกระเป๋า)",
    Values = GetInventoryPackCards(),
    Multi = true,
    Default = {}
})
SmartBasePackRanks:OnChanged(function(Value)
    getgenv().SelectedSmartBasePacks = {}
    if type(Value) == "table" then
        for k, v in pairs(Value) do
            if type(k) == "number" then
                getgenv().SelectedSmartBasePacks[string.lower(tostring(v))] = true
            elseif v == true then
                getgenv().SelectedSmartBasePacks[string.lower(tostring(k))] = true
            end
        end
    end
end)

Tabs.Manage:AddButton({
    Title = "🔄 รีเฟรชรายการแพ็คการ์ด",
    Callback = function()
        SmartBasePackRanks:SetValues(GetInventoryPackCards())
        Fluent:Notify({ Title = "Smart Base", Content = "รีเฟรชรายการแพ็คการ์ดในกระเป๋าแล้ว!", Duration = 3 })
    end
})

local SmartBaseToggle = Tabs.Manage:AddToggle("SmartBaseState", { Title = "วางการ์ดลงฐานอัตโนมัติ", Default = false })
SmartBaseToggle:OnChanged(function(state)
    getgenv().SmartBase = state
    if state then
        task.spawn(function()
            while getgenv().SmartBase do
                pcall(function()
                    local plotFolder = findPlayerPlot()
                    if plotFolder then
                        local baseDescendants = plotFolder:GetDescendants()
                        local countedModels = {}
                        local packsOnBaseCount = 0
                        for _, desc in ipairs(baseDescendants) do
                            if desc:IsA("ProximityPrompt") then
                                local actTxt = string.upper((desc.ActionText or "") .. " " .. (desc.ObjectText or "") .. " " .. desc.Name)
                                if actTxt:find("OPEN") or actTxt:find("เปิด") or actTxt:find("SKIP") or actTxt:find("ข้าม") then
                                    local model = desc:FindFirstAncestorOfClass("Model")
                                    if model and model ~= plotFolder and model.Name ~= "SellPart" and not countedModels[model] then
                                        local mName = string.upper(model.Name)
                                        if not mName:find("SKIP ALL") and not mName:find("SELL") and not mName:find("SHOP") and not mName:find("PLOT") and not mName:find("REBIRTH") then
                                            countedModels[model] = true
                                            packsOnBaseCount = packsOnBaseCount + 1
                                        end
                                    end
                                end
                            end
                        end
                        
                        local maxPlace = math.max(0, 10 - packsOnBaseCount)
                        if maxPlace > 0 then
                            local packsToPlace = {}
                            local bp = LocalPlayer:FindFirstChild("Backpack")
                            local char = LocalPlayer.Character
                            
                            local selectedPacks = getgenv().SelectedSmartBasePacks or {}
                            local function isAllowed(t)
                                local hasFilter = false
                                for _, sel in pairs(selectedPacks) do
                                    if sel then hasFilter = true; break end
                                end
                                if not hasFilter then return true end
                                
                                local tName = tostring(t:GetAttribute("CardName") or t:GetAttribute("TemplateName") or t.Name)
                                local lowerTName = string.lower(tName)
                                
                                for k, selected in pairs(selectedPacks) do
                                    if selected then
                                        local keyStr = string.lower(tostring(k))
                                        keyStr = string.gsub(keyStr, "%.%.%.", "")
                                        keyStr = string.gsub(keyStr, "%s*%(x%d+%)", "")
                                        keyStr = string.match(keyStr, "^%s*(.-)%s*$") or ""
                                        if keyStr ~= "" and (string.find(lowerTName, keyStr, 1, true) or string.find(keyStr, lowerTName, 1, true)) then
                                            return true
                                        end
                                    end
                                end
                                return false
                            end
                            
                            local function scanForPacks(folder)
                                if not folder then return end
                                for _, t in ipairs(folder:GetChildren()) do
                                    if t:IsA("Tool") and isPackCard(t) and isAllowed(t) then
                                        table.insert(packsToPlace, t)
                                    end
                                end
                            end
                            scanForPacks(bp)
                            if char then scanForPacks(char) end
                            
                            if #packsToPlace > 0 then
                                local candidates = {}
                                for _, desc in ipairs(baseDescendants) do
                                    if desc:IsA("ProximityPrompt") or desc:IsA("ClickDetector") then
                                        local actTxt = desc:IsA("ProximityPrompt") and string.upper((desc.ActionText or "") .. " " .. (desc.ObjectText or "") .. " " .. desc.Name) or string.upper(desc.Name or "")
                                        
                                        local isIgnored = actTxt:find("SELL") or actTxt:find("ขาย") or actTxt:find("OPEN") or actTxt:find("เปิด") 
                                            or actTxt:find("ARTIFACT") or actTxt:find("อาร์ติแฟกต์") or actTxt:find("SKIP") or actTxt:find("ข้าม") 
                                            or actTxt:find("BOSS") or actTxt:find("บอส") or actTxt:find("MASTER") or actTxt:find("ROBUX") 
                                            or actTxt:find("BUY") or actTxt:find("PURCHASE") or actTxt:find("LUCK") or actTxt:find("CASH") 
                                            or actTxt:find("BOOST") or actTxt:find("GEMS") or actTxt:find("PASS") or actTxt:find("PREMIUM") or actTxt:find("VIP")
                                            or actTxt:find("UPGRADE") or actTxt:find("SHOP") or actTxt:find("REBIRTH") or actTxt:find("JOIN") or actTxt:find("ENTER")
                                            
                                        if not isIgnored then
                                            local model = desc:FindFirstAncestorOfClass("Model")
                                            local targetPos
                                            if desc.Parent and desc.Parent:IsA("BasePart") then targetPos = desc.Parent.Position
                                            elseif desc.Parent and desc.Parent:IsA("Attachment") then targetPos = desc.Parent.WorldPosition
                                            elseif model and model.PrimaryPart then targetPos = model.PrimaryPart.Position end
                                            
                                            if targetPos then
                                                local isPlacePrompt = actTxt:find("PLACE") or actTxt:find("วาง") or actTxt:find("EQUIP")
                                                local isRemovePrompt = actTxt:find("REMOVE") or actTxt:find("ถอด") or actTxt:find("เอาออก") or actTxt:find("เก็บ") or actTxt:find("ลบ")
                                                
                                                if isPlacePrompt or not model or model == plotFolder or string.find(string.upper(model.Name), "PLOT") then
                                                    table.insert(candidates, { prompt = desc, score = -1, pos = targetPos, isEmpty = true })
                                                elseif (isRemovePrompt or (model and model ~= plotFolder)) and model.Name ~= "SellPart" and not model:FindFirstChildOfClass("Humanoid") then
                                                    local isAlreadyPack = isPackCard(model)
                                                    if not isAlreadyPack then
                                                        local score = getUnifiedCardScore(model)
                                                        table.insert(candidates, { prompt = desc, score = score, pos = targetPos, isRemove = true, model = model })
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                
                                table.sort(candidates, function(a, b) return a.score < b.score end)
                                
                                local countToPlace = math.min(#packsToPlace, #candidates, maxPlace)
                                if countToPlace > 0 then
                                    local originalCFrame = char and char:GetPivot()
                                    
                                    for i = 1, countToPlace do
                                        local packTool = packsToPlace[i]
                                        local target = candidates[i]
                                        
                                        if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                                            if target.isEmpty then
                                                char.Humanoid:EquipTool(packTool)
                                                task.wait(0.4)
                                                char.HumanoidRootPart.CFrame = CFrame.new(target.pos) + Vector3.new(0, 3, 0)
                                                task.wait(0.4)
                                                
                                                if target.prompt and target.prompt.Parent then
                                                    if target.prompt:IsA("ProximityPrompt") then
                                                        target.prompt.RequiresLineOfSight = false
                                                        target.prompt.MaxActivationDistance = 99999
                                                        target.prompt.HoldDuration = 0
                                                        fireproximityprompt(target.prompt)
                                                    elseif target.prompt:IsA("ClickDetector") then
                                                        fireclickdetector(target.prompt)
                                                    end
                                                    task.wait(0.5)
                                                end
                                            elseif target.isRemove then
                                                char.HumanoidRootPart.CFrame = CFrame.new(target.pos) + Vector3.new(0, 3, 0)
                                                task.wait(0.3)
                                                
                                                if target.prompt and target.prompt.Parent then
                                                    if target.prompt:IsA("ProximityPrompt") then
                                                        target.prompt.RequiresLineOfSight = false
                                                        target.prompt.MaxActivationDistance = 99999
                                                        target.prompt.HoldDuration = 0
                                                        fireproximityprompt(target.prompt)
                                                    elseif target.prompt:IsA("ClickDetector") then
                                                        fireclickdetector(target.prompt)
                                                    end
                                                end
                                                
                                                task.wait(1.5)
                                                char.Humanoid:EquipTool(packTool)
                                                task.wait(0.4)
                                                
                                                local newPlacePrompt = nil
                                                for retry = 1, 6 do
                                                    for _, desc in ipairs(plotFolder:GetDescendants()) do
                                                        if desc:IsA("ProximityPrompt") or desc:IsA("ClickDetector") then
                                                            local nTxt = desc:IsA("ProximityPrompt") and string.upper((desc.ActionText or "") .. " " .. (desc.ObjectText or "") .. " " .. desc.Name) or string.upper(desc.Name)
                                                            if nTxt:find("PLACE") or nTxt:find("วาง") or nTxt:find("EQUIP") or not desc:FindFirstAncestorOfClass("Model") then
                                                                local nPos
                                                                if desc.Parent:IsA("BasePart") then nPos = desc.Parent.Position
                                                                elseif desc.Parent:IsA("Attachment") then nPos = desc.Parent.WorldPosition end
                                                                
                                                                if nPos and (nPos - target.pos).Magnitude < 5 then
                                                                    newPlacePrompt = desc
                                                                    break
                                                                end
                                                            end
                                                        end
                                                    end
                                                    if newPlacePrompt then break end
                                                    task.wait(0.3)
                                                end
                                                
                                                if newPlacePrompt then
                                                    if newPlacePrompt:IsA("ProximityPrompt") then
                                                        newPlacePrompt.RequiresLineOfSight = false
                                                        newPlacePrompt.MaxActivationDistance = 99999
                                                        newPlacePrompt.HoldDuration = 0
                                                        fireproximityprompt(newPlacePrompt)
                                                    elseif newPlacePrompt:IsA("ClickDetector") then
                                                        fireclickdetector(newPlacePrompt)
                                                    end
                                                    task.wait(0.5)
                                                end
                                            end
                                        end
                                    end
                                    
                                    if originalCFrame and char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = originalCFrame
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(3)
            end
        end)
    end
end)

local AutoOpenPackToggle = Tabs.Manage:AddToggle("AutoOpenPackState", { Title = "เปิดแพ็กบนฐานอัตโนมัติ", Default = false })
AutoOpenPackToggle:OnChanged(function(state)
    getgenv().AutoOpenPack = state
    if state then
        task.spawn(function()
            while getgenv().AutoOpenPack do
                pcall(function()
                    local plot = findPlayerPlot()
                    if plot and plot:FindFirstChild("Plot_N0") then
                        for _, desc in ipairs(plot.Plot_N0:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") then
                                local actTxt = string.upper(desc.ActionText or "")
                                if actTxt:find("OPEN") or actTxt:find("เปิด") then
                                    local model = desc:FindFirstAncestorOfClass("Model")
                                    if model then
                                        local isReady = false
                                        if model:GetAttribute("Progress") == 1 or model:GetAttribute("IsReady") == true then
                                            isReady = true
                                        end
                                        if not isReady then
                                            local hasTimeText = false
                                            for _, txtObj in ipairs(model:GetDescendants()) do
                                                if (txtObj:IsA("TextLabel") or txtObj:IsA("TextButton")) and txtObj.Text then
                                                    if string.match(txtObj.Text, "%d+:%d+") or string.match(txtObj.Text, "%d+%.%d+s") then
                                                        hasTimeText = true
                                                        break
                                                    end
                                                end
                                            end
                                            if not hasTimeText then isReady = true end
                                        end
                                        
                                        if isReady then
                                            local char = LocalPlayer.Character
                                            local originalCFrame = char and char:GetPivot()
                                            local targetPos
                                            if desc.Parent:IsA("BasePart") then targetPos = desc.Parent.Position
                                            elseif desc.Parent:IsA("Attachment") then targetPos = desc.Parent.WorldPosition
                                            elseif model.PrimaryPart then targetPos = model.PrimaryPart.Position end
                                            
                                            if targetPos and char and char:FindFirstChild("HumanoidRootPart") then
                                                char.HumanoidRootPart.CFrame = CFrame.new(targetPos) + Vector3.new(0, 3, 0)
                                                task.wait(0.5)
                                            end
                                            
                                            desc.RequiresLineOfSight = false
                                            desc.MaxActivationDistance = 99999
                                            fireproximityprompt(desc)
                                            task.wait(0.5)
                                            
                                            if originalCFrame and char and char:FindFirstChild("HumanoidRootPart") then
                                                char.HumanoidRootPart.CFrame = originalCFrame
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

Tabs.Manage:AddSection("⬆️ อัปเกรดฐาน (Auto Upgrade)")

local UpgradeBudgetInput = Tabs.Manage:AddInput("UpgradeBudget", {
    Title = "เงินเก็บขั้นต่ำ (Anti-Broke Budget)",
    Default = "1000",
    Placeholder = "เช่น 5000",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        getgenv().UpgradeBudget = tonumber(Value) or 0
    end
})
getgenv().UpgradeBudget = 1000

local UpgradePriorityDrop = Tabs.Manage:AddDropdown("UpgradePriority", {
    Title = "จัดลำดับความสำคัญ (Priority)",
    Values = {"สมดุล (Balance)", "เน้นเงิน (Cash > Speed > Time)", "เน้นความเร็ว (Speed > Cash > Time)"},
    Multi = false,
    Default = "สมดุล (Balance)"
})
UpgradePriorityDrop:OnChanged(function(Value)
    getgenv().UpgradePriorityMode = Value
end)

local AutoUpgradeToggle = Tabs.Manage:AddToggle("AutoUpgradeBase", { Title = "อัปเกรดฐานและสายพานอัตโนมัติ", Default = false })
AutoUpgradeToggle:OnChanged(function(state)
    getgenv().AutoUpgradeBase = state
    if state then
        task.spawn(function()
            local function parseNum(str)
                if not str then return 0 end
                str = string.upper(str)
                if str:find("MAX") then return 999999999999999 end
                local numStr, suf = string.match(str, "([%d%.]+)%s*([A-Z]+)")
                if numStr then
                    local num = tonumber(numStr) or 0
                    if suf == "QI" then return num * 1e18
                    elseif suf == "QA" then return num * 1e15
                    elseif suf == "T" then return num * 1e12
                    elseif suf == "B" then return num * 1e9
                    elseif suf == "M" then return num * 1e6
                    elseif suf == "K" then return num * 1e3
                    end
                    return num
                end
                local nOnly = tonumber(string.match(str, "[%d%.]+"))
                return nOnly or 0
            end

            while getgenv().AutoUpgradeBase do
                pcall(function()
                    local currentCash = 0
                    if LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Cash") then
                        currentCash = LocalPlayer.leaderstats.Cash.Value
                    end
                    local budget = getgenv().UpgradeBudget or 0
                    local availableCash = currentCash - budget

                    if availableCash > 0 then
                        local upgradeFrames = {}
                        local gui = LocalPlayer:FindFirstChild("PlayerGui")
                        if gui then
                            for _, txt in ipairs(gui:GetDescendants()) do
                                if txt:IsA("TextLabel") and (
                                    txt.Text:find("Base Expansion") or 
                                    txt.Text:find("Luck Boost") or 
                                    txt.Text:find("Cash Boost") or 
                                    txt.Text:find("Time Boost") or 
                                    txt.Text:find("Speed Boost")
                                ) then
                                    local parentFrame = txt.Parent
                                    if parentFrame then
                                        for _, child in ipairs(parentFrame:GetDescendants()) do
                                            if child:IsA("TextButton") or child:IsA("ImageButton") then
                                                local bTxt = ""
                                                if child:IsA("TextButton") then bTxt = string.upper(child.Text)
                                                elseif child:FindFirstChildWhichIsA("TextLabel") then
                                                    bTxt = string.upper(child:FindFirstChildWhichIsA("TextLabel").Text)
                                                end
                                                if bTxt ~= "" and not bTxt:find("MAX") then
                                                    local cost = parseNum(bTxt)
                                                    if cost > 0 then
                                                        table.insert(upgradeFrames, { button = child, cost = cost, name = txt.Text, type = "ui" })
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        local plot = findPlayerPlot()
                        if plot and plot:FindFirstChild("Plot_N0") then
                            for _, prompt in ipairs(plot.Plot_N0:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") then
                                    local actTxt = string.upper((prompt.ActionText or "") .. " " .. (prompt.ObjectText or ""))
                                    if actTxt:find("UPGRADE") or actTxt:find("อัปเกรด") or actTxt:find("SPEED") or actTxt:find("CASH") then
                                        local cost = 0
                                        local matched = string.match(actTxt, "%$[%d%.KMBTQAQI]+")
                                        if matched then cost = parseNum(matched) end
                                        table.insert(upgradeFrames, { prompt = prompt, cost = cost, name = actTxt, type = "prompt" })
                                    end
                                end
                            end
                        end

                        table.sort(upgradeFrames, function(a, b) return a.cost < b.cost end)

                        for _, up in ipairs(upgradeFrames) do
                            if availableCash >= up.cost then
                                if up.type == "ui" and up.button then
                                    pcall(function()
                                        fireButton(up.button)
                                        if up.button:FindFirstChildOfClass("BindableEvent") then
                                            up.button:FindFirstChildOfClass("BindableEvent"):Fire()
                                        end
                                    end)
                                    availableCash = availableCash - up.cost
                                    task.wait(0.3)
                                elseif up.type == "prompt" and up.prompt then
                                    up.prompt.RequiresLineOfSight = false
                                    up.prompt.MaxActivationDistance = 99999
                                    fireproximityprompt(up.prompt)
                                    availableCash = availableCash - up.cost
                                    task.wait(0.3)
                                end
                            end
                        end
                    end
                end)
                task.wait(5)
            end
        end)
    end
end)

---------------------------------------------------------
-- 4. RAID & TOWER TAB (เรด & ทาวเวอร์)
---------------------------------------------------------
local RarityTiers = {
    ["admin"] = 1000000, ["แอดมิน"] = 1000000,
    ["divine"] = 900000, ["ดิไวน์"] = 900000,
    ["transcendent"] = 850000, ["ทรานเซนเดนท์"] = 850000,
    ["shadow"] = 800000, ["แชโดว์"] = 800000,
    ["emperor"] = 750000, ["เอมเพอเรอร์"] = 750000, ["จักรพรรดิ"] = 750000,
    ["demon"] = 700000, ["เดมอน"] = 700000, ["ปีศาจ"] = 700000,
    ["manga"] = 650000, ["มังงะ"] = 650000,
    ["celestial"] = 600000, ["เซเลสเชียล"] = 600000,
    ["heavenly"] = 550000, ["เฮฟเวนลี่"] = 550000,
    ["corrupted"] = 500000, ["คอร์รัปเต็ด"] = 500000,
    ["striker"] = 480000, ["สไตรเกอร์"] = 480000,
    ["sacred"] = 450000, ["เซเคอร์ด"] = 450000,
    ["paradox"] = 420000, ["พาราด็อกซ์"] = 420000,
    ["founder"] = 400000, ["ฟาวน์เดอร์"] = 400000,
    ["evolved"] = 380000, ["อีวอลฟ์"] = 380000,
    ["magic"] = 350000, ["เมจิก"] = 350000,
    ["oni"] = 320000, ["โอนิ"] = 320000,
    ["chaos"] = 300000, ["เคออส"] = 300000,
    ["ruin"] = 280000, ["รูอิน"] = 280000,
    ["reborn"] = 260000, ["รีบอร์น"] = 260000,
    ["beast"] = 240000, ["บีสต์"] = 240000,
    ["nordic"] = 220000, ["นอร์ดิค"] = 220000,
    ["hunter"] = 200000, ["ฮันเตอร์"] = 200000,
    ["soul"] = 180000, ["โซล"] = 180000,
    ["swordsman"] = 170000, ["สวอร์ดสแมน"] = 170000,
    ["gamer"] = 160000, ["เกมเมอร์"] = 160000,
    ["revenge"] = 150000, ["รีเวนจ์"] = 150000,
    ["chainsaw"] = 140000, ["เชนซอว์"] = 140000,
    ["eternity"] = 130000, ["อีเทอร์นิตี้"] = 130000,
    ["academy"] = 120000, ["อคาเดมี่"] = 120000,
    ["dynasty"] = 110000, ["ไดนาสตี้"] = 110000,
    ["grail"] = 105000, ["เกรล"] = 105000,
    ["conquest"] = 100000, ["คอนเควสต์"] = 100000,
    ["blaze"] = 95000, ["เบลซ"] = 95000,
    ["devour"] = 90000, ["ดีเวาร์"] = 90000,
    ["raven"] = 85000, ["เรเวน"] = 85000,
    ["arcane"] = 80000, ["อาเคน"] = 80000,
    ["nightfall"] = 75000, ["ไนท์ฟอล"] = 75000,
    ["smash"] = 70000, ["สแมช"] = 70000,
    ["emblem"] = 65000, ["เอมเบลม"] = 65000,
    ["chrono"] = 60000, ["โครโน"] = 60000,
    ["godly"] = 55000, ["ก๊อดลี่"] = 55000, ["กอดลี่"] = 55000,
    ["secret"] = 50000, ["ซีเคร็ท"] = 50000, ["ซีเครท"] = 50000,
    ["mythic"] = 30000, ["mythical"] = 30000, ["มิทิคอล"] = 30000, ["มิทิค"] = 30000,
    ["legendary"] = 15000, ["เลเจนดารี่"] = 15000,
    ["epic"] = 8000, ["เอพิก"] = 8000,
    ["rare"] = 4000, ["แรร์"] = 4000,
    ["uncommon"] = 2000, ["อันคอมมอน"] = 2000,
    ["common"] = 1000, ["คอมมอน"] = 1000,
}

local MutationScores = {
    ["unknow"] = 13000, ["unknown"] = 13000, ["admin"] = 12000, ["starfallen"] = 11000, ["glitch"] = 10000,
    ["radioactive"] = 9000, ["blessed"] = 8000, ["candy"] = 7000, ["sakura"] = 6000,
    ["rainbow"] = 5000, ["venomous"] = 4000, ["diamond"] = 3000, ["golden"] = 2000,
}

local function parseSuffixValue(txt)
    if not txt then return 0 end
    local numStr, suffix = string.match(string.upper(txt), "([%d%.]+)%s*([A-Z]+)")
    if numStr then
        local num = tonumber(numStr) or 0
        local mult = 1
        if suffix == "DC" then mult = 1e33
        elseif suffix == "NO" then mult = 1e30
        elseif suffix == "OC" then mult = 1e27
        elseif suffix == "SP" then mult = 1e24
        elseif suffix == "SX" then mult = 1e21
        elseif suffix == "QI" then mult = 1e18
        elseif suffix == "QA" then mult = 1e15
        elseif suffix == "T" then mult = 1e12
        elseif suffix == "B" then mult = 1e9
        elseif suffix == "M" then mult = 1e6
        elseif suffix == "K" then mult = 1e3
        end
        return num * mult
    end
    return 0
end

local function getRarityScore(rarityText)
    if not rarityText then return 0 end
    local clean = string.lower(string.gsub(tostring(rarityText), "<[^>]+>", ""))
    for k, score in pairs(RarityTiers) do
        if string.find(clean, k) then return score end
    end
    return 0
end

-- Helper to check if a model/prompt is a Raid Card, Boss Card, Pack, Ticket, or non-unit object
local function isSpecialNonUnitItem(model, promptText)
    if not model then return true end

    if model:GetAttribute("BoxValue") ~= nil 
        or model:GetAttribute("IsPack") == true 
        or model:GetAttribute("PackName") ~= nil
        or model:GetAttribute("IsBossCard") == true
        or model:GetAttribute("IsRaidCard") == true
        or model:GetAttribute("IsTitanCard") == true
    then
        return true
    end

    local modelName = string.upper(model.Name or "")
    local cardNameAttr = string.upper(tostring(model:GetAttribute("CardName") or model:GetAttribute("TemplateName") or model:GetAttribute("Name") or ""))
    local promptUpper = string.upper(promptText or "")

    local nonUnitKeywords = {
        "RAID", "BOSS", "TITAN", "EVENT", "PASS", "TICKET", "KEY",
        "PACK", "BOX", "CHEST", "BAG", "SELL", "BUY", "SPAWN",
        "UPGRADE", "CLAIM", "REBIRTH", "JOIN", "ENTER", "CONVEYOR",
        "เรด", "บอส", "ไททัน", "แพ็ค", "แพ็ก", "กล่อง", "ตั๋ว", "บัตร", "กุญแจ", "ถุง", "อีเวนต์", "กิจกรรม"
    }

    for _, kw in ipairs(nonUnitKeywords) do
        if string.find(modelName, kw) or string.find(cardNameAttr, kw) or string.find(promptUpper, kw) then
            return true
        end
    end

    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
            local txtUpper = string.upper(desc.Text or "")
            for _, kw in ipairs(nonUnitKeywords) do
                if string.find(txtUpper, kw) then
                    return true
                end
            end
        end
    end

    return false
end

local function collect4BestBaseCards(cardSource)
    pcall(function()
        local source = cardSource or getgenv().TowerCardSource or "จากในกระเป๋า (Inventory)"
        if source == "จากในกระเป๋า (Inventory)" then
            return
        end

        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local plotFolder = findPlayerPlot()
        if not plotFolder then return end

        local cardList = {}
        local processedModels = {}

        -- สแกนทุก Plot_N0 ถึง Plot_N4 (Plot 1-4 ที่มีการ์ดวางอยู่)
        local plotsToScan = { plotFolder }
        -- หาก plotFolder มี parent ที่เป็น Plots folder ให้สแกนทุก plot ภายใน
        local plotsParent = plotFolder.Parent
        if plotsParent and plotsParent.Name == "Plots" then
            for _, sibling in ipairs(plotsParent:GetChildren()) do
                local sibOwner = sibling:GetAttribute("Owner")
                if sibling ~= plotFolder and (sibOwner == LocalPlayer.Name or sibOwner == nil) then
                    -- ดึงเฉพาะ plots ของตัวเอง หรือ plots ว่าง
                    -- ไม่ใส่ plots คนอื่นเข้า
                end
            end
        end
        -- ขยายไปยัง sub-plot folders ภายใน plotFolder (Plot_N0, Plot_N1, Plot_N2...)
        local additionalFolders = {}
        for i = 0, 4 do
            local subPlot = plotFolder:FindFirstChild("Plot_N" .. tostring(i))
            if subPlot then table.insert(additionalFolders, subPlot) end
        end
        -- รวมทุก folder
        for _, f in ipairs(additionalFolders) do
            table.insert(plotsToScan, f)
        end

        -- สแกนการ์ดจากทุก folder ที่รวบรวมไว้
        for _, scanTarget in ipairs(plotsToScan) do
        for _, desc in ipairs(scanTarget:GetDescendants()) do
            if desc:IsA("ProximityPrompt") or desc:IsA("ClickDetector") then
                local pText = desc:IsA("ProximityPrompt") and string.upper((desc.ActionText or "") .. " " .. (desc.ObjectText or "")) or ""
                
                local isIgnoredAction = string.find(pText, "BUY") or string.find(pText, "ซื้อ")
                    or string.find(pText, "SPAWN") or string.find(pText, "สุ่ม")
                    or string.find(pText, "OPEN") or string.find(pText, "เปิด")
                    or string.find(pText, "TOWER") or string.find(pText, "ทาวเวอร์")
                    or string.find(pText, "UPGRADE") or string.find(pText, "อัปเกรด")
                    or string.find(pText, "CLAIM") or string.find(pText, "รับ")
                    or string.find(pText, "SELL") or string.find(pText, "ขาย")
                    or string.find(pText, "REBIRTH") or string.find(pText, "จุติ")
                    or string.find(pText, "JOIN") or string.find(pText, "ENTER")
                
                if not isIgnoredAction then
                    local model = desc:FindFirstAncestorOfClass("Model")
                    if model and model.Name ~= "SellPart" and not model:FindFirstChildOfClass("Humanoid") and not processedModels[model] then
                        if isSpecialNonUnitItem(model, pText) or isPackCard(model) then
                            continue
                        end
                        
                        processedModels[model] = true
                        
                        local cashScore, rarityScore, mutationScore, levelScore = 0, 0, 0, 0
                        
                        local attrRarity = model:GetAttribute("Rarity") or model:GetAttribute("CardGrade") or model:GetAttribute("Grade") or model:GetAttribute("CardRarity")
                        if attrRarity then
                            local s = getRarityScore(attrRarity)
                            if s > rarityScore then rarityScore = s end
                        end
                        
                        local attrMut = model:GetAttribute("Mutation") or model:GetAttribute("CardMutation")
                        if attrMut then
                            local cleanMut = string.lower(tostring(attrMut))
                            for mName, mScore in pairs(MutationScores) do
                                if string.find(cleanMut, mName) and mScore > mutationScore then
                                    mutationScore = mScore
                                end
                            end
                        end

                        local attrLvl = model:GetAttribute("Level") or model:GetAttribute("CardLevel")
                        if attrLvl and tonumber(attrLvl) then
                            levelScore = tonumber(attrLvl)
                        end

                        local attrMult = model:GetAttribute("CashMultiplier") or model:GetAttribute("Multiplier") or model:GetAttribute("Damage") or model:GetAttribute("Power")
                        if attrMult and tonumber(attrMult) then
                            cashScore = tonumber(attrMult)
                        end
                        
                        for _, txtObj in ipairs(model:GetDescendants()) do
                            if txtObj:IsA("TextLabel") or txtObj:IsA("TextButton") then
                                local txt = txtObj.Text or ""
                                local val = parseSuffixValue(txt)
                                if val > cashScore then cashScore = val end
                                
                                local s = getRarityScore(txt)
                                if s > rarityScore then rarityScore = s end
                                
                                local cleanMut = string.lower(string.gsub(txt, "<[^>]+>", ""))
                                cleanMut = string.match(cleanMut, "^%s*(.-)%s*$") or ""
                                for mName, mScore in pairs(MutationScores) do
                                    if string.find(cleanMut, mName) and mScore > mutationScore then
                                        mutationScore = mScore
                                    end
                                end

                                if levelScore == 0 then
                                    local lvlNum = string.match(txt, "[L|l][V|v][L|l]%s*:%s*(%d+)") or string.match(txt, "[L|l][V|v]%s*:%s*(%d+)")
                                    if lvlNum then levelScore = tonumber(lvlNum) or 0 end
                                end
                            end
                        end
                        
                        local totalScore = (rarityScore * 10000000) + (mutationScore * 100000) + (levelScore * 1000) + math.min(cashScore, 999)
                        if totalScore > 0 and not string.find(string.upper(model.Name or ""), "PLOT") then
                            table.insert(cardList, { interact = desc, score = totalScore, model = model })
                        end
                    end
                end
            end
        end  -- end for _, desc
        end  -- end for _, scanTarget in plotsToScan

        if #cardList == 0 then return end
        table.sort(cardList, function(a, b) return a.score > b.score end)

        local originalCFrame = hrp.CFrame
        getgenv().CollectedCardPositions = {}

        for i = 1, math.min(4, #cardList) do
            local item = cardList[i]
            if item and item.interact and item.interact.Parent then
                pcall(function()
                    local targetPos
                    if item.interact.Parent:IsA("BasePart") then
                        targetPos = item.interact.Parent.Position
                    elseif item.interact.Parent:IsA("Attachment") then
                        targetPos = item.interact.Parent.WorldPosition
                    elseif item.model and item.model.PrimaryPart then
                        targetPos = item.model.PrimaryPart.Position
                    end
                    
                    if targetPos and hrp then
                        table.insert(getgenv().CollectedCardPositions, targetPos)
                        hrp.CFrame = CFrame.new(targetPos) + Vector3.new(0, 2, 0)
                        task.wait(0.12)
                        
                        if item.interact:IsA("ProximityPrompt") then
                            item.interact.RequiresLineOfSight = false
                            item.interact.MaxActivationDistance = 99999
                            item.interact.HoldDuration = 0
                            for _ = 1, 2 do
                                if not item.interact or not item.interact.Parent then break end
                                fireproximityprompt(item.interact)
                                task.wait(0.05)
                            end
                        elseif item.interact:IsA("ClickDetector") then
                            for _ = 1, 2 do
                                fireclickdetector(item.interact)
                                task.wait(0.05)
                            end
                        end
                        task.wait(0.08)
                    end
                end)
            end
        end

        if originalCFrame and hrp then
            hrp.CFrame = originalCFrame
            task.wait(0.1)
        end
    end)
end

local function placeCollectedCardsBack()
    pcall(function()
        local positions = getgenv().CollectedCardPositions
        if not positions or #positions == 0 then return end

        local startCF = LocalPlayer.Character and LocalPlayer.Character:GetPivot()

        for _, pos in ipairs(positions) do
            pcall(function()
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if not hrp or not humanoid then return end

                local tool
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, t in ipairs(backpack:GetChildren()) do
                        if t:IsA("Tool") and not isPackCard(t) then tool = t break end
                    end
                end
                if not tool and character then
                    for _, t in ipairs(character:GetChildren()) do
                        if t:IsA("Tool") and not isPackCard(t) then tool = t break end
                    end
                end

                if tool then
                    humanoid:EquipTool(tool)
                    task.wait(0.12)
                else
                    return
                end

                hrp.CFrame = CFrame.new(pos) + Vector3.new(0, 2, 0)
                task.wait(0.12)

                local plotFolder = findPlayerPlot()
                if plotFolder then
                    for _, desc in ipairs(plotFolder:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") or desc:IsA("ClickDetector") then
                            local descPos
                            if desc.Parent:IsA("BasePart") then descPos = desc.Parent.Position
                            elseif desc.Parent:IsA("Attachment") then descPos = desc.Parent.WorldPosition end
                            
                            if descPos and (descPos - pos).Magnitude < 5 then
                                if desc:IsA("ProximityPrompt") then
                                    desc.RequiresLineOfSight = false
                                    desc.MaxActivationDistance = 99999
                                    desc.HoldDuration = 0
                                    for _ = 1, 2 do fireproximityprompt(desc) task.wait(0.05) end
                                elseif desc:IsA("ClickDetector") then
                                    for _ = 1, 2 do fireclickdetector(desc) task.wait(0.05) end
                                end
                                break
                            end
                        end
                    end
                end
                task.wait(0.1)
            end)
        end

        getgenv().CollectedCardPositions = nil
        if LocalPlayer.Character and startCF then
            LocalPlayer.Character:PivotTo(startCF)
            task.wait(0.1)
        end
    end)
end

local function getCurrentHourKey()
    return os.date("!%Y-%m-%d-%H")
end

local function hasFoughtBossThisHour()
    return getgenv().BossFoughtHourKey == getCurrentHourKey()
end

local function isBossTimeWindow()
    local min = tonumber(os.date("!%M")) or tonumber(os.date("%M")) or 0
    return min <= 5 or min >= 58
end

local function closeBossRaidUI()
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        for _, v in ipairs(playerGui:GetDescendants()) do
            if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                local txt = v:IsA("TextButton") and v.Text or ""
                local cleanTxt = string.upper(string.match(string.gsub(txt, "<[^>]+>", ""), "^%s*(.-)%s*$") or "")
                local name = string.upper(v.Name or "")
                if cleanTxt == "X" or name == "CLOSE" or name == "CLOSEBUTTON" or name == "EXIT" or name == "XBUTTON" or name == "XBTN" then
                    local p = v.Parent
                    local isRaidUI = false
                    while p and p:IsA("GuiObject") do
                        local pName = string.upper(p.Name)
                        if pName:find("RAID") or pName:find("BOSS") then
                            isRaidUI = true
                            break
                        end
                        p = p.Parent
                    end
                    if isRaidUI or cleanTxt == "X" then
                        fireButton(v)
                        task.wait(0.1)
                    end
                end
            end
        end
    end)
end

local function exitTowerNow()
    getgenv().AutoReplayToggled = false
    pcall(closeBossRaidUI)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local exitButtons = {}
        local autoReplayButtons = {}

        for _, v in ipairs(playerGui:GetDescendants()) do
            if v:IsA("TextButton") or v:IsA("ImageButton") or v:IsA("TextLabel") then
                local cleanText = (v:IsA("TextLabel") or v:IsA("TextButton")) and string.gsub(v.Text or "", "<[^>]+>", "") or ""
                local text = string.upper(string.match(cleanText, "^%s*(.-)%s*$") or "")
                local name = string.upper(v.Name or "")

                local btn = (v:IsA("TextButton") or v:IsA("ImageButton")) and v 
                    or v:FindFirstAncestorWhichIsA("TextButton") 
                    or v:FindFirstAncestorWhichIsA("ImageButton")

                if btn then
                    if text == "AUTO REPLAY" or name:find("AUTOREPLAY") or name:find("REPLAY") then
                        table.insert(autoReplayButtons, btn)
                    end

                    if text:find("EXIT") or text:find("LEAVE") or text:find("QUIT") or text:find("ABANDON") 
                        or text:find("CANCEL") or text:find("ออก") or text:find("ถอนตัว")
                        or name:find("EXIT") or name:find("LEAVE") or name:find("QUIT") or name:find("CLOSE")
                        or name:find("ABANDON") or name:find("CANCEL") or name:find("RETURN")
                    then
                        table.insert(exitButtons, btn)
                    end
                end
            end
        end

        for _, btn in ipairs(autoReplayButtons) do
            pcall(function() fireButton(btn) end)
            task.wait(0.2)
        end

        for _, btn in ipairs(exitButtons) do
            pcall(function() fireButton(btn) end)
            task.wait(0.2)
        end
    end

    local character = LocalPlayer.Character
    if getgenv().TowerOriginalCFrame and character then
        character:PivotTo(getgenv().TowerOriginalCFrame)
        getgenv().TowerOriginalCFrame = nil
    end

    pcall(placeCollectedCardsBack)
    getgenv().TowerHasCollected = false
end

-- UI Component Setup

getgenv().TargetTowerFloor = getgenv().TargetTowerFloor or 0
local TargetFloorInput = Tabs.Raid:AddInput("TargetTowerFloorInput", {
    Title = "🏰 ชั้นหอคอยเป้าหมาย (0 = ชั้นล่าสุด/สูงสุด)",
    Default = tostring(getgenv().TargetTowerFloor or 0),
    Placeholder = "เช่น 10 (ใส่ 0 เพื่อลงชั้นสูงสุด)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        getgenv().TargetTowerFloor = tonumber(Value) or 0
    end
})

getgenv().TowerCardSource = getgenv().TowerCardSource or "จากในกระเป๋า (Inventory)"
local TowerSourceDropdown = Tabs.Raid:AddDropdown("TowerCardSource", {
    Title = "🏰 แหล่งที่มาของการ์ดหอคอย",
    Values = {"จากในกระเป๋า (Inventory)", "จากบนฐาน (Plot)"},
    Multi = false,
    Default = getgenv().TowerCardSource
})
TowerSourceDropdown:OnChanged(function(Value)
    getgenv().TowerCardSource = Value
end)

getgenv().BossCardSource = getgenv().BossCardSource or "จากในกระเป๋า (Inventory)"
local BossSourceDropdown = Tabs.Raid:AddDropdown("BossCardSource", {
    Title = "🐉 แหล่งที่มาของการ์ดบอสเรด",
    Values = {"จากในกระเป๋า (Inventory)", "จากบนฐาน (Plot)"},
    Multi = false,
    Default = getgenv().BossCardSource
})
BossSourceDropdown:OnChanged(function(Value)
    getgenv().BossCardSource = Value
end)

local BossDiffDropdown = Tabs.Raid:AddDropdown("BossRaidDifficulty", {
    Title = "⚔️ ระดับความยากบอสเรด",
    Values = { "EASY", "MEDIUM", "HARD", "NIGHTMARE" },
    Multi = false,
    Default = getgenv().BossRaidDifficulty or "NIGHTMARE"
})
BossDiffDropdown:OnChanged(function(Value)
    getgenv().BossRaidDifficulty = Value
end)

local function getMinutesToNextBoss()
    local min = tonumber(os.date("!%M")) or tonumber(os.date("%M")) or 0
    if min <= 5 then return 0
    elseif min >= 58 then return 0
    else return 58 - min end
end

-- Unified Background Orchestrator Loop for Tower & Boss Raid
local isRaidTowerLoopRunning = false
local function startRaidTowerManagerLoop()
    if isRaidTowerLoopRunning then return end
    isRaidTowerLoopRunning = true

    task.spawn(function()
        local _lastBossAttemptTick = 0  -- throttle: ป้องกันกด boss ซ้ำเร็วเกินไป
        local _bossCompletedThisWindow = false  -- flag รอบ boss window นี้จบแล้ว
        local _prevBossTimeWindow = false  -- detect เปลี่ยน window
        while getgenv().AutoTower or getgenv().AutoBossRaid do
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local isBossTime = isBossTimeWindow()
            local bossAlreadyDone = hasFoughtBossThisHour()

            -- Reset per-window completed flag เมื่อออกจาก boss window
            if not isBossTime and _prevBossTimeWindow then
                _bossCompletedThisWindow = false
            end
            _prevBossTimeWindow = isBossTime

            -- shouldDoBoss: เปิดให้ลงบอสได้เฉพาะเมื่อ boss window เปิดอยู่ และยังไม่ได้ลงรอบนี้
            local shouldDoBoss = getgenv().AutoBossRaid and isBossTime and not bossAlreadyDone and not _bossCompletedThisWindow

            if playerGui then
                local function isGuiVisible(gui)
                    if not gui or (gui:IsA("GuiObject") and not gui.Visible) then return false end
                    local current = gui.Parent
                    while current and current:IsA("GuiObject") do
                        if not current.Visible then return false end
                        current = current.Parent
                    end
                    return not (current and current:IsA("ScreenGui")) or current.Enabled
                end

                if shouldDoBoss then
                    -- 1. Execute Boss Raid Logic
                    -- Priority Guard: ออกจากหอคอยเฉพาะเมื่อ boss window เปิดจริง
                    -- ป้องกันสลับออกจากหอคอยกลางคัน แล้วพลาดรางวัล
                    if getgenv().AutoReplayToggled or getgenv().TowerHasCollected then
                        if logLine then pcall(function() logLine("RAID", "🐉 ถึงเวลาบอสเรด! รอจบ auto replay แล้วออก...") end) end
                        -- รอให้ auto replay จบก่อน (ไม่ exit กลางคัน) โดยรออีก 3 วินาที
                        -- ถ้าเกิน 5 นาทีใน boss window แล้วยังไม่จบ ค่อย force exit
                        local waitedSec = 0
                        while (getgenv().AutoReplayToggled or getgenv().TowerHasCollected) and isBossTimeWindow() and waitedSec < 180 do
                            task.wait(3)
                            waitedSec = waitedSec + 3
                        end
                        if getgenv().AutoReplayToggled or getgenv().TowerHasCollected then
                            if logLine then pcall(function() logLine("RAID", "🐉 รอนานเกินไป! ออกจากหอคอยเพื่อลงบอส...") end) end
                            Fluent:Notify({ Title = "บอสเรด", Content = "ถึงเวลาบอสเรด! กำลังออกจากหอคอย...", Duration = 4 })
                            exitTowerNow()
                            task.wait(1.5)
                        end
                    end

                    local equipBtn, battleBtn, diffBtn, autoReplayBtn, showBattleBtn, hideBattleBtn
                    local alreadyFoughtText = false

                    for _, v in ipairs(playerGui:GetDescendants()) do
                        if (v:IsA("TextButton") or v:IsA("TextLabel")) and v.Text then
                            local cleanText = string.gsub(v.Text, "<[^>]+>", "")
                            local text = string.upper(string.match(cleanText, "^%s*(.-)%s*$") or "")
                            
                            if string.find(text, "ALREADY FOUGHT THE BOSS") and isGuiVisible(v) then
                                alreadyFoughtText = true
                            end

                            local isInventoryBtn = false
                            local parentObj = v.Parent
                            while parentObj and parentObj:IsA("GuiObject") do
                                local pName = string.lower(parentObj.Name)
                                if pName:find("inventory") or pName:find("backpack") or pName:find("cardbag") or pName:find("bag") or pName:find("คลัง") then
                                    isInventoryBtn = true
                                    break
                                end
                                parentObj = parentObj.Parent
                            end

                            local targetDiff = string.upper(tostring(getgenv().BossRaidDifficulty or "NIGHTMARE"))
                            if (text == "EQUIP BEST" or text == "สวมใส่ดีที่สุด" or text == "สวมใส่ที่ดีที่สุด") and not isInventoryBtn then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then equipBtn = btn end
                            elseif text == "BATTLE" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then battleBtn = btn end
                            elseif text == targetDiff then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then diffBtn = btn end
                            elseif text == "AUTO REPLAY" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then autoReplayBtn = btn end
                            elseif text == "SHOW BATTLE" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then showBattleBtn = btn end
                            elseif text == "HIDE BATTLE" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then hideBattleBtn = btn end
                            end
                        end
                    end

                    if alreadyFoughtText then
                        getgenv().BossFoughtHourKey = getCurrentHourKey()
                        pcall(closeBossRaidUI)
                        Fluent:Notify({ Title = "บอสเรด", Content = "คุณสู้บอสไปแล้วในชั่วโมงนี้! สลับกลับไปลงหอคอย", Duration = 4 })
                    else
                        local inBattle = equipBtn or battleBtn or autoReplayBtn or showBattleBtn
                        if not inBattle then
                            if getgenv().BossCardSource == "จากบนฐาน (Plot)" and not getgenv().BossHasCollected then
                                collect4BestBaseCards(getgenv().BossCardSource)
                                getgenv().BossHasCollected = true
                                task.wait(0.5)
                            end

                            local bossPrompt, portalPrompt
                            for _, p in ipairs(workspace:GetDescendants()) do
                                if p:IsA("ProximityPrompt") then
                                    local pText = string.upper(p.ActionText .. " " .. p.ObjectText .. " " .. (p.Parent and p.Parent.Name or ""))
                                    if string.find(pText, "BOSS RAID") and string.find(pText, "TELEPORT") then
                                        portalPrompt = p
                                    elseif not string.find(pText, "SHOP") and not string.find(pText, "RETURN") and not string.find(pText, "BACK") and not string.find(pText, "TELEPORT") then
                                        if string.find(pText, "TITAN") or string.find(pText, "BOSS") or string.find(pText, "RAID") or string.find(pText, "FIGHT") then
                                            bossPrompt = p
                                        end
                                    end
                                end
                            end

                            local targetPrompt = bossPrompt or portalPrompt
                            if targetPrompt then
                                pcall(function()
                                    local character = LocalPlayer.Character
                                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        local targetPos = targetPrompt.Parent:IsA("BasePart") and targetPrompt.Parent.Position
                                            or (targetPrompt.Parent:IsA("Attachment") and targetPrompt.Parent.WorldPosition)
                                            or (targetPrompt.Parent:IsA("Model") and targetPrompt.Parent.PrimaryPart and targetPrompt.Parent.PrimaryPart.Position)
                                        if targetPos and (hrp.Position - targetPos).Magnitude > 15 then
                                            if not getgenv().BossOriginalCFrame then
                                                getgenv().BossOriginalCFrame = character:GetPivot()
                                            end
                                            character:PivotTo(CFrame.new(targetPos) + Vector3.new(0, 3, 0))
                                            task.wait(0.1)
                                        end
                                    end
                                    targetPrompt.RequiresLineOfSight = false
                                    targetPrompt.MaxActivationDistance = 99999
                                    fireproximityprompt(targetPrompt)
                                end)
                                task.wait(0.5)
                            end
                        end

                        if diffBtn and not (autoReplayBtn or showBattleBtn) then fireButton(diffBtn) task.wait(0.1) end
                        if equipBtn then fireButton(equipBtn) task.wait(0.1) end
                        if battleBtn then
                            if logLine then pcall(function() logLine("RAID", "🐉 เริ่มเข้าต่อสู้บอสเรด (Boss Raid)") end) end
                            fireButton(battleBtn)
                            task.wait(1.5)  -- รอให้ battle เริ่มก่อน
                            -- Set BossFoughtHourKey หลัง battle เริ่มจริงแล้ว ป้องกัน race condition
                            getgenv().BossFoughtHourKey = getCurrentHourKey()
                            _bossCompletedThisWindow = true  -- mark รอบนี้ลงแล้ว
                            _lastBossAttemptTick = tick()
                            local character = LocalPlayer.Character
                            if getgenv().BossOriginalCFrame and character then
                                character:PivotTo(getgenv().BossOriginalCFrame)
                                getgenv().BossOriginalCFrame = nil
                                placeCollectedCardsBack()
                            end
                            getgenv().BossHasCollected = false
                            getgenv().AutoReplayToggledBoss = false
                            getgenv().AutoReplayToggled = false  -- reset tower replay เพื่อให้กลับไปลงหอได้ใหม่
                            pcall(closeBossRaidUI)
                        end

                        if autoReplayBtn and not getgenv().AutoReplayToggledBoss then
                            fireButton(autoReplayBtn)
                            getgenv().AutoReplayToggledBoss = true
                            task.wait(0.2)
                        end

                        if hideBattleBtn then fireButton(hideBattleBtn) task.wait(0.2) end
                    end

                elseif getgenv().AutoTower then
                    -- 2. Execute Auto Tower Logic
                    local equipBtn, battleBtn, nextBtn, playBtn, openBtn, autoReplayBtn, hideBattleBtn, showBattleBtn
                    
                    for _, v in ipairs(playerGui:GetDescendants()) do
                        if (v:IsA("TextButton") or v:IsA("TextLabel")) and v.Text then
                            local cleanText = string.gsub(v.Text, "<[^>]+>", "")
                            local text = string.upper(string.match(cleanText, "^%s*(.-)%s*$") or "")
                            
                            local isInventoryBtn = false
                            local parentObj = v.Parent
                            while parentObj and parentObj:IsA("GuiObject") do
                                local pName = string.lower(parentObj.Name)
                                if pName:find("inventory") or pName:find("backpack") or pName:find("cardbag") or pName:find("bag") or pName:find("คลัง") then
                                    isInventoryBtn = true
                                    break
                                end
                                parentObj = parentObj.Parent
                            end

                            if (text == "EQUIP BEST" or text == "สวมใส่ดีที่สุด" or text == "สวมใส่ที่ดีที่สุด") and not isInventoryBtn then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then equipBtn = btn end
                            elseif text == "BATTLE" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then battleBtn = btn end
                            elseif text == "NEXT" or text == "NEXT FLOOR" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then nextBtn = btn end
                            elseif text == "PLAY" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then playBtn = btn end
                            elseif text == "AUTO REPLAY" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then autoReplayBtn = btn end
                            elseif text == "HIDE BATTLE" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then hideBattleBtn = btn end
                            elseif text == "SHOW BATTLE" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then showBattleBtn = btn end
                            elseif string.find(text, "OPEN INFINITY TOWER") then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn then openBtn = btn end
                            end
                        end
                    end

                    -- Apply Target Floor setting if specified by user
                    local targetFloorNum = tonumber(getgenv().TargetTowerFloor) or 0
                    if targetFloorNum > 0 then
                        pcall(function()
                            for _, tb in ipairs(playerGui:GetDescendants()) do
                                if tb:IsA("TextBox") and isGuiVisible(tb) then
                                    local pName = string.lower(tb.Name)
                                    local parentName = tb.Parent and string.lower(tb.Parent.Name) or ""
                                    if pName:find("floor") or pName:find("level") or parentName:find("tower") or parentName:find("floor") then
                                        if tb.Text ~= tostring(targetFloorNum) then
                                            tb.Text = tostring(targetFloorNum)
                                            if getconnections then
                                                for _, c in ipairs(getconnections(tb.FocusLost)) do c:Fire(true) end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end

                    local openPrompt
                    for _, p in ipairs(workspace:GetDescendants()) do
                        if p:IsA("ProximityPrompt") then
                            local pText = string.upper(p.ActionText .. " " .. p.ObjectText)
                            if string.find(pText, "OPEN INFINITY TOWER") or string.find(pText, "INFINITY TOWER") then
                                openPrompt = p
                                break
                            end
                        end
                    end

                    local inTowerUI = equipBtn or battleBtn
                    local inBattle = autoReplayBtn or showBattleBtn

                    if openPrompt and not inTowerUI and not inBattle then
                        if getgenv().TowerCardSource == "จากบนฐาน (Plot)" and not getgenv().TowerHasCollected then
                            collect4BestBaseCards()
                            getgenv().TowerHasCollected = true
                            task.wait(0.5)
                        end
                        pcall(function()
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local targetPos = openPrompt.Parent:IsA("BasePart") and openPrompt.Parent.Position
                                    or (openPrompt.Parent:IsA("Attachment") and openPrompt.Parent.WorldPosition)
                                    or (openPrompt.Parent:IsA("Model") and openPrompt.Parent.PrimaryPart and openPrompt.Parent.PrimaryPart.Position)
                                if targetPos and (hrp.Position - targetPos).Magnitude > 15 then
                                    if not getgenv().TowerOriginalCFrame then getgenv().TowerOriginalCFrame = LocalPlayer.Character:GetPivot() end
                                    LocalPlayer.Character:PivotTo(CFrame.new(targetPos) + Vector3.new(0, 3, 0))
                                    task.wait(0.2)
                                end
                            end
                            openPrompt.RequiresLineOfSight = false
                            openPrompt.MaxActivationDistance = 99999
                            fireproximityprompt(openPrompt)
                        end)
                        task.wait(0.4)
                    end

                    if openBtn and not inTowerUI and not inBattle then fireButton(openBtn) task.wait(0.4) end
                    if equipBtn then fireButton(equipBtn) task.wait(0.4) end
                    if battleBtn then
                        local floorNotice = targetFloorNum > 0 and (" ชั้น: " .. tostring(targetFloorNum)) or ""
                        if logLine then pcall(function() logLine("TOWER", "🏰 เริ่มเข้าต่อสู้หอคอย (Infinity Tower)" .. floorNotice) end) end
                        fireButton(battleBtn)
                        task.wait(0.5)
                        if getgenv().TowerOriginalCFrame and LocalPlayer.Character then
                            LocalPlayer.Character:PivotTo(getgenv().TowerOriginalCFrame)
                            getgenv().TowerOriginalCFrame = nil
                            placeCollectedCardsBack()
                        end
                        getgenv().TowerHasCollected = false
                    end
                    if autoReplayBtn and not getgenv().AutoReplayToggled then
                        -- ป้องกันกด auto replay ในขณะที่กำลังจะลงบอส (ใน boss window)
                        if not (getgenv().AutoBossRaid and isBossTimeWindow() and not hasFoughtBossThisHour()) then
                            fireButton(autoReplayBtn)
                            getgenv().AutoReplayToggled = true
                            task.wait(0.3)
                        end
                    end
                    if nextBtn then fireButton(nextBtn) task.wait(0.2) end
                    if playBtn then fireButton(playBtn) task.wait(0.2) end
                end
            end
            task.wait(0.3)
        end
        isRaidTowerLoopRunning = false
    end)
end

local AutoTowerToggle = Tabs.Raid:AddToggle("AutoTower", { Title = "🏰 ลงหอคอยอัตโนมัติ (Auto Tower)", Default = false })
AutoTowerToggle:OnChanged(function(state)
    getgenv().AutoTower = state
    if not state and not getgenv().AutoBossRaid then
        local cam = workspace.CurrentCamera
        local character = LocalPlayer.Character
        if cam and getgenv().TowerSavedCamCF then
            cam.CameraType = Enum.CameraType.Custom
            if character and character:FindFirstChild("Humanoid") then
                cam.CameraSubject = character.Humanoid
            end
            getgenv().TowerSavedCamCF = nil
        end
        if getgenv().TowerOriginalCFrame and character then
            character:PivotTo(getgenv().TowerOriginalCFrame)
            getgenv().TowerOriginalCFrame = nil
        end
    end
    if state then
        startRaidTowerManagerLoop()
    end
end)

local AutoBossToggle = Tabs.Raid:AddToggle("AutoBossRaid", { Title = "🐉 ลงบอสเรดอัตโนมัติ (Auto Boss Raid)", Default = false })
AutoBossToggle:OnChanged(function(state)
    getgenv().AutoBossRaid = state
    if state then
        startRaidTowerManagerLoop()
    end
end)

Tabs.Raid:AddButton({
    Title = "⏱️ เช็คคูลดาวน์บอสเรด",
    Callback = function()
        local minLeft = getMinutesToNextBoss()
        Fluent:Notify({ Title = "คูลดาวน์บอสเรด", Content = string.format("เหลือเวลาอีก %d นาที จะเกิดบอสรอบถัดไป", minLeft), Duration = 5 })
    end
})

---------------------------------------------------------
-- 5. TRADE TAB (แลกเปลี่ยน)
---------------------------------------------------------
local TradePlayerDropdown = Tabs.Trade:AddDropdown("SelectedTradePlayer", {
    Title = "👤 เลือกผู้เล่นที่จะแลกเปลี่ยน",
    Values = GetPlayerNames(),
    Multi = false,
    Default = "ไม่มีผู้เล่นอื่น"
})
TradePlayerDropdown:OnChanged(function(Value)
    getgenv().SelectedTradePlayer = tostring(Value or "")
end)

Tabs.Trade:AddButton({
    Title = "🔄 รีเฟรชรายชื่อผู้เล่น",
    Callback = function()
        TradePlayerDropdown:SetValues(GetPlayerNames())
        Fluent:Notify({ Title = "แลกเปลี่ยน", Content = "รีเฟรชรายชื่อผู้เล่นสำเร็จ!", Duration = 3 })
    end
})

Tabs.Trade:AddButton({
    Title = "🚀 วาร์ปไปหาผู้เล่นเป้าหมาย",
    Callback = function()
        local targetPlayer = findTargetPlayer(getgenv().SelectedTradePlayer)
        if targetPlayer and targetPlayer.Character then
            local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localHrp and targetHrp then
                localHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
                Fluent:Notify({ Title = "แลกเปลี่ยน", Content = "วาร์ปไปหา " .. targetPlayer.Name, Duration = 3 })
            end
        else
            Fluent:Notify({ Title = "ข้อผิดพลาด", Content = "ไม่พบตัวละครของผู้เล่นเป้าหมาย!", Duration = 3 })
        end
    end
})

local function GetInventoryCardsForTrade()
    local inventory = {}
    local function scanFolder(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Tool") then
                -- แสดงทุก Tool รวม Pack Card ด้วย ไม่ filter
                local displayName = tostring(
                    item:GetAttribute("CardName")
                    or item:GetAttribute("TemplateName")
                    or item.Name
                )
                local rarityAttr = getCardRank(item)
                local mutation = getCardMutation(item)
                local key = displayName .. " | " .. tostring(rarityAttr) .. " | " .. tostring(mutation)
                inventory[key] = (inventory[key] or 0) + 1
            end
        end
    end
    pcall(function()
        scanFolder(LocalPlayer:FindFirstChild("Backpack"))
        if LocalPlayer.Character then scanFolder(LocalPlayer.Character) end
    end)
    local list = {}
    for key, count in pairs(inventory) do
        table.insert(list, key .. " (x" .. tostring(count) .. ")")
    end
    if #list == 0 then table.insert(list, "No cards found") end
    return list
end

local TradeCardsDropdown = Tabs.Trade:AddDropdown("SelectedTradeCards", {
    Title = "🃏 เลือกการ์ดที่จะแลกเปลี่ยน",
    Values = GetInventoryCardsForTrade(),
    Multi = true,
    Default = {}
})
TradeCardsDropdown:OnChanged(function(Value)
    getgenv().SelectedTradeCards = {}
    if type(Value) == "table" then
        for k, v in pairs(Value) do
            if v == true or type(k) == "number" then
                local name = (type(k) == "number") and tostring(v) or tostring(k)
                getgenv().SelectedTradeCards[name] = true
            end
        end
    end
end)

Tabs.Trade:AddButton({
    Title = "🔄 รีเฟรชการ์ดในกระเป๋า",
    Callback = function()
        TradeCardsDropdown:SetValues(GetInventoryCardsForTrade())
        Fluent:Notify({ Title = "แลกเปลี่ยน", Content = "รีเฟรชการ์ดสำเร็จ!", Duration = 3 })
    end
})

local AutoGiftToggle = Tabs.Trade:AddToggle("AutoGiftCards", { Title = "🎁 ส่งการ์ด/เทรดอัตโนมัติ", Default = false })
AutoGiftToggle:OnChanged(function(state)
    getgenv().AutoGiftCards = state
    if state then
        task.spawn(function()
            while getgenv().AutoGiftCards do
                local targetPlayer = findTargetPlayer(getgenv().SelectedTradePlayer)
                if targetPlayer and targetPlayer.Character then
                    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local localChar = LocalPlayer.Character
                    if targetHrp and localChar and localChar:FindFirstChild("Humanoid") then
                        
                        local function getGiftableTool()
                            local function isSelected(t)
                                if not t:IsA("Tool") then return false end
                                -- ถ้าไม่ได้เลือกเฉพาะเจาะจง → ส่งการ์ดทุกอัน
                                if not next(getgenv().SelectedTradeCards) then return true end
                                local displayName = tostring(
                                    t:GetAttribute("CardName")
                                    or t:GetAttribute("TemplateName")
                                    or t.Name
                                )
                                local key = displayName .. " | " .. tostring(getCardRank(t)) .. " | " .. tostring(getCardMutation(t))
                                for selectedText, _ in pairs(getgenv().SelectedTradeCards) do
                                    if selectedText:find(displayName, 1, true) or selectedText:find(key, 1, true) then return true end
                                end
                                return false
                            end

                            local backpack = LocalPlayer:FindFirstChild("Backpack")
                            if backpack then
                                for _, t in ipairs(backpack:GetChildren()) do
                                    if isSelected(t) then return t end
                                end
                            end
                            if localChar then
                                for _, t in ipairs(localChar:GetChildren()) do
                                    if isSelected(t) then return t end
                                end
                            end
                            return nil
                        end

                        local tool = getGiftableTool()
                        if tool then
                            if tool.Parent ~= localChar then
                                localChar.Humanoid:EquipTool(tool)
                                task.wait(0.1)
                            end
                            local localHrp = localChar:FindFirstChild("HumanoidRootPart")
                            if localHrp then localHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0) end
                            task.wait(0.1)

                            -- ค้นหา gift prompt ทั้งบน character และ workspace รอบๆ
                            local function tryFireGiftPrompts()
                                local targetPos = targetHrp.Position
                                local function checkPrompt(desc)
                                    if not desc:IsA("ProximityPrompt") then return end
                                    local action = string.lower(desc.ActionText or "")
                                    local obj = string.lower(desc.ObjectText or "")
                                    local name = string.lower(desc.Name or "")
                                    if action:find("gift") or obj:find("gift") or name:find("gift")
                                        or action:find("ส่ง") or action:find("trade") or action:find("แลก")
                                        or action:find("give") or obj:find("give") then
                                        desc.RequiresLineOfSight = false
                                        desc.MaxActivationDistance = 99999
                                        fireproximityprompt(desc)
                                    end
                                end
                                -- ค้นบน character
                                for _, desc in ipairs(targetPlayer.Character:GetDescendants()) do
                                    checkPrompt(desc)
                                end
                                -- ค้น workspace ในรัศมี 20 studs
                                for _, desc in ipairs(workspace:GetDescendants()) do
                                    if desc:IsA("ProximityPrompt") then
                                        local pPos
                                        pcall(function()
                                            if desc.Parent:IsA("BasePart") then pPos = desc.Parent.Position
                                            elseif desc.Parent:IsA("Attachment") then pPos = desc.Parent.WorldPosition
                                            elseif desc.Parent and desc.Parent.Parent and desc.Parent.Parent:IsA("Model") and desc.Parent.Parent.PrimaryPart then
                                                pPos = desc.Parent.Parent.PrimaryPart.Position
                                            end
                                        end)
                                        if pPos and (pPos - targetPos).Magnitude <= 20 then
                                            checkPrompt(desc)
                                        end
                                    end
                                end
                            end
                            tryFireGiftPrompts()
                            task.wait(0.5)
                        else
                            task.wait(1)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)

local AutoAcceptToggle = Tabs.Trade:AddToggle("AutoAcceptTrade", { Title = "✅ ยอมรับการเทรดอัตโนมัติ", Default = false })
AutoAcceptToggle:OnChanged(function(state)
    getgenv().AutoAcceptTrade = state
    if state then
        task.spawn(function()
            while getgenv().AutoAcceptTrade do
                pcall(function()
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if playerGui then
                        -- [OPT] ค้นหาเฉพาะ TextButton ที่ Visible เท่านั้น ลด scan overhead
                        for _, v in ipairs(playerGui:GetDescendants()) do
                            if v:IsA("TextButton") and v.Visible and v.Text then
                                local text = string.upper(string.match(v.Text or "", "^%s*(.-)%s*$") or "")
                                if text == "ACCEPT" or text == "YES" or text == "รับ" or text == "ยอมรับ" or text == "ตกลง" then
                                    local fired = false
                                    if getconnections then
                                        for _, conn in pairs(getconnections(v.MouseButton1Click)) do conn:Fire() fired = true end
                                        for _, conn in pairs(getconnections(v.Activated)) do conn:Fire() fired = true end
                                    end
                                    if not fired then
                                        local vim = game:GetService("VirtualInputManager")
                                        local center = v.AbsolutePosition + (v.AbsoluteSize / 2)
                                        vim:SendMouseButtonEvent(center.X, center.Y + 36, 0, true, game, 1)
                                        task.wait(0.1)
                                        vim:SendMouseButtonEvent(center.X, center.Y + 36, 0, false, game, 1)
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(1.5)  -- [OPT] เพิ่ม interval จาก 0.5s -> 1.5s ลด scan ใน playerGui
            end
        end)
    end
end)

---------------------------------------------------------
-- 5.5 FPS TAB (ลด FPS)
---------------------------------------------------------
Tabs.FPS:AddSection("⚡ การตั้งค่าประสิทธิภาพ (Performance)")

getgenv().FPSCap = getgenv().FPSCap or "ไม่จำกัด (Max)"
local FPSDropdown = Tabs.FPS:AddDropdown("FPSCapLimit", {
    Title = "⏱️ จำกัดเฟรมเรต (FPS Cap)",
    Description = "เลือกระดับ FPS เพื่อลดการทำงานของการ์ดจอ/ซีพียู",
    Values = {"ไม่จำกัด (Max)", "60 FPS", "30 FPS", "15 FPS", "5 FPS"},
    Multi = false,
    Default = getgenv().FPSCap
})

FPSDropdown:OnChanged(function(Value)
    getgenv().FPSCap = Value
    if setfpscap then
        if Value == "60 FPS" then setfpscap(60)
        elseif Value == "30 FPS" then setfpscap(30)
        elseif Value == "15 FPS" then setfpscap(15)
        elseif Value == "5 FPS" then setfpscap(5)
        else setfpscap(999) end
    end
end)


local AFKToggle = Tabs.FPS:AddToggle("AFKModeWhiteScreen", {
    Title = "📺 โหมดจอขาว (AFK Mode)",
    Description = "ปิดการเรนเดอร์ภาพ 3D และแสดงจอดำ (ประหยัด GPU 99%)",
    Default = false
})

local afkScreenGui = nil
AFKToggle:OnChanged(function(state)
    getgenv().AFKMode = state
    pcall(function()
        if state then
            if not afkScreenGui then
                afkScreenGui = Instance.new("ScreenGui")
                afkScreenGui.Name = "PayomboyZ_AFK"
                afkScreenGui.IgnoreGuiInset = true
                afkScreenGui.ResetOnSpawn = false
                afkScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 1, 0)
                button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                button.Text = "🌙 AFK Mode กำลังทำงาน...\n(ประหยัดพลังงาน GPU)\n\nคลิกที่นี่เพื่อปิดโหมดนี้"
                button.TextColor3 = Color3.fromRGB(200, 200, 200)
                button.Font = Enum.Font.GothamBold
                button.TextSize = 24
                button.Parent = afkScreenGui

                button.MouseButton1Click:Connect(function()
                    if afkScreenGui then afkScreenGui.Parent = nil end
                    pcall(function() RunService:Set3dRenderingEnabled(true) end)
                    getgenv().AFKMode = false
                    if Options and Options.AFKModeWhiteScreen then
                        pcall(function() Options.AFKModeWhiteScreen:SetValue(false) end)
                    end
                end)
            end
            afkScreenGui.Parent = CoreGui
            pcall(function() RunService:Set3dRenderingEnabled(false) end)
        else
            if afkScreenGui then afkScreenGui.Parent = nil end
            pcall(function() RunService:Set3dRenderingEnabled(true) end)
        end
    end)
end)

local originalStates = {}
local PotatoToggle = Tabs.FPS:AddToggle("PotatoGraphics", {
    Title = "🥔 โหมดภาพกาก (Potato Graphics)",
    Description = "ลบพื้นผิวและเงาในเกม (เปิด/ปิด ได้)",
    Default = false
})

PotatoToggle:OnChanged(function(state)
    getgenv().PotatoGraphics = state
    pcall(function()
        local Lighting = game:GetService("Lighting")
        if state then
            Lighting.GlobalShadows = false
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsA("MeshPart") then
                    if originalStates[v] == nil then
                        originalStates[v] = { Material = v.Material, Reflectance = v.Reflectance }
                    end
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    if originalStates[v] == nil then
                        originalStates[v] = { Transparency = v.Transparency }
                    end
                    v.Transparency = 1
                end
            end
            Fluent:Notify({ Title = "ลด FPS", Content = "เปิดโหมดภาพกากเรียบร้อยแล้ว!", Duration = 3 })
        else
            Lighting.GlobalShadows = true
            for obj, data in pairs(originalStates) do
                if obj and obj.Parent then
                    if data.Material then obj.Material = data.Material end
                    if data.Reflectance then obj.Reflectance = data.Reflectance end
                    if data.Transparency then obj.Transparency = data.Transparency end
                end
            end
            originalStates = {}
            Fluent:Notify({ Title = "ลด FPS", Content = "ปิดโหมดภาพกาก (คืนค่าเดิม)", Duration = 3 })
        end
    end)
end)

local visualConn = nil
local DisableEffectsToggle = Tabs.FPS:AddToggle("DisableVisualEffects", {
    Title = "✨ ปิดเอฟเฟกต์ทั้งหมด (Disable Effects)",
    Description = "ปิดการแสดงผล Particle, Beam, Trail ถาวรขณะเปิด",
    Default = false
})

DisableEffectsToggle:OnChanged(function(state)
    getgenv().DisableVisualEffects = state
    if visualConn then visualConn:Disconnect(); visualConn = nil end
    if state then
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
        end)
        visualConn = workspace.DescendantAdded:Connect(function(v)
            if getgenv().DisableVisualEffects then
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
        end)
    end
end)

Tabs.FPS:AddButton({
    Title = "☀️ ฟื้นฟูแสงและสีหน้าจอ (Restore Screen Brightness)",
    Description = "ลบเอฟเฟกต์มืด/เบลอ และคืนค่าความสว่างปกติของเกมทันที",
    Callback = function()
        pcall(function()
            disableScreenDarkening()
            local Lighting = game:GetService("Lighting")
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("ColorCorrectionEffect") then
                    v:Destroy()
                end
            end
            Lighting.GlobalShadows = true
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Fluent:Notify({ Title = "แสงสว่าง", Content = "ฟื้นฟูแสงและสีหน้าจอปกติเรียบร้อยแล้ว!", Duration = 3 })
        end)
    end
})

---------------------------------------------------------
-- 6. DASHBOARD & CONFIG TAB (แดชบอร์ด & ตั้งค่า)
---------------------------------------------------------
Tabs.Dashboard:AddSection("📊 สถานะคลังการ์ด")

local function getCardInventoryText()
    local cards = {}
    local totalCards = 0
    local function scanFolder(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Tool") and not isPackCard(item) then
                local rarity = getCardRank(item)
                local mutation = getCardMutation(item)
                local key = rarity .. " | " .. mutation
                cards[key] = (cards[key] or 0) + 1
                totalCards = totalCards + 1
            end
        end
    end
    pcall(function()
        scanFolder(LocalPlayer:FindFirstChild("Backpack"))
        if LocalPlayer.Character then scanFolder(LocalPlayer.Character) end
    end)
    local lines = { "=== Status Card (Total: " .. totalCards .. " Cards) ===" }
    if totalCards > 0 then
        for key, count in pairs(cards) do table.insert(lines, "  " .. key .. " x" .. tostring(count)) end
    else
        table.insert(lines, "  No Cards in Stock")
    end
    return table.concat(lines, "\n")
end

local function getPackInventoryText()
    local packs = {}
    local totalPacks = 0
    local function scanFolder(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Tool") and isPackCard(item) then
                local rarity = tostring(item:GetAttribute("Rarity") or "Unknown")
                local mutation = tostring(item:GetAttribute("Mutation") or "Normal")
                local key = rarity .. " | " .. mutation
                packs[key] = (packs[key] or 0) + 1
                totalPacks = totalPacks + 1
            end
        end
    end
    pcall(function()
        scanFolder(LocalPlayer:FindFirstChild("Backpack"))
        if LocalPlayer.Character then scanFolder(LocalPlayer.Character) end
    end)
    local lines = { "=== Status Pack Card (Total: " .. totalPacks .. " Packs) ===" }
    if totalPacks > 0 then
        for key, count in pairs(packs) do table.insert(lines, "  " .. key .. " x" .. tostring(count)) end
    else
        table.insert(lines, "  No Pack Cards in Stock")
    end
    return table.concat(lines, "\n")
end

Tabs.Dashboard:AddButton({
    Title = "🃏 แสดงสถานะ Card",
    Callback = function()
        local text = getCardInventoryText()
        if setclipboard then setclipboard(text) end
        Fluent:Notify({ Title = "สถานะ Card", Content = text, Duration = 8 })
    end
})

Tabs.Dashboard:AddButton({
    Title = "📦 แสดงสถานะ Pack Card",
    Callback = function()
        local text = getPackInventoryText()
        if setclipboard then setclipboard(text) end
        Fluent:Notify({ Title = "สถานะ Pack Card", Content = text, Duration = 8 })
    end
})

Tabs.Dashboard:AddSection("🌐 Discord Webhook")

local WebhookInput = Tabs.Dashboard:AddInput("DiscordWebhook", {
    Title = "Discord Webhook URL",
    Default = getgenv().DiscordWebhook or "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Numeric = false,
    Finished = false
})

if getgenv().DiscordWebhook and getgenv().DiscordWebhook ~= "" then
    pcall(function() WebhookInput:SetValue(getgenv().DiscordWebhook) end)
end

WebhookInput:OnChanged(function(text)
    getgenv().DiscordWebhook = text
    getgenv().NotifiedCards = {}
    if writefile and text and text ~= "" then
        pcall(function()
            for _, folderName in ipairs(ConfigFolders) do
                if isfolder and not isfolder(folderName) then pcall(makefolder, folderName) end
                writefile(folderName .. "/Webhook.txt", text)
            end
        end)
    end
end)

---------------------------------------------------------
-- FULLY FIXED & COMPATIBLE CONFIG MANAGER
---------------------------------------------------------
Tabs.Dashboard:AddSection("💾 ระบบจัดการการตั้งค่า (Config System)")

local ConfigNameInputComp = Tabs.Dashboard:AddInput("ConfigNameInput", {
    Title = "ชื่อการตั้งค่าใหม่",
    Default = "",
    Placeholder = "เช่น Default, FarmFast...",
    Numeric = false,
    Finished = false
})

local function GetConfigs()
    local configs = {}
    local seen = {}
    for _, folderName in ipairs(ConfigFolders) do
        if isfolder and isfolder(folderName) and listfiles then
            for _, file in ipairs(listfiles(folderName)) do
                if file:sub(-5) == ".json" and not file:find("_MainConfig.json") then
                    local name = file:match("([^/\\]+)%.json$")
                    if name and not seen[name] then
                        seen[name] = true
                        table.insert(configs, name)
                    end
                end
            end
        end
    end
    if #configs == 0 then table.insert(configs, "ไม่มีการตั้งค่า") end
    return configs
end

local SelectedConfigVar = (ConfigData.Autoload ~= "") and ConfigData.Autoload or "ไม่มีการตั้งค่า"

local ConfigDropdown = Tabs.Dashboard:AddDropdown("SavedConfigsList", {
    Title = "การตั้งค่าที่บันทึกไว้",
    Values = GetConfigs(),
    Multi = false,
    Default = SelectedConfigVar
})
ConfigDropdown:OnChanged(function(val)
    if type(val) == "string" and val ~= "" then
        SelectedConfigVar = val
    end
end)

local function SaveConfig(name)
    local cleanName = string.match(tostring(name or ""), "^%s*(.-)%s*$")
    if cleanName == "" or cleanName == "ไม่มีการตั้งค่า" then
        Fluent:Notify({ Title = "การตั้งค่า", Content = "กรุณาใส่ชื่อการตั้งค่าก่อนบันทึก!", Duration = 3 })
        return
    end
    local data = {
        Rarities = getgenv().SelectedRarities or {},
        Mutations = getgenv().SelectedMutations or {},
        AutoSpawn = getgenv().AutoSpawnPack or false,
        AutoSpawnDelay = getgenv().AutoSpawnDelay or 0.01,
        AutoBuy = getgenv().AutoBuyCards or false,
        AutoCarry = getgenv().AutoCarry or false,
        AutoSellBox = getgenv().AutoSellBox or false,
        AutoCarryDelay = getgenv().AutoCarryDelay or 5,
        AntiAfk = getgenv().AntiAfkState or false,
        AutoUseLuck = getgenv().AutoUseLuck or false,
        AutoUseCash = getgenv().AutoUseCash or false,
        AutoUseMutation = getgenv().AutoUseMutation or false,
        AutoUseProduction = getgenv().AutoUseProduction or false,
        AutoTower = getgenv().AutoTower or false,
        AutoBossRaid = getgenv().AutoBossRaid or false,
        BossRaidDifficulty = getgenv().BossRaidDifficulty or "NIGHTMARE",
        Webhook = getgenv().DiscordWebhook or "",
        RerollSpeed = getgenv().RerollSpeed or 0.05,
        SelectedTraits = getgenv().SelectedTraits or {},
        SelectedRanks = getgenv().SelectedRanks or {},
    }
    if writefile then
        pcall(function()
            for _, folderName in ipairs(ConfigFolders) do
                if isfolder and not isfolder(folderName) then pcall(makefolder, folderName) end
                writefile(folderName .. "/" .. cleanName .. ".json", HttpService:JSONEncode(data))
            end
            Fluent:Notify({ Title = "การตั้งค่า", Content = "บันทึกการตั้งค่าสำเร็จ: " .. cleanName, Duration = 3 })
        end)
        ConfigDropdown:SetValues(GetConfigs())
        pcall(function() ConfigDropdown:SetValue(cleanName) end)
        SelectedConfigVar = cleanName
    end
end

local function LoadConfig(name)
    if not name or name == "" or name == "ไม่มีการตั้งค่า" then return end
    
    local fileContent = nil
    for _, folderName in ipairs(ConfigFolders) do
        local path = folderName .. "/" .. name .. ".json"
        if isfile and isfile(path) then
            pcall(function() fileContent = readfile(path) end)
            if fileContent then break end
        end
    end

    if fileContent then
        local st, data = pcall(function() return HttpService:JSONDecode(fileContent) end)
        if st and type(data) == "table" then
            getgenv().SelectedRarities = data.Rarities or {}
            getgenv().SelectedMutations = data.Mutations or {}
            getgenv().DiscordWebhook = data.Webhook or ""
            getgenv().AutoCarryDelay = data.AutoCarryDelay or 5
            getgenv().RerollSpeed = data.RerollSpeed or 0.05
            getgenv().BossRaidDifficulty = data.BossRaidDifficulty or "NIGHTMARE"
            getgenv().SelectedTraits = data.SelectedTraits or {}
            getgenv().SelectedRanks = data.SelectedRanks or {}

            -- Sync Rarities Multi-Dropdown UI
            local listR = {}
            if type(data.Rarities) == "table" then
                for _, v in ipairs(RaritiesList) do
                    local lowerV = string.lower(v)
                    if data.Rarities[lowerV] == true or data.Rarities[v] == true or (table.find(data.Rarities, v) or table.find(data.Rarities, lowerV)) then
                        table.insert(listR, v)
                        getgenv().SelectedRarities[lowerV] = true
                    end
                end
            end
            if Options and Options.SelectedRarities then pcall(function() Options.SelectedRarities:SetValue(listR) end) end

            -- Sync Mutations Multi-Dropdown UI
            local listM = {}
            if type(data.Mutations) == "table" then
                for _, v in ipairs(MutationsList) do
                    local lowerM = string.lower(v)
                    if data.Mutations[lowerM] == true or data.Mutations[v] == true or (table.find(data.Mutations, v) or table.find(data.Mutations, lowerM)) then
                        table.insert(listM, v)
                        getgenv().SelectedMutations[lowerM] = true
                    end
                end
            end
            if Options and Options.SelectedMutations then pcall(function() Options.SelectedMutations:SetValue(listM) end) end

            -- Sync Traits Multi-Dropdown UI
            local listT = {}
            if type(data.SelectedTraits) == "table" then
                for _, v in ipairs(TraitsList) do
                    local lowerT = string.lower(v)
                    if data.SelectedTraits[lowerT] == true or data.SelectedTraits[v] == true or (table.find(data.SelectedTraits, v) or table.find(data.SelectedTraits, lowerT)) then
                        table.insert(listT, v)
                        getgenv().SelectedTraits[lowerT] = true
                    end
                end
            end
            if Options and Options.SelectedTraits then pcall(function() Options.SelectedTraits:SetValue(listT) end) end

            -- Sync Ranks Multi-Dropdown UI
            local listRank = {}
            if type(data.SelectedRanks) == "table" then
                for _, v in ipairs(RankList) do
                    local lowerR = string.lower(v)
                    if data.SelectedRanks[lowerR] == true or data.SelectedRanks[v] == true or (table.find(data.SelectedRanks, v) or table.find(data.SelectedRanks, lowerR)) then
                        table.insert(listRank, v)
                        getgenv().SelectedRanks[lowerR] = true
                    end
                end
            end
            if Options and Options.SelectedRank then pcall(function() Options.SelectedRank:SetValue(listRank) end) end
            if Options and Options.SelectedRanks then pcall(function() Options.SelectedRanks:SetValue(listRank) end) end

            -- Sync Toggles UI
            local function safeSetToggle(optName, val)
                if Options[optName] then
                    pcall(function() Options[optName]:SetValue(val == true) end)
                end
            end

            safeSetToggle("AutoSpawnPack", data.AutoSpawn)
            safeSetToggle("AutoBuyCards", data.AutoBuy)
            safeSetToggle("AutoCarry", data.AutoCarry)
            safeSetToggle("AutoSellBox", data.AutoSellBox)
            safeSetToggle("AntiAfkState", data.AntiAfk)
            safeSetToggle("AutoUseLuck", data.AutoUseLuck)
            safeSetToggle("AutoUseCash", data.AutoUseCash)
            safeSetToggle("AutoUseMutation", data.AutoUseMutation)
            safeSetToggle("AutoUseProduction", data.AutoUseProduction)
            safeSetToggle("AutoTower", data.AutoTower)
            safeSetToggle("AutoBossRaid", data.AutoBossRaid)

            if Options.AutoSpawnDelay and data.AutoSpawnDelay then pcall(function() Options.AutoSpawnDelay:SetValue(tonumber(data.AutoSpawnDelay)) end) end
            if Options.AutoCarryDelay and data.AutoCarryDelay then pcall(function() Options.AutoCarryDelay:SetValue(tonumber(data.AutoCarryDelay)) end) end
            if Options.RerollSpeed and data.RerollSpeed then pcall(function() Options.RerollSpeed:SetValue(tonumber(data.RerollSpeed)) end) end
            if Options.BossRaidDifficulty and data.BossRaidDifficulty then pcall(function() Options.BossRaidDifficulty:SetValue(tostring(data.BossRaidDifficulty)) end) end
            if Options.DiscordWebhook and data.Webhook then pcall(function() Options.DiscordWebhook:SetValue(tostring(data.Webhook)) end) end

            Fluent:Notify({ Title = "การตั้งค่า", Content = "โหลดการตั้งค่าสำเร็จ: " .. name, Duration = 3 })
        else
            Fluent:Notify({ Title = "การตั้งค่า", Content = "โหลดการตั้งค่าไม่สำเร็จ!", Duration = 3 })
        end
    end
end

Tabs.Dashboard:AddButton({
    Title = "🚀 เปิดหน้าต่างโหมด AFK (ไก่ตัน) [Full Screen]",
    Callback = function()
        if Options and Options.AFKModeToggle then
            Options.AFKModeToggle:SetValue(true)
        else
            afkOpen()
        end
    end
})

Tabs.Dashboard:AddButton({
    Title = "💾 บันทึกการตั้งค่า (Save)",
    Callback = function()
        local name = ConfigNameInputComp.Value
        if not name or name == "" then
            name = Options.ConfigNameInput and Options.ConfigNameInput.Value
        end
        SaveConfig(name)
    end
})

Tabs.Dashboard:AddButton({
    Title = "📂 โหลดการตั้งค่าที่เลือก (Load)",
    Callback = function()
        local selected = SelectedConfigVar
        if not selected or selected == "" or selected == "ไม่มีการตั้งค่า" then
            selected = Options.SavedConfigsList and Options.SavedConfigsList.Value
        end
        LoadConfig(selected)
    end
})

Tabs.Dashboard:AddButton({
    Title = "🔄 รีเฟรชรายการตั้งค่า",
    Callback = function()
        ConfigDropdown:SetValues(GetConfigs())
        Fluent:Notify({ Title = "การตั้งค่า", Content = "รีเฟรชรายการการตั้งค่าแล้ว", Duration = 3 })
    end
})

Tabs.Dashboard:AddButton({
    Title = "🗑️ ลบการตั้งค่าที่เลือก (Delete)",
    Callback = function()
        local selected = SelectedConfigVar
        if not selected or selected == "" or selected == "ไม่มีการตั้งค่า" then
            selected = Options.SavedConfigsList and Options.SavedConfigsList.Value
        end
        if selected and selected ~= "" and selected ~= "ไม่มีการตั้งค่า" then
            for _, folderName in ipairs(ConfigFolders) do
                local filePath = folderName .. "/" .. selected .. ".json"
                if isfile and isfile(filePath) then
                    pcall(delfile, filePath)
                end
            end
            if ConfigData.Autoload == selected then
                ConfigData.Autoload = ""
                SaveMainConfig()
            end
            ConfigDropdown:SetValues(GetConfigs())
            pcall(function() ConfigDropdown:SetValue("ไม่มีการตั้งค่า") end)
            SelectedConfigVar = "ไม่มีการตั้งค่า"
            Fluent:Notify({ Title = "การตั้งค่า", Content = "ลบการตั้งค่าสำเร็จ: " .. selected, Duration = 3 })
        end
    end
})

local AutoLoadToggle = Tabs.Dashboard:AddToggle("AutoLoadConfigToggle", {
    Title = "⚡ โหลดการตั้งค่าอัตโนมัติเมื่อรันสคริปต์ (Auto Load)",
    Default = (ConfigData.Autoload ~= "")
})
AutoLoadToggle:OnChanged(function(state)
    if state then
        local selected = SelectedConfigVar
        if not selected or selected == "" or selected == "ไม่มีการตั้งค่า" then
            selected = Options.SavedConfigsList and Options.SavedConfigsList.Value
        end
        if selected and selected ~= "" and selected ~= "ไม่มีการตั้งค่า" then
            ConfigData.Autoload = selected
            SaveMainConfig()
            Fluent:Notify({ Title = "Auto Load", Content = "ตั้งค่าเป็น Autoload: " .. selected, Duration = 3 })
        else
            Fluent:Notify({ Title = "Auto Load", Content = "กรุณาเลือกการตั้งค่าก่อนเปิด!", Duration = 3 })
            AutoLoadToggle:SetValue(false)
        end
    else
        ConfigData.Autoload = ""
        SaveMainConfig()
        Fluent:Notify({ Title = "Auto Load", Content = "ยกเลิก Auto Load แล้ว", Duration = 3 })
    end
end)

-- Execute Auto Load if configured
if ConfigData.Autoload ~= "" and ConfigData.Autoload ~= "ไม่มีการตั้งค่า" then
    task.spawn(function()
        task.wait(1.2)
        LoadConfig(ConfigData.Autoload)
    end)
end

---------------------------------------------------------
-- UI SCALE & MOBILE POPUP DRAGGABLE BUTTON
---------------------------------------------------------
do
    Tabs.Dashboard:AddSection("📱 การปรับขนาด UI (Mobile Scale)")

    local isMobile = UserInputService.TouchEnabled or not UserInputService.KeyboardEnabled
    local initialScale = isMobile and 0.80 or 1.0
    local currentUIScale = initialScale

    local function setUIScale(scaleVal)
        currentUIScale = scaleVal
        pcall(function()
            local containers = {CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}
            for _, guiParent in ipairs(containers) do
                if guiParent then
                    for _, child in ipairs(guiParent:GetChildren()) do
                        local cname = string.lower(child.Name)
                        if child:IsA("ScreenGui") and (
                            string.find(cname, "fluent") or
                            string.find(cname, "payomboy") or
                            string.find(cname, "dexq") or
                            child.Name == "PayomboyZ_UI"
                        ) then
                            local uiScale = child:FindFirstChildOfClass("UIScale")
                            if not uiScale then
                                uiScale = Instance.new("UIScale")
                                uiScale.Parent = child
                            end
                            uiScale.Scale = currentUIScale
                        end
                    end
                end
            end
        end)
    end

    local UIScaleSlider = Tabs.Dashboard:AddSlider("UIScaleSlider", {
        Title = "🔍 ขนาด UI (UI Scale)",
        Description = "ปรับขนาดเมนูให้พอดีกับหน้าจอมือถือ/แท็บเล็ต",
        Default = initialScale,
        Min = 0.5,
        Max = 1.2,
        Rounding = 2
    })
    UIScaleSlider:OnChanged(function(val)
        setUIScale(val)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == Enum.KeyCode.F then
            local newScale = (currentUIScale == 1.0 and 0.75 or 1.0)
            UIScaleSlider:SetValue(newScale)
            Fluent:Notify({ Title = "UI Scale", Content = "ปรับขนาด UI เป็น: " .. tostring(newScale), Duration = 2 })
        end
    end)

    -- Initial Auto-Scale apply
    task.spawn(function()
        task.wait(0.6)
        setUIScale(initialScale)
    end)

    Fluent:Notify({
        Title = "PayomboyZ",
        Content = "ปรับแต่งหน้าจอสำหรับมือถือสมบูรณ์! ✅\nปรับ UIScale = " .. tostring(initialScale),
        Duration = 6
    })
end

Window:SelectTab(1)

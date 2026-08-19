-- [[ PayomboyZ - Anime Card Farm Script (Obsidian Glassmorphic 2 Engine Edition) ]]
-- Theme: Obsidian Glassmorphic 2 (FlowAuth Aesthetics with Left User Profile Panel)
-- Controls: [K] Toggle UI Visibility | [F] Toggle UI Scale | Mobile Floating Capsule Button

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

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
    gui.ResetOnSpawn = false
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

    -- Snow Particles Animation Effect Layer
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

    -- LEFT COLUMN: SIDEBAR (USER INFO & VERTICAL TAB NAVIGATION)
    local userPanel = Instance.new("Frame")
    userPanel.Name = "UserPanel"
    userPanel.Size = UDim2.new(0, 240, 1, 0)
    userPanel.BackgroundColor3 = COLORS.userPanel
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

    -- Compact Profile Header
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
    avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
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

    -- RIGHT COLUMN: MAIN HUB PANEL
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
    closeBtn.Text = "X"
    closeBtn.TextColor3 = COLORS.textMuted
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = headerBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        shell.Visible = not shell.Visible
    end)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(28, 28)
    minBtn.Position = UDim2.new(1, -72, 0, 10)
    minBtn.BackgroundColor3 = COLORS.glass
    minBtn.Text = "─"
    minBtn.TextColor3 = COLORS.textMuted
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 13
    minBtn.Parent = headerBar

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minBtn

    minBtn.MouseButton1Click:Connect(function()
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
        shell.Visible = not shell.Visible
    end

    function WindowObj:AddTab(tabCfg)
        local tabTitle = tabCfg.Title or "Tab"
        local tabIndex = #WindowObj.Tabs + 1

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -6, 0, 40)
        tabBtn.Position = UDim2.new(0, 3, 0, 0)
        tabBtn.BackgroundColor3 = (tabIndex == 1) and COLORS.primary or Color3.fromRGB(38, 16, 24)
        tabBtn.BackgroundTransparency = (tabIndex == 1) and 0 or 0.1
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
            for _, t in ipairs(WindowObj.Tabs) do
                t.btn.BackgroundColor3 = Color3.fromRGB(38, 16, 24)
                t.btn.BackgroundTransparency = 0.1
                t.btn.TextColor3 = COLORS.textMuted
                t.stroke.Color = Color3.fromRGB(70, 30, 45)
                t.stroke.Transparency = 0.3
                if t.indicator then t.indicator.Visible = false end
                t.page.Visible = false
            end
            tabBtn.BackgroundColor3 = COLORS.primary
            tabBtn.BackgroundTransparency = 0
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

        -- DROPDOWN WIDGET WITH INTERACTIVE POPUP MODAL
        function TabObj:AddDropdown(id, dCfg)
            local title = dCfg.Title or id
            local values = dCfg.Values or {}
            local defaultVal = dCfg.Value or (values[1] or "")
            local isMulti = dCfg.Multi == true

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 52)
            frame.BackgroundColor3 = COLORS.glassDeep
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

            local function formatValText(val)
                if type(val) == "table" then
                    if #val == 0 then return "[ กดเพื่อเลือกรายการ ]" end
                    return table.concat(val, ", ")
                end
                return tostring(val)
            end

            dBtn.Text = formatValText(defaultVal)
            dBtn.TextColor3 = COLORS.cyan
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
            end

            function OptionObj:SetValue(val)
                updateDropdown(val)
            end

            function OptionObj:SetValues(newVals)
                OptionObj.Values = newVals
            end

            -- POPUP OVERLAY MODAL FOR SELECTION
            dBtn.MouseButton1Click:Connect(function()
                if #OptionObj.Values == 0 then return end

                local gui = shell.Parent
                if not gui then return end

                local existingModal = gui:FindFirstChild("DropdownModalOverlay")
                if existingModal then existingModal:Destroy() end

                local modalOverlay = Instance.new("Frame")
                modalOverlay.Name = "DropdownModalOverlay"
                modalOverlay.Size = UDim2.fromScale(1, 1)
                modalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                modalOverlay.BackgroundTransparency = 0.55
                modalOverlay.ZIndex = 9999
                modalOverlay.Parent = gui

                local bgDismissBtn = Instance.new("TextButton")
                bgDismissBtn.Size = UDim2.fromScale(1, 1)
                bgDismissBtn.BackgroundTransparency = 1
                bgDismissBtn.Text = ""
                bgDismissBtn.ZIndex = 9999
                bgDismissBtn.Parent = modalOverlay

                local modalFrame = Instance.new("Frame")
                modalFrame.Size = UDim2.fromOffset(380, 440)
                modalFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                modalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                modalFrame.BackgroundColor3 = COLORS.shell
                modalFrame.BorderSizePixel = 0
                modalFrame.ZIndex = 10000
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
                mHeader.Size = UDim2.new(1, -50, 0, 24)
                mHeader.Position = UDim2.new(0, 16, 0, 14)
                mHeader.BackgroundTransparency = 1
                mHeader.Text = "📌 " .. title
                mHeader.TextColor3 = COLORS.text
                mHeader.Font = Enum.Font.GothamBold
                mHeader.TextSize = 15
                mHeader.TextXAlignment = Enum.TextXAlignment.Left
                mHeader.ZIndex = 10001
                mHeader.Parent = modalFrame

                local mSub = Instance.new("TextLabel")
                mSub.Size = UDim2.new(1, -50, 0, 18)
                mSub.Position = UDim2.new(0, 16, 0, 38)
                mSub.BackgroundTransparency = 1
                mSub.Text = isMulti and "คำแนะนำ: คลิกเลือก/ยกเลิกได้หลายตัวเลือก" or "คำแนะนำ: คลิก 1 รายการเพื่อเลือก"
                mSub.TextColor3 = COLORS.textMuted
                mSub.Font = Enum.Font.Gotham
                mSub.TextSize = 11
                mSub.TextXAlignment = Enum.TextXAlignment.Left
                mSub.ZIndex = 10001
                mSub.Parent = modalFrame

                local closeBtn = Instance.new("TextButton")
                closeBtn.Size = UDim2.fromOffset(30, 30)
                closeBtn.Position = UDim2.new(1, -40, 0, 12)
                closeBtn.BackgroundColor3 = COLORS.surface
                closeBtn.Text = "X"
                closeBtn.TextColor3 = COLORS.text
                closeBtn.Font = Enum.Font.GothamBold
                closeBtn.TextSize = 14
                closeBtn.ZIndex = 10001
                closeBtn.Parent = modalFrame

                local cbCorner = Instance.new("UICorner")
                cbCorner.CornerRadius = UDim.new(0, 6)
                cbCorner.Parent = closeBtn

                closeBtn.MouseButton1Click:Connect(function()
                    modalOverlay:Destroy()
                end)

                bgDismissBtn.MouseButton1Click:Connect(function()
                    modalOverlay:Destroy()
                end)

                -- Option list
                local optScroll = Instance.new("ScrollingFrame")
                optScroll.Size = UDim2.new(1, -28, 1, -124)
                optScroll.Position = UDim2.new(0, 14, 0, 64)
                optScroll.BackgroundTransparency = 1
                optScroll.ScrollBarThickness = 4
                optScroll.ScrollBarImageColor3 = COLORS.primary
                optScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                optScroll.ZIndex = 10001
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

                    for _, optVal in ipairs(OptionObj.Values) do
                        local isSelected = false
                        if isMulti then
                            isSelected = table.find(currentSelected, optVal) ~= nil
                        else
                            isSelected = (currentSelected[1] == optVal)
                        end

                        local itemBtn = Instance.new("TextButton")
                        itemBtn.Size = UDim2.new(1, -6, 0, 38)
                        itemBtn.BackgroundColor3 = isSelected and COLORS.primary or COLORS.glassDeep
                        itemBtn.Text = (isSelected and "   ✓  " or "       ") .. tostring(optVal)
                        itemBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or COLORS.text
                        itemBtn.Font = Enum.Font.GothamBold
                        itemBtn.TextSize = 13
                        itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                        itemBtn.ZIndex = 10002
                        itemBtn.Parent = optScroll

                        local ibCorner = Instance.new("UICorner")
                        ibCorner.CornerRadius = UDim.new(0, 8)
                        ibCorner.Parent = itemBtn

                        local ibStroke = Instance.new("UIStroke")
                        ibStroke.Color = isSelected and COLORS.primary or COLORS.surfaceRaised
                        ibStroke.Thickness = 1
                        ibStroke.Parent = itemBtn

                        itemBtn.MouseButton1Click:Connect(function()
                            if isMulti then
                                local foundIdx = table.find(currentSelected, optVal)
                                if foundIdx then
                                    table.remove(currentSelected, foundIdx)
                                else
                                    table.insert(currentSelected, optVal)
                                end
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

                -- Confirm / Done Button
                local confirmBtn = Instance.new("TextButton")
                confirmBtn.Size = UDim2.new(1, -28, 0, 40)
                confirmBtn.Position = UDim2.new(0, 14, 1, -50)
                confirmBtn.BackgroundColor3 = COLORS.primary
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
                    if isMulti then
                        updateDropdown(currentSelected)
                    end
                    modalOverlay:Destroy()
                end)
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
    "Smash", "Emblem", "Chrono", "Limited"
}

local MutationsList = {
    "Normal", "Golden", "Diamond", "Venomous", "Rainbow", "Sakura", "Candy",
    "Blessed", "Radioactive", "Glitch", "Starfallen", "Admin", "Unknow", "Event"
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

    local inventoryText = "Unknown"
    pcall(function() inventoryText = GetAllInventorySummary() end)

    local data = {
        ["content"] = "",
        ["embeds"] = {
            {
                ["title"] = "🎉 Card Bought (PayomboyZ)!",
                ["description"] = "Successfully bought a card matching your criteria.",
                ["type"] = "rich",
                ["color"] = 13382451,
                ["fields"] = {
                    { ["name"] = "Rarity", ["value"] = tostring(rarity), ["inline"] = true },
                    { ["name"] = "Mutation", ["value"] = tostring(mutation), ["inline"] = true },
                    { ["name"] = "Full Inventory", ["value"] = inventoryText, ["inline"] = false },
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

---------------------------------------------------------
-- 1. MAIN TAB (หลัก)
---------------------------------------------------------
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
                if getgenv().AutoBuyCards then
                    if activeCards == 0 then
                        pcall(fireclickdetector, cd)
                        task.wait(0.3)
                    else
                        task.wait(0.05)
                    end
                else
                    pcall(fireclickdetector, cd)
                    if activeCards >= 3 then
                        task.wait(0.2)
                    else
                        task.wait(0.01)
                    end
                end
            end
        end)
    end
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

local function getCardModelRarityAndMutation(model)
    if not model then return "", "Normal" end

    local rarity = model:GetAttribute("Rarity") 
        or model:GetAttribute("CardGrade") 
        or model:GetAttribute("Grade") 
        or model:GetAttribute("CardRarity")
        or model:GetAttribute("PackRarity")
        or model:GetAttribute("BoxRarity")
        or model:GetAttribute("PackName")
        or model:GetAttribute("TemplateName")
    local mutation = model:GetAttribute("Mutation") or model:GetAttribute("CardMutation")

    rarity = rarity and tostring(rarity) or ""
    mutation = mutation and tostring(mutation) or "Normal"

    if rarity == "" or rarity == "nil" then
        for _, childName in ipairs({"Rarity", "CardGrade", "Grade", "CardRarity", "RarityLabel", "PackRarity", "PackName", "TemplateName"}) do
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
                for _, rName in ipairs({"common", "uncommon", "rare", "epic", "legendary", "mythical", "secret", "godly", "admin", "grail", "blaze", "conquest", "devour", "unknown", "unknow"}) do
                    if cl:find(rName) then
                        rarity = rName
                        break
                    end
                end
                if rarity ~= "" then break end
            end
        end
    end

    if rarity == "" or rarity == "nil" then
        local mName = string.lower(model.Name)
        if mName:find("unknown") then
            rarity = "Unknown"
        elseif mName:find("unknow") then
            rarity = "Unknow"
        end
    end

    return rarity, mutation
end

-- Heartbeat Instant Buy Loop
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
        if buyAttempts >= 25 or (tick() - firstSeen > 20) then
            model:SetAttribute("Rejected", true)
            continue
        end

        local cardRarity, cardMutation = getCardModelRarityAndMutation(model)
        local rLower = string.lower(tostring(cardRarity))
        local mLower = string.lower(tostring(cardMutation))

        local matchRarity = (next(getgenv().SelectedRarities) == nil)
        if not matchRarity and rLower ~= "" then
            if getgenv().SelectedRarities[rLower] == true then
                matchRarity = true
            elseif (rLower:find("unknown") or rLower:find("unknow")) and (getgenv().SelectedRarities["unknown"] == true or getgenv().SelectedRarities["unknow"] == true) then
                matchRarity = true
            end
        end

        local matchMutation = (next(getgenv().SelectedMutations) == nil)
        if not matchMutation and mLower ~= "" then
            if getgenv().SelectedMutations[mLower] == true then
                matchMutation = true
            elseif (mLower:find("unknown") or mLower:find("unknow")) and (getgenv().SelectedMutations["unknown"] == true or getgenv().SelectedMutations["unknow"] == true) then
                matchMutation = true
            end
        end

        if isPackCard(model) then
            if getgenv().SelectedRarities["unknown"] or getgenv().SelectedRarities["unknow"] or getgenv().SelectedMutations["unknown"] or getgenv().SelectedMutations["unknow"] then
                if rLower:find("unknown") or rLower:find("unknow") or mLower:find("unknown") or mLower:find("unknow") or string.lower(model.Name):find("pack") or string.lower(model.Name):find("box") then
                    matchRarity = true
                    matchMutation = true
                end
            end
        end

        if next(getgenv().SelectedRarities) == nil and next(getgenv().SelectedMutations) == nil then
            matchRarity = true
            matchMutation = true
        end

        if matchRarity and matchMutation then
            local now = tick()
            if not getgenv().PromptCooldowns[prompt] or now - getgenv().PromptCooldowns[prompt] > 0.1 then
                getgenv().PromptCooldowns[prompt] = now
                model:SetAttribute("BuyAttempts", buyAttempts + 1)
                pcall(function()
                    prompt.RequiresLineOfSight = false
                    prompt.MaxActivationDistance = 99999
                    fireproximityprompt(prompt)
                end)
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
            model:SetAttribute("Rejected", true)
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

local antiAfkConnection
local AntiAfkToggle = Tabs.Main:AddToggle("AntiAfkState", { Title = "🛡️ ป้องกันหลุด (Anti AFK)", Default = false })
AntiAfkToggle:OnChanged(function(state)
    getgenv().AntiAfkState = state
    if state then
        antiAfkConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
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

local function GetInventoryCardsForReroll()
    local inventory = {}
    local function scanFolder(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Tool") and not isPackCard(item) and (item:GetAttribute("CardName") or item:GetAttribute("TemplateName") or string.find(item.Name, "Card")) then
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

getgenv().SelectedRerollCardKey = nil
local RerollCardsDropdown = Tabs.Reroll:AddDropdown("SelectedRerollCard", {
    Title = "เลือกการ์ดที่ต้องการรีโรล Trait",
    Values = GetInventoryCardsForReroll(),
    Multi = false,
    Default = "No cards found"
})
RerollCardsDropdown:OnChanged(function(Value)
    getgenv().SelectedRerollCardKey = Value
end)

Tabs.Reroll:AddButton({
    Title = "🔄 รีเฟรชรายการการ์ด (Trait)",
    Callback = function()
        RerollCardsDropdown:SetValues(GetInventoryCardsForReroll())
        Fluent:Notify({ Title = "Reroll", Content = "รีเฟรชรายการการ์ดแล้ว!", Duration = 3 })
    end
})

getgenv().AutoReroll = false
local AutoRerollToggle = Tabs.Reroll:AddToggle("AutoRerollTrait", { Title = "🔥 รีโรล Trait อัตโนมัติ", Default = false })
AutoRerollToggle:OnChanged(function(state)
    getgenv().AutoReroll = state
    if state then
        task.spawn(function()
            getgenv().NotifiedRerollStart = nil
            while getgenv().AutoReroll do
                if getgenv().PauseReroll then
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid:UnequipTools()
                        end
                    end)
                    task.wait(1)
                    continue
                end
                local cardKey = getgenv().SelectedRerollCardKey
                local cardTool = getgenv().RerollInventoryMap and getgenv().RerollInventoryMap[cardKey]
                
                if cardTool and cardTool.Parent then
                    local currentTrait = getCardTrait(cardTool)
                    
                    local hasSelected = false
                    for trait, _ in pairs(getgenv().SelectedTraits) do
                        if string.find(string.lower(currentTrait), string.lower(trait)) then
                            hasSelected = true
                            break
                        end
                    end
                    
                    if hasSelected then
                        Fluent:Notify({ Title = "Auto Reroll", Content = "ได้รับ Trait ที่ต้องการแล้ว: " .. currentTrait, Duration = 5 })
                        getgenv().AutoReroll = false
                        if Options and Options.AutoRerollTrait then Options.AutoRerollTrait:SetValue(false) end
                        break
                    end
                    
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") and cardTool.Parent ~= char then
                            char.Humanoid:EquipTool(cardTool)
                            task.wait(0.2)
                        end
                    end)

                    local cId = cardTool:GetAttribute("UUID") or cardTool:GetAttribute("Id") or cardTool:GetAttribute("CardId") or cardTool.Name
                    
                    if not getgenv().NotifiedRerollStart then
                        Fluent:Notify({ Title = "Auto Reroll", Content = "เริ่มการรีโรล...", Duration = 3 })
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
                    
                    local function fireAll(id)
                        local argsToTry = {
                            id, cardTool, { Card = id }, { UUID = id }, { Tool = cardTool }
                        }
                        local rs = game:GetService("ReplicatedStorage")
                        for _, obj in ipairs(rs:GetDescendants()) do
                            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                                local name = string.lower(obj.Name)
                                if string.find(name, "roll") or string.find(name, "trait") then
                                    if obj:IsA("RemoteEvent") then
                                        for _, arg in ipairs(argsToTry) do
                                            pcall(function() obj:FireServer(arg) end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    fireAll(cId)
                    
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
                else
                    Fluent:Notify({ Title = "Auto Reroll", Content = "ไม่พบการ์ด! กรุณาเลือกใหม่", Duration = 3 })
                    getgenv().AutoReroll = false
                    if Options and Options.AutoRerollTrait then Options.AutoRerollTrait:SetValue(false) end
                end
                
                task.wait(getgenv().RerollSpeed or 1.5)
            end
        end)
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

getgenv().SelectedRankCardKey = nil
local RankCardsDropdown = Tabs.Reroll:AddDropdown("SelectedRankCard", {
    Title = "เลือกการ์ดที่ต้องการรีโรล Rank",
    Values = GetInventoryCardsForReroll(),
    Multi = false,
    Default = "No cards found"
})
RankCardsDropdown:OnChanged(function(Value)
    getgenv().SelectedRankCardKey = Value
end)

Tabs.Reroll:AddButton({
    Title = "🔄 รีเฟรชรายการการ์ด (Rank)",
    Callback = function()
        RankCardsDropdown:SetValues(GetInventoryCardsForReroll())
        Fluent:Notify({ Title = "Auto Rank", Content = "รีเฟรชรายการการ์ดแล้ว!", Duration = 3 })
    end
})

getgenv().AutoRankReroll = false
local AutoRankRerollToggle = Tabs.Reroll:AddToggle("AutoRerollRank", { Title = "💥 รีโรล Rank อัตโนมัติ", Default = false })
AutoRankRerollToggle:OnChanged(function(state)
    getgenv().AutoRankReroll = state
    if state then
        task.spawn(function()
            getgenv().NotifiedRankRerollStart = nil
            while getgenv().AutoRankReroll do
                if getgenv().PauseReroll then
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid:UnequipTools()
                        end
                    end)
                    task.wait(1)
                    continue
                end
                local cardKey = getgenv().SelectedRankCardKey
                local cardTool = getgenv().RerollInventoryMap and getgenv().RerollInventoryMap[cardKey]
                
                if cardTool and cardTool.Parent then
                    local currentRank = getCardRank(cardTool)
                    
                    local hasSelected = false
                    for rank, _ in pairs(getgenv().SelectedRanks) do
                        if string.lower(currentRank) == string.lower(rank) then
                            hasSelected = true
                            break
                        end
                    end
                    
                    if hasSelected then
                        Fluent:Notify({ Title = "Auto Rank", Content = "ได้รับ Rank ที่ต้องการแล้ว: " .. currentRank, Duration = 5 })
                        getgenv().AutoRankReroll = false
                        if Options and Options.AutoRerollRank then Options.AutoRerollRank:SetValue(false) end
                        break
                    end
                    
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") and cardTool.Parent ~= char then
                            char.Humanoid:EquipTool(cardTool)
                            task.wait(0.2)
                        end
                    end)

                    local cId = cardTool:GetAttribute("UUID") or cardTool:GetAttribute("Id") or cardTool:GetAttribute("CardId") or cardTool.Name
                    
                    if not getgenv().NotifiedRankRerollStart then
                        Fluent:Notify({ Title = "Auto Rank", Content = "เริ่มการรีโรล Rank...", Duration = 3 })
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
                    
                    local function fireAll(id)
                        local argsToTry = {
                            id, cardTool, { Card = id }, { UUID = id }, { Tool = cardTool }
                        }
                        local keywords = {"rank", "ranking", "upgrade", "stat", "boost", "cashboost", "cardroll", "rollcard", "rerollcard"}
                        local rs = game:GetService("ReplicatedStorage")
                        for _, obj in ipairs(rs:GetDescendants()) do
                            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                                local name = string.lower(obj.Name)
                                local match = false
                                for _, kw in ipairs(keywords) do
                                    if string.find(name, kw) then
                                        match = true
                                        break
                                    end
                                end
                                if match then
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
                        end
                    end
                    fireAll(cId)
                else
                    Fluent:Notify({ Title = "Auto Rank", Content = "ไม่พบการ์ด! กรุณาเลือกใหม่", Duration = 3 })
                    getgenv().AutoRankReroll = false
                    if Options and Options.AutoRerollRank then Options.AutoRerollRank:SetValue(false) end
                end
                
                task.wait(getgenv().RerollSpeed or 1.5)
            end
        end)
    end
end)

local RerollSpeedSlider = Tabs.Reroll:AddSlider("RerollSpeed", {
    Title = "⚡ ความเร็วในการรีโรล (วินาที)",
    Default = 1.5,
    Min = 0.1,
    Max = 3.0,
    Rounding = 1
})
RerollSpeedSlider:OnChanged(function(val)
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

local function getRarityScore(rarityText)
    if not rarityText then return 0 end
    local clean = string.lower(string.gsub(rarityText, "<[^>]+>", ""))
    for k, score in pairs(RarityTiers) do
        if string.find(clean, k) then return score end
    end
    return 0
end

---------------------------------------------------------
-- 3.5 MANAGE TAB (ระบบจัดการ)
---------------------------------------------------------
local function getUnifiedCardScore(item)
    if not item then return 0 end
    local cashScore, rarityScore, mutationScore = 0, 0, 0
    for _, txtObj in ipairs(item:GetDescendants()) do
        if txtObj:IsA("TextLabel") or txtObj:IsA("TextButton") then
            local val = parseSuffixValue(txtObj.Text)
            if val > cashScore then cashScore = val end
            local s = getRarityScore(txtObj.Text)
            if s > rarityScore then rarityScore = s end
            
            local cleanMut = string.lower(string.gsub(txtObj.Text or "", "<[^>]+>", ""))
            cleanMut = string.match(cleanMut, "^%s*(.-)%s*$") or ""
            local MutationScores = {
                ["unknow"] = 130, ["admin"] = 120, ["starfallen"] = 110, ["glitch"] = 100,
                ["radioactive"] = 90, ["blessed"] = 80, ["candy"] = 70, ["sakura"] = 60,
                ["rainbow"] = 50, ["venomous"] = 40, ["diamond"] = 30, ["golden"] = 20,
            }
            for mName, mScore in pairs(MutationScores) do
                if string.find(cleanMut, mName) and mScore > mutationScore then
                    mutationScore = mScore
                end
            end
        end
    end
    if cashScore == 0 and rarityScore == 0 then
        local lvl = item:GetAttribute("Level") or item:GetAttribute("CardLevel") or 0
        if tonumber(lvl) then cashScore = tonumber(lvl) end
        if cashScore == 0 then
            local val = item:GetAttribute("CashMultiplier") or item:GetAttribute("Multiplier")
            if tonumber(val) then cashScore = tonumber(val) end
        end
        if cashScore == 0 and rarityScore == 0 and getCardRank then
            local rName = getCardRank(item)
            rarityScore = getRarityScore(rName)
        end
    end
    return cashScore + (rarityScore * 1000) + (mutationScore * 100)
end

getgenv().AutoClaimRewards = false
local AutoClaimToggle = Tabs.Manage:AddToggle("AutoClaimState", { Title = "🎁 กดรับรางวัลอัตโนมัติ (Playtime/Daily)", Default = false })
AutoClaimToggle:OnChanged(function(state)
    getgenv().AutoClaimRewards = state
    if state then
        task.spawn(function()
            while getgenv().AutoClaimRewards do
                pcall(function()
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if playerGui then
                        for _, v in ipairs(playerGui:GetDescendants()) do
                            if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                                local btnText = ""
                                if v:IsA("TextButton") then
                                    btnText = string.upper(string.match(v.Text or "", "^%s*(.-)%s*$") or "")
                                else
                                    local txtLabel = v:FindFirstChildWhichIsA("TextLabel")
                                    if txtLabel then btnText = string.upper(string.match(txtLabel.Text or "", "^%s*(.-)%s*$") or "") end
                                end
                                
                                local name = string.upper(v.Name)
                                if (btnText:find("CLAIM") or btnText:find("COLLECT") or btnText:find("รับ") or name:find("CLAIM") or name:find("COLLECT")) then
                                    local isForbidden = false
                                    local current = v
                                    while current and (current:IsA("GuiObject") or current:IsA("ScreenGui")) do
                                        local cName = string.upper(current.Name)
                                        if cName:find("GUILD") or cName:find("กิลด์") or cName:find("CLAN") 
                                            or cName:find("ROBUX") or cName:find("PASS") or cName:find("SHOP") 
                                            or cName:find("REBIRTH") or cName:find("TRADE") or cName:find("GIFT")
                                        then
                                            isForbidden = true
                                            break
                                        end
                                        current = current.Parent
                                    end

                                    if not isForbidden and not name:find("ROBUX") and not btnText:find("ROBUX") and not btnText:find("R$") then
                                        fireButton(v)
                                        task.wait(0.2)
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(30)
            end
        end)
    end
end)

Tabs.Manage:AddSection("🗑️ จัดการกระเป๋า (Inventory Balancing)")
local InvBalToggle = Tabs.Manage:AddToggle("InvBalState", { Title = "เคลียร์ขยะอัตโนมัติเมื่อกระเป๋าเต็ม", Default = false })
local MinRarityDrop = Tabs.Manage:AddDropdown("MinRarityKeep", {
    Title = "ระดับขั้นต่ำที่ต้องการเก็บไว้",
    Values = RaritiesList,
    Multi = false,
    Default = "Rare"
})
local MinRarityIdx = {}
for i, v in ipairs(RaritiesList) do MinRarityIdx[v] = i end

InvBalToggle:OnChanged(function(state)
    getgenv().InventoryBalancing = state
    if state then
        task.spawn(function()
            while getgenv().InventoryBalancing do
                pcall(function()
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    local char = LocalPlayer.Character
                    local items = {}
                    if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then table.insert(items, t) end end end
                    if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(items, t) end end end
                    
                    if #items > 0 then
                        local threshold = MinRarityIdx[MinRarityDrop.Value or "Rare"] or 3
                        local trashCards = {}
                        
                        for _, t in ipairs(items) do
                            local isPack = isPackCard(t)
                            local rank = getCardRank(t)
                            local rankIdx = MinRarityIdx[rank] or 99
                            
                            if isPack and rankIdx == 99 then
                                local upName = string.upper(t.Name)
                                for r, idx in pairs(MinRarityIdx) do
                                    if string.find(upName, string.upper(r)) then
                                        rankIdx = idx
                                        break
                                    end
                                end
                            end
                            
                            if not isPack then
                                local mut = string.lower(getCardMutation(t))
                                if mut ~= "normal" and mut ~= "golden" then continue end
                                if rank:find("SS") or rank:find("UR") or rank:find("LR") then rankIdx = 99 end
                            end
                            
                            local cashScore = 0
                            pcall(function()
                                for _, desc in ipairs(t:GetDescendants()) do
                                    if desc:IsA("TextLabel") and desc.Text then
                                        local txt = string.upper(desc.Text)
                                        local nStr, suf = string.match(txt, "([%d%.]+)%s*([A-Z]+)")
                                        if nStr and suf then
                                            local mult = 0
                                            if suf == "DD" then mult = 1e39
                                            elseif suf == "UD" then mult = 1e36
                                            elseif suf == "DC" then mult = 1e33
                                            elseif suf == "NO" or suf == "N" then mult = 1e30
                                            elseif suf == "OC" or suf == "O" then mult = 1e27
                                            end
                                            local v = (tonumber(nStr) or 0) * mult
                                            if v > cashScore then cashScore = v end
                                        end
                                    end
                                end
                            end)
                            if cashScore >= 1e27 then continue end
                            
                            if rankIdx < threshold then
                                table.insert(trashCards, t)
                            end
                        end
                        
                        if #trashCards > 0 and char and char:FindFirstChild("Humanoid") then
                            for _, t in ipairs(trashCards) do
                                pcall(function()
                                    char.Humanoid:EquipTool(t)
                                    task.wait(0.2)
                                    local rem = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                                    if rem and rem:FindFirstChild("SellRE") then
                                        rem.SellRE:FireServer("SellHand")
                                    end
                                    task.wait(0.2)
                                    if t and t.Parent then t:Destroy() end
                                end)
                            end
                        end
                    end
                end)
                task.wait(10)
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
    local clean = string.lower(string.gsub(rarityText, "<[^>]+>", ""))
    for k, score in pairs(RarityTiers) do
        if string.find(clean, k) then return score end
    end
    return 0
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
        for _, desc in ipairs(plotFolder:GetDescendants()) do
            if desc:IsA("ProximityPrompt") or desc:IsA("ClickDetector") then
                local pText = desc:IsA("ProximityPrompt") and string.upper((desc.ActionText or "") .. " " .. (desc.ObjectText or "")) or ""
                
                local isIgnoredPrompt = string.find(pText, "BUY") or string.find(pText, "ซื้อ")
                    or string.find(pText, "SPAWN") or string.find(pText, "สุ่ม")
                    or string.find(pText, "OPEN") or string.find(pText, "เปิด")
                    or string.find(pText, "TOWER") or string.find(pText, "ทาวเวอร์")
                    or string.find(pText, "UPGRADE") or string.find(pText, "อัปเกรด")
                    or string.find(pText, "CLAIM") or string.find(pText, "รับ")
                    or string.find(pText, "SELL") or string.find(pText, "ขาย")
                    or string.find(pText, "REBIRTH") or string.find(pText, "จุติ")
                    or string.find(pText, "JOIN") or string.find(pText, "ENTER")
                
                if not isIgnoredPrompt then
                    local model = desc:FindFirstAncestorOfClass("Model")
                    if model and model.Name ~= "SellPart" and not model:FindFirstChildOfClass("Humanoid") then
                        local isPack = isPackCard(model)
                        if not isPack then
                            for _, txtObj in ipairs(model:GetDescendants()) do
                                if (txtObj:IsA("TextLabel") or txtObj:IsA("TextButton")) and txtObj.Text then
                                    local txtUpper = string.upper(txtObj.Text or "")
                                    if string.find(txtUpper, "PACK") or string.find(txtUpper, "แพ็ค") or string.find(txtUpper, "BOX") or string.find(txtUpper, "กล่อง") then
                                        isPack = true
                                        break
                                    end
                                end
                            end
                        end
                        if isPack then continue end
                        
                        local cashScore, rarityScore, mutationScore = 0, 0, 0
                        for _, txtObj in ipairs(model:GetDescendants()) do
                            if txtObj:IsA("TextLabel") or txtObj:IsA("TextButton") then
                                local val = parseSuffixValue(txtObj.Text)
                                if val > cashScore then cashScore = val end
                                local s = getRarityScore(txtObj.Text)
                                if s > rarityScore then rarityScore = s end
                                
                                local cleanMut = string.lower(string.gsub(txtObj.Text or "", "<[^>]+>", ""))
                                cleanMut = string.match(cleanMut, "^%s*(.-)%s*$") or ""
                                local MutationScores = {
                                    ["unknow"] = 130, ["admin"] = 120, ["starfallen"] = 110, ["glitch"] = 100,
                                    ["radioactive"] = 90, ["blessed"] = 80, ["candy"] = 70, ["sakura"] = 60,
                                    ["rainbow"] = 50, ["venomous"] = 40, ["diamond"] = 30, ["golden"] = 20,
                                }
                                for mName, mScore in pairs(MutationScores) do
                                    if string.find(cleanMut, mName) and mScore > mutationScore then
                                        mutationScore = mScore
                                    end
                                end
                            end
                        end
                        
                        if cashScore == 0 and rarityScore == 0 then
                            local lvl = model:GetAttribute("Level") or model:GetAttribute("CardLevel") or 0
                            if tonumber(lvl) then cashScore = tonumber(lvl) end
                            if cashScore == 0 then
                                local val = model:GetAttribute("CashMultiplier") or model:GetAttribute("Multiplier")
                                if tonumber(val) then cashScore = tonumber(val) end
                            end
                        end

                        local totalScore = cashScore + (rarityScore * 1000) + (mutationScore * 100)
                        if totalScore > 0 and not string.find(string.upper(model.Name or ""), "PLOT") then
                            table.insert(cardList, { interact = desc, score = totalScore, model = model })
                        end
                    end
                end
            end
        end

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
                        task.wait(0.8)
                        
                        if item.interact:IsA("ProximityPrompt") then
                            item.interact.RequiresLineOfSight = false
                            item.interact.MaxActivationDistance = 99999
                            item.interact.HoldDuration = 0
                            for _ = 1, 5 do
                                if not item.interact or not item.interact.Parent then break end
                                fireproximityprompt(item.interact)
                                task.wait(0.3)
                            end
                        elseif item.interact:IsA("ClickDetector") then
                            for _ = 1, 5 do
                                fireclickdetector(item.interact)
                                task.wait(0.3)
                            end
                        end
                        task.wait(1.0)
                    end
                end)
            end
        end

        if originalCFrame and hrp then
            hrp.CFrame = originalCFrame
            task.wait(0.5)
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
                    task.wait(1.0)
                else
                    return
                end

                hrp.CFrame = CFrame.new(pos) + Vector3.new(0, 2, 0)
                task.wait(0.8)

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
                                    for _ = 1, 5 do fireproximityprompt(desc) task.wait(0.3) end
                                elseif desc:IsA("ClickDetector") then
                                    for _ = 1, 4 do fireclickdetector(desc) task.wait(0.3) end
                                end
                                break
                            end
                        end
                    end
                end
                task.wait(1.7)
            end)
        end

        getgenv().CollectedCardPositions = nil
        if LocalPlayer.Character and startCF then
            LocalPlayer.Character:PivotTo(startCF)
            task.wait(0.5)
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

-- Unified Background Orchestrator Loop for Tower & Boss Raid
local isRaidTowerLoopRunning = false
local function startRaidTowerManagerLoop()
    if isRaidTowerLoopRunning then return end
    isRaidTowerLoopRunning = true

    task.spawn(function()
        while getgenv().AutoTower or getgenv().AutoBossRaid do
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local isBossTime = isBossTimeWindow()
            local bossAlreadyDone = hasFoughtBossThisHour()
            local shouldDoBoss = getgenv().AutoBossRaid and isBossTime and not bossAlreadyDone

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
                    -- 1. Execute Boss Raid Logic (Or transition out of Tower if currently inside)
                    local equipBtn, battleBtn, diffBtn, autoReplayBtn, showBattleBtn, hideBattleBtn, nextBtn, playBtn
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
                        Fluent:Notify({ Title = "บอสเรด", Content = "คุณสู้บอสไปแล้วในชั่วโมงนี้! สลับกลับไปทำระบบอื่น", Duration = 4 })
                    else
                        -- If we are in Tower, exit tower first to enter Boss Raid
                        if getgenv().AutoReplayToggled and not (diffBtn or battleBtn) then
                            exitTowerNow()
                            task.wait(1.5)
                        end

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
                            fireButton(battleBtn)
                            getgenv().BossFoughtHourKey = getCurrentHourKey()
                            task.wait(0.2)
                            local character = LocalPlayer.Character
                            if getgenv().BossOriginalCFrame and character then
                                character:PivotTo(getgenv().BossOriginalCFrame)
                                getgenv().BossOriginalCFrame = nil
                                placeCollectedCardsBack()
                            end
                            getgenv().BossHasCollected = false
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
                        fireButton(autoReplayBtn)
                        getgenv().AutoReplayToggled = true
                        task.wait(0.3)
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
                        for _, v in ipairs(playerGui:GetDescendants()) do
                            if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Text then
                                local text = string.upper(string.match(v.Text or "", "^%s*(.-)%s*$") or "")
                                if text == "ACCEPT" or text == "YES" or text == "รับ" or text == "ยอมรับ" or text == "ตกลง" then
                                    local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                    if btn and btn.Visible then
                                        local fired = false
                                        if getconnections then
                                            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do conn:Fire() fired = true end
                                            for _, conn in pairs(getconnections(btn.Activated)) do conn:Fire() fired = true end
                                        end
                                        if not fired then
                                            local vim = game:GetService("VirtualInputManager")
                                            local center = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
                                            vim:SendMouseButtonEvent(center.X, center.Y + 36, 0, true, game, 1)
                                            task.wait(0.1)
                                            vim:SendMouseButtonEvent(center.X, center.Y + 36, 0, false, game, 1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.5)
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
                    if Options.AFKModeWhiteScreen then
                        Options.AFKModeWhiteScreen:SetValue(false)
                    end
                end)
            end
            afkScreenGui.Parent = CoreGui
            RunService:Set3dRenderingEnabled(false)
        else
            if afkScreenGui then afkScreenGui.Parent = nil end
            RunService:Set3dRenderingEnabled(true)
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
            local dictR = {}
            if type(data.Rarities) == "table" then
                for _, v in ipairs(RaritiesList) do
                    local lowerV = string.lower(v)
                    if data.Rarities[lowerV] == true or data.Rarities[v] == true then
                        dictR[v] = true
                        getgenv().SelectedRarities[lowerV] = true
                    end
                end
            end
            pcall(function() Options.SelectedRarities:SetValue(dictR) end)

            -- Sync Mutations Multi-Dropdown UI
            local dictM = {}
            if type(data.Mutations) == "table" then
                for _, v in ipairs(MutationsList) do
                    local lowerM = string.lower(v)
                    if data.Mutations[lowerM] == true or data.Mutations[v] == true then
                        dictM[v] = true
                        getgenv().SelectedMutations[lowerM] = true
                    end
                end
            end
            pcall(function() Options.SelectedMutations:SetValue(dictM) end)

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

-- Mobile Floating Draggable Toggle Button
pcall(function()
    if CoreGui:FindFirstChild("PayomboyZ_MobileToggle") then
        CoreGui.PayomboyZ_MobileToggle:Destroy()
    end

    local mobileGui = Instance.new("ScreenGui")
    mobileGui.Name = "PayomboyZ_MobileToggle"
    mobileGui.ResetOnSpawn = false
    mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mobileGui.Parent = CoreGui

    local toggleWrapper = Instance.new("TextButton")
    toggleWrapper.Name = "FloatingToggleButton"
    toggleWrapper.Size = UDim2.new(0, 180, 0, 50)
    toggleWrapper.Position = UDim2.new(0, 15, 0.35, 0)
    toggleWrapper.BackgroundColor3 = Color3.fromRGB(6, 11, 20)
    toggleWrapper.Text = ""
    toggleWrapper.AutoButtonColor = false
    toggleWrapper.Active = true
    toggleWrapper.Draggable = true
    toggleWrapper.Parent = mobileGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 25)
    corner.Parent = toggleWrapper

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(67, 207, 255)
    stroke.Thickness = 2
    stroke.Parent = toggleWrapper

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.new(0, 40, 0, 40)
    avatarImg.Position = UDim2.new(0, 5, 0, 5)
    avatarImg.BackgroundColor3 = Color3.fromRGB(13, 23, 39)
    
    local customImagePath = "543199739_2812856088914181_3062917809445648175_n.jpg"
    if isfile and isfile(customImagePath) and getcustomasset then
        avatarImg.Image = getcustomasset(customImagePath)
    else
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    end
    avatarImg.Parent = toggleWrapper

    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0)
    avCorner.Parent = avatarImg

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Title"
    nameLabel.Size = UDim2.new(0, 125, 0, 18)
    nameLabel.Position = UDim2.new(0, 50, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = LocalPlayer.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = toggleWrapper

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(0, 125, 0, 15)
    fpsLabel.Position = UDim2.new(0, 50, 0, 25)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: -- • Ping: --"
    fpsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    fpsLabel.TextSize = 11
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = toggleWrapper

    task.spawn(function()
        local Stats = game:GetService("Stats")
        while task.wait(1) do
            if not fpsLabel or not fpsLabel.Parent then break end
            local currentFps = math.floor(workspace:GetRealPhysicsFPS() or 60)
            local pingValue = 0
            pcall(function()
                pingValue = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            
            fpsLabel.Text = "FPS: " .. tostring(currentFps) .. " • Ping: " .. tostring(pingValue) .. "ms"
            
            if currentFps >= 50 and pingValue < 150 then
                fpsLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
            elseif currentFps >= 30 and pingValue < 300 then
                fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
            else
                fpsLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            end
        end
    end)

    toggleWrapper.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)
end)

Fluent:Notify({
    Title = "PayomboyZ",
    Content = "ปรับแต่งหน้าจอสำหรับมือถือสมบูรณ์! ✅\nปรับ UIScale = " .. tostring(initialScale),
    Duration = 6
})

Window:SelectTab(1)

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
while not player do task.wait(0.1); player = Players.LocalPlayer end
local playerGui = player:WaitForChild("PlayerGui", 10) or player.PlayerGui

-- Fast & Resilient CDN HTTP Loader for Fluent UI with Fallback Mirrors & Retries
local function safeHttpGet(urls)
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
    for retry = 1, 2 do
        for _, url in ipairs(urls) do
            -- Method 1: Standard game:HttpGet
            local ok, res = pcall(function() return game:HttpGet(url) end)
            if ok and type(res) == "string" and #res > 500 then
                return res
            end
            -- Method 2: HTTP Request table fallback (works on mobile executors with custom headers)
            if requestFunc then
                local reqOk, reqRes = pcall(function()
                    return requestFunc({ Url = url, Method = "GET" })
                end)
                if reqOk and reqRes and reqRes.Body and type(reqRes.Body) == "string" and #reqRes.Body > 500 then
                    return reqRes.Body
                end
            end
        end
        task.wait(0.5)
    end
    return nil
end

local fluentCode = safeHttpGet({
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua",
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@main/main.lua",
    "https://fastly.jsdelivr.net/gh/dawid-scripts/Fluent@main/main.lua",
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
})

local saveManagerCode = safeHttpGet({
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@main/Addons/SaveManager.lua",
    "https://fastly.jsdelivr.net/gh/dawid-scripts/Fluent@main/Addons/SaveManager.lua"
})

local interfaceManagerCode = safeHttpGet({
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua",
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@main/Addons/InterfaceManager.lua",
    "https://fastly.jsdelivr.net/gh/dawid-scripts/Fluent@main/Addons/InterfaceManager.lua"
})

if not fluentCode or not saveManagerCode or not interfaceManagerCode then
    StarterGui:SetCore("SendNotification", {
        Title = "PayomboyZ HUB",
        Text = "ไม่สามารถโหลด Fluent UI ได้ กรุณาตรวจสอบอินเทอร์เน็ตแล้วลองใหม่",
        Duration = 10
    })
    return
end

local Fluent = loadstring(fluentCode)()
local SaveManager = loadstring(saveManagerCode)()
local InterfaceManager = loadstring(interfaceManagerCode)()

-- Responsive UI Sizing for Mobile & Emulators
local viewport = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)
local winWidth = math.clamp(viewport.X - 30, 320, 580)
local winHeight = math.clamp(viewport.Y - 60, 280, 440)
local tabWidth = (viewport.X < 500) and 130 or 170

local Window = Fluent:CreateWindow({
    Title = "Roll Anime to Fight! ⚔️",
    SubTitle = "by PayomboyZ HUB",
    TabWidth = tabWidth,
    Size = UDim2.fromOffset(winWidth, winHeight),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Rich Floating Toggle & Profile HUD for Mobile & PC
task.spawn(function()
    local oldGui = CoreGui:FindFirstChild("PayomboyZToggleGui") or playerGui:FindFirstChild("PayomboyZToggleGui")
    if oldGui then oldGui:Destroy() end

    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "PayomboyZToggleGui"
    toggleGui.ResetOnSpawn = false

    pcall(function() toggleGui.Parent = CoreGui end)
    if not toggleGui.Parent or toggleGui.Parent ~= CoreGui then
        toggleGui.Parent = playerGui
    end

    local mainWidget = Instance.new("Frame")
    mainWidget.Name = "ProfileToggleWidget"
    mainWidget.Size = UDim2.fromOffset(230, 54)
    mainWidget.Position = UDim2.new(0, 15, 0.35, 0)
    mainWidget.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainWidget.BackgroundTransparency = 0.15
    mainWidget.BorderSizePixel = 0
    mainWidget.Active = true
    mainWidget.Parent = toggleGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = mainWidget

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 170, 255)
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = mainWidget

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 32, 48)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 16, 26))
    })
    gradient.Rotation = 45
    gradient.Parent = mainWidget

    -- Logo Image from GitHub
    local logoImage = Instance.new("ImageLabel")
    logoImage.Name = "LogoImage"
    logoImage.Size = UDim2.fromOffset(38, 38)
    logoImage.Position = UDim2.new(0, 8, 0.5, -19)
    logoImage.BackgroundTransparency = 1
    logoImage.ScaleType = Enum.ScaleType.Fit
    logoImage.Image = "rbxassetid://0"
    logoImage.Parent = mainWidget

    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 8)
    logoCorner.Parent = logoImage

    -- Non-blocking Async Image Download
    task.spawn(function()
        local logoUrl = "https://raw.githubusercontent.com/payomboyz333/Anime-Card-Farm/main/543199739_2812856088914181_3062917809445648175_n.jpg"
        local fileName = "543199739_2812856088914181_3062917809445648175_n.jpg"
        if getcustomasset then
            if isfile and isfile(fileName) then
                pcall(function() logoImage.Image = getcustomasset(fileName) end)
            else
                local req = (syn and syn.request) or (http and http.request) or http_request or request
                if req then
                    pcall(function()
                        local res = req({ Url = logoUrl, Method = "GET" })
                        if res and res.Body and writefile then
                            writefile(fileName, res.Body)
                            if isfile and isfile(fileName) then
                                logoImage.Image = getcustomasset(fileName)
                            end
                        end
                    end)
                else
                    pcall(function()
                        if writefile then
                            writefile(fileName, game:HttpGet(logoUrl))
                            if isfile and isfile(fileName) then
                                logoImage.Image = getcustomasset(fileName)
                            end
                        end
                    end)
                end
            end
        end
    end)

    -- Avatar Headshot Image
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Name = "AvatarImage"
    avatarImage.Size = UDim2.fromOffset(38, 38)
    avatarImage.Position = UDim2.new(0, 50, 0.5, -19)
    avatarImage.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    avatarImage.BackgroundTransparency = 0.5
    avatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    avatarImage.Parent = mainWidget

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatarImage

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = Color3.fromRGB(0, 200, 255)
    avatarStroke.Thickness = 1
    avatarStroke.Parent = avatarImage

    -- Player Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -96, 0, 20)
    nameLabel.Position = UDim2.new(0, 94, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = mainWidget

    -- FPS & Ping Label
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -96, 0, 16)
    statsLabel.Position = UDim2.new(0, 94, 0, 28)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "FPS: -- | Ping: --ms"
    statsLabel.Font = Enum.Font.GothamMedium
    statsLabel.TextSize = 11
    statsLabel.TextColor3 = Color3.fromRGB(0, 225, 255)
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = mainWidget

    -- Custom Dragging & Click-Toggle System (No blocking overlay)
    local dragging = false
    local dragStart = Vector3.new()
    local startPos = UDim2.new()
    local totalDragDist = 0

    mainWidget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainWidget.Position
            totalDragDist = 0
        end
    end)

    mainWidget.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                if totalDragDist < 6 then
                    if Window then
                        if type(Window.Minimize) == "function" then
                            Window:Minimize()
                        elseif Window.Root then
                            Window.Root.Visible = not Window.Root.Visible
                        end
                    end
                end
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            totalDragDist = totalDragDist + math.abs(delta.X) + math.abs(delta.Y)
            mainWidget.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Low-overhead FPS & Ping Update Loop
    local fpsCount = 0
    local lastFpsTick = tick()
    local currentFps = 60

    RunService.RenderStepped:Connect(function()
        fpsCount = fpsCount + 1
        if tick() - lastFpsTick >= 1 then
            currentFps = fpsCount
            fpsCount = 0
            lastFpsTick = tick()
        end
    end)

    local function getPing()
        local ok, p = pcall(function() return player:GetNetworkPing() end)
        if ok and p then
            return math.floor(p * 1000)
        end
        local ping = 0
        pcall(function()
            local s = Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerStatsItem")
            local item = s and s:FindFirstChild("Data Ping")
            if item then ping = math.floor(item:GetValue()) end
        end)
        return ping
    end

    task.spawn(function()
        while task.wait(1) do
            statsLabel.Text = string.format("FPS: %d | Ping: %dms", currentFps, getPing())
        end
    end)
end)

local Tabs = {
    Main = Window:AddTab({ Title = "หน้าหลัก", Icon = "home" }),
    AutoPlacement = Window:AddTab({ Title = "ออโต้วางยูนิต (Auto Play)", Icon = "sword" }),
    Tower = Window:AddTab({ Title = "ออโต้ทาวเวอร์ (Auto Tower)", Icon = "shield" }),
    Clone = Window:AddTab({ Title = "เครื่องโคลน (Clone Machine)", Icon = "copy" }),
    Trait = Window:AddTab({ Title = "ปรับแต่ง Trait (Trait Machine)", Icon = "sparkles" }),
    AutoSell = Window:AddTab({ Title = "ออโต้ขายยูนิต (Auto Sell)", Icon = "trash-2" }),
    Filter = Window:AddTab({ Title = "ตัวละคร / Rarity", Icon = "users" }),
    Upgrade = Window:AddTab({ Title = "อัปเกรด (Upgrade)", Icon = "trending-up" }),
    Settings = Window:AddTab({ Title = "ตั้งค่า", Icon = "settings" })
}

local Options = Fluent.Options
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

local function safeFireRemote(remote, ...)
    if not remote then return end
    local args = { ... }
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
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local owner = getPlotOwner(plot)
        if owner == player.UserId or owner == player.Name then
            cachedPlot = plot
            return plot
        end

        local ok, pivot = pcall(function() return plot:GetPivot() end)
        local dist = (ok and hrp) and (hrp.Position - pivot.Position).Magnitude or math.huge
        if dist < 50 then
            cachedPlot = plot
            return plot
        end
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

local function getOwnInventoryUnits()
    local unitNames = {}
    local seen = {}

    local function addUnit(name)
        if name and type(name) == "string" and name ~= "" and not seen[name] then
            seen[name] = true
            table.insert(unitNames, name)
        end
    end

    pcall(function()
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    addUnit(item.Name)
                end
            end
        end

        local char = player.Character
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    addUnit(item.Name)
                end
            end
        end

        local hotbar = safeFindPath(playerGui, "MainUI", "Hotbar") or safeFindPath(playerGui, "Hotbar")
        if hotbar then
            for _, slot in ipairs(hotbar:GetChildren()) do
                local textLabel = slot:FindFirstChildWhichIsA("TextLabel", true)
                if textLabel and textLabel.Text and textLabel.Text ~= "" and not tonumber(textLabel.Text) then
                    addUnit(textLabel.Text)
                end
            end
        end

        local invSlots = safeFindPath(playerGui, "MainUI", "Frames", "Animes", "Frame", "Main", "InventorySlots")
                      or safeFindPath(playerGui, "MainUI", "Frames", "Animes")
        if invSlots then
            for _, slot in ipairs(invSlots:GetDescendants()) do
                if slot:IsA("TextLabel") and (slot.Name == "UnitName" or slot.Name == "Title" or slot.Name == "Name") then
                    if slot.Text and slot.Text ~= "" then
                        addUnit(slot.Text)
                    end
                end
            end
        end
    end)

    table.sort(unitNames)
    if #unitNames == 0 then
        for _, name in ipairs(CharacterFallbackValues) do
            addUnit(name)
        end
    end
    return unitNames
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

    if not next(values) then
        local plots = workspace:FindFirstChild("Plots")
        if plots then
            for _, plot in ipairs(plots:GetChildren()) do
                local characters = plot:FindFirstChild("Characters")
                if characters then
                    for _, model in ipairs(characters:GetChildren()) do
                        if model:IsA("Model") then
                            addWorkspaceModelName(model, values)
                        end
                    end
                end
            end
        end
    end

    for _, name in ipairs(CharacterFallbackValues) do
        values[name] = true
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
            for _, value in ipairs(allowedValues) do
                if selectedValues[value] or table.find(selectedValues, value) then
                    table.insert(list, value)
                end
            end
        end
        return list
    end

    local function addSelectedTargets(mode, selectedValues, selectedMutations)
        local sourceValues = mode == "Rarity" and RarityValues or CharacterValues
        local selectedList = collectSelectedValues(selectedValues, sourceValues)
        if #selectedList == 0 then
            return
        end

        local mutations = {}
        if type(selectedMutations) == "table" then
            for _, mutation in ipairs(MutationValues) do
                if selectedMutations[mutation] or table.find(selectedMutations, mutation) then
                    table.insert(mutations, mutation)
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
    local sellInstances = {}

    -- METHOD 1: Scan Inventory GUI Slots (PlayerGui.MainUI.Frames.Animes.Frame.Main.ScrollingFrame)
    local invSlots = safeFindPath(playerGui, "MainUI", "Frames", "Animes", "Frame", "Main", "ScrollingFrame")
                  or safeFindPath(playerGui, "MainUI", "Frames", "Animes", "Frame", "Main", "InventorySlots")

    if invSlots then
        for _, slot in ipairs(invSlots:GetChildren()) do
            if slot:IsA("Frame") or slot:IsA("GuiObject") then
                if slot.Name == "Template" or slot.Name:find("Layout") then continue end

                -- Check lock
                if isUnitLocked(slot) then continue end

                -- Check equipped
                local eqLabel = slot:FindFirstChild("Equipped", true) or slot:GetAttribute("Equipped")
                if eqLabel == true or (eqLabel and eqLabel:IsA("GuiObject") and eqLabel.Visible) then
                    continue
                end

                -- Find unit name
                local nameLabel = safeFindPath(slot, "Frame", "Info", "AnimeName")
                               or slot:FindFirstChild("AnimeName", true)
                               or slot:FindFirstChild("Title", true)
                               or slot:FindFirstChild("UnitName", true)
                local unitName = nameLabel and nameLabel.Text or slot.Name
                local rarity = getUnitRarity(unitName, slot)

                if rarity then
                    local lowerR = rarity:lower()
                    -- EXCLUSION: Never sell Secret or Limited!
                    if lowerR ~= "secret" and lowerR ~= "limited" then
                        if activeRaritySet[lowerR] then
                            local uuid = getUnitUUID(slot)
                            if uuid then
                                table.insert(sellUUIDs, uuid)
                            end
                            table.insert(sellInstances, slot)
                        end
                    end
                end
            end
        end
    end

    -- METHOD 2: Scan Player Backpack Tools
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Parent ~= player.Character then
                if not isUnitLocked(tool) then
                    local rarity = getUnitRarity(tool.Name, tool)
                    if rarity then
                        local lowerR = rarity:lower()
                        -- EXCLUSION: Never sell Secret or Limited!
                        if lowerR ~= "secret" and lowerR ~= "limited" then
                            if activeRaritySet[lowerR] then
                                local uuid = getUnitUUID(tool)
                                if uuid then
                                    table.insert(sellUUIDs, uuid)
                                end
                                table.insert(sellInstances, tool)
                            end
                        end
                    end
                end
            end
        end
    end

    local countToSell = math.max(#sellUUIDs, #sellInstances)
    if countToSell == 0 then
        return 0
    end

    -- ENSURE SELL MODE IS OPEN IN GAME UI BEFORE SELLING
    pcall(function()
        local animesFrame = safeFindPath(playerGui, "MainUI", "Frames", "Animes")
                         or safeFindPath(playerGui, "MainUI", "Frames", "Animes", "Frame")
        if animesFrame then
            local isSellModeActive = false
            for _, desc in ipairs(animesFrame:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Visible then
                    local txt = desc.Text:lower()
                    if txt:find("select") and txt:find("sell") then
                        isSellModeActive = true
                        break
                    end
                end
            end

            if not isSellModeActive then
                for _, desc in ipairs(animesFrame:GetDescendants()) do
                    if (desc:IsA("ImageButton") or desc:IsA("TextButton")) and desc.Visible then
                        local n = desc.Name:lower()
                        if n:find("sell") or n:find("dollar") or n:find("toggle") then
                            if firesignal then firesignal(desc.MouseButton1Click)
                            elseif firebutton then firebutton(desc) end
                            task.wait(0.2)
                            break
                        end
                    end
                end
            end
        end
    end)

    -- EXECUTE SELL REMOTE VIA LATENCY-MANAGED BATCH QUEUE
    pcall(function()
        if sellRemote then
            if #sellUUIDs > 0 then
                -- Single batch array call format: Sell:FireServer({ UUID_1, UUID_2, ... })
                safeFireRemote(sellRemote, sellUUIDs)
            elseif #sellInstances > 0 then
                for _, inst in ipairs(sellInstances) do
                    safeFireRemote(sellRemote, inst)
                end
            end
        end
    end)

    -- Also trigger UI click buttons on card slots if present
    for _, slot in ipairs(sellInstances) do
        pcall(function()
            if slot:IsA("GuiObject") then
                local clickBtn = slot:FindFirstChild("ClickButton", true) or slot:FindFirstChildWhichIsA("GuiButton", true)
                if clickBtn then
                    if firesignal then firesignal(clickBtn.MouseButton1Click)
                    elseif firebutton then firebutton(clickBtn) end
                end
            end
        end)
    end

    return countToSell
end

-- ===== FLUENT UI COMPONENTS =====

Tabs.Filter:AddSection("Select Unit Type Rarity")

local Rarities1 = Tabs.Filter:AddDropdown("Rarities1", {
    Title = "Rarity 1",
    Description = "เลือกระดับที่ต้องการ 1",
    Values = RarityValues,
    Multi = true,
    Default = {},
})

local Mutations1 = Tabs.Filter:AddDropdown("Mutations1", {
    Title = "Mutation 1",
    Description = "เลือกบัพที่ต้องการ 1",
    Values = MutationValues,
    Multi = true,
    Default = {},
})

local Rarities2 = Tabs.Filter:AddDropdown("Rarities2", {
    Title = "Rarity 2",
    Description = "เลือกระดับที่ต้องการ 2",
    Values = RarityValues,
    Multi = true,
    Default = {},
})

local Mutations2 = Tabs.Filter:AddDropdown("Mutations2", {
    Title = "Mutation 2",
    Description = "เลือกบัพที่ต้องการ 2",
    Values = MutationValues,
    Multi = true,
    Default = {},
})

Tabs.Filter:AddSection("Select Unit Type Name")

local Names3 = Tabs.Filter:AddDropdown("Names3", {
    Title = "Name 1",
    Description = "เลือกชื่อที่ต้องการ 1",
    Values = CharacterValues,
    Multi = true,
    Default = {},
})

local Mutations3 = Tabs.Filter:AddDropdown("Mutations3", {
    Title = "Mutation 1",
    Description = "เลือกบัพที่ต้องการ 1",
    Values = MutationValues,
    Multi = true,
    Default = {},
})

local Names4 = Tabs.Filter:AddDropdown("Names4", {
    Title = "Name 2",
    Description = "เลือกชื่อที่ต้องการ 2",
    Values = CharacterValues,
    Multi = true,
    Default = {},
})

local Mutations4 = Tabs.Filter:AddDropdown("Mutations4", {
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

Tabs.Main:AddSection("ฟังชั่นอื่นๆ (Misc)")

local AutoSpinWheel = Tabs.Main:AddToggle("AutoSpinWheel", {
    Title = "Auto Spin Wheel",
    Description = "ออโต้วงล้อ",
    Default = false,
})

local AutoClaimBattlepass = Tabs.Main:AddToggle("AutoClaimBattlepass", {
    Title = "Auto Claim Battlepass (Free)",
    Description = "ออโต้เคลมแบทเทิลพาส (ฟรี)",
    Default = false,
})

local AutoClaimPremiumBattlepass = Tabs.Main:AddToggle("AutoClaimPremiumBattlepass", {
    Title = "Auto Claim Battlepass (Premium)",
    Description = "ออโต้เคลมแบทเทิลพาส (พรีเมียม)",
    Default = false,
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

Tabs.Clone:AddSection("ระบบเครื่องโคลนยูนิต (Clone Machine System)")

local initialUnits = getOwnInventoryUnits()

local SelectCloneUnit = Tabs.Clone:AddDropdown("SelectCloneUnit", {
    Title = "เลือกยูนิตที่จะโคลน (Select Clone Unit)",
    Description = "เลือกตัวละครจากในกระเป๋าของคุณเท่านั้น",
    Values = initialUnits,
    Default = initialUnits[1] or "",
})

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

local SelectTraitUnit = Tabs.Trait:AddDropdown("SelectTraitUnit", {
    Title = "เลือกตัวละครจากกระเป๋า (Select Trait Unit)",
    Description = "เลือกตัวละครจากในกระเป๋าเพื่อสุ่ม Trait",
    Values = initialTraitUnits,
    Default = initialTraitUnits[1] or "",
})

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

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("PayomboyZ")
SaveManager:SetFolder("PayomboyZ/RollAnimeToFight")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()
Window:SelectTab(1)
rebuildTargetLookup()

task.delay(0.5, function()
    isUiInitialized = true
end)

Fluent:Notify({
    Title = "PayomboyZ HUB",
    Content = "โหลด Fluent UI สำเร็จแล้ว! ❤️",
    Duration = 5
})

-- ===== BACKGROUND AUTOMATION THREADS (NON-BLOCKING & THROTTLED) =====

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
    task.wait(2)
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

-- Throttled Auto Tower Thread
task.spawn(function()
    task.wait(2.0)
    while task.wait(1.5) do
        local doTower = Options.AutoJoinTower and Options.AutoJoinTower.Value
        if doTower then
            local joinTowerRemote = safeFindPath(ReplicatedStorage, "Remotes", "JoinTower")
            if joinTowerRemote then
                safeFireRemote(joinTowerRemote)
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



-- Throttled Auto Clone Machine Thread
task.spawn(function()
    local lastCloneAttempt = 0
    while task.wait(3.0) do
        local doClone = Options.AutoClone and Options.AutoClone.Value
        local doHalfTime = Options.AutoCloneHalfTime and Options.AutoCloneHalfTime.Value

        if not (doClone or doHalfTime) then continue end

        local cloneMachine = safeFindPath(workspace, "Machines", "Clone")
                          or workspace:FindFirstChild("Clone", true)
        local prompt = cloneMachine and (safeFindPath(cloneMachine, "PP", "ProximityPrompt") or cloneMachine:FindFirstChildWhichIsA("ProximityPrompt", true))

        if prompt then
            pcall(function() firePrompt(prompt) end)
            task.wait(0.3)
        end

        local cloneFrame = safeFindPath(playerGui, "MainUI", "Frames", "Clone", "Frame", "Main")
        if cloneFrame then
            if doHalfTime then
                local halfBtn = safeFindPath(cloneFrame, "Buttons", "TimerHalf", "Button")
                if halfBtn then
                    pcall(function()
                        if firesignal then firesignal(halfBtn.MouseButton1Click)
                        elseif firebutton then firebutton(halfBtn) end
                    end)
                    task.wait(0.3)
                end
            end

            if doClone and (tick() - lastCloneAttempt > 10) then
                local cloneBtn = safeFindPath(cloneFrame, "Buttons", "Clone", "Button")
                if cloneBtn then
                    pcall(function()
                        if firesignal then firesignal(cloneBtn.MouseButton1Click)
                        elseif firebutton then firebutton(cloneBtn) end
                    end)
                    lastCloneAttempt = tick()
                    task.wait(0.5)
                end
            end
        end
    end
end)

-- Throttled Auto Trait Machine Thread
task.spawn(function()
    local lastPromptTime = 0

    while task.wait(0.4) do
        local doRoll = Options.AutoRollTrait and Options.AutoRollTrait.Value
        if not doRoll then continue end

        local selectedUnitName = Options.SelectTraitUnit and Options.SelectTraitUnit.Value
        local delayVal = (Options.TraitRollDelay and Options.TraitRollDelay.Value) or 0.5

        local traitsFrame = safeFindPath(playerGui, "MainUI", "Frames", "Traits")
        local isUiVisible = traitsFrame and (traitsFrame.Visible or (traitsFrame:IsA("CanvasGroup") and traitsFrame.GroupTransparency < 0.9))

        -- Step 1: Only trigger ProximityPrompt if UI is NOT open yet (avoid pressing E repeatedly!)
        if not isUiVisible and (tick() - lastPromptTime > 4) then
            lastPromptTime = tick()
            local traitMachine = safeFindPath(workspace, "Machines", "Trait")
                              or safeFindPath(workspace, "Machines", "Traits")
                              or workspace:FindFirstChild("Trait", true)
                              or workspace:FindFirstChild("Traits", true)
            local prompt = traitMachine and (safeFindPath(traitMachine, "PP", "ProximityPrompt") or traitMachine:FindFirstChildWhichIsA("ProximityPrompt", true))

            if prompt then
                pcall(function() firePrompt(prompt) end)
                task.wait(0.8)
            end
        end

        -- Step 2: Hold/equip selected unit tool in hand if present
        local targetUnitObj = nil
        local backpack = player:FindFirstChild("Backpack")
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")

        if selectedUnitName then
            if backpack then
                targetUnitObj = backpack:FindFirstChild(selectedUnitName)
            end
            if not targetUnitObj and char then
                targetUnitObj = char:FindFirstChild(selectedUnitName)
            end
            if targetUnitObj and targetUnitObj:IsA("Tool") and humanoid and targetUnitObj.Parent ~= char then
                pcall(function() humanoid:EquipTool(targetUnitObj) end)
            end
        end

        -- Step 3: Check current trait of unit to see if target lock is reached
        local targetLocks = (Options.TargetTraitLocks and Options.TargetTraitLocks.Value) or {}
        if targetUnitObj then
            local currentTrait = targetUnitObj:GetAttribute("Trait")
                              or targetUnitObj:GetAttribute("CurrentTrait")

            local isMatched = false
            if currentTrait then
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
                        Content = "ได้รับ Trait ล็อคเป้าหมาย: " .. tostring(currentTrait) .. " ให้กับ " .. tostring(selectedUnitName) .. " เรียบร้อยแล้ว!",
                        Duration = 8
                    })
                end)
                continue
            end
        end

        -- Step 4: Execute Roll via RemoteEvent
        local traitRemote = safeFindPath(ReplicatedStorage, "Remotes", "Trait", "Request")
                         or safeFindPath(ReplicatedStorage, "Remotes", "Trait", "Roll")
        if traitRemote then
            if targetUnitObj then
                safeFireRemote(traitRemote, "Roll", targetUnitObj)
            else
                safeFireRemote(traitRemote, "Roll")
            end
        end

        -- Step 5: Also click ROLL button in UI
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
    task.wait(2.5)
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
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart", 10) or character:FindFirstChild("HumanoidRootPart")
    local plotsFolder = workspace:WaitForChild("Plots", 10) or workspace:FindFirstChild("Plots")
    local cashLabel = nil

    if not hrp or not plotsFolder then return end

    local state = { buying = false, hasBoughtThisRoll = false }

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
        local buyUI = head and head:FindFirstChild("BuyUI")
        if buyUI then
            local frame = buyUI:FindFirstChild("Frame")
            local chance = frame and frame:FindFirstChild("Chance")
            local label = chance and chance:FindFirstChild("TextLabel")
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
        local buyUI = head and head:FindFirstChild("BuyUI")
        if buyUI then
            local frame = buyUI:FindFirstChild("Frame")
            local nameFrame = frame and frame:FindFirstChild("Name")
            local label = nameFrame and nameFrame:FindFirstChild("TextLabel")
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

        if targetConfig and #targetConfig > 0 then
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
        else
            -- DEFAULT: Score unit rarity so candidates[1] is ALWAYS the single best unit on the plot
            local score = getRarityScore(model)
            return (1000000000 - score), rarity or "Unknown", mutation, "Best"
        end
    end

    local function getPlotOwner(plot)
        return plot:GetAttribute("OwnerUserId")
            or plot:GetAttribute("OwnerId")
            or plot:GetAttribute("Owner")
            or plot:GetAttribute("OwnerName")
            or plot:GetAttribute("Player")
            or plot:GetAttribute("UserId")
    end

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

    local lastCashSearch = 0
    local function readCash()
        if not cashLabel or not cashLabel.Parent then
            if tick() - lastCashSearch > 5 then
                lastCashSearch = tick()
                cashLabel = safeFindPath(playerGui, "MainUI", "UILeft", "TopButtons", "Cash", "CashLabel")
                         or safeFindPath(playerGui, "MainUI", "TopButtons", "Cash", "CashLabel")
                         or playerGui:FindFirstChild("CashLabel", true)
            end
        end
        if cashLabel and cashLabel:IsA("TextLabel") then
            local val = parseMoney(cashLabel.Text)
            if val then return val end
        end
        return math.huge
    end

    local function getPriceLabel(model)
        local head = model:FindFirstChild("Head")
        local buyUI = head and head:FindFirstChild("BuyUI")
        if buyUI then
            local frame = buyUI:FindFirstChild("Frame")
            local price = frame and frame:FindFirstChild("Price")
            local label = price and price:FindFirstChild("TextLabel")
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

        return plot:FindFirstChild("RollPrompt", true)
    end

    local function getBuyCandidates(plot)
        local candidates = {}
        local scanRoot = plot:FindFirstChild("Characters") or plot
        local models = scanRoot:GetChildren()

        for _, inst in ipairs(models) do
            if inst:IsA("Model") then
                -- Fast Guard: Unit must have Head or BuyUI to be a buy candidate
                local head = inst:FindFirstChild("Head")
                local buyUI = head and head:FindFirstChild("BuyUI") or inst:FindFirstChild("BuyUI")
                if not buyUI then continue end

                if isBoughtCharacterModel(inst, scanRoot) then
                    continue
                end

                local priceLabel = getPriceLabel(inst)
                local prompt = findPrompt(inst)
                if not prompt then continue end

                local targetIndex, characterName, mutation = getTargetIndex(inst)

                if priceLabel and targetIndex then
                    local price = parseMoney(priceLabel.Text) or 0
                    table.insert(candidates, {
                        model = inst,
                        characterName = characterName,
                        mutation = mutation,
                        targetIndex = targetIndex,
                        price = price,
                        priceLabel = priceLabel,
                        prompt = prompt,
                    })
                end
            end
        end

        table.sort(candidates, function(a, b)
            if a.targetIndex ~= b.targetIndex then
                return a.targetIndex < b.targetIndex
            end
            return a.price < b.price
        end)

        return candidates
    end

    state.hasBoughtThisRoll = false

    while true do
        local delayTime = (Options.RollDelay and tonumber(Options.RollDelay.Value)) or 2.0
        if delayTime < 0.5 then delayTime = 0.5 end

        if not Options.AutoBuyPlot or not Options.AutoBuyPlot.Value then
            task.wait(0.5)
            continue
        end

        local myPlot = getBestPlot()
        if not myPlot then
            task.wait(0.5)
            continue
        end

        local cycleStartTime = tick()
        local boughtOrBlocked = false

        if not state.buying and not state.hasBoughtThisRoll then
            local candidates = getBuyCandidates(myPlot)
            local cash = readCash()

            -- Buy ONLY the SINGLE BEST candidate from this roll round!
            if #candidates > 0 then
                local bestCandidate = candidates[1]
                if cash >= bestCandidate.price then
                    state.buying = true
                    firePrompt(bestCandidate.prompt)
                    task.wait(0.4)
                    state.buying = false
                    state.hasBoughtThisRoll = true
                    boughtOrBlocked = true
                else
                    -- Cannot afford the best unit yet, hold and wait until cash accumulates
                    boughtOrBlocked = true
                end
            end
        end

        -- If we already bought 1 unit from this roll (or if nothing to buy), Roll next round!
        if not state.buying and (state.hasBoughtThisRoll or not boughtOrBlocked) then
            local rollPrompt = getRollPrompt(myPlot)
            if rollPrompt and rollPrompt.Enabled then
                firePrompt(rollPrompt)
                state.hasBoughtThisRoll = false
                
                -- Wait for server to spawn/update the model & BuyUI on plot
                task.wait(0.4)

                -- Scan immediately after roll spawn
                local postRollCandidates = getBuyCandidates(myPlot)
                local cash = readCash()
                if #postRollCandidates > 0 then
                    local bestCandidate = postRollCandidates[1]
                    if cash >= bestCandidate.price then
                        state.buying = true
                        firePrompt(bestCandidate.prompt)
                        task.wait(0.4)
                        state.buying = false
                        state.hasBoughtThisRoll = true
                    end
                end
            end
        end

        -- Throttle whole cycle so it fires once per delayTime (default 2 seconds)
        local elapsed = tick() - cycleStartTime
        local sleepTime = delayTime - elapsed
        if sleepTime > 0 then
            task.wait(sleepTime)
        else
            task.wait(0.2)
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

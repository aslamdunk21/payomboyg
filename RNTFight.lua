local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
while not player do task.wait(0.1); player = Players.LocalPlayer end
local playerGui = player:WaitForChild("PlayerGui", 10) or player.PlayerGui

-- Fast CDN HTTP Loader for Fluent UI
local function safeHttpGet(urls)
    for _, url in ipairs(urls) do
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and type(res) == "string" and #res > 500 then
            return res
        end
    end
    return nil
end

local fluentCode = safeHttpGet({
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua",
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@main/main.lua",
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
})

local saveManagerCode = safeHttpGet({
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@main/Addons/SaveManager.lua"
})

local interfaceManagerCode = safeHttpGet({
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua",
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@main/Addons/InterfaceManager.lua"
})

if not fluentCode or not saveManagerCode or not interfaceManagerCode then
    StarterGui:SetCore("SendNotification", {
        Title = "PayomboyZ HUB",
        Text = "ไม่สามารถโหลด Fluent UI ได้ กรุณาลองใหม่อีกครั้ง",
        Duration = 10
    })
    return
end

local Fluent = loadstring(fluentCode)()
local SaveManager = loadstring(saveManagerCode)()
local InterfaceManager = loadstring(interfaceManagerCode)()

local Window = Fluent:CreateWindow({
    Title = "Roll Anime to Fight! ⚔️",
    SubTitle = "by PayomboyZ HUB",
    TabWidth = 180,
    Size = UDim2.fromOffset(600, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "หน้าหลัก", Icon = "home" }),
    Filter = Window:AddTab({ Title = "ตัวละคร / Rarity", Icon = "users" }),
    Settings = Window:AddTab({ Title = "ตั้งค่า", Icon = "settings" })
}

local Options = Fluent.Options

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

local function sortedValues(set)
    local values = {}
    for value in pairs(set) do
        table.insert(values, value)
    end
    table.sort(values)
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

    return sortedValues(values)
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

Tabs.Main:AddSection("ระบบออโต้หลัก (Main Auto)")

local AutoBuyPlot = Tabs.Main:AddToggle("AutoBuyPlot", {
    Title = "Auto Roll/Buy",
    Description = "ออโต้โรลและซื้อ",
    Default = false,
})

local RollDelaySlider = Tabs.Main:AddSlider("RollDelay", {
    Title = "Roll Delay",
    Description = "ดีเลย์การสุ่ม (วินาที)",
    Default = 0.8,
    Min = 0.3,
    Max = 3.0,
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

Fluent:Notify({
    Title = "PayomboyZ HUB",
    Content = "โหลด Fluent UI สำเร็จแล้ว! ❤️",
    Duration = 5
})

-- ===== BACKGROUND AUTOMATION THREADS (NON-BLOCKING & THROTTLED) =====

local function safeFindPath(root, ...)
    local current = root
    for _, name in ipairs({...}) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

-- Refresh Dynamic Values
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
    while task.wait(1.5) do
        if not Options.AutoSpinWheel or not Options.AutoSpinWheel.Value then continue end

        local label = safeFindPath(playerGui, "MainUI", "Frames", "SpinWheel", "Content", "Buttons", "Spin", "Label")
        local remote = safeFindPath(ReplicatedStorage, "Remotes", "SpinWheel", "Spin")

        if label and remote then
            local text = label.Text or ""
            local count = tonumber(text:match("%((%d+)%)")) or 0
            if count > 0 then
                remote:FireServer("Spin")
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
                                remote:FireServer(index, "Free")
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
                                remote:FireServer(index, "Premium")
                                task.wait(0.2)
                            end
                        end
                    end
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
    local cashLabel = safeFindPath(playerGui, "MainUI", "UILeft", "TopButtons", "Cash", "CashLabel")

    if not hrp or not plotsFolder then return end

    local state = { buying = false }

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

    local function getTargetIndex(model)
        local nameAliases = getModelCharacterNameAliases(model)
        local rarity = getModelRarity(model)
        local mutation = getModelMutation(model)
        if not mutation then return nil end

        local normalizedMutation = normalizeKey(mutation)
        local normalizedRarity = rarity and normalizeKey(rarity) or nil
        local normalizedNames = {}

        for _, alias in ipairs(nameAliases) do
            normalizedNames[normalizeKey(alias)] = alias
        end

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

    local function readCash()
        if not cashLabel then
            cashLabel = safeFindPath(playerGui, "MainUI", "UILeft", "TopButtons", "Cash", "CashLabel")
        end
        if not cashLabel then return 0 end
        return parseMoney(cashLabel.Text) or 0
    end

    local function getPriceLabel(model)
        local head = model:FindFirstChild("Head")
        local buyUI = head and head:FindFirstChild("BuyUI")
        if buyUI then
            local frame = buyUI:FindFirstChild("Frame")
            local price = frame and frame:FindFirstChild("Price")
            local label = price and price:FindFirstChild("TextLabel")
            if label then return label end
        end
        return nil
    end

    local function findPrompt(root)
        if not root then return nil end
        local head = root:FindFirstChild("Head")
        local buyUI = head and head:FindFirstChild("BuyUI")
        if buyUI then
            local prompt = buyUI:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then return prompt end
        end
        return root:FindFirstChildWhichIsA("ProximityPrompt")
    end

    local function firePrompt(prompt)
        if not prompt then return false end
        return pcall(function() fireproximityprompt(prompt) end)
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

    local function getBestPlot()
        local bestPlot = nil
        local bestDist = math.huge

        for _, plot in ipairs(plotsFolder:GetChildren()) do
            local owner = getPlotOwner(plot)
            if owner == player.UserId or owner == player.Name then
                return plot
            end

            local ok, pivot = pcall(function() return plot:GetPivot() end)
            local dist = ok and (hrp.Position - pivot.Position).Magnitude or math.huge
            if dist < bestDist then
                bestDist = dist
                bestPlot = plot
            end
        end
        return bestPlot
    end

    local function getBuyCandidates(plot)
        local candidates = {}
        local scanRoot = plot:FindFirstChild("Characters") or plot
        local models = scanRoot == plot and scanRoot:GetDescendants() or scanRoot:GetChildren()

        for _, inst in ipairs(models) do
            if inst:IsA("Model") then
                local head = inst:FindFirstChild("Head")
                if not head or not head:FindFirstChild("BuyUI") then
                    continue
                end

                if isBoughtCharacterModel(inst, scanRoot) then
                    continue
                end

                local priceLabel = getPriceLabel(inst)
                local prompt = findPrompt(inst)
                local targetIndex, characterName, mutation = getTargetIndex(inst)

                if priceLabel and prompt and prompt.Enabled and targetIndex then
                    local price = parseMoney(priceLabel.Text)
                    if price then
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
        end

        table.sort(candidates, function(a, b)
            if a.targetIndex ~= b.targetIndex then
                return a.targetIndex < b.targetIndex
            end
            return a.price < b.price
        end)

        return candidates
    end

    while task.wait(0.35) do
        if not Options.AutoBuyPlot or not Options.AutoBuyPlot.Value then continue end

        local myPlot = getBestPlot()
        if not myPlot then continue end

        local boughtOrBlocked = false

        if not state.buying then
            local candidates = getBuyCandidates(myPlot)
            local cash = readCash() or 0

            for _, candidate in ipairs(candidates) do
                if cash < candidate.price then
                    boughtOrBlocked = true
                    continue
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
            if rollPrompt and rollPrompt.Enabled then
                firePrompt(rollPrompt)
                local delayTime = (Options.RollDelay and tonumber(Options.RollDelay.Value)) or 0.8
                task.wait(delayTime)
            end
        end
    end
end)

local CoreGui = gethui and gethui() or game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
while not player do
    task.wait(0.1)
    player = Players.LocalPlayer
end
local playerGui = player:WaitForChild("PlayerGui", 15) or player.PlayerGui

local function safeHttpGet(url, name)
    local content = nil
    for i = 1, 5 do
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if success and result and result ~= "" and not result:find("Curl error") then
            content = result
            break
        end
        task.wait(1)
    end
    if not content then
        error("Failed to load dependency: " .. tostring(name) .. " after 5 attempts. Check your internet connection or executor.")
    end
    return content
end

local Fluent = loadstring(safeHttpGet("https://cdn.jsdelivr.net/gh/1dontgiveaf/Fluent@main/main.lua", "Fluent"))()
local SaveManager = loadstring(safeHttpGet("https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@master/Addons/SaveManager.lua", "SaveManager"))()
local InterfaceManager = loadstring(safeHttpGet("https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@master/Addons/InterfaceManager.lua", "InterfaceManager"))()
local Window = Fluent:CreateWindow({
    Title = "Roll Anime to Fight! ⚔️",
    SubTitle = "Made by PayomboyZ HUB",
    TabWidth = 200,
    Size = UDim2.fromOffset(580, 400),
    Acrylic = false,
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.K
})

task.spawn(function()
    local titleLabel
    local subLabel
    local attempts = 0

    repeat
        attempts = attempts + 1
        local fluentGui = nil
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name:find("Fluent") or gui.Name:find("ScreenGui")) then
                fluentGui = gui
                break
            end
        end
        
        if fluentGui then
            for _, v in ipairs(fluentGui:GetDescendants()) do
                if v:IsA("TextLabel") then
                    if not titleLabel and v.Text:find("Roll Anime to Fight!") then
                        titleLabel = v
                    elseif not subLabel and v.Text:find("Made by PayomboyZ HUB") then
                        subLabel = v
                    end
                end
            end
        end
        
        if not (titleLabel and subLabel) then
            task.wait(1)
        end
    until (titleLabel and subLabel) or attempts > 10

    if titleLabel and subLabel then
        titleLabel.RichText = true
        subLabel.RichText = true
        titleLabel.Text = '<b><font color="rgb(255,100,100)">Roll Anime to Fight! ⚔️</font></b>'
        subLabel.Text = '<b><font color="rgb(200,200,200)">Made by PayomboyZ HUB</font></b>'
    end
end)

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

StarterGui:SetCore("SendNotification", {
    Title = "PayomboyZ HUB",
    Text = "AntiAFK Active",
    Duration = 5
})

local MainTab = Window:AddTab({ Title = "หน้าหลัก", Icon = "home" })
local FilterTab = Window:AddTab({ Title = "ตัวละคร", Icon = "users" })
local Setting = Window:AddTab({ Title = "ตั้งค่า", Icon = "settings" })
local Options = Fluent.Options

local ConfigFolder = "PayomboyZ"
local ConfigFile = ConfigFolder .. "/config.json"

local CharacterFallbackValues = {
    "Zoro",
    "Krillin",
    "Luffy",
    "Ussop",
    "Itadori",
    "Maki",
    "Goku",
    "Sakura",
    "Mob",
    "Junwoo",
    "Tanjiro",
    "Shinra",
}

local RarityFallbackValues = {
    "Common",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "God",
    "Secret",
    "Limited",
}

local MutationFallbackValues = {
    "Normal",
    "Gold",
    "Diamond",
    "Demon",
    "Destroyer",
    "Hollow",
    "Slayer",
    "Cursed",
    "Astronaut",
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

    local function addWorkspaceModelName(model)
        addName(model.Name)

        local head = model:FindFirstChild("Head")
        local buyUI = head and head:FindFirstChild("BuyUI")
        local frame = buyUI and buyUI:FindFirstChild("Frame")
        local nameFrame = frame and frame:FindFirstChild("Name")
        local label = nameFrame and nameFrame:FindFirstChild("TextLabel")

        if label and label:IsA("TextLabel") then
            addName(label.Text)
            return
        end

        local fallbackBuyUI = model:FindFirstChild("BuyUI", true)
        if fallbackBuyUI then
            local fallbackName = fallbackBuyUI:FindFirstChild("Name", true)
            if fallbackName then
                label = fallbackName:FindFirstChildWhichIsA("TextLabel", true)
                if label then
                    addName(label.Text)
                end
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
                            addWorkspaceModelName(model)
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

    local fallbackDamage = {}
    for index, mutation in ipairs(MutationFallbackValues) do
        fallbackDamage[mutation:lower()] = index - 1
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

local function normalizeMultiValue(value, allowedValues)
    local selected = {}

    if type(value) ~= "table" then
        return selected
    end

    for _, item in ipairs(allowedValues) do
        if value[item] == true or table.find(value, item) then
            selected[item] = true
        end
    end

    return selected
end

local function selectedToList(selectedValues, allowedValues)
    local selected = {}

    for _, item in ipairs(allowedValues) do
        if selectedValues[item] then
            table.insert(selected, item)
        end
    end

    return selected
end

local AutoBuyPlotEnabled = false
local RollDelay = 0.8
local AutoSpinWheelEnabled = false
local AutoClaimBattlepassEnabled = false
local AutoClaimPremiumBattlepassEnabled = false
local SelectedRarities = {}
local SelectedMutations = {}
local SelectedRarities2 = {}
local SelectedMutations2 = {}
local SelectedNames3 = {}
local SelectedMutations3 = {}
local SelectedNames4 = {}
local SelectedMutations4 = {}

local function getOptionValue(optionName, fallback)
    local value = fallback

    pcall(function()
        if Options and Options[optionName] and Options[optionName].Value ~= nil then
            value = Options[optionName].Value
        end
    end)

    return value
end

local function saveConfig()
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end

    local configTable = {
        Rarities1 = getOptionValue("Rarities1", SelectedRarities),
        Mutations1 = getOptionValue("Mutations1", SelectedMutations),
        Rarities2 = getOptionValue("Rarities2", SelectedRarities2),
        Mutations2 = getOptionValue("Mutations2", SelectedMutations2),
        Names3 = getOptionValue("Names3", SelectedNames3),
        Mutations3 = getOptionValue("Mutations3", SelectedMutations3),
        Names4 = getOptionValue("Names4", SelectedNames4),
        Mutations4 = getOptionValue("Mutations4", SelectedMutations4),
        AutoBuyPlot = getOptionValue("AutoBuyPlot", AutoBuyPlotEnabled),
        RollDelay = getOptionValue("RollDelay", RollDelay),
        AutoSpinWheel = getOptionValue("AutoSpinWheel", AutoSpinWheelEnabled),
        AutoClaimBattlepass = getOptionValue("AutoClaimBattlepass", AutoClaimBattlepassEnabled),
        AutoClaimPremiumBattlepass = getOptionValue("AutoClaimPremiumBattlepass", AutoClaimPremiumBattlepassEnabled),
    }

    local success, jsonString = pcall(function()
        return HttpService:JSONEncode(configTable)
    end)

    if success then
        writefile(ConfigFile, jsonString)
    end
end

local function loadConfig()
    if not isfile(ConfigFile) then
        return
    end

    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(ConfigFile))
    end)

    if not success or type(decoded) ~= "table" then
        return
    end

    local loadedRarities = normalizeMultiValue(decoded.Rarities1, RarityValues)
    local loadedMutations = normalizeMultiValue(decoded.Mutations1 or decoded.Mutations, MutationValues)
    local loadedRarities2 = normalizeMultiValue(decoded.Rarities2, RarityValues)
    local loadedMutations2 = normalizeMultiValue(decoded.Mutations2, MutationValues)
    local loadedNames3 = normalizeMultiValue(decoded.Names3, CharacterValues)
    local loadedMutations3 = normalizeMultiValue(decoded.Mutations3, MutationValues)
    local loadedNames4 = normalizeMultiValue(decoded.Names4, CharacterValues)
    local loadedMutations4 = normalizeMultiValue(decoded.Mutations4, MutationValues)

    if next(loadedRarities) then
        SelectedRarities = loadedRarities
    end

    if next(loadedMutations) then
        SelectedMutations = loadedMutations
    end

    if next(loadedRarities2) then
        SelectedRarities2 = loadedRarities2
    end

    if next(loadedMutations2) then
        SelectedMutations2 = loadedMutations2
    end

    if next(loadedNames3) then
        SelectedNames3 = loadedNames3
    end

    if next(loadedMutations3) then
        SelectedMutations3 = loadedMutations3
    end

    if next(loadedNames4) then
        SelectedNames4 = loadedNames4
    end

    if next(loadedMutations4) then
        SelectedMutations4 = loadedMutations4
    end

    AutoBuyPlotEnabled = decoded.AutoBuyPlot == true
    if decoded.RollDelay ~= nil then
        RollDelay = tonumber(decoded.RollDelay) or 0.8
    end
    AutoSpinWheelEnabled = decoded.AutoSpinWheel == true
    AutoClaimBattlepassEnabled = decoded.AutoClaimBattlepass == true
    AutoClaimPremiumBattlepassEnabled = decoded.AutoClaimPremiumBattlepass == true

    task.spawn(function()
        repeat
            task.wait()
        until Options
            and Options.Rarities1
            and Options.Mutations1
            and Options.Rarities2
            and Options.Mutations2
            and Options.Names3
            and Options.Mutations3
            and Options.Names4
            and Options.Mutations4
            and Options.AutoBuyPlot
            and Options.RollDelay
            and Options.AutoSpinWheel
            and Options.AutoClaimBattlepass
            and Options.AutoClaimPremiumBattlepass

        if decoded.Rarities1 ~= nil then
            Options.Rarities1:SetValue(decoded.Rarities1)
        end

        if decoded.Mutations1 ~= nil then
            Options.Mutations1:SetValue(decoded.Mutations1)
        elseif decoded.Mutations ~= nil then
            Options.Mutations1:SetValue(decoded.Mutations)
        end

        if decoded.Rarities2 ~= nil then
            Options.Rarities2:SetValue(decoded.Rarities2)
        end

        if decoded.Mutations2 ~= nil then
            Options.Mutations2:SetValue(decoded.Mutations2)
        end

        if decoded.Names3 ~= nil then
            Options.Names3:SetValue(decoded.Names3)
        end

        if decoded.Mutations3 ~= nil then
            Options.Mutations3:SetValue(decoded.Mutations3)
        end

        if decoded.Names4 ~= nil then
            Options.Names4:SetValue(decoded.Names4)
        end

        if decoded.Mutations4 ~= nil then
            Options.Mutations4:SetValue(decoded.Mutations4)
        end

        if decoded.AutoBuyPlot ~= nil then
            Options.AutoBuyPlot:SetValue(decoded.AutoBuyPlot)
        end

        if decoded.RollDelay ~= nil then
            Options.RollDelay:SetValue(decoded.RollDelay)
        end

        if decoded.AutoSpinWheel ~= nil then
            Options.AutoSpinWheel:SetValue(decoded.AutoSpinWheel)
        end

        if decoded.AutoClaimBattlepass ~= nil then
            Options.AutoClaimBattlepass:SetValue(decoded.AutoClaimBattlepass)
        end

        if decoded.AutoClaimPremiumBattlepass ~= nil then
            Options.AutoClaimPremiumBattlepass:SetValue(decoded.AutoClaimPremiumBattlepass)
        end

    end)
end

loadConfig()

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

        for _, value in ipairs(allowedValues) do
            if selectedValues[value] then
                table.insert(list, value)
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

        for _, mutation in ipairs(MutationValues) do
            if selectedMutations[mutation] then
                table.insert(mutations, mutation)
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

    addSelectedTargets("Rarity", SelectedRarities, SelectedMutations)
    addSelectedTargets("Rarity", SelectedRarities2, SelectedMutations2)
    addSelectedTargets("Name", SelectedNames3, SelectedMutations3)
    addSelectedTargets("Name", SelectedNames4, SelectedMutations4)

    return config
end

local function rebuildTargetLookup()
    targetConfig = buildTargetConfig()
end
local Section = FilterTab:AddSection("เลือกระดับยูนิตที่ต้องการ (Rarity)")
local RarityDropdown1 = FilterTab:AddDropdown("Rarities1", {
    Title = "ระดับ 1 (Rarity 1)",
    Description = "เลือกระดับที่ต้องการ 1",
    Values = RarityValues,
    Multi = true,
    Default = selectedToList(SelectedRarities, RarityValues),
})

local MutationDropdown1 = FilterTab:AddDropdown("Mutations1", {
    Title = "บัพ 1 (Mutation 1)",
    Description = "เลือกบัพที่ต้องการ 1",
    Values = MutationValues,
    Multi = true,
    Default = selectedToList(SelectedMutations, MutationValues),
})

local RarityDropdown2 = FilterTab:AddDropdown("Rarities2", {
    Title = "ระดับ 2 (Rarity 2)",
    Description = "เลือกระดับที่ต้องการ 2",
    Values = RarityValues,
    Multi = true,
    Default = selectedToList(SelectedRarities2, RarityValues),
})

local MutationDropdown2 = FilterTab:AddDropdown("Mutations2", {
    Title = "บัพ 2 (Mutation 2)",
    Description = "เลือกบัพที่ต้องการ 2",
    Values = MutationValues,
    Multi = true,
    Default = selectedToList(SelectedMutations2, MutationValues),
})
local Section = FilterTab:AddSection("เลือกชื่อยูนิตที่ต้องการ (Name)")
local NameDropdown3 = FilterTab:AddDropdown("Names3", {
    Title = "ชื่อ 1 (Name 1)",
    Description = "เลือกชื่อที่ต้องการ 1",
    Values = CharacterValues,
    Multi = true,
    Default = selectedToList(SelectedNames3, CharacterValues),
})

local MutationDropdown3 = FilterTab:AddDropdown("Mutations3", {
    Title = "บัพ 1 (Mutation 1)",
    Description = "เลือกบัพที่ต้องการ 1",
    Values = MutationValues,
    Multi = true,
    Default = selectedToList(SelectedMutations3, MutationValues),
})

local NameDropdown4 = FilterTab:AddDropdown("Names4", {
    Title = "ชื่อ 2 (Name 2)",
    Description = "เลือกชื่อที่ต้องการ 2",
    Values = CharacterValues,
    Multi = true,
    Default = selectedToList(SelectedNames4, CharacterValues),
})

local MutationDropdown4 = FilterTab:AddDropdown("Mutations4", {
    Title = "บัพ 2 (Mutation 2)",
    Description = "เลือกบัพที่ต้องการ 2",
    Values = MutationValues,
    Multi = true,
    Default = selectedToList(SelectedMutations4, MutationValues),
})

local Section = MainTab:AddSection("ระบบออโต้หลัก (Main Auto)")
local AutoBuyPlotToggle = MainTab:AddToggle("AutoBuyPlot", {
    Title = "ออโต้สุ่ม/ซื้อ (Auto Roll/Buy)",
    Description = "เปิดเพื่อเริ่มออโต้โรลและซื้อยูนิต",
    Default = AutoBuyPlotEnabled,
})
local RollDelaySlider = MainTab:AddSlider("RollDelay", {
    Title = "ดีเลย์การสุ่ม (Roll Delay)",
    Description = "ความเร็วการสุ่ม (วินาที) - แนะนำ 0.8s ขึ้นไปเพื่อลดปิง",
    Default = RollDelay,
    Min = 0.3,
    Max = 3.0,
    Rounding = 1,
})
local Section = MainTab:AddSection("ฟังชั่นอื่นๆ (Misc)")
local AutoSpinWheelToggle = MainTab:AddToggle("AutoSpinWheel", {
    Title = "ออโต้วงล้อ (Auto Spin Wheel)",
    Description = "สปินวงล้ออัตโนมัติเมื่อมีสิทธิ์",
    Default = AutoSpinWheelEnabled,
})

local AutoClaimBattlepassToggle = MainTab:AddToggle("AutoClaimBattlepass", {
    Title = "ออโต้รับแบทเทิลพาส (ฟรี)",
    Description = "รับของรางวัลแบทเทิลพาส (ฟรี) อัตโนมัติ",
    Default = AutoClaimBattlepassEnabled,
})

local AutoClaimPremiumBattlepassToggle = MainTab:AddToggle("AutoClaimPremiumBattlepass", {
    Title = "ออโต้รับแบทเทิลพาส (พรีเมียม)",
    Description = "รับของรางวัลแบทเทิลพาส (พรีเมียม) อัตโนมัติ",
    Default = AutoClaimPremiumBattlepassEnabled,
})



RarityDropdown1:OnChanged(function(value)
    SelectedRarities = normalizeMultiValue(value, RarityValues)
    rebuildTargetLookup()
    saveConfig()
end)

MutationDropdown1:OnChanged(function(value)
    SelectedMutations = normalizeMultiValue(value, MutationValues)
    rebuildTargetLookup()
    saveConfig()
end)

RarityDropdown2:OnChanged(function(value)
    SelectedRarities2 = normalizeMultiValue(value, RarityValues)
    rebuildTargetLookup()
    saveConfig()
end)

MutationDropdown2:OnChanged(function(value)
    SelectedMutations2 = normalizeMultiValue(value, MutationValues)
    rebuildTargetLookup()
    saveConfig()
end)

NameDropdown3:OnChanged(function(value)
    SelectedNames3 = normalizeMultiValue(value, CharacterValues)
    rebuildTargetLookup()
    saveConfig()
end)

MutationDropdown3:OnChanged(function(value)
    SelectedMutations3 = normalizeMultiValue(value, MutationValues)
    rebuildTargetLookup()
    saveConfig()
end)

NameDropdown4:OnChanged(function(value)
    SelectedNames4 = normalizeMultiValue(value, CharacterValues)
    rebuildTargetLookup()
    saveConfig()
end)

MutationDropdown4:OnChanged(function(value)
    SelectedMutations4 = normalizeMultiValue(value, MutationValues)
    rebuildTargetLookup()
    saveConfig()
end)

AutoBuyPlotToggle:OnChanged(function(value)
    AutoBuyPlotEnabled = value == true
    saveConfig()
end)

RollDelaySlider:OnChanged(function(value)
    RollDelay = tonumber(value) or 0.8
    saveConfig()
end)

AutoSpinWheelToggle:OnChanged(function(value)
    AutoSpinWheelEnabled = value == true
    saveConfig()
end)

AutoClaimBattlepassToggle:OnChanged(function(value)
    AutoClaimBattlepassEnabled = value == true
    saveConfig()
end)

AutoClaimPremiumBattlepassToggle:OnChanged(function(value)
    AutoClaimPremiumBattlepassEnabled = value == true
    saveConfig()
end)

RarityDropdown1:SetValue(selectedToList(SelectedRarities, RarityValues))
MutationDropdown1:SetValue(selectedToList(SelectedMutations, MutationValues))
RarityDropdown2:SetValue(selectedToList(SelectedRarities2, RarityValues))
MutationDropdown2:SetValue(selectedToList(SelectedMutations2, MutationValues))
NameDropdown3:SetValue(selectedToList(SelectedNames3, CharacterValues))
MutationDropdown3:SetValue(selectedToList(SelectedMutations3, MutationValues))
NameDropdown4:SetValue(selectedToList(SelectedNames4, CharacterValues))
MutationDropdown4:SetValue(selectedToList(SelectedMutations4, MutationValues))
AutoBuyPlotToggle:SetValue(AutoBuyPlotEnabled)
RollDelaySlider:SetValue(RollDelay)
AutoSpinWheelToggle:SetValue(AutoSpinWheelEnabled)
AutoClaimBattlepassToggle:SetValue(AutoClaimBattlepassEnabled)
AutoClaimPremiumBattlepassToggle:SetValue(AutoClaimPremiumBattlepassEnabled)
rebuildTargetLookup()

local function valuesSignature(values)
    return table.concat(values, "\31")
end

local raritySignature = valuesSignature(RarityValues)
local mutationSignature = valuesSignature(MutationValues)

local function refreshDynamicValues()
    local latestRarities = getRarityValues()
    local latestMutations = getMutationValues()
    local latestRaritySignature = valuesSignature(latestRarities)
    local latestMutationSignature = valuesSignature(latestMutations)

    if latestRaritySignature ~= raritySignature then
        raritySignature = latestRaritySignature
        RarityValues = latestRarities
        RarityDropdown1:SetValues(RarityValues)
        RarityDropdown2:SetValues(RarityValues)
        SelectedRarities = normalizeMultiValue(SelectedRarities, RarityValues)
        SelectedRarities2 = normalizeMultiValue(SelectedRarities2, RarityValues)
        RarityDropdown1:SetValue(selectedToList(SelectedRarities, RarityValues))
        RarityDropdown2:SetValue(selectedToList(SelectedRarities2, RarityValues))
        rebuildTargetLookup()
    end

    if latestMutationSignature ~= mutationSignature then
        mutationSignature = latestMutationSignature
        MutationValues = latestMutations
        MutationDropdown1:SetValues(MutationValues)
        MutationDropdown2:SetValues(MutationValues)
        MutationDropdown3:SetValues(MutationValues)
        MutationDropdown4:SetValues(MutationValues)
        SelectedMutations = normalizeMultiValue(SelectedMutations, MutationValues)
        SelectedMutations2 = normalizeMultiValue(SelectedMutations2, MutationValues)
        SelectedMutations3 = normalizeMultiValue(SelectedMutations3, MutationValues)
        SelectedMutations4 = normalizeMultiValue(SelectedMutations4, MutationValues)
        MutationDropdown1:SetValue(selectedToList(SelectedMutations, MutationValues))
        MutationDropdown2:SetValue(selectedToList(SelectedMutations2, MutationValues))
        MutationDropdown3:SetValue(selectedToList(SelectedMutations3, MutationValues))
        MutationDropdown4:SetValue(selectedToList(SelectedMutations4, MutationValues))
        rebuildTargetLookup()
    end
end

task.spawn(function()
    while task.wait(120) do
        refreshDynamicValues()
    end
end)

task.spawn(function()
    local label = playerGui
        :WaitForChild("MainUI")
        :WaitForChild("Frames")
        :WaitForChild("SpinWheel")
        :WaitForChild("Content")
        :WaitForChild("Buttons")
        :WaitForChild("Spin")
        :WaitForChild("Label")
    local remote = ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("SpinWheel")
        :WaitForChild("Spin")

    local running = false

    local function getSpinCount()
        local text = label.Text
        local num = tonumber(text:match("%((%d+)%)"))
        return num or 0
    end

    while task.wait(1) do
        if not AutoSpinWheelEnabled then
            running = false
            continue
        end

        local count = getSpinCount()

        if count > 0 then
            if not running then
                running = true
            end

            remote:FireServer("Spin")
            task.wait(2)
        else
            running = false
        end
    end
end)

task.spawn(function()
    local rewards = playerGui
        :WaitForChild("MainUI")
        :WaitForChild("Frames")
        :WaitForChild("Battlepass")
        :WaitForChild("Frame")
        :WaitForChild("Main")
        :WaitForChild("Battlepass")
        :WaitForChild("ScrollingFrame")
        :WaitForChild("Content")
        :WaitForChild("Rewards")

    local remote = ReplicatedStorage
        :WaitForChild("Modules")
        :WaitForChild("Battlepass")
        :WaitForChild("Claim")

    while task.wait(5) do
        if not AutoClaimBattlepassEnabled then
            continue
        end

        local index = 0

        for _, reward in pairs(rewards:GetChildren()) do
            if reward.Name == "BattlepassReward" then
                index += 1

                local free = reward:FindFirstChild("Free")

                if free then
                    local locked = free:FindFirstChild("Locked")
                    local checked = free:FindFirstChild("Checked")

                    if locked and checked and locked:IsA("GuiObject") and checked:IsA("GuiObject") then
                        if locked.Visible == false and checked.Visible == false then
                            remote:FireServer(index, "Free")
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    local rewards = playerGui
        :WaitForChild("MainUI")
        :WaitForChild("Frames")
        :WaitForChild("Battlepass")
        :WaitForChild("Frame")
        :WaitForChild("Main")
        :WaitForChild("Battlepass")
        :WaitForChild("ScrollingFrame")
        :WaitForChild("Content")
        :WaitForChild("Rewards")

    local remote = ReplicatedStorage
        :WaitForChild("Modules")
        :WaitForChild("Battlepass")
        :WaitForChild("Claim")

    while task.wait(5) do
        if not AutoClaimPremiumBattlepassEnabled then
            continue
        end

        local index = 0

        for _, reward in pairs(rewards:GetChildren()) do
            if reward.Name == "BattlepassReward" then
                index += 1

                local premium = reward:FindFirstChild("Premium")

                if premium then
                    local locked = premium:FindFirstChild("Locked")
                    local checked = premium:FindFirstChild("Checked")

                    if locked and checked and locked:IsA("GuiObject") and checked:IsA("GuiObject") then
                        if locked.Visible == false and checked.Visible == false then
                            remote:FireServer(index, "Premium")
                        end
                    end
                end
            end
        end
    end
end)

local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local plotsFolder = workspace:WaitForChild("Plots")

local cashLabel = playerGui
    :WaitForChild("MainUI")
    :WaitForChild("UILeft")
    :WaitForChild("TopButtons")
    :WaitForChild("Cash")
    :WaitForChild("CashLabel")

local state = {
    buying = false,
}

local function normalizeKey(value)
    local key = tostring(value or ""):lower():gsub("%s+", "")
    return key
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
        local chance = buyUI:FindFirstChild("Chance", true)
        if chance then return chance:FindFirstChildWhichIsA("TextLabel") end
    end
    return nil
end

local function getModelRarity(model)
    local label = getRarityLabel(model)
    local rarity = label and tostring(label.Text or ""):gsub("<.->", ""):match("^%s*(.-)%s*$") or ""

    if rarity == "" then
        return nil
    end

    rarity = rarity:match("^(%S+)") or rarity
    return rarity
end

local function getCharacterNameLabel(model)
    local head = model:FindFirstChild("Head")
    local buyUI = head and head:FindFirstChild("BuyUI")
    if buyUI then
        local nameFrame = buyUI:FindFirstChild("Name", true)
        if nameFrame then return nameFrame:FindFirstChildWhichIsA("TextLabel") end
    end
    return nil
end

local function getModelCharacterName(model)
    local label = getCharacterNameLabel(model)
    local characterName = label and tostring(label.Text or ""):gsub("<.->", ""):match("^%s*(.-)%s*$") or tostring(model.Name or "")

    if characterName == "" then
        return nil
    end

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
    if not mutation then
        return nil
    end

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
    if text:find("free", 1, true) then
        return 0
    end

    local numberText, suffix = text:match("([%d,%.]+)%s*([kmbtq]?)")

    if not numberText then
        return nil
    end

    local value = tonumber((numberText:gsub(",", "")))
    if not value then
        return nil
    end

    local scale = {
        k = 1e3,
        m = 1e6,
        b = 1e9,
        t = 1e12,
        q = 1e15,
    }

    return value * (scale[suffix] or 1)
end

local function readCash()
    if not cashLabel then return 0 end
    return parseMoney(cashLabel.Text) or 0
end

local function getPriceLabel(model)
    local head = model:FindFirstChild("Head")
    local buyUI = head and head:FindFirstChild("BuyUI")
    if buyUI then
        local price = buyUI:FindFirstChild("Price", true)
        if price then return price:FindFirstChildWhichIsA("TextLabel") end
    end
    return nil
end

local function findPrompt(root)
    if not root then return nil end
    local head = root:FindFirstChild("Head")
    local buyUI = head and head:FindFirstChild("BuyUI")
    if buyUI then
        return buyUI:FindFirstChildWhichIsA("ProximityPrompt", true) or root:FindFirstChildWhichIsA("ProximityPrompt", true)
    end
    return root:FindFirstChildWhichIsA("ProximityPrompt", true)
end

local function getFullName(inst)
    local ok, name = pcall(function()
        return inst:GetFullName()
    end)

    return ok and name or tostring(inst)
end

local function firePrompt(prompt)
    if not prompt then
        return false
    end

    return pcall(function()
        fireproximityprompt(prompt)
    end)
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

        local ok, pivot = pcall(function()
            return plot:GetPivot()
        end)

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
                    local entry = {
                        model = inst,
                        characterName = characterName,
                        mutation = mutation,
                        targetIndex = targetIndex,
                        price = price,
                        priceLabel = priceLabel,
                        prompt = prompt,
                    }

                    table.insert(candidates, entry)
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

local myPlot = getBestPlot()

if myPlot then
    task.spawn(function()
        while task.wait(0.35) do
            if not AutoBuyPlotEnabled then
                continue
            end

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
                    task.wait(RollDelay)
                end
            end
        end
    end)
end



Setting:AddSection("จัดการระบบส่วนหลัง (System Config)")

SaveManager:LoadAutoloadConfig()
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Setting)
SaveManager:BuildConfigSection(Setting)

if Fluent.Options and Fluent.Options.MenuKeybind then
    Fluent.Options.MenuKeybind:SetValue("K")
end

task.spawn(function()
    local translations = {
        ["Config name"] = "ชื่อคอนฟิก",
        ["Config list"] = "รายการคอนฟิก",
        ["Create config"] = "สร้างคอนฟิก",
        ["Load config"] = "โหลดคอนฟิก",
        ["Overwrite config"] = "บันทึกทับคอนฟิก",
        ["Refresh list"] = "รีเฟรชรายการ",
        ["Set as autoload"] = "ตั้งเป็นออโต้โหลด",
        ["Menu bind"] = "ปุ่มซ่อน/แสดงเมนู",
        ["Interface theme"] = "ธีมหน้าต่าง (Theme)",
        ["Acrylic toggle"] = "พื้นหลังโปร่งใส (Acrylic)",
        ["Transparent toggle"] = "ไม่มีพื้นหลัง (Transparent)",
        ["Settings"] = "ตั้งค่า",
        ["Interface"] = "การปรับแต่ง UI",
        ["Configuration"] = "จัดการคอนฟิก",
    }
    task.wait(2)
    local targetGui = nil
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:find("Fluent") or gui.Name:find("ScreenGui")) then
            targetGui = gui
            break
        end
    end
    
    if targetGui then
        for i = 1, 5 do
            for _, v in ipairs(targetGui:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextButton") then
                    if translations[v.Text] then
                        v.Text = translations[v.Text]
                    end
                    if v.Text:match("^Current autoload config:") then
                        local configName = v.Text:gsub("Current autoload config: ", "")
                        if configName == "none" then configName = "ไม่มี" end
                        v.Text = "คอนฟิกออโต้โหลดปัจจุบัน: " .. configName
                    end
                end
            end
            task.wait(1)
        end
    end
end)
Window:SelectTab(1)

Fluent:Notify({
    Title = "PayomboyZ HUB",
    Content = "โหลดสคริปต์สำเร็จ! ขอให้สนุกนะ ❤️",
    SubContent = "เปิดใช้งานโหมดธีม Rose (Red Theme) 🌹",
    Duration = 8
})

return myPlot

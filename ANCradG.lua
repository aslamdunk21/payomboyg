-- [[ PayomboyZ - Anime Card Farm Script (Full Compatibility & Fixed Config) ]]
-- Theme: Crimson Red / Dark Elegance (Fluent UI)
-- Controls: [K] Toggle UI Visibility | [F] Toggle UI Scale | Mobile Floating Button

local Fluent = nil
local s, r = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if s and r then
    Fluent = r
else
    Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/main.lua"))()
end

local SaveManager = nil
local s2, r2 = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
end)
if s2 and r2 then SaveManager = r2 end

local InterfaceManager = nil
local s3, r3 = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)
if s3 and r3 then InterfaceManager = r3 end

local UserInputService = game:GetService("UserInputService")
local isMobileDevice = UserInputService.TouchEnabled or not UserInputService.KeyboardEnabled
local defaultWindowSize = isMobileDevice and UDim2.fromOffset(340, 260) or UDim2.fromOffset(540, 390)
local defaultTabWidth = isMobileDevice and 90 or 145

local Window = Fluent:CreateWindow({
    Title = "PayomboyZ",
    SubTitle = "โดย Dexq | Anime Card Farm",
    TabWidth = defaultTabWidth,
    Size = defaultWindowSize,
    Acrylic = false,
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.K
})

local Tabs = {
    Main = Window:AddTab({ Title = "หลัก", Icon = "home" }),
    Reroll = Window:AddTab({ Title = "รีโรล", Icon = "refresh-cw" }),
    Potion = Window:AddTab({ Title = "น้ำยา", Icon = "flask-conical" }),
    Raid = Window:AddTab({ Title = "เรด & ทาวเวอร์", Icon = "swords" }),
    Trade = Window:AddTab({ Title = "แลกเปลี่ยน", Icon = "arrow-left-right" }),
    FPS = Window:AddTab({ Title = "ลด FPS", Icon = "monitor-off" }),
    Dashboard = Window:AddTab({ Title = "แดชบอร์ด", Icon = "sliders" }),
    Settings = Window:AddTab({ Title = "ตั้งค่าระบบ", Icon = "settings" })
}

local Options = Fluent.Options

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
    "Dynasty", "Grail", "Conquest", "Blaze", "Devour", "Raven", "Arcane", "Nightfall", "Limited"
}

local MutationsList = {
    "Normal", "Golden", "Diamond", "Venomous", "Rainbow", "Sakura", "Candy",
    "Blessed", "Radioactive", "Glitch", "Starfallen", "Admin", "Unknow"
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
                for _, rName in ipairs({"common", "uncommon", "rare", "epic", "legendary", "mythical", "secret", "godly", "admin", "grail", "blaze", "conquest", "devour"}) do
                    if cl:find(rName) then
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
            if getgenv().InsufficientFundsAction == "หยุดสายพาน" then
                getgenv().AutoSpawnPack = false
                if Options and Options.AutoSpawnPack then Options.AutoSpawnPack:SetValue(false) end
                Fluent:Notify({ Title = "แจ้งเตือน", Content = "ซื้อการ์ดไม่สำเร็จ (เงินอาจไม่พอ) หยุดสายพานแล้ว", Duration = 5 })
            end
            model:SetAttribute("Rejected", true)
            continue
        end

        local cardRarity, cardMutation = getCardModelRarityAndMutation(model)

        local matchRarity = (next(getgenv().SelectedRarities) == nil) or (cardRarity ~= "" and getgenv().SelectedRarities[string.lower(cardRarity)] == true)
        local matchMutation = (next(getgenv().SelectedMutations) == nil) or (cardMutation ~= "" and getgenv().SelectedMutations[string.lower(cardMutation)] == true)

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

getgenv().InsufficientFundsAction = getgenv().InsufficientFundsAction or "ข้าม"
local FundsActionDropdown = Tabs.Main:AddDropdown("InsufficientFundsAction", {
    Title = "💰 เมื่อเจอการ์ดซื้อเงินไม่พอซื้อ",
    Values = {"ข้าม", "หยุดสายพาน"},
    Multi = false,
    Default = getgenv().InsufficientFundsAction
})
FundsActionDropdown:OnChanged(function(Value)
    getgenv().InsufficientFundsAction = Value
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
                    getgenv().PauseReroll = true
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
                                prompt.MaxActivationDistance = 99999
                                
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
                    getgenv().PauseReroll = false
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
        if suffix == "UD" then mult = 1e36
        elseif suffix == "DC" then mult = 1e33
        elseif suffix == "NO" or suffix == "N" then mult = 1e30
        elseif suffix == "OC" or suffix == "O" then mult = 1e27
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

local function getUnifiedCardScore(item)
    if not item then return 0 end
    local cashScore, rarityScore, mutationScore = 0, 0, 0
    
    local function parseScoreFromText(txt)
        local val = parseSuffixValue(txt)
        if val > cashScore then cashScore = val end
        local s = getRarityScore(txt)
        if s > rarityScore then rarityScore = s end
        local cleanMut = string.lower(string.gsub(txt, "<[^>]+>", ""))
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

    for _, txtObj in ipairs(item:GetDescendants()) do
        if (txtObj:IsA("TextLabel") or txtObj:IsA("TextButton")) and txtObj.Text then
            parseScoreFromText(txtObj.Text)
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

local function collect4BestBaseCards()
    pcall(function()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local allCards = {}
        
        local function scanInv(container)
            if not container then return end
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") and not isPackCard(t) then
                    local score = getUnifiedCardScore(t)
                    table.insert(allCards, { item = t, score = score, source = "Inv", uuid = t.Name })
                end
            end
        end
        scanInv(LocalPlayer:FindFirstChild("Backpack"))
        scanInv(character)

        if getgenv().TowerCardSource ~= "จากในกระเป๋า (Inventory)" then
            local plotFolder = findPlayerPlot()
            if plotFolder then
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
                                if not isPack then
                                    local score = getUnifiedCardScore(model)
                                    if score > 0 and not string.find(string.upper(model.Name or ""), "PLOT") then
                                        table.insert(allCards, { item = model, score = score, source = "Plot", interact = desc })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if #allCards == 0 then return end
        table.sort(allCards, function(a, b) return a.score > b.score end)

        local originalCFrame = hrp.CFrame
        getgenv().CollectedCardPositions = {}

        for i = 1, math.min(4, #allCards) do
            local card = allCards[i]
            if card.source == "Plot" and card.interact and card.interact.Parent then
                pcall(function()
                    local targetPos
                    if card.interact.Parent:IsA("BasePart") then
                        targetPos = card.interact.Parent.Position
                    elseif card.interact.Parent:IsA("Attachment") then
                        targetPos = card.interact.Parent.WorldPosition
                    elseif card.item and card.item.PrimaryPart then
                        targetPos = card.item.PrimaryPart.Position
                    end
                    
                    if targetPos and hrp then
                        table.insert(getgenv().CollectedCardPositions, { pos = targetPos, score = card.score, assumedName = card.item.Name })
                        hrp.CFrame = CFrame.new(targetPos) + Vector3.new(0, 2, 0)
                        task.wait(0.8)
                        
                        if card.interact:IsA("ProximityPrompt") then
                            card.interact.RequiresLineOfSight = false
                            card.interact.MaxActivationDistance = 99999
                            card.interact.HoldDuration = 0
                            for _ = 1, 5 do
                                if not card.interact or not card.interact.Parent then break end
                                fireproximityprompt(card.interact)
                                task.wait(0.3)
                            end
                        elseif card.interact:IsA("ClickDetector") then
                            for _ = 1, 5 do
                                fireclickdetector(card.interact)
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
        local collected = getgenv().CollectedCardPositions
        if not collected or #collected == 0 then return end

        local startCF = LocalPlayer.Character and LocalPlayer.Character:GetPivot()

        for _, record in ipairs(collected) do
            pcall(function()
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if not hrp or not humanoid then return end

                local tool
                local bestScoreMatch = -1
                
                local function checkContainer(container)
                    if not container then return end
                    for _, t in ipairs(container:GetChildren()) do
                        if t:IsA("Tool") and not isPackCard(t) then
                            local s = getUnifiedCardScore(t)
                            if s == record.score or t.Name == record.assumedName then
                                tool = t
                                bestScoreMatch = s
                                if s == record.score then return true end
                            end
                        end
                    end
                    return false
                end
                
                if not checkContainer(LocalPlayer:FindFirstChild("Backpack")) then
                    checkContainer(character)
                end
                
                if not tool then
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    if backpack then
                        for _, t in ipairs(backpack:GetChildren()) do
                            if t:IsA("Tool") and not isPackCard(t) then tool = t break end
                        end
                    end
                end

                if tool then
                    humanoid:EquipTool(tool)
                    task.wait(1.0)
                else
                    return
                end

                hrp.CFrame = CFrame.new(record.pos) + Vector3.new(0, 2, 0)
                task.wait(0.8)

                local plotFolder = findPlayerPlot()
                if plotFolder then
                    for _, desc in ipairs(plotFolder:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") or desc:IsA("ClickDetector") then
                            local descPos
                            if desc.Parent:IsA("BasePart") then descPos = desc.Parent.Position
                            elseif desc.Parent:IsA("Attachment") then descPos = desc.Parent.WorldPosition end
                            
                            if descPos and (descPos - record.pos).Magnitude < 5 then
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

local function getMinutesToNextBoss()
    local min = tonumber(os.date("!%M"))
    if min >= 58 or min <= 5 then return 0 end
    return 60 - min
end

local function isBossTimeWindow()
    local min = tonumber(os.date("!%M"))
    return min <= 5 or min >= 58
end


-- UI Component Setup

getgenv().TowerCardSource = getgenv().TowerCardSource or "จากบนฐาน (Plot)"
local TowerSourceDropdown = Tabs.Raid:AddDropdown("TowerCardSource", {
    Title = "แหล่งที่มาของการ์ดหอคอย",
    Values = {"จากบนฐาน (Plot)", "จากในกระเป๋า (Inventory)"},
    Multi = false,
    Default = getgenv().TowerCardSource
})
TowerSourceDropdown:OnChanged(function(Value)
    getgenv().TowerCardSource = Value
end)

local AutoTowerToggle = Tabs.Raid:AddToggle("AutoTower", { Title = "🏰 ลงหอคอยอัตโนมัติ (Auto Tower)", Default = false })
AutoTowerToggle:OnChanged(function(state)
    getgenv().AutoTower = state
    if not state then
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
        task.spawn(function()
            while getgenv().AutoTower do
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local equipBtn, battleBtn, nextBtn, playBtn, openBtn, autoReplayBtn, hideBattleBtn, showBattleBtn
                    local function isGuiVisible(gui)
                        if not gui or (gui:IsA("GuiObject") and not gui.Visible) then return false end
                        local current = gui.Parent
                        while current and current:IsA("GuiObject") do
                            if not current.Visible then return false end
                            current = current.Parent
                        end
                        return not (current and current:IsA("ScreenGui")) or current.Enabled
                    end
                    
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
                        if not getgenv().TowerHasCollected then
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
                task.wait(0.2)
            end
        end)
    end
end)

local BossDiffDropdown = Tabs.Raid:AddDropdown("BossRaidDifficulty", {
    Title = "⚔️ ระดับความยากบอสเรด",
    Values = { "EASY", "MEDIUM", "HARD", "NIGHTMARE" },
    Multi = false,
    Default = "NIGHTMARE"
})
BossDiffDropdown:OnChanged(function(Value)
    getgenv().BossRaidDifficulty = Value
end)

local AutoBossToggle = Tabs.Raid:AddToggle("AutoBossRaid", { Title = "🐉 ลงบอสเรดอัตโนมัติ (Auto Boss Raid)", Default = false })
AutoBossToggle:OnChanged(function(state)
    getgenv().AutoBossRaid = state
    if state then
        getgenv().AutoTower = false
        if Options and Options.AutoTower then Options.AutoTower:SetValue(false) end
        
        task.spawn(function()
            while getgenv().AutoBossRaid do
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local equipBtn, battleBtn, diffBtn, autoReplayBtn, showBattleBtn, hideBattleBtn, nextBtn, playBtn
                    local alreadyFought = false

                    local function isGuiVisible(gui)
                        if not gui or (gui:IsA("GuiObject") and not gui.Visible) then return false end
                        local current = gui.Parent
                        while current and current:IsA("GuiObject") do
                            if not current.Visible then return false end
                            current = current.Parent
                        end
                        return not (current and current:IsA("ScreenGui")) or current.Enabled
                    end

                    for _, v in ipairs(playerGui:GetDescendants()) do
                        if (v:IsA("TextButton") or v:IsA("TextLabel")) and v.Text then
                            local cleanText = string.gsub(v.Text, "<[^>]+>", "")
                            local text = string.upper(string.match(cleanText, "^%s*(.-)%s*$") or "")
                            
                            if string.find(text, "ALREADY FOUGHT THE BOSS") and isGuiVisible(v) then
                                alreadyFought = true
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

                            if (text == "EQUIP BEST" or text == "สวมใส่ดีที่สุด" or text == "สวมใส่ที่ดีที่สุด") and not isInventoryBtn then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then equipBtn = btn end
                            elseif text == "BATTLE" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then battleBtn = btn end
                            elseif text == getgenv().BossRaidDifficulty then
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
                            elseif text == "NEXT" or text == "NEXT FLOOR" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then nextBtn = btn end
                            elseif text == "PLAY" then
                                local btn = v:IsA("TextButton") and v or v:FindFirstAncestorWhichIsA("TextButton") or v:FindFirstAncestorWhichIsA("ImageButton")
                                if btn and isGuiVisible(btn) then playBtn = btn end
                            end
                        end
                    end

                    if alreadyFought then
                        getgenv().AutoBossRaid = false
                        if Options and Options.AutoBossRaid then Options.AutoBossRaid:SetValue(false) end
                        Fluent:Notify({ Title = "บอสเรด", Content = "คุณสู้บอสไปแล้วในชั่วโมงนี้! หยุดลงบอสเรด", Duration = 5 })
                        local character = LocalPlayer.Character
                        if getgenv().BossOriginalCFrame and character then
                            character:PivotTo(getgenv().BossOriginalCFrame)
                            getgenv().BossOriginalCFrame = nil
                        end
                        break
                    end

                    local inBattle = equipBtn or battleBtn or autoReplayBtn or showBattleBtn
                    if not inBattle and isBossTimeWindow() then
                        local bossPrompt, portalPrompt
                        for _, p in ipairs(workspace:GetDescendants()) do
                            if p:IsA("ProximityPrompt") then
                                local pText = string.upper(p.ActionText .. " " .. p.ObjectText .. " " .. (p.Parent and p.Parent.Name or "") .. " " .. p.Name)
                                if (string.find(pText, "BOSS RAID") or string.find(pText, "BOSS")) and string.find(pText, "TELEPORT") then
                                    portalPrompt = p
                                elseif not string.find(pText, "SHOP") and not string.find(pText, "RETURN") and not string.find(pText, "BACK") then
                                    if string.find(pText, "TITAN") or string.find(pText, "BOSS") or string.find(pText, "RAID") or string.find(pText, "FIGHT") or string.find(pText, "ENTER") then
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
                                    if targetPos then
                                        if (hrp.Position - targetPos).Magnitude > 15 then
                                            if not getgenv().BossOriginalCFrame then
                                                getgenv().BossOriginalCFrame = character:GetPivot()
                                            end
                                            character:PivotTo(CFrame.new(targetPos) + Vector3.new(0, 3, 0))
                                            task.wait(0.1)
                                        end
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
                        task.wait(0.2)
                        local character = LocalPlayer.Character
                        if getgenv().BossOriginalCFrame and character then
                            character:PivotTo(getgenv().BossOriginalCFrame)
                            getgenv().BossOriginalCFrame = nil
                        end
                    end

                    if autoReplayBtn then
                        local color = autoReplayBtn.BackgroundColor3
                        if autoReplayBtn.BackgroundTransparency > 0.5 and autoReplayBtn.Parent and autoReplayBtn.Parent:IsA("GuiObject") then
                            color = autoReplayBtn.Parent.BackgroundColor3
                        end
                        if autoReplayBtn:IsA("ImageButton") and autoReplayBtn.ImageColor3 ~= Color3.new(1, 1, 1) then
                            color = autoReplayBtn.ImageColor3
                        end
                        local isGreen = (color.G > color.R + 0.1)
                        if isGreen then
                            getgenv().AutoReplayToggledBoss = true
                        elseif not getgenv().AutoReplayToggledBoss then
                            fireButton(autoReplayBtn)
                            getgenv().AutoReplayToggledBoss = true
                            task.wait(0.2)
                        end
                    end

                    if not (autoReplayBtn or showBattleBtn or hideBattleBtn) then
                        getgenv().AutoReplayToggledBoss = false
                    end

                    if autoReplayBtn or showBattleBtn then
                        local character = LocalPlayer.Character
                        if getgenv().BossOriginalCFrame and character then
                            character:PivotTo(getgenv().BossOriginalCFrame)
                            getgenv().BossOriginalCFrame = nil
                        end
                    end

                    if hideBattleBtn then fireButton(hideBattleBtn) task.wait(0.2) end
                    if nextBtn then fireButton(nextBtn) task.wait(0.2) end
                    if playBtn then fireButton(playBtn) task.wait(0.2) end
                end
                task.wait(0.2)
            end
        end)
    else
        local character = LocalPlayer.Character
        if getgenv().BossOriginalCFrame and character then
            character:PivotTo(getgenv().BossOriginalCFrame)
            getgenv().BossOriginalCFrame = nil
        end
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
        InsufficientFundsAction = getgenv().InsufficientFundsAction or "ข้าม",
        FPSCap = getgenv().FPSCap or "ไม่จำกัด (Max)",
        AFKMode = getgenv().AFKMode or false,
        DisableVisualEffects = getgenv().DisableVisualEffects or false,
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
            getgenv().InsufficientFundsAction = data.InsufficientFundsAction or "ข้าม"
            getgenv().FPSCap = data.FPSCap or "ไม่จำกัด (Max)"
            getgenv().AFKMode = data.AFKMode or false
            getgenv().DisableVisualEffects = data.DisableVisualEffects or false

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
            safeSetToggle("AFKModeWhiteScreen", data.AFKMode)
            safeSetToggle("DisableVisualEffects", data.DisableVisualEffects)

            if Options.AutoCarryDelay and data.AutoCarryDelay then pcall(function() Options.AutoCarryDelay:SetValue(tonumber(data.AutoCarryDelay)) end) end
            if Options.RerollSpeed and data.RerollSpeed then pcall(function() Options.RerollSpeed:SetValue(tonumber(data.RerollSpeed)) end) end
            if Options.BossRaidDifficulty and data.BossRaidDifficulty then pcall(function() Options.BossRaidDifficulty:SetValue(tostring(data.BossRaidDifficulty)) end) end
            if Options.DiscordWebhook and data.Webhook then pcall(function() Options.DiscordWebhook:SetValue(tostring(data.Webhook)) end) end
            if Options.InsufficientFundsAction and data.InsufficientFundsAction then pcall(function() Options.InsufficientFundsAction:SetValue(tostring(data.InsufficientFundsAction)) end) end
            if Options.FPSCapLimit and data.FPSCap then pcall(function() Options.FPSCapLimit:SetValue(tostring(data.FPSCap)) end) end

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
-- FPS OPTIMIZATION & PERFORMANCE
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
    Default = (ConfigData.AFKMode == true) or false
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
            originalStates = {} -- Clear memory
            Fluent:Notify({ Title = "ลด FPS", Content = "ปิดโหมดภาพกาก (คืนค่าเดิม)", Duration = 3 })
        end
    end)
end)

local DisableEffectsToggle = Tabs.FPS:AddToggle("DisableVisualEffects", {
    Title = "✨ ปิดเอฟเฟกต์ทั้งหมด (Disable Effects)",
    Description = "ปิดการแสดงผล Particle, Beam, Trail ถาวรขณะเปิด",
    Default = false
})

DisableEffectsToggle:OnChanged(function(state)
    getgenv().DisableVisualEffects = state
end)

task.spawn(function()
    while task.wait(5) do
        if getgenv().DisableVisualEffects then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                        v.Enabled = false
                    end
                end
            end)
        end
    end
end)


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
    toggleWrapper.Size = UDim2.new(0, 180, 0, 50) -- ขยายให้กว้างขึ้นเพื่อใส่ชื่อ, FPS และ Ping
    toggleWrapper.Position = UDim2.new(0, 15, 0.35, 0)
    toggleWrapper.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    toggleWrapper.Text = "" -- ไม่แสดงข้อความของปุ่มหลัก
    toggleWrapper.AutoButtonColor = false
    toggleWrapper.Active = true
    toggleWrapper.Draggable = true
    toggleWrapper.Parent = mobileGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 25) -- ขอบมนแบบแคปซูล
    corner.Parent = toggleWrapper

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 180, 80)
    stroke.Thickness = 2
    stroke.Parent = toggleWrapper

    -- ภาพ Avatar ซ้ายมือ
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.new(0, 40, 0, 40)
    avatarImg.Position = UDim2.new(0, 5, 0, 5)
    avatarImg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    local customImagePath = "543199739_2812856088914181_3062917809445648175_n.jpg"
    if isfile and isfile(customImagePath) and getcustomasset then
        avatarImg.Image = getcustomasset(customImagePath)
    else
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    end
    avatarImg.Parent = toggleWrapper

    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0) -- ทำให้รูปกลม
    avCorner.Parent = avatarImg

    -- ป้ายชื่อ (Title)
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

    -- ป้าย FPS & Ping (เท่ๆ)
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

    -- ระบบนับ FPS & Ping (ทำงานพื้นหลัง)
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local frames = 0
    local timer = 0
    RunService.RenderStepped:Connect(function(dt)
        frames = frames + 1
        timer = timer + dt
        if timer >= 1 then
            local currentFps = math.floor(frames / timer)
            
            local pingValue = 0
            pcall(function()
                pingValue = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            
            fpsLabel.Text = "FPS: " .. tostring(currentFps) .. " • Ping: " .. tostring(pingValue) .. "ms"
            
            -- ไล่สีตามความลื่นไหล
            if currentFps >= 50 and pingValue < 150 then
                fpsLabel.TextColor3 = Color3.fromRGB(80, 255, 120) -- เขียว
            elseif currentFps >= 30 and pingValue < 300 then
                fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 50) -- เหลือง
            else
                fpsLabel.TextColor3 = Color3.fromRGB(255, 80, 80) -- แดง
            end
            
            frames = 0
            timer = 0
        end
    end)

    toggleWrapper.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)
end)

-- Profile Box removed as requested because Toggle now acts as the profile.

-- Hand the library over to our managers (SaveManager & InterfaceManager)
if SaveManager and InterfaceManager then
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)

    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({"SelectedRerollCard", "SelectedRankCard", "SelectedTradePlayer", "SelectedTradeCards", "ConfigNameInput"})

    InterfaceManager:SetFolder("PayomboyZ_Config")
    SaveManager:SetFolder("PayomboyZ_Config/AnimeCardFarm")

    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    Window:SelectTab(1)

    Fluent:Notify({
        Title = "PayomboyZ",
        Content = "สคริปต์ PayomboyZ โหลดเรียบร้อยแล้ว! ✅",
        Duration = 8
    })

    SaveManager:LoadAutoloadConfig()
elseif InterfaceManager then
    InterfaceManager:SetLibrary(Fluent)
    InterfaceManager:SetFolder("PayomboyZ_Config")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)

    Window:SelectTab(1)

    Fluent:Notify({
        Title = "PayomboyZ",
        Content = "สคริปต์ PayomboyZ โหลดเรียบร้อยแล้ว! ✅",
        Duration = 8
    })
else
    Window:SelectTab(1)

    Fluent:Notify({
        Title = "PayomboyZ",
        Content = "สคริปต์ PayomboyZ โหลดเรียบร้อยแล้ว! ✅",
        Duration = 8
    })
end

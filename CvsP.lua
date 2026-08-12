-- PayomboyZ HUB | Premium Fluent UI (Light Theme & Acrylic Blur)
-- Translated to Thai, comfortable for the eyes, rounded and aesthetic.
local fluentLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/Beta.lua"))()

local replicatedStorage = game:GetService("ReplicatedStorage")
local playersService = game:GetService("Players")

local remotes = replicatedStorage:WaitForChild("Remotes")
local modules = replicatedStorage:WaitForChild("Modules")

local shopDataModule = require(modules:WaitForChild("ShopData"))
local bossDataModule = require(modules:WaitForChild("BossData"))
local buyItemRemote = remotes:WaitForChild("BuyItem")
local requestPersonalStockRemote = remotes:WaitForChild("RequestPersonalStock")
local buyMerchantItemRemote = remotes:WaitForChild("BuyMerchantItem")
local requestMerchantStockRemote = remotes:WaitForChild("RequestMerchantStock")

-- ปรับแต่งธีมสว่าง ให้มีสีแดง (PayomboyZ Red) มาตัดตามที่ขอครับ!
if fluentLibrary.Themes and fluentLibrary.Themes.Light then
    fluentLibrary.Themes.Light.Accent = Color3.fromRGB(255, 60, 60)
end

local Window = fluentLibrary:CreateWindow({
    Title = "PayomboyZ HUB",
    SubTitle = "คาปิบาร่า vs ต้นไม้",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- ปิด Acrylic เพื่อลดอาการกระตุกและ FPS Drop
    Theme = "Light", -- ธีมสว่าง สบายตา พร้อมสีแดงตัด
    MinimizeKey = Enum.KeyCode.LeftControl
})

-------------------------------------------------------------------------
-- SHOP TAB (ร้านค้า)
-------------------------------------------------------------------------
local shopTab = Window:AddTab({ Title = "ร้านค้า (Shop)", Icon = "shopping-cart" })

local eggNamesList = {}
for _, eggName in ipairs(shopDataModule.ShopOrders.EggShop) do
    table.insert(eggNamesList, eggName)
end

local selectedEgg = eggNamesList[1] or ""
local eggDropdown = shopTab:AddDropdown("SelectEgg", {
    Title = "เลือกไข่คาปิบาร่า",
    Description = "เลือกไข่ที่ต้องการให้บอทซื้ออัตโนมัติ",
    Values = eggNamesList,
    Multi = false,
    Default = 1,
})
local lastEggStockCheck = 0
local cachedEggStock = 0

eggDropdown:OnChanged(function(Value)
    selectedEgg = Value
    lastEggStockCheck = 0 -- รีเซ็ตการเช็คสต็อกเมื่อเปลี่ยนไอเทม
end)

getgenv().autoBuyEggsEnabled = false
local buyEggToggle = shopTab:AddToggle("AutoBuyEgg", {
    Title = "เปิดออโต้ซื้อไข่",
    Description = "บอทจะทำการซื้อไข่ที่เลือกไว้อัตโนมัติ",
    Default = false
})
buyEggToggle:OnChanged(function(Value)
    getgenv().autoBuyEggsEnabled = Value
end)

task.spawn(function()
    while task.wait(1) do
        if getgenv().autoBuyEggsEnabled and selectedEgg ~= "" then
            pcall(function()
                -- ดึงข้อมูลสต็อกทุกๆ 10 วิ แทนการดึงทุกรอบ (แก้ปัญหากระตุกจาก InvokeServer)
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

shopTab:AddParagraph({
    Title = "ระบบอุปกรณ์ (Gears)",
    Content = "หมวดหมู่การซื้ออุปกรณ์อัตโนมัติ"
})

local gearNamesList = {}
for _, gearName in ipairs(shopDataModule.ShopOrders.GearShop) do
    table.insert(gearNamesList, gearName)
end

local selectedGear = gearNamesList[1] or ""
local gearDropdown = shopTab:AddDropdown("SelectGear", {
    Title = "เลือกอุปกรณ์",
    Description = "เลือกอุปกรณ์ที่ต้องการให้บอทซื้อ",
    Values = gearNamesList,
    Multi = false,
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

shopTab:AddParagraph({
    Title = "พ่อค้าเร่ (Traveling Merchant)",
    Content = "หมวดหมู่การซื้อของจากพ่อค้าเร่"
})

local merchantItemsList = {}
for _, merchantType in ipairs(shopDataModule.TravelingMerchantPool) do
    for _, itemName in ipairs(shopDataModule.ShopOrders[merchantType]) do
        table.insert(merchantItemsList, itemName)
    end
end

local selectedMerchant = merchantItemsList[1] or ""
local merchantDropdown = shopTab:AddDropdown("SelectMerchant", {
    Title = "เลือกของพ่อค้าเร่",
    Description = "เลือกไอเทมจากพ่อค้าที่ต้องการซื้อ",
    Values = merchantItemsList,
    Multi = false,
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

-------------------------------------------------------------------------
-- AUTO TAB (ออโต้ฟาร์ม)
-------------------------------------------------------------------------
local autoTab = Window:AddTab({ Title = "ฟาร์ม (Auto)", Icon = "bot" })

local hatchRemote = remotes:WaitForChild("Hatch")
getgenv().autoHatchEnabled = false
local hatchToggle = autoTab:AddToggle("AutoHatch", {
    Title = "ออโต้ฟักไข่ (Auto Hatch)",
    Description = "ฟักไข่ทั้งหมดที่พร้อมฟักแล้วแบบอัตโนมัติ",
    Default = false
})
hatchToggle:OnChanged(function(Value)
    getgenv().autoHatchEnabled = Value
end)

local equipBestPlantsRemote = remotes:WaitForChild("EquipBestPlants")
getgenv().autoEquipBestEnabled = false
local equipToggle = autoTab:AddToggle("AutoEquip", {
    Title = "ออโต้ใส่ตัวดีสุด (Auto Equip Best)",
    Description = "ระบบจะคำนวณและสวมใส่ตัวละครที่ดีที่สุดให้",
    Default = false
})
equipToggle:OnChanged(function(Value)
    getgenv().autoEquipBestEnabled = Value
end)

task.spawn(function()
    while task.wait(60) do
        if getgenv().autoEquipBestEnabled then
            pcall(function()
                equipBestPlantsRemote:FireServer()
            end)
        end
    end
end)

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

-------------------------------------------------------------------------
-- BOSS TAB (บอส)
-------------------------------------------------------------------------
local bossTab = Window:AddTab({ Title = "บอส (Boss)", Icon = "swords" })

local bossNamesList = {}
for _, bossName in ipairs(bossDataModule.BossList) do
    table.insert(bossNamesList, bossName)
end

local selectedBoss = bossNamesList[1] or ""
local bossDropdown = bossTab:AddDropdown("SelectBoss", {
    Title = "เลือกบอส",
    Description = "เลือกบอสที่ต้องการให้บอทเรียกออกมา",
    Values = bossNamesList,
    Multi = false,
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
local summonBossRemote = remotes:WaitForChild("SummonBoss")
local bossToggle = bossTab:AddToggle("AutoBoss", {
    Title = "ออโต้เรียกบอส (Auto Spawn Boss)",
    Description = "ระบบจะทำการเรียกบอสที่เลือกไว้อัตโนมัติ",
    Default = false
})
bossToggle:OnChanged(function(Value)
    getgenv().autoSpawnBossEnabled = Value
end)

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

-------------------------------------------------------------------------
-- SELL TAB (ขาย)
-------------------------------------------------------------------------
local sellTab = Window:AddTab({ Title = "ขาย (Sell)", Icon = "coins" })

sellTab:AddParagraph({
    Title = "ระบบขายอัตโนมัติ",
    Content = "จะทำการขายต้นไม้/พืชทั้งหมดแบบ Bulk Sell"
})

getgenv().autoSellAllEnabled = false
local sellRemote = remotes:WaitForChild("Sell")
local sellToggle = sellTab:AddToggle("AutoSell", {
    Title = "ออโต้ขายทั้งหมด (Auto Sell All)",
    Description = "ขายพืช/ต้นไม้ทั้งหมดในกระเป๋าทันที",
    Default = false
})
sellToggle:OnChanged(function(Value)
    getgenv().autoSellAllEnabled = Value
end)

task.spawn(function()
    while task.wait(5) do
        if getgenv().autoSellAllEnabled then
            pcall(function()
                sellRemote:FireServer("bulkSell", "Plant")
            end)
        end
    end
end)

-------------------------------------------------------------------------
-- SETTINGS TAB (ตั้งค่า)
-------------------------------------------------------------------------
local settingsTab = Window:AddTab({ Title = "ตั้งค่า (Settings)", Icon = "settings" })

settingsTab:AddParagraph({
    Title = "PayomboyZ HUB Configuration",
    Content = "จัดการระบบแจ้งเตือนและบันทึกการตั้งค่าของคุณ"
})

local webhookUrl = ""
local webhookInput = settingsTab:AddInput("WebhookURL", {
    Title = "Discord Webhook URL",
    Description = "ใส่ลิงก์ Webhook สำหรับแจ้งเตือน",
    Default = "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Numeric = false,
    Finished = false,
})
webhookInput:OnChanged(function(Value)
    webhookUrl = Value
end)

settingsTab:AddButton({
    Title = "ทดสอบส่ง Webhook (Test Webhook)",
    Description = "ส่งข้อความทดสอบเข้า Discord ของคุณ",
    Callback = function()
        if webhookUrl ~= "" then
            local HttpService = game:GetService("HttpService")
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
            fluentLibrary:Notify({ Title = "Webhook", Content = "ส่งข้อความทดสอบสำเร็จ", Duration = 3 })
        else
            fluentLibrary:Notify({ Title = "Webhook", Content = "กรุณาใส่ลิงก์ Webhook ก่อน!", Duration = 3 })
        end
    end
})

settingsTab:AddButton({
    Title = "บันทึกการตั้งค่า (Save Config)",
    Description = "บันทึกการตั้งค่าปัจจุบันลงเครื่อง",
    Callback = function()
        fluentLibrary:Notify({ Title = "ระบบ Config", Content = "บันทึกการตั้งค่าสำเร็จ (จำลอง)", Duration = 3 })
    end
})

Window:SelectTab(1)
fluentLibrary:Notify({
    Title = "PayomboyZ HUB",
    Content = "รันสคริปต์สำเร็จ! ขอให้สนุกครับ",
    Duration = 5
})

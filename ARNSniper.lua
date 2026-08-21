-- ======================================================================================
-- [[ OBSIDIAN GLASSMORPHIC 2 UI ENGINE - LOGOUT SYSTEM TEMPLATE & SPECIFICATION ]]
-- ======================================================================================
-- ใช้เทมเพลตและพรอมต์นี้ในการติดตั้งระบบ Log out + ลบคีย์อัตโนมัติ + สั่งหยุดสคริปต์ที่กำลังรันอยู่!
-- ======================================================================================

-----------------------------------------------------------------------------------------
-- 📐 1. LOGOUT BUTTON UI SPECIFICATION (ข้อกำหนดปุ่มและตำแหน่ง)
-----------------------------------------------------------------------------------------
--[[
    Parent Container : userPanel (แถบ Sidebar ซ้ายมือ ถัดจากชื่อผู้ใช้)
    Position         : UDim2.new(1, -74, 0, 20)
    Size             : UDim2.fromOffset(62, 24)
    Background Color : COLORS.surfacePressed -- Color3.fromRGB(34, 14, 20) (Trans = 0.20)
    Corner Radius    : 6px
    Stroke Color     : COLORS.danger -- Color3.fromRGB(255, 60, 60) (Thickness = 1, Trans = 0.4)
    Text / Label     : "Log out" (GothamBold, Size 11, TextColor3 = COLORS.danger)
    Hover Animation  : Tween Background -> Danger Red (Trans 0.15), Stroke -> Trans 0, Text -> White (#FFFFFF)
    Click Audio      : playClickSound()
--]]

-----------------------------------------------------------------------------------------
-- 🔑 2. LOGOUT & KEY CLEARING & SCRIPT TERMINATION CODE (โค้ดลบคีย์และสั่งหยุดสคริปต์)
-----------------------------------------------------------------------------------------

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
    -- 1. เรียกใช้ฟังก์ชัน Cleanup หลักของสคริปต์ (ถ้านิยามไว้)
    if _G.GakuranCleanup then pcall(_G.GakuranCleanup) end
    if _G.ScriptCleanup then pcall(_G.ScriptCleanup) end
    if _G.PayomboyZCleanup then pcall(_G.PayomboyZCleanup) end

    -- 2. ปิดสวิตช์ฟังก์ชันทั้งหมดใน Options (ถ้ามี)
    if ObsidianGlassEngine and ObsidianGlassEngine.Options then
        for _, option in pairs(ObsidianGlassEngine.Options) do
            if type(option) == "table" and option.SetValue then
                pcall(function() option:SetValue(false) end)
            end
        end
    end
end

-- [โค้ดสร้างปุ่ม Logout ใน userPanel ของ Obsidian Glass Engine]
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

-- Hover Animation Effects
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

-- Click Handler (เมื่อกดปุ่ม Logout)
logoutBtn.MouseButton1Click:Connect(function()
    playClickSound()

    -- 1. สั่งหยุดการทำงานของสคริปต์ทั้งหมด (Terminate all script threads & loops)
    stopAllScriptOperations()

    -- 2. ลบคีย์ในเครื่องและล้างค่าตัวแปรในระบบ (พร้อมตั้งค่า Flag getgenv().PayomboyZ_LoggedOut = true)
    performLogoutKeyClear()

    -- 3. ทำลายหน้าจอ UI ปัจจุบัน
    if gui then
        pcall(function() gui:Destroy() end)
    end

    -- 4. โหลดสคริปต์กลับสู่หน้าเมนูหลัก (Start UI Redirection)
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/aslamdunk7/paypmboygang/refs/heads/main/Start"))()
    end)
end)


-----------------------------------------------------------------------------------------
-- 🤖 3. AI PROMPT TEMPLATE (พรอมต์สำหรับสั่ง AI ให้นำระบบ Logout ไปใส่ในสคริปต์แมพอื่น)
-----------------------------------------------------------------------------------------
--[[
    [ Copy พรอมต์ด้านล่างนี้เพื่อนำไปใช้งานกับ AI สำหรับแมพอื่นๆ ]

    "ช่วยเพิ่มระบบ Log out + ลบคีย์อัตโนมัติ + สั่งหยุดสคริปต์ที่กำลังทำงานอยู่ ลงในสคริปต์นี้ โดยสร้างปุ่มไว้ข้างๆ ชื่อผู้ใช้ใน UserPanel Sidebar
    - ปุ่มขนาด 62x24px กรอบสีแดง Danger (Color3.fromRGB(255, 60, 60)) แสดงข้อความคำว่า "Log out"
    - เมื่อกด Logout ให้ดำเนินการตามลำดับดังนี้:
      1. สั่งหยุดการทำงานของสคริปต์ที่กำลังใช้งานอยู่ทั้งหมดทันที (Disconnect Event Connections, Cancel Loops/Threads และปิด Toggle ทุกตัว)
      2. ลบไฟล์คีย์ในเครื่อง PayomboyZ_LuarmorKey.txt, PayomboyZ_VVIPKey.txt, PayomboyZ_SavedKey.txt (ใช้ delfile / deletefile)
      3. รีเซ็ตตัวแปรคีย์ getgenv().script_key, getrenv().script_key, getfenv().script_key, _G.script_key, shared.script_key, script_key เป็น nil
      4. ตั้งค่า Flag getgenv().PayomboyZ_LoggedOut = true เพื่อป้องกัน Start script Auto-Login จากคีย์ที่ค้างในตัวรันสคริปต์
      5. ทำลายหน้าจอ UI (Destroy GUI)
      6. โหลดสคริปต์กลับหน้าหลัก https://raw.githubusercontent.com/aslamdunk7/paypmboygang/refs/heads/main/Start"
--]]

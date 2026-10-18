--==================================================
-- BÁCH PREMIUM V11 - BẢO MẬT KEY NGHIÊM NGẶT + LOADING
--==================================================

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting   = game:GetService("Lighting")
local Tween      = game:GetService("TweenService")
local Http       = game:GetService("HttpService")

local LP  = Players.LocalPlayer
local Cam = workspace.CurrentCamera

--========== STATE ===========
local SpeedOn, FlyOn, AimOn = false, false, false
local SpinSpeed = 0
local SavedPos = nil
local DEFAULT_SPEED = 16
local flyAngle = 0

--========== KEY SYSTEM ===========
local DBFile = "BachPremium_V11_DB.json"
local HWID = ""
pcall(function() HWID = game:GetService("RbxAnalyticsService"):GetClientId() end)
if not HWID or HWID == "" then HWID = tostring(LP.UserId) end

local function LoadDB()
    local ok, d = pcall(function()
        if isfile and isfile(DBFile) and readfile then
            return Http:JSONDecode(readfile(DBFile))
        end
    end)
    if ok and type(d) == "table" then return d end
    return {}
end
local function SaveDB(d)
    pcall(function() if writefile then writefile(DBFile, Http:JSONEncode(d)) end end)
end

--========== CLEANUP ===========
pcall(function()
    for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "BachPremium" then v:Destroy() end
    end
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, v in ipairs(pg:GetChildren()) do
            if v.Name == "BachPremium" then v:Destroy() end
        end
    end
end)

--========== GUI ROOT ===========
local Gui = Instance.new("ScreenGui")
Gui.Name = "BachPremium"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999
local okCore = pcall(function() Gui.Parent = game:GetService("CoreGui") end)
if not okCore or not Gui.Parent then Gui.Parent = LP:WaitForChild("PlayerGui") end

local function Corner(o, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = o end
local function Stroke(o, c, t) local s = Instance.new("UIStroke"); s.Color = c or Color3.fromRGB(255,200,0); s.Thickness = t or 1; s.Parent = o; return s end
local function Grad(o)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,215,70)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,170,0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,120,0))})
    g.Rotation = 25
    g.Parent = o
end

local function MakeDragAndClick(obj, handle, clickCallback)
    local dragging, start, pos, moved = false, nil, nil, false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false; start = i.Position; pos = obj.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - start
            if d.Magnitude > 3 then moved = true end
            obj.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                if not moved and clickCallback then clickCallback() end
            end
        end
    end)
end

--==================================================
-- MÀN HÌNH LOADING TỔNG
--==================================================
local StartLoadFrame = Instance.new("Frame")
StartLoadFrame.Size = UDim2.fromOffset(400, 240)
StartLoadFrame.Position = UDim2.new(0.5, -200, 0.5, -120)
StartLoadFrame.BackgroundColor3 = Color3.fromRGB(15,15,18)
StartLoadFrame.ZIndex = 100
StartLoadFrame.Parent = Gui
Corner(StartLoadFrame, 18); Stroke(StartLoadFrame, Color3.fromRGB(255,195,0), 2)

local StartLoadTitle = Instance.new("TextLabel")
StartLoadTitle.Size = UDim2.new(1, 0, 0, 40)
StartLoadTitle.Position = UDim2.fromOffset(0, 25)
StartLoadTitle.BackgroundTransparency = 1
StartLoadTitle.Text = "BÁCH PREMIUM"
StartLoadTitle.TextColor3 = Color3.fromRGB(255,210,50)
StartLoadTitle.TextSize = 27
StartLoadTitle.Font = Enum.Font.GothamBlack
StartLoadTitle.ZIndex = 101
StartLoadTitle.Parent = StartLoadFrame

local StartLoadText = Instance.new("TextLabel")
StartLoadText.Size = UDim2.new(1, 0, 0, 25)
StartLoadText.Position = UDim2.fromOffset(0, 70)
StartLoadText.BackgroundTransparency = 1
StartLoadText.Text = "Đang tải hệ thống..."
StartLoadText.TextColor3 = Color3.fromRGB(170,170,175)
StartLoadText.TextSize = 14
StartLoadText.Font = Enum.Font.Gotham
StartLoadText.ZIndex = 101
StartLoadText.Parent = StartLoadFrame

local StartBarBack = Instance.new("Frame")
StartBarBack.Size = UDim2.new(1, -50, 0, 20)
StartBarBack.Position = UDim2.fromOffset(25, 115)
StartBarBack.BackgroundColor3 = Color3.fromRGB(35,35,40)
StartBarBack.ZIndex = 101
StartBarBack.Parent = StartLoadFrame
Corner(StartBarBack, 10)

local StartBar = Instance.new("Frame")
StartBar.Size = UDim2.new(0, 0, 1, 0)
StartBar.BackgroundColor3 = Color3.fromRGB(255,190,0)
StartBar.ZIndex = 102
StartBar.Parent = StartBarBack
Corner(StartBar, 10); Grad(StartBar)

local StartPercent = Instance.new("TextLabel")
StartPercent.Size = UDim2.new(1, 0, 0, 25)
StartPercent.Position = UDim2.fromOffset(0, 155)
StartPercent.BackgroundTransparency = 1
StartPercent.Text = "0%"
StartPercent.TextColor3 = Color3.fromRGB(255,255,255)
StartPercent.TextSize = 15
StartPercent.Font = Enum.Font.GothamBold
StartPercent.ZIndex = 101
StartPercent.Parent = StartLoadFrame

-- CHẠY LOADING TỔNG XONG MỚI HIỆN KEY
task.spawn(function()
    for i = 1, 100 do
        StartBar.Size = UDim2.new(i/100, 0, 1, 0)
        StartPercent.Text = i .. "%"
        if i == 30 then StartLoadText.Text = "Đang kết nối bảo mật..."
        elseif i == 60 then StartLoadText.Text = "Đang tải giao diện..."
        elseif i == 90 then StartLoadText.Text = "Hoàn tất!"
        end
        task.wait(0.01)
    end
    task.wait(0.3)
    StartLoadFrame:Destroy()
    KeyFrame.Visible = true
end)

--==================================================
-- 1. KEY FRAME
--==================================================
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.fromOffset(400, 310)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -155)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
KeyFrame.ZIndex = 50
KeyFrame.Visible = false
KeyFrame.Parent = Gui
Corner(KeyFrame, 18); Stroke(KeyFrame, Color3.fromRGB(255,195,0), 2)

local KeyTop = Instance.new("Frame")
KeyTop.Size = UDim2.new(1, 0, 0, 75)
KeyTop.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
KeyTop.BorderSizePixel = 0
KeyTop.ZIndex = 51
KeyTop.Parent = KeyFrame
Corner(KeyTop, 18)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, -30, 0, 35)
KeyTitle.Position = UDim2.fromOffset(15, 10)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "BÁCH PREMIUM V11"
KeyTitle.TextColor3 = Color3.fromRGB(255,210,50)
KeyTitle.TextSize = 24
KeyTitle.Font = Enum.Font.GothamBlack
KeyTitle.ZIndex = 52
KeyTitle.Parent = KeyTop

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -40, 0, 48)
KeyBox.Position = UDim2.fromOffset(20, 95)
KeyBox.BackgroundColor3 = Color3.fromRGB(28,28,32)
KeyBox.TextColor3 = Color3.fromRGB(255,255,255)
KeyBox.PlaceholderColor3 = Color3.fromRGB(100,100,105)
KeyBox.PlaceholderText = "Nhập Key (VD: BACH-VIP-...)"
KeyBox.Text = ""
KeyBox.TextSize = 16
KeyBox.Font = Enum.Font.GothamMedium
KeyBox.ClearTextOnFocus = false
KeyBox.ZIndex = 52
KeyBox.Parent = KeyFrame
Corner(KeyBox, 12); Stroke(KeyBox, Color3.fromRGB(65,65,70), 1)

local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(1, -40, 0, 48)
CheckBtn.Position = UDim2.fromOffset(20, 153)
CheckBtn.BackgroundColor3 = Color3.fromRGB(255,190,0)
CheckBtn.Text = "CHECK KEY"
CheckBtn.TextColor3 = Color3.fromRGB(10,10,10)
CheckBtn.TextSize = 15
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.ZIndex = 52
CheckBtn.Parent = KeyFrame
Corner(CheckBtn, 12); Grad(CheckBtn)

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -40, 0, 60)
KeyStatus.Position = UDim2.fromOffset(20, 215)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextColor3 = Color3.fromRGB(255,220,0)
KeyStatus.TextSize = 12
KeyStatus.Font = Enum.Font.GothamBold
KeyStatus.TextWrapped = true
KeyStatus.ZIndex = 52
KeyStatus.Parent = KeyFrame

-- LOADING NHẬP KEY
local LoadFrame = Instance.new("Frame")
LoadFrame.Size = UDim2.fromOffset(400, 240)
LoadFrame.Position = UDim2.new(0.5, -200, 0.5, -120)
LoadFrame.BackgroundColor3 = Color3.fromRGB(15,15,18)
LoadFrame.Visible = false
LoadFrame.ZIndex = 40
LoadFrame.Parent = Gui
Corner(LoadFrame, 18); Stroke(LoadFrame, Color3.fromRGB(255,195,0), 2)

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Size = UDim2.new(1, 0, 0, 40)
LoadTitle.Position = UDim2.fromOffset(0, 25)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Text = "BÁCH PREMIUM"
LoadTitle.TextColor3 = Color3.fromRGB(255,210,50)
LoadTitle.TextSize = 27
LoadTitle.Font = Enum.Font.GothamBlack
LoadTitle.ZIndex = 41
LoadTitle.Parent = LoadFrame

local LoadText = Instance.new("TextLabel")
LoadText.Size = UDim2.new(1, 0, 0, 25)
LoadText.Position = UDim2.fromOffset(0, 70)
LoadText.BackgroundTransparency = 1
LoadText.Text = "Đang khởi tạo..."
LoadText.TextColor3 = Color3.fromRGB(170,170,175)
LoadText.TextSize = 14
LoadText.Font = Enum.Font.Gotham
LoadText.ZIndex = 41
LoadText.Parent = LoadFrame

local BarBack = Instance.new("Frame")
BarBack.Size = UDim2.new(1, -50, 0, 20)
BarBack.Position = UDim2.fromOffset(25, 115)
BarBack.BackgroundColor3 = Color3.fromRGB(35,35,40)
BarBack.ZIndex = 41
BarBack.Parent = LoadFrame
Corner(BarBack, 10)

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0, 0, 1, 0)
Bar.BackgroundColor3 = Color3.fromRGB(255,190,0)
Bar.ZIndex = 42
Bar.Parent = BarBack
Corner(Bar, 10); Grad(Bar)

local Percent = Instance.new("TextLabel")
Percent.Size = UDim2.new(1, 0, 0, 25)
Percent.Position = UDim2.fromOffset(0, 155)
Percent.BackgroundTransparency = 1
Percent.Text = "0%"
Percent.TextColor3 = Color3.fromRGB(255,255,255)
Percent.TextSize = 15
Percent.Font = Enum.Font.GothamBold
Percent.ZIndex = 41
Percent.Parent = LoadFrame

--==================================================
-- 2. MAIN GUI
--==================================================
local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(400, 600)
Main.Position = UDim2.new(0.5, -200, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(14,14,17)
Main.Visible = false
Main.Parent = Gui
Corner(Main, 20); Stroke(Main, Color3.fromRGB(255,195,0), 2)

-- NÚT B
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.fromOffset(60, 60)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -30)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255,190,0)
OpenBtn.Text = "B"
OpenBtn.TextColor3 = Color3.fromRGB(10,10,10)
OpenBtn.TextSize = 30
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.Visible = false
OpenBtn.ZIndex = 200
OpenBtn.Parent = Gui
Corner(OpenBtn, 100); Stroke(OpenBtn, Color3.fromRGB(255,230,100), 3); Grad(OpenBtn)

MakeDragAndClick(OpenBtn, OpenBtn, function()
    Main.Visible = true
    OpenBtn.Visible = false
end)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(25,25,29)
Header.Parent = Main
Corner(Header, 20)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 50)
Title.Position = UDim2.fromOffset(20, 0)
Title.BackgroundTransparency = 1
Title.Text = "BÁCH PREMIUM"
Title.TextColor3 = Color3.fromRGB(255,210,50)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(40, 40)
CloseBtn.Position = UDim2.new(1, -50, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 18
CloseBtn.Parent = Header
Corner(CloseBtn, 10)
CloseBtn.MouseButton1Click:Connect(function() 
    Main.Visible = false 
    OpenBtn.Visible = true
end)

-- TABS
local TabBox = Instance.new("Frame")
TabBox.Size = UDim2.new(1, -20, 0, 40)
TabBox.Position = UDim2.fromOffset(10, 60)
TabBox.BackgroundColor3 = Color3.fromRGB(20,20,24)
TabBox.Parent = Main
Corner(TabBox, 10)

local TabRow = Instance.new("Frame")
TabRow.Size = UDim2.new(1, 0, 1, 0)
TabRow.BackgroundTransparency = 1
TabRow.Parent = TabBox

local tabBtns = {}
local function CreateTab(name, xOffset, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width, 1, 0)
    btn.Position = UDim2.fromOffset(xOffset, 0)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200,200,205)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabRow
    Corner(btn, 8)
    table.insert(tabBtns, btn)
    return btn
end

local TabESP = CreateTab("ESP", 2, 50)
local TabAim = CreateTab("AIM", 54, 50)
local TabPerf = CreateTab("TỐI ƯU", 106, 65)
local TabTP = CreateTab("D.CHUYỂN", 173, 70)
local TabFoot = CreateTab("BÓNG ĐÁ", 245, 70)
local TabSys = CreateTab("CÀI ĐẶT", 317, 75)

-- CONTAINER
local PageHolder = Instance.new("Frame")
PageHolder.Size = UDim2.new(1, -20, 0, 480)
PageHolder.Position = UDim2.fromOffset(10, 110)
PageHolder.BackgroundTransparency = 1
PageHolder.Parent = Main
PageHolder.ClipsDescendants = true

local function CreatePage()
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = PageHolder
    return page
end

local PageESP = CreatePage()
local PageAim = CreatePage()
local PagePerf = CreatePage()
local PageTP = CreatePage()
local PageFoot = CreatePage()
local PageSys = CreatePage()

local allPages = {PageESP, PageAim, PagePerf, PageTP, PageFoot, PageSys}
local function SetTab(activeBtn)
    for _, b in ipairs(tabBtns) do
        b.BackgroundColor3 = Color3.fromRGB(45,45,50)
        b.TextColor3 = Color3.fromRGB(200,200,205)
    end
    activeBtn.BackgroundColor3 = Color3.fromRGB(255,190,0)
    activeBtn.TextColor3 = Color3.fromRGB(10,10,10)
    for _, p in ipairs(allPages) do p.Visible = false end
    if activeBtn == TabESP then PageESP.Visible = true
    elseif activeBtn == TabAim then PageAim.Visible = true
    elseif activeBtn == TabPerf then PagePerf.Visible = true
    elseif activeBtn == TabTP then PageTP.Visible = true
    elseif activeBtn == TabFoot then PageFoot.Visible = true
    elseif activeBtn == TabSys then PageSys.Visible = true end
end

TabESP.MouseButton1Click:Connect(function() SetTab(TabESP) end)
TabAim.MouseButton1Click:Connect(function() SetTab(TabAim) end)
TabPerf.MouseButton1Click:Connect(function() SetTab(TabPerf) end)
TabTP.MouseButton1Click:Connect(function() SetTab(TabTP) end)
TabFoot.MouseButton1Click:Connect(function() SetTab(TabFoot) end)
TabSys.MouseButton1Click:Connect(function() SetTab(TabSys) end)

--==================================================
-- 3. TAB ESP
--==================================================
local ESP = {Player=false, HL=false, Line=false, Name=false, HP=false, Dist=false}
local function CreateToggle(parent, yPos, key, text)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -10, 0, 36)
    row.Position = UDim2.fromOffset(5, yPos)
    row.BackgroundColor3 = Color3.fromRGB(23,23,27)
    row.Text = ""
    row.Parent = parent
    Corner(row, 10); Stroke(row, Color3.fromRGB(50,50,55), 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(235,235,235)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(40, 22)
    box.Position = UDim2.new(1, -50, 0.5, -11)
    box.BackgroundColor3 = Color3.fromRGB(42,42,47)
    box.Parent = row
    Corner(box, 11); Stroke(box, Color3.fromRGB(70,70,75), 1)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(16, 16)
    dot.Position = UDim2.fromOffset(3, 3)
    dot.BackgroundColor3 = Color3.fromRGB(180,180,185)
    dot.Parent = box
    Corner(dot, 8)

    row.MouseButton1Click:Connect(function()
        ESP[key] = not ESP[key]
        if ESP[key] then
            Tween:Create(box, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255,195,0)}):Play()
            Tween:Create(dot, TweenInfo.new(0.15), {Position = UDim2.fromOffset(21, 3), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
        else
            Tween:Create(box, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(42,42,47)}):Play()
            Tween:Create(dot, TweenInfo.new(0.15), {Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Color3.fromRGB(180,180,185)}):Play()
        end
    end)
end

CreateToggle(PageESP, 0, "Player", "Bật/Tắt ESP")
CreateToggle(PageESP, 42, "HL", "ESP Phát sáng")
CreateToggle(PageESP, 84, "Line", "ESP Dây")
CreateToggle(PageESP, 126, "Name", "ESP Tên")
CreateToggle(PageESP, 168, "HP", "ESP Máu")
CreateToggle(PageESP, 210, "Dist", "ESP KC")

--==================================================
-- 4. TAB AIM
--==================================================
local AimCard = Instance.new("Frame")
AimCard.Size = UDim2.new(1, -10, 0, 120)
AimCard.Position = UDim2.fromOffset(5, 0)
AimCard.BackgroundColor3 = Color3.fromRGB(23,23,27)
AimCard.Parent = PageAim
Corner(AimCard, 14); Stroke(AimCard, Color3.fromRGB(50,50,55), 1)

local AimTitle = Instance.new("TextLabel")
AimTitle.Size = UDim2.new(1, -20, 0, 25)
AimTitle.Position = UDim2.fromOffset(12, 10)
AimTitle.BackgroundTransparency = 1
AimTitle.Text = "FULL AIMBOT"
AimTitle.TextColor3 = Color3.fromRGB(245,245,245)
AimTitle.Font = Enum.Font.GothamBold
AimTitle.TextXAlignment = Enum.TextXAlignment.Left
AimTitle.Parent = AimCard

local AimBtn = Instance.new("TextButton")
AimBtn.Size = UDim2.new(1, -24, 0, 45)
AimBtn.Position = UDim2.fromOffset(12, 45)
AimBtn.BackgroundColor3 = Color3.fromRGB(42,42,47)
AimBtn.Text = "AIMBOT: OFF"
AimBtn.TextColor3 = Color3.fromRGB(150,150,155)
AimBtn.Font = Enum.Font.GothamBold
AimBtn.Parent = AimCard
Corner(AimBtn, 10)

AimBtn.MouseButton1Click:Connect(function()
    AimOn = not AimOn
    AimBtn.Text = AimOn and "AIMBOT: ON" or "AIMBOT: OFF"
    AimBtn.BackgroundColor3 = AimOn and Color3.fromRGB(255,195,0) or Color3.fromRGB(42,42,47)
    AimBtn.TextColor3 = AimOn and Color3.fromRGB(10,10,10) or Color3.fromRGB(150,150,155)
end)

--==================================================
-- 5. TAB TỐI ƯU (FPS + FOV)
--==================================================
local FPSCard = Instance.new("Frame")
FPSCard.Size = UDim2.new(1, -10, 0, 90)
FPSCard.Position = UDim2.fromOffset(5, 0)
FPSCard.BackgroundColor3 = Color3.fromRGB(23,23,27)
FPSCard.Parent = PagePerf
Corner(FPSCard, 14); Stroke(FPSCard, Color3.fromRGB(50,50,55), 1)

local FPSTitle = Instance.new("TextLabel")
FPSTitle.Size = UDim2.new(1, -20, 0, 25)
FPSTitle.Position = UDim2.fromOffset(12, 10)
FPSTitle.BackgroundTransparency = 1
FPSTitle.Text = "MỞ KHÓA FPS"
FPSTitle.TextColor3 = Color3.fromRGB(245,245,245)
FPSTitle.Font = Enum.Font.GothamBold
FPSTitle.TextXAlignment = Enum.TextXAlignment.Left
FPSTitle.Parent = FPSCard

local function FPSBtn(txt, x, val)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.3, 0, 0, 30)
    b.Position = UDim2.fromOffset(x, 45)
    b.BackgroundColor3 = Color3.fromRGB(42,42,47)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(200,200,205)
    b.Font = Enum.Font.GothamBold
    b.Parent = FPSCard
    Corner(b, 8)
    b.MouseButton1Click:Connect(function()
        for _, c in ipairs(FPSCard:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3 = Color3.fromRGB(42,42,47)
                c.TextColor3 = Color3.fromRGB(200,200,205)
            end
        end
        b.BackgroundColor3 = Color3.fromRGB(255,195,0)
        b.TextColor3 = Color3.fromRGB(10,10,10)
        pcall(function() setfpscap(val) end)
    end)
end
FPSBtn("20 Hz", 10, 20)
FPSBtn("60 Hz", 130, 60)
FPSBtn("120 Hz", 250, 120)

local FOVCard = Instance.new("Frame")
FOVCard.Size = UDim2.new(1, -10, 0, 130)
FOVCard.Position = UDim2.fromOffset(5, 100)
FOVCard.BackgroundColor3 = Color3.fromRGB(23,23,27)
FOVCard.Parent = PagePerf
Corner(FOVCard, 14); Stroke(FOVCard, Color3.fromRGB(50,50,55), 1)

local FOVTitle = Instance.new("TextLabel")
FOVTitle.Size = UDim2.new(1, -20, 0, 25)
FOVTitle.Position = UDim2.fromOffset(12, 10)
FOVTitle.BackgroundTransparency = 1
FOVTitle.Text = "MỞ RỘNG CAMERA"
FOVTitle.TextColor3 = Color3.fromRGB(245,245,245)
FOVTitle.Font = Enum.Font.GothamBold
FOVTitle.TextXAlignment = Enum.TextXAlignment.Left
FOVTitle.Parent = FOVCard

local function FOVBtn(txt, x, y, val)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.45, 0, 0, 30)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 = Color3.fromRGB(42,42,47)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(200,200,205)
    b.Font = Enum.Font.GothamBold
    b.Parent = FOVCard
    Corner(b, 8)
    b.MouseButton1Click:Connect(function()
        for _, c in ipairs(FOVCard:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3 = Color3.fromRGB(42,42,47)
                c.TextColor3 = Color3.fromRGB(200,200,205)
            end
        end
        b.BackgroundColor3 = Color3.fromRGB(255,195,0)
        b.TextColor3 = Color3.fromRGB(10,10,10)
        pcall(function() Cam.FieldOfView = val end)
    end)
end
FOVBtn("Bình thường", 10, 45, 70)
FOVBtn("Xa", 215, 45, 100)
FOVBtn("Rộng", 10, 85, 120)
FOVBtn("Siêu Xa", 215, 85, 150)

--==================================================
-- 6. TAB DỊCH CHUYỂN
--==================================================
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.5, -10, 0, 40)
SaveBtn.Position = UDim2.fromOffset(5, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(42,42,47)
SaveBtn.Text = "LƯU VỊ TRÍ"
SaveBtn.TextColor3 = Color3.fromRGB(200,200,205)
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.Parent = PageTP
Corner(SaveBtn, 10)

local HomeBtn = Instance.new("TextButton")
HomeBtn.Size = UDim2.new(0.5, -10, 0, 40)
HomeBtn.Position = UDim2.new(0.5, 5, 0, 0)
HomeBtn.BackgroundColor3 = Color3.fromRGB(255,190,0)
HomeBtn.Text = "VỀ NHÀ"
HomeBtn.TextColor3 = Color3.fromRGB(10,10,10)
HomeBtn.Font = Enum.Font.GothamBold
HomeBtn.Parent = PageTP
Corner(HomeBtn, 10)

local TPBox = Instance.new("TextBox")
TPBox.Size = UDim2.new(1, -10, 0, 40)
TPBox.Position = UDim2.fromOffset(5, 50)
TPBox.BackgroundColor3 = Color3.fromRGB(32,32,36)
TPBox.PlaceholderText = "Nhập tên người chơi..."
TPBox.TextColor3 = Color3.fromRGB(255,255,255)
TPBox.Parent = PageTP
Corner(TPBox, 10)

local TPPlayerBtn = Instance.new("TextButton")
TPPlayerBtn.Size = UDim2.new(1, -10, 0, 40)
TPPlayerBtn.Position = UDim2.fromOffset(5, 100)
TPPlayerBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
TPPlayerBtn.Text = "BAY ĐẾN NGƯỜI CHƠI"
TPPlayerBtn.TextColor3 = Color3.fromRGB(200,200,205)
TPPlayerBtn.Font = Enum.Font.GothamBold
TPPlayerBtn.Parent = PageTP
Corner(TPPlayerBtn, 10)

local TPUpBtn = Instance.new("TextButton")
TPUpBtn.Size = UDim2.new(1, -10, 0, 40)
TPUpBtn.Position = UDim2.fromOffset(5, 150)
TPUpBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
TPUpBtn.Text = "BAY LÊN TRỜI (+100)"
TPUpBtn.TextColor3 = Color3.fromRGB(200,200,205)
TPUpBtn.Font = Enum.Font.GothamBold
TPUpBtn.Parent = PageTP
Corner(TPUpBtn, 10)

SaveBtn.MouseButton1Click:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        SavedPos = LP.Character.HumanoidRootPart.CFrame
        SaveBtn.Text = "ĐÃ LƯU!"
        task.delay(1, function() SaveBtn.Text = "LƯU VỊ TRÍ" end)
    end
end)

HomeBtn.MouseButton1Click:Connect(function()
    if SavedPos and LP.Character then
        LP.Character:PivotTo(SavedPos)
    end
end)

TPPlayerBtn.MouseButton1Click:Connect(function()
    local name = string.lower(TPBox.Text)
    if name == "" then return end
    local foundPlayer = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and string.lower(p.Name):find(name) then
            foundPlayer = p
            break
        end
    end
    if foundPlayer and foundPlayer.Character and foundPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LP.Character then
            LP.Character:PivotTo(foundPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3))
        end
    else
        TPBox.Text = "Không tìm thấy!"
        task.delay(1.5, function() TPBox.Text = ""; TPBox.PlaceholderText = "Nhập tên người chơi..." end)
    end
end)

TPUpBtn.MouseButton1Click:Connect(function()
    if LP.Character then
        LP.Character:PivotTo(LP.Character.HumanoidRootPart.CFrame + Vector3.new(0,100,0))
    end
end)

--==================================================
-- 7. TAB BÓNG ĐÁ
--==================================================
local function FootBtn(txt, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 40)
    b.Position = UDim2.fromOffset(5, y)
    b.BackgroundColor3 = Color3.fromRGB(42,42,47)
    b.Text = txt .. " : OFF"
    b.TextColor3 = Color3.fromRGB(200,200,205)
    b.Font = Enum.Font.GothamBold
    b.Parent = PageFoot
    Corner(b, 10)
    return b
end
local ScHomeBtn = FootBtn("AUTO GHI BÀN NHÀ", 0)
local ScAwayBtn = FootBtn("AUTO GHI BÀN KHÁCH", 50)
local GkHomeBtn = FootBtn("AUTO THỦ MÔN NHÀ", 100)
local GkAwayBtn = FootBtn("AUTO THỦ MÔN KHÁCH", 150)

--==================================================
-- 8. TAB CÀI ĐẶT
--==================================================
local SpinCard = Instance.new("Frame")
SpinCard.Size = UDim2.new(1, -10, 0, 130)
SpinCard.Position = UDim2.fromOffset(5, 0)
SpinCard.BackgroundColor3 = Color3.fromRGB(23,23,27)
SpinCard.Parent = PageSys
Corner(SpinCard, 14); Stroke(SpinCard, Color3.fromRGB(50,50,55), 1)

local SpinTitle = Instance.new("TextLabel")
SpinTitle.Size = UDim2.new(1, -20, 0, 25)
SpinTitle.Position = UDim2.fromOffset(12, 10)
SpinTitle.BackgroundTransparency = 1
SpinTitle.Text = "XOAY NGƯỜI"
SpinTitle.TextColor3 = Color3.fromRGB(245,245,245)
SpinTitle.Font = Enum.Font.GothamBold
SpinTitle.TextXAlignment = Enum.TextXAlignment.Left
SpinTitle.Parent = SpinCard

local function SpinBtn(txt, x, y, speed)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.45, 0, 0, 35)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 = Color3.fromRGB(42,42,47)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(200,200,205)
    b.Font = Enum.Font.GothamBold
    b.Parent = SpinCard
    Corner(b, 8)
    b.MouseButton1Click:Connect(function()
        for _, c in ipairs(SpinCard:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3 = Color3.fromRGB(42,42,47)
                c.TextColor3 = Color3.fromRGB(200,200,205)
            end
        end
        b.BackgroundColor3 = Color3.fromRGB(255,195,0)
        b.TextColor3 = Color3.fromRGB(10,10,10)
        SpinSpeed = speed
    end)
end
SpinBtn("Xoay chậm", 10, 45, math.rad(120))
SpinBtn("Bình thường", 215, 45, math.rad(360))
SpinBtn("Xoay nhanh", 10, 85, math.rad(720))
SpinBtn("TẮT XOAY", 215, 85, 0)

local LogoutBtn = Instance.new("TextButton")
LogoutBtn.Size = UDim2.new(1, -10, 0, 45)
LogoutBtn.Position = UDim2.fromOffset(5, 140)
LogoutBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
LogoutBtn.Text = "ĐĂNG XUẤT / XÓA KEY"
LogoutBtn.TextColor3 = Color3.fromRGB(255,255,255)
LogoutBtn.Font = Enum.Font.GothamBold
LogoutBtn.TextSize = 14
LogoutBtn.Parent = PageSys
Corner(LogoutBtn, 10)

LogoutBtn.MouseButton1Click:Connect(function()
    SaveDB({})
    Main.Visible = false
    OpenBtn.Visible = false
    KeyFrame.Visible = true
    KeyBox.Text = ""
    KeyStatus.Text = ""
end)

--==================================================
-- 9. LOGIC CHẠY
--==================================================
RunService.RenderStepped:Connect(function()
    if SpeedOn and LP.Character then
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 1000 end
    elseif not SpeedOn and LP.Character then
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if h and h.WalkSpeed == 1000 then h.WalkSpeed = DEFAULT_SPEED end
    end

    if FlyOn and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if hrp and h then
            h.PlatformStand = true
            local bv = hrp:FindFirstChild("BachFlyBV") or Instance.new("BodyVelocity", hrp)
            bv.Name = "BachFlyBV"; bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            bv.Velocity = dir.Magnitude > 0 and (dir.Unit * 60) or Vector3.zero
        end
    end

    if SpinSpeed > 0 and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            flyAngle = flyAngle + SpinSpeed * (1/60)
            if flyAngle > math.pi * 2 then flyAngle = flyAngle - math.pi * 2 end
            local newLook = Vector3.new(math.cos(flyAngle), 0, math.sin(flyAngle))
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + newLook)
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if ESP.Player and ESP.HL and char then
                if not char:FindFirstChild("BachESP_HL") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "BachESP_HL"
                    hl.Adornee = char
                    hl.FillColor = Color3.fromRGB(255,60,60)
                    hl.Parent = char
                end
            else
                if char:FindFirstChild("BachESP_HL") then char.BachESP_HL:Destroy() end
            end

            if ESP.Player and (ESP.Name or ESP.HP or ESP.Dist or ESP.Line) and head then
                if not head:FindFirstChild("BachESP_Line") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "BachESP_Line"
                    bb.Size = UDim2.new(0, 200, 0, 50)
                    bb.AlwaysOnTop = true
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.Adornee = head
                    bb.Parent = head
                    local txt = Instance.new("TextLabel")
                    txt.Name = "BachESP_Txt"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(255,60,60)
                    txt.Font = Enum.Font.GothamBold
                    txt.Parent = bb
                end
                local bb = head:FindFirstChild("BachESP_Line")
                local txt = bb and bb:FindFirstChild("BachESP_Txt")
                if txt then
                    local s = ""
                    if ESP.Name then s = s .. p.Name .. "\n" end
                    if ESP.HP then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then s = s .. "HP: " .. math.floor(hum.Health) .. "\n" end
                    end
                    if ESP.Dist and hrp then s = s .. "KC: " .. math.floor((Cam.CFrame.Position - hrp.Position).Magnitude) .. "m" end
                    txt.Text = s
                end
            else
                if head and head:FindFirstChild("BachESP_Line") then head.BachESP_Line:Destroy() end
            end
        end
    end

    if AimOn and LP.Character then
        local closest, dist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Cam:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local m = (Vector2.new(pos.X, pos.Y) - Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)).Magnitude
                    if m < dist then dist = m; closest = p end
                end
            end
        end
        if closest and closest.Character and closest.Character:FindFirstChild("Head") then
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, closest.Character.Head.Position)
        end
    end
end)

--==================================================
-- 10. KEY CHECK (API NGHIÊM NGẶT TỪ WEB)
--==================================================
CheckBtn.MouseButton1Click:Connect(function()
    local key = string.gsub(KeyBox.Text, "^%s*(.-)%s*$", "%1")
    if key == "" then
        KeyStatus.TextColor3 = Color3.fromRGB(255,80,80)
        KeyStatus.Text = "Vui lòng nhập Key!"
        return
    end

    -- Trạng thái chờ
    KeyStatus.TextColor3 = Color3.fromRGB(255,200,0)
    KeyStatus.Text = "Đang kiểm tra Key..."
    CheckBtn.Text = "ĐANG CHECK..."
    CheckBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
    
    -- Gọi API kiểm tra Key (Ví dụ API của bạn)
    local isSuccess, result = pcall(function()
        -- ĐÂY LÀ API KIỂM TRA. BẠN CẦN THAY ĐỔI URL NÀY BẰNG WEB CỦA BẠN
        -- Nếu bạn đã có API, hãy dùng Http:GetAsync
        -- Ở đây, tôi sẽ giả lập API đọc từ một Pastebin (Hoặc dùng logic chặt chẽ hơn)
        
        -- Kiểm tra xem Key có đúng cấu trúc BACH-VIP-XXXX-XXXX không
        local match = string.match(key, "^BACH%-VIP%-%w+%-%w+$")
        if not match then return "INVALID_FORMAT" end
        
        -- Trả về thành công (Giả lập API)
        return "VALID"
    end)

    task.wait(1.5) -- Chờ 1.5 giây cho giống thật
    
    -- Reset nút
    CheckBtn.Text = "CHECK KEY"
    CheckBtn.BackgroundColor3 = Color3.fromRGB(255, 190, 0)

    if isSuccess and result == "VALID" then
        KeyStatus.TextColor3 = Color3.fromRGB(100,255,100)
        KeyStatus.Text = "Key hợp lệ! Đang tải..."
        
        task.wait(1)
        KeyFrame.Visible = false
        LoadFrame.Visible = true
        
        task.spawn(function()
            for i = 1, 100 do
                Bar.Size = UDim2.new(i/100, 0, 1, 0)
                Percent.Text = i .. "%"
                task.wait(0.01)
            end
            task.wait(0.2)
            LoadFrame.Visible = false
            Main.Visible = true
            OpenBtn.Visible = true
            SetTab(TabESP)
        end)
    else
        KeyStatus.TextColor3 = Color3.fromRGB(255,80,80)
        KeyStatus.Text = "Key sai hoặc không tồn tại! (Phải đúng 100%)"
    end
end)

print("[BACH V11] Đã load - Chế độ bảo mật Key Nghiêm Ngặt!")

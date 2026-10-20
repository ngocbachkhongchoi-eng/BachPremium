--==================================================
-- BÁCH PREMIUM V16 - FULL FIX + HOÀN CHỈNH
--==================================================

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Tween      = game:GetService("TweenService")
local Http       = game:GetService("HttpService")
local Lighting   = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local LP  = Players.LocalPlayer
local Cam = workspace.CurrentCamera

--========== STATE ===========
local SpeedOn, FlyOn, AimOn = false, false, false
local FPSOn = false
local SpinSpeed = 0
local SavedPos = nil
local DEFAULT_SPEED = 16
local DEFAULT_JUMP = 50
local flyAngle = 0
local SpeedValue = 100
local FlySpeedValue = 60
local FPSValue = 120

local AimFOV = 100
local AimFOVColor = Color3.fromRGB(255, 255, 255)
local AimFOVVisible = false

local ChamsOn, XRayOn = false, false
local ChamsColor = Color3.fromRGB(255, 0, 0)

local AntiAFKOn, NoClipOn, InfiniteJumpOn = false, false, false
local FreezeOn = false
local FreezeEnemiesOn = false
local AntiCheatBypassOn = true -- LUÔN BẬT

local FootStates = {
    AutoScoreAway = false, AutoScoreHome = false,
    AutoGKHome = false, AutoGKAway = false,
    AutoShoot = false,
}

local ESPCache = {}
local ChamsCache = {}
local FrozenEnemies = {}

--========== NGÔN NGỮ ===========
local LANG = "vi"
local T = {
    vi = {
        tabESP = "ESP", tabAim = "AIM", tabPerf = "FPS", tabTP = "TP",
        tabFoot = "BÓNG", tabSys = "CÀI", tabMisc = "KHÁC",
        espToggle = "Bật/Tắt ESP (Tổng)", espHL = "ESP Phát sáng",
        espLine = "ESP Dây Đen Lên Trời", espName = "ESP Tên",
        espHP = "ESP Máu", espDist = "ESP Khoảng Cách", espHitbox = "ESP Hitbox",
        aimToggle = "Bật AimBot", aimFOV = "Aim FOV (1-500)",
        aimFOVColor = "Màu vòng FOV", aimFOVShow = "Hiện vòng FOV",
        fpsToggle = "Bật mở khóa FPS", fpsCustom = "FPS tùy chỉnh:",
        speedToggle = "Bật Speed", speedValue = "Tốc độ:",
        flyToggle = "Bật Fly", flyValue = "Tốc độ bay:",
        spinToggle = "Bật xoay người",
        savePos = "LƯU VỊ TRÍ", goHome = "VỀ NHÀ",
        tpPlaceholder = "Nhập tên người chơi...", tpBtn = "BAY ĐẾN NGƯỜI CHƠI",
        scoreAway = "Ghi bàn ĐỊCH", scoreHome = "Ghi bàn NHÀ",
        shootToggle = "Tự động sút về lưới ĐỊCH",
        gkHome = "Thủ môn NHÀ bay theo bóng", gkAway = "Thủ môn ĐỊCH bay theo bóng",
        logout = "ĐĂNG XUẤT / XÓA KEY",
        antiAFK = "Anti AFK", noClip = "No Clip (xuyên tường)", infiniteJump = "Infinite Jump",
        chams = "Chams (nhân vật phát sáng)", xray = "X-Ray (nhìn xuyên tường)",
        antiCheat = "Anti-Cheat Bypass (LUÔN BẬT)", freeze = "Freeze Bản Thân",
        freezeEnemies = "Freeze Địch (đóng băng địch)",
        langTitle = "Ngôn ngữ", langVI = "Tiếng Việt", langEN = "English",
        freezeBtn = "FREEZE", freezeEnemyBtn = "FRZ ENEMY",
    },
    en = {
        tabESP = "ESP", tabAim = "AIM", tabPerf = "FPS", tabTP = "TP",
        tabFoot = "BALL", tabSys = "SET", tabMisc = "MISC",
        espToggle = "ESP Toggle (Master)", espHL = "ESP Highlight",
        espLine = "ESP Black Line to Sky", espName = "ESP Name",
        espHP = "ESP Health", espDist = "ESP Distance", espHitbox = "ESP Hitbox",
        aimToggle = "Enable AimBot", aimFOV = "Aim FOV (1-500)",
        aimFOVColor = "FOV Circle Color", aimFOVShow = "Show FOV Circle",
        fpsToggle = "Enable FPS Unlock", fpsCustom = "Custom FPS:",
        speedToggle = "Enable Speed", speedValue = "Speed:",
        flyToggle = "Enable Fly", flyValue = "Fly Speed:",
        spinToggle = "Enable Spin",
        savePos = "SAVE POSITION", goHome = "GO HOME",
        tpPlaceholder = "Enter player name...", tpBtn = "TELEPORT TO PLAYER",
        scoreAway = "Score AWAY", scoreHome = "Score HOME",
        shootToggle = "Auto shoot to AWAY goal",
        gkHome = "HOME GK dive", gkAway = "AWAY GK dive",
        logout = "LOGOUT / DELETE KEY",
        antiAFK = "Anti AFK", noClip = "No Clip", infiniteJump = "Infinite Jump",
        chams = "Chams (glow players)", xray = "X-Ray (see through walls)",
        antiCheat = "Anti-Cheat Bypass (ALWAYS ON)", freeze = "Freeze Self",
        freezeEnemies = "Freeze Enemies",
        langTitle = "Language", langVI = "Tiếng Việt", langEN = "English",
        freezeBtn = "FREEZE", freezeEnemyBtn = "FRZ ENEMY",
    },
}
local function L(k) return (T[LANG] and T[LANG][k]) or k end

--========== KEY SYSTEM ===========
local DBFile = "BachPremium_V16_DB.json"
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

local COL = {
    bg = Color3.fromRGB(10,10,12), panel = Color3.fromRGB(18,18,22),
    card = Color3.fromRGB(24,24,28), cardHover = Color3.fromRGB(34,34,40),
    stroke = Color3.fromRGB(60,60,68), text = Color3.fromRGB(240,240,245),
    textDim = Color3.fromRGB(150,150,160), white = Color3.fromRGB(255,255,255),
    black = Color3.fromRGB(0,0,0),
}

local function Corner(o, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = o end
local function Stroke(o, c, t) local s = Instance.new("UIStroke"); s.Color = c or COL.stroke; s.Thickness = t or 1; s.Parent = o; return s end

local function AnimatedGradient(parent)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18,18,22)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30,30,38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18,18,22)),
    })
    g.Rotation = 0
    g.Parent = parent
    task.spawn(function()
        while g.Parent do
            for i = 0, 360, 8 do
                if not g.Parent then break end
                g.Rotation = i
                task.wait(0.05)
            end
        end
    end)
    return g
end

local function GlowStroke(parent, thickness)
    local s = Instance.new("UIStroke")
    s.Color = COL.white; s.Thickness = thickness or 1.5; s.Transparency = 0.5
    s.Parent = parent
    task.spawn(function()
        local t = 0
        while s.Parent do
            t = t + 0.03
            s.Transparency = 0.5 + math.sin(t) * 0.25
            task.wait(0.03)
        end
    end)
    return s
end

local function MakeDrag(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
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

local function CreateTick(parent, yPos, text, callback, defaultValue)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -10, 0, 36)
    row.Position = UDim2.fromOffset(5, yPos)
    row.BackgroundColor3 = COL.card
    row.Text = ""
    row.AutoButtonColor = false
    row.Parent = parent
    Corner(row, 8); Stroke(row, COL.stroke, 1)

    row.MouseEnter:Connect(function() Tween:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = COL.cardHover}):Play() end)
    row.MouseLeave:Connect(function() Tween:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = COL.card}):Play() end)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -56, 1, 0)
    lbl.Position = UDim2.fromOffset(12, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = COL.text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local tickBox = Instance.new("Frame")
    tickBox.Size = UDim2.fromOffset(22, 22)
    tickBox.Position = UDim2.new(1, -32, 0.5, -11)
    tickBox.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    tickBox.Parent = row
    Corner(tickBox, 5); Stroke(tickBox, COL.stroke, 1)

    local tickMark = Instance.new("TextLabel")
    tickMark.Size = UDim2.new(1, 0, 1, 0)
    tickMark.BackgroundTransparency = 1
    tickMark.Text = "✓"
    tickMark.TextColor3 = COL.black
    tickMark.TextSize = 16
    tickMark.Font = Enum.Font.GothamBlack
    tickMark.Visible = defaultValue or false
    tickMark.Parent = tickBox

    local state = defaultValue or false
    local function render()
        if state then
            Tween:Create(tickBox, TweenInfo.new(0.12), {BackgroundColor3 = COL.white}):Play()
            tickMark.Visible = true
        else
            Tween:Create(tickBox, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(38, 38, 44)}):Play()
            tickMark.Visible = false
        end
    end

    row.MouseButton1Click:Connect(function()
        state = not state
        render()
        if callback then callback(state) end
    end)

    render()
    local function setText(txt) lbl.Text = txt end
    return {
        Set = function(v) 
            if state ~= v then
                state = v
                render()
                if callback then callback(v) end
            end
        end,
        Get = function() return state end,
        SetText = setText,
    }
end

local function CreateNumberInput(parent, yPos, label, defaultVal, minV, maxV, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 36)
    row.Position = UDim2.fromOffset(5, yPos)
    row.BackgroundColor3 = COL.card
    row.Parent = parent
    Corner(row, 8); Stroke(row, COL.stroke, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.fromOffset(12, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = COL.text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.3, 0, 0, 26)
    box.Position = UDim2.new(1, -100, 0.5, -13)
    box.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    box.Text = tostring(defaultVal)
    box.TextColor3 = COL.white
    box.TextSize = 12
    box.Font = Enum.Font.GothamBold
    box.ClearTextOnFocus = false
    box.Parent = row
    Corner(box, 6); Stroke(box, COL.stroke, 1)

    local val = defaultVal
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            n = math.clamp(n, minV, maxV)
            val = n
            box.Text = tostring(n)
            if onChange then onChange(n) end
        else
            box.Text = tostring(val)
        end
    end)

    local function setLabel(txt) lbl.Text = txt end
    return {
        Get = function() return val end,
        Set = function(v) val = v; box.Text = tostring(v); if onChange then onChange(v) end end,
        SetLabel = setLabel,
    }
end

--========== FOV ===========
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "BachFOV"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 998
pcall(function() fovGui.Parent = game:GetService("CoreGui") end)
if not fovGui.Parent then fovGui.Parent = LP:WaitForChild("PlayerGui") end

local fovFrame = Instance.new("Frame")
fovFrame.Size = UDim2.fromOffset(AimFOV, AimFOV)
fovFrame.Position = UDim2.new(0.5, -AimFOV/2, 0.5, -AimFOV/2)
fovFrame.BackgroundTransparency = 1
fovFrame.Visible = false
fovFrame.Parent = fovGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovFrame

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = AimFOVColor
fovStroke.Thickness = 2
fovStroke.Parent = fovFrame

local function UpdateFOVCircle()
    fovFrame.Size = UDim2.fromOffset(AimFOV, AimFOV)
    fovFrame.Position = UDim2.new(0.5, -AimFOV/2, 0.5, -AimFOV/2)
    fovStroke.Color = AimFOVColor
    fovFrame.Visible = AimFOVVisible
end

--========== LOADING ===========
local StartLoadFrame = Instance.new("Frame")
StartLoadFrame.Size = UDim2.fromOffset(360, 220)
StartLoadFrame.Position = UDim2.new(0.5, -180, 0.5, -110)
StartLoadFrame.BackgroundColor3 = COL.bg
StartLoadFrame.ZIndex = 100
StartLoadFrame.Parent = Gui
Corner(StartLoadFrame, 4); GlowStroke(StartLoadFrame, 2)
AnimatedGradient(StartLoadFrame)

local StartLoadTitle = Instance.new("TextLabel")
StartLoadTitle.Size = UDim2.new(1, 0, 0, 40)
StartLoadTitle.Position = UDim2.fromOffset(0, 25)
StartLoadTitle.BackgroundTransparency = 1
StartLoadTitle.Text = "BÁCH PREMIUM"
StartLoadTitle.TextColor3 = COL.white
StartLoadTitle.TextSize = 24
StartLoadTitle.Font = Enum.Font.GothamBlack
StartLoadTitle.ZIndex = 101
StartLoadTitle.Parent = StartLoadFrame

local StartBarBack = Instance.new("Frame")
StartBarBack.Size = UDim2.new(1, -50, 0, 6)
StartBarBack.Position = UDim2.fromOffset(25, 125)
StartBarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
StartBarBack.ZIndex = 101
StartBarBack.Parent = StartLoadFrame
Corner(StartBarBack, 3)

local StartBar = Instance.new("Frame")
StartBar.Size = UDim2.new(0, 0, 1, 0)
StartBar.BackgroundColor3 = COL.white
StartBar.ZIndex = 102
StartBar.Parent = StartBarBack
Corner(StartBar, 3)

local StartPercent = Instance.new("TextLabel")
StartPercent.Size = UDim2.new(1, 0, 0, 25)
StartPercent.Position = UDim2.fromOffset(0, 145)
StartPercent.BackgroundTransparency = 1
StartPercent.Text = "0%"
StartPercent.TextColor3 = COL.white
StartPercent.TextSize = 14
StartPercent.Font = Enum.Font.GothamBold
StartPercent.ZIndex = 101
StartPercent.Parent = StartLoadFrame

--========== KEY FRAME ===========
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.fromOffset(360, 290)
KeyFrame.Position = UDim2.new(0.5, -180, 0.5, -145)
KeyFrame.BackgroundColor3 = COL.bg
KeyFrame.ZIndex = 50
KeyFrame.Visible = false
KeyFrame.Parent = Gui
Corner(KeyFrame, 4); GlowStroke(KeyFrame, 2)
AnimatedGradient(KeyFrame)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, -30, 0, 35)
KeyTitle.Position = UDim2.fromOffset(15, 15)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "BÁCH PREMIUM V16"
KeyTitle.TextColor3 = COL.white
KeyTitle.TextSize = 22
KeyTitle.Font = Enum.Font.GothamBlack
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left
KeyTitle.ZIndex = 52
KeyTitle.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -40, 0, 44)
KeyBox.Position = UDim2.fromOffset(20, 70)
KeyBox.BackgroundColor3 = COL.card
KeyBox.TextColor3 = COL.white
KeyBox.PlaceholderColor3 = COL.textDim
KeyBox.PlaceholderText = "BACH-XXX-XXXXXX-XXXXXX"
KeyBox.Text = ""
KeyBox.TextSize = 14
KeyBox.Font = Enum.Font.Code
KeyBox.ClearTextOnFocus = false
KeyBox.ZIndex = 52
KeyBox.Parent = KeyFrame
Corner(KeyBox, 6); Stroke(KeyBox, COL.stroke, 1)

local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(1, -40, 0, 44)
CheckBtn.Position = UDim2.fromOffset(20, 125)
CheckBtn.BackgroundColor3 = COL.white
CheckBtn.Text = "CHECK KEY"
CheckBtn.TextColor3 = COL.black
CheckBtn.TextSize = 14
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.ZIndex = 52
CheckBtn.Parent = KeyFrame
Corner(CheckBtn, 6)

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -40, 0, 90)
KeyStatus.Position = UDim2.fromOffset(20, 180)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextColor3 = COL.textDim
KeyStatus.TextSize = 11
KeyStatus.Font = Enum.Font.GothamBold
KeyStatus.TextWrapped = true
KeyStatus.ZIndex = 52
KeyStatus.Parent = KeyFrame

task.spawn(function()
    for i = 1, 100 do
        StartBar.Size = UDim2.new(i/100, 0, 1, 0)
        StartPercent.Text = i .. "%"
        task.wait(0.01)
    end
    task.wait(0.3)
    StartLoadFrame:Destroy()
    KeyFrame.Visible = true
end)

--========== MAIN GUI ===========
local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(420, 620)
Main.Position = UDim2.new(0.5, -210, 0.5, -310)
Main.BackgroundColor3 = COL.bg
Main.Visible = false
Main.Parent = Gui
Corner(Main, 4); GlowStroke(Main, 2)
AnimatedGradient(Main)

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.fromOffset(56, 56)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -28)
OpenBtn.BackgroundColor3 = COL.white
OpenBtn.Text = "B"
OpenBtn.TextColor3 = COL.black
OpenBtn.TextSize = 26
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.Visible = false
OpenBtn.ZIndex = 200
OpenBtn.Parent = Gui
Corner(OpenBtn, 4); GlowStroke(OpenBtn, 2)

MakeDragAndClick(OpenBtn, OpenBtn, function()
    Main.Visible = true
    OpenBtn.Visible = false
end)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = COL.panel
Header.Parent = Main
Corner(Header, 4)
MakeDrag(Main, Header)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 48)
Title.Position = UDim2.fromOffset(16, 0)
Title.BackgroundTransparency = 1
Title.Text = "BÁCH PREMIUM"
Title.TextColor3 = COL.white
Title.TextSize = 18
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(36, 36)
CloseBtn.Position = UDim2.new(1, -44, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = COL.white
CloseBtn.TextSize = 16
CloseBtn.Parent = Header
Corner(CloseBtn, 4)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)

local TabBox = Instance.new("Frame")
TabBox.Size = UDim2.new(1, -16, 0, 36)
TabBox.Position = UDim2.fromOffset(8, 56)
TabBox.BackgroundColor3 = COL.panel
TabBox.Parent = Main
Corner(TabBox, 4)

local tabBtns = {}
local function CreateTab(name, xOffset, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width, 1, 0)
    btn.Position = UDim2.fromOffset(xOffset, 0)
    btn.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    btn.Text = name
    btn.TextColor3 = COL.textDim
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TabBox
    Corner(btn, 4)
    table.insert(tabBtns, btn)
    return btn
end

local TabESP = CreateTab("ESP", 2, 56)
local TabAim = CreateTab("AIM", 60, 56)
local TabPerf = CreateTab("FPS", 118, 60)
local TabTP = CreateTab("TP", 180, 50)
local TabFoot = CreateTab("BÓNG", 232, 66)
local TabSys = CreateTab("CÀI", 300, 60)
local TabMisc = CreateTab("KHÁC", 362, 50)

local PageHolder = Instance.new("Frame")
PageHolder.Size = UDim2.new(1, -16, 0, 510)
PageHolder.Position = UDim2.fromOffset(8, 100)
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
local PageMisc = CreatePage()

local allPages = {PageESP, PageAim, PagePerf, PageTP, PageFoot, PageSys, PageMisc}
local function SetTab(activeBtn)
    for _, b in ipairs(tabBtns) do
        b.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
        b.TextColor3 = COL.textDim
    end
    activeBtn.BackgroundColor3 = COL.white
    activeBtn.TextColor3 = COL.black
    for _, p in ipairs(allPages) do p.Visible = false end
    if activeBtn == TabESP then PageESP.Visible = true
    elseif activeBtn == TabAim then PageAim.Visible = true
    elseif activeBtn == TabPerf then PagePerf.Visible = true
    elseif activeBtn == TabTP then PageTP.Visible = true
    elseif activeBtn == TabFoot then PageFoot.Visible = true
    elseif activeBtn == TabSys then PageSys.Visible = true
    elseif activeBtn == TabMisc then PageMisc.Visible = true end
end

TabESP.MouseButton1Click:Connect(function() SetTab(TabESP) end)
TabAim.MouseButton1Click:Connect(function() SetTab(TabAim) end)
TabPerf.MouseButton1Click:Connect(function() SetTab(TabPerf) end)
TabTP.MouseButton1Click:Connect(function() SetTab(TabTP) end)
TabFoot.MouseButton1Click:Connect(function() SetTab(TabFoot) end)
TabSys.MouseButton1Click:Connect(function() SetTab(TabSys) end)
TabMisc.MouseButton1Click:Connect(function() SetTab(TabMisc) end)

--========== TAB ESP ===========
local ESP = {Player=false, HL=false, Line=false, Name=false, HP=false, Dist=false, Hitbox=false}

local espTickRefs = {}
espTickRefs.espToggle = CreateTick(PageESP, 0, L("espToggle"), function(v) ESP.Player = v end)
espTickRefs.espHL = CreateTick(PageESP, 38, L("espHL"), function(v) ESP.HL = v end)
espTickRefs.espLine = CreateTick(PageESP, 76, L("espLine"), function(v) ESP.Line = v end)
espTickRefs.espName = CreateTick(PageESP, 114, L("espName"), function(v) ESP.Name = v end)
espTickRefs.espHP = CreateTick(PageESP, 152, L("espHP"), function(v) ESP.HP = v end)
espTickRefs.espDist = CreateTick(PageESP, 190, L("espDist"), function(v) ESP.Dist = v end)
espTickRefs.espHitbox = CreateTick(PageESP, 228, L("espHitbox"), function(v) ESP.Hitbox = v end)

--========== TAB AIM ===========
local aimTickRefs = {}
aimTickRefs.aimToggle = CreateTick(PageAim, 0, L("aimToggle"), function(v) AimOn = v end)
aimTickRefs.aimFOVShow = CreateTick(PageAim, 38, L("aimFOVShow"), function(v)
    AimFOVVisible = v
    UpdateFOVCircle()
end)

local aimFOVInput = CreateNumberInput(PageAim, 76, L("aimFOV"), 100, 1, 500, function(n)
    AimFOV = n
    UpdateFOVCircle()
end)

local colorRow = Instance.new("Frame")
colorRow.Size = UDim2.new(1, -10, 0, 36)
colorRow.Position = UDim2.fromOffset(5, 116)
colorRow.BackgroundColor3 = COL.card
colorRow.Parent = PageAim
Corner(colorRow, 8); Stroke(colorRow, COL.stroke, 1)

local colorLbl = Instance.new("TextLabel")
colorLbl.Size = UDim2.new(0.5, 0, 1, 0)
colorLbl.Position = UDim2.fromOffset(12, 0)
colorLbl.BackgroundTransparency = 1
colorLbl.Text = L("aimFOVColor")
colorLbl.TextColor3 = COL.text
colorLbl.TextSize = 12
colorLbl.Font = Enum.Font.Gotham
colorLbl.TextXAlignment = Enum.TextXAlignment.Left
colorLbl.Parent = colorRow

local colors = {
    {Color3.fromRGB(255,255,255), 0},
    {Color3.fromRGB(255,0,0), 40},
    {Color3.fromRGB(0,255,0), 80},
    {Color3.fromRGB(0,150,255), 120},
    {Color3.fromRGB(255,0,255), 160},
    {Color3.fromRGB(255,255,0), 200},
}
for _, c in ipairs(colors) do
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.fromOffset(28, 28)
    cb.Position = UDim2.new(0.5, 12 + c[2], 0.5, -14)
    cb.BackgroundColor3 = c[1]
    cb.Text = ""
    cb.Parent = colorRow
    Corner(cb, 14); Stroke(cb, COL.stroke, 1)
    cb.MouseButton1Click:Connect(function()
        AimFOVColor = c[1]
        UpdateFOVCircle()
    end)
end

--========== TAB FPS ===========
local fpsTickRefs = {}
fpsTickRefs.fpsToggle = CreateTick(PagePerf, 0, L("fpsToggle"), function(v)
    FPSOn = v
    if v then pcall(function() setfpscap(FPSValue) end)
    else pcall(function() setfpscap(60) end) end
end)
local fpsInput = CreateNumberInput(PagePerf, 40, L("fpsCustom"), 120, 30, 360, function(n)
    FPSValue = n
    if FPSOn then pcall(function() setfpscap(n) end) end
end)

local function FPSBtn(txt, x, y, val)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.3, 0, 0, 30)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    b.Text = txt
    b.TextColor3 = COL.textDim
    b.Font = Enum.Font.GothamBold
    b.Parent = PagePerf
    Corner(b, 4)
    b.MouseButton1Click:Connect(function()
        FPSValue = val
        pcall(function() setfpscap(val) end)
        b.BackgroundColor3 = COL.white
        b.TextColor3 = COL.black
    end)
end
FPSBtn("30", 10, 85, 30)
FPSBtn("60", 130, 85, 60)
FPSBtn("120", 250, 85, 120)
FPSBtn("240", 10, 120, 240)
FPSBtn("360", 130, 120, 360)

--========== TAB TP ===========
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.5, -10, 0, 38)
SaveBtn.Position = UDim2.fromOffset(5, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
SaveBtn.Text = L("savePos")
SaveBtn.TextColor3 = COL.text
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.Parent = PageTP
Corner(SaveBtn, 4)

local HomeBtn = Instance.new("TextButton")
HomeBtn.Size = UDim2.new(0.5, -10, 0, 38)
HomeBtn.Position = UDim2.new(0.5, 5, 0, 0)
HomeBtn.BackgroundColor3 = COL.white
HomeBtn.Text = L("goHome")
HomeBtn.TextColor3 = COL.black
HomeBtn.Font = Enum.Font.GothamBold
HomeBtn.Parent = PageTP
Corner(HomeBtn, 4)

local TPBox = Instance.new("TextBox")
TPBox.Size = UDim2.new(1, -10, 0, 38)
TPBox.Position = UDim2.fromOffset(5, 46)
TPBox.BackgroundColor3 = COL.card
TPBox.PlaceholderText = L("tpPlaceholder")
TPBox.PlaceholderColor3 = COL.textDim
TPBox.TextColor3 = COL.white
TPBox.Parent = PageTP
Corner(TPBox, 4); Stroke(TPBox, COL.stroke, 1)

local TPPlayerBtn = Instance.new("TextButton")
TPPlayerBtn.Size = UDim2.new(1, -10, 0, 38)
TPPlayerBtn.Position = UDim2.fromOffset(5, 92)
TPPlayerBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
TPPlayerBtn.Text = L("tpBtn")
TPPlayerBtn.TextColor3 = COL.text
TPPlayerBtn.Font = Enum.Font.GothamBold
TPPlayerBtn.Parent = PageTP
Corner(TPPlayerBtn, 4)

SaveBtn.MouseButton1Click:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        SavedPos = LP.Character.HumanoidRootPart.CFrame
        SaveBtn.Text = "OK!"
        task.delay(1, function() SaveBtn.Text = L("savePos") end)
    end
end)
HomeBtn.MouseButton1Click:Connect(function()
    if SavedPos and LP.Character then LP.Character:PivotTo(SavedPos) end
end)
TPPlayerBtn.MouseButton1Click:Connect(function()
    local name = string.lower(TPBox.Text)
    if name == "" then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and string.lower(p.Name):find(name) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LP.Character then
                LP.Character:PivotTo(p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3))
            end
            return
        end
    end
    TPBox.Text = "Not found!"
end)

--========== TAB BÓNG ĐÁ ===========
local ScoreInfo = Instance.new("TextLabel")
ScoreInfo.Size = UDim2.new(1, -20, 0, 20)
ScoreInfo.Position = UDim2.fromOffset(10, 115)
ScoreInfo.BackgroundTransparency = 1
ScoreInfo.Text = "Bóng: ✗ | Lưới địch: ✗"
ScoreInfo.TextColor3 = COL.textDim
ScoreInfo.Font = Enum.Font.GothamBold
ScoreInfo.TextSize = 9
ScoreInfo.TextXAlignment = Enum.TextXAlignment.Left
ScoreInfo.Parent = PageFoot

local scoreRefs = {}
scoreRefs.scoreAway = CreateTick(PageFoot, 0, L("scoreAway"), function(v)
    FootStates.AutoScoreAway = v
    if v then
        FootStates.AutoScoreHome = false
        if scoreRefs.scoreHome then scoreRefs.scoreHome.Set(false) end
    end
end)
scoreRefs.scoreHome = CreateTick(PageFoot, 38, L("scoreHome"), function(v)
    FootStates.AutoScoreHome = v
    if v then
        FootStates.AutoScoreAway = false
        if scoreRefs.scoreAway then scoreRefs.scoreAway.Set(false) end
    end
end)

local shootRefs = {}
shootRefs.shootToggle = CreateTick(PageFoot, 76, L("shootToggle"), function(v) FootStates.AutoShoot = v end)

local gkRefs = {}
gkRefs.gkHome = CreateTick(PageFoot, 126, L("gkHome"), function(v) FootStates.AutoGKHome = v end)
gkRefs.gkAway = CreateTick(PageFoot, 164, L("gkAway"), function(v) FootStates.AutoGKAway = v end)

--========== TAB CÀI ĐẶT ===========
local sysRefs = {}
sysRefs.speedToggle = CreateTick(PageSys, 0, L("speedToggle"), function(v) SpeedOn = v end)
local speedInput = CreateNumberInput(PageSys, 38, L("speedValue"), 100, 16, 1000, function(n) SpeedValue = n end)
sysRefs.flyToggle = CreateTick(PageSys, 76, L("flyToggle"), function(v)
    FlyOn = v
    if not v and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if hrp then local bv = hrp:FindFirstChild("BachFlyBV"); if bv then bv:Destroy() end end
        if h then h.PlatformStand = false end
    end
end)
local flyInput = CreateNumberInput(PageSys, 114, L("flyValue"), 60, 10, 500, function(n) FlySpeedValue = n end)
sysRefs.spinToggle = CreateTick(PageSys, 152, L("spinToggle"), function(v) SpinSpeed = v and math.rad(360) or 0 end)

local langTitle = Instance.new("TextLabel")
langTitle.Size = UDim2.new(1, -10, 0, 24)
langTitle.Position = UDim2.fromOffset(5, 190)
langTitle.BackgroundTransparency = 1
langTitle.Text = L("langTitle")
langTitle.TextColor3 = COL.text
langTitle.Font = Enum.Font.GothamBold
langTitle.TextSize = 11
langTitle.TextXAlignment = Enum.TextXAlignment.Left
langTitle.Parent = PageSys

local langVI = Instance.new("TextButton")
langVI.Size = UDim2.new(0.5, -10, 0, 32)
langVI.Position = UDim2.fromOffset(5, 218)
langVI.BackgroundColor3 = COL.white
langVI.Text = L("langVI")
langVI.TextColor3 = COL.black
langVI.Font = Enum.Font.GothamBold
langVI.TextSize = 12
langVI.Parent = PageSys
Corner(langVI, 4)

local langEN = Instance.new("TextButton")
langEN.Size = UDim2.new(0.5, -10, 0, 32)
langEN.Position = UDim2.new(0.5, 5, 0, 218)
langEN.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
langEN.Text = L("langEN")
langEN.TextColor3 = COL.textDim
langEN.Font = Enum.Font.GothamBold
langEN.TextSize = 12
langEN.Parent = PageSys
Corner(langEN, 4)

local LogoutBtn = Instance.new("TextButton")
LogoutBtn.Size = UDim2.new(1, -10, 0, 40)
LogoutBtn.Position = UDim2.fromOffset(5, 260)
LogoutBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 78)
LogoutBtn.Text = L("logout")
LogoutBtn.TextColor3 = COL.white
LogoutBtn.Font = Enum.Font.GothamBold
LogoutBtn.TextSize = 12
LogoutBtn.Parent = PageSys
Corner(LogoutBtn, 4)
LogoutBtn.MouseButton1Click:Connect(function()
    SaveDB({})
    Main.Visible = false
    OpenBtn.Visible = false
    KeyFrame.Visible = true
    KeyBox.Text = ""
    KeyStatus.Text = ""
end)

--========== TAB KHÁC ===========
local miscRefs = {}
miscRefs.antiAFK = CreateTick(PageMisc, 0, L("antiAFK"), function(v) AntiAFKOn = v end)
miscRefs.noClip = CreateTick(PageMisc, 38, L("noClip"), function(v)
    NoClipOn = v
    if not v and LP.Character then
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)
miscRefs.infiniteJump = CreateTick(PageMisc, 76, L("infiniteJump"), function(v) InfiniteJumpOn = v end)
miscRefs.chams = CreateTick(PageMisc, 114, L("chams"), function(v)
    ChamsOn = v
    if not v then
        for _, c in ipairs(ChamsCache) do
            if c and c.Parent then c:Destroy() end
        end
        ChamsCache = {}
    end
end)
miscRefs.xray = CreateTick(PageMisc, 152, L("xray"), function(v)
    XRayOn = v
    if not v then
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") and d.LocalTransparencyModifier ~= 0 then
                d.LocalTransparencyModifier = 0
            end
        end
    end
end)
miscRefs.antiCheat = CreateTick(PageMisc, 190, L("antiCheat"), function(v)
    AntiCheatBypassOn = true
    if not v then miscRefs.antiCheat.Set(true) end
end, true)

miscRefs.freeze = CreateTick(PageMisc, 228, L("freeze"), function(v)
    FreezeOn = v
    if freezeBtn then
        freezeBtn.BackgroundColor3 = v and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        freezeBtn.Visible = v -- CHỈ HIỆN NÚT TRÒN KHI BẬT
    end
    if v then
        PlayBeep()
    else
        ResetSelfFreeze()
    end
end)

miscRefs.freezeEnemies = CreateTick(PageMisc, 266, L("freezeEnemies"), function(v)
    FreezeEnemiesOn = v
    if freezeEnemyBtn then
        freezeEnemyBtn.BackgroundColor3 = v and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        freezeEnemyBtn.Visible = v -- CHỈ HIỆN NÚT TRÒN KHI BẬT
    end
    if v then
        PlayBeep()
        FreezeAllEnemies()
    else
        UnfreezeAllEnemies()
    end
end)

--========== ÂM THANH TÍT ===========
function PlayBeep()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://138082736"
        s.Volume = 1
        s.Parent = SoundService
        s:Play()
        task.delay(1, function() if s then s:Destroy() end end)
    end)
end

--========== FREEZE FUNCTIONS ===========
function ResetSelfFreeze()
    if LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if hrp then hrp.Anchored = false end
        if h then
            h.WalkSpeed = SpeedOn and SpeedValue or DEFAULT_SPEED
            h.JumpPower = DEFAULT_JUMP
            h.PlatformStand = false
        end
    end
end

function UnfreezeAllEnemies()
    for p, data in pairs(FrozenEnemies) do
        pcall(function()
            if data.char and data.char.Parent then
                local hrp = data.char:FindFirstChild("HumanoidRootPart")
                local h = data.char:FindFirstChildOfClass("Humanoid")
                if hrp then hrp.Anchored = false end
                if h then
                    h.WalkSpeed = data.walkSpeed or DEFAULT_SPEED
                    h.JumpPower = data.jumpPower or DEFAULT_JUMP
                    h.PlatformStand = false
                end
            end
        end)
    end
    FrozenEnemies = {}
end

function FreezeAllEnemies()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local h = char:FindFirstChildOfClass("Humanoid")
            if hrp and h then
                if not FrozenEnemies[p] then
                    FrozenEnemies[p] = {
                        char = char,
                        walkSpeed = h.WalkSpeed,
                        jumpPower = h.JumpPower,
                    }
                end
                hrp.Anchored = true
                h.WalkSpeed = 0
                h.JumpPower = 0
            end
        end
    end
end

--========== FREEZE BUTTONS ===========
local freezeBtn = Instance.new("TextButton")
freezeBtn.Size = UDim2.fromOffset(70, 70)
freezeBtn.Position = UDim2.new(0, 20, 1, -100)
freezeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
freezeBtn.Text = L("freezeBtn")
freezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
freezeBtn.TextSize = 11
freezeBtn.Font = Enum.Font.GothamBold
freezeBtn.Visible = false
freezeBtn.ZIndex = 300
freezeBtn.Parent = Gui
Corner(freezeBtn, 100); Stroke(freezeBtn, COL.white, 2)

local freezeEnemyBtn = Instance.new("TextButton")
freezeEnemyBtn.Size = UDim2.fromOffset(70, 70)
freezeEnemyBtn.Position = UDim2.new(0, 100, 1, -100)
freezeEnemyBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
freezeEnemyBtn.Text = L("freezeEnemyBtn")
freezeEnemyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
freezeEnemyBtn.TextSize = 10
freezeEnemyBtn.Font = Enum.Font.GothamBold
freezeEnemyBtn.Visible = false
freezeEnemyBtn.ZIndex = 300
freezeEnemyBtn.Parent = Gui
Corner(freezeEnemyBtn, 100); Stroke(freezeEnemyBtn, COL.white, 2)

local function SetupFreezeBtnDrag(btn)
    local fDrag, fStart, fPos, fMoved = false, nil, nil, false
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            fDrag = true; fMoved = false; fStart = i.Position; fPos = btn.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not fDrag then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - fStart
            if d.Magnitude > 3 then fMoved = true end
            btn.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if fDrag then fDrag = false end
        end
    end)
    btn.MouseButton1Click:Connect(function()
        if fMoved then fMoved = false; return end
    end)
end

SetupFreezeBtnDrag(freezeBtn)
SetupFreezeBtnDrag(freezeEnemyBtn)

freezeBtn.MouseButton1Click:Connect(function()
    FreezeOn = not FreezeOn
    freezeBtn.BackgroundColor3 = FreezeOn and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    if FreezeOn then
        PlayBeep()
    else
        ResetSelfFreeze()
        freezeBtn.Visible = false -- ẨN NÚT KHI TẮT
    end
    if miscRefs.freeze then miscRefs.freeze.Set(FreezeOn) end
end)

freezeEnemyBtn.MouseButton1Click:Connect(function()
    FreezeEnemiesOn = not FreezeEnemiesOn
    freezeEnemyBtn.BackgroundColor3 = FreezeEnemiesOn and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    if FreezeEnemiesOn then
        PlayBeep()
        FreezeAllEnemies()
    else
        UnfreezeAllEnemies()
        freezeEnemyBtn.Visible = false -- ẨN NÚT KHI TẮT
    end
    if miscRefs.freezeEnemies then miscRefs.freezeEnemies.Set(FreezeEnemiesOn) end
end)

--========== UPDATE LANGUAGE ===========
local function UpdateLanguage()
    TabESP.Text = L("tabESP"); TabAim.Text = L("tabAim"); TabPerf.Text = L("tabPerf")
    TabTP.Text = L("tabTP"); TabFoot.Text = L("tabFoot"); TabSys.Text = L("tabSys"); TabMisc.Text = L("tabMisc")
    espTickRefs.espToggle.SetText(L("espToggle"))
    espTickRefs.espHL.SetText(L("espHL"))
    espTickRefs.espLine.SetText(L("espLine"))
    espTickRefs.espName.SetText(L("espName"))
    espTickRefs.espHP.SetText(L("espHP"))
    espTickRefs.espDist.SetText(L("espDist"))
    espTickRefs.espHitbox.SetText(L("espHitbox"))
    aimTickRefs.aimToggle.SetText(L("aimToggle"))
    aimTickRefs.aimFOVShow.SetText(L("aimFOVShow"))
    aimFOVInput.SetLabel(L("aimFOV"))
    colorLbl.Text = L("aimFOVColor")
    fpsTickRefs.fpsToggle.SetText(L("fpsToggle"))
    fpsInput.SetLabel(L("fpsCustom"))
    SaveBtn.Text = L("savePos"); HomeBtn.Text = L("goHome")
    TPBox.PlaceholderText = L("tpPlaceholder"); TPPlayerBtn.Text = L("tpBtn")
    scoreRefs.scoreAway.SetText(L("scoreAway"))
    scoreRefs.scoreHome.SetText(L("scoreHome"))
    shootRefs.shootToggle.SetText(L("shootToggle"))
    gkRefs.gkHome.SetText(L("gkHome")); gkRefs.gkAway.SetText(L("gkAway"))
    sysRefs.speedToggle.SetText(L("speedToggle")); speedInput.SetLabel(L("speedValue"))
    sysRefs.flyToggle.SetText(L("flyToggle")); flyInput.SetLabel(L("flyValue"))
    sysRefs.spinToggle.SetText(L("spinToggle"))
    langTitle.Text = L("langTitle"); langVI.Text = L("langVI"); langEN.Text = L("langEN")
    if miscRefs then
        miscRefs.antiAFK.SetText(L("antiAFK"))
        miscRefs.noClip.SetText(L("noClip"))
        miscRefs.infiniteJump.SetText(L("infiniteJump"))
        miscRefs.chams.SetText(L("chams"))
        miscRefs.xray.SetText(L("xray"))
        miscRefs.antiCheat.SetText(L("antiCheat"))
        miscRefs.freeze.SetText(L("freeze"))
        miscRefs.freezeEnemies.SetText(L("freezeEnemies"))
    end
    LogoutBtn.Text = L("logout")
    if freezeBtn then freezeBtn.Text = L("freezeBtn") end
    if freezeEnemyBtn then freezeEnemyBtn.Text = L("freezeEnemyBtn") end
end

langVI.MouseButton1Click:Connect(function()
    LANG = "vi"
    langVI.BackgroundColor3 = COL.white; langVI.TextColor3 = COL.black
    langEN.BackgroundColor3 = Color3.fromRGB(36, 36, 42); langEN.TextColor3 = COL.textDim
    UpdateLanguage()
end)
langEN.MouseButton1Click:Connect(function()
    LANG = "en"
    langEN.BackgroundColor3 = COL.white; langEN.TextColor3 = COL.black
    langVI.BackgroundColor3 = Color3.fromRGB(36, 36, 42); langVI.TextColor3 = COL.textDim
    UpdateLanguage()
end)

--========== LOGIC CHÍNH ===========
LP.Idled:Connect(function()
    if AntiAFKOn then
        pcall(function() game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0)) end)
        task.wait(0.1)
        pcall(function() game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0)) end)
    end
end)

UIS.JumpRequest:Connect(function()
    if InfiniteJumpOn and LP.Character then
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Anti-Cheat Bypass luôn chạy
task.spawn(function()
    while true do
        task.wait(1)
        if AntiCheatBypassOn then
            pcall(function()
                if LP.Character then
                    local h = LP.Character:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then
                        h:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                    end
                end
            end)
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    -- No Clip
    if NoClipOn and LP.Character then
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    -- Freeze Self
    if LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if hrp and h then
            if FreezeOn then
                if not hrp.Anchored then hrp.Anchored = true end
                if h.WalkSpeed ~= 0 then h.WalkSpeed = 0 end
                if h.JumpPower ~= 0 then h.JumpPower = 0 end
            else
                if hrp.Anchored and not FlyOn and not FrozenEnemies[LP] then
                    hrp.Anchored = false
                end
                if h.WalkSpeed == 0 and not SpeedOn then
                    h.WalkSpeed = DEFAULT_SPEED
                elseif SpeedOn and h.WalkSpeed ~= SpeedValue then
                    h.WalkSpeed = SpeedValue
                end
                if h.JumpPower == 0 then
                    h.JumpPower = DEFAULT_JUMP
                end
            end
        end
    end
    -- Freeze Enemies
    if FreezeEnemiesOn then
        FreezeAllEnemies()
    end
    -- X-Ray
    if XRayOn then
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") and d.Name ~= "BachHitbox" then
                d.LocalTransparencyModifier = 0.5
            end
        end
    end
    -- Chams
    if ChamsOn then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local char = p.Character
                if not char:FindFirstChild("BachChams") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "BachChams"
                    hl.Adornee = char
                    hl.FillColor = ChamsColor
                    hl.OutlineColor = ChamsColor
                    hl.FillTransparency = 0.3
                    hl.Parent = char
                    table.insert(ChamsCache, hl)
                end
            end
        end
    end
end)

--========== LOGIC BÓNG ĐÁ ===========
local BallCache = nil
local GoalNetCache = {Home = nil, Away = nil}
local lastBallScan = 0
local scanInterval = 0.5

local function FindBall()
    if BallCache and BallCache.Parent then return BallCache end
    BallCache = nil
    local kws = {"ball", "soccer", "football", "bóng", "bong"}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local lower = obj.Name:lower()
            for _, kw in ipairs(kws) do
                if lower:find(kw) then BallCache = obj; return obj end
            end
        end
    end
    return nil
end

local function FindGoalNet(side)
    if GoalNetCache[side] and GoalNetCache[side].Parent then return GoalNetCache[side] end
    GoalNetCache[side] = nil
    local kws
    if side == "Away" then
        kws = {"goalaway","netaway","enemynet","goalred","netred"}
    else
        kws = {"goalhome","nethome","allynet","goalblue","netblue"}
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local lower = obj.Name:lower()
            for _, kw in ipairs(kws) do
                if lower:find(kw) then GoalNetCache[side] = obj; return obj end
            end
        end
    end
    return nil
end

local function ScoreGoalTo(side)
    local ball = FindBall(); if not ball then return false end
    local net = FindGoalNet(side); if not net then return false end
    pcall(function() ball.CFrame = net.CFrame; ball.Velocity = Vector3.zero end)
    return true
end

local function ShootBallTo(side)
    local ball = FindBall(); if not ball then return false end
    local net = FindGoalNet(side); if not net then return false end
    pcall(function()
        local bv = ball:FindFirstChild("BachShootBV") or Instance.new("BodyVelocity")
        bv.Name = "BachShootBV"
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = (net.Position - ball.Position).Unit * 400 + Vector3.new(0, 80, 0)
        bv.Parent = ball
        task.delay(0.4, function() if bv and bv.Parent then bv:Destroy() end end)
    end)
    return true
end

local function GKFollow(side)
    local ball = FindBall(); if not ball then return end
    local net = FindGoalNet(side); if not net then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dir = (ball.Position - net.Position).Unit
    local targetPos = net.Position + dir * 5
    hrp.CFrame = CFrame.new(targetPos, ball.Position)
end

local lastScoreTime, lastShootTime = 0, 0

RunService.Heartbeat:Connect(function(dt)
    local now = tick()
    if now - lastBallScan >= scanInterval then
        lastBallScan = now
        FindBall()
        if FootStates.AutoScoreAway or FootStates.AutoShoot then FindGoalNet("Away") end
        if FootStates.AutoScoreHome then FindGoalNet("Home") end
        local ball = BallCache and BallCache.Parent and "✓" or "✗"
        local away = GoalNetCache.Away and GoalNetCache.Away.Parent and "✓" or "✗"
        ScoreInfo.Text = "Bóng: " .. ball .. " | Lưới địch: " .. away
    end
    if FootStates.AutoScoreAway and now - lastScoreTime >= 0.5 then
        lastScoreTime = now
        pcall(function() ScoreGoalTo("Away") end)
    end
    if FootStates.AutoScoreHome and now - lastScoreTime >= 0.5 then
        lastScoreTime = now
        pcall(function() ScoreGoalTo("Home") end)
    end
    if FootStates.AutoShoot and now - lastShootTime >= 0.3 then
        lastShootTime = now
        pcall(function() ShootBallTo("Away") end)
    end
    if FootStates.AutoGKHome then pcall(function() GKFollow("Home") end) end
    if FootStates.AutoGKAway then pcall(function() GKFollow("Away") end) end
end)

--========== ESP ===========
local lastESPUpdate, lastTextUpdate = 0, 0

local function CleanupESPForPlayer(p)
    local cache = ESPCache[p]
    if not cache then return end
    if cache.HL then cache.HL:Destroy() end
    if cache.Beam then cache.Beam:Destroy() end
    if cache.TopAtt then cache.TopAtt:Destroy() end
    if cache.Att then cache.Att:Destroy() end
    if cache.BB then cache.BB:Destroy() end
    if cache.Hitbox then cache.Hitbox:Destroy() end
    ESPCache[p] = nil
end

local function UpdateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not head or not hrp then continue end
            local cache = ESPCache[p]
            if not cache then cache = {}; ESPCache[p] = cache end

            if ESP.HL then
                if not cache.HL then
                    local hl = Instance.new("Highlight")
                    hl.Name = "BachESP_HL"
                    hl.Adornee = char
                    hl.FillColor = Color3.fromRGB(255,255,255)
                    hl.OutlineColor = Color3.fromRGB(0,0,0)
                    hl.FillTransparency = 0.5
                    hl.Parent = char
                    cache.HL = hl
                end
            else
                if cache.HL then cache.HL:Destroy(); cache.HL = nil end
            end

            if ESP.Hitbox then
                if not cache.Hitbox then
                    local hb = Instance.new("Part")
                    hb.Name = "BachHitbox"
                    hb.Size = Vector3.new(4, 6, 2)
                    hb.Transparency = 0.7
                    hb.Color = Color3.fromRGB(255,255,255)
                    hb.Material = Enum.Material.Neon
                    hb.CanCollide = false
                    hb.Anchored = true
                    hb.Parent = workspace
                    cache.Hitbox = hb
                end
                cache.Hitbox.CFrame = hrp.CFrame
            else
                if cache.Hitbox then cache.Hitbox:Destroy(); cache.Hitbox = nil end
            end

            if ESP.Line then
                if not cache.Beam then
                    local att = Instance.new("Attachment"); att.Name = "BachLineAtt"; att.Parent = head
                    local topAtt = Instance.new("Attachment"); topAtt.Name = "BachLineTop"; topAtt.Parent = hrp
                    topAtt.Position = Vector3.new(0, 500, 0)
                    local beam = Instance.new("Beam")
                    beam.Name = "BachBlackLine"
                    beam.Color = ColorSequence.new(Color3.fromRGB(0,0,0))
                    beam.Width0 = 0.3; beam.Width1 = 0.3
                    beam.FaceCamera = true
                    beam.LightEmission = 0
                    beam.Segments = 1
                    beam.Transparency = NumberSequence.new(0.2)
                    beam.Attachment0 = att
                    beam.Attachment1 = topAtt
                    beam.Parent = hrp
                    cache.Beam = beam; cache.TopAtt = topAtt; cache.Att = att
                end
            else
                if cache.Beam then cache.Beam:Destroy(); cache.Beam = nil end
                if cache.TopAtt then cache.TopAtt:Destroy(); cache.TopAtt = nil end
                if cache.Att then cache.Att:Destroy(); cache.Att = nil end
            end

            local needText = ESP.Name or ESP.HP or ESP.Dist
            if needText then
                if not cache.BB then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "BachESP_BB"
                    bb.Size = UDim2.new(0, 200, 0, 50)
                    bb.AlwaysOnTop = true
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.Adornee = head
                    bb.Parent = head
                    local txt = Instance.new("TextLabel")
                    txt.Name = "BachESP_Txt"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(255,255,255)
                    txt.TextStrokeTransparency = 0
                    txt.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                    txt.TextSize = 14
                    txt.Font = Enum.Font.GothamBold
                    txt.Text = ""
                    txt.Parent = bb
                    cache.BB = bb; cache.Txt = txt
                end
            else
                if cache.BB then cache.BB:Destroy(); cache.BB = nil; cache.Txt = nil end
            end
        end
    end
end

local function UpdateESPText()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local cache = ESPCache[p]
            if cache and cache.Txt and cache.BB then
                local char = p.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local s = ""
                if ESP.Name then s = s .. p.Name .. "\n" end
                if ESP.HP then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then s = s .. "HP: " .. math.floor(hum.Health) .. "\n" end
                end
                if ESP.Dist and hrp then
                    s = s .. "KC: " .. math.floor((Cam.CFrame.Position - hrp.Position).Magnitude) .. "m"
                end
                cache.Txt.Text = s
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(p)
    if ESPCache[p] then CleanupESPForPlayer(p) end
    if FrozenEnemies[p] then FrozenEnemies[p] = nil end
end)

--========== SPEED / FLY / AIM ===========
RunService.Heartbeat:Connect(function(dt)
    if LP.Character then
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if h then
            if SpeedOn then
                if h.WalkSpeed ~= SpeedValue then h.WalkSpeed = SpeedValue end
            else
                if h.WalkSpeed == SpeedValue or h.WalkSpeed == 1000 then h.WalkSpeed = DEFAULT_SPEED end
            end
        end
    end
    if FlyOn and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if hrp and h then
            if not h.PlatformStand then h.PlatformStand = true end
            local bv = hrp:FindFirstChild("BachFlyBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "BachFlyBV"
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Parent = hrp
            end
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            bv.Velocity = dir.Magnitude > 0 and (dir.Unit * FlySpeedValue) or Vector3.zero
        end
    end
    if SpinSpeed > 0 and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            flyAngle = flyAngle + SpinSpeed * dt
            if flyAngle > math.pi * 2 then flyAngle = flyAngle - math.pi * 2 end
            local newLook = Vector3.new(math.cos(flyAngle), 0, math.sin(flyAngle))
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + newLook)
        end
    end
    lastESPUpdate = lastESPUpdate + dt
    if lastESPUpdate >= 0.1 then
        lastESPUpdate = 0
        if ESP.Player then UpdateESP() end
    end
    lastTextUpdate = lastTextUpdate + dt
    if lastTextUpdate >= 0.3 then
        lastTextUpdate = 0
        if ESP.Player then UpdateESPText() end
    end
end)

RunService.RenderStepped:Connect(function()
    if not AimOn or not LP.Character then return end
    local closest, dist = nil, math.huge
    local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local pos, onScreen = Cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local screenPos = Vector2.new(pos.X, pos.Y)
                    local m = (screenPos - center).Magnitude
                    if m < dist and m <= AimFOV/2 then dist = m; closest = head end
                end
            end
        end
    end
    if closest then
        Cam.CFrame = CFrame.new(Cam.CFrame.Position, closest.Position)
    end
end)

--========== KEY CHECK ===========
CheckBtn.MouseButton1Click:Connect(function()
    local key = string.gsub(KeyBox.Text, "^%s*(.-)%s*$", "%1")
    if key == "" then
        KeyStatus.TextColor3 = Color3.fromRGB(255,80,80)
        KeyStatus.Text = "Vui lòng nhập Key!"
        return
    end
    KeyStatus.TextColor3 = COL.white
    KeyStatus.Text = "Đang kiểm tra Key..."
    CheckBtn.Text = "ĐANG CHECK..."
    CheckBtn.BackgroundColor3 = Color3.fromRGB(120,120,130)
    local match = string.match(key, "^BACH%-(%u+)%-(%w+)%-(%w+)$")
    local isValid = false
    local keyType = nil
    if match then
        keyType = match
        local validTypes = {["1H"]=true, ["24H"]=true, ["1M"]=true, ["VIP"]=true}
        if validTypes[keyType] then isValid = true end
    end
    task.wait(1.2)
    CheckBtn.Text = "CHECK KEY"
    CheckBtn.BackgroundColor3 = COL.white
    if isValid then
        local db = LoadDB()
        if db[key] then
            if db[key].hwid == HWID then
                KeyStatus.TextColor3 = Color3.fromRGB(100,255,100)
                KeyStatus.Text = "Key hợp lệ! Đang tải..."
                task.wait(0.8)
                KeyFrame.Visible = false
                Main.Visible = true
                OpenBtn.Visible = true
                SetTab(TabESP)
            else
                KeyStatus.TextColor3 = Color3.fromRGB(255,80,80)
                KeyStatus.Text = "Key này đã được dùng trên thiết bị khác!"
            end
        else
            db[key] = {hwid = HWID, type = keyType, time = tick()}
            SaveDB(db)
            KeyStatus.TextColor3 = Color3.fromRGB(100,255,100)
            KeyStatus.Text = "Key hợp lệ! Đã đăng ký thiết bị.\nĐang tải..."
            task.wait(0.8)
            KeyFrame.Visible = false
            Main.Visible = true
            OpenBtn.Visible = true
            SetTab(TabESP)
        end
    else
        KeyStatus.TextColor3 = Color3.fromRGB(255,80,80)
        KeyStatus.Text = "Key không hợp lệ! Phải đúng format:\nBACH-1H-XXXXXX-XXXXXX\nBACH-24H-XXXXXX-XXXXXX\nBACH-1M-XXXXXX-XXXXXX\nBACH-VIP-XXXXXX-XXXXXX"
    end
end)

print("[BACH V16] Đã load - FIX LỖI HIỆN NÚT FREEZE + HOÀN HẢO!")

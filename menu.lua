--==================================================
-- BÁCH PREMIUM MENU (FULL FIXED: FIX LAG + HWID + PERSISTENT TIMER)
-- MADE BY NSMOD
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DEFAULT_SPEED = 16
local SpeedOn = false
local FlyOn = false
local LightLagOn = false
local StrongLagOn = false
local AimOn = false

-- HỆ THỐNG LƯU TRỮ CỤC BỘ (HWID & THỜI GIAN THỰC)
local DBFileName = "BachPremium_KeyDatabase.json"
local HWID = ""
pcall(function()
	HWID = game:GetService("RbxAnalyticsService"):GetClientId()
end)
if not HWID or HWID == "" then
	HWID = tostring(Player.UserId)
end

local function LoadDatabase()
	local success, data = pcall(function()
		if isfile and isfile(DBFileName) and readfile then
			return HttpService:JSONDecode(readfile(DBFileName))
		end
	end)
	if success and type(data) == "table" then
		return data
	end
	return {}
end

local function SaveDatabase(db)
	pcall(function()
		if writefile then
			writefile(DBFileName, HttpService:JSONEncode(db))
		end
	end)
end

local KeyAbsoluteExpiry = 0
local IsKeyLifetime = false
local CurrentLang = "VIE"

local Translations = {
	VIE = {
		Title = "BÁCH PREMIUM",
		SubKey = "Hệ thống Key • MADE BY NSMOD",
		KeyPlace = "Nhập Key hệ thống...",
		CheckKey = "✓ CHECK KEY",
		ErrKey = "✕ Vui lòng nhập Key hợp lệ!",
		ErrUsedDevice = "✕ Key này đã được kích hoạt trên thiết bị khác!",
		ErrExpired = "✕ Key này đã hết hạn sử dụng!",
		Dev = "✓ Thiết bị: ",
		Time = "\n⏰ Giờ nhập: ",
		Exp = "\n⏳ Thời hạn: ",
		Exp1h = "1 Giờ",
		Exp24h = "24 Giờ",
		Exp1m = "1 Tháng",
		Exp1y = "1 Năm",
		ExpLife = "Vĩnh viễn",
		LoadingInit = "Đang khởi tạo giao diện...",
		LoadingFeatures = "Đang tải tính năng Aimbot & ESP...",
		LoadingDone = "Hoàn tất...",
		TabMove = "MOVE",
		TabESP = "ESP",
		TabAim = "AIM",
		TabPerf = "PERF",
		TabSys = "SYS",
		WalkSpeed = "⚡ WALK SPEED",
		FlyMode = "✈ FLY MODE",
		FlySpeedLbl = "Tốc độ bay (10-1000)",
		EspPlayer = "ESP Player (tổng)",
		EspHighlight = "ESP Highlight",
		EspBox = "ESP Hộp (Box)",
		EspLine = "ESP Dây (thẳng lên trời)",
		EspName = "ESP Tên",
		EspHealth = "ESP Máu",
		EspDist = "ESP Khoảng cách (m)",
		EspHead = "ESP Đầu",
		EspTeam = "ESP Đồng đội",
		AimTitle = "🎯 FULL AIMBOT",
		AimOn = "AIMBOT: ON",
		AimOff = "AIMBOT: OFF",
		FixLagLight = "⚡ FIX LAG NHẸ\n",
		FixLagStrong = "🔥 FIX LAG MẠNH\n",
		ResetChar = "↻ RESET NHÂN VẬT",
		LangLbl = "🌐 NGÔN NGỮ / LANGUAGE",
		KeyInfoTitle = "🔑 THÔNG TIN KEY SỬ DỤNG",
		DeviceLbl = "📱 Máy: ",
		TimeRemainingLbl = "⏳ Hạn Key: ",
		KeyExpiredMsg = "⚠️ HẾT THỜI HẠN KEY! ĐANG VỀ MÀN HÌNH CHỜ..."
	},
	ENG = {
		Title = "BACH PREMIUM",
		SubKey = "Key System • MADE BY NSMOD",
		KeyPlace = "Enter system key...",
		CheckKey = "✓ CHECK KEY",
		ErrKey = "✕ Please enter a valid key!",
		ErrUsedDevice = "✕ Key already used on another device!",
		ErrExpired = "✕ Key has expired!",
		Dev = "✓ Device: ",
		Time = "\n⏰ Login time: ",
		Exp = "\n⏳ Duration: ",
		Exp1h = "1 Hour",
		Exp24h = "24 Hours",
		Exp1m = "1 Month",
		Exp1y = "1 Year",
		ExpLife = "Lifetime",
		LoadingInit = "Initializing interface...",
		LoadingFeatures = "Loading Aimbot & ESP...",
		LoadingDone = "Completed...",
		TabMove = "MOVE",
		TabESP = "ESP",
		TabAim = "AIM",
		TabPerf = "PERF",
		TabSys = "SYS",
		WalkSpeed = "⚡ WALK SPEED",
		FlyMode = "✈ FLY MODE",
		FlySpeedLbl = "Fly speed (10-1000)",
		EspPlayer = "ESP Player (All)",
		EspHighlight = "ESP Highlight",
		EspBox = "ESP Box",
		EspLine = "ESP Line (Sky)",
		EspName = "ESP Name",
		EspHealth = "ESP Health",
		EspDist = "ESP Distance (m)",
		EspHead = "ESP Head",
		EspTeam = "ESP Team",
		AimTitle = "🎯 FULL AIMBOT",
		AimOn = "AIMBOT: ON",
		AimOff = "AIMBOT: OFF",
		FixLagLight = "⚡ LIGHT FIX LAG\n",
		FixLagStrong = "🔥 STRONG FIX LAG\n",
		ResetChar = "↻ RESET CHARACTER",
		LangLbl = "🌐 NGÔN NGỮ / LANGUAGE",
		KeyInfoTitle = "🔑 KEY & DEVICE INFO",
		DeviceLbl = "📱 Device: ",
		TimeRemainingLbl = "⏳ Key Expiry: ",
		KeyExpiredMsg = "⚠️ KEY EXPIRED! RETURNING TO LOGIN..."
	},
	CHS = {
		Title = "BÁCH 辅助菜单",
		SubKey = "密钥系统 • MADE BY NSMOD",
		KeyPlace = "输入系统密钥...",
		CheckKey = "✓ 验证密钥",
		ErrKey = "✕ 请输入有效密钥！",
		ErrUsedDevice = "✕ 此密钥已在其他设备上使用！",
		ErrExpired = "✕ 密钥已过期！",
		Dev = "✓ 设备: ",
		Time = "\n⏰ 登录时间: ",
		Exp = "\n⏳ 有效期: ",
		Exp1h = "1小时",
		Exp24h = "24小时",
		Exp1m = "1个月",
		Exp1y = "1年",
		ExpLife = "永久",
		LoadingInit = "正在初始化界面...",
		LoadingFeatures = "正在加载 Aimbot 与 ESP...",
		LoadingDone = "完成...",
		TabMove = "移动",
		TabESP = "透视",
		TabAim = "自喵",
		TabPerf = "优化",
		TabSys = "系统",
		WalkSpeed = "⚡ 移动速度",
		FlyMode = "✈ 飞行模式",
		FlySpeedLbl = "飞行速度 (10-1000)",
		EspPlayer = "ESP 玩家 (总)",
		EspHighlight = "ESP 高亮",
		EspBox = "ESP 方框",
		EspLine = "ESP 射线 (通天)",
		EspName = "ESP 名字",
		EspHealth = "ESP 血量",
		EspDist = "ESP 距离 (m)",
		EspHead = "ESP 头部",
		EspTeam = "ESP 队友",
		AimTitle = "🎯 全自动自喵",
		AimOn = "自喵: 开启",
		AimOff = "自喵: 关闭",
		FixLagLight = "⚡ 轻度防卡顿\n",
		FixLagStrong = "🔥 深度防卡顿\n",
		ResetChar = "↻ 重置角色",
		LangLbl = "🌐 NGÔN NGỮ / LANGUAGE",
		KeyInfoTitle = "🔑 密钥与设备信息",
		DeviceLbl = "📱 设备: ",
		TimeRemainingLbl = "⏳ 剩余时间: ",
		KeyExpiredMsg = "⚠️ 密钥已到期！正在返回登录界面..."
	},
	JPN = {
		Title = "BÁCH プレミアム",
		SubKey = "キーシステム • MADE BY NSMOD",
		KeyPlace = "キーを入力してください...",
		CheckKey = "✓ キー認証",
		ErrKey = "✕ 有効なキーを入力してください！",
		ErrUsedDevice = "✕ このキーは他の端末で使用されています！",
		ErrExpired = "✕ キーの有効期限が切れています！",
		Dev = "✓ 端末: ",
		Time = "\n⏰ 認証時間: ",
		Exp = "\n⏳ 有効期限: ",
		Exp1h = "1時間",
		Exp24h = "24時間",
		Exp1m = "1ヶ月",
		Exp1y = "1年",
		ExpLife = "無制限",
		LoadingInit = "UIを初期化中...",
		LoadingFeatures = "機能ロード中...",
		LoadingDone = "完了...",
		TabMove = "移動",
		TabESP = "ESP",
		TabAim = "エイム",
		TabPerf = "軽量化",
		TabSys = "設定",
		WalkSpeed = "⚡ 移動速度",
		FlyMode = "✈ 飛行モード",
		FlySpeedLbl = "飛行速度 (10-1000)",
		EspPlayer = "ESP プレイヤー",
		EspHighlight = "ESP ハイライト",
		EspBox = "ESP ボックス",
		EspLine = "ESP ライン (天まで)",
		EspName = "ESP 名前",
		EspHealth = "ESP 体力",
		EspDist = "ESP 距離 (m)",
		EspHead = "ESP 頭部",
		EspTeam = "ESP チーム",
		AimTitle = "🎯 フルエイムボット",
		AimOn = "エイム: ON",
		AimOff = "エイム: OFF",
		FixLagLight = "⚡ 軽度ラグ軽減\n",
		FixLagStrong = "🔥 重度ラグ軽減\n",
		ResetChar = "↻ キャラクターリセット",
		LangLbl = "🌐 言語選択 / LANGUAGE",
		KeyInfoTitle = "🔑 キー情報 & デバイス",
		DeviceLbl = "📱 デバイス: ",
		TimeRemainingLbl = "⏳ 残り時間: ",
		KeyExpiredMsg = "⚠️ キーの期限が切れました！"
	},
	KOR = {
		Title = "BÁCH 프리미엄",
		SubKey = "키 시스템 • MADE BY NSMOD",
		KeyPlace = "키를 입력하세요...",
		CheckKey = "✓ 키 확인",
		ErrKey = "✕ 올바른 키를 입력하세요!",
		ErrUsedDevice = "✕ 다른 기기에서 이미 사용된 키입니다!",
		ErrExpired = "✕ 만료된 키입니다!",
		Dev = "✓ 기기: ",
		Time = "\n⏰ 접속 시간: ",
		Exp = "\n⏳ 유효 기간: ",
		Exp1h = "1시간",
		Exp24h = "24시간",
		Exp1m = "1개월",
		Exp1y = "1년",
		ExpLife = "영구",
		LoadingInit = "인터페이스 초기화 중...",
		LoadingFeatures = "기능 로딩 중...",
		LoadingDone = "완료...",
		TabMove = "이동",
		TabESP = "ESP",
		TabAim = "에임",
		TabPerf = "최적화",
		TabSys = "설정",
		WalkSpeed = "⚡ 이동 속도",
		FlyMode = "✈ 비행 모드",
		FlySpeedLbl = "비행 속도 (10-1000)",
		EspPlayer = "ESP 플레이어",
		EspHighlight = "ESP 하이라이트",
		EspBox = "ESP 박스",
		EspLine = "ESP 라인 (하늘)",
		EspName = "ESP 이름",
		EspHealth = "ESP 체력",
		EspDist = "ESP 거리 (m)",
		EspHead = "ESP 머리",
		EspTeam = "ESP 팀",
		AimTitle = "🎯 풀 에임봇",
		AimOn = "에임: ON",
		AimOff = "에임: OFF",
		FixLagLight = "⚡ 일반 렉 줄이기\n",
		FixLagStrong = "🔥 강력 렉 줄이기\n",
		ResetChar = "↻ 캐릭터 리셋",
		LangLbl = "🌐 언어 선택 / LANGUAGE",
		KeyInfoTitle = "🔑 키 정보 및 기기",
		DeviceLbl = "📱 기기: ",
		TimeRemainingLbl = "⏳ 남은 시간: ",
		KeyExpiredMsg = "⚠️ 키 유효기간 만료! 로그인 화면으로 이동..."
	},
	RUS = {
		Title = "BÁCH ПРЕМИУМ",
		SubKey = "Система Ключей • MADE BY NSMOD",
		KeyPlace = "Введите ключ...",
		CheckKey = "✓ ПРОВЕРИТЬ КЛЮЧ",
		ErrKey = "✕ Введите действительный ключ!",
		ErrUsedDevice = "✕ Ключ уже используется на другом устройстве!",
		ErrExpired = "✕ Срок действия ключа истек!",
		Dev = "✓ Устройство: ",
		Time = "\n⏰ Время входа: ",
		Exp = "\n⏳ Срок: ",
		Exp1h = "1 Час",
		Exp24h = "24 Часа",
		Exp1m = "1 Месяц",
		Exp1y = "1 Год",
		ExpLife = "Навсегда",
		LoadingInit = "Инициализация...",
		LoadingFeatures = "Загрузка функций...",
		LoadingDone = "Готово...",
		TabMove = "ДВИЖ",
		TabESP = "ESP",
		TabAim = "АИМ",
		TabPerf = "ОПТИМ",
		TabSys = "НАСТР",
		WalkSpeed = "⚡ СКОРОСТЬ ХОДЬБЫ",
		FlyMode = "✈ РЕЖИМ ПОЛЕТА",
		FlySpeedLbl = "Скорость полета (10-1000)",
		EspPlayer = "ESP Игроки",
		EspHighlight = "ESP Подсветка",
		EspBox = "ESP Боксы",
		EspLine = "ESP Линии в небо",
		EspName = "ESP Имя",
		EspHealth = "ESP Здоровье",
		EspDist = "ESP Дистанция (m)",
		EspHead = "ESP Голова",
		EspTeam = "ESP Команда",
		AimTitle = "🎯 ПОЛНЫЙ АИМБОТ",
		AimOn = "АИМ: ВКЛ",
		AimOff = "АИМ: ВЫКЛ",
		FixLagLight = "⚡ ЛЕГКАЯ ОПТИМИЗАЦИЯ\n",
		FixLagStrong = "🔥 СИЛЬНАЯ ОПТИМИЗАЦИЯ\n",
		ResetChar = "↻ СБРОС ПЕРСОНАЖА",
		LangLbl = "🌐 ЯЗЫК / LANGUAGE",
		KeyInfoTitle = "🔑 ИНФО О КЛЮЧЕ И УСТРОЙСТВЕ",
		DeviceLbl = "📱 Устройство: ",
		TimeRemainingLbl = "⏳ Осталось: ",
		KeyExpiredMsg = "⚠️ СРОК ДЕЙСТВИЯ КЛЮЧА ИСТЕК!"
	}
}

local ESP = {
	Player = false,
	Highlight = false,
	Box = false,
	Line = false,
	Name = false,
	Health = false,
	Distance = false,
	Head = false,
	Team = false,
}

local ESPColor = Color3.fromRGB(255, 60, 60)
local ESPTeamColor = Color3.fromRGB(60, 255, 60)

pcall(function()
	for _, v in ipairs(CoreGui:GetChildren()) do
		if v.Name == "BachPremium" then v:Destroy() end
	end
end)
pcall(function()
	local pg = Player:FindFirstChild("PlayerGui")
	if pg then
		for _, v in ipairs(pg:GetChildren()) do
			if v.Name == "BachPremium" then v:Destroy() end
		end
	end
end)

for _, v in ipairs(game:GetDescendants()) do
	if v.Name:find("BachESP") then
		pcall(function() v:Destroy() end)
	end
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "BachPremium"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local successParent = pcall(function()
	Gui.Parent = CoreGui
end)
if not successParent then
	Gui.Parent = Player:WaitForChild("PlayerGui")
end

local function Corner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = obj
end

local function Stroke(obj, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(255, 200, 0)
	s.Thickness = thickness or 1
	s.Parent = obj
	return s
end

local function Gradient(obj)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 70)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 170, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 0))
	})
	g.Rotation = 25
	g.Parent = obj
end

local function MakeDraggable(Object, Handle)
	local Dragging = false
	local DragStart
	local StartPos
	local Moved = false

	Handle.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			Moved = false
			DragStart = Input.Position
			StartPos = Object.Position
		end
	end)

	UIS.InputChanged:Connect(function(Input)
		if not Dragging then return end
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			local Delta = Input.Position - DragStart
			if Delta.Magnitude > 3 then
				Moved = true
			end
			Object.Position = UDim2.new(
				StartPos.X.Scale, StartPos.X.Offset + Delta.X,
				StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
			)
		end
	end)

	UIS.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = false
		end
	end)

	return function() return Moved end
end

-- KEY FRAME
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.fromOffset(410, 310)
KeyFrame.Position = UDim2.new(0.5, -205, 0.5, -155)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
KeyFrame.ZIndex = 50
KeyFrame.Parent = Gui
Corner(KeyFrame, 18)
Stroke(KeyFrame, Color3.fromRGB(255, 195, 0), 2)

local KeyTop = Instance.new("Frame")
KeyTop.Size = UDim2.new(1, 0, 0, 75)
KeyTop.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
KeyTop.BorderSizePixel = 0
KeyTop.ZIndex = 51
KeyTop.Parent = KeyFrame
Corner(KeyTop, 18)

local KeyAccent = Instance.new("Frame")
KeyAccent.Size = UDim2.new(1, 0, 0, 3)
KeyAccent.Position = UDim2.new(0, 0, 1, -3)
KeyAccent.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
KeyAccent.BorderSizePixel = 0
KeyAccent.ZIndex = 52
KeyAccent.Parent = KeyTop
Gradient(KeyAccent)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, -30, 0, 35)
KeyTitle.Position = UDim2.fromOffset(15, 10)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = Translations.VIE.Title
KeyTitle.TextColor3 = Color3.fromRGB(255, 210, 50)
KeyTitle.TextSize = 25
KeyTitle.Font = Enum.Font.GothamBlack
KeyTitle.ZIndex = 52
KeyTitle.Parent = KeyTop

local KeySub = Instance.new("TextLabel")
KeySub.Size = UDim2.new(1, -30, 0, 22)
KeySub.Position = UDim2.fromOffset(15, 42)
KeySub.BackgroundTransparency = 1
KeySub.Text = Translations.VIE.SubKey
KeySub.TextColor3 = Color3.fromRGB(145, 145, 150)
KeySub.TextSize = 12
KeySub.Font = Enum.Font.Gotham
KeySub.TextXAlignment = Enum.TextXAlignment.Left
KeySub.ZIndex = 52
KeySub.Parent = KeyTop

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -40, 0, 48)
KeyBox.Position = UDim2.fromOffset(20, 95)
KeyBox.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 105)
KeyBox.PlaceholderText = Translations.VIE.KeyPlace
KeyBox.Text = ""
KeyBox.TextSize = 16
KeyBox.Font = Enum.Font.GothamMedium
KeyBox.ClearTextOnFocus = false
KeyBox.ZIndex = 52
KeyBox.Parent = KeyFrame
Corner(KeyBox, 12)
Stroke(KeyBox, Color3.fromRGB(65, 65, 70), 1)

local CheckKey = Instance.new("TextButton")
CheckKey.Size = UDim2.new(1, -40, 0, 48)
CheckKey.Position = UDim2.fromOffset(20, 153)
CheckKey.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
CheckKey.Text = Translations.VIE.CheckKey
CheckKey.TextColor3 = Color3.fromRGB(10, 10, 10)
CheckKey.TextSize = 15
CheckKey.Font = Enum.Font.GothamBold
CheckKey.ZIndex = 52
CheckKey.Parent = KeyFrame
Corner(CheckKey, 12)
Gradient(CheckKey)

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -40, 0, 60)
KeyStatus.Position = UDim2.fromOffset(20, 215)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextColor3 = Color3.fromRGB(255, 220, 0)
KeyStatus.TextSize = 12
KeyStatus.Font = Enum.Font.GothamBold
KeyStatus.TextWrapped = true
KeyStatus.ZIndex = 52
KeyStatus.Parent = KeyFrame

-- LOADING FRAME
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.fromOffset(410, 240)
LoadingFrame.Position = UDim2.new(0.5, -205, 0.5, -120)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
LoadingFrame.Visible = false
LoadingFrame.ZIndex = 40
LoadingFrame.Parent = Gui
Corner(LoadingFrame, 18)
Stroke(LoadingFrame, Color3.fromRGB(255, 195, 0), 2)

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Size = UDim2.new(1, 0, 0, 40)
LoadingTitle.Position = UDim2.fromOffset(0, 25)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = Translations.VIE.Title
LoadingTitle.TextColor3 = Color3.fromRGB(255, 210, 50)
LoadingTitle.TextSize = 27
LoadingTitle.Font = Enum.Font.GothamBlack
LoadingTitle.ZIndex = 41
LoadingTitle.Parent = LoadingFrame

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 25)
LoadingText.Position = UDim2.fromOffset(0, 70)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = Translations.VIE.LoadingInit
LoadingText.TextColor3 = Color3.fromRGB(170, 170, 175)
LoadingText.TextSize = 14
LoadingText.Font = Enum.Font.Gotham
LoadingText.ZIndex = 41
LoadingText.Parent = LoadingFrame

local BarBack = Instance.new("Frame")
BarBack.Size = UDim2.new(1, -50, 0, 20)
BarBack.Position = UDim2.fromOffset(25, 115)
BarBack.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
BarBack.ZIndex = 41
BarBack.Parent = LoadingFrame
Corner(BarBack, 10)

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0, 0, 1, 0)
Bar.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
Bar.ZIndex = 42
Bar.Parent = BarBack
Corner(Bar, 10)
Gradient(Bar)

local Percent = Instance.new("TextLabel")
Percent.Size = UDim2.new(1, 0, 0, 25)
Percent.Position = UDim2.fromOffset(0, 155)
Percent.BackgroundTransparency = 1
Percent.Text = "0%"
Percent.TextColor3 = Color3.fromRGB(255, 255, 255)
Percent.TextSize = 15
Percent.Font = Enum.Font.GothamBold
Percent.ZIndex = 41
Percent.Parent = LoadingFrame

-- MAIN FRAME
local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(400, 600)
Main.Position = UDim2.new(0.5, -200, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
Main.Visible = false
Main.ZIndex = 10
Main.Parent = Gui
Corner(Main, 20)
Stroke(Main, Color3.fromRGB(255, 195, 0), 2)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 29)
Header.BorderSizePixel = 0
Header.ZIndex = 11
Header.Parent = Main
Corner(Header, 20)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -30, 0, 2)
HeaderLine.Position = UDim2.new(0, 15, 1, -4)
HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
HeaderLine.BorderSizePixel = 0
HeaderLine.ZIndex = 12
HeaderLine.Parent = Header
Gradient(HeaderLine)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 28)
Title.Position = UDim2.fromOffset(18, 16)
Title.BackgroundTransparency = 1
Title.Text = Translations.VIE.Title
Title.TextColor3 = Color3.fromRGB(255, 210, 50)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(38, 38)
Close.Position = UDim2.new(1, -50, 0, 11)
Close.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 22
Close.Font = Enum.Font.GothamMedium
Close.ZIndex = 20
Close.Parent = Header
Corner(Close, 10)
Stroke(Close, Color3.fromRGB(70, 70, 75), 1)

-- TAB BAR
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 42)
TabBar.Position = UDim2.fromOffset(10, 68)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 11
TabBar.Parent = Main
Corner(TabBar, 10)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Parent = TabBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -205)
Content.Position = UDim2.fromOffset(10, 118)
Content.BackgroundTransparency = 1
Content.ZIndex = 11
Content.Parent = Main

local function CreatePage()
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = Color3.fromRGB(255, 190, 0)
	page.Visible = false
	page.ZIndex = 12
	page.Parent = Content
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page
	
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end)
	return page
end

local PageMove = CreatePage()
local PageESP = CreatePage()
local PageAim = CreatePage()
local PagePerf = CreatePage()
local PageSys = CreatePage()
PageMove.Visible = true

local function MakeTab(nameKey, order)
	local Tab = Instance.new("TextButton")
	Tab.Size = UDim2.new(0, 73, 0, 32)
	Tab.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	Tab.Text = Translations.VIE[nameKey]
	Tab.TextColor3 = Color3.fromRGB(200, 200, 205)
	Tab.TextSize = 11
	Tab.Font = Enum.Font.GothamBold
	Tab.LayoutOrder = order
	Tab.ZIndex = 13
	Tab.Parent = TabBar
	Corner(Tab, 8)
	return Tab
end

local TabMove = MakeTab("TabMove", 1)
local TabESP = MakeTab("TabESP", 2)
local TabAim = MakeTab("TabAim", 3)
local TabPerf = MakeTab("TabPerf", 4)
local TabSys = MakeTab("TabSys", 5)

local function SetActiveTab(tab)
	for _, t in ipairs({TabMove, TabESP, TabAim, TabPerf, TabSys}) do
		t.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
		t.TextColor3 = Color3.fromRGB(200, 200, 205)
	end
	tab.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
	tab.TextColor3 = Color3.fromRGB(10, 10, 10)

	PageMove.Visible = false
	PageESP.Visible = false
	PageAim.Visible = false
	PagePerf.Visible = false
	PageSys.Visible = false

	if tab == TabMove then PageMove.Visible = true
	elseif tab == TabESP then PageESP.Visible = true
	elseif tab == TabAim then PageAim.Visible = true
	elseif tab == TabPerf then PagePerf.Visible = true
	elseif tab == TabSys then PageSys.Visible = true end
end

TabMove.MouseButton1Click:Connect(function() SetActiveTab(TabMove) end)
TabESP.MouseButton1Click:Connect(function() SetActiveTab(TabESP) end)
TabAim.MouseButton1Click:Connect(function() SetActiveTab(TabAim) end)
TabPerf.MouseButton1Click:Connect(function() SetActiveTab(TabPerf) end)
TabSys.MouseButton1Click:Connect(function() SetActiveTab(TabSys) end)

-- BOTTOM CARD
local BottomCard = Instance.new("Frame")
BottomCard.Size = UDim2.new(1, -20, 0, 70)
BottomCard.Position = UDim2.new(0, 10, 1, -80)
BottomCard.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
BottomCard.ZIndex = 15
BottomCard.Parent = Main
Corner(BottomCard, 12)
Stroke(BottomCard, Color3.fromRGB(255, 200, 0), 1.5)

local BottomTitle = Instance.new("TextLabel")
BottomTitle.Size = UDim2.new(1, -16, 0, 20)
BottomTitle.Position = UDim2.fromOffset(10, 5)
BottomTitle.BackgroundTransparency = 1
BottomTitle.Text = Translations.VIE.KeyInfoTitle
BottomTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
BottomTitle.TextSize = 12
BottomTitle.Font = Enum.Font.GothamBold
BottomTitle.TextXAlignment = Enum.TextXAlignment.Left
BottomTitle.ZIndex = 16
BottomTitle.Parent = BottomCard

local DeviceInfoLbl = Instance.new("TextLabel")
DeviceInfoLbl.Size = UDim2.new(1, -16, 0, 18)
DeviceInfoLbl.Position = UDim2.fromOffset(10, 25)
DeviceInfoLbl.BackgroundTransparency = 1
DeviceInfoLbl.Text = Translations.VIE.DeviceLbl .. UIS:GetPlatform().Name
DeviceInfoLbl.TextColor3 = Color3.fromRGB(255, 230, 100)
DeviceInfoLbl.TextSize = 11
DeviceInfoLbl.Font = Enum.Font.GothamMedium
DeviceInfoLbl.TextXAlignment = Enum.TextXAlignment.Left
DeviceInfoLbl.ZIndex = 16
DeviceInfoLbl.Parent = BottomCard

local TimeRemainingLbl = Instance.new("TextLabel")
TimeRemainingLbl.Size = UDim2.new(1, -16, 0, 18)
TimeRemainingLbl.Position = UDim2.fromOffset(10, 43)
TimeRemainingLbl.BackgroundTransparency = 1
TimeRemainingLbl.Text = Translations.VIE.TimeRemainingLbl .. "00:00:00"
TimeRemainingLbl.TextColor3 = Color3.fromRGB(255, 230, 100)
TimeRemainingLbl.TextSize = 11
TimeRemainingLbl.Font = Enum.Font.GothamBold
TimeRemainingLbl.TextXAlignment = Enum.TextXAlignment.Left
TimeRemainingLbl.ZIndex = 16
TimeRemainingLbl.Parent = BottomCard

local toggleLabels = {}

local function MakeToggle(Parent, key, labelKey)
	local Row = Instance.new("TextButton")
	Row.Size = UDim2.new(1, 0, 0, 38)
	Row.BackgroundColor3 = Color3.fromRGB(23, 23, 27)
	Row.Text = ""
	Row.ZIndex = 13
	Row.Parent = Parent
	Corner(Row, 10)
	Stroke(Row, Color3.fromRGB(50, 50, 55), 1)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -80, 1, 0)
	lbl.Position = UDim2.fromOffset(14, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = Translations.VIE[labelKey]
	lbl.TextColor3 = Color3.fromRGB(235, 235, 235)
	lbl.TextSize = 13
	lbl.Font = Enum.Font.Gotham
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 14
	lbl.Parent = Row

	toggleLabels[labelKey] = lbl

	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(46, 26)
	box.Position = UDim2.new(1, -58, 0.5, -13)
	box.BackgroundColor3 = Color3.fromRGB(42, 42, 47)
	box.ZIndex = 14
	box.Parent = Row
	Corner(box, 13)
	Stroke(box, Color3.fromRGB(70, 70, 75), 1)

	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(20, 20)
	dot.Position = UDim2.fromOffset(3, 3)
	dot.BackgroundColor3 = Color3.fromRGB(180, 180, 185)
	dot.ZIndex = 15
	dot.Parent = box
	Corner(dot, 10)

	Row.MouseButton1Click:Connect(function()
		ESP[key] = not ESP[key]
		if ESP[key] then
			TweenService:Create(box, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 195, 0)}):Play()
			TweenService:Create(dot, TweenInfo.new(0.15), {Position = UDim2.fromOffset(23, 3), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		else
			TweenService:Create(box, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(42, 42, 47)}):Play()
			TweenService:Create(dot, TweenInfo.new(0.15), {Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Color3.fromRGB(180, 180, 185)}):Play()
		end
	end)

	return Row
end

-- MOVE PANEL
local SpeedCard = Instance.new("Frame")
SpeedCard.Size = UDim2.new(1, 0, 0, 100)
SpeedCard.BackgroundColor3 = Color3.fromRGB(23, 23, 27)
SpeedCard.LayoutOrder = 1
SpeedCard.Parent = PageMove
Corner(SpeedCard, 14)
Stroke(SpeedCard, Color3.fromRGB(50, 50, 55), 1)

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(1, -20, 0, 22)
SpeedTitle.Position = UDim2.fromOffset(12, 10)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = Translations.VIE.WalkSpeed
SpeedTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
SpeedTitle.TextSize = 14
SpeedTitle.Font = Enum.Font.GothamBold
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.ZIndex = 12
SpeedTitle.Parent = SpeedCard

local SpeedValue = Instance.new("TextBox")
SpeedValue.Size = UDim2.fromOffset(70, 35)
SpeedValue.Position = UDim2.new(1, -155, 0, 40)
SpeedValue.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
SpeedValue.TextColor3 = Color3.fromRGB(255, 205, 40)
SpeedValue.Text = "50"
SpeedValue.TextSize = 15
SpeedValue.Font = Enum.Font.GothamBold
SpeedValue.ClearTextOnFocus = false
SpeedValue.ZIndex = 13
SpeedValue.Parent = SpeedCard
Corner(SpeedValue, 9)
Stroke(SpeedValue, Color3.fromRGB(75, 75, 80), 1)

local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.fromOffset(68, 35)
SpeedToggle.Position = UDim2.new(1, -78, 0, 40)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(42, 42, 47)
SpeedToggle.Text = "OFF"
SpeedToggle.TextColor3 = Color3.fromRGB(150, 150, 155)
SpeedToggle.TextSize = 12
SpeedToggle.Font = Enum.Font.GothamBold
SpeedToggle.ZIndex = 13
SpeedToggle.Parent = SpeedCard
Corner(SpeedToggle, 9)

SpeedToggle.MouseButton1Click:Connect(function()
	SpeedOn = not SpeedOn
	if SpeedOn then
		SpeedToggle.Text = "ON"
		SpeedToggle.TextColor3 = Color3.fromRGB(5, 5, 5)
		SpeedToggle.BackgroundColor3 = Color3.fromRGB(255, 195, 0)
	else
		SpeedToggle.Text = "OFF"
		SpeedToggle.TextColor3 = Color3.fromRGB(150, 150, 155)
		SpeedToggle.BackgroundColor3 = Color3.fromRGB(42, 42, 47)
		if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
			Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = DEFAULT_SPEED
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if SpeedOn and Player.Character then
		local hum = Player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			local v = tonumber(SpeedValue.Text) or 50
			hum.WalkSpeed = v
		end
	end
end)

-- FLY PANEL
local FlyCard = Instance.new("Frame")
FlyCard.Size = UDim2.new(1, 0, 0, 130)
FlyCard.BackgroundColor3 = Color3.fromRGB(23, 23, 27)
FlyCard.LayoutOrder = 2
FlyCard.Parent = PageMove
Corner(FlyCard, 14)
Stroke(FlyCard, Color3.fromRGB(50, 50, 55), 1)

local FlyTitle = Instance.new("TextLabel")
FlyTitle.Size = UDim2.new(1, -20, 0, 22)
FlyTitle.Position = UDim2.fromOffset(12, 10)
FlyTitle.BackgroundTransparency = 1
FlyTitle.Text = Translations.VIE.FlyMode
FlyTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
FlyTitle.TextSize = 14
FlyTitle.Font = Enum.Font.GothamBold
FlyTitle.TextXAlignment = Enum.TextXAlignment.Left
FlyTitle.ZIndex = 12
FlyTitle.Parent = FlyCard

local FlyDesc = Instance.new("TextLabel")
FlyDesc.Size = UDim2.new(1, -20, 0, 18)
FlyDesc.Position = UDim2.fromOffset(12, 32)
FlyDesc.BackgroundTransparency = 1
FlyDesc.Text = "W A S D • Space • Ctrl"
FlyDesc.TextColor3 = Color3.fromRGB(105, 105, 110)
FlyDesc.TextSize = 11
FlyDesc.Font = Enum.Font.Gotham
FlyDesc.TextXAlignment = Enum.TextXAlignment.Left
FlyDesc.ZIndex = 12
FlyDesc.Parent = FlyCard

local FlySpeedBox = Instance.new("TextBox")
FlySpeedBox.Size = UDim2.fromOffset(80, 35)
FlySpeedBox.Position = UDim2.fromOffset(12, 65)
FlySpeedBox.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
FlySpeedBox.TextColor3 = Color3.fromRGB(80, 190, 255)
FlySpeedBox.Text = "60"
FlySpeedBox.TextSize = 15
FlySpeedBox.Font = Enum.Font.GothamBold
FlySpeedBox.ClearTextOnFocus = false
FlySpeedBox.ZIndex = 13
FlySpeedBox.Parent = FlyCard
Corner(FlySpeedBox, 9)
Stroke(FlySpeedBox, Color3.fromRGB(75, 75, 80), 1)

local FlySpeedLabel = Instance.new("TextLabel")
FlySpeedLabel.Size = UDim2.fromOffset(160, 20)
FlySpeedLabel.Position = UDim2.fromOffset(100, 72)
FlySpeedLabel.BackgroundTransparency = 1
FlySpeedLabel.Text = Translations.VIE.FlySpeedLbl
FlySpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 185)
FlySpeedLabel.TextSize = 11
FlySpeedLabel.Font = Enum.Font.Gotham
FlySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
FlySpeedLabel.ZIndex = 13
FlySpeedLabel.Parent = FlyCard

local FlyToggle = Instance.new("TextButton")
FlyToggle.Size = UDim2.new(0, 78, 0, 40)
FlyToggle.Position = UDim2.new(1, -92, 0, 65)
FlyToggle.BackgroundColor3 = Color3.fromRGB(42, 42, 47)
FlyToggle.Text = "OFF"
FlyToggle.TextColor3 = Color3.fromRGB(150, 150, 155)
FlyToggle.TextSize = 12
FlyToggle.Font = Enum.Font.GothamBold
FlyToggle.ZIndex = 13
FlyToggle.Parent = FlyCard
Corner(FlyToggle, 10)

FlyToggle.MouseButton1Click:Connect(function()
	FlyOn = not FlyOn
	if FlyOn then
		FlyToggle.Text = "ON"
		FlyToggle.TextColor3 = Color3.fromRGB(5, 5, 5)
		FlyToggle.BackgroundColor3 = Color3.fromRGB(255, 195, 0)
	else
		FlyToggle.Text = "OFF"
		FlyToggle.TextColor3 = Color3.fromRGB(150, 150, 155)
		FlyToggle.BackgroundColor3 = Color3.fromRGB(42, 42, 47)
		if Player.Character then
			local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
			local hum = Player.Character:FindFirstChildOfClass("Humanoid")
			if hrp then
				local bv = hrp:FindFirstChild("BachFlyBV")
				if bv then bv:Destroy() end
			end
			if hum then hum.PlatformStand = false end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if FlyOn and Player.Character then
		local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
		local hum = Player.Character:FindFirstChildOfClass("Humanoid")
		if hrp and hum then
			hum.PlatformStand = true
			local bv = hrp:FindFirstChild("BachFlyBV")
			if not bv then
				bv = Instance.new("BodyVelocity")
				bv.Name = "BachFlyBV"
				bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				bv.Parent = hrp
			end
			local speed = tonumber(FlySpeedBox.Text) or 60
			local dir = Vector3.zero
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
			
			bv.Velocity = dir.Magnitude > 0 and (dir.Unit * speed) or Vector3.zero
		end
	end
end)

-- ESP PANEL
MakeToggle(PageESP, "Player", "EspPlayer")
MakeToggle(PageESP, "Highlight", "EspHighlight")
MakeToggle(PageESP, "Box", "EspBox")
MakeToggle(PageESP, "Line", "EspLine")
MakeToggle(PageESP, "Name", "EspName")
MakeToggle(PageESP, "Health", "EspHealth")
MakeToggle(PageESP, "Distance", "EspDist")
MakeToggle(PageESP, "Head", "EspHead")
MakeToggle(PageESP, "Team", "EspTeam")

-- AIMBOT PANEL
local AimCard = Instance.new("Frame")
AimCard.Size = UDim2.new(1, 0, 0, 120)
AimCard.BackgroundColor3 = Color3.fromRGB(23, 23, 27)
AimCard.LayoutOrder = 1
AimCard.Parent = PageAim
Corner(AimCard, 14)
Stroke(AimCard, Color3.fromRGB(50, 50, 55), 1)

local AimTitle = Instance.new("TextLabel")
AimTitle.Size = UDim2.new(1, -20, 0, 25)
AimTitle.Position = UDim2.fromOffset(12, 10)
AimTitle.BackgroundTransparency = 1
AimTitle.Text = Translations.VIE.AimTitle
AimTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
AimTitle.TextSize = 15
AimTitle.Font = Enum.Font.GothamBold
AimTitle.TextXAlignment = Enum.TextXAlignment.Left
AimTitle.ZIndex = 12
AimTitle.Parent = AimCard

local AimToggle = Instance.new("TextButton")
AimToggle.Size = UDim2.new(1, -24, 0, 42)
AimToggle.Position = UDim2.fromOffset(12, 45)
AimToggle.BackgroundColor3 = Color3.fromRGB(42, 42, 47)
AimToggle.Text = Translations.VIE.AimOff
AimToggle.TextColor3 = Color3.fromRGB(150, 150, 155)
AimToggle.TextSize = 13
AimToggle.Font = Enum.Font.GothamBold
AimToggle.ZIndex = 13
AimToggle.Parent = AimCard
Corner(AimToggle, 10)

AimToggle.MouseButton1Click:Connect(function()
	AimOn = not AimOn
	if AimOn then
		AimToggle.Text = Translations[CurrentLang].AimOn
		AimToggle.TextColor3 = Color3.fromRGB(5, 5, 5)
		AimToggle.BackgroundColor3 = Color3.fromRGB(255, 195, 0)
	else
		AimToggle.Text = Translations[CurrentLang].AimOff
		AimToggle.TextColor3 = Color3.fromRGB(150, 150, 155)
		AimToggle.BackgroundColor3 = Color3.fromRGB(42, 42, 47)
	end
end)

-- PERF PANEL (FIX LAG HỆ THỐNG ĐÃ SỬA HOÀN TOÀN)
local PerfCard = Instance.new("Frame")
PerfCard.Size = UDim2.new(1, 0, 0, 130)
PerfCard.BackgroundColor3 = Color3.fromRGB(23, 23, 27)
PerfCard.LayoutOrder = 1
PerfCard.Parent = PagePerf
Corner(PerfCard, 14)
Stroke(PerfCard, Color3.fromRGB(50, 50, 55), 1)

local LightButton = Instance.new("TextButton")
LightButton.Size = UDim2.new(0.5, -15, 0, 55)
LightButton.Position = UDim2.fromOffset(10, 20)
LightButton.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
LightButton.Text = Translations.VIE.FixLagLight .. "OFF"
LightButton.TextColor3 = Color3.fromRGB(200, 200, 205)
LightButton.TextSize = 12
LightButton.Font = Enum.Font.GothamBold
LightButton.ZIndex = 12
LightButton.Parent = PerfCard
Corner(LightButton, 10)
Stroke(LightButton, Color3.fromRGB(50, 50, 55), 1)

local StrongButton = Instance.new("TextButton")
StrongButton.Size = UDim2.new(0.5, -15, 0, 55)
StrongButton.Position = UDim2.new(0.5, 5, 0, 20)
StrongButton.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
StrongButton.Text = Translations.VIE.FixLagStrong .. "OFF"
StrongButton.TextColor3 = Color3.fromRGB(200, 200, 205)
StrongButton.TextSize = 12
StrongButton.Font = Enum.Font.GothamBold
StrongButton.ZIndex = 12
StrongButton.Parent = PerfCard
Corner(StrongButton, 10)
Stroke(StrongButton, Color3.fromRGB(50, 50, 55), 1)

local function ApplyLightFixLag()
	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 9e9
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
				v.Enabled = false
			end
		end
	end)
end

local function ApplyStrongFixLag()
	ApplyLightFixLag()
	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		for _, v in ipairs(game:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Material = Enum.Material.SmoothPlastic
				v.Reflectance = 0
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 1
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
				v.Enabled = false
			end
		end
	end)
end

LightButton.MouseButton1Click:Connect(function()
	LightLagOn = not LightLagOn
	if LightLagOn then
		LightButton.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
		LightButton.TextColor3 = Color3.fromRGB(10, 10, 10)
		LightButton.Text = Translations[CurrentLang].FixLagLight .. "ON"
		ApplyLightFixLag()
	else
		LightButton.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
		LightButton.TextColor3 = Color3.fromRGB(200, 200, 205)
		LightButton.Text = Translations[CurrentLang].FixLagLight .. "OFF"
	end
end)

StrongButton.MouseButton1Click:Connect(function()
	StrongLagOn = not StrongLagOn
	if StrongLagOn then
		StrongButton.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
		StrongButton.TextColor3 = Color3.fromRGB(10, 10, 10)
		StrongButton.Text = Translations[CurrentLang].FixLagStrong .. "ON"
		ApplyStrongFixLag()
	else
		StrongButton.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
		StrongButton.TextColor3 = Color3.fromRGB(200, 200, 205)
		StrongButton.Text = Translations[CurrentLang].FixLagStrong .. "OFF"
	end
end)

-- SYSTEM PANEL
local SysCard = Instance.new("Frame")
SysCard.Size = UDim2.new(1, 0, 0, 180)
SysCard.BackgroundColor3 = Color3.fromRGB(23, 23, 27)
SysCard.LayoutOrder = 1
SysCard.Parent = PageSys
Corner(SysCard, 14)
Stroke(SysCard, Color3.fromRGB(50, 50, 55), 1)

local LangLabel = Instance.new("TextLabel")
LangLabel.Size = UDim2.new(1, -20, 0, 20)
LangLabel.Position = UDim2.fromOffset(10, 8)
LangLabel.BackgroundTransparency = 1
LangLabel.Text = Translations.VIE.LangLbl
LangLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
LangLabel.TextSize = 12
LangLabel.Font = Enum.Font.GothamBold
LangLabel.TextXAlignment = Enum.TextXAlignment.Left
LangLabel.ZIndex = 12
LangLabel.Parent = SysCard

local LangGrid = Instance.new("Frame")
LangGrid.Size = UDim2.new(1, -20, 0, 80)
LangGrid.Position = UDim2.fromOffset(10, 32)
LangGrid.BackgroundTransparency = 1
LangGrid.ZIndex = 12
LangGrid.Parent = SysCard

local GridLay = Instance.new("UIGridLayout")
GridLay.CellSize = UDim2.new(0.31, 0, 0, 32)
GridLay.CellPadding = UDim2.new(0.03, 0, 0, 8)
GridLay.Parent = LangGrid

local function MakeLangBtn(code, label)
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	b.Text = label
	b.TextColor3 = Color3.fromRGB(200, 200, 205)
	b.TextSize = 11
	b.Font = Enum.Font.GothamBold
	b.ZIndex = 13
	b.Parent = LangGrid
	Corner(b, 8)
	return b
end

local BtnVie = MakeLangBtn("VIE", "Tiếng Việt")
local BtnEng = MakeLangBtn("ENG", "English")
local BtnChs = MakeLangBtn("CHS", "中文")
local BtnJpn = MakeLangBtn("JPN", "日本語")
local BtnKor = MakeLangBtn("KOR", "한국어")
local BtnRus = MakeLangBtn("RUS", "Русский")

local ResetButton = Instance.new("TextButton")
ResetButton.Size = UDim2.new(1, -20, 0, 40)
ResetButton.Position = UDim2.fromOffset(10, 125)
ResetButton.BackgroundColor3 = Color3.fromRGB(45, 20, 25)
ResetButton.Text = Translations.VIE.ResetChar
ResetButton.TextColor3 = Color3.fromRGB(255, 200, 200)
ResetButton.TextSize = 13
ResetButton.Font = Enum.Font.GothamBold
ResetButton.ZIndex = 12
ResetButton.Parent = SysCard
Corner(ResetButton, 10)
Stroke(ResetButton, Color3.fromRGB(80, 40, 50), 1)

ResetButton.MouseButton1Click:Connect(function()
	if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
		Player.Character:FindFirstChildOfClass("Humanoid").Health = 0
	end
end)

-- NÚT B DI CHUYỂN
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.fromOffset(68, 68)
OpenButton.Position = UDim2.new(0, 25, 0.5, -34)
OpenButton.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
OpenButton.Text = "B"
OpenButton.TextColor3 = Color3.fromRGB(10, 10, 10)
OpenButton.TextSize = 31
OpenButton.Font = Enum.Font.GothamBlack
OpenButton.Visible = false
OpenButton.ZIndex = 200
OpenButton.Parent = Gui
Corner(OpenButton, 100)
Stroke(OpenButton, Color3.fromRGB(255, 230, 100), 3)
Gradient(OpenButton)

local WasMovedB = MakeDraggable(OpenButton, OpenButton)

OpenButton.MouseButton1Click:Connect(function()
	if not WasMovedB() then
		Main.Visible = true
		OpenButton.Visible = false
	end
end)

-- CẬP NHẬT NGÔN NGỮ
local function UpdateLanguage(lang)
	CurrentLang = lang
	local t = Translations[lang]

	KeyTitle.Text = t.Title
	KeySub.Text = t.SubKey
	KeyBox.PlaceholderText = t.KeyPlace
	CheckKey.Text = t.CheckKey
	LoadingTitle.Text = t.Title
	Title.Text = t.Title

	TabMove.Text = t.TabMove
	TabESP.Text = t.TabESP
	TabAim.Text = t.TabAim
	TabPerf.Text = t.TabPerf
	TabSys.Text = t.TabSys

	SpeedTitle.Text = t.WalkSpeed
	FlyTitle.Text = t.FlyMode
	FlySpeedLabel.Text = t.FlySpeedLbl

	for k, lbl in pairs(toggleLabels) do
		if t[k] then lbl.Text = t[k] end
	end

	AimTitle.Text = t.AimTitle
	AimToggle.Text = AimOn and t.AimOn or t.AimOff

	LightButton.Text = t.FixLagLight .. (LightLagOn and "ON" or "OFF")
	StrongButton.Text = t.FixLagStrong .. (StrongLagOn and "ON" or "OFF")

	LangLabel.Text = t.LangLbl
	ResetButton.Text = t.ResetChar

	BottomTitle.Text = t.KeyInfoTitle
	DeviceInfoLbl.Text = t.DeviceLbl .. UIS:GetPlatform().Name

	local allBtns = {
		VIE = BtnVie, ENG = BtnEng, CHS = BtnChs,
		JPN = BtnJpn, KOR = BtnKor, RUS = BtnRus
	}

	for c, b in pairs(allBtns) do
		if c == lang then
			b.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
			b.TextColor3 = Color3.fromRGB(10, 10, 10)
		else
			b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
			b.TextColor3 = Color3.fromRGB(200, 200, 205)
		end
	end
end

BtnVie.MouseButton1Click:Connect(function() UpdateLanguage("VIE") end)
BtnEng.MouseButton1Click:Connect(function() UpdateLanguage("ENG") end)
BtnChs.MouseButton1Click:Connect(function() UpdateLanguage("CHS") end)
BtnJpn.MouseButton1Click:Connect(function() UpdateLanguage("JPN") end)
BtnKor.MouseButton1Click:Connect(function() UpdateLanguage("KOR") end)
BtnRus.MouseButton1Click:Connect(function() UpdateLanguage("RUS") end)

-- ĐẾM NGƯỢC THỜI GIAN THỰC (OS.TIME) KHÔNG BAO GIỜ RESET LẠI TỪ ĐẦU
task.spawn(function()
	while true do
		task.wait(1)
		if Main.Visible or KeyFrame.Visible then
			if IsKeyLifetime then
				TimeRemainingLbl.Text = Translations[CurrentLang].TimeRemainingLbl .. Translations[CurrentLang].ExpLife
			else
				local remaining = KeyAbsoluteExpiry - os.time()
				if remaining > 0 then
					local hrs = math.floor(remaining / 3600)
					local mins = math.floor((remaining % 3600) / 60)
					local secs = remaining % 60
					TimeRemainingLbl.Text = string.format("%s%02d:%02d:%02d", Translations[CurrentLang].TimeRemainingLbl, hrs, mins, secs)
				else
					if Main.Visible then
						Main.Visible = false
						OpenButton.Visible = false
						KeyFrame.Visible = true
						KeyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
						KeyStatus.Text = Translations[CurrentLang].KeyExpiredMsg
					end
				end
			end
		end
	end
end)

-- AIMBOT LOGIC
local function GetClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Player and plr.Character and plr.Character:FindFirstChild("Head") then
			local isTeam = plr.Team and plr.Team == Player.Team
			if not (ESP.Team and isTeam) then
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
					if onScreen then
						local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
						if magnitude < shortestDistance then
							shortestDistance = magnitude
							closestPlayer = plr
						end
					end
				end
			end
		end
	end
	return closestPlayer
end

RunService.RenderStepped:Connect(function()
	if AimOn then
		local target = GetClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
		end
	end
end)

-- ESP SYSTEM
local espObjects = {}

local function RemoveESP(plr)
	if espObjects[plr] then
		for _, v in pairs(espObjects[plr]) do
			pcall(function() v:Destroy() end)
		end
		espObjects[plr] = nil
	end
end

local function UpdateESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Player then
			local char = plr.Character
			local isTeam = plr.Team and plr.Team == Player.Team
			local color = isTeam and ESPTeamColor or ESPColor

			if ESP.Player and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
				local hrp = char.HumanoidRootPart
				local head = char.Head
				local hum = char:FindFirstChildOfClass("Humanoid")

				if not espObjects[plr] then espObjects[plr] = {} end
				local objs = espObjects[plr]

				-- HIGHLIGHT
				if ESP.Highlight then
					if not objs.Highlight then
						local hl = Instance.new("Highlight")
						hl.Name = "BachESP_HL"
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						hl.Parent = char
						objs.Highlight = hl
					end
					objs.Highlight.Adornee = char
					objs.Highlight.FillColor = color
					objs.Highlight.Enabled = true
				elseif objs.Highlight then
					objs.Highlight.Enabled = false
				end

				-- BOX
				if ESP.Box then
					if not objs.Box then
						local bx = Instance.new("SelectionBox")
						bx.Name = "BachESP_BX"
						bx.LineThickness = 0.05
						bx.Parent = Gui
						objs.Box = bx
					end
					objs.Box.Adornee = char
					objs.Box.Color3 = color
					objs.Box.Visible = true
				elseif objs.Box then
					objs.Box.Visible = false
				end

				-- LINE
				if ESP.Line then
					if not objs.LineBeam then
						local att0 = Instance.new("Attachment")
						att0.Name = "BachESP_Att0"
						att0.Parent = head

						local att1 = Instance.new("Attachment")
						att1.Name = "BachESP_Att1"
						att1.Parent = workspace.Terrain

						local beam = Instance.new("Beam")
						beam.Name = "BachESP_Beam"
						beam.Attachment0 = att0
						beam.Attachment1 = att1
						beam.Width0 = 0.4
						beam.Width1 = 0.1
						beam.FaceCamera = true
						beam.LightEmission = 1
						beam.Parent = head

						objs.Att0 = att0
						objs.Att1 = att1
						objs.LineBeam = beam
					end
					
					objs.Att0.WorldPosition = head.Position
					objs.Att1.WorldPosition = head.Position + Vector3.new(0, 10000, 0)
					objs.LineBeam.Color = ColorSequence.new(color)
					objs.LineBeam.Enabled = true
				elseif objs.LineBeam then
					objs.LineBeam.Enabled = false
				end

				-- HEAD
				if ESP.Head then
					if not objs.Head then
						local hd = Instance.new("SelectionBox")
						hd.Name = "BachESP_HD"
						hd.LineThickness = 0.08
						hd.Parent = Gui
						objs.Head = hd
					end
					objs.Head.Adornee = head
					objs.Head.Color3 = color
					objs.Head.Visible = true
				elseif objs.Head then
					objs.Head.Visible = false
				end

				-- BILLBOARD
				if ESP.Name or ESP.Health or ESP.Distance then
					if not objs.BB then
						local bb = Instance.new("BillboardGui")
						bb.Name = "BachESP_BB"
						bb.Size = UDim2.new(0, 200, 0, 60)
						bb.AlwaysOnTop = true
						bb.StudsOffset = Vector3.new(0, 3.5, 0)
						bb.Parent = Gui

						local txt = Instance.new("TextLabel")
						txt.Size = UDim2.new(1, 0, 1, 0)
						txt.BackgroundTransparency = 1
						txt.TextColor3 = Color3.fromRGB(255, 255, 255)
						txt.TextSize = 13
						txt.Font = Enum.Font.GothamBold
						txt.TextStrokeTransparency = 0
						txt.Parent = bb

						objs.BB = bb
						objs.BBText = txt
					end
					objs.BB.Adornee = head
					objs.BB.Enabled = true

					local infoStr = ""
					if ESP.Name then infoStr = infoStr .. plr.Name .. "\n" end
					if ESP.Health and hum then infoStr = infoStr .. "❤ " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. "\n" end
					if ESP.Distance then
						local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
						infoStr = infoStr .. "📏 " .. dist .. "m"
					end
					objs.BBText.Text = infoStr
					objs.BBText.TextColor3 = color
				elseif objs.BB then
					objs.BB.Enabled = false
				end

			else
				RemoveESP(plr)
			end
		end
	end
end

RunService.RenderStepped:Connect(UpdateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- XÁC THỰC KEY
CheckKey.MouseButton1Click:Connect(function()
	local keyInput = string.gsub(KeyBox.Text, "^%s*(.-)%s*$", "%1")
	if keyInput ~= "" then
		local t = Translations[CurrentLang]
		local db = LoadDatabase()
		local currentTimeSec = os.time()
		
		local record = db[keyInput]
		
		if record then
			if record.HWID ~= HWID then
				KeyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
				KeyStatus.Text = t.ErrUsedDevice
				return
			end
			
			if record.Expiry ~= math.huge and currentTimeSec >= record.Expiry then
				KeyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
				KeyStatus.Text = t.ErrExpired
				return
			end
			
			if record.Expiry == math.huge then
				IsKeyLifetime = true
			else
				KeyAbsoluteExpiry = record.Expiry
				IsKeyLifetime = false
			end
		else
			local upperKey = string.upper(keyInput)
			local duration = 3600
			
			if string.find(upperKey, "1H") then
				duration = 3600
			elseif string.find(upperKey, "24H") then
				duration = 86400
			elseif string.find(upperKey, "1M") then
				duration = 2592000
			elseif string.find(upperKey, "1Y") then
				duration = 31536000
			elseif string.find(upperKey, "LIFE") or string.find(upperKey, "VIP") then
				duration = math.huge
			end
			
			local expiryTime = (duration == math.huge) and math.huge or (currentTimeSec + duration)
			
			db[keyInput] = {
				HWID = HWID,
				Expiry = expiryTime,
				Used = true
			}
			SaveDatabase(db)
			
			if duration == math.huge then
				IsKeyLifetime = true
			else
				KeyAbsoluteExpiry = expiryTime
				IsKeyLifetime = false
			end
		end

		local deviceName = UIS:GetPlatform().Name
		local loginTimeStr = os.date("%H:%M:%S - %d/%m/%Y")
		local expiryInfoStr = IsKeyLifetime and t.ExpLife or (string.find(string.upper(keyInput), "24H") and t.Exp24h or t.Exp1h)

		KeyStatus.TextColor3 = Color3.fromRGB(255, 220, 0)
		KeyStatus.Text = t.Dev .. deviceName .. t.Time .. loginTimeStr .. t.Exp .. expiryInfoStr
		
		task.wait(1.2)
		KeyFrame.Visible = false
		LoadingFrame.Visible = true

		task.spawn(function()
			for i = 1, 100 do
				Bar.Size = UDim2.new(i / 100, 0, 1, 0)
				Percent.Text = i .. "%"
				if i == 30 then
					LoadingText.Text = Translations[CurrentLang].LoadingInit
				elseif i == 60 then
					LoadingText.Text = Translations[CurrentLang].LoadingFeatures
				elseif i == 90 then
					LoadingText.Text = Translations[CurrentLang].LoadingDone
				end
				task.wait(0.01)
			end
			task.wait(0.2)
			LoadingFrame.Visible = false
			Main.Visible = true
			OpenButton.Visible = true
		end)
	else
		KeyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
		KeyStatus.Text = Translations[CurrentLang].ErrKey
	end
end)

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
	OpenButton.Visible = true
end)

MakeDraggable(Main, Header)
MakeDraggable(KeyFrame, KeyTop)

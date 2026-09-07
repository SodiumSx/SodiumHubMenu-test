--[[
	NEXUS Hub � Display Only
	Pure UI shell. No logic, no feature loops, no networking.
	Toggle menu: INSERT key.
	Dang loadstring (giong ProxyLib):
	  local NexusLib = loadstring(game:HttpGet("LINK_RAW_CUA_BAN"))()
	  local Lib = NexusLib.new()
	  Lib:Notify("Tieu de", "Noi dung", 2)
]]

--========================== COMPAT (client cu) ==========================--
-- task.* va math.clamp khong co tren client rat cu -> tu tao fallback
if task == nil then
	task = {}
	function task.wait(t) return wait(t or 0) end
	function task.spawn(fn, ...) local a = {...} spawn(function() fn(unpack(a)) end) end
	function task.delay(t, fn, ...) local a = {...} delay(t, function() fn(unpack(a)) end) end
end
if math.clamp == nil then
	function math.clamp(v, mn, mx)
		if v < mn then return mn end
		if v > mx then return mx end
		return v
	end
end
if table.clear == nil then
	function table.clear(t)
		for k in pairs(t) do t[k] = nil end
	end
end

--========================== SERVICES ==========================--
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LP = Players.LocalPlayer

--========================== KILL OLD INSTANCE ==========================--
if _G.__NEXUS_UI then
	pcall(_G.__NEXUS_UI)
end
_G.__NEXUS_UI = nil

--========================== COLORS (xam den + do, vien chim) ==========================--
local C = {
	bg      = Color3.fromRGB(20, 17, 18),   -- xam den hoi do
	sidebar = Color3.fromRGB(24, 20, 21),
	panel   = Color3.fromRGB(30, 25, 27),
	card    = Color3.fromRGB(38, 30, 32),
	accent  = Color3.fromRGB(220, 38, 38),  -- do dam (highlight)
	accent2 = Color3.fromRGB(127, 29, 29),  -- do rat dam (badge / nut)
	border  = Color3.fromRGB(60, 50, 54),   -- vien chim
	hover   = Color3.fromRGB(25, 25, 25),   -- xam sang hon nen (hover)
	text    = Color3.fromRGB(240, 230, 230),
	muted   = Color3.fromRGB(184, 160, 160),
	green   = Color3.fromRGB(74, 222, 128),
	red     = Color3.fromRGB(248, 113, 113),
	glow    = Color3.fromRGB(200, 200, 210),
}

--========================== FONT CHUNG (doi 1 cho, ca GUI doi theo) ==========================--
-- Cach doi truoc khi chay file:
--   _G.NEXUS_Font = Enum.Font.Code
--   _G.NEXUS_FontBold = Enum.Font.CodeBold
-- Doi live sau khi GUI da hien:
--   _G.NEXUS_SetFont(Enum.Font.Code, Enum.Font.CodeBold)
_G.NEXUS_Font = _G.NEXUS_Font or Enum.Font.GothamMedium
_G.NEXUS_FontBold = _G.NEXUS_FontBold or Enum.Font["GothamBold"]
local FONT = _G.NEXUS_Font
local FONTBOLD = _G.NEXUS_FontBold
local AllTexts = {} -- {obj, bold}
local function regFont(obj, bold)
	pcall(function()
		table.insert(AllTexts, {obj = obj, bold = (bold == true)})
	end)
end
function _G.NEXUS_SetFont(normal, bold)
	if normal then
		_G.NEXUS_Font = normal
		FONT = normal
	end
	if bold then
		_G.NEXUS_FontBold = bold
		FONTBOLD = bold
	end
	for _, e in ipairs(AllTexts) do
		pcall(function()
			if e.obj and e.obj.Parent then
				e.obj.Font = e.bold and FONTBOLD or FONT
			end
		end)
	end
end

--========================== PARENT GUI ==========================--
local function getParent()
	local g
	pcall(function() g = gethui and gethui() end)
	if g then return g end
	pcall(function() g = game:GetService("CoreGui") end)
	if g then return g end
	return LP:WaitForChild("PlayerGui")
end

-- xoa sach instance cu o MOI parent (gethui / CoreGui / PlayerGui)
-- de khong bao gio con GUI cu de lai gay "thay nhu cu"
do
	local seen = {}
	local function killIn(p)
		pcall(function()
			if p and not seen[p] then
				seen[p] = true
				local o = p:FindFirstChild("NexusHub")
				if o then o:Destroy() end
			end
		end)
	end
	pcall(function() if gethui then killIn(gethui()) end end)
	pcall(function() killIn(game:GetService("CoreGui")) end)
	pcall(function() killIn(LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui")) end)
	killIn(getParent())
end

local ScreenGui       = Instance.new("ScreenGui")
ScreenGui.Name        = "NexusHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent      = getParent()

_G.__NEXUS_UI = function() ScreenGui:Destroy() end

--========================== FLAGS / API (nut BAT-TAT that) ==========================--
_G.NEXUS_Flags = _G.NEXUS_Flags or {}
_G.NEXUS_Callbacks = _G.NEXUS_Callbacks or {}

function _G.NEXUS_SetToggle(title, state)
	_G.NEXUS_Flags[title] = state
	local cbs = _G.NEXUS_Callbacks[title]
	if cbs then
		for _, cb in ipairs(cbs) do
			pcall(cb, state)
		end
	end
end

function _G.NEXUS_OnToggle(title, cb)
	_G.NEXUS_Callbacks[title] = _G.NEXUS_Callbacks[title] or {}
	table.insert(_G.NEXUS_Callbacks[title], cb)
	-- tra ve trang thai hien tai neu co
	if _G.NEXUS_Flags[title] ~= nil then
		pcall(cb, _G.NEXUS_Flags[title])
	end
end

function _G.NEXUS_GetToggle(title)
	return _G.NEXUS_Flags[title]
end
-- alias cho slider (chung kho _G.NEXUS_Flags)
_G.NEXUS_GetSlider = _G.NEXUS_GetToggle
function _G.NEXUS_SetSlider(title, v)
	_G.NEXUS_SetToggle(title, v)
end

--========================== HELPERS ==========================--
local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = p
end
local function stroke(p, col, th)
	local s = Instance.new("UIStroke")
	s.Color = col or C.border
	s.Thickness = th or 1
	pcall(function() s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
	s.Parent = p
end
local function pad(p, t, r, b, l)
	local u = Instance.new("UIPadding")
	u.PaddingTop    = UDim.new(0, t)
	u.PaddingRight  = UDim.new(0, r or t)
	u.PaddingBottom = UDim.new(0, b or t)
	u.PaddingLeft   = UDim.new(0, l or r or t)
	u.Parent = p
end
local function list(p, dir, gap)
	local l = Instance.new("UIListLayout")
	l.FillDirection = dir or Enum.FillDirection.Vertical
	l.SortOrder     = Enum.SortOrder.LayoutOrder
	l.Padding       = UDim.new(0, gap or 0)
	l.Parent = p
	return l
end
local function label(p, txt, size, col, xalign, font)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text  = txt
	l.TextSize = size or 12
	l.TextColor3 = col or C.text
	l.Font  = font or FONT
	l.TextXAlignment = xalign or Enum.TextXAlignment.Left
	l.Parent = p
	regFont(l, font == FONTBOLD or font == FONTBOLD)
	return l
end
local function frame(p, size, pos, col, name)
	local f = Instance.new("Frame")
	f.Size = size
	f.Position = pos or UDim2.new()
	f.BackgroundColor3 = col or C.bg
	f.BorderSizePixel = 0
	if name then f.Name = name end
	f.Parent = p
	return f
end
local function scrollFrame(p, size, pos)
	local f = Instance.new("ScrollingFrame")
	f.Size = size
	f.Position = pos or UDim2.new()
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.ScrollBarThickness = 3
	pcall(function() f.ScrollBarImageColor3 = C.border end)
	f.CanvasSize = UDim2.new(0, 0, 0, 0)
	-- game cu khong co Enum.AutomaticCanvasSize -> pcall de khong chet script
	local hasAuto = pcall(function()
		f.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
	end)
	f.Parent = p
	if not hasAuto then
		-- fallback cho client cu: tu cap nhat CanvasSize theo UIListLayout
		task.spawn(function()
			task.wait(0.3)
			local layout = f:FindFirstChildOfClass("UIListLayout")
			if layout then
				local function upd()
					pcall(function()
						f.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
					end)
				end
				pcall(function()
					layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
				end)
				-- update dinh ky phong khi signal khong chay
				for i = 1, 20 do upd() task.wait(0.5) end
			else
				pcall(function()
					f.CanvasSize = UDim2.new(0, 0, 0, 600)
				end)
			end
		end)
	end
	return f
end

-- mark logo "S": o vuong gradient do xoay + vien trang mo (thay asset id)
local function logoMark(parent, px, pos, z)
	local m = frame(parent, UDim2.fromOffset(px, px), pos, Color3.new(1, 1, 1))
	m.Name = "LogoMark"
	m.BorderSizePixel = 0
	if z then m.ZIndex = z end
	corner(m, math.floor(px * 0.3))
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 120)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 38, 38)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 20, 20)),
	})
	g.Rotation = 45
	g.Parent = m
	local s = label(m, "S", math.floor(px * 0.55), Color3.new(1, 1, 1),
		Enum.TextXAlignment.Center, FONTBOLD)
	s.Size = UDim2.fromScale(1, 1)
	s.TextYAlignment = Enum.TextYAlignment.Center
	if z then s.ZIndex = z + 1 end
	local st = Instance.new("UIStroke")
	st.Color = Color3.new(1, 1, 1)
	st.Transparency = 0.8
	st.Thickness = 1
	pcall(function() st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
	st.Parent = m
	task.spawn(function()
		while m.Parent do
			pcall(function()
				local tw = TweenService:Create(g,
					TweenInfo.new(5, Enum.EasingStyle.Linear),
					{Rotation = 405})
				tw:Play()
				tw.Completed:Wait()
				g.Rotation = 45
			end)
			task.wait(0.2)
		end
	end)
	return m
end

--========================== ROOT WINDOW (xam den, da xoa vien do) ==========================--
local Win = frame(ScreenGui,
	UDim2.fromOffset(680, 440),
	UDim2.new(0.5, -340, 0.5, -220),
	C.bg, "Win")
Win.ZIndex = 2
Win.ClipsDescendants = true -- background trong khong tran ra ngoai vien
corner(Win, 12)
-- vien ngoai: chi giu lop trang mo nhe (da xoa vien do)
do
	local w2 = Instance.new("UIStroke")
	w2.Color = Color3.new(1, 1, 1)
	w2.Transparency = 0.9
	w2.Thickness = 1
	pcall(function() w2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
	w2.Parent = Win
end

-- open animation
Win.Size = UDim2.fromOffset(0, 0)
pcall(function()
	TweenService:Create(Win,
		TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = UDim2.fromOffset(680, 440)}):Play()
end)

--========================== MAN HINH LOADING ==========================--
do
	local load = frame(Win, UDim2.fromScale(1, 1), UDim2.new(), C.bg, "Loading")
	load.ZIndex = 50
	load.Active = true
	corner(load, 12)

	local loadIcon = logoMark(load, 64, UDim2.new(0.5, -32, 0.5, -70), 51)

	local lname = label(load, "SodiumHub", 18, Color3.new(1, 1, 1), Enum.TextXAlignment.Center, FONTBOLD)
	lname.Position = UDim2.new(0, 0, 0.5, 0)
	lname.Size = UDim2.new(1, 0, 0, 24)
	lname.ZIndex = 51
	do
		local lg = Instance.new("UIGradient")
		lg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 90, 90)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 29, 29)),
		})
		lg.Parent = lname
	end
	-- typing: go "Sd" -> xoa "d" -> go "SodiumHub", con tro | chop tat
	lname.Text = ""
	task.spawn(function()
		local base = ""
		local showCur = true
		local alive = true
		-- tach chuoi UTF-8 thanh tung ky tu (ky tu dac biet dai nhieu byte)
		local function chars(s)
			local out = {}
			for c in string.gmatch(s, "([%z\1-\127\194-\244][\128-\191]*)") do
				table.insert(out, c)
			end
			return out
		end
		task.spawn(function()
			while alive and lname.Parent do
				showCur = not showCur
				pcall(function()
					lname.Text = base .. (showCur and "|" or "")
				end)
				task.wait(0.5)
			end
		end)
		local function typeTo(s, speed)
			local cs = chars(s)
			for i = 1, #cs do
				if not lname.Parent then alive = false return end
				base = table.concat(cs, "", 1, i)
				task.wait(speed or 0.1)
			end
		end
		task.wait(0.3)
		typeTo("Sd", 0.25)   -- go Sd
		task.wait(0.5)
		base = "S"            -- xoa d
		task.wait(0.4)
		typeTo("SodiumHub", 0.18) -- go tiep thanh SodiumHub
		task.wait(1.2)
		alive = false
		pcall(function()
			if lname.Parent then lname.Text = "SodiumHub" end
		end)
	end)

	local barBg = frame(load, UDim2.fromOffset(220, 5), UDim2.new(0.5, -110, 0.5, 34), C.border)
	corner(barBg, 3)
	barBg.ZIndex = 51
	local barFill = frame(barBg, UDim2.new(0, 0, 1, 0), UDim2.new(), C.accent)
	corner(barFill, 3)
	barFill.ZIndex = 52
	do
		local fg = Instance.new("UIGradient")
		fg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 110, 110)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 28, 28)),
		})
		fg.Parent = barFill
	end

	local pct = label(load, "0%", 11, C.muted, Enum.TextXAlignment.Center, FONTBOLD)
	pct.Position = UDim2.new(0, 0, 0.5, 48)
	pct.Size = UDim2.new(1, 0, 0, 16)
	pct.ZIndex = 51

	-- mua do roi trong luc load
	task.spawn(function()
		while load.Parent do
			pcall(function()
				local w = 680
				pcall(function() w = math.floor(load.AbsoluteSize.X) end)
				if w < 50 then w = 680 end
				local drop = frame(load,
					UDim2.fromOffset(2, math.random(8, 16)),
					UDim2.fromOffset(math.random(0, w - 4), -20),
					C.accent)
				drop.BorderSizePixel = 0
				drop.ZIndex = 52
				drop.BackgroundTransparency = 1
				-- mo dan khi vua roi
				TweenService:Create(drop,
					TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{BackgroundTransparency = 0.25}):Play()
				local x = drop.Position.X.Offset
				local dur = 0.4 + math.random() * 0.5
				TweenService:Create(drop,
					TweenInfo.new(dur, Enum.EasingStyle.Linear),
					{Position = UDim2.fromOffset(x, 450)}):Play()
				task.delay(dur + 0.1, function()
					pcall(function() drop:Destroy() end)
				end)
			end)
			task.wait(0.05)
		end
	end)

	task.spawn(function()
		for i = 0, 100, 1 do
			pcall(function()
				if not load.Parent then return end
				barFill.Size = UDim2.new(i / 100, 0, 1, 0)
				pct.Text = i .. "%"
			end)
			task.wait(0.035)
		end
		task.wait(0.2)
		pcall(function()
			local f = TweenService:Create(load, TweenInfo.new(0.35),
				{BackgroundTransparency = 1})
			f:Play()
			for _, o in ipairs(load:GetDescendants()) do
				pcall(function()
					if o:IsA("TextLabel") then
						TweenService:Create(o, TweenInfo.new(0.35),
							{TextTransparency = 1}):Play()
					elseif o:IsA("ImageLabel") then
						TweenService:Create(o, TweenInfo.new(0.35),
							{ImageTransparency = 1}):Play()
					elseif o:IsA("Frame") then
						TweenService:Create(o, TweenInfo.new(0.35),
							{BackgroundTransparency = 1}):Play()
					end
				end)
			end
			f.Completed:Wait()
		end)
		pcall(function() load:Destroy() end)
	end)
end

-- drag
do
	local dragBar, dragging, ds, sp
	local function setupDrag(bar)
		bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging, ds, sp = true, i.Position, Win.Position
				i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
	end
	-- attach drag to topbar later
	_G.__NEXUS_SetupDrag = setupDrag
end

UserInputService.InputChanged:Connect(function(i)
	-- handled per-component above
end)

--========================== LAYOUT: SIDEBAR + MAIN ==========================--
-- Sidebar (140px)
local Sidebar = frame(Win,
	UDim2.new(0, 140, 1, 0), UDim2.new(),
	C.bg, "Sidebar")
corner(Sidebar, 12)
-- fill right side corners
local sbFix = frame(Sidebar,
	UDim2.new(0, 12, 1, 0), UDim2.new(1, -12, 0, 0),
	C.bg)

-- Main area
local Main = frame(Win,
	UDim2.new(1, -140, 1, 0), UDim2.new(0, 140, 0, 0),
	C.bg, "Main")

-- vien doc ngan cach sidebar trai va menu: gradient mo 2 dau + tho nhe
local sideDiv = frame(Win, UDim2.new(0, 2, 1, 0), UDim2.new(0, 140, 0, 0), C.accent)
sideDiv.BorderSizePixel = 0
sideDiv.ZIndex = 3
do
	local dg = Instance.new("UIGradient")
	dg.Rotation = 90
	dg.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 0),
		NumberSequenceKeypoint.new(0.85, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	dg.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 120)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 38, 38)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 120)),
	})
	dg.Parent = sideDiv
	task.spawn(function()
		while sideDiv.Parent do
			pcall(function()
				local a = TweenService:Create(sideDiv,
					TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{BackgroundTransparency = 0.1})
				a:Play() a.Completed:Wait()
				local b = TweenService:Create(sideDiv,
					TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{BackgroundTransparency = 0.45})
				b:Play() b.Completed:Wait()
			end)
			task.wait(0.1)
		end
	end)
end

--========================== SIDEBAR: LOGO ==========================--
local LogoArea = frame(Sidebar,
	UDim2.new(1, 0, 0, 52), UDim2.new(),
	C.bg, "Logo")
-- bottom border
local logoBorder = frame(LogoArea,
	UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1),
	C.border)

local logoIcon = Instance.new("ImageLabel")
logoIcon.Name = "LogoIcon"
logoIcon.Size = UDim2.fromOffset(35, 35)
logoIcon.Position = UDim2.fromOffset(8, 8)
logoIcon.BackgroundTransparency = 1
logoIcon.BorderSizePixel = 0
logoIcon.Image = "rbxassetid://110499565626919"
logoIcon.ScaleType = Enum.ScaleType.Stretch
logoIcon.Parent = LogoArea
pcall(function()
	local logoIconCorner = Instance.new("UICorner")
	logoIconCorner.CornerRadius = UDim.new(0, 6)
	logoIconCorner.Parent = logoIcon
end)

local logoName = label(LogoArea, "SodiumHub", 13, Color3.new(1, 1, 1), nil, FONTBOLD)
logoName.Position = UDim2.fromOffset(48, 12)
logoName.Size = UDim2.new(1, -54, 0, 18)
-- gradient do sang -> do dam cho chu SodiumHub + xoay cham cho song dong
do
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 90, 90)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 29, 29)),
	})
	grad.Rotation = 0
	grad.Parent = logoName
	-- xoay gradient cham (hieu ung chay mau)
	task.spawn(function()
		while logoName.Parent do
			pcall(function()
				local tw = TweenService:Create(grad,
					TweenInfo.new(4, Enum.EasingStyle.Linear),
					{Rotation = 360})
				tw:Play()
				tw.Completed:Wait()
				grad.Rotation = 0
			end)
			task.wait(0.2)
		end
	end)
end

local logoSub = label(LogoArea, "v1.6", 10, C.muted)
logoSub.Position = UDim2.fromOffset(48, 31)
logoSub.Size = UDim2.new(1, -54, 0, 14)

--========================== SIDEBAR: TABS ==========================--
local TabScroll = scrollFrame(Sidebar,
	UDim2.new(1, 0, 1, -136), UDim2.new(0, 0, 0, 84))
pad(TabScroll, 8, 6)
local TabList = list(TabScroll, nil, 2)

-- player info nam day sidebar trai (avatar + ten + ID)
do
	local pbox = frame(Sidebar, UDim2.new(1, 0, 0, 52), UDim2.new(0, 0, 1, -52), C.bg, "PlayerBox")
	corner(pbox, 10) -- bo day de khop goc bo cua menu
	frame(pbox, UDim2.new(1, 0, 0, 1), UDim2.new(), C.border)
	local av = Instance.new("ImageLabel")
	av.Size = UDim2.fromOffset(30, 30)
	av.Position = UDim2.fromOffset(8, 11)
	av.BackgroundColor3 = C.panel
	av.BorderSizePixel = 0
	av.Parent = pbox
	corner(av, 15)
	task.spawn(function()
		pcall(function()
			local url = Players:GetUserThumbnailAsync(
				LP.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100)
			if url and url ~= "" then av.Image = url end
		end)
	end)
	local nm = label(pbox, "SodiumSX", 14, C.accent, nil, FONTBOLD)
	nm.Position = UDim2.fromOffset(44, 7)
	nm.Size = UDim2.new(1, -48, 0, 20)
	pcall(function() nm.TextTruncate = Enum.TextTruncate.AtEnd end)
	local uid = label(pbox, "SodiumHub", 9, C.muted)
	uid.Position = UDim2.fromOffset(44, 27)
	uid.Size = UDim2.new(1, -48, 0, 13)
end

local pages      = {}  -- [name] = Frame
local tabButtons = {}  -- [name] = Frame (tab row)
local sideLabels = {}  -- nhan MAIN / MISC (an khi loc)
local FeatureIndex = {} -- {title, tab, row} de tim chuc nang trong tab
local currentTab = nil

-- tim tab chua 1 row bang cach di nguoc len Page_<ten>
local function findTabOfSafe(obj)
	local p = obj and obj.Parent
	while p do
		if p.Name and string.sub(p.Name, 1, 5) == "Page_" then
			return string.sub(p.Name, 6)
		end
		p = p.Parent
	end
	return nil
end
local function regFeature(title, row)
	pcall(function()
		if title and tostring(title) ~= "" and row then
			table.insert(FeatureIndex, {
				title = tostring(title),
				lower = string.lower(tostring(title)),
				tab = findTabOfSafe(row),
				row = row,
			})
		end
	end)
end
-- chop sang row tim thay
local function flashRow(row)
	pcall(function()
		if not row or not row.Parent then return end
		row.BackgroundColor3 = C.accent2
		local tw = TweenService:Create(row, TweenInfo.new(0.25),
			{BackgroundTransparency = 0.2})
		tw:Play()
		tw.Completed:Wait()
		local tw2 = TweenService:Create(row, TweenInfo.new(0.6),
			{BackgroundTransparency = 1})
		tw2:Play()
	end)
end

local function sideLabel(txt)
	local l = label(TabScroll, txt, 9, C.muted, nil, FONTBOLD)
	l.Size = UDim2.new(1, 0, 0, 22)
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = #TabScroll:GetChildren()
	table.insert(sideLabels, l)
end

local function paintTabs(sel)
	for n, tb in pairs(tabButtons) do
		local on = (n == sel)
		pcall(function()
			TweenService:Create(tb.row, TweenInfo.new(0.15),
				{BackgroundColor3 = on and C.panel or C.bg}):Play()
			tb.ico.TextColor3 = on and Color3.new(1, 1, 1) or C.muted
			tb.bar.BackgroundTransparency = on and 0 or 1
			tb.txt.TextColor3 = on and C.text or C.muted
			tb.txt.Position = UDim2.fromOffset(on and 42 or 38, 0)
		end)
	end
end

local function makeTab(name, icon, lo)
	local row = frame(TabScroll, UDim2.new(1, 0, 0, 36), nil, C.bg, "Tab_"..name)
	row.LayoutOrder = lo
	corner(row, 8)

	-- thanh chi bao do ben trai (hien khi duoc chon)
	local bar = frame(row, UDim2.fromOffset(3, 22), UDim2.fromOffset(0, 7), C.accent)
	corner(bar, 2)
	bar.BackgroundTransparency = 1

	-- icon khong khung (chu truc tiep)
	local ico = label(row, icon, 14, C.muted, nil, FONTBOLD)
	ico.Position = UDim2.fromOffset(12, 0)
	ico.Size = UDim2.fromOffset(18, 36)
	ico.TextYAlignment = Enum.TextYAlignment.Center

	local txt = label(row, name, 12, C.muted)
	txt.Position = UDim2.fromOffset(38, 0)
	txt.Size = UDim2.new(1, -48, 1, 0)
	txt.TextYAlignment = Enum.TextYAlignment.Center

	tabButtons[name] = {row = row, ico = ico, txt = txt, bar = bar}

	-- hover: sang nhe + chu truot phai khi chua chon
	row.MouseEnter:Connect(function()
		if currentTab ~= name then
			pcall(function()
				TweenService:Create(row, TweenInfo.new(0.12),
					{BackgroundColor3 = C.hover}):Play()
				TweenService:Create(txt, TweenInfo.new(0.12),
					{Position = UDim2.fromOffset(42, 0)}):Play()
			end)
		end
	end)
	row.MouseLeave:Connect(function()
		if currentTab ~= name then
			pcall(function()
				TweenService:Create(row, TweenInfo.new(0.15),
					{BackgroundColor3 = C.bg}):Play()
				TweenService:Create(txt, TweenInfo.new(0.15),
					{Position = UDim2.fromOffset(38, 0)}):Play()
			end)
		end
	end)

	row.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			paintTabs(name)
			for n, pg in pairs(pages) do
				pg.Visible = (n == name)
			end
			currentTab = name
		end
	end)
	return row
end

-- build sidebar nav
sideLabel("  MAIN")
makeTab("Combat",   "?", 2)
makeTab("Visuals",  "?", 3)
makeTab("Player",   "?", 4)
sideLabel("  MISC")
makeTab("Settings", "?", 6)
makeTab("Scripts",  "?", 7)

-- o tim kiem tren cung tab trai (loc tab theo ten)
local searchBox = frame(Sidebar, UDim2.new(1, -12, 0, 26), UDim2.fromOffset(6, 56), C.panel)
corner(searchBox, 8)
stroke(searchBox, C.border, 1)
local searchInput = Instance.new("TextBox")
searchInput.Size = UDim2.fromScale(1, 1)
searchInput.BackgroundTransparency = 1
searchInput.BorderSizePixel = 0
searchInput.Text = ""
searchInput.PlaceholderText = "Tìm kiếm..."
searchInput.PlaceholderColor3 = C.muted
searchInput.TextColor3 = C.text
searchInput.TextSize = 12
searchInput.Font = FONT
searchInput.TextXAlignment = Enum.TextXAlignment.Left
searchInput.ClearTextOnFocus = false
searchInput.Parent = searchBox
regFont(searchInput, false)
do
	local sp = Instance.new("UIPadding")
	sp.PaddingLeft = UDim.new(0, 10)
	sp.PaddingRight = UDim.new(0, 10)
	sp.Parent = searchInput
end
searchInput:GetPropertyChangedSignal("Text"):Connect(function()
	local q = string.lower(searchInput.Text or "")
	pcall(function()
		if q == "" then
			for _, tb in pairs(tabButtons) do tb.row.Visible = true end
			for _, l in ipairs(sideLabels) do l.Visible = true end
			return
		end
		-- 1) khop ten tab -> loc tab
		local tabHit = false
		for name in pairs(tabButtons) do
			if string.find(string.lower(name), q, 1, true) then
				tabHit = true
				break
			end
		end
		if tabHit then
			for name, tb in pairs(tabButtons) do
				tb.row.Visible = (string.find(string.lower(name), q, 1, true) ~= nil)
			end
			for _, l in ipairs(sideLabels) do l.Visible = false end
			return
		end
		-- 2) khop ten chuc nang -> nhay toi tab chua no + chop sang
		for _, f in ipairs(FeatureIndex) do
			if string.find(f.lower, q, 1, true) and f.tab and pages[f.tab] then
				selectTab(f.tab)
				task.spawn(function()
					task.wait(0.1)
					flashRow(f.row)
				end)
				return
			end
		end
	end)
end)

--========================== MAIN: TOPBAR ==========================--
local Topbar = frame(Main, UDim2.new(1, 0, 0, 52), nil, C.bg, "Topbar")
-- bottom border
frame(Topbar, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1), C.border)
corner(Topbar, 0)

if _G.__NEXUS_SetupDrag then _G.__NEXUS_SetupDrag(Topbar) end
_G.__NEXUS_SetupDrag = nil

local tbTitle = label(Topbar, "Combat", 13, C.text, nil, FONTBOLD)
tbTitle.Position = UDim2.fromOffset(14, 0)
tbTitle.Size = UDim2.fromOffset(200, 52)
tbTitle.TextYAlignment = Enum.TextYAlignment.Center

-- badge ten game (giua topbar, dich len tren) + FPS o duoi -- PHANG 2D
local badge = frame(Topbar, UDim2.fromOffset(180, 22), UDim2.new(0.5, -90, 0.5, -23), C.accent2)
corner(badge, 20)
local badgeTxt = label(badge, "NINJA TYCOON  V4.7.6", 11, Color3.new(1,1,1), Enum.TextXAlignment.Center, FONTBOLD)
badgeTxt.Size = UDim2.fromScale(1,1)
badgeTxt.TextYAlignment = Enum.TextYAlignment.Center

-- FPS that duoi chu PRO
local fpsLbl = label(Topbar, "FPS: --", 13, C.muted, Enum.TextXAlignment.Center, FONTBOLD)
fpsLbl.Position = UDim2.new(0.5, -50, 0.5, 4)
fpsLbl.Size = UDim2.fromOffset(100, 16)
fpsLbl.TextYAlignment = Enum.TextYAlignment.Center
task.spawn(function()
	local frames = 0
	pcall(function()
		RunService.RenderStepped:Connect(function()
			frames = frames + 1
		end)
	end)
	while fpsLbl.Parent do
		task.wait(1)
		pcall(function()
			fpsLbl.Text = "FPS: " .. tostring(frames)
		end)
		frames = 0
	end
end)

-- (da xoa cham xanh + chu Connected theo yeu cau)

-- wire tab title to topbar
for name, tb in pairs(tabButtons) do
	tb.row.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			tbTitle.Text = name
		end
	end)
end

--========================== PAGE HELPERS ==========================--
local ContentArea = frame(Main,
	UDim2.new(1, 0, 1, -52), UDim2.new(0, 0, 0, 52),
	C.bg, "ContentArea")

local function makePage(name)
	local pg = frame(ContentArea, UDim2.fromScale(1,1), nil, C.bg, "Page_"..name)
	pg.Visible = false
	pages[name] = pg

	-- two columns
	local left  = scrollFrame(pg, UDim2.new(0.5, -1, 1, 0), UDim2.new())
	local right = scrollFrame(pg, UDim2.new(0.5, -1, 1, 0), UDim2.new(0.5, 1, 0, 0))
	pad(left, 10, 10)
	pad(right, 10, 10)
	list(left,  nil, 8)
	list(right, nil, 8)

	-- center divider
	frame(pg, UDim2.new(0, 1, 1, 0), UDim2.new(0.5, 0, 0, 0), C.border)

	return left, right
end

-- section label inside a column (gach do + chu cach dieu)
local function secLabel(parent, txt)
	local wrap = frame(parent, UDim2.new(1, 0, 0, 20))
	wrap.BackgroundTransparency = 1
	wrap.LayoutOrder = #parent:GetChildren()
	local bar = frame(wrap, UDim2.fromOffset(3, 12), UDim2.fromOffset(0, 4), C.accent)
	corner(bar, 2)
	local l = label(wrap, "  " .. txt, 9, C.muted, nil, FONTBOLD)
	l.Position = UDim2.fromOffset(8, 0)
	l.Size = UDim2.new(1, -8, 1, 0)
	l.TextYAlignment = Enum.TextYAlignment.Center
end

-- duong gach ngang chia section (co the kem chu o giua)
-- Vi du: rowDiv(L) | rowDiv(L, "PVP")
local function rowDiv(parent, txt)
	local hasTxt = txt and tostring(txt) ~= ""
	local d = frame(parent, UDim2.new(1, 0, 0, hasTxt and 22 or 14))
	d.BackgroundTransparency = 1
	d.LayoutOrder = #parent:GetChildren()
	if hasTxt then
		local l1 = frame(d, UDim2.new(0.5, -52, 0, 2), UDim2.new(0, 0, 0.5, -1), C.accent)
		local g1 = Instance.new("UIGradient")
		g1.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(127, 29, 29)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 110, 110)),
		})
		g1.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.45, 0),
			NumberSequenceKeypoint.new(1, 0),
		})
		g1.Parent = l1
		local l = label(d, tostring(txt), 9, C.muted, Enum.TextXAlignment.Center, FONTBOLD)
		l.Position = UDim2.new(0.5, -42, 0, 0)
		l.Size = UDim2.fromOffset(84, 22)
		l.TextYAlignment = Enum.TextYAlignment.Center
		local l2 = frame(d, UDim2.new(0.5, -52, 0, 2), UDim2.new(0.5, 52, 0.5, -1), C.accent)
		local g2 = Instance.new("UIGradient")
		g2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 110, 110)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 29, 29)),
		})
		g2.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.55, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		g2.Parent = l2
	else
		local l = frame(d, UDim2.new(1, -8, 0, 2), UDim2.new(0, 4, 0.5, -1), C.accent)
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(127, 29, 29)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 110, 110)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 29, 29)),
		})
		g.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.2, 0),
			NumberSequenceKeypoint.new(0.8, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		g.Parent = l
	end
	return d
end
-- doan van ban mo ta (nhieu dong, tu xuong hang)
-- Vi du: rowPara(L, "Noi dung...") | rowPara(L, "Tieu de", "Noi dung...", 64)
local function rowPara(parent, p1, p2, p3)
	local title, text, h
	if p2 == nil then
		title, text, h = nil, p1, 40
	elseif type(p2) == "number" then
		title, text, h = nil, p1, p2
	else
		title, text, h = p1, p2, (type(p3) == "number" and p3 or 58)
	end
	local d = frame(parent, UDim2.new(1, 0, 0, h))
	d.BackgroundTransparency = 1
	d.LayoutOrder = #parent:GetChildren()
	-- nen giong button (gradient panel -> bg) + gach do dau dong + vien ran chay
	local bg = frame(d, UDim2.fromScale(1, 1), UDim2.new(), C.panel)
	pcall(function() bg.BackgroundTransparency = 0.6 end)
	corner(bg, 6)
	do
		local pg = Instance.new("UIGradient")
		pg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.panel),
			ColorSequenceKeypoint.new(1, C.bg),
		})
		pg.Rotation = 90
		pg.Parent = bg
	end
	do
		local run = Instance.new("UIStroke")
		run.Color = Color3.fromRGB(255, 90, 90)
		run.Thickness = 2
		run.Transparency = 0.15
		pcall(function() run.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
		run.Parent = bg
		local rg = Instance.new("UIGradient")
		rg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 150)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 38, 38)),
		})
		rg.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.6, 1),
			NumberSequenceKeypoint.new(0.75, 0),
			NumberSequenceKeypoint.new(0.9, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		rg.Rotation = 0
		rg.Parent = run
		task.spawn(function()
			while run.Parent do
				pcall(function()
					local tw = TweenService:Create(rg,
						TweenInfo.new(1.6, Enum.EasingStyle.Linear),
						{Rotation = 360})
					tw:Play()
					tw.Completed:Wait()
					rg.Rotation = 0
				end)
				task.wait()
			end
		end)
	end
	local bar = frame(bg, UDim2.fromOffset(3, 0), UDim2.new(0, 8, 0, -16), C.accent)
	corner(bar, 2)
	local y = 4
	if title and tostring(title) ~= "" then
		-- tittle to, do dam de de nhin
		local t = label(bg, tostring(title), 14, C.accent, nil, FONTBOLD)
		t.Position = UDim2.fromOffset(12, 4)
		t.Size = UDim2.new(1, -18, 0, 20)
		y = 26
	end
	-- chu trang sang de doc
	local l = label(bg, tostring(text or ""), 12, C.text)
	l.Position = UDim2.fromOffset(12, y)
	l.Size = UDim2.new(1, -18, 1, -(y + 4))
	l.TextWrapped = true
	l.TextYAlignment = Enum.TextYAlignment.Top
	regFeature(title or text, d)
	return d, l
end

-- card row base
local function card(parent, h)
	local f = frame(parent, UDim2.new(1, 0, 0, h or 42), nil, C.card)
	f.LayoutOrder = #parent:GetChildren()
	corner(f, 8)
	stroke(f, C.border, 1)
	return f
end

-- toggle pill CO NHAN CLICK (nut tat / mo that) --
-- Tra ve: pill, knob, get(), set()
local function togglePill(parent, on, onChanged)
	local state = (on == true)

	local pillBtn = Instance.new("Frame")
	pillBtn.Size = UDim2.fromOffset(36, 20)
	pillBtn.Position = UDim2.new(1, -48, 0.5, -10)
	pillBtn.BackgroundColor3 = state and C.accent or C.panel
	pillBtn.BorderSizePixel = 0
	pillBtn.Parent = parent
	corner(pillBtn, 10)
	stroke(pillBtn, C.border, 1)

	local knob = frame(pillBtn, UDim2.fromOffset(16, 16),
		UDim2.fromOffset(state and 18 or 2, 2),
		Color3.new(1,1,1))
	corner(knob, 8)

	local function refresh(animate)
		local targetCol = state and C.accent or C.panel
		local targetPos = state and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)
		if animate then
			pcall(function()
				TweenService:Create(pillBtn, TweenInfo.new(0.15), {BackgroundColor3 = targetCol}):Play()
				TweenService:Create(knob, TweenInfo.new(0.15), {Position = targetPos}):Play()
			end)
		else
			pillBtn.BackgroundColor3 = targetCol
			knob.Position = targetPos
		end
	end

	local function set(v, fire)
		state = (v == true)
		refresh(true)
		if fire ~= false and onChanged then
			pcall(onChanged, state)
		end
	end

	-- khong connect click o day nua: rowToggle se tao 1 nut trong suot phu ca card
	-- de tranh double-toggle khi bam vao pill (pill la Frame hien thi thoi)
	return pillBtn, knob, function() return state end, set, refresh
end

-- row: title + nut BAT/TAT an duoc (KHONG KHUNG - nen trong suot)
-- callback(newState) se chay moi lan bam
local function rowToggle(parent, title, on, subtitle, callback)
	if type(subtitle) == "function" and callback == nil then
		callback, subtitle = subtitle, nil
	end
	local c = frame(parent, UDim2.new(1, 0, 0, subtitle and 48 or 38))
	c.BackgroundTransparency = 1
	c.BackgroundColor3 = C.hover
	corner(c, 6)
	c.LayoutOrder = #parent:GetChildren()
	c.Active = true

	local t = label(c, title, 12, C.text)
	t.Position = UDim2.fromOffset(4, subtitle and 8 or 10)
	t.Size = UDim2.new(1, -56, 0, 18)
	if subtitle then
		local s = label(c, subtitle, 10, C.muted)
		s.Position = UDim2.fromOffset(4, 28)
		s.Size = UDim2.new(1, -56, 0, 14)
	end

	-- luu flag toan cuc de file khac doc duoc: _G.NEXUS_Flags["Enabled"] = true/false
	if _G.NEXUS_Flags[title] == nil then
		_G.NEXUS_Flags[title] = (on == true)
	end

	local pill, knob, get, set
	local function fire(state)
		_G.NEXUS_Flags[title] = state
		if callback then pcall(callback, state) end
		local cbs = _G.NEXUS_Callbacks[title]
		if cbs then
			for _, cb in ipairs(cbs) do pcall(cb, state) end
		end
	end
	pill, knob, get, set = togglePill(c, _G.NEXUS_Flags[title], fire)

	-- 1 nut trong suot phu full card -> bam dau tren card cung toggle, khong bi double
	local hit = Instance.new("TextButton")
	hit.Size = UDim2.fromScale(1, 1)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	hit.ZIndex = 5
	hit.Parent = c
	hit.MouseButton1Click:Connect(function()
		set(not get(), true)
	end)
	-- hover: nen hang sang len (nhat hon background)
	hit.MouseEnter:Connect(function()
		pcall(function()
			TweenService:Create(c, TweenInfo.new(0.12),
				{BackgroundTransparency = 0}):Play()
		end)
	end)
	hit.MouseLeave:Connect(function()
		pcall(function()
			TweenService:Create(c, TweenInfo.new(0.15),
				{BackgroundTransparency = 1}):Play()
		end)
	end)

	-- API cho ben ngoai: _G.NEXUS_SetToggle("Enabled", true)
	regFeature(title, c)
	return {
		frame = c,
		pill = pill,
		get = get,
		set = function(v) set(v, true) end,
		setSilent = function(v) set(v, false) _G.NEXUS_Flags[title] = (v == true) end,
		onChanged = function(cb)
			_G.NEXUS_OnToggle(title, cb)
		end,
	}
end

-- row: title + slider KEO DUOC (KHONG KHUNG - nen trong suot)
-- callback(newVal) chay moi lan doi gia tri. Luu ở _G.NEXUS_Flags["FOV"]
local function rowSlider(parent, title, val, suffix, min, max, h, callback)
	if type(h) == "function" and callback == nil then
		callback, h = h, nil
	end
	min, max = (min or 0), (max or 100)
	suffix = suffix or ""
	local value = tonumber(val) or min
	value = math.clamp(value, min, max)
	if _G.NEXUS_Flags[title] ~= nil then
		value = math.clamp(tonumber(_G.NEXUS_Flags[title]) or value, min, max)
	else
		_G.NEXUS_Flags[title] = value
	end

	local c = frame(parent, UDim2.new(1, 0, 0, h or 56))
	c.BackgroundTransparency = 1
	c.BackgroundColor3 = C.hover
	corner(c, 6)
	c.LayoutOrder = #parent:GetChildren()
	local t = label(c, title, 12, C.text)
	t.Position = UDim2.fromOffset(4, 2)
	t.Size = UDim2.new(1, -80, 0, 18)

	local valLbl = label(c, tostring(value)..suffix, 11, C.accent, Enum.TextXAlignment.Right, FONTBOLD)
	valLbl.Position = UDim2.new(1, -60, 0, 2)
	valLbl.Size = UDim2.fromOffset(56, 18)

	-- track day hon, fill gradient do, thumb tron do (track giu mau toi de noi fill)
	local track = frame(c, UDim2.new(1,-8,0,5), UDim2.fromOffset(4,34), C.panel)
	corner(track, 3)
	-- fill
	local pct0 = math.clamp((value - min) / (max - min), 0, 1)
	local fill = frame(track, UDim2.new(pct0,0,1,0), nil, Color3.new(1, 1, 1))
	corner(fill, 3)
	do
		local fg = Instance.new("UIGradient")
		fg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 110, 110)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 28, 28)),
		})
		fg.Rotation = 0
		fg.Parent = fill
	end
	-- thumb: nut tron do dac, neo theo track nen khong tran
	local thumb = frame(track,
		UDim2.fromOffset(14,14),
		UDim2.new(pct0, -7, 0.5, -7),
		C.accent)
	corner(thumb, 7)

	local range = max - min
	local function roundVal(v)
		if range <= 5 then
			return math.floor(v * 100 + 0.5) / 100
		elseif range <= 50 then
			return math.floor(v * 10 + 0.5) / 10
		else
			return math.floor(v + 0.5)
		end
	end

	local function fire(v)
		_G.NEXUS_Flags[title] = v
		if callback then pcall(callback, v) end
		local cbs = _G.NEXUS_Callbacks[title]
		if cbs then
			for _, cb in ipairs(cbs) do pcall(cb, v) end
		end
	end

	local lastFire = 0
	local function refresh(newVal, notify, force)
		value = math.clamp(roundVal(newVal), min, max)
		local pct = 0
		if max > min then pct = math.clamp((value - min) / (max - min), 0, 1) end
		-- hinh cap nhat ngay lap tuc; callback bi han che tan suat cho do khung
		fill.Size = UDim2.new(pct, 0, 1, 0)
		thumb.Position = UDim2.new(pct, -7, 0.5, -7)
		valLbl.Text = tostring(value)..suffix
		if notify ~= false then
			local now = tick()
			if force or (now - lastFire) >= 0.06 then
				lastFire = now
				fire(value)
			end
		end
	end
	refresh(value, false)

	-- vung bam rong quanh track cho de keo (mobile)
	local hit = Instance.new("TextButton")
	hit.Size = UDim2.new(1, 0, 0, 24)
	hit.Position = UDim2.fromOffset(0, 28)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	hit.ZIndex = 5
	hit.Parent = c

	local dragging = false
	local function setFromInput(inputPos)
		local ok, res = pcall(function()
			local pos = track.AbsolutePosition
			local size = track.AbsoluteSize
			if size.X <= 0 then return end
			local p = math.clamp((inputPos.X - pos.X) / size.X, 0, 1)
			refresh(min + p * (max - min), true)
		end)
		return ok and res
	end

	hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			pcall(function() setFromInput(i.Position) end)
		end
	end)
	hit.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				refresh(value, true, true) -- chot gia tri cuoi
			end
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch) then
			setFromInput(i.Position)
		end
	end)
	-- rot ve giua / an toan: tha chuot ngoai nut cung dung keo + chot gia tri
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				refresh(value, true, true)
			end
		end
	end)
	-- hover / cham vao: thumb to ra + track sang len + nen hang sang len
	hit.MouseEnter:Connect(function()
		pcall(function()
			TweenService:Create(thumb, TweenInfo.new(0.12),
				{Size = UDim2.fromOffset(16, 16)}):Play()
			TweenService:Create(track, TweenInfo.new(0.12),
				{BackgroundColor3 = C.border}):Play()
			TweenService:Create(c, TweenInfo.new(0.12),
				{BackgroundTransparency = 0}):Play()
		end)
	end)
	hit.MouseLeave:Connect(function()
		if not dragging then
			pcall(function()
				TweenService:Create(thumb, TweenInfo.new(0.15),
					{Size = UDim2.fromOffset(14, 14)}):Play()
				TweenService:Create(track, TweenInfo.new(0.15),
					{BackgroundColor3 = C.panel}):Play()
				TweenService:Create(c, TweenInfo.new(0.15),
					{BackgroundTransparency = 1}):Play()
			end)
		end
	end)

	regFeature(title, c)
	return {
		frame = c,
		get = function() return value end,
		set = function(v) refresh(v, true, true) end,
		setSilent = function(v) refresh(v, false) _G.NEXUS_Flags[title] = value end,
		onChanged = function(cb) _G.NEXUS_OnToggle(title, cb) end,
	}
end

-- row: button BAM DUOC (KHONG KHUNG - vien mo, nen trong suot)
-- callback() chay moi lan bam. Vi du: rowButton(L, "Save Config", function() ... end)
-- Co desc: rowButton(L, "Save Config", "Mo ta nho o duoi", function() ... end)
local function rowButton(parent, title, desc, callback, h)
	if type(title) == "function" and desc == nil then
		callback, title = title, "Button"
	end
	if type(desc) == "function" and callback == nil then
		callback, desc = desc, nil
	end
	if type(desc) == "number" and h == nil then
		h, desc = desc, nil
	end
	local hasDesc = desc ~= nil and tostring(desc) ~= ""
	local c = frame(parent, UDim2.new(1, 0, 0, h or (hasDesc and 46 or 32)))
	c.BackgroundTransparency = 1
	c.LayoutOrder = #parent:GetChildren()
	c.Active = true

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromScale(1, 1)
	btn.BackgroundColor3 = C.hover
	btn.BackgroundTransparency = 0.55
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.Parent = c
	corner(btn, 8)
	-- chi giu vien ran chay (da xoa vien nau xam cu)
	do
		local run = Instance.new("UIStroke")
		run.Color = Color3.fromRGB(255, 90, 90)
		run.Thickness = 2
		run.Transparency = 0.15
		pcall(function() run.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
		run.Parent = btn
		local rg = Instance.new("UIGradient")
		rg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 150)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 38, 38)),
		})
		rg.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.6, 1),
			NumberSequenceKeypoint.new(0.75, 0),
			NumberSequenceKeypoint.new(0.9, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		rg.Rotation = 0
		rg.Parent = run
		task.spawn(function()
			while run.Parent do
				pcall(function()
					local tw = TweenService:Create(rg,
						TweenInfo.new(1.6, Enum.EasingStyle.Linear),
						{Rotation = 360})
					tw:Play()
					tw.Completed:Wait()
					rg.Rotation = 0
				end)
				task.wait()
			end
		end)
	end
	-- nen gradient + gach do dau nut
	do
		local bgg = Instance.new("UIGradient")
		bgg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.hover),
			ColorSequenceKeypoint.new(1, C.bg),
		})
		bgg.Rotation = 90
		bgg.Parent = btn
	end
	local bbar = frame(btn, UDim2.fromOffset(3, 0), UDim2.new(0, 8, 0, -16), C.accent)
	corner(bbar, 2)

	local ttl = label(btn, title, 14, C.accent, Enum.TextXAlignment.Left, FONTBOLD)
	ttl.BackgroundTransparency = 1
	pcall(function()
		ttl.TextStrokeTransparency = 0.75
		ttl.TextStrokeColor3 = Color3.new(0, 0, 0)
	end)
	if hasDesc then
		ttl.Position = UDim2.fromOffset(10, 5)
		ttl.Size = UDim2.new(1, -40, 0, 16)
		ttl.TextYAlignment = Enum.TextYAlignment.Center
		local sub = label(btn, tostring(desc), 12, C.text, Enum.TextXAlignment.Left, FONT)
		sub.Position = UDim2.fromOffset(10, 22)
		sub.Size = UDim2.new(1, -40, 0, 14)
		sub.TextYAlignment = Enum.TextYAlignment.Top
		sub.BackgroundTransparency = 1
	else
		ttl.Position = UDim2.fromOffset(10, 0)
		ttl.Size = UDim2.new(1, -40, 1, 0)
		ttl.TextYAlignment = Enum.TextYAlignment.Center
	end

	local arrow = label(btn, "▶", 16, C.accent, Enum.TextXAlignment.Right, FONTBOLD)
	arrow.Position = UDim2.new(1, -28, 0, 0)
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.TextYAlignment = Enum.TextYAlignment.Center
	arrow.BackgroundTransparency = 1

	local function flash()
		pcall(function()
			TweenService:Create(btn, TweenInfo.new(0.08),
				{BackgroundTransparency = 0}):Play()
			task.delay(0.12, function()
				pcall(function()
					TweenService:Create(btn, TweenInfo.new(0.15),
						{BackgroundTransparency = 0.55}):Play()
				end)
			end)
		end)
	end

	btn.MouseButton1Click:Connect(function()
		flash()
		if callback then pcall(callback) end
	end)
	-- hover: nut sang + chu trang + mui ten truot phai
	btn.MouseEnter:Connect(function()
		pcall(function()
			TweenService:Create(btn, TweenInfo.new(0.12),
				{BackgroundTransparency = 0.2}):Play()
			TweenService:Create(ttl, TweenInfo.new(0.12),
				{TextColor3 = Color3.new(1, 1, 1)}):Play()
			TweenService:Create(arrow, TweenInfo.new(0.12),
				{Position = UDim2.new(1, -26, 0, 0)}):Play()
		end)
	end)
	btn.MouseLeave:Connect(function()
		pcall(function()
			TweenService:Create(btn, TweenInfo.new(0.15),
				{BackgroundTransparency = 0.55}):Play()
			TweenService:Create(ttl, TweenInfo.new(0.15),
				{TextColor3 = C.accent}):Play()
			TweenService:Create(arrow, TweenInfo.new(0.15),
				{Position = UDim2.new(1, -28, 0, 0)}):Play()
		end)
	end)

	regFeature(title, c)
	return {
		frame = c,
		button = btn,
		click = function() flash() if callback then pcall(callback) end end,
		setText = function(t) ttl.Text = tostring(t) end,
	}
end

-- row: title + badge/key BAM DE SET KEY
-- Bam vao badge -> hien "..." -> nhan phim/mouse moi de gan
-- callback(newKey) chay moi lan doi. Luu o _G.NEXUS_Flags["Aim Key"]
local activeBind = nil -- badge dang cho nhan phim
local function rowBadge(parent, title, badgeTxt, col, callback)
	if type(col) == "function" and callback == nil then
		callback, col = col, nil
	end
	local current = tostring(badgeTxt or "-")
	if _G.NEXUS_Flags[title] ~= nil then
		current = tostring(_G.NEXUS_Flags[title])
	else
		_G.NEXUS_Flags[title] = current
	end

	local c = frame(parent, UDim2.new(1, 0, 0, 36))
	c.BackgroundTransparency = 1
	c.LayoutOrder = #parent:GetChildren()
	local t = label(c, title, 12, C.text)
	t.Position = UDim2.fromOffset(4, 0)
	t.Size = UDim2.new(1, -48, 1, 0)
	t.TextYAlignment = Enum.TextYAlignment.Center

	local badgeF = frame(c,
		UDim2.fromOffset(26, 26),
		UDim2.new(1, -30, 0.5, -13),
		C.bg)
	corner(badgeF, 7)
	-- vien giong float: lop ngoai gradient do + lop trong trang mo
	do
		local bb1 = Instance.new("UIStroke")
		bb1.Color = C.accent
		bb1.Thickness = 1.5
		pcall(function() bb1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
		bb1.Parent = badgeF
		local bbg = Instance.new("UIGradient")
		bbg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 120)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 38, 38)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 29, 29)),
		})
		bbg.Rotation = 45
		bbg.Parent = bb1
		local bb2 = Instance.new("UIStroke")
		bb2.Color = Color3.new(1, 1, 1)
		bb2.Transparency = 0.85
		bb2.Thickness = 1
		pcall(function() bb2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
		bb2.Parent = badgeF
	end
	local bl = label(badgeF, current, 9, col and Color3.new(1,1,1) or C.accent,
		Enum.TextXAlignment.Center, FONTBOLD)
	bl.Size = UDim2.fromScale(1,1)
	bl.TextYAlignment = Enum.TextYAlignment.Center

	-- gach chan mo thay cho khung hop
	local div = frame(c, UDim2.new(1, -8, 0, 1), UDim2.new(0, 4, 1, -1), C.border)
	pcall(function() div.BackgroundTransparency = 0.4 end)

	local conn = nil
	local function stopListen(restore)
		if conn then pcall(function() conn:Disconnect() end) conn = nil end
		if activeBind and activeBind.bl == bl then activeBind = nil end
		if restore then bl.Text = current end
	end
	local function fire(key)
		current = key
		_G.NEXUS_Flags[title] = key
		bl.Text = key
		if callback then pcall(callback, key) end
		local cbs = _G.NEXUS_Callbacks[title]
		if cbs then
			for _, cb in ipairs(cbs) do pcall(cb, key) end
		end
	end

	local hit = Instance.new("TextButton")
	hit.Size = UDim2.fromScale(1, 1)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	hit.ZIndex = 5
	hit.Parent = badgeF
	hit.MouseButton1Click:Connect(function()
		-- huy badge khac dang cho neu co
		if activeBind and activeBind.stop then
			pcall(activeBind.stop, true)
		end
		bl.Text = "..."
		local myBind = {}
		activeBind = myBind
		myBind.bl = bl
		myBind.stop = function(restore) stopListen(restore) end
		conn = UserInputService.InputBegan:Connect(function(i, gpe)
			if activeBind ~= myBind then return end
			local key = nil
			if i.KeyCode ~= Enum.KeyCode.Unknown then
				key = i.KeyCode.Name
			elseif i.UserInputType == Enum.UserInputType.MouseButton1 then
				key = "LMB"
			elseif i.UserInputType == Enum.UserInputType.MouseButton2 then
				key = "RMB"
			elseif i.UserInputType == Enum.UserInputType.MouseButton3 then
				key = "MMB"
			end
			if key then
				stopListen(false)
				fire(key)
			end
		end)
	end)

	regFeature(title, c)
	return {
		frame = c,
		get = function() return current end,
		set = function(v) fire(tostring(v)) end,
		onChanged = function(cb) _G.NEXUS_OnToggle(title, cb) end,
	}
end

local openDrop = nil -- dropdown dang mo (mo cai moi tu dong dong cai cu)

-- row: dropdown CHON 1 (bam tieu de de mo danh sach)
-- Vi du: rowDropSingle(L, "Aim Part", {"Head", "Torso", "Random"}, "Head", function(v) ... end)
local function rowDropSingle(parent, title, options, default, callback)
	if type(default) == "function" and callback == nil then
		callback, default = default, nil
	end
	options = options or {}
	local current = tostring(default or options[1] or "-")
	if _G.NEXUS_Flags[title] ~= nil then
		current = tostring(_G.NEXUS_Flags[title])
	else
		_G.NEXUS_Flags[title] = current
	end

	local c = frame(parent, UDim2.new(1, 0, 0, 38))
	c.BackgroundTransparency = 1
	c.BackgroundColor3 = C.bg
	corner(c, 6)
	c.LayoutOrder = #parent:GetChildren()
	c.Active = true
	local cstroke = Instance.new("UIStroke")
	cstroke.Color = C.accent
	cstroke.Thickness = 1
	cstroke.Transparency = 1
	pcall(function() cstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
	cstroke.Parent = c

	local t = label(c, title, 12, C.text)
	t.Position = UDim2.fromOffset(4, 0)
	t.Size = UDim2.new(1, -90, 0, 38)
	t.TextYAlignment = Enum.TextYAlignment.Center
	local val = label(c, current, 11, C.accent, Enum.TextXAlignment.Right, FONTBOLD)
	val.Position = UDim2.new(1, -84, 0, 0)
	val.Size = UDim2.fromOffset(60, 38)
	val.TextYAlignment = Enum.TextYAlignment.Center
	local chev = label(c, "▼", 12, C.muted, Enum.TextXAlignment.Center, FONTBOLD)
	chev.Position = UDim2.new(1, -24, 0, 0)
	chev.Size = UDim2.fromOffset(24, 38)
	chev.TextYAlignment = Enum.TextYAlignment.Center

	local opened = false
	local listH = math.max(#options, 1) * 28
	-- list trong suot, dinh lien header (hoa lam 1 khoi voi nut mo)
	local list = frame(c, UDim2.new(1, 0, 0, listH), UDim2.fromOffset(0, 38), C.card)
	list.BackgroundTransparency = 1
	list.Visible = false
	local optBtns = {}
	local function paintOpts()
		for opt, e in pairs(optBtns) do
			local on = (tostring(opt) == current)
			e.b.TextColor3 = on and C.accent or C.text
			e.b.TextSize = on and 13 or 12
			e.bar.BackgroundTransparency = on and 0 or 1
		end
	end
	local function fire(v)
		_G.NEXUS_Flags[title] = v
		if callback then pcall(callback, v) end
		local cbs = _G.NEXUS_Callbacks[title]
		if cbs then
			for _, cb in ipairs(cbs) do pcall(cb, v) end
		end
	end
	for i, opt in ipairs(options) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -8, 0, 28)
		b.Position = UDim2.new(0, 4, 0, (i - 1) * 28)
		b.BackgroundColor3 = C.bg
		b.BackgroundTransparency = 1
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		b.Text = "     " .. tostring(opt)
		b.TextSize = 12
		b.TextColor3 = C.text
		b.Font = FONT
		b.TextXAlignment = Enum.TextXAlignment.Left
		b.Parent = list
		corner(b, 5)
		regFont(b, false)
		-- thanh do danh dau muc dang chon
		local obar = frame(b, UDim2.fromOffset(3, 16), UDim2.fromOffset(5, 6), C.accent)
		corner(obar, 2)
		obar.BackgroundTransparency = 1
		optBtns[tostring(opt)] = {b = b, bar = obar}
		b.MouseEnter:Connect(function()
			pcall(function()
				b.BackgroundColor3 = C.hover
				TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0.35}):Play()
			end)
		end)
		b.MouseLeave:Connect(function()
			pcall(function()
				TweenService:Create(b, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
				task.delay(0.12, function() pcall(function() b.BackgroundColor3 = C.bg end) end)
			end)
		end)
		b.MouseButton1Click:Connect(function()
			current = tostring(opt)
			val.Text = current
			paintOpts()
			setOpen(false)
			fire(current)
		end)
	end
	paintOpts()

	local function setOpen(v)
		opened = v
		c.BackgroundColor3 = C.bg
		chev.Text = v and "▲" or "▼"
		chev.TextColor3 = v and C.accent or C.muted
		list.Visible = true
		-- mo/đong muot: tween chieu cao ca khoi
		pcall(function()
			local tw = TweenService:Create(c, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = UDim2.new(1, 0, 0, v and (38 + listH) or 38)})
			tw:Play()
			if not v then
				tw.Completed:Wait()
				if not opened then list.Visible = false end
			end
		end)
		if v then list.Visible = true end
		-- mo: hien khung bao quanh ca khoi; dong: ve trong suot
		pcall(function()
			TweenService:Create(c, TweenInfo.new(0.15),
				{BackgroundTransparency = v and 0 or 1}):Play()
			TweenService:Create(cstroke, TweenInfo.new(0.15),
				{Transparency = v and 0 or 1}):Play()
		end)
		if v then
			if openDrop and openDrop ~= setOpen then
				pcall(openDrop, false)
			end
			openDrop = setOpen
		elseif openDrop == setOpen then
			openDrop = nil
		end
	end

	local hit = Instance.new("TextButton")
	hit.Size = UDim2.new(1, 0, 0, 38)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	hit.ZIndex = 5
	hit.Parent = c
	hit.MouseButton1Click:Connect(function() setOpen(not opened) end)
	hit.MouseEnter:Connect(function()
		if opened then return end
		pcall(function()
			c.BackgroundColor3 = C.hover
			TweenService:Create(c, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
		end)
	end)
	hit.MouseLeave:Connect(function()
		if opened then return end
		pcall(function()
			TweenService:Create(c, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
			task.delay(0.15, function()
				if not opened then pcall(function() c.BackgroundColor3 = C.bg end) end
			end)
		end)
	end)

	regFeature(title, c)
	return {
		frame = c,
		get = function() return current end,
		set = function(v)
			current = tostring(v)
			val.Text = current
			paintOpts()
			fire(current)
		end,
		onChanged = function(cb) _G.NEXUS_OnToggle(title, cb) end,
	}
end

-- row: dropdown CHON NHIEU (tich nhieu muc, hien tom tat)
-- Vi du: rowDropMulti(L, "ESP Show", {"Name", "Box", "Health"}, {"Name", "Box"}, function(list) ... end)
local function rowDropMulti(parent, title, options, defaults, callback)
	if type(defaults) == "function" and callback == nil then
		callback, defaults = defaults, nil
	end
	options = options or {}
	local sel = {}
	if _G.NEXUS_Flags[title] ~= nil and type(_G.NEXUS_Flags[title]) == "table" then
		for _, v in ipairs(_G.NEXUS_Flags[title]) do sel[tostring(v)] = true end
	elseif type(defaults) == "table" then
		for _, v in ipairs(defaults) do sel[tostring(v)] = true end
	end
	local function copySel()
		local out = {}
		for _, opt in ipairs(options) do
			if sel[tostring(opt)] then table.insert(out, tostring(opt)) end
		end
		return out
	end
	_G.NEXUS_Flags[title] = copySel()

	local c = frame(parent, UDim2.new(1, 0, 0, 38))
	c.BackgroundTransparency = 1
	c.BackgroundColor3 = C.bg
	corner(c, 6)
	c.LayoutOrder = #parent:GetChildren()
	c.Active = true
	local cstroke = Instance.new("UIStroke")
	cstroke.Color = C.accent
	cstroke.Thickness = 1
	cstroke.Transparency = 1
	pcall(function() cstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
	cstroke.Parent = c

	local t = label(c, title, 12, C.text)
	t.Position = UDim2.fromOffset(4, 0)
	t.Size = UDim2.new(1, -110, 0, 38)
	t.TextYAlignment = Enum.TextYAlignment.Center
	local val = label(c, "", 11, C.accent, Enum.TextXAlignment.Right, FONTBOLD)
	val.Position = UDim2.new(1, -104, 0, 0)
	val.Size = UDim2.fromOffset(80, 38)
	val.TextYAlignment = Enum.TextYAlignment.Center
	local chev = label(c, "▼", 12, C.muted, Enum.TextXAlignment.Center, FONTBOLD)
	chev.Position = UDim2.new(1, -24, 0, 0)
	chev.Size = UDim2.fromOffset(24, 38)
	chev.TextYAlignment = Enum.TextYAlignment.Center

	local function summary()
		local names = {}
		for _, opt in ipairs(options) do
			if sel[tostring(opt)] then table.insert(names, tostring(opt)) end
		end
		if #names == 0 then return "Chưa chọn" end
		if #names == #options then return "Tất cả" end
		local s = table.concat(names, ", ")
		if #s > 22 then s = string.sub(s, 1, 22) .. "..." end
		return s
	end
	local function fire()
		local out = copySel()
		_G.NEXUS_Flags[title] = out
		if callback then pcall(callback, out) end
		local cbs = _G.NEXUS_Callbacks[title]
		if cbs then
			for _, cb in ipairs(cbs) do pcall(cb, out) end
		end
	end

	local opened = false
	local listH = math.max(#options, 1) * 28
	-- list trong suot, dinh lien header (hoa lam 1 khoi voi nut mo)
	local list = frame(c, UDim2.new(1, 0, 0, listH), UDim2.fromOffset(0, 38), C.card)
	list.BackgroundTransparency = 1
	list.Visible = false
	local optBtns = {}
	local paintMulti
	for i, opt in ipairs(options) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -8, 0, 28)
		b.Position = UDim2.new(0, 4, 0, (i - 1) * 28)
		b.BackgroundColor3 = C.bg
		b.BackgroundTransparency = 1
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		b.TextSize = 12
		b.Font = FONT
		b.TextXAlignment = Enum.TextXAlignment.Left
		b.Parent = list
		corner(b, 5)
		regFont(b, false)
		-- thanh do danh dau muc dang bat
		local obar = frame(b, UDim2.fromOffset(3, 16), UDim2.fromOffset(5, 6), C.accent)
		corner(obar, 2)
		obar.BackgroundTransparency = 1
		optBtns[tostring(opt)] = {b = b, bar = obar}
		b.MouseEnter:Connect(function()
			pcall(function()
				b.BackgroundColor3 = C.hover
				TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0.35}):Play()
			end)
		end)
		b.MouseLeave:Connect(function()
			pcall(function()
				TweenService:Create(b, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
				task.delay(0.12, function() pcall(function() b.BackgroundColor3 = C.bg end) end)
			end)
		end)
		b.MouseButton1Click:Connect(function()
			local k = tostring(opt)
			sel[k] = not sel[k]
			paintMulti()
			val.Text = summary()
			fire()
		end)
	end
	paintMulti = function()
		for opt, e in pairs(optBtns) do
			-- bat/tat phan biet bang mau + co chu + thanh do (khong [ ])
			local on = (sel[opt] == true)
			e.b.Text = "     " .. tostring(opt)
			e.b.TextColor3 = on and C.accent or C.muted
			e.b.TextSize = on and 13 or 12
			e.bar.BackgroundTransparency = on and 0 or 1
		end
	end
	paintMulti()
	val.Text = summary()

	local function setOpen(v)
		opened = v
		c.BackgroundColor3 = C.bg
		chev.Text = v and "▲" or "▼"
		chev.TextColor3 = v and C.accent or C.muted
		list.Visible = true
		-- mo/đong muot: tween chieu cao ca khoi
		pcall(function()
			local tw = TweenService:Create(c, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = UDim2.new(1, 0, 0, v and (38 + listH) or 38)})
			tw:Play()
			if not v then
				tw.Completed:Wait()
				if not opened then list.Visible = false end
			end
		end)
		if v then list.Visible = true end
		-- mo: hien khung bao quanh ca khoi; dong: ve trong suot
		pcall(function()
			TweenService:Create(c, TweenInfo.new(0.15),
				{BackgroundTransparency = v and 0 or 1}):Play()
			TweenService:Create(cstroke, TweenInfo.new(0.15),
				{Transparency = v and 0 or 1}):Play()
		end)
		if v then
			if openDrop and openDrop ~= setOpen then
				pcall(openDrop, false)
			end
			openDrop = setOpen
		elseif openDrop == setOpen then
			openDrop = nil
		end
	end

	local hit = Instance.new("TextButton")
	hit.Size = UDim2.new(1, 0, 0, 38)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	hit.ZIndex = 5
	hit.Parent = c
	hit.MouseButton1Click:Connect(function() setOpen(not opened) end)
	hit.MouseEnter:Connect(function()
		if opened then return end
		pcall(function()
			c.BackgroundColor3 = C.hover
			TweenService:Create(c, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
		end)
	end)
	hit.MouseLeave:Connect(function()
		if opened then return end
		pcall(function()
			TweenService:Create(c, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
			task.delay(0.15, function()
				if not opened then pcall(function() c.BackgroundColor3 = C.bg end) end
			end)
		end)
	end)

	regFeature(title, c)
	return {
		frame = c,
		get = function() return copySel() end,
		set = function(arr)
			table.clear(sel)
			if type(arr) == "table" then
				for _, v in ipairs(arr) do sel[tostring(v)] = true end
			end
			paintMulti()
			val.Text = summary()
			fire()
		end,
		onChanged = function(cb) _G.NEXUS_OnToggle(title, cb) end,
	}
end

-- row: CHON MAU (tieu de + hex + o mau vuong, bam mo bang mau + Apply)
-- Vi du: rowColorPicker(L, "UI Accent", "#DC2626", function(color, hex) ... end)
local function hexToColor(h)
	local s = tostring(h or ""):gsub("#", "")
	if #s == 6 then
		local r = tonumber(string.sub(s, 1, 2), 16)
		local g = tonumber(string.sub(s, 3, 4), 16)
		local b = tonumber(string.sub(s, 5, 6), 16)
		if r and g and b then return Color3.fromRGB(r, g, b) end
	end
	return C.accent
end
local function colorToHex(c)
	return string.format("#%02X%02X%02X",
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5))
end
_G.NEXUS_HexToColor = hexToColor
_G.NEXUS_ColorToHex = colorToHex
-- typeof khong co tren client cu -> tu check Color3
local function isColor3(v)
	if type(v) ~= "userdata" then return false end
	local ok = pcall(function() return v.R and v.G and v.B end)
	return ok
end

local function rowColorPicker(parent, title, default, callback)
	local startCol = C.accent
	if isColor3(default) then
		startCol = default
	elseif type(default) == "string" then
		startCol = hexToColor(default)
	end
	local startHex = colorToHex(startCol)
	if _G.NEXUS_Flags[title] ~= nil then
		startHex = tostring(_G.NEXUS_Flags[title])
		startCol = hexToColor(startHex)
	else
		_G.NEXUS_Flags[title] = startHex
	end
	local current, currentHex = startCol, startHex
	local pending, pendingHex = startCol, startHex

	local c = frame(parent, UDim2.new(1, 0, 0, 44))
	c.BackgroundTransparency = 1
	c.BackgroundColor3 = C.hover
	corner(c, 6)
	c.LayoutOrder = #parent:GetChildren()
	c.Active = true
	local cstroke = Instance.new("UIStroke")
	cstroke.Color = C.accent
	cstroke.Thickness = 1
	cstroke.Transparency = 1
	pcall(function() cstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
	cstroke.Parent = c

	local t = label(c, title, 12, C.text)
	t.Position = UDim2.fromOffset(4, 3)
	t.Size = UDim2.new(1, -60, 0, 18)
	local hexLbl = label(c, currentHex, 10, C.muted, nil, FONTBOLD)
	hexLbl.Position = UDim2.fromOffset(4, 23)
	hexLbl.Size = UDim2.new(1, -60, 0, 14)
	-- o mau vuong bo tron ben phai
	local prev = frame(c, UDim2.fromOffset(30, 30), UDim2.new(1, -38, 0.5, -15), current)
	corner(prev, 8)
	stroke(prev, C.border, 1)

	-- chuyen doi HSV (tu viet cho chac tren client cu)
	local function hsvToRgb(h, s, v)
		h = ((h % 1) + 1) % 1
		local c = v * s
		local hh = h * 6
		local x = c * (1 - math.abs(hh % 2 - 1))
		local r, g, b = 0, 0, 0
		local i = math.floor(hh) % 6
		if i == 0 then r, g, b = c, x, 0
		elseif i == 1 then r, g, b = x, c, 0
		elseif i == 2 then r, g, b = 0, c, x
		elseif i == 3 then r, g, b = 0, x, c
		elseif i == 4 then r, g, b = x, 0, c
		else r, g, b = c, 0, x end
		local m = v - c
		return Color3.new(r + m, g + m, b + m)
	end
	local function rgbToHsv(col)
		local r, g, b = col.R, col.G, col.B
		local mx = math.max(r, g, b)
		local mn = math.min(r, g, b)
		local d = mx - mn
		local h = 0
		if d > 0 then
			if mx == r then h = ((g - b) / d) % 6
			elseif mx == g then h = (b - r) / d + 2
			else h = (r - g) / d + 4 end
			h = h / 6
		end
		if h < 0 then h = h + 1 end
		return h, (mx == 0) and 0 or (d / mx), mx
	end
	local function hsvToHsl(h, s, v)
		local l = v * (1 - s / 2)
		local sl = 0
		if l > 0 and l < 1 then
			local m = math.min(l, 1 - l)
			if m > 0 then sl = (v - l) / m end
		end
		return h * 360, sl * 100, l * 100
	end
	local ph, ps, pv = rgbToHsv(pending)

	local padH, hueH = 140, 14
	local infoY = padH + 8 + hueH + 8
	local botY = infoY + 45 + 8
	local listH = botY + 30
	local opened = false
	local list = frame(c, UDim2.new(1, 0, 0, listH), UDim2.fromOffset(0, 44), C.bg)
	list.BackgroundTransparency = 1
	list.Visible = false

	-- o saturation/value lon
	local pad = frame(list, UDim2.new(1, -8, 0, padH), UDim2.fromOffset(4, 0), Color3.new(1, 1, 1))
	corner(pad, 8)
	local satG = Instance.new("UIGradient")
	satG.Rotation = 0
	satG.Parent = pad
	local valG = Instance.new("UIGradient")
	valG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
	})
	valG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	valG.Rotation = 90
	valG.Parent = pad
	local cur = frame(pad, UDim2.fromOffset(12, 12), UDim2.new(0, -6, 0, -6), Color3.new(1, 1, 1))
	corner(cur, 6)
	stroke(cur, Color3.fromRGB(40, 40, 40), 2)
	cur.ZIndex = 6

	-- thanh hue cau vong
	local hueBar = frame(list, UDim2.new(1, -8, 0, hueH), UDim2.fromOffset(4, padH + 8), Color3.new(1, 1, 1))
	corner(hueBar, 7)
	do
		local hg = Instance.new("UIGradient")
		hg.Rotation = 0
		hg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		})
		hg.Parent = hueBar
	end
	local thumb = frame(hueBar, UDim2.fromOffset(10, hueH + 6), UDim2.new(0, -5, 0.5, -(hueH + 6) / 2), Color3.new(1, 1, 1))
	corner(thumb, 5)
	stroke(thumb, Color3.fromRGB(40, 40, 40), 2)
	thumb.ZIndex = 6

	-- chi so Hex / RGB / HSL
	local infoHex = label(list, "", 11, C.text, nil, FONT)
	infoHex.Position = UDim2.fromOffset(4, infoY)
	infoHex.Size = UDim2.new(1, -8, 0, 15)
	local infoRGB = label(list, "", 11, C.text, nil, FONT)
	infoRGB.Position = UDim2.fromOffset(4, infoY + 15)
	infoRGB.Size = UDim2.new(1, -8, 0, 15)
	local infoHSL = label(list, "", 11, C.text, nil, FONT)
	infoHSL.Position = UDim2.fromOffset(4, infoY + 30)
	infoHSL.Size = UDim2.new(1, -8, 0, 15)

	-- o preview nho + nut Apply gon
	local bigPrev = frame(list, UDim2.fromOffset(30, 30), UDim2.fromOffset(4, botY - 4), pending)
	corner(bigPrev, 8)
	local apply = Instance.new("TextButton")
	apply.Size = UDim2.new(1, -46, 0, 30)
	apply.Position = UDim2.fromOffset(42, botY - 4)
	apply.BackgroundTransparency = 1
	apply.BorderSizePixel = 0
	apply.AutoButtonColor = false
	apply.Text = "✓ Apply"
	apply.TextSize = 13
	apply.TextColor3 = C.accent
	apply.Font = FONTBOLD
	apply.Parent = list
	regFont(apply, true)
	apply.MouseEnter:Connect(function()
		pcall(function()
			TweenService:Create(apply, TweenInfo.new(0.12),
				{TextColor3 = Color3.new(1, 1, 1)}):Play()
		end)
	end)
	apply.MouseLeave:Connect(function()
		pcall(function()
			TweenService:Create(apply, TweenInfo.new(0.15),
				{TextColor3 = C.accent}):Play()
		end)
	end)

	local function refreshPicker()
		pending = hsvToRgb(ph, ps, pv)
		pendingHex = colorToHex(pending)
		local hueCol = hsvToRgb(ph, 1, 1)
		satG.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, hueCol),
		})
		cur.Position = UDim2.new(ps, -6, 1 - pv, -6)
		thumb.Position = UDim2.new(ph, -5, 0.5, -(hueH + 6) / 2)
		prev.BackgroundColor3 = pending
		bigPrev.BackgroundColor3 = pending
		hexLbl.Text = pendingHex
		local r = math.floor(pending.R * 255 + 0.5)
		local g = math.floor(pending.G * 255 + 0.5)
		local b = math.floor(pending.B * 255 + 0.5)
		infoHex.Text = "Hex  " .. pendingHex
		infoRGB.Text = "RGB  " .. r .. ", " .. g .. ", " .. b
		local hh, ss, ll = hsvToHsl(ph, ps, pv)
		infoHSL.Text = string.format("HSL  %d, %d, %d",
			math.floor(hh + 0.5), math.floor(ss + 0.5), math.floor(ll + 0.5))
	end
	local function syncFromPending()
		ph, ps, pv = rgbToHsv(pending)
		refreshPicker()
	end
	refreshPicker()

	-- keo tren o SV
	local padDrag = false
	local padHit = Instance.new("TextButton")
	padHit.Size = UDim2.fromScale(1, 1)
	padHit.BackgroundTransparency = 1
	padHit.Text = ""
	padHit.AutoButtonColor = false
	padHit.ZIndex = 5
	padHit.Parent = pad
	local function padSet(inputPos)
		pcall(function()
			local pos = pad.AbsolutePosition
			local size = pad.AbsoluteSize
			if size.X <= 0 or size.Y <= 0 then return end
			ps = math.clamp((inputPos.X - pos.X) / size.X, 0, 1)
			pv = 1 - math.clamp((inputPos.Y - pos.Y) / size.Y, 0, 1)
			refreshPicker()
		end)
	end
	padHit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			padDrag = true
			padSet(i.Position)
		end
	end)
	padHit.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			padDrag = false
		end
	end)
	-- keo tren thanh hue
	local hueDrag = false
	local hueHit = Instance.new("TextButton")
	hueHit.Size = UDim2.fromScale(1, 1)
	hueHit.BackgroundTransparency = 1
	hueHit.Text = ""
	hueHit.AutoButtonColor = false
	hueHit.ZIndex = 5
	hueHit.Parent = hueBar
	local function hueSet(inputPos)
		pcall(function()
			local pos = hueBar.AbsolutePosition
			local size = hueBar.AbsoluteSize
			if size.X <= 0 then return end
			ph = math.clamp((inputPos.X - pos.X) / size.X, 0, 0.999)
			refreshPicker()
		end)
	end
	hueHit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			hueDrag = true
			hueSet(i.Position)
		end
	end)
	hueHit.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			hueDrag = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch then
			if padDrag then padSet(i.Position) end
			if hueDrag then hueSet(i.Position) end
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			padDrag, hueDrag = false, false
		end
	end)
	local function fire()
		_G.NEXUS_Flags[title] = pendingHex
		if callback then pcall(callback, pending, pendingHex) end
		local cbs = _G.NEXUS_Callbacks[title]
		if cbs then
			for _, cb in ipairs(cbs) do pcall(cb, pending, pendingHex) end
		end
	end
	apply.MouseButton1Click:Connect(function()
		current, currentHex = pending, pendingHex
		fire()
		setOpen(false)
	end)

	local function setOpen(v)
		opened = v
		if not v then
			-- dong khong Apply -> tra ve mau cu
			pending, pendingHex = current, currentHex
			syncFromPending()
		end
		list.Visible = true
		pcall(function()
			local tw = TweenService:Create(c, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = UDim2.new(1, 0, 0, v and (44 + listH) or 44)})
			tw:Play()
			if not v then
				tw.Completed:Wait()
				if not opened then list.Visible = false end
			end
		end)
		if v then list.Visible = true end
		-- mo: hien nen (khong vien do); dong: ve trong suot
		pcall(function()
			TweenService:Create(c, TweenInfo.new(0.15),
				{BackgroundTransparency = v and 0 or 1}):Play()
		end)
		if v then
			if openDrop and openDrop ~= setOpen then
				pcall(openDrop, false)
			end
			openDrop = setOpen
		elseif openDrop == setOpen then
			openDrop = nil
		end
	end

	local hit = Instance.new("TextButton")
	hit.Size = UDim2.new(1, 0, 0, 44)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	hit.ZIndex = 5
	hit.Parent = c
	hit.MouseButton1Click:Connect(function() setOpen(not opened) end)
	hit.MouseEnter:Connect(function()
		if opened then return end
		pcall(function()
			c.BackgroundColor3 = C.hover
			TweenService:Create(c, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
		end)
	end)
	hit.MouseLeave:Connect(function()
		if opened then return end
		pcall(function()
			TweenService:Create(c, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
			task.delay(0.15, function()
				if not opened then pcall(function() c.BackgroundColor3 = C.bg end) end
			end)
		end)
	end)

	regFeature(title, c)
	return {
		frame = c,
		get = function() return currentHex end,
		getColor = function() return current end,
		set = function(h)
			local col = isColor3(h) and h or hexToColor(h)
			current, currentHex = col, colorToHex(col)
			pending, pendingHex = col, currentHex
			syncFromPending()
			fire()
		end,
		onChanged = function(cb) _G.NEXUS_OnToggle(title, cb) end,
	}
end

-- tag (KHONG KHUNG - kieu gach chan)
local function rowTag(parent, title, tagTxt, tagCol)
	local c = frame(parent, UDim2.new(1, 0, 0, 36))
	c.BackgroundTransparency = 1
	c.LayoutOrder = #parent:GetChildren()
	local t = label(c, title, 12, C.text)
	t.Position = UDim2.fromOffset(4, 0)
	t.Size = UDim2.new(1, -86, 1, 0)
	t.TextYAlignment = Enum.TextYAlignment.Center

	local pill = frame(c, UDim2.fromOffset(66, 18), UDim2.new(1,-70,0.5,-9), tagCol)
	corner(pill, 20)
	local tl = label(pill, tagTxt, 9, Color3.new(1,1,1), Enum.TextXAlignment.Center, FONTBOLD)
	tl.Size = UDim2.fromScale(1,1)
	tl.TextYAlignment = Enum.TextYAlignment.Center

	local div = frame(c, UDim2.new(1, -8, 0, 1), UDim2.new(0, 4, 1, -1), C.border)
	pcall(function() div.BackgroundTransparency = 0.4 end)
	regFeature(title, c)
end

--========================== PAGE: COMBAT ==========================--
do
	local L, R = makePage("Combat")

	secLabel(L, "AIMBOT")
	rowToggle(L, "Enabled", true)
	rowSlider(L, "FOV", 180, "", 0, 360)
	rowBadge(L, "Aim Key",    "RMB")
	rowBadge(L, "Target Part","Head")
	rowSlider(L, "Smoothness", 3.1, "", 0, 10)
	rowSlider(L, "Prediction",  0.70, "", 0, 2)

	rowDiv(L)
	secLabel(L, "SILENT AIM")
	rowTag(L,   "Silent Aim",   "DETECTED", Color3.fromRGB(180, 60, 60))
	rowSlider(L, "Hit Chance",  80, "%", 0, 100)

	secLabel(R, "VISUALS")
	rowToggle(R, "Draw FOV Circle", true)
	rowSlider(R, "FOV Thickness",   1.5, "", 0.5, 5)
	rowToggle(R, "Target Indicator", false)
	rowToggle(R, "Hit Marker",      true)
	rowToggle(R, "Hit Marker Sound",true)

	rowDiv(R, "EXTRA")
	secLabel(R, "SETTINGS")
	rowToggle(R, "Team Check",   true)
	rowToggle(R, "Wall Check",   false)
	rowBadge(R,  "Target Priority", "Nearest")
end

--========================== PAGE: VISUALS ==========================--
do
	local L, R = makePage("Visuals")
	secLabel(L, "ESP")
	rowToggle(L, "Player ESP",   true)
	rowToggle(L, "Box ESP",      true)
	rowToggle(L, "Skeleton",     false)
	rowSlider(L, "ESP Distance", 800, "", 100, 2000)
	rowToggle(L, "Name Tag",     true)
	rowToggle(L, "Health Bar",   true)

	secLabel(R, "CHAMS")
	rowToggle(R, "Player Chams",   false)
	rowToggle(R, "Through Walls",  false)
	rowToggle(R, "Rainbow Chams",  false)
	rowSlider(R, "Chams Alpha", 80, "%", 0, 100)
end

--========================== PAGE: PLAYER ==========================--
do
	local L, R = makePage("Player")
	secLabel(L, "MOVEMENT")
	rowToggle(L, "Speed Hack",    false)
	rowSlider(L, "Walk Speed",    16, "", 16, 200)
	rowToggle(L, "Fly",           false)
	rowToggle(L, "No Clip",       false)
	rowSlider(L, "Fly Speed",     50, "", 10, 300)

	secLabel(R, "MISC")
	rowToggle(R, "Infinite Jump", false)
	rowToggle(R, "Anti-Void",     true)
	rowToggle(R, "No Fall Damage",true)
	rowToggle(R, "Anti-AFK",      true)
end

--========================== PAGE: SETTINGS ==========================--
do
	local L, R = makePage("Settings")
	secLabel(L, "KEYBINDS")
	rowBadge(L, "Toggle Menu",   "INSERT")
	rowBadge(L, "Toggle Aimbot", "F1")
	rowBadge(L, "Toggle ESP",    "F2")
	rowBadge(L, "Fly Toggle",    "F3")
	rowDropSingle(L, "Aim Part", {"Head", "Torso", "Random"}, "Head")
	rowDropMulti(L, "ESP Show", {"Name", "Box", "Health"}, {"Name", "Box"})
	rowColorPicker(L, "UI Accent", "#DC2626")

	secLabel(R, "CONFIG")
	rowTag(R, "Save Config",  "SAVED",   Color3.fromRGB(40, 140, 80))
	rowTag(R, "Load Config",  "DEFAULT", Color3.fromRGB(100, 60, 200))
	rowTag(R, "Reset All",    "DANGER",  Color3.fromRGB(180, 60, 60))
end

--========================== PAGE: SCRIPTS ==========================--
do
	local L, R = makePage("Scripts")
	secLabel(L, "QUICK SCRIPTS")
	rowToggle(L, "Auto Farm",    false)
	rowToggle(L, "Auto Collect", false)
	rowToggle(L, "Auto Sell",    false)
	rowToggle(L, "Auto Quest",   false)

	secLabel(R, "EXECUTOR")
	rowTag(R,   "Script Hub",   "ONLINE",  Color3.fromRGB(40, 140, 80))
	rowToggle(R, "Auto Execute", false)
	rowPara(R, "Ghi chú", "Bật Auto Execute để tự chạy script khi mở menu.")
	rowButton(R, "Test Notify", "Bấm để hiện thông báo test ở dưới", function()
		_G.NEXUS_Notify("SodiumHub", "Đây là thông báo test!", 2, "bottom")
	end)
end

--========================== SELECT DEFAULT TAB ==========================--
local function selectTab(name)
	paintTabs(name)
	for n, pg in pairs(pages) do
		pg.Visible = (n == name)
	end
	tbTitle.Text = name
	currentTab = name
end

-- wire tab clicks to also selectTab properly
for name, tb in pairs(tabButtons) do
	tb.row.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			selectTab(name)
		end
	end)
end

selectTab("Combat")

--========================== TOPBAR: NUT TAT / THU NHO ==========================--
do
	-- nut X tat menu (KHONG KHUNG - chi chu X, hover doi mau)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.fromOffset(30, 24)
	closeBtn.Position = UDim2.new(1, -36, 0.5, -12)
	closeBtn.BackgroundTransparency = 1
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "X"
	closeBtn.TextSize = 15
	closeBtn.TextColor3 = C.muted
	closeBtn.Font = FONTBOLD
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = Topbar
	regFont(closeBtn, true)

	closeBtn.MouseEnter:Connect(function()
		pcall(function()
			TweenService:Create(closeBtn, TweenInfo.new(0.12),
				{TextColor3 = C.accent}):Play()
		end)
	end)
	closeBtn.MouseLeave:Connect(function()
		pcall(function()
			TweenService:Create(closeBtn, TweenInfo.new(0.15),
				{TextColor3 = C.muted}):Play()
		end)
	end)
	closeBtn.MouseButton1Click:Connect(function()
		Win.Visible = false
	end)
end

--========================== RESIZE (keo goc phai duoi) ==========================--
do
	local grip = Instance.new("TextButton")
	grip.Name = "ResizeGrip"
	grip.Size = UDim2.fromOffset(22, 22)
	grip.Position = UDim2.new(1, -22, 1, -22)
	grip.BackgroundTransparency = 1
	grip.Text = ""
	grip.AutoButtonColor = false
	grip.Active = true
	grip.ZIndex = 10
	grip.Parent = Win
	-- ky tu resize
	local gripLbl = label(grip, "◿", 14, C.muted, Enum.TextXAlignment.Right, FONTBOLD)
	gripLbl.Size = UDim2.fromScale(1, 1)
	gripLbl.TextYAlignment = Enum.TextYAlignment.Bottom
	gripLbl.ZIndex = 11

	local resizing, rStart, rSize
	grip.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			rStart = i.Position
			rSize = Win.Size
		end
	end)
	local function stopResize(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			resizing = false
		end
	end
	grip.InputEnded:Connect(stopResize)
	UserInputService.InputEnded:Connect(stopResize)
	UserInputService.InputChanged:Connect(function(i)
		if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - rStart
			-- goc phai duoi: keo phai -> rong ra, keo xuong -> cao len (mep trai giu nguyen)
			local w = math.clamp(rSize.X.Offset + d.X, 480, 1000)
			local h = math.clamp(rSize.Y.Offset + d.Y, 320, 700)
			Win.Size = UDim2.fromOffset(w, h)
		end
	end)
end

--========================== DRAG (keo topbar di chuyen) ==========================--
do
	local dragging, ds, sp
	Topbar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; ds = i.Position; sp = Win.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - ds
			Win.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
		end
	end)
end

--========================== NUT TAT / MO MENU (FLOATING, MOBILE OK) ==========================--
local FloatBtn
do
	FloatBtn = Instance.new("TextButton")
	FloatBtn.Name = "FloatToggle"
	FloatBtn.Size = UDim2.fromOffset(52, 52)
	FloatBtn.Position = UDim2.new(0, 20, 0, 80)
	FloatBtn.AnchorPoint = Vector2.new(0, 0)
	FloatBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	FloatBtn.Text = ""
	FloatBtn.TextSize = 15
	FloatBtn.TextColor3 = Color3.new(1,1,1)
	FloatBtn.Font = FONTBOLD
	FloatBtn.AutoButtonColor = false
	FloatBtn.Active = true
	FloatBtn.ZIndex = 100
	FloatBtn.LayoutOrder = 999
	FloatBtn.BorderSizePixel = 0
	FloatBtn.Visible = true
	FloatBtn.Parent = ScreenGui
	regFont(FloatBtn, true)
	corner(FloatBtn, 10)
	-- vien 2 lop + gradient xoay: lop ngoai do gradient, lop trong trang mo tao chieu sau
	do
		local b1 = Instance.new("UIStroke")
		b1.Color = C.accent
		b1.Thickness = 2
		pcall(function() b1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
		b1.Parent = FloatBtn
		local bg = Instance.new("UIGradient")
		bg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 120)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 38, 38)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 29, 29)),
		})
		bg.Rotation = 45
		bg.Parent = b1
		local b2 = Instance.new("UIStroke")
		b2.Color = Color3.new(1, 1, 1)
		b2.Transparency = 0.85
		b2.Thickness = 1
		pcall(function() b2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
		b2.Parent = FloatBtn
		-- xoay gradient vien cham cho co hieu ung chay sang
		task.spawn(function()
			while b1.Parent do
				pcall(function()
					local tw = TweenService:Create(bg,
						TweenInfo.new(5, Enum.EasingStyle.Linear),
						{Rotation = 405})
					tw:Play()
					tw.Completed:Wait()
					bg.Rotation = 45
				end)
				task.wait(0.2)
			end
		end)
	end
	-- icon rbxassetid cua ban nam giua nut tron
	local floatIcon = Instance.new("ImageLabel")
	floatIcon.Name = "FloatIcon"
	floatIcon.Size = UDim2.new(1, -16, 1, -16)
	floatIcon.Position = UDim2.new(0, 8, 0, 8)
	floatIcon.BackgroundTransparency = 1
	floatIcon.BorderSizePixel = 0
	floatIcon.Image = "rbxassetid://110499565626919"
	floatIcon.ScaleType = Enum.ScaleType.Fit
	floatIcon.ZIndex = 101
	floatIcon.Parent = FloatBtn
	FloatBtn.Visible = true

	-- tat menu -> icon thu nho, bat menu -> icon phong lon
	local function setIconSize(visible)
		pcall(function()
			if visible then
				TweenService:Create(floatIcon,
					TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{Size = UDim2.new(1, -16, 1, -16), Position = UDim2.new(0, 8, 0, 8)}):Play()
			else
				TweenService:Create(floatIcon,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{Size = UDim2.new(1, -24, 1, -24), Position = UDim2.new(0, 12, 0, 12)}):Play()
			end
		end)
	end

	local function toggleUI()
		Win.Visible = not Win.Visible
		FloatBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		setIconSize(Win.Visible)
	end
	_G.NEXUS_ToggleUI = toggleUI

	-- keo nut tron di khap man hinh (mobile + pc)
	-- phan biet keo vs bam: chi mo menu khi THA TAY gan cho bat dau (<=10px)
	-- keo di xa hon thi coi la keo, khong mo menu
	local dragging, ds, sp
	FloatBtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			ds, sp = i.Position, FloatBtn.Position
		end
	end)
	FloatBtn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				local dist = 9999
				pcall(function() dist = (i.Position - ds).Magnitude end)
				if dist <= 10 then
					toggleUI()
				end
			end
		end
	end)
	-- tha tay ngoai nut: chi dung keo, khong mo menu
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - ds
			FloatBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
		end
	end)

	-- bao dam kill-old-instance cung xoa nut tron
	local oldKill = _G.__NEXUS_UI
	_G.__NEXUS_UI = function()
		pcall(oldKill)
		pcall(function() FloatBtn:Destroy() end)
	end
end

--========================== INSERT + PHIM TAT TOGGLE ==========================--
UserInputService.InputBegan:Connect(function(i, gpe)
	if gpe then return end
	if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.RightShift then
		if _G.NEXUS_ToggleUI then _G.NEXUS_ToggleUI() else Win.Visible = not Win.Visible end
	end
end)

--========================== NOTIFY CUSTOM ==========================--
-- _G.NEXUS_Notify("Tieu de", "Noi dung", 2)
-- tieu de do, chu trang, nen mau menu, khong vien, thanh dem nguoc + tieng
local NotifyRoot = frame(ScreenGui, UDim2.fromOffset(272, 320),
	UDim2.new(1, -284, 0, 12), Color3.new(0, 0, 0))
NotifyRoot.BackgroundTransparency = 1
NotifyRoot.ZIndex = 200
NotifyRoot.Name = "NotifyRoot"
do
	local nl = Instance.new("UIListLayout")
	nl.FillDirection = Enum.FillDirection.Vertical
	nl.SortOrder = Enum.SortOrder.LayoutOrder
	nl.Padding = UDim.new(0, 8)
	nl.Parent = NotifyRoot
end
local notifySeq = 0
-- them root duoi-phai + tham so vi tri "top"/"bottom"
local NotifyRootB = frame(ScreenGui, UDim2.fromOffset(272, 320),
	UDim2.new(1, -284, 1, -332), Color3.new(0, 0, 0))
NotifyRootB.BackgroundTransparency = 1
NotifyRootB.ZIndex = 200
NotifyRootB.Name = "NotifyRootB"
do
	local nl = Instance.new("UIListLayout")
	nl.FillDirection = Enum.FillDirection.Vertical
	nl.SortOrder = Enum.SortOrder.LayoutOrder
	nl.VerticalAlignment = Enum.VerticalAlignment.Bottom
	nl.Padding = UDim.new(0, 8)
	nl.Parent = NotifyRootB
end
local notifyLists = {[NotifyRoot] = {}, [NotifyRootB] = {}}
function _G.NEXUS_Notify(title, text, dur, where)
	dur = tonumber(dur) or 2
	notifySeq = notifySeq + 1
	local root = (where == "bottom") and NotifyRootB or NotifyRoot
	local lst = notifyLists[root]
	-- gioi han 4 notify, xoa cai cu nhat
	while #lst >= 4 do
		local oldest = table.remove(lst, 1)
		pcall(function() if oldest then oldest:Destroy() end end)
	end
	local n = frame(root, UDim2.fromOffset(260, 66), UDim2.new(), C.bg)
	n.LayoutOrder = (where == "bottom") and notifySeq or -notifySeq
	table.insert(lst, n)
	n.ZIndex = 201
	n.BackgroundTransparency = 1
	n.BorderSizePixel = 0
	n.ClipsDescendants = true
	-- hop noi dung truot tu phai sang trai
	local box = frame(n, UDim2.fromScale(1, 1), UDim2.new(1, 0, 0, 0), C.bg)
	box.ZIndex = 201
	corner(box, 8)
	pcall(function()
		TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{Position = UDim2.new(0, 0, 0, 0)}):Play()
	end)
	-- mieng va vuong 2 goc duoi (2 goc tren giu bo tron)
	local sqPatch = frame(box, UDim2.fromOffset(10, 10), UDim2.new(1, -10, 1, -10), C.bg)
	sqPatch.ZIndex = 201
	local sqPatchL = frame(box, UDim2.fromOffset(10, 10), UDim2.new(0, 0, 1, -10), C.bg)
	sqPatchL.ZIndex = 201
	local nt = label(box, tostring(title or "Thông báo"), 13, C.accent, nil, FONTBOLD)
	nt.Position = UDim2.fromOffset(12, 8)
	nt.Size = UDim2.new(1, -24, 0, 18)
	nt.ZIndex = 202
	local nm2 = label(box, tostring(text or ""), 11, Color3.new(1, 1, 1))
	nm2.Position = UDim2.fromOffset(12, 28)
	nm2.Size = UDim2.new(1, -24, 0, 26)
	nm2.TextWrapped = true
	nm2.TextYAlignment = Enum.TextYAlignment.Top
	nm2.ZIndex = 202
	-- thanh dem nguoc nam lot vao day notify: tran ca 2 vien duoi
	local barFill = frame(box, UDim2.new(1, 0, 0, 3), UDim2.new(0, 0, 1, -3), C.accent)
	barFill.ZIndex = 203
	do
		local ng = Instance.new("UIGradient")
		ng.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 110, 110)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 28, 28)),
		})
		ng.Parent = barFill
	end
	-- tieng bao
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://3398620867"
		s.Volume = 0.6
		s.Parent = n
		s:Play()
	end)
	task.spawn(function()
		pcall(function()
			local tw = TweenService:Create(barFill,
				TweenInfo.new(dur, Enum.EasingStyle.Linear),
				{Size = UDim2.new(0, 0, 0, 3)})
			tw:Play()
			tw.Completed:Wait()
		end)
		pcall(function()
			local out = TweenService:Create(box,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Position = UDim2.new(1, 0, 0, 0)})
			out:Play()
			out.Completed:Wait()
		end)
		pcall(function() n:Destroy() end)
		pcall(function()
			for i, f in ipairs(lst) do
				if f == n then table.remove(lst, i) break end
			end
		end)
	end)
end

print("[NEXUS] Loaded. Nhan INSERT / nut tron NX de tat-mo menu. Toggle da bam duoc.")

--========================== LOADSTRING API (giong ProxyLib) ==========================--
-- Cach xai sau khi up file nay len GitHub lay link Raw:
--   local NexusLib = loadstring(game:HttpGet("LINK_RAW_CUA_BAN"))()
--   local Lib = NexusLib.new()
--   Lib:Notify("Tieu de", "Noi dung", 2)
-- Luu y: file tu dung UI ngay khi load (giong cu), table tra ve chi de goi API.
local NexusLib = {}
NexusLib.__index = NexusLib
function NexusLib.new()
	return setmetatable({}, NexusLib)
end
function NexusLib:Notify(title, text, dur, where)
	return _G.NEXUS_Notify(title, text, dur, where)
end
function NexusLib:ToggleUI()
	if _G.NEXUS_ToggleUI then return _G.NEXUS_ToggleUI() end
end
function NexusLib:SetToggle(title, state)
	return _G.NEXUS_SetToggle(title, state)
end
function NexusLib:OnToggle(title, cb)
	return _G.NEXUS_OnToggle(title, cb)
end
function NexusLib:GetToggle(title)
	return _G.NEXUS_GetToggle(title)
end
function NexusLib:SetSlider(title, v)
	return _G.NEXUS_SetSlider(title, v)
end
function NexusLib:GetSlider(title)
	return _G.NEXUS_GetSlider(title)
end
function NexusLib:SetFont(normal, bold)
	return _G.NEXUS_SetFont(normal, bold)
end
NexusLib.Flags = _G.NEXUS_Flags
return NexusLib

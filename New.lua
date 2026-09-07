-- CustomMenu.lua RED PREMIUM x2 | menu tu lam, chu dao DO
-- Up de len New.lua -> link Raw giu nguyen:
-- local MyMenu = loadstring(game:HttpGet("LINK_RAW_CUA_BAN"))()
-- local Lib = MyMenu.new()

local MyMenu = {}
MyMenu.__index = MyMenu
function MyMenu.new() return setmetatable({}, MyMenu) end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- PALETTE DO PREMIUM
local RED = Color3.fromRGB(255, 45, 65)
local RED_DARK = Color3.fromRGB(170, 20, 35)
local RED_GLOW = Color3.fromRGB(255, 95, 110)
local RED_BG = Color3.fromRGB(42, 18, 24)
local BG = Color3.fromRGB(11, 11, 16)
local BG2 = Color3.fromRGB(17, 17, 24)
local CARD = Color3.fromRGB(21, 21, 30)
local CARD_HOVER = Color3.fromRGB(30, 23, 30)
local TEXT = Color3.fromRGB(245, 245, 250)
local DIM = Color3.fromRGB(155, 155, 172)
local OFF_TRACK = Color3.fromRGB(52, 52, 66)

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = o
    return c
end
local function stroke(o, color, tr)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(50, 50, 65)
    s.Transparency = tr or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o
    return s
end
local function tw(o, t, props, style)
    pcall(function()
        Tween:Create(o, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end)
end
local function getParent()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    return LocalPlayer:WaitForChild("PlayerGui")
end

function MyMenu:CreateWindow(opt)
    opt = opt or {}
    local title = opt.Title or "My Menu"
    local sub = opt.Subtitle or "RED PREMIUM v2.0"
    local key = opt.Keybind or Enum.KeyCode.RightShift
    local sz = opt.Size or Vector2.new(580, 410)

    local parent = getParent()
    pcall(function() if parent:FindFirstChild("MyMenu_UI") then parent.MyMenu_UI:Destroy() end end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "MyMenu_UI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent

    -- Bong do duoi menu
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(0, sz.X + 16, 0, sz.Y + 16)
    shadow.Position = UDim2.new(0.5, -sz.X / 2 - 8, 0.5, -sz.Y / 2 - 8)
    shadow.BackgroundColor3 = Color3.new(0, 0, 0)
    shadow.BackgroundTransparency = 0.55
    shadow.BorderSizePixel = 0
    shadow.Parent = gui
    corner(shadow, 16)

    -- Khung chinh + animation mo
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, sz.X, 0, sz.Y)
    main.Position = UDim2.new(0.5, -sz.X / 2, 0.5, -sz.Y / 2)
    main.BackgroundColor3 = BG
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = gui
    corner(main, 14)
    stroke(main, Color3.fromRGB(80, 28, 40), 0.3)
    local scale = Instance.new("UIScale")
    scale.Scale = 0.92
    scale.Parent = main
    tw(scale, 0.28, { Scale = 1 }, Enum.EasingStyle.Back)

    -- Dai sang do tren dinh
    local topGlow = Instance.new("Frame")
    topGlow.Size = UDim2.new(1, -40, 0, 3)
    topGlow.Position = UDim2.new(0, 20, 0, 0)
    topGlow.BackgroundColor3 = RED
    topGlow.BorderSizePixel = 0
    topGlow.Parent = main
    corner(topGlow, 99)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, RED_DARK),
        ColorSequenceKeypoint.new(0.5, RED_GLOW),
        ColorSequenceKeypoint.new(1, RED_DARK),
    })
    grad.Parent = topGlow

    -- Title bar
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 52)
    top.BackgroundColor3 = BG2
    top.BorderSizePixel = 0
    top.Parent = main
    corner(top, 14)
    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 14)
    topFix.Position = UDim2.new(0, 0, 1, -14)
    topFix.BackgroundColor3 = BG2
    topFix.BorderSizePixel = 0
    topFix.Parent = top

    -- Logo do co vien sang
    local logo = Instance.new("Frame")
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Position = UDim2.new(0, 12, 0, 11)
    logo.BackgroundColor3 = RED
    logo.BorderSizePixel = 0
    logo.Parent = top
    corner(logo, 9)
    local lg = Instance.new("UIGradient")
    lg.Rotation = 45
    lg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, RED_GLOW),
        ColorSequenceKeypoint.new(1, RED_DARK),
    })
    lg.Parent = logo
    local lt = Instance.new("TextLabel")
    lt.Size = UDim2.new(1, 0, 1, 0)
    lt.BackgroundTransparency = 1
    lt.Font = Enum.Font.GothamBlack
    lt.TextSize = 15
    lt.TextColor3 = Color3.new(1, 1, 1)
    lt.Text = "S"
    lt.Parent = logo

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -140, 0, 20)
    tl.Position = UDim2.new(0, 50, 0, 7)
    tl.BackgroundTransparency = 1
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 15
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.TextColor3 = TEXT
    tl.TextTruncate = Enum.TextTruncate.AtEnd
    tl.Text = title
    tl.Parent = top

    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(1, -140, 0, 13)
    sl.Position = UDim2.new(0, 50, 0, 28)
    sl.BackgroundTransparency = 1
    sl.Font = Enum.Font.Gotham
    sl.TextSize = 11
    sl.TextXAlignment = Enum.TextXAlignment.Left
    sl.TextColor3 = DIM
    sl.TextTruncate = Enum.TextTruncate.AtEnd
    sl.Text = sub
    sl.Parent = top

    -- Badge PREMIUM
    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 62, 0, 18)
    badge.Position = UDim2.new(1, -128, 0, 8)
    badge.BackgroundColor3 = RED
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 9
    badge.TextColor3 = Color3.new(1, 1, 1)
    badge.Text = "PREMIUM"
    badge.Parent = top
    corner(badge, 99)

    -- Nut - va X
    local minB = Instance.new("TextButton")
    minB.Size = UDim2.new(0, 26, 0, 26)
    minB.Position = UDim2.new(1, -60, 0, 22)
    minB.BackgroundColor3 = CARD
    minB.Font = Enum.Font.GothamBold
    minB.TextSize = 14
    minB.TextColor3 = DIM
    minB.Text = "-"
    minB.AutoButtonColor = false
    minB.Parent = top
    corner(minB, 8)
    local closeB = Instance.new("TextButton")
    closeB.Size = UDim2.new(0, 26, 0, 26)
    closeB.Position = UDim2.new(1, -30, 0, 22)
    closeB.BackgroundColor3 = Color3.fromRGB(60, 18, 26)
    closeB.Font = Enum.Font.GothamBold
    closeB.TextSize = 12
    closeB.TextColor3 = RED_GLOW
    closeB.Text = "X"
    closeB.AutoButtonColor = false
    closeB.Parent = top
    corner(closeB, 8)

    local redLine = Instance.new("Frame")
    redLine.Size = UDim2.new(1, -24, 0, 1)
    redLine.Position = UDim2.new(0, 12, 1, -1)
    redLine.BackgroundColor3 = RED
    redLine.BackgroundTransparency = 0.55
    redLine.BorderSizePixel = 0
    redLine.Parent = top

    -- Sidebar
    local side = Instance.new("Frame")
    side.Size = UDim2.new(0, 146, 1, -52)
    side.Position = UDim2.new(0, 0, 0, 52)
    side.BackgroundColor3 = BG2
    side.BorderSizePixel = 0
    side.Parent = main
    corner(side, 14)
    local sFix1 = Instance.new("Frame")
    sFix1.Size = UDim2.new(1, 0, 0, 14)
    sFix1.BackgroundColor3 = BG2
    sFix1.BorderSizePixel = 0
    sFix1.Parent = side
    local sFix2 = Instance.new("Frame")
    sFix2.Size = UDim2.new(0, 14, 1, 0)
    sFix2.Position = UDim2.new(1, -14, 0, 0)
    sFix2.BackgroundColor3 = BG2
    sFix2.BorderSizePixel = 0
    sFix2.Parent = side

    local navLbl = Instance.new("TextLabel")
    navLbl.Size = UDim2.new(1, -20, 0, 14)
    navLbl.Position = UDim2.new(0, 12, 0, 10)
    navLbl.BackgroundTransparency = 1
    navLbl.Font = Enum.Font.GothamBold
    navLbl.TextSize = 9
    navLbl.TextXAlignment = Enum.TextXAlignment.Left
    navLbl.TextColor3 = Color3.fromRGB(110, 110, 130)
    navLbl.Text = "N A V I G A T I O N"
    navLbl.Parent = side

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, -146, 1, -52)
    body.Position = UDim2.new(0, 146, 0, 52)
    body.BackgroundTransparency = 1
    body.Parent = main

    -- Footer trang thai
    local foot = Instance.new("TextLabel")
    foot.Size = UDim2.new(1, -16, 0, 14)
    foot.Position = UDim2.new(0, 8, 1, -20)
    foot.BackgroundTransparency = 1
    foot.Font = Enum.Font.Gotham
    foot.TextSize = 9
    foot.TextXAlignment = Enum.TextXAlignment.Left
    foot.TextColor3 = Color3.fromRGB(100, 100, 120)
    foot.Text = "●  Connected  •  RightShift: show/hide"
    foot.Parent = side

    do
        local dr, dst, sp = false, nil, nil
        top.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dr = true dst = i.Position sp = main.Position
                local sp2 = shadow.Position
                local con
                con = UIS.InputChanged:Connect(function(j)
                    if dr and (j.UserInputType == Enum.UserInputType.MouseMovement or j.UserInputType == Enum.UserInputType.Touch) then
                        local d = j.Position - dst
                        main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
                        shadow.Position = UDim2.new(sp2.X.Scale, sp2.X.Offset + d.X, sp2.Y.Scale, sp2.Y.Offset + d.Y)
                    end
                end)
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then dr = false if con then con:Disconnect() end end
                end)
            end
        end)
    end

    local Win = { _side = side, _body = body, _tabs = {}, _open = true, _min = false }
    local function setOpen(v)
        Win._open = v
        main.Visible = v
        shadow.Visible = v
    end
    closeB.MouseButton1Click:Connect(function() setOpen(false) end)
    minB.MouseButton1Click:Connect(function()
        Win._min = not Win._min
        body.Visible = not Win._min
        side.Visible = not Win._min
        if Win._min then
            main.Size = UDim2.new(0, sz.X, 0, 52)
            shadow.Size = UDim2.new(0, sz.X + 16, 0, 68)
        else
            main.Size = UDim2.new(0, sz.X, 0, sz.Y)
            shadow.Size = UDim2.new(0, sz.X + 16, 0, sz.Y + 16)
        end
    end)
    closeB.MouseEnter:Connect(function() tw(closeB, 0.15, { BackgroundColor3 = RED }) tw(closeB, 0.15, { TextColor3 = Color3.new(1, 1, 1) }) end)
    closeB.MouseLeave:Connect(function() tw(closeB, 0.15, { BackgroundColor3 = Color3.fromRGB(60, 18, 26) }) tw(closeB, 0.15, { TextColor3 = RED_GLOW }) end)
    UIS.InputBegan:Connect(function(i, gp)
        if not gp and i.KeyCode == key then setOpen(not Win._open) end
    end)

    function Win:CreateTab(o)
        o = o or {}
        local name = o.Title or "Main"
        local idx = #Win._tabs

        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -16, 0, 36)
        b.Position = UDim2.new(0, 8, 0, 30 + idx * 42)
        b.BackgroundColor3 = CARD
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.TextColor3 = DIM
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Text = "    " .. name
        b.AutoButtonColor = false
        b.Parent = side
        corner(b, 10)
        local bst = stroke(b, Color3.fromRGB(45, 45, 60), 0.6)

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 3, 0, 20)
        bar.Position = UDim2.new(0, 7, 0.5, -10)
        bar.BackgroundColor3 = RED
        bar.BorderSizePixel = 0
        bar.Visible = false
        bar.Parent = b
        corner(bar, 99)

        local page = Instance.new("Frame")
        page.Size = UDim2.new(1, -16, 1, -16)
        page.Position = UDim2.new(0, 8, 0, 8)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = body

        local left = Instance.new("ScrollingFrame")
        left.Size = UDim2.new(0.5, -4, 1, 0)
        left.BackgroundTransparency = 1
        left.ScrollBarThickness = 3
        left.ScrollBarImageColor3 = RED
        left.CanvasSize = UDim2.new(0, 0, 0, 0)
        left.AutomaticCanvasSize = Enum.AutomaticSize.Y
        left.Parent = page
        local ll = Instance.new("UIListLayout")
        ll.Padding = UDim.new(0, 8)
        ll.Parent = left

        local right = Instance.new("ScrollingFrame")
        right.Size = UDim2.new(0.5, -4, 1, 0)
        right.Position = UDim2.new(0.5, 4, 0, 0)
        right.BackgroundTransparency = 1
        right.ScrollBarThickness = 3
        right.ScrollBarImageColor3 = RED
        right.CanvasSize = UDim2.new(0, 0, 0, 0)
        right.AutomaticCanvasSize = Enum.AutomaticSize.Y
        right.Parent = page
        local rl = Instance.new("UIListLayout")
        rl.Padding = UDim.new(0, 8)
        rl.Parent = right

        local function sel()
            for _, t in ipairs(Win._tabs) do
                t.Page.Visible = false
                tw(t.Btn, 0.15, { BackgroundColor3 = CARD })
                t.Btn.TextColor3 = DIM
                t.Bar.Visible = false
                t.Stroke.Color = Color3.fromRGB(45, 45, 60)
            end
            page.Visible = true
            tw(b, 0.15, { BackgroundColor3 = RED_BG })
            b.TextColor3 = TEXT
            bar.Visible = true
            bst.Color = RED
            page.BackgroundTransparency = 1
        end
        b.MouseEnter:Connect(function()
            if page.Visible == false then tw(b, 0.12, { BackgroundColor3 = CARD_HOVER }) end
        end)
        b.MouseLeave:Connect(function()
            if page.Visible == false then tw(b, 0.12, { BackgroundColor3 = CARD }) end
        end)
        b.MouseButton1Click:Connect(sel)
        table.insert(Win._tabs, { Btn = b, Page = page, Bar = bar, Stroke = bst })
        if #Win._tabs == 1 then sel() end

        local Tab = {}
        local function col(s) if s == 2 then return right else return left end end

        function Tab:CreateSection(o2)
            o2 = o2 or {}
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 28)
            f.BackgroundTransparency = 1
            f.Parent = col(o2.Side or 1)
            local pill = Instance.new("Frame")
            pill.Size = UDim2.new(0, 4, 0, 14)
            pill.Position = UDim2.new(0, 2, 0, 2)
            pill.BackgroundColor3 = RED
            pill.BorderSizePixel = 0
            pill.Parent = f
            corner(pill, 99)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -12, 0, 18)
            l.Position = UDim2.new(0, 12, 0, 0)
            l.BackgroundTransparency = 1
            l.Font = Enum.Font.GothamBlack
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextColor3 = TEXT
            l.Text = string.upper(o2.Text or "SECTION")
            l.Parent = f
            local gray = Instance.new("Frame")
            gray.Size = UDim2.new(1, -4, 0, 1)
            gray.Position = UDim2.new(0, 2, 0, 22)
            gray.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            gray.BorderSizePixel = 0
            gray.BackgroundTransparency = 0.3
            gray.Parent = f
            local red = Instance.new("Frame")
            red.Size = UDim2.new(0, 46, 0, 2)
            red.Position = UDim2.new(0, 2, 0, 21.5)
            red.BackgroundColor3 = RED
            red.BorderSizePixel = 0
            red.Parent = f
            corner(red, 99)
            return f
        end

        function Tab:CreateToggle(o2)
            o2 = o2 or {}
            local ti = o2.Title or "Toggle"
            local desc = o2.Desc or o2.Description or ""
            local st = o2.Default or false
            local cb = o2.Callback or function() end

            local f = Instance.new("TextButton")
            f.Size = UDim2.new(1, 0, 0, desc ~= "" and 52 or 46)
            f.BackgroundColor3 = CARD
            f.BorderSizePixel = 0
            f.Text = ""
            f.AutoButtonColor = false
            f.Parent = col(o2.Side or 1)
            corner(f, 11)
            local st1 = stroke(f, Color3.fromRGB(50, 50, 65), 0.5)
            local g = Instance.new("UIGradient")
            g.Rotation = 90
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 190)),
            })
            g.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.96),
                NumberSequenceKeypoint.new(1, 1),
            })
            g.Parent = f

            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -60, 0, 18)
            l.Position = UDim2.new(0, 12, 0, desc ~= "" and 6 or 8)
            l.BackgroundTransparency = 1
            l.Font = Enum.Font.GothamBold
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextColor3 = TEXT
            l.TextTruncate = Enum.TextTruncate.AtEnd
            l.Text = ti
            l.Parent = f

            local d
            if desc ~= "" then
                d = Instance.new("TextLabel")
                d.Size = UDim2.new(1, -60, 0, 13)
                d.Position = UDim2.new(0, 12, 0, 25)
                d.BackgroundTransparency = 1
                d.Font = Enum.Font.Gotham
                d.TextSize = 10
                d.TextXAlignment = Enum.TextXAlignment.Left
                d.TextColor3 = DIM
                d.TextTruncate = Enum.TextTruncate.AtEnd
                d.Text = desc
                d.Parent = f
            end

            -- Den trang thai nho
            local stDot = Instance.new("Frame")
            stDot.Size = UDim2.new(0, 6, 0, 6)
            stDot.Position = UDim2.new(0, 12, 1, -11)
            stDot.BorderSizePixel = 0
            stDot.Parent = f
            corner(stDot, 99)

            local sw = Instance.new("Frame")
            sw.Size = UDim2.new(0, 44, 0, 24)
            sw.AnchorPoint = Vector2.new(1, 0.5)
            sw.Position = UDim2.new(1, -10, 0.5, 0)
            sw.BorderSizePixel = 0
            sw.Parent = f
            corner(sw, 99)

            local dot2 = Instance.new("Frame")
            dot2.Size = UDim2.new(0, 18, 0, 18)
            dot2.BorderSizePixel = 0
            dot2.Parent = sw
            corner(dot2, 99)
            local dStroke = Instance.new("UIStroke")
            dStroke.Color = Color3.new(1, 1, 1)
            dStroke.Transparency = 0.85
            dStroke.Parent = dot2

            local function rf(anim)
                local t = anim == false and 0 or 0.18
                if st then
                    tw(sw, t, { BackgroundColor3 = RED })
                    tw(dot2, t, { Position = UDim2.new(1, -21, 0.5, -9) })
                    dot2.BackgroundColor3 = Color3.new(1, 1, 1)
                    tw(st1, t, { Color = RED })
                    st1.Transparency = 0.3
                    stDot.BackgroundColor3 = RED
                    l.TextColor3 = TEXT
                else
                    tw(sw, t, { BackgroundColor3 = OFF_TRACK })
                    tw(dot2, t, { Position = UDim2.new(0, 3, 0.5, -9) })
                    dot2.BackgroundColor3 = Color3.fromRGB(165, 165, 180)
                    tw(st1, t, { Color = Color3.fromRGB(50, 50, 65) })
                    l.TextColor3 = Color3.fromRGB(220, 220, 230)
                    stDot.BackgroundColor3 = OFF_TRACK
                end
            end
            -- dat vi tri dau (khong anim)
            if st then
                sw.BackgroundColor3 = RED
                dot2.Position = UDim2.new(1, -21, 0.5, -9)
                dot2.BackgroundColor3 = Color3.new(1, 1, 1)
            else
                sw.BackgroundColor3 = OFF_TRACK
                dot2.Position = UDim2.new(0, 3, 0.5, -9)
                dot2.BackgroundColor3 = Color3.fromRGB(165, 165, 180)
            end
            rf(false)
            f.MouseEnter:Connect(function() tw(st1, 0.12, { Transparency = 0.2 }) end)
            f.MouseLeave:Connect(function() tw(st1, 0.12, { Transparency = st and 0.3 or 0.5 }) end)
            f.MouseButton1Click:Connect(function()
                st = not st rf(true) pcall(cb, st)
            end)
            local api = {}
            function api:Set(v) st = (v == true) rf(true) pcall(cb, st) end
            function api:Get() return st end
            task.defer(function() pcall(cb, st) end)
            return api
        end

        return Tab
    end

    return Win
end

return MyMenu

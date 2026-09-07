-- CustomMenu.lua RED EDITION | menu tu lam, chu dao DO
-- Up file nay de len New.lua tren GitHub -> lay link Raw:
-- local MyMenu = loadstring(game:HttpGet("LINK_RAW_CUA_BAN"))()
-- local Lib = MyMenu.new()

local MyMenu = {}
MyMenu.__index = MyMenu
function MyMenu.new() return setmetatable({}, MyMenu) end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- CHU DAO DO
local RED = Color3.fromRGB(255, 45, 65)
local RED_DARK = Color3.fromRGB(170, 20, 35)
local RED_GLOW = Color3.fromRGB(255, 80, 95)
local BG = Color3.fromRGB(12, 12, 17)
local BG2 = Color3.fromRGB(18, 18, 25)
local CARD = Color3.fromRGB(22, 22, 31)
local CARD_HOVER = Color3.fromRGB(30, 22, 28)
local TEXT = Color3.fromRGB(245, 245, 250)
local DIM = Color3.fromRGB(155, 155, 170)
local OFF_TRACK = Color3.fromRGB(55, 55, 68)

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = o
end
local function stroke(o, color, tr)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(50, 50, 65)
    s.Transparency = tr or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o
    return s
end
local function getParent()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    return LocalPlayer:WaitForChild("PlayerGui")
end

function MyMenu:CreateWindow(opt)
    opt = opt or {}
    local title = opt.Title or "My Menu"
    local sub = opt.Subtitle or "RED EDITION v1.0"
    local key = opt.Keybind or Enum.KeyCode.RightShift
    local sz = opt.Size or Vector2.new(560, 400)

    local parent = getParent()
    pcall(function() if parent:FindFirstChild("MyMenu_UI") then parent.MyMenu_UI:Destroy() end end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "MyMenu_UI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent

    -- Khung chinh
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, sz.X, 0, sz.Y)
    main.Position = UDim2.new(0.5, -sz.X / 2, 0.5, -sz.Y / 2)
    main.BackgroundColor3 = BG
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = gui
    corner(main, 12)
    stroke(main, Color3.fromRGB(70, 25, 35), 0.35)

    -- Vien do phat sang tren dinh
    local topGlow = Instance.new("Frame")
    topGlow.Size = UDim2.new(1, -24, 0, 2)
    topGlow.Position = UDim2.new(0, 12, 0, 0)
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
    top.Size = UDim2.new(1, 0, 0, 48)
    top.BackgroundColor3 = BG2
    top.BorderSizePixel = 0
    top.Parent = main
    corner(top, 12)
    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 12)
    topFix.Position = UDim2.new(0, 0, 1, -12)
    topFix.BackgroundColor3 = BG2
    topFix.BorderSizePixel = 0
    topFix.Parent = top

    -- Cham do + tieu de
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 14, 0, 19)
    dot.BackgroundColor3 = RED
    dot.BorderSizePixel = 0
    dot.Parent = top
    corner(dot, 99)

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -60, 0, 20)
    tl.Position = UDim2.new(0, 30, 0, 6)
    tl.BackgroundTransparency = 1
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 15
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.TextColor3 = TEXT
    tl.Text = title
    tl.Parent = top

    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(1, -60, 0, 13)
    sl.Position = UDim2.new(0, 30, 0, 27)
    sl.BackgroundTransparency = 1
    sl.Font = Enum.Font.Gotham
    sl.TextSize = 11
    sl.TextXAlignment = Enum.TextXAlignment.Left
    sl.TextColor3 = DIM
    sl.Text = sub
    sl.Parent = top

    -- Gach do duoi title
    local redLine = Instance.new("Frame")
    redLine.Size = UDim2.new(1, 0, 0, 1)
    redLine.Position = UDim2.new(0, 0, 1, 0)
    redLine.BackgroundColor3 = RED
    redLine.BackgroundTransparency = 0.4
    redLine.BorderSizePixel = 0
    redLine.Parent = top

    -- Sidebar
    local side = Instance.new("Frame")
    side.Size = UDim2.new(0, 138, 1, -48)
    side.Position = UDim2.new(0, 0, 0, 48)
    side.BackgroundColor3 = BG2
    side.BorderSizePixel = 0
    side.Parent = main
    corner(side, 12)
    local sFix1 = Instance.new("Frame")
    sFix1.Size = UDim2.new(1, 0, 0, 12)
    sFix1.BackgroundColor3 = BG2
    sFix1.BorderSizePixel = 0
    sFix1.Parent = side
    local sFix2 = Instance.new("Frame")
    sFix2.Size = UDim2.new(0, 12, 1, 0)
    sFix2.Position = UDim2.new(1, -12, 0, 0)
    sFix2.BackgroundColor3 = BG2
    sFix2.BorderSizePixel = 0
    sFix2.Parent = side

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, -138, 1, -48)
    body.Position = UDim2.new(0, 138, 0, 48)
    body.BackgroundTransparency = 1
    body.Parent = main

    -- Keo tha
    do
        local dr, dst, sp = false, nil, nil
        top.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dr = true dst = i.Position sp = main.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dst
                main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dr = false end
        end)
    end

    local Win = { _side = side, _body = body, _tabs = {}, _open = true }
    local function setOpen(v) Win._open = v main.Visible = v end
    UIS.InputBegan:Connect(function(i, gp)
        if not gp and i.KeyCode == key then setOpen(not Win._open) end
    end)

    function Win:CreateTab(o)
        o = o or {}
        local name = o.Title or "Main"
        local idx = #Win._tabs

        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -16, 0, 34)
        b.Position = UDim2.new(0, 8, 0, 10 + idx * 40)
        b.BackgroundColor3 = CARD
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.TextColor3 = DIM
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Text = "   " .. name
        b.AutoButtonColor = false
        b.Parent = side
        corner(b, 8)
        stroke(b, Color3.fromRGB(45, 45, 60), 0.6)

        -- Thanh do ben trai nut tab khi select
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 3, 0, 18)
        bar.Position = UDim2.new(0, 6, 0.5, -9)
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
                t.Btn.BackgroundColor3 = CARD
                t.Btn.TextColor3 = DIM
                t.Bar.Visible = false
                stroke(t.Btn, Color3.fromRGB(45, 45, 60), 0.6)
            end
            page.Visible = true
            b.BackgroundColor3 = Color3.fromRGB(42, 18, 24)
            b.TextColor3 = TEXT
            bar.Visible = true
            stroke(b, RED, 0.35)
        end
        b.MouseEnter:Connect(function()
            if page.Visible == false then b.BackgroundColor3 = CARD_HOVER end
        end)
        b.MouseLeave:Connect(function()
            if page.Visible == false then b.BackgroundColor3 = CARD end
        end)
        b.MouseButton1Click:Connect(sel)
        table.insert(Win._tabs, { Btn = b, Page = page, Bar = bar })
        if #Win._tabs == 1 then sel() end

        local Tab = {}
        local function col(s) if s == 2 then return right else return left end end

        -- SECTION do + chu trang
        function Tab:CreateSection(o2)
            o2 = o2 or {}
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 26)
            f.BackgroundTransparency = 1
            f.Parent = col(o2.Side or 1)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 0, 16)
            l.BackgroundTransparency = 1
            l.Font = Enum.Font.GothamBold
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextColor3 = TEXT
            l.Text = "  " .. string.upper(o2.Text or "SECTION")
            l.Parent = f
            local red = Instance.new("Frame")
            red.Size = UDim2.new(0, 34, 0, 2)
            red.Position = UDim2.new(0, 2, 0, 18)
            red.BackgroundColor3 = RED
            red.BorderSizePixel = 0
            red.Parent = f
            corner(red, 99)
            local gray = Instance.new("Frame")
            gray.Size = UDim2.new(1, -40, 0, 1)
            gray.Position = UDim2.new(0, 38, 0, 18)
            gray.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            gray.BorderSizePixel = 0
            gray.Parent = f
            return f
        end

        -- TOGGLE nen den, bat = DO
        function Tab:CreateToggle(o2)
            o2 = o2 or {}
            local ti = o2.Title or "Toggle"
            local st = o2.Default or false
            local cb = o2.Callback or function() end

            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 44)
            f.BackgroundColor3 = CARD
            f.BorderSizePixel = 0
            f.Parent = col(o2.Side or 1)
            corner(f, 9)
            local st1 = stroke(f, Color3.fromRGB(50, 50, 65), 0.5)

            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 11)
            pad.PaddingRight = UDim.new(0, 10)
            pad.Parent = f

            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -54, 1, 0)
            l.BackgroundTransparency = 1
            l.Font = Enum.Font.GothamBold
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextColor3 = TEXT
            l.TextTruncate = Enum.TextTruncate.AtEnd
            l.Text = ti
            l.Parent = f

            local sw = Instance.new("TextButton")
            sw.Size = UDim2.new(0, 42, 0, 23)
            sw.AnchorPoint = Vector2.new(1, 0.5)
            sw.Position = UDim2.new(1, 0, 0.5, 0)
            sw.Text = ""
            sw.AutoButtonColor = false
            sw.Parent = f
            corner(sw, 99)

            local dot2 = Instance.new("Frame")
            dot2.Size = UDim2.new(0, 17, 0, 17)
            dot2.Position = UDim2.new(0, 3, 0.5, -8.5)
            dot2.BorderSizePixel = 0
            dot2.Parent = sw
            corner(dot2, 99)

            local function rf()
                if st then
                    sw.BackgroundColor3 = RED
                    dot2.Position = UDim2.new(1, -20, 0.5, -8.5)
                    dot2.BackgroundColor3 = Color3.new(1, 1, 1)
                    st1.Color = RED
                    st1.Transparency = 0.35
                else
                    sw.BackgroundColor3 = OFF_TRACK
                    dot2.Position = UDim2.new(0, 3, 0.5, -8.5)
                    dot2.BackgroundColor3 = Color3.fromRGB(160, 160, 175)
                    st1.Color = Color3.fromRGB(50, 50, 65)
                    st1.Transparency = 0.5
                end
            end
            rf()
            local function toggle()
                st = not st rf() pcall(cb, st)
            end
            sw.MouseButton1Click:Connect(toggle)
            -- bam ca khung cung toggle cho de
            f.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then toggle() end
            end)
            local api = {}
            function api:Set(v) st = (v == true) rf() pcall(cb, st) end
            function api:Get() return st end
            task.defer(function() pcall(cb, st) end)
            return api
        end

        return Tab
    end

    return Win
end

return MyMenu

--[[ ProxyMenu_New.lua | Menu moi gon nhe, ready lam link raw
Up file nay len GitHub -> lay link Raw -> xai:
local ProxyLib = loadstring(game:HttpGet("LINK_RAW_CUA_BAN"))()
local Lib = ProxyLib.new()
]]
local ProxyLib = {}
ProxyLib.__index = ProxyLib
function ProxyLib.new() return setmetatable({}, ProxyLib) end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local ACCENT = Color3.fromRGB(124,92,255)
local BG = Color3.fromRGB(16,16,22)
local BG2 = Color3.fromRGB(22,22,30)
local CARD = Color3.fromRGB(26,26,36)
local TEXT = Color3.fromRGB(235,235,245)
local DIM = Color3.fromRGB(150,150,170)

local function corner(o,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=o return c end
local function stroke(o) local s=Instance.new("UIStroke") s.Color=Color3.fromRGB(45,45,60) s.Transparency=0.4 s.Parent=o return s end
local function getParent()
    local ok,h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    return LocalPlayer:WaitForChild("PlayerGui")
end

function ProxyLib:CreateWindow(opt)
    opt = opt or {}
    local title = opt.Title or "Menu Moi"
    local sub = opt.Subtitle or "v1.0"
    local key = opt.Keybind or Enum.KeyCode.RightShift
    local sz = opt.Size or Vector2.new(520,380)
    local parent = getParent()
    pcall(function() if parent:FindFirstChild("ProxyNew_UI") then parent.ProxyNew_UI:Destroy() end end)
    local gui = Instance.new("ScreenGui") gui.Name="ProxyNew_UI" gui.ResetOnSpawn=false gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=parent
    local main = Instance.new("Frame") main.Size=UDim2.new(0,sz.X,0,sz.Y) main.Position=UDim2.new(0.5,-sz.X/2,0.5,-sz.Y/2)
    main.BackgroundColor3=BG main.BorderSizePixel=0 main.Active=true main.Parent=gui corner(main,12) stroke(main)
    local top = Instance.new("Frame") top.Size=UDim2.new(1,0,0,44) top.BackgroundColor3=BG2 top.BorderSizePixel=0 top.Parent=main corner(top,12)
    local fix = Instance.new("Frame") fix.Size=UDim2.new(1,0,0,12) fix.Position=UDim2.new(0,0,1,-12) fix.BackgroundColor3=BG2 fix.BorderSizePixel=0 fix.Parent=top
    local tl = Instance.new("TextLabel") tl.Size=UDim2.new(1,-20,0,20) tl.Position=UDim2.new(0,14,0,5) tl.BackgroundTransparency=1
    tl.Font=Enum.Font.GothamBold tl.TextSize=14 tl.TextXAlignment=Enum.TextXAlignment.Left tl.TextColor3=TEXT tl.Text=title tl.Parent=top
    local sl = Instance.new("TextLabel") sl.Size=UDim2.new(1,-20,0,14) sl.Position=UDim2.new(0,14,0,25) sl.BackgroundTransparency=1
    sl.Font=Enum.Font.Gotham sl.TextSize=11 tl.TextXAlignment=Enum.TextXAlignment.Left sl.TextColor3=DIM sl.Text=sub sl.Parent=top
    local side = Instance.new("Frame") side.Size=UDim2.new(0,140,1,-44) side.Position=UDim2.new(0,0,0,44) side.BackgroundColor3=BG2 side.BorderSizePixel=0 side.Parent=main corner(side,12)
    local body = Instance.new("Frame") body.Size=UDim2.new(1,-140,1,-44) body.Position=UDim2.new(0,140,0,44) body.BackgroundTransparency=1 body.Parent=main
    -- drag
    do local dr,dst,sp=false,nil,nil
        top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true dst=i.Position sp=main.Position end end)
        UIS.InputChanged:Connect(function(i) if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-dst main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end)
    end
    local Win = {_gui=gui,_main=main,_side=side,_body=body,_tabs={},_open=true}
    local function setOpen(v) Win._open=v main.Visible=v end
    UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==key then setOpen(not Win._open) end end)

    function Win:CreateTab(o)
        o=o or{} local name=o.Title or "Main"
        local b=Instance.new("TextButton") b.Size=UDim2.new(1,-20,0,32) b.Position=UDim2.new(0,10,0,10+#Win._tabs*38)
        b.BackgroundColor3=CARD b.Font=Enum.Font.GothamBold b.TextSize=12 b.TextColor3=DIM b.Text=name b.Parent=side corner(b,8)
        local page=Instance.new("ScrollingFrame") page.Size=UDim2.new(1,-16,1,-16) page.Position=UDim2.new(0,8,0,8)
        page.BackgroundTransparency=1 page.ScrollBarThickness=3 page.ScrollBarImageColor3=ACCENT page.CanvasSize=UDim2.new(0,0,0,0) page.AutomaticCanvasSize=Enum.AutomaticSize.Y page.Visible=false page.Parent=body
        local lay=Instance.new("UIListLayout") lay.Padding=UDim.new(0,8) lay.Parent=page
        -- 2 cot Side 1/2
        local left=Instance.new("Frame") left.Size=UDim2.new(0.5,-4,0,0) left.BackgroundTransparency=1 left.AutomaticSize=Enum.AutomaticSize.Y left.Parent=page
        local lL=Instance.new("UIListLayout") lL.Padding=UDim.new(0,8) lL.Parent=left
        local right=Instance.new("Frame") right.Size=UDim2.new(0.5,-4,0,0) right.BackgroundTransparency=1 right.AutomaticSize=Enum.AutomaticSize.Y right.Parent=page
        local rL=Instance.new("UIListLayout") rL.Padding=UDim.new(0,8) rL.Parent=right
        -- xep 2 cot ngang: dung UIList thi doc, nen dat left/right vao 1 frame ngang
        -- don gian: page chua 1 Frame ngang
        -- de giu gon, ta де 2 frame nay nam ngang bang cach doi page thanh Frame ngang + scroll tong
        local function col(s) if s==2 then return right else return left end end
        local function sel()
            for _,t in ipairs(Win._tabs) do t.Page.Visible=false t.Btn.BackgroundColor3=CARD t.Btn.TextColor3=DIM end
            page.Visible=true b.BackgroundColor3=Color3.fromRGB(34,30,55) b.TextColor3=TEXT
        end
        b.MouseButton1Click:Connect(sel)
        table.insert(Win._tabs,{Btn=b,Page=page})
        if #Win._tabs==1 then sel() end
        local Tab={}
        function Tab:CreateSection(o2) o2=o2 or{}
            local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,24) f.BackgroundTransparency=1 f.Parent=col(o2.Side or 1)
            local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Font=Enum.Font.GothamBold l.TextSize=12 l.TextXAlignment=Enum.TextXAlignment.Left l.TextColor3=TEXT l.Text=string.upper(o2.Text or "SECTION") l.Parent=f
            return f
        end
        function Tab:CreateToggle(o2)
            o2=o2 or{} local ti=o2.Title or "Toggle" local st=o2.Default or false local cb=o2.Callback or function() end
            local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,42) f.BackgroundColor3=CARD f.BorderSizePixel=0 f.Parent=col(o2.Side or 1) corner(f,8) stroke(f)
            local p=Instance.new("UIPadding") p.PaddingLeft=UDim.new(0,10) p.PaddingRight=UDim.new(0,10) p.Parent=f
            local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-52,1,0) l.BackgroundTransparency=1 l.Font=Enum.Font.GothamBold l.TextSize=12 l.TextXAlignment=Enum.TextXAlignment.Left l.TextColor3=TEXT l.TextTruncate=Enum.TextTruncate.AtEnd l.Text=ti l.Parent=f
            local sw=Instance.new("TextButton") sw.Size=UDim2.new(0,40,0,22) sw.AnchorPoint=Vector2.new(1,0.5) sw.Position=UDim2.new(1,0,0.5,0) sw.Text="" sw.Parent=f corner(sw,99)
            local dot=Instance.new("Frame") dot.Size=UDim2.new(0,16,0,16) dot.Position=UDim2.new(0,3,0.5,-8) dot.BackgroundColor3=Color3.fromRGB(120,120,140) dot.BorderSizePixel=0 dot.Parent=sw corner(dot,99)
            local function rf() if st then sw.BackgroundColor3=ACCENT dot.Position=UDim2.new(1,-19,0.5,-8) dot.BackgroundColor3=Color3.new(1,1,1) else sw.BackgroundColor3=Color3.fromRGB(45,45,60) dot.Position=UDim2.new(0,3,0.5,-8) dot.BackgroundColor3=Color3.fromRGB(120,120,140) end end
            rf() sw.MouseButton1Click:Connect(function() st=not st rf() pcall(cb,st) end)
            local api={} function api:Set(v) st=(v==true) rf() pcall(cb,st) end function api:Get() return st end
            task.defer(function() pcall(cb,st) end)
            return api
        end
        return Tab
    end
    return Win
end
return ProxyLib

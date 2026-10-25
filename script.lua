local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
	local success, res = pcall(function()
		return gethui and gethui() or CoreGui
	end)
	if success and res then return res end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local parentGui = getGuiParent()
if parentGui:FindFirstChild("DawnExactMenu") then
	parentGui.DawnExactMenu:Destroy()
end
if Lighting:FindFirstChild("DawnMenuBlur") then
	Lighting.DawnMenuBlur:Destroy()
end

local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "DawnMenuBlur"
blurEffect.Size = 0
blurEffect.Parent = Lighting

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DawnExactMenu"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = parentGui

local normalTop = Color3.fromRGB(19, 21, 26)
local normalBottom = Color3.fromRGB(15, 17, 21)
local hoverTopLeft = Color3.fromRGB(62, 69, 88)
local hoverBottomRight = Color3.fromRGB(21, 24, 31)
local accentRed = Color3.fromRGB(224, 52, 68)
local tweenInfoHover = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local fadeTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local currentState = "Closed"

local function isPointInPoly(x, y, poly)
	local inside = false
	local j = #poly
	for i = 1, #poly do
		local xi, yi = poly[i][1], poly[i][2]
		local xj, yj = poly[j][1], poly[j][2]
		if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi + 0.00001) + xi) then
			inside = not inside
		end
		j = i
	end
	return inside
end

local fhasixPolygons = {
	{ {0.342, 0.345}, {0.895, 0.168}, {0.668, 0.348}, {0.378, 0.422}, {0.288, 0.535} },
	{ {0.352, 0.492}, {0.715, 0.432}, {0.576, 0.538}, {0.370, 0.590}, {0.418, 0.612}, {0.246, 0.818} }
}

local function drawFhasixLogo(parentFrame, baseZIndex, resolution)
	local res = resolution or 68
	for row = 0, res - 1 do
		local y = (row + 0.5) / res
		local startCol = nil
		for col = 0, res do
			local x = (col + 0.5) / res
			local filled = false
			if col < res then
				for _, poly in ipairs(fhasixPolygons) do
					if isPointInPoly(x, y, poly) then
						filled = true
						break
					end
				end
			end
			if filled and not startCol then
				startCol = col
			elseif not filled and startCol then
				local span = Instance.new("Frame")
				span.Size = UDim2.new((col - startCol) / res, 0, (1 / res) + 0.006, 0)
				span.Position = UDim2.new(startCol / res, 0, row / res, 0)
				span.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				span.BorderSizePixel = 0
				span.ZIndex = baseZIndex
				span.Parent = parentFrame
				startCol = nil
			end
		end
	end
end

local hudContainer = Instance.new("Frame")
hudContainer.Name = "LiveHUD"
hudContainer.Size = UDim2.new(1, 0, 1, 0)
hudContainer.BackgroundTransparency = 1
hudContainer.ZIndex = 6
hudContainer.Parent = screenGui

local fpsHudPill = Instance.new("Frame")
fpsHudPill.Size = UDim2.new(0, 86, 0, 28)
fpsHudPill.Position = UDim2.new(0, 16, 0, 58)
fpsHudPill.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
fpsHudPill.BackgroundTransparency = 0.2
fpsHudPill.Visible = false
fpsHudPill.Active = true
fpsHudPill.ZIndex = 6
fpsHudPill.Parent = hudContainer

local fpsHudCorner = Instance.new("UICorner")
fpsHudCorner.CornerRadius = UDim.new(0, 6)
fpsHudCorner.Parent = fpsHudPill

local fpsHudStroke = Instance.new("UIStroke")
fpsHudStroke.Color = Color3.fromRGB(255, 255, 255)
fpsHudStroke.Transparency = 0.88
fpsHudStroke.Thickness = 1
fpsHudStroke.Parent = fpsHudPill

local fpsHudText = Instance.new("TextLabel")
fpsHudText.Size = UDim2.new(1, 0, 1, 0)
fpsHudText.BackgroundTransparency = 1
fpsHudText.Text = "144 FPS"
fpsHudText.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsHudText.Font = Enum.Font.GothamBold
fpsHudText.TextSize = 11
fpsHudText.ZIndex = 7
fpsHudText.Parent = fpsHudPill

local cpsHudPill = Instance.new("Frame")
cpsHudPill.Size = UDim2.new(0, 86, 0, 28)
cpsHudPill.Position = UDim2.new(0, 110, 0, 58)
cpsHudPill.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
cpsHudPill.BackgroundTransparency = 0.2
cpsHudPill.Visible = false
cpsHudPill.Active = true
cpsHudPill.ZIndex = 6
cpsHudPill.Parent = hudContainer

local cpsHudCorner = Instance.new("UICorner")
cpsHudCorner.CornerRadius = UDim.new(0, 6)
cpsHudCorner.Parent = cpsHudPill

local cpsHudStroke = Instance.new("UIStroke")
cpsHudStroke.Color = Color3.fromRGB(255, 255, 255)
cpsHudStroke.Transparency = 0.88
cpsHudStroke.Thickness = 1
cpsHudStroke.Parent = cpsHudPill

local cpsHudText = Instance.new("TextLabel")
cpsHudText.Size = UDim2.new(1, 0, 1, 0)
cpsHudText.BackgroundTransparency = 1
cpsHudText.Text = "0 | 0 CPS"
cpsHudText.TextColor3 = Color3.fromRGB(255, 255, 255)
cpsHudText.Font = Enum.Font.GothamBold
cpsHudText.TextSize = 11
cpsHudText.ZIndex = 7
cpsHudText.Parent = cpsHudPill

local function makeDraggableInHub(hudFrame, strokeObj)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	hudFrame.InputBegan:Connect(function(input)
		if currentState == "Hub" and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = true
			dragStart = input.Position
			startPos = hudFrame.Position
			strokeObj.Transparency = 0.35

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					strokeObj.Transparency = (currentState == "Hub") and 0.65 or 0.88
				end
			end)
		end
	end)hudFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging and currentState == "Hub" then
			local delta = input.Position - dragStart
			hudFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

makeDraggableInHub(fpsHudPill, fpsHudStroke)
makeDraggableInHub(cpsHudPill, cpsHudStroke)

local topRightBtn = Instance.new("TextButton")
topRightBtn.Name = "TopRightToggle"
topRightBtn.Size = UDim2.new(0, 38, 0, 38)
topRightBtn.AnchorPoint = Vector2.new(1, 0)
topRightBtn.Position = UDim2.new(1, -12, 0, 60)
topRightBtn.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
topRightBtn.BackgroundTransparency = 0.12
topRightBtn.AutoButtonColor = false
topRightBtn.Text = ""
topRightBtn.Visible = true
topRightBtn.ZIndex = 500
topRightBtn.Parent = screenGui

local trCorner = Instance.new("UICorner")
trCorner.CornerRadius = UDim.new(0, 9)
trCorner.Parent = topRightBtn

local trStroke = Instance.new("UIStroke")
trStroke.Color = Color3.fromRGB(255, 255, 255)
trStroke.Transparency = 0.85
trStroke.Thickness = 1.2
trStroke.Parent = topRightBtn

local miniLogo = Instance.new("Frame")
miniLogo.Size = UDim2.new(0, 28, 0, 28)
miniLogo.AnchorPoint = Vector2.new(0.5, 0.5)
miniLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
miniLogo.BackgroundTransparency = 1
miniLogo.ZIndex = 501
miniLogo.Parent = topRightBtn

drawFhasixLogo(miniLogo, 502, 42)

local darkFadeOverlay = Instance.new("Frame")
darkFadeOverlay.Name = "DarkBackgroundFade"
darkFadeOverlay.Size = UDim2.new(1, 0, 1, 0)
darkFadeOverlay.BackgroundColor3 = Color3.fromRGB(6, 7, 10)
darkFadeOverlay.BackgroundTransparency = 1
darkFadeOverlay.BorderSizePixel = 0
darkFadeOverlay.Visible = false
darkFadeOverlay.ZIndex = 2
darkFadeOverlay.Parent = screenGui

local fadeGradient = Instance.new("UIGradient")
fadeGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 14, 18)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
})
fadeGradient.Rotation = 90
fadeGradient.Parent = darkFadeOverlay

local centerContainer = Instance.new("Frame")
centerContainer.Name = "CenterContainer"
centerContainer.Size = UDim2.new(0, 190, 0, 165)
centerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
centerContainer.Position = UDim2.new(0.5, 0, 0.52, 0)
centerContainer.BackgroundTransparency = 1
centerContainer.Visible = false
centerContainer.ZIndex = 5
centerContainer.Parent = screenGui

local logoHolder = Instance.new("Frame")
logoHolder.Size = UDim2.new(0, 54, 0, 54)
logoHolder.AnchorPoint = Vector2.new(0.5, 0)
logoHolder.Position = UDim2.new(0.5, 0, 0, -4)
logoHolder.BackgroundTransparency = 1
logoHolder.ZIndex = 5
logoHolder.Parent = centerContainer

drawFhasixLogo(logoHolder, 6, 72)

local mainBtn = Instance.new("TextButton")
mainBtn.Name = "MainSettingsButton"
mainBtn.Size = UDim2.new(0, 166, 0, 36)
mainBtn.AnchorPoint = Vector2.new(0.5, 0)
mainBtn.Position = UDim2.new(0.5, 0, 0, 56)
mainBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainBtn.AutoButtonColor = false
mainBtn.Text = ""
mainBtn.ZIndex = 5
mainBtn.Parent = centerContainer

local mainBtnCorner = Instance.new("UICorner")
mainBtnCorner.CornerRadius = UDim.new(0, 7)
mainBtnCorner.Parent = mainBtn

local mainBtnStroke = Instance.new("UIStroke")
mainBtnStroke.Color = Color3.fromRGB(255, 255, 255)
mainBtnStroke.Transparency = 0.93
mainBtnStroke.Thickness = 1
mainBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainBtnStroke.Parent = mainBtn

local btnGradient = Instance.new("UIGradient")
btnGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, normalTop),
	ColorSequenceKeypoint.new(1, normalBottom)
})
btnGradient.Rotation = 25
btnGradient.Parent = mainBtn

local mainBtnLabel = Instance.new("TextLabel")
mainBtnLabel.Size = UDim2.new(1, 0, 1, 0)
mainBtnLabel.BackgroundTransparency = 1
mainBtnLabel.Text = "FHASIX SETTINGS"
mainBtnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
mainBtnLabel.Font = Enum.Font.GothamBold
mainBtnLabel.TextSize = 11
mainBtnLabel.ZIndex = 7
mainBtnLabel.Parent = mainBtn

local hoverProgress = Instance.new("NumberValue")
hoverProgress.Value = 0
hoverProgress.Changed:Connect(function(val)
	btnGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, normalTop:Lerp(hoverTopLeft, val)),
		ColorSequenceKeypoint.new(1, normalBottom:Lerp(hoverBottomRight, val))
	})
end)

mainBtn.MouseEnter:Connect(function()
	TweenService:Create(hoverProgress, tweenInfoHover, {Value = 1}):Play()
	TweenService:Create(mainBtnStroke, tweenInfoHover, {Transparency = 0.82}):Play()
end)
mainBtn.MouseLeave:Connect(function()
	TweenService:Create(hoverProgress, tweenInfoHover, {Value = 0}):Play()
	TweenService:Create(mainBtnStroke, tweenInfoHover, {Transparency = 0.93}):Play()
end)

local iconRow = Instance.new("Frame")
iconRow.Size = UDim2.new(0, 166, 0, 34)
iconRow.AnchorPoint = Vector2.new(0.5, 0)
iconRow.Position = UDim2.new(0.5, 0, 0, 102)
iconRow.BackgroundTransparency = 1
iconRow.ZIndex = 5
iconRow.Parent = centerContainer

local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowLayout.Padding = UDim.new(0, 10)
rowLayout.Parent = iconRow

local function createSquareIconBtn(name, order)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.LayoutOrder = order
	btn.Size = UDim2.new(0, 34, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.ZIndex = 5
	btn.Parent = iconRow

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.93
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = btn

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, normalTop),
		ColorSequenceKeypoint.new(1, normalBottom)
	})
	grad.Rotation = 25
	grad.Parent = btn

	local prog = Instance.new("NumberValue")
	prog.Value = 0
	prog.Changed:Connect(function(v)
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, normalTop:Lerp(hoverTopLeft, v)),
			ColorSequenceKeypoint.new(1, normalBottom:Lerp(hoverBottomRight, v))
		})
	end)

	btn.MouseEnter:Connect(function()
		TweenService:Create(prog, tweenInfoHover, {Value = 1}):Play()
		TweenService:Create(stroke, tweenInfoHover, {Transparency = 0.82}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(prog, tweenInfoHover, {Value = 0}):Play()
		TweenService:Create(stroke, tweenInfoHover, {Transparency = 0.93}):Play()
	end)

	return btn
end

local shopBtn = createSquareIconBtn("ShopButton", 1)
local shopIcon = Instance.new("Frame")
shopIcon.Size = UDim2.new(0, 15, 0, 14)
shopIcon.AnchorPoint = Vector2.new(0.5, 0.5)
shopIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
shopIcon.BackgroundTransparency = 1
shopIcon.ZIndex = 7
shopIcon.Parent = shopBtn

local awning = Instance.new("Frame")
awning.Size = UDim2.new(1, 0, 0, 5)
awning.BackgroundTransparency = 1
awning.ZIndex = 7
awning.Parent = shopIcon

local awningStroke = Instance.new("UIStroke")
awningStroke.Color = Color3.fromRGB(255, 255, 255)
awningStroke.Thickness = 1.4
awningStroke.Parent = awning

local awningCorner = Instance.new("UICorner")
awningCorner.CornerRadius = UDim.new(0, 2)
awningCorner.Parent = awning

for i = 1, 2 do
	local div = Instance.new("Frame")
	div.Size = UDim2.new(0, 1.2, 1, 0)
	div.Position = UDim2.new(i / 3, 0, 0, 0)
	div.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	div.BorderSizePixel = 0
	div.ZIndex = 7
	div.Parent = awning
end

local storeBody = Instance.new("Frame")
storeBody.Size = UDim2.new(0, 11, 0, 8)
storeBody.AnchorPoint = Vector2.new(0.5, 0)
storeBody.Position = UDim2.new(0.5, 0, 0, 6)
storeBody.BackgroundTransparency = 1
storeBody.ZIndex = 7
storeBody.Parent = shopIcon

local bodyStroke = Instance.new("UIStroke")
bodyStroke.Color = Color3.fromRGB(255, 255, 255)
bodyStroke.Thickness = 1.4
bodyStroke.Parent = storeBody

local wingBtn = createSquareIconBtn("CosmeticsButton", 2)
local wingHolder = Instance.new("Frame")
wingHolder.Size = UDim2.new(0, 15, 0, 15)
wingHolder.AnchorPoint = Vector2.new(0.5, 0.5)
wingHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
wingHolder.BackgroundTransparency = 1
wingHolder.ZIndex = 7
wingHolder.Parent = wingBtn

local function makeFeather(pos, sz, rot)
	local f = Instance.new("Frame")
	f.Size = sz
	f.Position = pos
	f.Rotation = rot
	f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	f.BorderSizePixel = 0
	f.ZIndex = 7
	f.Parent = wingHolder
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = f
end

makeFeather(UDim2.new(0, 1, 0, 2), UDim2.new(0, 12, 0, 3.2), -25)
makeFeather(UDim2.new(0, 2, 0, 6), UDim2.new(0, 11, 0, 3.2), -12)
makeFeather(UDim2.new(0, 4, 0, 9.5), UDim2.new(0, 8, 0, 3.2), 2)

local chatBtn = createSquareIconBtn("ChatButton", 3)
local bubble = Instance.new("Frame")
bubble.Size = UDim2.new(0, 13, 0, 11)
bubble.AnchorPoint = Vector2.new(0.5, 0.5)
bubble.Position = UDim2.new(0.5, 0, 0.5, -1)
bubble.BackgroundTransparency = 1
bubble.ZIndex = 7
bubble.Parent = chatBtn

local bubbleCorner = Instance.new("UICorner")
bubbleCorner.CornerRadius = UDim.new(0, 3)
bubbleCorner.Parent = bubble

local bubbleStroke = Instance.new("UIStroke")
bubbleStroke.Color = Color3.fromRGB(255, 255, 255)
bubbleStroke.Thickness = 1.4
bubbleStroke.Parent = bubble

for i = 0, 1 do
	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, 7 - (i * 2.5), 0, 1.3)
	line.Position = UDim2.new(0, 3, 0, 3.2 + (i * 3))
	line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	line.BorderSizePixel = 0
	line.ZIndex = 7
	line.Parent = bubble
end

local badge = Instance.new("TextButton")
badge.Name = "TitleScreenBadge"
badge.Size = UDim2.new(0, 17, 0, 14)
badge.AnchorPoint = Vector2.new(0.5, 0.5)
badge.Position = UDim2.new(1, -2, 0, 2)
badge.BackgroundColor3 = Color3.fromRGB(238, 108, 30)
badge.BorderSizePixel = 0
badge.AutoButtonColor = false
badge.Text = "9+"
badge.TextColor3 = Color3.fromRGB(255, 255, 255)
badge.Font = Enum.Font.GothamBold
badge.TextSize = 8
badge.ZIndex = 9
badge.Parent = chatBtn

local badgeCorner = Instance.new("UICorner")
badgeCorner.CornerRadius = UDim.new(1, 0)
badgeCorner.Parent = badge

local linkBtn = createSquareIconBtn("LinkButton", 4)
local linkHolder = Instance.new("Frame")
linkHolder.Size = UDim2.new(0, 15, 0, 15)
linkHolder.AnchorPoint = Vector2.new(0.5, 0.5)
linkHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
linkHolder.Rotation = -45
linkHolder.BackgroundTransparency = 1
linkHolder.ZIndex = 7
linkHolder.Parent = linkBtn

local linkLeft = Instance.new("Frame")
linkLeft.Size = UDim2.new(0, 8.5, 0, 5.5)
linkLeft.Position = UDim2.new(0, 0, 0.5, -2.75)
linkLeft.BackgroundTransparency = 1
linkLeft.ZIndex = 7
linkLeft.Parent = linkHolder

local llCorner = Instance.new("UICorner")
llCorner.CornerRadius = UDim.new(1, 0)
llCorner.Parent = linkLeft

local llStroke = Instance.new("UIStroke")
llStroke.Color = Color3.fromRGB(255, 255, 255)
llStroke.Thickness = 1.5
llStroke.Parent = linkLeft

local linkRight = Instance.new("Frame")
linkRight.Size = UDim2.new(0, 8.5, 0, 5.5)
linkRight.Position = UDim2.new(0, 6.5, 0.5, -2.75)
linkRight.BackgroundTransparency = 1
linkRight.ZIndex = 7
linkRight.Parent = linkHolder

local lrCorner = Instance.new("UICorner")
lrCorner.CornerRadius = UDim.new(1, 0)
lrCorner.Parent = linkRight

local lrStroke = Instance.new("UIStroke")
lrStroke.Color = Color3.fromRGB(255, 255, 255)
lrStroke.Thickness = 1.5
lrStroke.Parent = linkRight

local modMenuWrapper = Instance.new("Frame")
modMenuWrapper.Name = "ModMenuWrapper"
modMenuWrapper.Size = UDim2.new(0, 520, 0, 310)
modMenuWrapper.AnchorPoint = Vector2.new(0.5, 0.5)
modMenuWrapper.Position = UDim2.new(0.5, 0, 0.53, 0)
modMenuWrapper.BackgroundTransparency = 1
modMenuWrapper.Visible = false
modMenuWrapper.ZIndex = 10
modMenuWrapper.Parent = screenGui

local topHeader = Instance.new("Frame")
topHeader.Size = UDim2.new(1, 0, 0, 30)
topHeader.Position = UDim2.new(0, 0, 0, 0)
topHeader.BackgroundTransparency = 1
topHeader.ZIndex = 11
topHeader.Parent = modMenuWrapper

local modMenuRedTab = Instance.new("TextButton")
modMenuRedTab.Size = UDim2.new(0, 110, 0, 28)
modMenuRedTab.BackgroundColor3 = accentRed
modMenuRedTab.Text = "❖ PERFORMANCE"
modMenuRedTab.TextColor3 = Color3.fromRGB(255, 255, 255)
modMenuRedTab.Font = Enum.Font.GothamBold
modMenuRedTab.TextSize = 9
modMenuRedTab.AutoButtonColor = false
modMenuRedTab.ZIndex = 12
modMenuRedTab.Parent = topHeader

local mmTabCorner = Instance.new("UICorner")
mmTabCorner.CornerRadius = UDim.new(0, 6)
mmTabCorner.Parent = modMenuRedTab

local topGearBtn = Instance.new("TextButton")
topGearBtn.Size = UDim2.new(0, 28, 0, 28)
topGearBtn.Position = UDim2.new(0, 116, 0, 0)
topGearBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
topGearBtn.Text = "⚙"
topGearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
topGearBtn.Font = Enum.Font.GothamBold
topGearBtn.TextSize = 13
topGearBtn.AutoButtonColor = false
topGearBtn.ZIndex = 12
topGearBtn.Parent = topHeader

local tgCorner = Instance.new("UICorner")
tgCorner.CornerRadius = UDim.new(0, 6)
tgCorner.Parent = topGearBtn

local closeMenuBtn = Instance.new("TextButton")
closeMenuBtn.Size = UDim2.new(0, 26, 0, 24)
closeMenuBtn.AnchorPoint = Vector2.new(1, 0)
closeMenuBtn.Position = UDim2.new(1, 0, 0, 2)
closeMenuBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 26)
closeMenuBtn.Text = "✕"
closeMenuBtn.TextColor3 = accentRed
closeMenuBtn.Font = Enum.Font.GothamBold
closeMenuBtn.TextSize = 11
closeMenuBtn.ZIndex = 12
closeMenuBtn.Parent = topHeader

local cmCorner = Instance.new("UICorner")
cmCorner.CornerRadius = UDim.new(0, 5)
cmCorner.Parent = closeMenuBtn

local cmStroke = Instance.new("UIStroke")
cmStroke.Color = accentRed
cmStroke.Transparency = 0.5
cmStroke.Thickness = 1
cmStroke.Parent = closeMenuBtn

local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(1, 0, 1, -36)
mainPanel.Position = UDim2.new(0, 0, 0, 36)
mainPanel.BackgroundColor3 = Color3.fromRGB(13, 15, 19)
mainPanel.BorderSizePixel = 0
mainPanel.ZIndex = 11
mainPanel.Parent = modMenuWrapper

local mpCorner = Instance.new("UICorner")
mpCorner.CornerRadius = UDim.new(0, 8)
mpCorner.Parent = mainPanel

local mpStroke = Instance.new("UIStroke")
mpStroke.Color = Color3.fromRGB(255, 255, 255)
mpStroke.Transparency = 0.94
mpStroke.Thickness = 1
mpStroke.Parent = mainPanel

local viewContainer = Instance.new("Frame")
viewContainer.Size = UDim2.new(1, 0, 1, 0)
viewContainer.BackgroundTransparency = 1
viewContainer.ZIndex = 12
viewContainer.Parent = mainPanel

local modMenuGridView = Instance.new("Frame")
modMenuGridView.Size = UDim2.new(1, 0, 1, 0)
modMenuGridView.BackgroundTransparency = 1
modMenuGridView.Visible = true
modMenuGridView.ZIndex = 12
modMenuGridView.Parent = viewContainer

local performanceSettingsView = Instance.new("Frame")
performanceSettingsView.Size = UDim2.new(1, 0, 1, 0)
performanceSettingsView.BackgroundTransparency = 1
performanceSettingsView.Visible = false
performanceSettingsView.ZIndex = 12
performanceSettingsView.Parent = viewContainer

local fpsPreviewLabel, cpsPreviewLabel

do
	local filterRow = Instance.new("Frame")
	filterRow.Size = UDim2.new(1, -24, 0, 26)
	filterRow.Position = UDim2.new(0, 12, 0, 12)
	filterRow.BackgroundTransparency = 1
	filterRow.ZIndex = 12
	filterRow.Parent = modMenuGridView

	local tabsHolder = Instance.new("Frame")
	tabsHolder.Size = UDim2.new(0, 280, 1, 0)
	tabsHolder.BackgroundTransparency = 1
	tabsHolder.ZIndex = 12
	tabsHolder.Parent = filterRow

	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.FillDirection = Enum.FillDirection.Horizontal
	tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabsLayout.Padding = UDim.new(0, 6)
	tabsLayout.Parent = tabsHolder

	local categories = {"All", "New", "HUD", "Hypixel", "PvP"}
	for idx, catName in ipairs(categories) do
		local tab = Instance.new("TextButton")
		tab.LayoutOrder = idx
		tab.Size = UDim2.new(0, 46, 0, 22)
		tab.BackgroundColor3 = (idx == 1) and accentRed or Color3.fromRGB(21, 24, 30)
		tab.Text = catName
		tab.TextColor3 = (idx == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(165, 170, 180)
		tab.Font = Enum.Font.GothamBold
		tab.TextSize = 9
		tab.AutoButtonColor = false
		tab.ZIndex = 13
		tab.Parent = tabsHolder

		local tc = Instance.new("UICorner")
		tc.CornerRadius = UDim.new(0, 4)
		tc.Parent = tab
	end

	local searchBoxFrame = Instance.new("Frame")
	searchBoxFrame.Size = UDim2.new(0, 130, 0, 22)
	searchBoxFrame.AnchorPoint = Vector2.new(1, 0)
	searchBoxFrame.Position = UDim2.new(1, 0, 0, 0)
	searchBoxFrame.BackgroundColor3 = Color3.fromRGB(19, 22, 28)
	searchBoxFrame.ZIndex = 12
	searchBoxFrame.Parent = filterRow

	local sbCorner = Instance.new("UICorner")
	sbCorner.CornerRadius = UDim.new(0, 4)
	sbCorner.Parent = searchBoxFrame

	local sbStroke = Instance.new("UIStroke")
	sbStroke.Color = Color3.fromRGB(255, 255, 255)
	sbStroke.Transparency = 0.93
	sbStroke.Thickness = 1
	sbStroke.Parent = searchBoxFrame

	local searchInput = Instance.new("TextBox")
	searchInput.Size = UDim2.new(1, -14, 1, 0)
	searchInput.Position = UDim2.new(0, 7, 0, 0)
	searchInput.BackgroundTransparency = 1
	searchInput.PlaceholderText = "Search"
	searchInput.PlaceholderColor3 = Color3.fromRGB(115, 120, 130)
	searchInput.Text = ""
	searchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	searchInput.Font = Enum.Font.Gotham
	searchInput.TextSize = 9
	searchInput.TextXAlignment = Enum.TextXAlignment.Left
	searchInput.ZIndex = 13
	searchInput.Parent = searchBoxFrame

	local cardsGrid = Instance.new("Frame")
	cardsGrid.Size = UDim2.new(1, -24, 1, -54)
	cardsGrid.Position = UDim2.new(0, 12, 0, 44)
	cardsGrid.BackgroundTransparency = 1
	cardsGrid.ZIndex = 12
	cardsGrid.Parent = modMenuGridView

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 148, 0, 108)
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = cardsGrid

	local function createModCard(title, previewDefaultText, order, onToggle)
		local card = Instance.new("Frame")
		card.Name = title .. "Card"
		card.LayoutOrder = order
		card.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
		card.ZIndex = 13
		card.Parent = cardsGrid

		local cc = Instance.new("UICorner")
		cc.CornerRadius = UDim.new(0, 6)
		cc.Parent = card

		local cs = Instance.new("UIStroke")
		cs.Color = Color3.fromRGB(255, 255, 255)
		cs.Transparency = 0.94
		cs.Thickness = 1
		cs.Parent = card

		local titleLbl = Instance.new("TextLabel")
		titleLbl.Size = UDim2.new(1, -30, 0, 20)
		titleLbl.Position = UDim2.new(0, 10, 0, 6)
		titleLbl.BackgroundTransparency = 1
		titleLbl.Text = title
		titleLbl.TextColor3 = Color3.fromRGB(215, 220, 230)
		titleLbl.Font = Enum.Font.GothamBold
		titleLbl.TextSize = 10
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.ZIndex = 14
		titleLbl.Parent = card

		local favArrow = Instance.new("TextLabel")
		favArrow.Size = UDim2.new(0, 16, 0, 16)
		favArrow.Position = UDim2.new(1, -22, 0, 8)
		favArrow.BackgroundTransparency = 1
		favArrow.Text = "▾"
		favArrow.TextColor3 = Color3.fromRGB(140, 145, 155)
		favArrow.Font = Enum.Font.GothamBold
		favArrow.TextSize = 10
		favArrow.ZIndex = 14
		favArrow.Parent = card

		local whitePill = Instance.new("Frame")
		whitePill.Size = UDim2.new(0, 76, 0, 26)
		whitePill.AnchorPoint = Vector2.new(0.5, 0.5)
		whitePill.Position = UDim2.new(0.5, 0, 0, 50)
		whitePill.BackgroundColor3 = Color3.fromRGB(245, 247, 250)
		whitePill.ZIndex = 14
		whitePill.Parent = card

		local wpCorner = Instance.new("UICorner")
		wpCorner.CornerRadius = UDim.new(0, 4)
		wpCorner.Parent = whitePill

		local previewLbl = Instance.new("TextLabel")
		previewLbl.Size = UDim2.new(1, 0, 1, 0)
		previewLbl.BackgroundTransparency = 1
		previewLbl.Text = previewDefaultText
		previewLbl.TextColor3 = Color3.fromRGB(20, 22, 28)
		previewLbl.Font = Enum.Font.GothamBold
		previewLbl.TextSize = 9
		previewLbl.ZIndex = 15
		previewLbl.Parent = whitePill

		local cardGear = Instance.new("TextButton")
		cardGear.Size = UDim2.new(0, 22, 0, 22)
		cardGear.Position = UDim2.new(0, 8, 1, -28)
		cardGear.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
		cardGear.Text = "⚙"
		cardGear.TextColor3 = Color3.fromRGB(150, 155, 165)
		cardGear.Font = Enum.Font.GothamBold
		cardGear.TextSize = 11
		cardGear.AutoButtonColor = false
		cardGear.ZIndex = 14
		cardGear.Parent = card

		local cgCorner = Instance.new("UICorner")
		cgCorner.CornerRadius = UDim.new(0, 4)
		cgCorner.Parent = cardGear

		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Size = UDim2.new(1, -42, 0, 22)
		toggleBtn.Position = UDim2.new(0, 34, 1, -28)
		toggleBtn.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
		toggleBtn.Text = "Disabled"
		toggleBtn.TextColor3 = Color3.fromRGB(150, 155, 165)
		toggleBtn.Font = Enum.Font.GothamBold
		toggleBtn.TextSize = 9
		toggleBtn.AutoButtonColor = false
		toggleBtn.ClipsDescendants = true
		toggleBtn.ZIndex = 14
		toggleBtn.Parent = card

		local tbCorner = Instance.new("UICorner")
		tbCorner.CornerRadius = UDim.new(0, 4)
		tbCorner.Parent = toggleBtn

		local isEnabled = false
		local isAnimating = false
		local lastClickPos = nil

		toggleBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				lastClickPos = input.Position
			end
		end)

		toggleBtn.MouseButton1Click:Connect(function()
			if isAnimating then return end
			isAnimating = true
			isEnabled = not isEnabled

			local absPos = toggleBtn.AbsolutePosition
			local absSize = toggleBtn.AbsoluteSize
			local relX = absSize.X * 0.5
			local relY = absSize.Y * 0.5
			if lastClickPos then
				relX = math.clamp(lastClickPos.X - absPos.X, 0, absSize.X)
				relY = math.clamp(lastClickPos.Y - absPos.Y, 0, absSize.Y)
        end
        
			local ripple = Instance.new("Frame")
			ripple.AnchorPoint = Vector2.new(0.5, 0.5)
			ripple.Position = UDim2.new(0, relX, 0, relY)
			ripple.Size = UDim2.new(0, 0, 0, 0)
			ripple.BackgroundColor3 = isEnabled and Color3.fromRGB(65, 215, 110) or Color3.fromRGB(255, 255, 255)
			ripple.BackgroundTransparency = 0.45
			ripple.BorderSizePixel = 0
			ripple.ZIndex = 15
			ripple.Parent = toggleBtn

			local rCorner = Instance.new("UICorner")
			rCorner.CornerRadius = UDim.new(1, 0)
			rCorner.Parent = ripple

			local targetDiameter = math.max(absSize.X, absSize.Y) * 2.5
			TweenService:Create(ripple, TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, targetDiameter, 0, targetDiameter),
				BackgroundTransparency = 1
			}):Play()

			task.delay(0.16, function()
				if isEnabled then
					toggleBtn.Text = "Enabled"
					TweenService:Create(toggleBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(36, 138, 72),
						TextColor3 = Color3.fromRGB(255, 255, 255)
					}):Play()
				else
					toggleBtn.Text = "Disabled"
					TweenService:Create(toggleBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(24, 27, 34),
						TextColor3 = Color3.fromRGB(150, 155, 165)
					}):Play()
				end
				if onToggle then onToggle(isEnabled) end
				isAnimating = false
			end)

			task.delay(0.4, function()
				if ripple then ripple:Destroy() end
			end)
		end)

		return previewLbl
	end

	fpsPreviewLabel = createModCard("FPS Display", "144 FPS", 1, function(state)
		fpsHudPill.Visible = state
	end)

	cpsPreviewLabel = createModCard("CPS", "0 | 0 CPS", 2, function(state)
		cpsHudPill.Visible = state
	end)

	local topInfoBar = Instance.new("Frame")
	topInfoBar.Size = UDim2.new(1, -24, 0, 28)
	topInfoBar.Position = UDim2.new(0, 12, 0, 12)
	topInfoBar.BackgroundTransparency = 1
	topInfoBar.ZIndex = 13
	topInfoBar.Parent = performanceSettingsView

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(0, 220, 1, 0)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "ℹ Extra performance options"
	infoLabel.TextColor3 = Color3.fromRGB(165, 170, 180)
	infoLabel.Font = Enum.Font.GothamMedium
	infoLabel.TextSize = 11
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left
	infoLabel.ZIndex = 13
	infoLabel.Parent = topInfoBar

	local resetSettingsBtn = Instance.new("TextButton")
	resetSettingsBtn.Size = UDim2.new(0, 96, 0, 24)
	resetSettingsBtn.AnchorPoint = Vector2.new(1, 0)
	resetSettingsBtn.Position = UDim2.new(1, 0, 0, 2)
	resetSettingsBtn.BackgroundColor3 = Color3.fromRGB(22, 25, 32)
	resetSettingsBtn.Text = "Reset Settings"
	resetSettingsBtn.TextColor3 = Color3.fromRGB(170, 175, 185)
	resetSettingsBtn.Font = Enum.Font.GothamBold
	resetSettingsBtn.TextSize = 10
	resetSettingsBtn.AutoButtonColor = false
	resetSettingsBtn.ZIndex = 13
	resetSettingsBtn.Parent = topInfoBar

	local rsCorner = Instance.new("UICorner")
	rsCorner.CornerRadius = UDim.new(0, 6)
	rsCorner.Parent = resetSettingsBtn

	local rsStroke = Instance.new("UIStroke")
	rsStroke.Color = Color3.fromRGB(255, 255, 255)
	rsStroke.Transparency = 0.90
	rsStroke.Thickness = 1
	rsStroke.Parent = resetSettingsBtn

	local sectionHeader = Instance.new("TextButton")
	sectionHeader.Size = UDim2.new(1, -24, 0, 22)
	sectionHeader.Position = UDim2.new(0, 12, 0, 50)
	sectionHeader.BackgroundTransparency = 1
	sectionHeader.Text = "⌄ Rendering Settings"
	sectionHeader.TextColor3 = Color3.fromRGB(224, 52, 68)
	sectionHeader.Font = Enum.Font.GothamBold
	sectionHeader.TextSize = 11
	sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
	sectionHeader.AutoButtonColor = false
	sectionHeader.ZIndex = 13
	sectionHeader.Parent = performanceSettingsView

	local togglesBox = Instance.new("Frame")
	togglesBox.Size = UDim2.new(1, -24, 0, 106)
	togglesBox.Position = UDim2.new(0, 12, 0, 78)
	togglesBox.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
	togglesBox.ZIndex = 13
	togglesBox.Parent = performanceSettingsView

	local tbBoxCorner = Instance.new("UICorner")
	tbBoxCorner.CornerRadius = UDim.new(0, 6)
	tbBoxCorner.Parent = togglesBox

	local tbBoxStroke = Instance.new("UIStroke")
	tbBoxStroke.Color = Color3.fromRGB(255, 255, 255)
	tbBoxStroke.Transparency = 0.93
	tbBoxStroke.Thickness = 1
	tbBoxStroke.Parent = togglesBox

	local function createPerfToggleRow(labelText, posX, posY, onToggleCallback)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(0, 210, 0, 30)
		row.Position = UDim2.new(0, posX, 0, posY)
		row.BackgroundTransparency = 1
		row.ZIndex = 14
		row.Parent = togglesBox

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -44, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Color3.fromRGB(205, 210, 220)
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 14
		lbl.Parent = row

		local switchBtn = Instance.new("TextButton")
		switchBtn.Size = UDim2.new(0, 36, 0, 20)
		switchBtn.AnchorPoint = Vector2.new(1, 0.5)
		switchBtn.Position = UDim2.new(1, -4, 0.5, 0)
		switchBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 40)
		switchBtn.Text = ""
		switchBtn.AutoButtonColor = false
		switchBtn.ClipsDescendants = true
		switchBtn.ZIndex = 15
		switchBtn.Parent = row

		local swCorner = Instance.new("UICorner")
		swCorner.CornerRadius = UDim.new(1, 0)
		swCorner.Parent = switchBtn

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 16, 0, 16)
		knob.AnchorPoint = Vector2.new(0, 0.5)
		knob.Position = UDim2.new(0, 2, 0.5, 0)
		knob.BackgroundColor3 = Color3.fromRGB(150, 155, 165)
		knob.ZIndex = 16
		knob.Parent = switchBtn

		local knobCorner = Instance.new("UICorner")
		knobCorner.CornerRadius = UDim.new(1, 0)
		knobCorner.Parent = knob

		local isOn = false
		switchBtn.MouseButton1Click:Connect(function()
			isOn = not isOn
			local targetColor = isOn and Color3.fromRGB(36, 138, 72) or Color3.fromRGB(28, 32, 40)
			local targetKnobColor = isOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 155, 165)
			local targetKnobPos = isOn and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)

			TweenService:Create(switchBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
			TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundColor3 = targetKnobColor,
				Position = targetKnobPos
			}):Play()

			if onToggleCallback then onToggleCallback(isOn) end
		end)
	end

	local originalQualityLevel = nil
	createPerfToggleRow("Low Graphics Quality", 14, 16, function(state)
		pcall(function()
			local rendering = settings().Rendering
			if state then
				if originalQualityLevel == nil then
					originalQualityLevel = rendering.QualityLevel
				end
				rendering.QualityLevel = Enum.QualityLevel.Level01
			elseif originalQualityLevel ~= nil then
				rendering.QualityLevel = originalQualityLevel
			end
		end)
	end)

	local effectsActive = false
	local effectOriginals = {}
	local effectConnection = nil
	local effectClasses = {
		ParticleEmitter = true,
		Trail = true,
		Beam = true,
		Fire = true,
		Smoke = true,
		Sparkles = true
	}

	local function disableEffect(obj)
		if effectClasses[obj.ClassName] then
			if effectOriginals[obj] == nil then
				effectOriginals[obj] = {"Enabled", obj.Enabled}
			end
			obj.Enabled = false
		elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
			if obj.Shadows and effectOriginals[obj] == nil then
				effectOriginals[obj] = {"Shadows", true}
				obj.Shadows = false
			end
		end
	end

	createPerfToggleRow("No Particles & Effects", 230, 16, function(state)
		effectsActive = state
		if state then
			if effectConnection then effectConnection:Disconnect() end
			effectConnection = workspace.DescendantAdded:Connect(function(obj)
				if effectsActive then
					pcall(disableEffect, obj)
				end
			end)
			task.spawn(function()
				local count = 0
				for _, obj in ipairs(workspace:GetDescendants()) do
					if not effectsActive then break end
					pcall(disableEffect, obj)
					count = count + 1
					if count % 400 == 0 then
						task.wait()
					end
				end
			end)
		else
			if effectConnection then
				effectConnection:Disconnect()
				effectConnection = nil
			end
			for obj, data in pairs(effectOriginals) do
				if obj.Parent then
					pcall(function()
						obj[data[1]] = data[2]
					end)
				end
				effectOriginals[obj] = nil
			end
		end
	end)

	local glowActive = false
	local glowOriginals = {}
	local glowWatchers = {}
	local glowConnections = {}

	local glowEffectClasses = {
		BloomEffect = true,
		SunRaysEffect = true,
		DepthOfFieldEffect = true,
		BlurEffect = true
	}

	local function forceOff(obj, prop, offValue)
		if glowOriginals[obj] == nil then
			glowOriginals[obj] = {}
		end
		if glowOriginals[obj][prop] == nil then
			glowOriginals[obj][prop] = obj[prop]
		end
		obj[prop] = offValue

		if glowWatchers[obj] == nil then
			glowWatchers[obj] = {}
		end
		if glowWatchers[obj][prop] == nil then
			glowWatchers[obj][prop] = obj:GetPropertyChangedSignal(prop):Connect(function()
				if glowActive and obj[prop] ~= offValue then
					obj[prop] = offValue
				end
			end)
		end
	end

	local function removeGlow(obj)
		if obj:GetAttribute("FhasixCosmetic") then return end

		if glowEffectClasses[obj.ClassName] then
			if obj ~= blurEffect then
				forceOff(obj, "Enabled", false)
			end
		elseif obj:IsA("Highlight") then
			forceOff(obj, "Enabled", false)
		elseif obj:IsA("Atmosphere") then
			forceOff(obj, "Glare", 0)
			forceOff(obj, "Haze", 0)
		elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
			forceOff(obj, "Enabled", false)
		elseif obj:IsA("SurfaceAppearance") then
			forceOff(obj, "EmissiveStrength", 0)
		elseif obj:IsA("BasePart") and (obj.Material == Enum.Material.Neon or obj.Material == Enum.Material.ForceField) then
			forceOff(obj, "Material", Enum.Material.SmoothPlastic)
		end
	end

	createPerfToggleRow("Remove Glow / Bloom", 14, 60, function(state)
		glowActive = state
		if state then
			for _, container in ipairs({Lighting, workspace.CurrentCamera}) do
				if container then
					for _, obj in ipairs(container:GetDescendants()) do
						pcall(removeGlow, obj)
					end
					table.insert(glowConnections, container.DescendantAdded:Connect(function(obj)
						if glowActive then pcall(removeGlow, obj) end
					end))
				end
        end
        table.insert(glowConnections, workspace.DescendantAdded:Connect(function(obj)
				if glowActive then pcall(removeGlow, obj) end
			end))
			task.spawn(function()
				local count = 0
				for _, obj in ipairs(workspace:GetDescendants()) do
					if not glowActive then break end
					pcall(removeGlow, obj)
					count = count + 1
					if count % 400 == 0 then
						task.wait()
					end
				end
			end)
		else
			for _, conn in ipairs(glowConnections) do
				conn:Disconnect()
			end
			table.clear(glowConnections)

			for obj, props in pairs(glowWatchers) do
				for _, conn in pairs(props) do
					conn:Disconnect()
				end
				glowWatchers[obj] = nil
			end

			for obj, props in pairs(glowOriginals) do
				if obj.Parent then
					for prop, original in pairs(props) do
						pcall(function()
							obj[prop] = original
						end)
					end
				end
				glowOriginals[obj] = nil
			end
		end
	end)

	createPerfToggleRow("Light Texture Boost", 230, 60, function(state)
		Lighting.GlobalShadows = not state
	end)

	local lastUpdate = tick()
	local frameCount = 0

	RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
		local now = tick()
		if now - lastUpdate >= 0.5 then
			local currentFps = math.floor(frameCount / (now - lastUpdate))
			fpsPreviewLabel.Text = currentFps .. " FPS"
			fpsHudText.Text = currentFps .. " FPS"
			frameCount = 0
			lastUpdate = now
		end
	end)

	local leftClicks = {}
	local rightClicks = {}

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			table.insert(leftClicks, tick())
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			table.insert(rightClicks, tick())
		end
	end)

	RunService.Heartbeat:Connect(function()
		local now = tick()
		for i = #leftClicks, 1, -1 do
			if now - leftClicks[i] > 1 then table.remove(leftClicks, i) end
		end
		for i = #rightClicks, 1, -1 do
			if now - rightClicks[i] > 1 then table.remove(rightClicks, i) end
		end
		local cpsString = #leftClicks .. " | " .. #rightClicks .. " CPS"
		cpsPreviewLabel.Text = cpsString
		cpsHudText.Text = cpsString
	end)
end

local titleFrozen = {}

local function freezePlayer()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and not titleFrozen.hum then
		pcall(function()
			titleFrozen.hum = hum
			titleFrozen.WalkSpeed = hum.WalkSpeed
			titleFrozen.JumpPower = hum.JumpPower
			titleFrozen.JumpHeight = hum.JumpHeight
			hum.WalkSpeed = 0
			hum.JumpPower = 0
			hum.JumpHeight = 0
		end)
	end
end

local function unfreezePlayer()
	if titleFrozen.hum then
		pcall(function()
			titleFrozen.hum.WalkSpeed = titleFrozen.WalkSpeed
			titleFrozen.hum.JumpPower = titleFrozen.JumpPower
			titleFrozen.hum.JumpHeight = titleFrozen.JumpHeight
		end)
	end
	table.clear(titleFrozen)
end

local function fadeAndDestroy(g, duration)
	local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	for _, o in ipairs(g:GetDescendants()) do
		local goal = {}
		if o:IsA("GuiObject") then
			goal.BackgroundTransparency = 1
		end
		if o:IsA("TextLabel") or o:IsA("TextButton") then
			goal.TextTransparency = 1
		end
		if next(goal) then
			pcall(function()
				TweenService:Create(o, info, goal):Play()
			end)
		end
	end
	task.delay(duration + 0.05, function()
		g:Destroy()
	end)
end

local function createLoadingScreen(statusText)
	local old = parentGui:FindFirstChild("FhasixLoading")
	if old then
		old:Destroy()
	end

	local lg = Instance.new("ScreenGui")
	lg.Name = "FhasixLoading"
	lg.IgnoreGuiInset = true
	lg.ResetOnSpawn = false
	lg.DisplayOrder = 1001
	lg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	lg.Parent = parentGui

	local cover = Instance.new("TextButton")
	cover.Size = UDim2.new(1, 0, 1, 0)
	cover.BackgroundColor3 = Color3.fromRGB(6, 7, 10)
	cover.BorderSizePixel = 0
	cover.AutoButtonColor = false
	cover.Text = ""
	cover.ZIndex = 1
	cover.Parent = lg

	local logo = Instance.new("Frame")
	logo.Size = UDim2.new(0, 64, 0, 64)
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.Position = UDim2.new(0.5, 0, 0.5, -26)
	logo.BackgroundTransparency = 1
	logo.ZIndex = 2
	logo.Parent = lg
	drawFhasixLogo(logo, 3, 56)

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(0, 220, 0, 16)
	statusLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	statusLabel.Position = UDim2.new(0.5, 0, 0.5, 24)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = statusText
	statusLabel.TextColor3 = Color3.fromRGB(150, 155, 165)
	statusLabel.Font = Enum.Font.GothamMedium
	statusLabel.TextSize = 12
	statusLabel.ZIndex = 2
	statusLabel.Parent = lg

	local track = Instance.new("Frame")
	track.Size = UDim2.new(0, 170, 0, 4)
	track.AnchorPoint = Vector2.new(0.5, 0.5)
	track.Position = UDim2.new(0.5, 0, 0.5, 46)
	track.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
	track.BorderSizePixel = 0
	track.ZIndex = 2
	track.Parent = lg
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 2)
	trackCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(247, 126, 30)
	fill.BorderSizePixel = 0
	fill.ZIndex = 3
	fill.Parent = track
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 2)
	fillCorner.Parent = fill

	local api = {}
	function api.setProgress(p)
		fill.Size = UDim2.new(math.clamp(p, 0, 1), 0, 1, 0)
	end
	function api.setStatus(t)
		statusLabel.Text = t
	end
	function api.finish()
		fadeAndDestroy(lg, 0.35)
	end
	return api
end

local function preloadAssets(items, minTime, maxTime, setProgress)
	local failed = {}
	local total = #items
	local completed = 0
	local finished = false

	if total > 0 then
		task.spawn(function()
			pcall(function()
				ContentProvider:PreloadAsync(items, function(contentId, status)
					completed = completed + 1
					if status ~= Enum.AssetFetchStatus.Success then
						failed[contentId] = true
					end
				end)
			end)
			finished = true
		end)
	else
		finished = true
	end

	local startT = tick()
	while true do
		local elapsed = tick() - startT
		local timeP = math.min(elapsed / minTime, 1)
		local realP
		if finished then
			realP = 1
		elseif total > 0 then
			realP = (completed / total) * 0.9
		else
			realP = 0.9
		end
		setProgress(math.min(timeP, realP))
		if finished and timeP >= 1 then break end
		if elapsed >= maxTime then break end
		task.wait()
	end
	setProgress(1)
	return failed
end

local function tryLoadImage(content, timeout)
	local probe = Instance.new("ImageLabel")
	probe.BackgroundTransparency = 1
	probe.ImageTransparency = 0.99
	probe.Size = UDim2.new(0, 2, 0, 2)
	probe.Position = UDim2.new(0, -10, 0, -10)
	probe.Image = content
	probe.Parent = screenGui

	local done = false
	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync({probe})
		end)
		done = true
	end)

	local result = false
	local startT = tick()
	local doneAt = nil
	while tick() - startT < timeout do
		local loaded = false
		pcall(function()
			loaded = probe.IsLoaded
		end)
		if loaded then
			result = true
			break
		end
		if done then
			doneAt = doneAt or tick()
			if tick() - doneAt > 0.6 then
				break
			end
		end
		task.wait(0.05)
  end
  probe:Destroy()
	return result
end

local function httpGetAny(url)
	local okH, body = pcall(function()
		return game:HttpGet(url)
	end)
	if okH and type(body) == "string" and #body > 0 then
		return body
	end
	local req = (syn and syn.request) or request or http_request
	if req then
		local okR, res = pcall(function()
			return req({Url = url, Method = "GET"})
		end)
		if okR and type(res) == "table" and type(res.Body) == "string" and #res.Body > 0 then
			return res.Body
		end
	end
	return nil
end

local function imageTypeOf(body)
	local b1, b2, b3, b4 = string.byte(body, 1, 4)
	if b1 == 137 and b2 == 80 and b3 == 78 and b4 == 71 then return "png" end
	if b1 == 255 and b2 == 216 and b3 == 255 then return "jpg" end
	if b1 == 82 and b2 == 73 and b3 == 70 and b4 == 70 then return "webp" end
	return nil
end

local function loadImageFromUrl(url, timeout, log)
	local body = httpGetAny(url)
	if not body then
		table.insert(log, "could not download the link (HttpGet/request missing or link blocked)")
		return nil
	end
	local ext = imageTypeOf(body)
	if not ext then
		table.insert(log, "link is not a png/jpg/webp image")
		return nil
	end
	if not (writefile and getcustomasset) then
		table.insert(log, "executor cannot save files or getcustomasset missing")
		return nil
	end
	local fname = "FhasixClient_bg." .. ext
	local okW = pcall(writefile, fname, body)
	if not okW then
		table.insert(log, "writefile failed")
		return nil
	end
	local okC, custom = pcall(getcustomasset, fname)
	if not (okC and type(custom) == "string" and custom ~= "") then
		table.insert(log, "getcustomasset failed")
		return nil
	end
	if tryLoadImage(custom, timeout) then
		return custom
	end
	table.insert(log, "downloaded image did not load on screen")
	return nil
end

local function resolveImageContent(assetId, timeout, log)
	local idStr = tostring(assetId)
	local direct = "rbxassetid://" .. idStr

	if tryLoadImage(direct, timeout) then
		return direct
	end
	table.insert(log, "roblox id did not load directly")

	local okGet, objs = pcall(function()
		return game:GetObjects(direct)
	end)
	if okGet and type(objs) == "table" and #objs > 0 then
		local sawTexture = false
		for _, rootObj in ipairs(objs) do
			local nodes = {rootObj}
			for _, d in ipairs(rootObj:GetDescendants()) do
				table.insert(nodes, d)
			end
			for _, o in ipairs(nodes) do
				local tex = nil
				if o:IsA("Decal") or o:IsA("Texture") then
					tex = o.Texture
				elseif o:IsA("ImageLabel") or o:IsA("ImageButton") then
					tex = o.Image
				end
				if tex and tex ~= "" then
					sawTexture = true
					if tryLoadImage(tex, timeout) then
						return tex
					end
				end
			end
		end
		table.insert(log, sawTexture and "roblox decal image did not load" or "roblox asset has no image inside")
	else
		table.insert(log, "GetObjects not available for roblox id")
	end

	return nil
end

local SAVE_FILE = "FhasixClient_Save.json"
local DAILY_POINTS = 100
local COSMETIC_PRICE = 1500
local SKIN_ID = "fhasix_glow"

local PASS_NAME = "AKZ531"
local PASS_ID = 2052035315

local saveData = {points = 0, lastClaimDay = -1, owned = {}, equipped = "", passOwned = false}
local canSave = (writefile ~= nil and readfile ~= nil)

local function loadSave()
	if not canSave then return end
	local ok, content = pcall(function()
		if isfile and not isfile(SAVE_FILE) then
			return nil
		end
		return readfile(SAVE_FILE)
	end)
	if ok and type(content) == "string" and #content > 0 then
		local ok2, data = pcall(function()
			return HttpService:JSONDecode(content)
		end)
		if ok2 and type(data) == "table" then
			saveData.points = tonumber(data.points) or 0
			saveData.lastClaimDay = tonumber(data.lastClaimDay) or -1
			saveData.owned = (type(data.owned) == "table") and data.owned or {}
			saveData.equipped = (type(data.equipped) == "string") and data.equipped or ""
			saveData.passOwned = (data[PASS_NAME] == true) or (data.passOwned == true)
		end
	end
end

local function writeSave()
	if not canSave then return end
	pcall(function()
		local out = {
			points = saveData.points,
			lastClaimDay = saveData.lastClaimDay,
			owned = saveData.owned,
			equipped = saveData.equipped,
			passOwned = saveData.passOwned,
			[PASS_NAME] = saveData.passOwned
		}
		writefile(SAVE_FILE, HttpService:JSONEncode(out))
	end)
end

loadSave()

local pointListeners = {}

local function bindPoints(fn)
	local key = {}
	pointListeners[key] = fn
	return function()
		pointListeners[key] = nil
	end
end

local function firePoints()
	for _, fn in pairs(pointListeners) do
		pcall(fn)
	end
end

local function todayNumber()
	return math.floor(os.time() / 86400)
end

local function canClaimDaily()
	return saveData.lastClaimDay ~= todayNumber()
end

local function claimDaily()
	if not canClaimDaily() then
		return false
	end
	saveData.lastClaimDay = todayNumber()
	saveData.points = saveData.points + DAILY_POINTS
	writeSave()
	firePoints()
	return true
end

local function ownsSkin(id)
	if id == SKIN_ID and saveData.passOwned then
		return true
	end
	return saveData.owned[id] == true
end

local function buySkin(id)
	if ownsSkin(id) then
		return "owned"
  end
  if saveData.points < COSMETIC_PRICE then
		return "poor"
	end
	saveData.points = saveData.points - COSMETIC_PRICE
	saveData.owned[id] = true
	writeSave()
	firePoints()
	return "ok"
end

local function checkPassOnRoblox()
	if PASS_ID == 0 then
		return nil
	end
	local ok, owned = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, PASS_ID)
	end)
	if ok then
		return owned == true
	end
	return nil
end

local function refreshPassOwnership()
	local result = checkPassOnRoblox()
	if result == true and not saveData.passOwned then
		saveData.passOwned = true
		writeSave()
		firePoints()
	end
	return result
end

task.spawn(refreshPassOwnership)

local skinEquipped = false
local skinObjects = {}
local skinTweens = {}

local function removeSkinObjects()
	for _, tw in ipairs(skinTweens) do
		pcall(function()
			tw:Cancel()
		end)
	end
	table.clear(skinTweens)
	for _, obj in ipairs(skinObjects) do
		pcall(function()
			obj:Destroy()
		end)
	end
	table.clear(skinObjects)
end

local function applySkinToCharacter(char)
	removeSkinObjects()
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
	if not root or not skinEquipped then return end

	local hl = Instance.new("Highlight")
	hl.Name = "FhasixSkinGlow"
	hl:SetAttribute("FhasixCosmetic", true)
	hl.FillColor = Color3.fromRGB(255, 170, 80)
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.45
	hl.OutlineTransparency = 0.1
	hl.DepthMode = Enum.HighlightDepthMode.Occluded
	hl.Parent = char
	table.insert(skinObjects, hl)

	local light = Instance.new("PointLight")
	light.Name = "FhasixSkinLight"
	light:SetAttribute("FhasixCosmetic", true)
	light.Color = Color3.fromRGB(255, 170, 80)
	light.Brightness = 1.8
	light.Range = 12
	light.Shadows = false
	light.Parent = root
	table.insert(skinObjects, light)

	local pulseInfo = TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local t1 = TweenService:Create(hl, pulseInfo, {FillTransparency = 0.8})
	local t2 = TweenService:Create(light, pulseInfo, {Brightness = 0.7})
	t1:Play()
	t2:Play()
	table.insert(skinTweens, t1)
	table.insert(skinTweens, t2)
end

local function setSkinEquipped(state)
	skinEquipped = state
	if state then
		task.spawn(applySkinToCharacter, LocalPlayer.Character)
	else
		removeSkinObjects()
	end
end

LocalPlayer.CharacterAdded:Connect(function(char)
	if skinEquipped then
		task.spawn(applySkinToCharacter, char)
	end
end)

if saveData.equipped == SKIN_ID and ownsSkin(SKIN_ID) then
	setSkinEquipped(true)
end

local launchShown = false
local openLaunchScreen

local function setMenuState(newState)
	currentState = newState

	if newState == "Closed" then
		centerContainer.Visible = false
		modMenuWrapper.Visible = false
		fpsHudStroke.Transparency = 0.88
		cpsHudStroke.Transparency = 0.88
		TweenService:Create(blurEffect, fadeTweenInfo, {Size = 0}):Play()
		TweenService:Create(darkFadeOverlay, fadeTweenInfo, {BackgroundTransparency = 1}):Play()
		task.delay(0.25, function()
			if currentState == "Closed" then
				darkFadeOverlay.Visible = false
			end
		end)

	elseif newState == "Hub" then
		darkFadeOverlay.Visible = true
		modMenuWrapper.Visible = false
		centerContainer.Visible = true
		fpsHudStroke.Transparency = 0.65
		cpsHudStroke.Transparency = 0.65
		TweenService:Create(blurEffect, fadeTweenInfo, {Size = 22}):Play()
		TweenService:Create(darkFadeOverlay, fadeTweenInfo, {BackgroundTransparency = 0.42}):Play()

	elseif newState == "ModMenu" then
		darkFadeOverlay.Visible = true
		centerContainer.Visible = false
		modMenuWrapper.Visible = true
		modMenuGridView.Visible = true
		performanceSettingsView.Visible = false
		fpsHudStroke.Transparency = 0.88
		cpsHudStroke.Transparency = 0.88
		TweenService:Create(blurEffect, fadeTweenInfo, {Size = 22}):Play()
		TweenService:Create(darkFadeOverlay, fadeTweenInfo, {BackgroundTransparency = 0.42}):Play()

	elseif newState == "PerformanceSettings" then
		darkFadeOverlay.Visible = true
		centerContainer.Visible = false
		modMenuWrapper.Visible = true
		modMenuGridView.Visible = false
		performanceSettingsView.Visible = true
		fpsHudStroke.Transparency = 0.88
		cpsHudStroke.Transparency = 0.88
		TweenService:Create(blurEffect, fadeTweenInfo, {Size = 22}):Play()
		TweenService:Create(darkFadeOverlay, fadeTweenInfo, {BackgroundTransparency = 0.42}):Play()
	end
end

local function safeOpenLaunch()
	local ok, err = pcall(function()
		openLaunchScreen()
	end)
	if not ok then
		warn("[Fhasix] title screen failed: " .. tostring(err))
		for _, n in ipairs({"FhasixLaunchScreen", "FhasixLoading"}) do
			local g = parentGui:FindFirstChild(n)
			if g then
				g:Destroy()
			end
		end
		unfreezePlayer()
		setMenuState("Hub")
	end
end

local function onToggleRequest()
	if currentState == "Launch" then return end
	if not launchShown then
		safeOpenLaunch()
		return
	end
	if currentState == "Closed" then
		setMenuState("Hub")
	else
		setMenuState("Closed")
	end
end

topRightBtn.MouseButton1Click:Connect(onToggleRequest)

local function onTitleScreenRequest()
	if currentState == "Hub" then
		safeOpenLaunch()
	end
end
chatBtn.MouseButton1Click:Connect(onTitleScreenRequest)
badge.MouseButton1Click:Connect(onTitleScreenRequest)

mainBtn.MouseButton1Click:Connect(function()
	setMenuState("ModMenu")
end)

topGearBtn.MouseButton1Click:Connect(function()
	setMenuState("PerformanceSettings")
end)

closeMenuBtn.MouseButton1Click:Connect(function()
	setMenuState("Hub")
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
		onToggleRequest()
	end
end)

openLaunchScreen = function()
	if currentState == "Launch" then return end
	launchShown = true
	setMenuState("Closed")
	currentState = "Launch"
	freezePlayer()

	local DISCORD_LINK = "https://discord.gg/KdxZAmxnmv"
	local DISCORD_TEXT = "discord.gg/KdxZAmxnmv"
	local VERSION_TEXT = "Fhasix Client 1.0 (stable)"
	local BG_URL = "https://i.ibb.co/ym6McDys/background.png"
	local BG_ASSET_ID = 107676629216247
	local DESIGN_HEIGHT = 500
	local MIN_LOAD_TIME = 1.4
	local RESUME_LOAD_TIME = 0.9
	local MAX_LOAD_TIME = 8
	local PASS_CONTINUE_WAIT = 3

	local WHITE = Color3.fromRGB(255, 255, 255)
	local ORANGE = Color3.fromRGB(247, 126, 30)
	local GRAY = Color3.fromRGB(150, 155, 165)
	local CARD = Color3.fromRGB(19, 21, 26)
	local GREEN = Color3.fromRGB(65, 215, 110)

	local camera = workspace.CurrentCamera
	local closing = false
	local scaleConn = nil
	local unbindPoints = nil
	local refreshAll = function() end
	local warningOpen = false

	local old = parentGui:FindFirstChild("FhasixLaunchScreen")
	if old then
		old:Destroy()
	end

	local loader = createLoadingScreen("Loading assets")
	task.wait(0.15)

	local function addCorner(obj, r)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, r)
		c.Parent = obj
		return c
	end

	local function addStroke(obj, color, transparency, thickness)
		local s = Instance.new("UIStroke")
		s.Color = color
		s.Transparency = transparency
		s.Thickness = thickness or 1
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = obj
		return s
	end

	local function box(parent, size, pos, z, color, transparency)
		local f = Instance.new("Frame")
		f.Size = size
		f.Position = pos
		f.BackgroundColor3 = color or WHITE
		f.BackgroundTransparency = transparency or 0
		f.BorderSizePixel = 0
		f.ZIndex = z or 6
		f.Parent = parent
		return f
	end

	local function label(parent, text, size, pos, textSize, color, font, xAlign, z)
		local l = Instance.new("TextLabel")
		l.Size = size
		l.Position = pos
		l.BackgroundTransparency = 1
		l.Text = text
		l.TextColor3 = color or WHITE
		l.Font = font or Enum.Font.GothamBold
		l.TextSize = textSize
		l.TextXAlignment = xAlign or Enum.TextXAlignment.Center
		l.ZIndex = z or 6
		l.Parent = parent
		return l
	end

	local function ring(parent, size, pos, radius, thickness)
		local f = box(parent, size, pos, 7, WHITE, 1)
		addCorner(f, radius)
		local s = Instance.new("UIStroke")
		s.Color = WHITE
		s.Thickness = thickness or 1.4
		s.Parent = f
		return f
	end

	local function line(h, x1, y1, x2, y2, thickness)
		local dx = x2 - x1
		local dy = y2 - y1
		local len = math.sqrt(dx * dx + dy * dy)
		local f = box(h, UDim2.new(0, len, 0, thickness or 1.5), UDim2.new(0, (x1 + x2) / 2, 0, (y1 + y2) / 2), 7, WHITE)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Rotation = math.deg(math.atan2(dy, dx))
		return f
	end

	local function fillPoly(parent, polys, res, z, color)
		for row = 0, res - 1 do
			local y = (row + 0.5) / res
			local startCol = nil
			for col = 0, res do
				local x = (col + 0.5) / res
				local filled = false
				if col < res then
					for _, poly in ipairs(polys) do
						if isPointInPoly(x, y, poly) then
							filled = true
							break
						end
					end
				end
				if filled and not startCol then
					startCol = col
				elseif not filled and startCol then
					box(parent, UDim2.new((col - startCol) / res, 0, 1 / res + 0.01, 0), UDim2.new(startCol / res, 0, row / res, 0), z, color or WHITE)
					startCol = nil
				end
			end
		end
	end

	local function gear(h, cx, cy, d)
		local rad = d / 2 + 0.6
		for t = 0, 7 do
			local ang = math.rad(t * 45)
			local tooth = box(h, UDim2.new(0, d * 0.3, 0, d * 0.34), UDim2.new(0, cx + math.sin(ang) * rad, 0, cy - math.cos(ang) * rad), 7)
			tooth.AnchorPoint = Vector2.new(0.5, 0.5)
			tooth.Rotation = t * 45
		end
		ring(h, UDim2.new(0, d, 0, d), UDim2.new(0, cx - d / 2, 0, cy - d / 2), 50, 1.8)
	end

	local function attachHover(btn, grad, strokeObj, topN, botN, topH, botH, strokeN, strokeH)
		local prog = Instance.new("NumberValue")
		prog.Value = 0
		prog.Changed:Connect(function(v)
			grad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, topN:Lerp(topH, v)),
				ColorSequenceKeypoint.new(1, botN:Lerp(botH, v))
			})
		end)
		local function setHover(on)
			TweenService:Create(prog, tweenInfoHover, {Value = on and 1 or 0}):Play()
			TweenService:Create(strokeObj, tweenInfoHover, {Transparency = on and strokeH or strokeN}):Play()
		end
		btn.MouseEnter:Connect(function() setHover(true) end)
		btn.MouseLeave:Connect(function() setHover(false) end)
		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then setHover(true) end
		end)
		btn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then setHover(false) end
		end)
	end

	local function darkButton(parent, size, pos, radius)
		local btn = Instance.new("TextButton")
		btn.Size = size
		btn.Position = pos
		btn.BackgroundColor3 = WHITE
		btn.AutoButtonColor = false
		btn.Text = ""
		btn.BorderSizePixel = 0
		btn.ZIndex = 5
		btn.Parent = parent
		addCorner(btn, radius or 6)
		local st = addStroke(btn, WHITE, 0.93, 1)
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, normalTop),
			ColorSequenceKeypoint.new(1, normalBottom)
		})
		g.Rotation = 25
		g.Parent = btn
		attachHover(btn, g, st, normalTop, normalBottom, hoverTopLeft, hoverBottomRight, 0.93, 0.82)
		return btn
	end

	local function menuLabel(btn, text, iconBuilder, color)
		local group = Instance.new("Frame")
		group.AnchorPoint = Vector2.new(0.5, 0.5)
		group.Position = UDim2.new(0.5, 0, 0.5, 0)
		group.Size = UDim2.new(0, 0, 1, 0)
		group.AutomaticSize = Enum.AutomaticSize.X
		group.BackgroundTransparency = 1
		group.ZIndex = 6
		group.Parent = btn
		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 8)
		layout.Parent = group
		if iconBuilder then
			local holder = Instance.new("Frame")
			holder.Size = UDim2.new(0, 14, 0, 14)
			holder.BackgroundTransparency = 1
			holder.LayoutOrder = 1
			holder.ZIndex = 6
			holder.Parent = group
			iconBuilder(holder)
    end
    local lbl = Instance.new("TextLabel")
		lbl.AutomaticSize = Enum.AutomaticSize.X
		lbl.Size = UDim2.new(0, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = color or WHITE
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 13
		lbl.LayoutOrder = 2
		lbl.ZIndex = 6
		lbl.Parent = group
	end

	local starPoly = {}
	for i = 0, 9 do
		local a = math.rad(-90 + i * 36)
		local r = (i % 2 == 0) and 0.5 or 0.21
		table.insert(starPoly, {0.5 + math.cos(a) * r, 0.53 + math.sin(a) * r})
	end

	local shirtPoly = {
		{0.0, 0.3}, {0.28, 0.08}, {0.4, 0.08}, {0.5, 0.2}, {0.6, 0.08}, {0.72, 0.08},
		{1.0, 0.3}, {0.85, 0.5}, {0.75, 0.42}, {0.75, 0.95}, {0.25, 0.95}, {0.25, 0.42}, {0.15, 0.5}
	}

	local icons = {}

	icons.person = function(h)
		addCorner(box(h, UDim2.new(0, 6, 0, 6), UDim2.new(0, 4, 0, 0), 7), 3)
		addCorner(box(h, UDim2.new(0, 12, 0, 6), UDim2.new(0, 1, 0, 8), 7), 4)
	end

	icons.people = function(h)
		addCorner(box(h, UDim2.new(0, 5, 0, 5), UDim2.new(0, 1, 0, 1), 7), 3)
		addCorner(box(h, UDim2.new(0, 8, 0, 5), UDim2.new(0, 0, 0, 8), 7), 3)
		addCorner(box(h, UDim2.new(0, 5, 0, 5), UDim2.new(0, 8, 0, 1), 7), 3)
		addCorner(box(h, UDim2.new(0, 8, 0, 5), UDim2.new(0, 6, 0, 8), 7), 3)
	end

	icons.star = function(h)
		fillPoly(h, {starPoly}, 20, 7, WHITE)
	end

	icons.shirt = function(h)
		fillPoly(h, {shirtPoly}, 20, 7, WHITE)
	end

	icons.store = function(h)
		local awn = ring(h, UDim2.new(1, 0, 0, 5), UDim2.new(0, 0, 0, 0), 2, 1.3)
		for i = 1, 2 do
			box(awn, UDim2.new(0, 1.2, 1, 0), UDim2.new(i / 3, 0, 0, 0), 7)
		end
		ring(h, UDim2.new(0, 10, 0, 8), UDim2.new(0, 2, 0, 6), 1, 1.3)
	end

	icons.grid = function(h)
		for gx = 0, 1 do
			for gy = 0, 1 do
				ring(h, UDim2.new(0, 7, 0, 7), UDim2.new(0, 1 + gx * 9, 0, 1 + gy * 9), 2, 1.5)
			end
		end
	end

	icons.chat = function(h)
		ring(h, UDim2.new(0, 10, 0, 8), UDim2.new(0, 0, 0, 0), 3, 1.5)
		ring(h, UDim2.new(0, 9, 0, 7), UDim2.new(0, 8, 0, 10), 3, 1.5)
	end

	icons.scan = function(h)
		for cx = 0, 1 do
			for cy = 0, 1 do
				local px = (cx == 0) and 0 or 13
				local py = (cy == 0) and 0 or 13
				box(h, UDim2.new(0, 5, 0, 1.6), UDim2.new(0, px, 0, (cy == 0) and 0 or 16.4), 7)
				box(h, UDim2.new(0, 1.6, 0, 5), UDim2.new(0, (cx == 0) and 0 or 16.4, 0, py), 7)
			end
		end
		ring(h, UDim2.new(0, 6, 0, 6), UDim2.new(0, 6, 0, 6), 50, 1.5)
	end

	icons.gears = function(h)
		gear(h, 7, 11, 8)
		gear(h, 14, 5, 5)
	end

	icons.gem = function(h)
		local segs = {
			{4, 2, 14, 2}, {14, 2, 18, 7}, {18, 7, 9, 16.5}, {9, 16.5, 0, 7}, {0, 7, 4, 2},
			{0, 7, 18, 7}, {4, 2, 7, 7}, {14, 2, 11, 7}, {7, 7, 9, 16.5}, {11, 7, 9, 16.5}
		}
		for _, s in ipairs(segs) do
			line(h, s[1], s[2], s[3], s[4], 1.4)
		end
	end

	icons.archive = function(h)
		ring(h, UDim2.new(0, 16, 0, 5), UDim2.new(0, 1, 0, 1), 2, 1.5)
		ring(h, UDim2.new(0, 14, 0, 8), UDim2.new(0, 2, 0, 8), 2, 1.5)
		box(h, UDim2.new(0, 6, 0, 1.5), UDim2.new(0, 6, 0, 11), 7)
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "FhasixLaunchScreen"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 1000
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parentGui

	local bg = Instance.new("ImageButton")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(8, 9, 12)
	bg.BorderSizePixel = 0
	bg.AutoButtonColor = false
	bg.Image = ""
	bg.ScaleType = Enum.ScaleType.Crop
	bg.ZIndex = 1
	bg.Parent = gui

	local shade = Instance.new("Frame")
	shade.Size = UDim2.new(1, 0, 1, 0)
	shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shade.BorderSizePixel = 0
	shade.ZIndex = 2
	shade.Parent = gui
	local shadeGradient = Instance.new("UIGradient")
	shadeGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.55),
		NumberSequenceKeypoint.new(1, 0.2)
	})
	shadeGradient.Rotation = 90
	shadeGradient.Parent = shade

	local root = Instance.new("Frame")
	root.BackgroundTransparency = 1
	root.BorderSizePixel = 0
	root.Visible = false
	root.ZIndex = 3
	root.Parent = gui

	local rootScale = Instance.new("UIScale")
	rootScale.Parent = root

	local function updateScale()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
		local s = math.clamp(vp.Y / DESIGN_HEIGHT, 0.55, 1.25)
		s = math.floor(s * 20 + 0.5) / 20
		rootScale.Scale = s
		root.Size = UDim2.new(1 / s, 0, 1 / s, 0)
	end
	updateScale()
	if camera then
		scaleConn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	end

	local toast = box(root, UDim2.new(0, 240, 0, 30), UDim2.new(0.5, 0, 1, -8), 20, CARD)
	toast.AnchorPoint = Vector2.new(0.5, 1)
	toast.Visible = false
	addCorner(toast, 8)
	addStroke(toast, ORANGE, 0.5, 1)
	local toastLabel = label(toast, "", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 12, WHITE, Enum.Font.GothamBold, nil, 21)
	local toastToken = 0

	local function showToast(text)
		toastToken = toastToken + 1
		local mine = toastToken
		toastLabel.Text = text
		toast.Visible = true
		task.delay(2.2, function()
			if toastToken == mine then
				toast.Visible = false
			end
		end)
	end

	local function attachRipple(btn)
		btn.ClipsDescendants = true
		local lastPos = nil
		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				lastPos = input.Position
			end
		end)
		btn.MouseButton1Click:Connect(function()
			local s = rootScale.Scale
			local absPos = btn.AbsolutePosition
			local absSize = btn.AbsoluteSize
			local relX = absSize.X * 0.5 / s
			local relY = absSize.Y * 0.5 / s
			if lastPos then
				relX = math.clamp((lastPos.X - absPos.X) / s, 0, absSize.X / s)
				relY = math.clamp((lastPos.Y - absPos.Y) / s, 0, absSize.Y / s)
			end

			local ripple = Instance.new("Frame")
			ripple.AnchorPoint = Vector2.new(0.5, 0.5)
			ripple.Position = UDim2.new(0, relX, 0, relY)
			ripple.Size = UDim2.new(0, 0, 0, 0)
			ripple.BackgroundColor3 = WHITE
			ripple.BackgroundTransparency = 0.55
			ripple.BorderSizePixel = 0
			ripple.ZIndex = btn.ZIndex + 5
			ripple.Parent = btn
			addCorner(ripple, 100)

			local diameter = math.max(absSize.X, absSize.Y) / s * 2.6
			TweenService:Create(ripple, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, diameter, 0, diameter),
				BackgroundTransparency = 1
			}):Play()
			task.delay(0.5, function()
				ripple:Destroy()
			end)
		end)
	end

	local animated = {}
	local function registerSlide(obj, dx, dy)
		table.insert(animated, {obj = obj, final = obj.Position, dx = dx, dy = dy})
	end

	local function shifted(item)
		local f = item.final
		return UDim2.new(f.X.Scale, f.X.Offset + item.dx, f.Y.Scale, f.Y.Offset + item.dy)
	end

	local function revealUI()
		for _, item in ipairs(animated) do
			item.obj.Position = shifted(item)
		end
		root.Visible = true
		for idx, item in ipairs(animated) do
			task.delay((idx - 1) * 0.06, function()
				if not closing then
					TweenService:Create(item.obj, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = item.final}):Play()
				end
			end)
		end
	end

	local function hideUI()
		for _, item in ipairs(animated) do
			TweenService:Create(item.obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = shifted(item)}):Play()
		end
	end

	local function closeLaunch(afterClose)
		if closing then return end
		closing = true
		hideUI()
		task.delay(0.3, function()
			local resumeLoader = createLoadingScreen("Resuming")
			local ok, err = pcall(function()
				task.wait(0.1)
				if unbindPoints then
					unbindPoints()
				end
				if scaleConn then
					scaleConn:Disconnect()
				end
				gui:Destroy()
				unfreezePlayer()
				currentState = "Closed"
				if afterClose then
					afterClose()
				end
				preloadAssets({}, RESUME_LOAD_TIME, 4, resumeLoader.setProgress)
			end)
			if not ok then
				warn("[Fhasix] resume failed: " .. tostring(err))
				unfreezePlayer()
				if currentState == "Launch" then
					currentState = "Closed"
				end
			end
			resumeLoader.finish()
		end)
	end

	local function showPassWarning()
		if warningOpen then return end
		warningOpen = true

		local blocker = Instance.new("TextButton")
		blocker.Size = UDim2.new(1, 0, 1, 0)
		blocker.Position = UDim2.new(0, 0, 0, 0)
		blocker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		blocker.BackgroundTransparency = 0.35
		blocker.BorderSizePixel = 0
		blocker.AutoButtonColor = false
		blocker.Text = ""
		blocker.ZIndex = 40
		blocker.Parent = root

		local panel = box(root, UDim2.new(0, 300, 0, 226), UDim2.new(0.5, 0, 0.5, 0), 41, CARD)
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
		addCorner(panel, 10)
		addStroke(panel, ORANGE, 0.45, 1)

		label(panel, "Before you buy", UDim2.new(1, -24, 0, 22), UDim2.new(0, 12, 0, 10), 15, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 42)

		local body = label(panel, "Buy this cosmetic only from Roblox, on the official game pass page, and on the main account you want the cosmetic on.\n\nDo not delete your Roblox files or your executor folder. If you have to, back them up first. Deleting the save file removes the cosmetic from this client.", UDim2.new(1, -24, 0, 130), UDim2.new(0, 12, 0, 38), 11, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 42)
		body.TextWrapped = true
		body.TextYAlignment = Enum.TextYAlignment.Top

		local function closeWarning()
			blocker:Destroy()
			panel:Destroy()
			warningOpen = false
		end

		local cancelBtn = darkButton(panel, UDim2.new(0.5, -18, 0, 32), UDim2.new(0, 12, 1, -44), 6)
		label(cancelBtn, "Cancel", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 12, WHITE, Enum.Font.GothamBold, nil, 7)
		attachRipple(cancelBtn)
		cancelBtn.MouseButton1Click:Connect(closeWarning)

		local continueBtn = Instance.new("TextButton")
		continueBtn.Size = UDim2.new(0.5, -18, 0, 32)
		continueBtn.Position = UDim2.new(0.5, 6, 1, -44)
		continueBtn.BackgroundColor3 = Color3.fromRGB(60, 62, 70)
		continueBtn.AutoButtonColor = false
		continueBtn.BorderSizePixel = 0
		continueBtn.Font = Enum.Font.GothamBold
		continueBtn.TextSize = 12
		continueBtn.TextColor3 = WHITE
		continueBtn.Text = "Continue (" .. PASS_CONTINUE_WAIT .. ")"
		continueBtn.ZIndex = 42
		continueBtn.Parent = panel
		addCorner(continueBtn, 6)
		attachRipple(continueBtn)

		local ready = false
		task.spawn(function()
			for i = PASS_CONTINUE_WAIT, 1, -1 do
				if not panel.Parent then return end
				continueBtn.Text = "Continue (" .. i .. ")"
				task.wait(1)
			end
			if panel.Parent then
				continueBtn.Text = "Continue"
				continueBtn.BackgroundColor3 = ORANGE
				ready = true
			end
		end)

		continueBtn.MouseButton1Click:Connect(function()
			if not ready then return end
			closeWarning()
			local url = "https://www.roblox.com/game-pass/" .. tostring(PASS_ID)
			local opened = false
			if GuiService and GuiService.OpenBrowserWindow then
				opened = pcall(function()
					GuiService:OpenBrowserWindow(url)
				end)
			end
			if opened then
				showToast("Opened the pass page - after buying, press Check")
			elseif setclipboard then
				pcall(setclipboard, url)
				showToast("Pass link copied - buy it, then press Check")
			else
				showToast("Buy the pass: " .. url)
			end
		end)
	end

	local discordBtn = darkButton(root, UDim2.new(0, 200, 0, 40), UDim2.new(0, 12, 0, 12), 8)
	local discordIcon = box(discordBtn, UDim2.new(0, 22, 0, 18), UDim2.new(0, 14, 0.5, -9), 7, WHITE, 1)
	addCorner(box(discordIcon, UDim2.new(0, 22, 0, 15), UDim2.new(0, 0, 0, 1), 7, Color3.fromRGB(205, 208, 216)), 6)
	addCorner(box(discordIcon, UDim2.new(0, 4, 0, 5), UDim2.new(0, 5, 0, 6), 8, Color3.fromRGB(19, 21, 26)), 2)
	addCorner(box(discordIcon, UDim2.new(0, 4, 0, 5), UDim2.new(0, 13, 0, 6), 8, Color3.fromRGB(19, 21, 26)), 2)
	label(discordBtn, "Join our Discord", UDim2.new(1, -54, 0, 16), UDim2.new(0, 46, 0, 5), 12, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 7)
	label(discordBtn, DISCORD_TEXT, UDim2.new(1, -54, 0, 14), UDim2.new(0, 46, 0, 21), 10, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 7)
	discordBtn.MouseButton1Click:Connect(function()
		local copied = false
		if setclipboard then
			copied = pcall(setclipboard, DISCORD_LINK)
		end
		showToast(copied and "Discord link copied" or ("Discord: " .. DISCORD_LINK))
	end)
	registerSlide(discordBtn, 0, -80)

	local cluster = Instance.new("Frame")
	cluster.AnchorPoint = Vector2.new(1, 0)
	cluster.Position = UDim2.new(1, -12, 0, 12)
	cluster.Size = UDim2.new(0, 0, 0, 36)
	cluster.AutomaticSize = Enum.AutomaticSize.X
	cluster.BackgroundTransparency = 1
	cluster.ZIndex = 5
	cluster.Parent = root

	local clusterLayout = Instance.new("UIListLayout")
	clusterLayout.FillDirection = Enum.FillDirection.Horizontal
	clusterLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	clusterLayout.SortOrder = Enum.SortOrder.LayoutOrder
	clusterLayout.Padding = UDim.new(0, 8)
	clusterLayout.Parent = cluster

	local profile = darkButton(cluster, UDim2.new(0, 140, 0, 36), UDim2.new(0, 0, 0, 0), 8)
	profile.LayoutOrder = 0
	local avatarUrl = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(0, 24, 0, 24)
	avatar.Position = UDim2.new(0, 8, 0, 6)
	avatar.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
	avatar.BorderSizePixel = 0
	avatar.Image = avatarUrl
	avatar.ZIndex = 7
	avatar.Parent = profile
	addCorner(avatar, 6)
	local nameLabel = label(profile, LocalPlayer.Name, UDim2.new(1, -44, 1, 0), UDim2.new(0, 40, 0, 0), 11, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 7)
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	profile.MouseButton1Click:Connect(function()
		showToast("Profile - coming soon")
	end)

	local topIcons = {"grid", "chat", "scan", "gears", "gem", "archive"}
	for idx, iconName in ipairs(topIcons) do
		local b = darkButton(cluster, UDim2.new(0, 36, 0, 36), UDim2.new(0, 0, 0, 0), 8)
		b.LayoutOrder = idx
		local h = box(b, UDim2.new(0, 18, 0, 18), UDim2.new(0.5, -9, 0.5, -9), 6, WHITE, 1)
		icons[iconName](h)
		b.MouseButton1Click:Connect(function()
			if iconName == "gears" then
				closeLaunch(function()
					setMenuState("Hub")
				end)
			else
				showToast("Coming soon")
			end
		end)
	end
	registerSlide(cluster, 0, -80)

	local stack = Instance.new("Frame")
	stack.Size = UDim2.new(0, 220, 0, 332)
	stack.AnchorPoint = Vector2.new(0.5, 0.5)
	stack.Position = UDim2.new(0.5, 0, 0.5, 14)
	stack.BackgroundTransparency = 1
	stack.ZIndex = 5
	stack.Parent = root

	local brand = Instance.new("Frame")
	brand.Size = UDim2.new(1, 0, 0, 44)
	brand.Position = UDim2.new(0, 0, 0, 0)
	brand.BackgroundTransparency = 1
	brand.ZIndex = 5
	brand.Parent = stack

	local brandLayout = Instance.new("UIListLayout")
	brandLayout.FillDirection = Enum.FillDirection.Horizontal
	brandLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	brandLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	brandLayout.SortOrder = Enum.SortOrder.LayoutOrder
	brandLayout.Padding = UDim.new(0, 8)
	brandLayout.Parent = brand

	local launchLogo = Instance.new("Frame")
	launchLogo.Size = UDim2.new(0, 40, 0, 40)
	launchLogo.BackgroundTransparency = 1
	launchLogo.LayoutOrder = 1
	launchLogo.ZIndex = 5
	launchLogo.Parent = brand
	drawFhasixLogo(launchLogo, 6, 72)

	local brandText = Instance.new("TextLabel")
	brandText.AutomaticSize = Enum.AutomaticSize.X
	brandText.Size = UDim2.new(0, 0, 1, 0)
	brandText.BackgroundTransparency = 1
	brandText.RichText = true
	brandText.Text = 'Fhasix <font color="#F77E1E">Client</font>'
	brandText.TextColor3 = WHITE
	brandText.Font = Enum.Font.GothamBold
	brandText.TextSize = 20
	brandText.LayoutOrder = 2
	brandText.ZIndex = 5
	brandText.Parent = brand

	local PANEL_POS = UDim2.new(0.5, 0, 0.5, 30)
	local activePanel = nil
  local function openPanel(p)
		activePanel = p
		stack.Visible = false
		p.Position = UDim2.new(0.5, 0, 0.5, 56)
		p.Visible = true
		TweenService:Create(p, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = PANEL_POS}):Play()
	end

	local function closePanel()
		if activePanel then
			activePanel.Visible = false
			activePanel = nil
		end
		stack.Visible = true
	end

	local function makePanel(titleText, w, h)
		local p = Instance.new("Frame")
		p.Size = UDim2.new(0, w, 0, h)
		p.AnchorPoint = Vector2.new(0.5, 0.5)
		p.Position = PANEL_POS
		p.BackgroundColor3 = CARD
		p.BorderSizePixel = 0
		p.Visible = false
		p.ZIndex = 5
		p.Parent = root
		addCorner(p, 10)
		addStroke(p, WHITE, 0.9, 1)
		label(p, titleText, UDim2.new(1, -100, 0, 24), UDim2.new(0, 16, 0, 10), 15, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 6)
		local backBtn = darkButton(p, UDim2.new(0, 64, 0, 26), UDim2.new(1, -76, 0, 10), 6)
		label(backBtn, "Back", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 12, WHITE, Enum.Font.GothamBold, nil, 6)
		backBtn.MouseButton1Click:Connect(closePanel)
		return p
	end

	local friendsPanel = makePanel("Friends", 340, 290)

	local friendTabs = {"All", "Online", "In Game"}
	local friendTabButtons = {}
	local friendTab = "All"
	local friendData = nil
	local friendRows = {}
	local friendsLoading = false

	local tabHolder = Instance.new("Frame")
	tabHolder.Size = UDim2.new(1, -32, 0, 24)
	tabHolder.Position = UDim2.new(0, 16, 0, 46)
	tabHolder.BackgroundTransparency = 1
	tabHolder.ZIndex = 6
	tabHolder.Parent = friendsPanel
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.Parent = tabHolder

	for idx, tname in ipairs(friendTabs) do
		local tb = Instance.new("TextButton")
		tb.LayoutOrder = idx
		tb.Size = UDim2.new(0, 76, 1, 0)
		tb.BackgroundColor3 = (idx == 1) and ORANGE or Color3.fromRGB(21, 24, 30)
		tb.AutoButtonColor = false
		tb.BorderSizePixel = 0
		tb.Text = tname
		tb.TextColor3 = (idx == 1) and WHITE or GRAY
		tb.Font = Enum.Font.GothamBold
		tb.TextSize = 11
		tb.ZIndex = 6
		tb.Parent = tabHolder
		addCorner(tb, 6)
		friendTabButtons[tname] = tb
	end

	local friendsList = Instance.new("ScrollingFrame")
	friendsList.Size = UDim2.new(1, -32, 1, -90)
	friendsList.Position = UDim2.new(0, 16, 0, 78)
	friendsList.BackgroundTransparency = 1
	friendsList.BorderSizePixel = 0
	friendsList.ScrollBarThickness = 3
	friendsList.ScrollBarImageColor3 = Color3.fromRGB(90, 94, 104)
	friendsList.ScrollingDirection = Enum.ScrollingDirection.Y
	friendsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	friendsList.CanvasSize = UDim2.new(0, 0, 0, 0)
	friendsList.ZIndex = 6
	friendsList.Parent = friendsPanel
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 6)
	listLayout.Parent = friendsList

	local friendsStatus = label(friendsPanel, "", UDim2.new(1, -32, 0, 40), UDim2.new(0, 16, 0, 140), 12, GRAY, Enum.Font.GothamMedium, nil, 6)

	local function createFriendRow(f, order)
		local row = darkButton(friendsList, UDim2.new(1, -6, 0, 40), UDim2.new(0, 0, 0, 0), 8)
		row.LayoutOrder = order

		local av = Instance.new("ImageLabel")
		av.Size = UDim2.new(0, 28, 0, 28)
		av.Position = UDim2.new(0, 8, 0, 6)
		av.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
		av.BorderSizePixel = 0
		av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(f.id) .. "&w=100&h=100"
		av.ZIndex = 7
		av.Parent = row
		addCorner(av, 6)

		local nm = label(row, f.display, UDim2.new(1, -130, 0, 16), UDim2.new(0, 44, 0, 5), 12, WHITE, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 7)
		nm.TextTruncate = Enum.TextTruncate.AtEnd
		local un = label(row, "@" .. f.name, UDim2.new(1, -130, 0, 14), UDim2.new(0, 44, 0, 21), 10, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 7)
		un.TextTruncate = Enum.TextTruncate.AtEnd

		local statusText = "Offline"
		local statusColor = GRAY
		if f.ingame then
			statusText = "In game"
			statusColor = GREEN
		elseif f.online then
			statusText = "Online"
			statusColor = Color3.fromRGB(100, 180, 255)
		end
		local dot = box(row, UDim2.new(0, 8, 0, 8), UDim2.new(1, -78, 0.5, -4), 7, statusColor)
		addCorner(dot, 4)
		label(row, statusText, UDim2.new(0, 60, 1, 0), UDim2.new(1, -68, 0, 0), 10, statusColor, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 7)

		row.MouseButton1Click:Connect(function()
			local copied = false
			if setclipboard then
				copied = pcall(setclipboard, f.name)
			end
			showToast(copied and ("Copied @" .. f.name) or ("@" .. f.name))
		end)
	end

	local function renderFriends()
		for _, r in ipairs(friendRows) do
			r:Destroy()
		end
		table.clear(friendRows)
		if not friendData then return end

		local shown = 0
		for _, f in ipairs(friendData) do
			local pass = (friendTab == "All")
				or (friendTab == "Online" and (f.online or f.ingame))
				or (friendTab == "In Game" and f.ingame)
			if pass and shown < 150 then
				shown = shown + 1
				createFriendRow(f, shown)
			end
		end

		for _, child in ipairs(friendsList:GetChildren()) do
			if child:IsA("TextButton") then
				table.insert(friendRows, child)
			end
		end

		if shown == 0 then
			if #friendData == 0 then
				friendsStatus.Text = "No friends found"
			elseif friendTab == "Online" then
				friendsStatus.Text = "Nobody is online right now"
			elseif friendTab == "In Game" then
				friendsStatus.Text = "None of your friends are in this game"
			else
				friendsStatus.Text = "No friends found"
			end
			friendsStatus.Visible = true
		else
			friendsStatus.Visible = false
		end
	end

	local function setFriendTab(name)
		friendTab = name
		for tname, tb in pairs(friendTabButtons) do
			tb.BackgroundColor3 = (tname == name) and ORANGE or Color3.fromRGB(21, 24, 30)
			tb.TextColor3 = (tname == name) and WHITE or GRAY
		end
		renderFriends()
	end

	for tname, tb in pairs(friendTabButtons) do
		tb.MouseButton1Click:Connect(function()
			setFriendTab(tname)
		end)
	end

	local function loadFriends()
		if friendsLoading then return end
		friendsLoading = true
		friendsStatus.Text = "Loading friends..."
		friendsStatus.Visible = true

		local list = {}
		pcall(function()
			local pages = Players:GetFriendsAsync(LocalPlayer.UserId)
			while true do
				for _, item in ipairs(pages:GetCurrentPage()) do
					table.insert(list, {
						id = item.Id,
						name = item.Username,
						display = item.DisplayName or item.Username
					})
				end
				if pages.IsFinished or #list >= 200 then break end
				pages:AdvanceToNextPageAsync()
			end
		end)

		if #list == 0 then
			friendsStatus.Text = "Couldn't load friends"
			friendsLoading = false
			return
		end

		local onlineMap = {}
		pcall(function()
			for _, info in ipairs(LocalPlayer:GetFriendsOnline(200)) do
				onlineMap[info.VisitorId] = info
			end
		end)

		for _, f in ipairs(list) do
			local info = onlineMap[f.id]
			f.online = (info ~= nil) and (info.IsOnline == true)
			f.ingame = Players:GetPlayerByUserId(f.id) ~= nil
		end

		table.sort(list, function(a, b)
			local ra = a.ingame and 0 or (a.online and 1 or 2)
			local rb = b.ingame and 0 or (b.online and 1 or 2)
			if ra ~= rb then
				return ra < rb
			end
			return string.lower(a.display) < string.lower(b.display)
		end)

		friendData = list
		friendsLoading = false
		renderFriends()
	end

	local cosmeticsPanel = makePanel("Cosmetics", 300, 340)

	local cosPoints = label(cosmeticsPanel, "", UDim2.new(1, -32, 0, 18), UDim2.new(0, 16, 0, 40), 12, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 6)
	cosPoints.RichText = true

	local skinCard = box(cosmeticsPanel, UDim2.new(0, 200, 0, 168), UDim2.new(0.5, -100, 0, 66), 6, Color3.fromRGB(24, 27, 34))
	addCorner(skinCard, 8)
	addStroke(skinCard, WHITE, 0.93, 1)

	local orbRing = box(skinCard, UDim2.new(0, 64, 0, 64), UDim2.new(0.5, -32, 0, 10), 7, ORANGE, 1)
	addCorner(orbRing, 32)
	local orbStroke = addStroke(orbRing, ORANGE, 0.45, 2)
	TweenService:Create(orbStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.9}):Play()
	local orb = box(skinCard, UDim2.new(0, 34, 0, 34), UDim2.new(0.5, -17, 0, 25), 8, Color3.fromRGB(255, 170, 80))
	addCorner(orb, 17)

	label(skinCard, "Fhasix Glow", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 80), 14, WHITE, Enum.Font.GothamBold, nil, 7)
	local skinDesc = label(skinCard, "A soft pulsing aura around your character. Only you can see it.", UDim2.new(1, -24, 0, 26), UDim2.new(0, 12, 0, 100), 10, GRAY, Enum.Font.GothamMedium, nil, 7)
	skinDesc.TextWrapped = true

	local equipBtn = Instance.new("TextButton")
	equipBtn.Size = UDim2.new(1, -24, 0, 30)
	equipBtn.Position = UDim2.new(0, 12, 1, -40)
	equipBtn.AutoButtonColor = false
	equipBtn.BorderSizePixel = 0
	equipBtn.Font = Enum.Font.GothamBold
	equipBtn.TextSize = 12
	equipBtn.TextColor3 = WHITE
	equipBtn.ZIndex = 7
	equipBtn.Parent = skinCard
	addCorner(equipBtn, 6)
	attachRipple(equipBtn)

	local passBtn = darkButton(cosmeticsPanel, UDim2.new(0, 200, 0, 30), UDim2.new(0.5, -100, 0, 244), 6)
	passBtn.BackgroundColor3 = ORANGE
	label(passBtn, "Get with pass " .. PASS_NAME, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 12, WHITE, Enum.Font.GothamBold, nil, 7)
	attachRipple(passBtn)

	local checkBtn = darkButton(cosmeticsPanel, UDim2.new(0, 200, 0, 26), UDim2.new(0.5, -100, 0, 280), 6)
	label(checkBtn, "I bought it - check", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 11, GRAY, Enum.Font.GothamMedium, nil, 7)
	attachRipple(checkBtn)

	local function refreshSkinUI()
		cosPoints.Text = 'Your points: <font color="#F77E1E"><b>' .. tostring(math.floor(saveData.points)) .. '</b></font>'
		local owned = ownsSkin(SKIN_ID)
		if not owned then
			equipBtn.Text = "Claim - " .. COSMETIC_PRICE .. " points"
			equipBtn.BackgroundColor3 = ORANGE
		elseif skinEquipped then
			equipBtn.Text = "Unequip"
			equipBtn.BackgroundColor3 = Color3.fromRGB(46, 50, 60)
		else
			equipBtn.Text = "Equip"
			equipBtn.BackgroundColor3 = ORANGE
		end
		passBtn.Visible = not owned
		checkBtn.Visible = not owned
	end
	refreshSkinUI()
  equipBtn.MouseButton1Click:Connect(function()
		if not ownsSkin(SKIN_ID) then
			local res = buySkin(SKIN_ID)
			if res == "ok" then
				showToast("Fhasix Glow claimed")
			elseif res == "poor" then
				showToast("Need " .. COSMETIC_PRICE .. " points (you have " .. math.floor(saveData.points) .. ")")
			end
		else
			setSkinEquipped(not skinEquipped)
			saveData.equipped = skinEquipped and SKIN_ID or ""
			writeSave()
			showToast(skinEquipped and "Fhasix Glow equipped" or "Fhasix Glow removed")
		end
		refreshAll()
	end)

	passBtn.MouseButton1Click:Connect(function()
		if PASS_ID == 0 then
			showToast("Pass ID is not set in the script yet")
			return
		end
		if ownsSkin(SKIN_ID) then
			refreshAll()
			return
		end
		showPassWarning()
	end)

	checkBtn.MouseButton1Click:Connect(function()
		local result = refreshPassOwnership()
		if result == true then
			showToast("Pass found - cosmetic unlocked")
		elseif result == false then
			showToast("Pass not found on this account yet")
		else
			showToast("Could not reach Roblox - try again")
		end
		refreshAll()
	end)

	label(cosmeticsPanel, "More skins coming soon", UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 1, -26), 10, GRAY, Enum.Font.GothamMedium, nil, 6)

	local menuItems = {
		{"Resume", icons.person, "resume"},
		{"Friends", icons.people, "friends"},
		{"Partnered Servers", icons.star, "partners"},
		{"Cosmetics", icons.shirt, "cosmetics"}
	}
	for idx, item in ipairs(menuItems) do
		local b = darkButton(stack, UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 58 + (idx - 1) * 42), 8)
		menuLabel(b, item[1], item[2], WHITE)
		b.MouseButton1Click:Connect(function()
			local action = item[3]
			if action == "resume" then
				closeLaunch(function()
					setMenuState("Hub")
				end)
			elseif action == "friends" then
				openPanel(friendsPanel)
				if friendData == nil and not friendsLoading then
					task.spawn(function()
						pcall(loadFriends)
					end)
				end
			elseif action == "cosmetics" then
				refreshAll()
				openPanel(cosmeticsPanel)
			else
				showToast(item[1] .. " - coming soon")
			end
		end)
	end

	local storeBtn = Instance.new("TextButton")
	storeBtn.Size = UDim2.new(1, 0, 0, 34)
	storeBtn.Position = UDim2.new(0, 0, 0, 226)
	storeBtn.BackgroundColor3 = WHITE
	storeBtn.AutoButtonColor = false
	storeBtn.Text = ""
	storeBtn.BorderSizePixel = 0
	storeBtn.ZIndex = 5
	storeBtn.Parent = stack
	addCorner(storeBtn, 8)
	local storeStroke = addStroke(storeBtn, Color3.fromRGB(255, 150, 70), 0.55, 1)
	local storeTop = Color3.fromRGB(250, 128, 30)
	local storeBot = Color3.fromRGB(88, 46, 24)
	local storeGrad = Instance.new("UIGradient")
	storeGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, storeTop),
		ColorSequenceKeypoint.new(1, storeBot)
	})
	storeGrad.Rotation = 0
	storeGrad.Parent = storeBtn
	attachHover(storeBtn, storeGrad, storeStroke, storeTop, storeBot, Color3.fromRGB(255, 165, 80), Color3.fromRGB(130, 68, 32), 0.55, 0.15)
	menuLabel(storeBtn, "STORE", icons.store, WHITE)
	storeBtn.MouseButton1Click:Connect(function()
		showToast("Store - coming soon")
	end)

	local quitBtn = Instance.new("TextButton")
	quitBtn.AnchorPoint = Vector2.new(0.5, 0)
	quitBtn.Size = UDim2.new(0, 150, 0, 34)
	quitBtn.Position = UDim2.new(0.5, 0, 0, 272)
	quitBtn.BackgroundColor3 = Color3.fromRGB(64, 38, 22)
	quitBtn.BackgroundTransparency = 0.45
	quitBtn.AutoButtonColor = false
	quitBtn.BorderSizePixel = 0
	quitBtn.Text = "QUIT GAME"
	quitBtn.TextColor3 = ORANGE
	quitBtn.Font = Enum.Font.GothamBold
	quitBtn.TextSize = 13
	quitBtn.ZIndex = 5
	quitBtn.Parent = stack
	addCorner(quitBtn, 8)
	local function quitHover(on)
		TweenService:Create(quitBtn, tweenInfoHover, {BackgroundTransparency = on and 0.15 or 0.45}):Play()
	end
	quitBtn.MouseEnter:Connect(function() quitHover(true) end)
	quitBtn.MouseLeave:Connect(function() quitHover(false) end)
	quitBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then quitHover(true) end
	end)
	quitBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then quitHover(false) end
	end)
	quitBtn.MouseButton1Click:Connect(function()
		closeLaunch()
	end)

	label(stack, VERSION_TEXT, UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 0, 314), 11, GRAY, Enum.Font.GothamMedium, nil, 6)
	registerSlide(stack, 0, 70)

	local checkin = darkButton(root, UDim2.new(0, 186, 0, 46), UDim2.new(1, -12, 1, -12), 8)
	checkin.AnchorPoint = Vector2.new(1, 1)
	attachRipple(checkin)
	fillPoly(box(checkin, UDim2.new(0, 24, 0, 24), UDim2.new(0, 10, 0, 11), 7, WHITE, 1), {starPoly}, 24, 7, ORANGE)
	local checkinTop = label(checkin, "", UDim2.new(1, -50, 0, 14), UDim2.new(0, 44, 0, 8), 11, GRAY, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 7)
	local checkinLine = label(checkin, "", UDim2.new(1, -50, 0, 16), UDim2.new(0, 44, 0, 23), 12, WHITE, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 7)
	checkinLine.RichText = true
	checkin.MouseButton1Click:Connect(function()
		if claimDaily() then
			showToast("+" .. DAILY_POINTS .. " points claimed")
		else
			showToast("Already claimed - come back tomorrow")
		end
		refreshAll()
	end)
	registerSlide(checkin, 260, 0)

	local pointsPill = box(root, UDim2.new(0, 186, 0, 28), UDim2.new(1, -12, 1, -66), 5, CARD)
	pointsPill.AnchorPoint = Vector2.new(1, 1)
	addCorner(pointsPill, 8)
	addStroke(pointsPill, WHITE, 0.93, 1)
	local pillLabel = label(pointsPill, "", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 12, WHITE, Enum.Font.GothamBold, nil, 7)
	pillLabel.RichText = true
	registerSlide(pointsPill, 260, 0)

	refreshAll = function()
		pillLabel.Text = '<font color="#F77E1E">' .. tostring(math.floor(saveData.points)) .. '</font> points'
		if canClaimDaily() then
			checkinTop.Text = "Daily reward"
			checkinLine.Text = "Claim <b>" .. DAILY_POINTS .. " points</b>!"
		else
			checkinTop.Text = "Daily reward claimed"
			checkinLine.Text = "Come back <b>tomorrow</b>"
		end
		refreshSkinUI()
	end
	refreshAll()
	unbindPoints = bindPoints(function()
		refreshAll()
	end)

	loader.setProgress(0.12)
	loader.setStatus("Loading background")
	local bgLog = {}
	local bgContent = loadImageFromUrl(BG_URL, 4, bgLog)
	if not bgContent then
		bgContent = resolveImageContent(BG_ASSET_ID, 4, bgLog)
	end
	loader.setStatus("Loading assets")

	bg.Image = bgContent or ("rbxassetid://" .. tostring(BG_ASSET_ID))

	local items = {avatarUrl}
	if bgContent then
		table.insert(items, bgContent)
	end
	preloadAssets(items, MIN_LOAD_TIME, MAX_LOAD_TIME, loader.setProgress)
	loader.finish()
	revealUI()

	task.spawn(function()
		local t0 = tick()
		while tick() - t0 < 4 and not closing do
			local loaded = false
			pcall(function()
				loaded = bg.IsLoaded
			end)
			if loaded then
				return
			end
			task.wait(0.2)
		end
		if closing then return end
		local details = table.concat(bgLog, " | ")
		if details == "" then
			details = "image never reported as loaded"
		end
		if setclipboard then
			pcall(setclipboard, "Fhasix background debug: " .. details)
		end
		warn("[Fhasix] background failed: " .. details)
		showToast("Background failed - details copied")
	end)
end

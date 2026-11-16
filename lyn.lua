local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

pcall(function()
    local oldNameCall
    oldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            return
        end
        return oldNameCall(self, ...)
    end)
end)

pcall(function()
    for _, conn in ipairs(getconnections(LocalPlayer.Idled)) do
        conn:Disable()
    end
end)

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local HitboxEnabled = false
local EspEnabled = false
local AutoFireEnabled = false
local SpinBotEnabled = false
local SpeedEnabled = false
local FlyEnabled = false
local MenuVisible = true

local HitboxSquareSize = Vector3.new(20, 20, 20)
local NormalHeadSize = Vector3.new(2, 1, 1)
local NormalSpeed = 16
local CustomSpeed = 50 
local SpinSpeed = 50 
local FlySpeed = 50

local TOGGLE_HITBOX_KEY = Enum.KeyCode.G
local TOGGLE_ESP_KEY = Enum.KeyCode.H
local TOGGLE_AUTOFIRE_KEY = Enum.KeyCode.J
local TOGGLE_SPIN_KEY = Enum.KeyCode.K
local TOGGLE_SPEED_KEY = Enum.KeyCode.L
local TOGGLE_FLY_KEY = Enum.KeyCode.F
local TOGGLE_GUI_KEY = Enum.KeyCode.Insert

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LieuNhuYenGui_Pro"
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 345)
MainFrame.Position = UDim2.new(0.5, -130, 0, 15)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 105, 180)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.2
UIStroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 24)
TitleLabel.Position = UDim2.new(0, 10, 0, 8)
TitleLabel.Text = "LIỄU NHƯ YÊN "
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 2
TitleLabel.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -28, 0, 8)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 12
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
CloseButton.BackgroundTransparency = 0.2
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 3
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

local function createRowButton(text, yPos)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 240, 0, 30)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.BackgroundColor3 = Color3.fromRGB(219, 112, 147)
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.ZIndex = 2
    button.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 182, 193)
    stroke.Transparency = 0.4
    stroke.Parent = button

    return button
end

local HitboxButton = createRowButton("Hitbox [G]", 38)
local EspButton = createRowButton("ESP [H]", 72)
local AutoFireButton = createRowButton("Auto Fire [J]", 106)
local SpinButton = createRowButton("SpinBot [K]", 140)
local SpeedButton = createRowButton("Speed [L]", 174)
local FlyButton = createRowButton("Fly [F]", 208)

local SpeedDisplayLabel = Instance.new("TextLabel")
SpeedDisplayLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedDisplayLabel.Position = UDim2.new(0, 10, 0, 244)
SpeedDisplayLabel.Text = "Current Speed: 50"
SpeedDisplayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDisplayLabel.TextSize = 11
SpeedDisplayLabel.Font = Enum.Font.GothamBold
SpeedDisplayLabel.BackgroundTransparency = 1
SpeedDisplayLabel.TextXAlignment = Enum.TextXAlignment.Center
SpeedDisplayLabel.ZIndex = 2
SpeedDisplayLabel.Parent = MainFrame

local SpeedDownButton = createRowButton("Speed -", 268)
SpeedDownButton.Size = UDim2.new(0, 116, 0, 28)

local SpeedUpButton = createRowButton("Speed +", 268)
SpeedUpButton.Size = UDim2.new(0, 116, 0, 28)
SpeedUpButton.Position = UDim2.new(0, 134, 0, 268)

local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

local ON_COLOR = Color3.fromRGB(46, 204, 113)
local OFF_COLOR = Color3.fromRGB(231, 76, 60)

local function updateUI()
    HitboxButton.BackgroundColor3 = HitboxEnabled and ON_COLOR or OFF_COLOR
    EspButton.BackgroundColor3 = EspEnabled and ON_COLOR or OFF_COLOR
    AutoFireButton.BackgroundColor3 = AutoFireEnabled and ON_COLOR or OFF_COLOR
    SpinButton.BackgroundColor3 = SpinBotEnabled and ON_COLOR or OFF_COLOR
    SpeedButton.BackgroundColor3 = SpeedEnabled and ON_COLOR or OFF_COLOR
    FlyButton.BackgroundColor3 = FlyEnabled and ON_COLOR or OFF_COLOR
    SpeedDisplayLabel.Text = "Current Speed: " .. tostring(CustomSpeed)
end

local function isTarget(character)
    if not character or not character:IsA("Model") then return false end
    if LocalPlayer.Character and character == LocalPlayer.Character then return false end
    
    local player = Players:GetPlayerFromCharacter(character)
    if player then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return false
        end
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head") or character:FindFirstChild("head")
    
    if humanoid and head and humanoid.Health > 0 then
        return true
    end
    return false
end

local function applyHitbox(character)
    local head = character:FindFirstChild("Head") or character:FindFirstChild("head")
    if head and head:IsA("BasePart") then
        if head.Size ~= HitboxSquareSize then
            head.Size = HitboxSquareSize
            head.Transparency = 0.7
            head.BrickColor = BrickColor.new("Really red")
            head.Material = Enum.Material.Neon
            head.CanCollide = false
        end
    end
end

local function resetHitbox(character)
    local head = character:FindFirstChild("Head") or character:FindFirstChild("head")
    if head and head:IsA("BasePart") then
        head.Size = NormalHeadSize
        head.Transparency = 0
        head.Material = Enum.Material.SmoothPlastic
        head.CanCollide = true
    end
end

local function applyEsp(character)
    if not character:FindFirstChild("LieuHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "LieuHighlight"
        highlight.Adornee = character
        highlight.FillTransparency = 1
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end
end

local function removeEsp(character)
    local highlight = character:FindFirstChild("LieuHighlight")
    if highlight then highlight:Destroy() end
end

local bv, bg

local function toggleFly()
    FlyEnabled = not FlyEnabled
    updateUI()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if FlyEnabled then
        hum.PlatformStand = true
        bv = Instance.new("BodyVelocity")
        bv.Name = "LieuFlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = root

        bg = Instance.new("BodyGyro")
        bg.Name = "LieuFlyGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = root.CFrame
        bg.Parent = root
    else
        hum.PlatformStand = false
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end

local function toggleHitbox()
    HitboxEnabled = not HitboxEnabled
    updateUI()
    if not HitboxEnabled then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") then
                resetHitbox(obj)
            end
        end
    end
end

local function toggleEsp()
    EspEnabled = not EspEnabled
    updateUI()
    if not EspEnabled then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") then
                removeEsp(obj)
            end
        end
    end
end

local function toggleAutoFire()
    AutoFireEnabled = not AutoFireEnabled
    updateUI()
end

local function toggleSpinBot()
    SpinBotEnabled = not SpinBotEnabled
    updateUI()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.AutoRotate = not SpinBotEnabled
        end
    end
end

local function toggleSpeed()
    SpeedEnabled = not SpeedEnabled
    updateUI()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = SpeedEnabled and CustomSpeed or NormalSpeed
        end
    end
end

HitboxButton.Activated:Connect(toggleHitbox)
EspButton.Activated:Connect(toggleEsp)
AutoFireButton.Activated:Connect(toggleAutoFire)
SpinButton.Activated:Connect(toggleSpinBot)
SpeedButton.Activated:Connect(toggleSpeed)
FlyButton.Activated:Connect(toggleFly)

SpeedUpButton.Activated:Connect(function()
    CustomSpeed = CustomSpeed + 10
    updateUI()
end)

SpeedDownButton.Activated:Connect(function()
    if CustomSpeed > 10 then
        CustomSpeed = CustomSpeed - 10
        updateUI()
    end
end)

local function unloadScript()
    HitboxEnabled = false
    EspEnabled = false
    AutoFireEnabled = false
    SpinBotEnabled = false
    SpeedEnabled = false
    FlyEnabled = false
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") then
            resetHitbox(obj)
            removeEsp(obj)
        end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = NormalSpeed
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
    ScreenGui:Destroy()
end

CloseButton.Activated:Connect(unloadScript)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == TOGGLE_HITBOX_KEY then toggleHitbox()
    elseif input.KeyCode == TOGGLE_ESP_KEY then toggleEsp()
    elseif input.KeyCode == TOGGLE_AUTOFIRE_KEY then toggleAutoFire()
    elseif input.KeyCode == TOGGLE_SPIN_KEY then toggleSpinBot()
    elseif input.KeyCode == TOGGLE_SPEED_KEY then toggleSpeed()
    elseif input.KeyCode == TOGGLE_FLY_KEY then toggleFly()
    elseif input.KeyCode == TOGGLE_GUI_KEY then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

updateUI()

task.spawn(function()
    while true do
        if HitboxEnabled or EspEnabled then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and isTarget(obj) then
                    if HitboxEnabled then applyHitbox(obj) end
                    if EspEnabled then applyEsp(obj) end
                elseif obj:IsA("Folder") then
                    for _, subObj in ipairs(obj:GetChildren()) do
                        if subObj:IsA("Model") and isTarget(subObj) then
                            if HitboxEnabled then applyHitbox(subObj) end
                            if EspEnabled then applyEsp(subObj) end
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)

task.spawn(function()
    while true do
        if AutoFireEnabled then
            local targetPart = Mouse.Target
            if targetPart and targetPart.Parent then
                local characterModel = targetPart.Parent
                if not characterModel:IsA("Model") and characterModel.Parent then
                    characterModel = characterModel.Parent
                end

                if isTarget(characterModel) then
                    if mouse1press then
                        mouse1press()
                        task.wait(0.05)
                        mouse1release()
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")

        if hum then
            if SpinBotEnabled then
                hum.AutoRotate = false
            end
            
            if SpeedEnabled and hum.WalkSpeed ~= CustomSpeed then
                hum.WalkSpeed = CustomSpeed
            elseif not SpeedEnabled and hum.WalkSpeed == CustomSpeed then
                hum.WalkSpeed = NormalSpeed
            end
        end

        if SpinBotEnabled and root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
        end

        if FlyEnabled and root and bg and bv then
            bg.CFrame = Camera.CFrame
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end

            bv.Velocity = moveDir * FlySpeed
        end
    end
end)

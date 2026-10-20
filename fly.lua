--// FLY & SPEED HUB
--// Interface Mobile + PC

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remover interface anterior
local old = playerGui:FindFirstChild("FlySpeedHub")
if old then
    old:Destroy()
end

-- Configurações
local flying = false
local speedEnabled = false
local flySpeed = 50
local walkSpeed = 50

local flyConnection

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FlySpeedHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Função para arredondar
local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

-- Função para arrastar
local function draggable(frame)

    local dragging = false
    local dragStart
    local startPos

    frame.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

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

        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then

            local delta = input.Position - dragStart

            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Logo flutuante
local logo = Instance.new("TextButton")
logo.Size = UDim2.new(0, 58, 0, 58)
logo.Position = UDim2.new(0, 20, 0.5, -29)
logo.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
logo.Text = "✈"
logo.TextColor3 = Color3.fromRGB(0, 200, 255)
logo.TextSize = 30
logo.Font = Enum.Font.GothamBold
logo.Parent = gui

corner(logo, 18)
draggable(logo)

local logoStroke = Instance.new("UIStroke")
logoStroke.Color = Color3.fromRGB(0, 170, 255)
logoStroke.Thickness = 2
logoStroke.Parent = logo

-- Menu principal
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 285, 0, 330)
main.Position = UDim2.new(0.5, -142, 0.5, -165)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
main.Parent = gui

corner(main, 14)
draggable(main)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 160, 255)
stroke.Thickness = 1.5
stroke.Parent = main

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 0, 45)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✈ FLY & SPEED"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextSize = 19
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

-- Fechar
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(1, -39, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 24
close.Parent = main

corner(close, 8)

close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

logo.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- Scrollbar
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 420)
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingLeft = UDim.new(0, 5)
padding.PaddingRight = UDim.new(0, 5)
padding.Parent = scroll

-- Criar botões
local function button(text)

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 45)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 15
    b.Font = Enum.Font.GothamSemibold
    b.Parent = scroll

    corner(b, 10)

    return b
end

local function getHumanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- Fly
local flyButton = button("🕊️ Fly: OFF")

local function stopFly()

    flying = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    local root = getRoot()
    local humanoid = getHumanoid()

    if root then
        root.AssemblyLinearVelocity = Vector3.zero
    end

    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
    end

    flyButton.Text = "🕊️ Fly: OFF"
    flyButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
end

local function startFly()

    local root = getRoot()
    local humanoid = getHumanoid()

    if not root or not humanoid then return end

    flying = true

    flyButton.Text = "🕊️ Fly: ON"
    flyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 180)

    humanoid.PlatformStand = true

    flyConnection = RunService.RenderStepped:Connect(function()

        if not flying then return end

        local rootPart = getRoot()
        local hum = getHumanoid()

        if not rootPart or not hum then
            stopFly()
            return
        end

        local camera = workspace.CurrentCamera
        local direction = hum.MoveDirection

        local vertical = 0

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            vertical = 1
        elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            vertical = -1
        end

        local velocity =
            direction * flySpeed +
            Vector3.new(0, vertical * flySpeed, 0)

        rootPart.AssemblyLinearVelocity = velocity

        rootPart.CFrame = CFrame.new(
            rootPart.Position,
            rootPart.Position + camera.CFrame.LookVector
        )
    end)
end

flyButton.MouseButton1Click:Connect(function()

    if flying then
        stopFly()
    else
        startFly()
    end

end)

-- Speed
local speedButton = button("⚡ Speed: OFF")

speedButton.MouseButton1Click:Connect(function()

    speedEnabled = not speedEnabled

    local humanoid = getHumanoid()

    if speedEnabled then

        speedButton.Text = "⚡ Speed: ON"
        speedButton.BackgroundColor3 = Color3.fromRGB(0, 120, 180)

        if humanoid then
            humanoid.WalkSpeed = walkSpeed
        end

    else

        speedButton.Text = "⚡ Speed: OFF"
        speedButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)

        if humanoid then
            humanoid.WalkSpeed = 16
        end

    end

end)

-- Ajustar velocidade
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -10, 0, 30)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚙ Velocidade: 60"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextSize = 15
speedLabel.Font = Enum.Font.GothamSemibold
speedLabel.Parent = scroll

local plus = button("➕ Aumentar velocidade")
local minus = button("➖ Diminuir velocidade")

local function updateSpeed()

    speedLabel.Text = "⚙ Velocidade: " .. walkSpeed

    flySpeed = walkSpeed

    if speedEnabled then
        local humanoid = getHumanoid()

        if humanoid then
            humanoid.WalkSpeed = walkSpeed
        end
    end
end

plus.MouseButton1Click:Connect(function()

    walkSpeed = math.min(walkSpeed + 10, 300)
    updateSpeed()

end)

minus.MouseButton1Click:Connect(function()

    walkSpeed = math.max(walkSpeed - 10, 10)
    updateSpeed()

end)

-- Restaurar personagem
player.CharacterAdded:Connect(function()

    flying = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    flyButton.Text = "🕊️ Fly: OFF"
    flyButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)

    task.wait(1)

    if speedEnabled then
        local humanoid = getHumanoid()

        if humanoid then
            humanoid.WalkSpeed = walkSpeed
        end
    end

end)

print("Fly & Speed Hub carregado!")

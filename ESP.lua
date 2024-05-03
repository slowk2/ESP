-- esp_library.lua

local ESP = {}


function ESP.DrawPlayerESP(player, settings)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Size = Vector2.new(50, 50)
    box.Color = settings.Color or Color3.fromRGB(255, 255, 255)
    box.Thickness = settings.Thickness or 1
    box.Transparency = settings.Transparency or 1

    local function Visibility(state)
        box.Visible = state
    end

    local function Updater()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
                local head = player.Character:FindFirstChild("Head")
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if head and rootPart then
                    local headPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local rootPartPos, _ = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                        box.Position = Vector2.new(rootPartPos.X - box.Size.X / 2, rootPartPos.Y - box.Size.Y / 2)
                        Visibility(true)
                    else
                        Visibility(false)
                    end
                end
            else
                Visibility(false)
                if not game.Players:FindFirstChild(player.Name) then
                    connection:Disconnect()
                end
            end
        end)
    end

    coroutine.wrap(Updater)()

    return box
end

function ESP.DrawSkeletonESP(player, settings)
    local limbs = {}
    local R15 = (player.Character.Humanoid.RigType == Enum.HumanoidRigType.R15) and true or false
    if R15 then 
        limbs = {
            -- Spine
            Head_UpperTorso = Drawing.new("Line"),
            UpperTorso_LowerTorso = Drawing.new("Line"),
            -- Left Arm
            UpperTorso_LeftUpperArm = Drawing.new("Line"),
            LeftUpperArm_LeftLowerArm = Drawing.new("Line"),
            LeftLowerArm_LeftHand = Drawing.new("Line"),
            -- Right Arm
            UpperTorso_RightUpperArm = Drawing.new("Line"),
            RightUpperArm_RightLowerArm = Drawing.new("Line"),
            RightLowerArm_RightHand = Drawing.new("Line"),
            -- Left Leg
            LowerTorso_LeftUpperLeg = Drawing.new("Line"),
            LeftUpperLeg_LeftLowerLeg = Drawing.new("Line"),
            LeftLowerLeg_LeftFoot = Drawing.new("Line"),
            -- Right Leg
            LowerTorso_RightUpperLeg = Drawing.new("Line"),
            RightUpperLeg_RightLowerLeg = Drawing.new("Line"),
            RightLowerLeg_RightFoot = Drawing.new("Line"),
        }
    else 
        limbs = {
            Head_Spine = Drawing.new("Line"),
            Spine = Drawing.new("Line"),
            LeftArm = Drawing.new("Line"),
            LeftArm_UpperTorso = Drawing.new("Line"),
            RightArm = Drawing.new("Line"),
            RightArm_UpperTorso = Drawing.new("Line"),
            LeftLeg = Drawing.new("Line"),
            LeftLeg_LowerTorso = Drawing.new("Line"),
            RightLeg = Drawing.new("Line"),
            RightLeg_LowerTorso = Drawing.new("Line")
        }
    end
    
    for _, line in pairs(limbs) do
        line.Visible = false
        line.From = Vector2.new(0, 0)
        line.To = Vector2.new(0, 0)
        line.Color = settings.Color or Color3.fromRGB(255, 255, 255)
        line.Thickness = settings.Thickness or 1
        line.Transparency = settings.Transparency or 1
    end

    local function Visibility(state)
        for _, line in pairs(limbs) do
            line.Visible = state
        end
    end

    local function Updater()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("Head") then
                local function GetViewportPoint(part)
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                    return Vector2.new(pos.X, pos.Y), onScreen
                end
                
                local headPos, onScreen = GetViewportPoint(player.Character.Head)
                if onScreen then
                    -- Update the positions of the skeleton lines here
                    -- For example:
                    -- limbs.Head_UpperTorso.From = headPos
                    -- limbs.Head_UpperTorso.To = GetViewportPoint(player.Character.UpperTorso).X
                    -- limbs.Head_UpperTorso.To = GetViewportPoint(player.Character.UpperTorso).Y
                    -- limbs.Head_UpperTorso.Visible = true
                else
                    Visibility(false)
                end
            else
                Visibility(false)
                if not game.Players:FindFirstChild(player.Name) then
                    connection:Disconnect()
                end
            end
        end)
    end

    coroutine.wrap(Updater)()

    return limbs
end

function ESP.DrawViewTracerESP(player, settings)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = settings.Color or Color3.fromRGB(255, 203, 138)
    line.Thickness = settings.Thickness or 1
    line.Transparency = settings.Transparency or 1

    local function Updater()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("Head") then
                local headpos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.Head.Position)
                if OnScreen then
                    local offsetCFrame = CFrame.new(0, 0, -settings.Length or 15)
                    local check = false
                    line.From = Vector2.new(headpos.X, headpos.Y)
                    if settings.AutoThickness then
                        local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude
                        local value = math.clamp(1 / distance * 100, 0.1, 3)
                        line.Thickness = value
                    end
                    repeat
                        local dir = player.Character.Head.CFrame:ToWorldSpace(offsetCFrame)
                        offsetCFrame = offsetCFrame * CFrame.new(0, 0, settings.Smoothness or 0.2)
                        local dirpos, vis = workspace.CurrentCamera:WorldToViewportPoint(Vector3.new(dir.X, dir.Y, dir.Z))
                        if vis then
                            check = true
                            line.To = Vector2.new(dirpos.X, dirpos.Y)
                            line.Visible = true
                            offsetCFrame = CFrame.new(0, 0, -settings.Length or 15)
                        end
                    until check == true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
                if not game.Players:FindFirstChild(player.Name) then
                    connection:Disconnect()
                end
            end
        end)
    end

    coroutine.wrap(Updater)()

    return line
end

return ESP

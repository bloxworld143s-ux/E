--[[
    ========================================================================
    [+] GitHub: ://github.com
    [+] Optimization: Max Compatibility & Layer Override (All Games)
    [+] Feature: Built-In Execution Toast Notification
    [+] Version: 3.3.0 (Production Build)
    ========================================================================
]]--

pcall(function()
    -- 1. Anti-Duplicate Self-Cleaning Routine
    local function CleanOld()
        pcall(function()
            local cg = game:GetService("CoreGui"):FindFirstChild("Universal_Screensaver_Core")
            if cg then cg:Destroy() end
        end)
        pcall(function()
            local pl = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Universal_Screensaver_Core")
            if pl then pl:Destroy() end
        end)
    end
    CleanOld()

    -- 2. Core Service Mapping
    local G = game
    local S = G.GetService
    local Players = S(G, "Players")
    local UserInputService = S(G, "UserInputService")
    local TweenService = S(G, "TweenService")
    local RunService = S(G, "RunService")
    local StarterGui = S(G, "StarterGui")

    local Player = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- 3. Configuration Profiles
    local CONFIG = {
        TIMEOUT = 10,       -- Seconds before white screen activates
        FADE_TIME = 1.2,    -- Transition speed to white screen
        COLOR = Color3.fromRGB(255, 255, 255)
    }

    local State = {
        LastInput = os.time(),
        Active = false,
        LoopConnection = nil,
        RotateAngle = 0
    }

    -- 4. Environment Safe Parent Resolver
    local TargetParent = nil
    local successCore, errCore = pcall(function()
        local test = game:GetService("CoreGui").Name
        TargetParent = game:GetService("CoreGui")
    end)
    if not successCore or not TargetParent then
        TargetParent = Player:WaitForChild("PlayerGui")
    end

    -- 5. Fullscreen UI Assembly Initialization
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Universal_Screensaver_Core"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 2147483647 -- Highest possible 32-bit integer layer to override all heavy game UIs
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = TargetParent

    local Frame = Instance.new("Frame")
    Frame.Name = "Canvas"
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = CONFIG.COLOR
    Frame.BackgroundTransparency = 1
    Frame.Visible = false
    Frame.Parent = ScreenGui

    -- 6. Multi-Layer Anti-AFK Routine
    local function EngageAntiAfk(state)
        if state then
            if State.LoopConnection then return end
            
            State.LoopConnection = RunService.Heartbeat:Connect(function()
                if State.Active then
                    -- Camera Matrix Shifter
                    if Camera then
                        pcall(function()
                            State.RotateAngle = State.RotateAngle + 0.01
                            Camera.CFrame = Camera.CFrame * CFrame.Angles(0, math.sin(State.RotateAngle) * 0.0001, 0)
                        end)
                    end
                    
                    -- Virtual Input Emulation Hook
                    pcall(function()
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new(0, 0))
                    end)
                end
            end)
        else
            if State.LoopConnection then
                State.LoopConnection:Disconnect()
                State.LoopConnection = nil
            end
        end
    end

    -- 7. State Transition Logic
    local function ShowVisuals()
        if State.Active then return end
        State.Active = true
        Frame.Visible = true
        
        local ti = TweenInfo.new(CONFIG.FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(Frame, ti, {BackgroundTransparency = 0}):Play()
        
        EngageAntiAfk(true)
    end

    local function HideVisuals()
        if not State.Active then return end
        State.Active = false
        
        EngageAntiAfk(false)
        Frame.BackgroundTransparency = 1
        Frame.Visible = false
        State.LastInput = os.time()
    end

    -- 8. Hardware Input Listeners
    UserInputService.InputBegan:Connect(function() HideVisuals() end)
    UserInputService.TouchStarted:Connect(function() HideVisuals() end)

    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        Camera = workspace.CurrentCamera
    end)

    -- 9. Runtime Execution Watchdog Thread
    task.spawn(function()
        while true do
            task.wait(0.5)
            if State.Active and ScreenGui.DisplayOrder ~= 2147483647 then
                ScreenGui.DisplayOrder = 2147483647
            end
            
            if not State.Active and (os.time() - State.LastInput) >= CONFIG.TIMEOUT then
                ShowVisuals()
            end
        end
    end)

    -- 10. Success Execution Toast Notification
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "System Loaded",
            Text = "Universal Screensaver & Anti-AFK is active!",
            Duration = 5,
            Button1 = "OK"
        })
    end)
end)

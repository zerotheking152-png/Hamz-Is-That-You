local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local throwRemote = ReplicatedStorage:WaitForChild("Fishing_RemoteThrow")
local fishingFolder = ReplicatedStorage:WaitForChild("Fishing")
local toServer = fishingFolder:WaitForChild("ToServer")
local minigameStarted = toServer:WaitForChild("MinigameStarted")
local reelFinished = toServer:WaitForChild("ReelFinished")
local sellRemote = ReplicatedStorage:WaitForChild("Economy"):WaitForChild("ToServer"):WaitForChild("SellUnder")

local sessionID = nil
local oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if getnamecallmethod() == "FireServer" and self == throwRemote then
        local args = {...}
        if typeof(args[2]) == "string" and #args[2] > 20 then
            sessionID = args[2]
            print("✅ Session ID Captured: " .. sessionID)
        end
    end
    return oldNamecall(self, ...)
end))

getgenv().Blati = false
getgenv().ForceSecret = false
getgenv().InfiniteJump = false
getgenv().Noclip = false
getgenv().WalkSpeedValue = 16
getgenv().AutoSell = false
getgenv().SellCount = 10
getgenv().InstantMode = "Normal"

local fishCaught = 0
local humanoid = nil

local function getHumanoid()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        humanoid = player.Character.Humanoid
        return humanoid
    end
    return nil
end

player.CharacterAdded:Connect(function() task.wait(0.5) getHumanoid() end)
getHumanoid()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "HamzHub v2 🔥",
    LoadingTitle = "HamzHub Loading...",
    LoadingSubtitle = "Mancing Mode Activated",
    Theme = "Ocean",
    ToggleUIKeybind = "K",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("MAIN", 4483362458)
local PlayerTab = Window:CreateTab("PLAYER", 4483362458)
local TeleportTab = Window:CreateTab("TELEPORT", 4483362458)

MainTab:CreateLabel("🎣 MANCING MANUAL 1X DULU BARU NYALAIN BLATI!")

local instantLoop
local function startInstant()
    if instantLoop then return end
    instantLoop = task.spawn(function()
        while getgenv().Blati or getgenv().ForceSecret do
            if sessionID and humanoid then
                throwRemote:FireServer(0, sessionID)
                task.wait(0.00001)
                minigameStarted:FireServer(sessionID)
                task.wait(0.00001)

                local isSecret = getgenv().ForceSecret or (getgenv().InstantMode == "Secret")
                local successArgs = {
                    duration = math.random(7.5, 12.5),
                    result = "SUCCESS",
                    insideRatio = 0.8 + (math.random(3, 18) / 100),
                    catchType = isSecret and "SECRET" or "NORMAL",
                    isSecret = isSecret
                }
                reelFinished:FireServer(successArgs, sessionID)

                fishCaught = fishCaught + 1
                if getgenv().AutoSell and fishCaught >= getgenv().SellCount then
                    sellRemote:FireServer(800)
                    fishCaught = 0
                end
                task.wait(0.00001)
            else
                task.wait(0.1)
            end
        end
    end)
end

MainTab:CreateToggle({
    Name = "🔥 BLATI (Instant Fishing)",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().Blati = Value
        if Value then startInstant() end
        if not Value and not getgenv().ForceSecret then
            if instantLoop then task.cancel(instantLoop) instantLoop = nil end
        end
        if Value then
            ReplicatedStorage.FishUI.ToServer.ToggleFavorite:FireServer("bd4238ec-6bbc-4523-8c63-a17356e1f130")
            local tool = player.Backpack:FindFirstChildOfClass("Tool")
            if tool then tool.Parent = player.Character end
        end
    end
})

MainTab:CreateToggle({
    Name = "🌟 FORCE SECRET (100% Secret Fish)",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().ForceSecret = Value
        if Value then startInstant() end
        if not Value and not getgenv().Blati then
            if instantLoop then task.cancel(instantLoop) instantLoop = nil end
        end
        if Value then
            ReplicatedStorage.FishUI.ToServer.ToggleFavorite:FireServer("bd4238ec-6bbc-4523-8c63-a17356e1f130")
            local tool = player.Backpack:FindFirstChildOfClass("Tool")
            if tool then tool.Parent = player.Character end
        end
    end
})

MainTab:CreateDropdown({
    Name = "Instant Mode (kalau Blati nyala)",
    Options = {"Normal", "Secret"},
    CurrentOption = {"Secret"},
    Callback = function(opt) getgenv().InstantMode = opt[1] end
})

PlayerTab:CreateToggle({ Name = "Infinite Jump", Callback = function(v)
    getgenv().InfiniteJump = v
    if v then
        UserInputService.JumpRequest:Connect(function()
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end})

PlayerTab:CreateToggle({ Name = "Noclip", Callback = function(v)
    getgenv().Noclip = v
    if v then
        RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end})

PlayerTab:CreateInput({ Name = "WalkSpeed", CurrentValue = "16", Callback = function(txt)
    local val = tonumber(txt) or 16
    getgenv().WalkSpeedValue = val
    if humanoid then humanoid.WalkSpeed = val end
end})

PlayerTab:CreateInput({ Name = "Sell Every (ikan)", CurrentValue = "10", Callback = function(txt)
    getgenv().SellCount = tonumber(txt) or 10
end})

PlayerTab:CreateToggle({ Name = "AUTO SELL", Callback = function(v) getgenv().AutoSell = v end })

local tpSection = TeleportTab:CreateSection("📍 TELEPORT PULAU")
local islands = {
    ["Pulau Kinyis"] = CFrame.new(81.86, 1006.87, -818.23),
    ["Pulau Raja Ampat"] = CFrame.new(-1845.46, 1006.63, -1579.07),
    ["Pulau Wakatobi"] = CFrame.new(-1399.89, 1021.17, 1497.85),
    ["Pulau Bali"] = CFrame.new(989.35, 1034.92, 1607.39),
    ["Pulau Natuna"] = CFrame.new(2240.65, 995.99, -94.52),
    ["Pulau Banda"] = CFrame.new(-349.49, 1000.69, 178.11)
}

for name, cf in pairs(islands) do
    TeleportTab:CreateButton({
        Name = name,
        Callback = function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = cf
                sessionID = nil
                task.wait(0.5)
                local tool = player.Backpack:FindFirstChildOfClass("Tool")
                if tool then tool.Parent = player.Character end
            end
        end
    })
end

player.CharacterAdded:Connect(function() task.wait(1) if humanoid then humanoid.WalkSpeed = getgenv().WalkSpeedValue end end)

local VirtualUser = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

task.spawn(function()
    while true do
        if (getgenv().Blati or getgenv().ForceSecret) and player.Character then
            if not player.Character:FindFirstChildOfClass("Tool") then
                local tool = player.Backpack:FindFirstChildOfClass("Tool")
                if tool then tool.Parent = player.Character end
            end
        end
        task.wait(0.5)
    end
end)

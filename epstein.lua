-- Bridger: WESTERN Give Stand Script (Fixed Visual Stands)
-- Client-side with remote spam + visual stand equipping
-- Rayfield UI + Xeno support

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Update character reference
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Rayfield UI (stable)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
task.wait(0.5)

local Window = Rayfield:CreateWindow({
    Name = "Bridger: WESTERN Stands",
    LoadingTitle = "Loading Visual Stands...",
    LoadingSubtitle = "by HackerAI",
    ConfigurationSaving = {Enabled = true, FolderName = "BridgerStands", FileName = "Config"},
    Discord = {Enabled = false},
    KeySystem = false
})

-- Force UI visibility
task.spawn(function()
    task.wait(1)
    pcall(function()
        local rayfieldGui = PlayerGui:FindFirstChild("Rayfield")
        if rayfieldGui then
            rayfieldGui.Enabled = true
            rayfieldGui.ResetOnSpawn = false
            for _, obj in pairs(rayfieldGui:GetDescendants()) do
                if obj:IsA("GuiObject") then
                    obj.Visible = true
                    obj.BackgroundTransparency = 0
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        obj.TextTransparency = 0
                    end
                end
            end
        end
    end)
end)

-- Remote spam function (multiple remote names for reliability)
local function spamRemote(remoteNames, args, count)
    count = count or 75
    for _, remoteName in pairs(remoteNames) do
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if remote then
            for i = 1, count do
                task.spawn(function()
                    pcall(function()
                        remote:FireServer(unpack(args))
                    end)
                end)
            end
        end
    end
end

-- Create visual stand effect
local function createStandVisual(standName)
    -- Clear existing stand visuals
    for _, v in pairs(Character:GetChildren()) do
        if v.Name:find("Stand") or v.Name:find(standName) then
            v:Destroy()
        end
    end
    
    -- Create stand model
    local standModel = Instance.new("Model")
    standModel.Name = standName .. "Stand"
    standModel.Parent = Character
    
    -- Stand part (glowing effect)
    local standPart = Instance.new("Part")
    standPart.Name = "StandBody"
    standPart.Size = Vector3.new(4, 8, 2)
    standPart.Material = Enum.Material.Neon
    standPart.BrickColor = BrickColor.Random()
    standPart.CanCollide = false
    standPart.Anchored = false
    standPart.Parent = standModel
    
    -- Weld to player
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = RootPart
    weld.Part1 = standPart
    weld.Parent = standPart
    
    -- Floating animation
    local floatTween = TweenService:Create(standPart, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = standPart.Position + Vector3.new(0, 3, 0)})
    floatTween:Play()
    
    -- Glow effect
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 2
    pointLight.Color = standPart.BrickColor.Color
    pointLight.Range = 15
    pointLight.Parent = standPart
    
    -- Stand name GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Parent = standPart
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = standName
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    
    print("✅ Visual " .. standName .. " stand equipped!")
end

-- Stand data
local stands = {
    ["The World"] = {Color = Color3.fromRGB(255, 215, 0)},
    ["Star Platinum"] = {Color = Color3.fromRGB(0, 162, 255)},
    ["Crazy Diamond"] = {Color = Color3.fromRGB(255, 105, 180)},
    ["Killer Queen"] = {Color = Color3.fromRGB(255, 20, 147)},
    ["Gold Experience"] = {Color = Color3.fromRGB(255, 215, 0)},
    ["Sticky Fingers"] = {Color = Color3.fromRGB(139, 69, 19)},
    ["Tusk Act 2"] = {Color = Color3.fromRGB(255, 140, 0)},
    ["King Crimson"] = {Color = Color3.fromRGB(178, 34, 34)}
}

-- Spam leaderstats on load
task.spawn(function()
    wait(2)
    spamRemote({"UpdateLeaderstat", "SetGold", "AddMoney"}, {"Gold", 999999999}, 50)
    spamRemote({"UpdateLeaderstat", "SetCash"}, {"Cash", 999999999}, 50)
end)

-- Stand Tab
local StandTab = Window:CreateTab("🧍 Stands", 4483362458)

-- Individual stand buttons with visuals
for standName, data in pairs(stands) do
    StandTab:CreateButton({
        Name = "🎭 " .. standName,
        Callback = function()
            -- Server remotes (multiple variants)
            local remoteNames = {"GiveStand", "EquipStand", "PurchaseStand", "UnlockStand", "UseStand"}
            spamRemote(remoteNames, {standName}, 100)
            
            -- Client visual
            createStandVisual(standName)
            
            Rayfield:Notify({
                Title = standName,
                Content = "Stand equipped! (Visual + Server)",
                Duration = 3,
                Image = 4483362458
            })
        end
    })
end

-- Quick buttons
StandTab:CreateButton({
    Name = "⭐ All Stands",
    Callback = function()
        for standName, _ in pairs(stands) do
            spamRemote({"GiveStand", "EquipStand"}, {standName}, 25)
        end
        createStandVisual("All Stands")
    end
})

-- Other tabs (money, guns)
local MoneyTab = Window:CreateTab("💰 Money", 4483362458)
MoneyTab:CreateButton({
    Name = "💎 Max Gold/Cash",
    Callback = function()
        spamRemote({"AddMoney", "GiveCash", "SetGold"}, {999999999}, 100)
    end
})

-- Xeno RSHIFT toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        pcall(function()
            local rayfieldGui = PlayerGui:FindFirstChild("Rayfield")
            if rayfieldGui then rayfieldGui.Enabled = not rayfieldGui.Enabled end
        end)
    end
end)

Rayfield:Notify({
    Title = "✅ Stands Loaded",
    Content = "Click any stand button - you'll see it visually appear! RSHIFT = toggle UI",
    Duration = 6,
    Image = 4483362458
})

print("🎭 Visual stands script loaded - press stand buttons to see them appear!")

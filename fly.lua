-- UNIVERSAL HORSE FLY | IY Compatible | No Remote Guess
loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()

local player = game.Players.LocalPlayer
local RunSvc = game:GetService("RunService")
local WS = game:GetService("Workspace")

local flyingHorse = nil
local speed = 65
local enabled = false
local conn = nil

-- UNIVERSAL HORSE DETECT (Scans workspace every 2s)
spawn(function()
   while true do
      if enabled and not flyingHorse then
         -- Find ANY horse-like model
         for _, model in pairs(WS:GetChildren()) do
            if model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
               local name = model.Name:lower()
               if name:find("horse") or name:find("mount") or name:find(player.Name:lower()) then
                  flyingHorse = model.HumanoidRootPart
                  print("🐎 HORSE FOUND:", model.Name)
                  break
               end
            end
         end
      end
      task.wait(2)
   end
end)

-- SMOOTH HORSE CONTROL (Physics-based - NO CFrame spam)
local function toggle(enabled)
   enabled = enabled
   if enabled then
      -- Player mount prep
      if player.Character then
         player.Character.Humanoid.PlatformStand = true
         player.Character.Humanoid.Sit = true
      end
      
      conn = RunSvc.Heartbeat:Connect(function()
         if not enabled or not flyingHorse or not flyingHorse.Parent then return end
         
         local hrp = flyingHorse
         local hum = hrp.Parent:FindFirstChild("Humanoid")
         if not hum then return end
         
         -- Horse physics fly (server authoritative)
         local bv = hrp:FindFirstChild("HorseFlyBV") or Instance.new("BodyVelocity")
         bv.Name = "HorseFlyBV"
         bv.MaxForce = Vector3.new(4000,4000,4000)
         bv.Parent = hrp
         
         local cam = WS.CurrentCamera
         local move = Vector3.new()
         
         if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
         if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
         if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
         if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
         if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + cam.CFrame.UpVector end
         if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - cam.CFrame.UpVector end
         
         bv.Velocity = move.Unit * speed + Vector3.new(0, hrp.AssemblyLinearVelocity.Y * 0.9, 0)
         
         -- Mount player
         if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0,3,-2)
         end
      end)
      
   else
      if conn then conn:Disconnect(); conn = nil end
      if player.Character then
         player.Character.Humanoid.PlatformStand = false
         player.Character.Humanoid.Sit = false
      end
      if flyingHorse and flyingHorse:FindFirstChild("HorseFlyBV") then
         flyingHorse.HorseFlyBV:Destroy()
      end
      flyingHorse = nil
   end
end

-- TOGGLE (F1 key)
game:GetService("UserInputService").InputBegan:Connect(function(key)
   if key.KeyCode == Enum.KeyCode.F1 then
      toggle(not enabled)
      print("Horse Fly:", enabled and "OFF" or "ON")
   end
end)

print("🐎 Universal Horse Fly LOADED | F1 Toggle | Auto-detects horse")
print("💡 PRO TIP: Use RemoteSpy + normal H summon → paste remotes for perfect fix")

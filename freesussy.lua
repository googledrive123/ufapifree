
--// Ultimate Football: Boost Power and Hitbox Script

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- CONFIGURATION
local BOOST_FORCE_Y = 95
local BALL_DETECTION_RADIUS = 15
local COOLDOWN = 8

-- STATE
local CanBoost = true
local BoostEnabled = true
local TradeMode = false

-- FPS BOOST
--Local function applyFpsBoost()
	--Lighting.GlobalShadows = false
	--Lighting.FogEnd = 1000000
	--Lighting.FogStart = 0
	--Lighting.Brightness = 1
	--Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)

	--for _, v in pairs(Workspace:GetDescendants()) do
		--if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
			--v.Enabled = false
		--elseif v:IsA("Texture") and v.Transparency < 1 then
			--v.Transparency = 1
		--end
	--end
--end




local function getFootball()
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name:lower():find("ball") and not obj.Anchored then
            warn(obj.Name)
			return obj
		end
	end
	return nil
end


local function applyBoost(rootPart)
	local bv = Instance.new("BodyVelocity")
	bv.Velocity = Vector3.new(0, BOOST_FORCE_Y, 0)
	bv.MaxForce = Vector3.new(0, math.huge, 0)
	bv.P = 5000
	bv.Parent = rootPart
	game:GetService("Debris"):AddItem(bv, 0.2)
end


local function setup(character)
	local root = character:WaitForChild("HumanoidRootPart")
	root.Touched:Connect(function(hit)
		if not BoostEnabled or not CanBoost then return end
		if root.Velocity.Y >= -2 then return end
		local otherChar = hit:FindFirstAncestorWhichIsA("Model")
		if otherChar and otherChar ~= character and otherChar:FindFirstChild("Humanoid") then
			if TradeMode then
				CanBoost = false
				applyBoost(root)
				task.delay(COOLDOWN, function() CanBoost = true end)
			else
				local football = getFootball()
				if football and (football.Position - root.Position).Magnitude <= BALL_DETECTION_RADIUS then
					CanBoost = false
					applyBoost(root)
					task.delay(COOLDOWN, function() CanBoost = true end)
				end
			end
		end
	end)
end


UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.ButtonL2 then
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			local football = getFootball()
			local ballTooClose = football and ((football.Position - root.Position).Magnitude <= 5)
			if not ballTooClose then
				TradeMode = not TradeMode
				print("Trade Mode toggled via controller:", TradeMode)
				local gui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("JumpBoostToggleGui")
				if gui then
					local btn = gui:FindFirstChild("TradeModeButton")
					if btn then
						btn.Text = TradeMode and "Trade Mode: ON" or "Trade Mode: OFF"
						btn.BackgroundColor3 = TradeMode and Color3.fromRGB(50,120,50) or Color3.fromRGB(80,80,80)
					end
				end
			end
		end
	end
end)




getgenv().HBE = false -- HBE Variable, use this to control whether the hitboxes are active or not.
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function GetCharParent()
    local charParent
    repeat wait() until LocalPlayer.Character
    for _, char in pairs(workspace:GetDescendants()) do
        if string.find(char.Name, LocalPlayer.Name) and char:FindFirstChild("Humanoid") then
            charParent = char.Parent
            break
        end
    end
    return charParent
end


-- pcall to avoid the script breaking on low level executors (e.g. Solara or any Xeno paste)
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__index
    mt.__index = function(Self, Key)
        if tostring(Self) == "HumanoidRootPart" and tostring(Key) == "Size" then
            return Vector3.new(2,2,1)
        end
        return old(Self, Key)
    end
    setreadonly(mt, true)
end)


local CHAR_PARENT = GetCharParent()
local HITBOX_SIZE = 3.5 -- Default size. You can let the user choose with a slider. e.g. HITBOX_SIZE = Vector3.new(Value, Value, Value)
local HITBOX_COLOUR = Color3.fromRGB(255,0,0) -- Default colour (RGB)


local function AssignHitboxes(player)
    if player == LocalPlayer then return end

    local hitbox_connection;
    hitbox_connection = game:GetService("RunService").RenderStepped:Connect(function()
        local char = CHAR_PARENT:FindFirstChild(player.Name)
        if getgenv().HBE then
            if char and char:FindFirstChild("HumanoidRootPart") and (char.HumanoidRootPart.Size ~= HITBOX_SIZE or char.HumanoidRootPart.Color ~= HITBOX_COLOUR) then
                char.HumanoidRootPart.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
                char.HumanoidRootPart.Color = HITBOX_COLOUR
                char.HumanoidRootPart.CanCollide = true
                char.HumanoidRootPart.Transparency = 1
            end
        else
            hitbox_connection:Disconnect()
            char.HumanoidRootPart.Size = Vector3.new(2,2,1)
            char.HumanoidRootPart.Transparency = 1
        end
    end)
end


for _, player in ipairs(Players:GetPlayers()) do
    AssignHitboxes(player)
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Universe Football Script",
    LoadingTitle = "UF WR BOOST SCRIPT",
    LoadingSubtitle = "The Best UF Script for the Boost Made",
    Theme = "Amethyst",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "",
        FileName = ""
    },
    Discord = {
        Enabled = true,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "Universe Football Script",
        Subtitle = "Key System", 
        Note = "Get Key from owner",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"OSUO19BaHEBC8vOZc76vklGfBZEIL8AH"}

    },
})

local Tab1 = Window:CreateTab("Hitbox", 4483362458)
local Toggle = Tab1:CreateToggle({
    Name = "Hitbox",
    CurrentValue = false,
    Flag = "X",
    Callback = function(Value)
        getgenv().HBE = Value
        if Value then
            for i, v in ipairs(Players:GetPlayers()) do
                AssignHitboxes(v)
            end
        end
    end,

})

local Slider = Tab1:CreateSlider({
   Name = "Hitbox",
   Range = {0, 10},
   Increment = 0.1,
   Suffix = "Hitbox Size",
   CurrentValue = 3.5,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        HITBOX_SIZE = Value

   end,
})

local Tab2 = Window:CreateTab("Boost Power", 4483362458)
local Toggle = Tab2:CreateToggle({
    Name = "Boost",
    CurrentValue = false,
    Flag = "BoostPowerOne",
    Callback = function(Value)
        BoostEnabled = Value
        
    end,

})

local Toggle = Tab2:CreateToggle({
    Name = "Boost Without Jump",
    CurrentValue = false,
    Flag = "BoostPowerTwo",
    Callback = function(Value)
       TradeMode = Value
        
    end,

})

local Slider = Tab2:CreateSlider({
   Name = "Boost Power",
   Range = {0, 500}, --hlll
   Increment = 1,
   Suffix = "Boost Power",
   CurrentValue = 80,
   Flag = "Slider2", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
       BOOST_FORCE_Y = Value
   end
})

Players.PlayerAdded:Connect(function(player)
    if getgenv().HBE then
        AssignHitboxes(player)
    end
end)
-- PULL VECTOR FEATURE SETUP
local PULL_ENABLED = false
local PULL_STRENGTH = 50 -- default strength

local Tab0 = Window:CreateTab("Pull Vector", 4483362458)

-- Toggle Pull Vector
local PullToggle = Tab0:CreateToggle({
    Name = "Enable Pull Vector",
    CurrentValue = false,
    Flag = "PullVectorToggle",
    Callback = function(Value)
        PULL_ENABLED = Value
    end,
})

-- Slider for strength
local PullSlider = Tab0:CreateSlider({
   Name = "Pull Strength",
   Range = {10, 500},
   Increment = 1,
   Suffix = "Strength",
   CurrentValue = 50,
   Flag = "PullVectorSlider",
   Callback = function(Value)
       PULL_STRENGTH = Value
   end
})

-- Function to pull player to football
local function pullToBall()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local football = getFootball()
    if PULL_ENABLED and root and football then
        local direction = (football.Position - root.Position).Unit
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = direction * PULL_STRENGTH
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.P = 5000
        bv.Parent = root
        game:GetService("Debris"):AddItem(bv, 0.3)
    end
end

-- Bind Left Mouse Button to pull
Mouse.Button1Down:Connect(function()
    pullToBall()
end)

local TELEPORT_ENABLED = false

-- Function to teleport ball to hand
local function teleportBallToHand()
    local char = LocalPlayer.Character
    if not char then return end
    local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("HumanoidRootPart")
    local football = getFootball()

    if football and hand then
        football.CFrame = hand.CFrame
        football.Velocity = Vector3.zero
        football.RotVelocity = Vector3.zero
        football.Anchored = false
        print("Ball teleported to hand!")
    else
        warn("No football or hand found!")
    end
end

-- Bind Left Click only when toggle is on
Mouse.Button1Down:Connect(function()
    if not TELEPORT_ENABLED then return end
    teleportBallToHand()
end)

--====================================================--
-- UI TAB + TOGGLE SETUP
--====================================================--

-- Add new tab for teleport control (or attach to Pull Vector tab if you prefer)
local Tab3 = Window:CreateTab("Teleport", 4483362458)

-- Toggle for teleport feature
local TeleportToggle = Tab3:CreateToggle({
    Name = "Teleport Ball To Hand (LMB)",
    CurrentValue = false,
    Flag = "TeleportBallToggle",
    Callback = function(Value)
        TELEPORT_ENABLED = Value
        if TELEPORT_ENABLED then
            print("Teleport Ball feature enabled")
        else
            print("Teleport Ball feature disabled")
        end
    end,
})

-- Optional button for instant manual teleport (in case you don’t want to click)
local TeleportButton = Tab3:CreateButton({
    Name = "Teleport Ball To Hand (Manual)",
    Callback = function()
        teleportBallToHand()
    end,
})

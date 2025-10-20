
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
--====================================================--
-- PULL VECTOR SECTION (predictive pull version)
--====================================================--

local PULL_ENABLED = false
local PULL_STRENGTH = 50
local pulling = false

-- UI TAB SETUP
local Tab0 = Window:CreateTab("Pull Vector", 4483362458)

-- Toggle for enabling/disabling pull feature
local PullToggle = Tab0:CreateToggle({
    Name = "Enable Pull Vector",
    CurrentValue = false,
    Flag = "PullVectorToggle",
    Callback = function(Value)
        PULL_ENABLED = Value
    end,
})

-- Slider to adjust pull strength (0–100)
local PullSlider = Tab0:CreateSlider({
   Name = "Pull Strength",
   Range = {0, 100},
   Increment = 1,
   Suffix = "Strength",
   CurrentValue = 50,
   Flag = "PullVectorSlider",
   Callback = function(Value)
       PULL_STRENGTH = Value
   end
})

-- Helper function to get the player's root part
local function getRoot()
	local char = LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

-- Main pull function (predictive)
local function startPull()
	if pulling or not PULL_ENABLED then return end
	pulling = true

	task.spawn(function()
		while pulling and PULL_ENABLED do
			local root = getRoot()
			local football = getFootball()
			if root and football then
				-- Predictive position based on ball velocity
				local predictionTime = 0.15 -- seconds ahead
				local predictedPos = football.Position + football.Velocity * predictionTime

				local dir = predictedPos - root.Position
				local dist = dir.Magnitude
				if dist > 1 then -- stop when close
					dir = dir.Unit
					root.Velocity = dir * PULL_STRENGTH
				else
					root.Velocity = Vector3.zero
				end
			end
			task.wait()
		end
	end)
end

local function stopPull()
	pulling = false
end

-- Mouse input
Mouse.Button1Down:Connect(function()
	if PULL_ENABLED then
		startPull()
	end
end)

Mouse.Button1Up:Connect(function()
	stopPull()
end)

-- Controller input (Right Bumper)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonR1 then
		if PULL_ENABLED then
			startPull()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonR1 then
		stopPull()
	end
end)


-- --====================================================--
-- -- MOBILE SUPPORT
-- --====================================================--
-- if UserInputService.TouchEnabled then
-- 	local screenGui = Instance.new("ScreenGui")
-- 	screenGui.Name = "PullTouchUI"
-- 	screenGui.ResetOnSpawn = false
-- 	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 	local pullButton = Instance.new("ImageButton")
-- 	pullButton.Size = UDim2.new(0, 100, 0, 100)
-- 	pullButton.Position = UDim2.new(1, -120, 1, -140)
-- 	pullButton.BackgroundTransparency = 0.4
-- 	pullButton.BackgroundColor3 = Color3.fromRGB(50, 50, 120)
-- 	pullButton.Image = "rbxassetid://3926305904"
-- 	pullButton.ImageRectOffset = Vector2.new(4, 204)
-- 	pullButton.ImageRectSize = Vector2.new(36, 36)
-- 	pullButton.Parent = screenGui

-- 	pullButton.InputBegan:Connect(function(input)
-- 		if input.UserInputType == Enum.UserInputType.Touch and PULL_ENABLED then
-- 			startPull()
-- 		end
-- 	end)

-- 	pullButton.InputEnded:Connect(function(input)
-- 		if input.UserInputType == Enum.UserInputType.Touch then
-- 			stopPull()
-- 		end
-- 	end)
-- end

--====================================================--
-- REACH TAB SECTION
--====================================================--

local REACH_ENABLED = false
local REACH_SIZE = 5       -- default radius
local REACH_TRANSP = 0.2   -- default transparency

-- Create Reach Tab
local TabReach = Window:CreateTab("Reach", 4483362458)

-- Toggle to enable/disable reach
local ReachToggle = TabReach:CreateToggle({
    Name = "Enable Reach",
    CurrentValue = false,
    Flag = "ReachToggle",
    Callback = function(Value)
        REACH_ENABLED = Value
        if ReachPart then
            ReachPart.Visible = Value
        end
    end
})

-- Slider to change reach size
local ReachSizeSlider = TabReach:CreateSlider({
    Name = "Reach Size",
    Range = {1, 15},
    Increment = 0.1,
    Suffix = "Studs",
    CurrentValue = REACH_SIZE,
    Flag = "ReachSizeSlider",
    Callback = function(Value)
        REACH_SIZE = Value
        if ReachPart then
            ReachPart.Size = Vector3.new(Value, Value, Value)
        end
    end
})

-- Slider to change reach transparency
local ReachTransSlider = TabReach:CreateSlider({
    Name = "Reach Transparency",
    Range = {0, 1},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = REACH_TRANSP,
    Flag = "ReachTransSlider",
    Callback = function(Value)
        REACH_TRANSP = Value
        if ReachPart then
            ReachPart.Transparency = Value
        end
    end
})

-- Create the visual Reach Part
local ReachPart
local function setupReach()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Create a semi-transparent sphere
    ReachPart = Instance.new("Part")
    ReachPart.Shape = Enum.PartType.Ball
    ReachPart.Anchored = true
    ReachPart.CanCollide = false
    ReachPart.Material = Enum.Material.Neon
    ReachPart.Color = Color3.fromRGB(0, 255, 0)
    ReachPart.Transparency = REACH_TRANSP
    ReachPart.Size = Vector3.new(REACH_SIZE, REACH_SIZE, REACH_SIZE)
    ReachPart.Parent = workspace
    ReachPart.Visible = REACH_ENABLED

    -- Update position each frame
    game:GetService("RunService").RenderStepped:Connect(function()
        if ReachPart and root then
            ReachPart.Position = root.Position
            ReachPart.Size = Vector3.new(REACH_SIZE, REACH_SIZE, REACH_SIZE)
            ReachPart.Transparency = REACH_TRANSP
        end
    end)
end

-- Setup reach when character spawns
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5) -- small delay to ensure HumanoidRootPart exists
    setupReach()
end)

-- If character already exists
if LocalPlayer.Character then
    task.wait(0.5)
    setupReach()
end

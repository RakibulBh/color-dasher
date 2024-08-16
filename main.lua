local map = game.Workspace.Map
local lobby = game.Workspace.Lobby
local mapSpawns = map:WaitForChild("Spawns"):GetChildren()	
local lobbySpawns = lobby:WaitForChild("Spawns"):GetChildren()
local Status = game.ReplicatedStorage.Status
local plates = map:WaitForChild("Plates"):GetChildren()
local colour_display = map:FindFirstChild("ChosenColour")

local INTERMISSION_TIME = 5
local COLOURS_NUM = 10

local playing_players = {}

local colours = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(0,255, 0),
	Color3.fromRGB(0, 0,255),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(0, 255, 255)
}

local function teleportPlayers(spawns, isGame)
	for _, player in ipairs(game.Players:GetPlayers()) do
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local randomSpawn = spawns[math.random(1, #spawns)]
			if isGame then
				playing_players[player.UserId] = player
				local humanoid = character:WaitForChild("Humanoid")
				print(playing_players)
				humanoid.Died:Connect(function()
					if playing_players[player.UserId] then
						playing_players[player.UserId] = nil
						print(playing_players)
					end
				end)
			else
				if playing_players[player.UserId] then
					playing_players[player.UserId] = nil
				end
			end
			character.HumanoidRootPart.CFrame = randomSpawn.CFrame
		end
	end
end

local function setPlateColours() 
	for _, plate in ipairs(plates) do
		local randomColour = colours[math.random(1, #colours)]
		plate.Color = randomColour
	end
end

local function main_game()
	-- Game
	for i = COLOURS_NUM, 0, -1 do
		setPlateColours()
		
		
		local chosen_colour = colours[math.random(1, #colours)]
		colour_display.Color = chosen_colour


		task.wait(2)
		
		for _, plate in ipairs(plates) do
			if not (plate.Color == chosen_colour) then
				plate.CanCollide = false
				plate.CanTouch = false
				plate.Transparency = 1  -- Make non-matching plates invisible
			end
		end
		task.wait(2) 

		for _, plate in ipairs(plates) do
			if not (plate.Color == chosen_colour) then
				plate.CanCollide = true
				plate.CanTouch = true
				plate.Transparency = 0  -- Make non-matching plates visible again
			end
		end
	end
end

while true do
	-- Intermission
	for i = INTERMISSION_TIME, 0, -1 do
		Status.Value = "Intermission: " .. i
		task.wait(1)
	end

	-- Teleport players to map
	teleportPlayers(mapSpawns, true)
	
	Status.Value = "Get ready for the tiles to change colour!"
	
	task.wait(3)
	
	main_game()
	
	wait(2)
	
	Status.Value = "Well done to the winners!"
	
	
	for _, plate in ipairs(plates) do
		plate.Color = Color3.new(163, 162, 165)
	end

	-- Teleport players back to lobby
	teleportPlayers(lobbySpawns, false)
end




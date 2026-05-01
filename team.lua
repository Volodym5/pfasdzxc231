-- Phantom Forces - Shared Team Detection Module
-- Watches Player.TeamColor instead of scanning parts

local Players = game:GetService("Players")
local Workspace = workspace

local TeamModule = {}
local playerTeams = {}

local function findTeamFolderForPlayer(player)
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return nil end
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local charPos = root.Position

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end
        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end
            local center = Vector3.zero
            local count = 0
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    center = center + part.Position
                    count = count + 1
                end
            end
            if count == 0 then continue end
            center = center / count
            if (center - charPos).Magnitude < 10 then
                return teamFolder
            end
        end
    end
    return nil
end

local function onTeamColorChanged(player)
    local teamColor = player.TeamColor
    if not teamColor or teamColor == BrickColor.new("White") then
        playerTeams[player] = nil
        return
    end
    local folder = findTeamFolderForPlayer(player)
    playerTeams[player] = {
        colorNumber = teamColor.Number,
        folder = folder
    }
end

local function watchPlayer(player)
    if player.TeamColor and player.TeamColor ~= BrickColor.new("White") then
        onTeamColorChanged(player)
    end
    player:GetPropertyChangedSignal("TeamColor"):Connect(function()
        onTeamColorChanged(player)
    end)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        onTeamColorChanged(player)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    watchPlayer(player)
end

Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(function(player)
    playerTeams[player] = nil
end)

function TeamModule.GetPlayerTeam(player)
    return playerTeams[player]
end

function TeamModule.GetMyTeamFolder()
    local data = playerTeams[Players.LocalPlayer]
    return data and data.folder or nil
end

function TeamModule.GetMyTeamColorNumber()
    local data = playerTeams[Players.LocalPlayer]
    return data and data.colorNumber or nil
end

function TeamModule.IsSameTeam(player1, player2)
    local d1 = playerTeams[player1]
    local d2 = playerTeams[player2]
    if not d1 or not d2 then return false end
    return d1.colorNumber == d2.colorNumber
end

function TeamModule.IsEnemy(player)
    return not TeamModule.IsSameTeam(player, Players.LocalPlayer)
end

function TeamModule.GetTeamFolders()
    local myData = playerTeams[Players.LocalPlayer]
    if not myData or not myData.folder then return nil, nil end
    local myFolder = myData.folder
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return myFolder, nil end
    local enemyFolder = nil
    for _, f in ipairs(playersFolder:GetChildren()) do
        if f:IsA("Folder") and f ~= myFolder then
            enemyFolder = f
            break
        end
    end
    return myFolder, enemyFolder
end

function TeamModule.RefreshPlayer(player)
    onTeamColorChanged(player)
end

return TeamModule

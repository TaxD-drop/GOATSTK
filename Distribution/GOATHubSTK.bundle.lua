-- GENERATED FILE. Edit Config.lua/GOATHubSTKClient and run tools/build_bundle.py.
-- Runtime source of truth for executor deployment.

local __config = (function()
    -- Fonte de configuracao do GOATHubSTK.
    -- Preencha os IDs e regenere o bundle com: python3 tools/build_bundle.py

    return table.freeze({
        GAME_ID = 1489026993,
        PLACE_IDS = table.freeze({
            4580204640,
        }),

        UI = table.freeze({
            TITLE = "GOAT Hub — STK",
            PADDING = 12,
            DESKTOP_WIDTH = 380,
            DESKTOP_HEIGHT = 600,
            COMPACT_WIDTH = 350,
            COMPACT_BREAKPOINT = 520,
            NARROW_BREAKPOINT = 620,
        }),

        DISTANCES = table.freeze({
            KILLER_EVADE = 45,
            KILL_OFFSET_UP = 2.5,
            REVIVE_FOLLOW = 3,
            MIN_SAFE_TRAVEL = 24,
        }),

        TIMING = table.freeze({
            ESCAPE_POLL = 0.15,
            ESCAPE_DRAG_STEP = 0.06,
            KNIFE_SLASH = 0.31,
            REVIVE_FOLLOW = 0.10,
            LOOT_POLL = 0.20,
            LOOT_TOUCH = 0.16,
            LOOT_RETRY = 3.25,
            EVADE_POLL = 0.08,
            EVADE_COOLDOWN = 1.50,
        }),
    })
end)()

local function __validId(value)
    return typeof(value) == "number" and value > 0 and value % 1 == 0
end

if not __validId(__config.GAME_ID) then
    warn("[GOATHubSTK] Preencha GAME_ID em Config.lua e regenere o bundle.")
    return
end
if game.GameId ~= __config.GAME_ID then
    return
end

local __hasConfiguredPlace = false
local __placeAllowed = false
for _, placeId in ipairs(__config.PLACE_IDS) do
    if __validId(placeId) then
        __hasConfiguredPlace = true
        if game.PlaceId == placeId then
            __placeAllowed = true
        end
    end
end
if not __hasConfiguredPlace then
    warn("[GOATHubSTK] Preencha PLACE_IDS em Config.lua e regenere o bundle.")
    return
end
if not __placeAllowed then
    return
end

local __factories = {}
local __cache = { Config = __config }
local __require

__factories["Core/MovementCoordinator"] = function()
    local Runtime = __require("Core/Runtime")

    local MovementCoordinator = {}
    MovementCoordinator.__index = MovementCoordinator

    function MovementCoordinator.new()
        return setmetatable({
            destroyed = false,
            owner = nil,
            priority = -math.huge,
            lockUntil = 0,
            token = 0,
        }, MovementCoordinator)
    end

    function MovementCoordinator:_expired()
        return self.owner == nil or os.clock() >= self.lockUntil
    end

    function MovementCoordinator:acquire(owner, priority, holdSeconds)
        if self.destroyed then
            return nil
        end

        if not self:_expired() and self.owner ~= owner and priority < self.priority then
            return nil
        end

        self.token += 1
        self.owner = owner
        self.priority = priority
        self.lockUntil = os.clock() + math.max(holdSeconds or 0, 0)
        return self.token
    end

    function MovementCoordinator:isOwner(owner, token)
        return not self.destroyed and self.owner == owner and self.token == token
    end

    function MovementCoordinator:move(owner, priority, destination, holdSeconds)
        local token = self:acquire(owner, priority, holdSeconds)
        if not token then
            return false, nil
        end

        local character = Runtime.getCharacter()
        local root = Runtime.getRoot()
        if not character or not root then
            self:release(owner, token)
            return false, nil
        end

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        character:PivotTo(destination)
        return true, token
    end

    function MovementCoordinator:release(owner, token)
        if self.owner ~= owner or (token ~= nil and self.token ~= token) then
            return
        end
        self.owner = nil
        self.priority = -math.huge
        self.lockUntil = 0
    end

    function MovementCoordinator:stopOwner(owner)
        if self.owner == owner then
            self:release(owner)
        end
    end

    function MovementCoordinator:Destroy()
        self.destroyed = true
        self.owner = nil
        self.priority = -math.huge
        self.lockUntil = 0
        self.token += 1
    end

    return MovementCoordinator
end

__factories["Core/Runtime"] = function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")

    local Runtime = {}

    Runtime.Players = Players
    Runtime.Workspace = Workspace
    Runtime.LocalPlayer = Players.LocalPlayer

    function Runtime.getCharacter(player)
        player = player or Runtime.LocalPlayer
        local character = player and player.Character
        if character and character.Parent then
            return character
        end
        return nil
    end

    function Runtime.getRoot(player)
        local character = Runtime.getCharacter(player)
        if not character then
            return nil
        end
        return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    end

    function Runtime.getHumanoid(player)
        local character = Runtime.getCharacter(player)
        return character and character:FindFirstChildOfClass("Humanoid") or nil
    end

    function Runtime.isAlive(player)
        local humanoid = Runtime.getHumanoid(player)
        return humanoid ~= nil and humanoid.Health > 0 and Runtime.getRoot(player) ~= nil
    end

    function Runtime.getTeamName(player)
        player = player or Runtime.LocalPlayer
        if not player then
            return nil
        end

        local teamID = player:GetAttribute("TeamID")
        if typeof(teamID) == "string" and teamID ~= "" then
            return teamID
        end

        return player.Team and player.Team.Name or nil
    end

    function Runtime.isSurvivor(player)
        return Runtime.getTeamName(player) == "Survivor"
    end

    function Runtime.isKiller(player)
        return Runtime.getTeamName(player) == "Killer"
    end

    function Runtime.isDowned(player)
        player = player or Runtime.LocalPlayer
        return player ~= nil and player:GetAttribute("Downed") == true
    end

    function Runtime.isEscaped(player)
        player = player or Runtime.LocalPlayer
        return player ~= nil and player:GetAttribute("Escaped") == true
    end

    function Runtime.getCurrentMap()
        local mapName = Workspace:GetAttribute("Map")
        if typeof(mapName) ~= "string" or mapName == "" then
            return nil
        end
        return Workspace:FindFirstChild(mapName)
    end

    function Runtime.distanceBetween(firstPlayer, secondPlayer)
        local firstRoot = Runtime.getRoot(firstPlayer)
        local secondRoot = Runtime.getRoot(secondPlayer)
        if not firstRoot or not secondRoot then
            return math.huge
        end
        return (firstRoot.Position - secondRoot.Position).Magnitude
    end

    function Runtime.getPlayersOnTeam(teamName)
        local result = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if Runtime.getTeamName(player) == teamName then
                table.insert(result, player)
            end
        end
        return result
    end

    function Runtime.disconnect(connection)
        if connection then
            connection:Disconnect()
        end
    end

    return Runtime
end

__factories["Features/AutoEscape"] = function()
    local CollectionService = game:GetService("CollectionService")
    local Workspace = game:GetService("Workspace")

    local Config = __require("Config")
    local Runtime = __require("Core/Runtime")

    local AutoEscape = {}
    AutoEscape.__index = AutoEscape

    local OWNER = "AutoEscape"
    local PRIORITY = 100

    local function touch(root, trigger)
        if typeof(firetouchinterest) == "function" then
            pcall(firetouchinterest, root, trigger, 0)
            task.wait()
            pcall(firetouchinterest, root, trigger, 1)
        end
    end

    function AutoEscape.new(movement, mapProvider, onStatus)
        return setmetatable({
            movement = movement,
            mapProvider = mapProvider,
            onStatus = onStatus or function() end,
            enabled = false,
            generation = 0,
            escapedCycle = nil,
            connections = {},
        }, AutoEscape)
    end

    function AutoEscape:_cycleKey()
        return tostring(Workspace:GetAttribute("Map")) .. ":" .. tostring(Workspace:GetAttribute("ExitsOpen"))
    end

    function AutoEscape:_tryEscape()
        if not self.enabled or not Runtime.isSurvivor() or Runtime.isDowned() or Runtime.isEscaped() then
            return false
        end
        if Workspace:GetAttribute("ExitsOpen") ~= true then
            return false
        end

        local cycle = self:_cycleKey()
        if self.escapedCycle == cycle then
            return false
        end

        local selected = nil
        local root = Runtime.getRoot()
        if not root then
            return false
        end

        for _, exit in ipairs(self.mapProvider:getExits()) do
            if exit.open then
                if not selected or (exit.trigger.Position - root.Position).Magnitude < (selected.trigger.Position - root.Position).Magnitude then
                    selected = exit
                end
            end
        end
        if not selected then
            return false
        end

        local destination = selected.trigger.CFrame + Vector3.new(0, 2, 0)
        local moved, token = self.movement:move(OWNER, PRIORITY, destination, 2)
        if not moved then
            return false
        end

        self.onStatus("Auto Escape: atravessando o portao")
        touch(root, selected.trigger)
        task.wait(0.10)

        local base = selected.trigger.CFrame + Vector3.new(0, 2, 0)
        for _, direction in ipairs({ 1, -1 }) do
            for step = 1, 6 do
                if not self.enabled or not self.movement:isOwner(OWNER, token) or Runtime.isEscaped() then
                    break
                end
                local character = Runtime.getCharacter()
                root = Runtime.getRoot()
                if not character or not root then
                    break
                end
                character:PivotTo(base + selected.trigger.CFrame.LookVector * (direction * step * 1.35))
                touch(root, selected.trigger)
                task.wait(Config.TIMING.ESCAPE_DRAG_STEP)
            end
            if Runtime.isEscaped() then
                break
            end
        end

        self.movement:release(OWNER, token)
        if Runtime.isEscaped() or not Runtime.isSurvivor() then
            self.escapedCycle = cycle
            self.onStatus("Auto Escape: fuga confirmada")
            return true
        end

        self.onStatus("Auto Escape: aguardando confirmacao do servidor")
        return false
    end

    function AutoEscape:_loop(generation)
        while self.enabled and self.generation == generation do
            self:_tryEscape()
            task.wait(Config.TIMING.ESCAPE_POLL)
        end
    end

    function AutoEscape:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then
            return
        end

        self.enabled = enabled
        self.generation += 1
        self.escapedCycle = nil
        if enabled then
            local generation = self.generation
            task.spawn(function()
                self:_loop(generation)
            end)
        else
            self.movement:stopOwner(OWNER)
            self.onStatus("Auto Escape: OFF")
        end
    end

    function AutoEscape:stop()
        self:setEnabled(false)
    end

    function AutoEscape:Destroy()
        self:stop()
        for _, connection in ipairs(self.connections) do
            connection:Disconnect()
        end
        table.clear(self.connections)
    end

    return AutoEscape
end

__factories["Features/AutoEvade"] = function()
    local Config = __require("Config")
    local Runtime = __require("Core/Runtime")

    local AutoEvade = {}
    AutoEvade.__index = AutoEvade

    local OWNER = "AutoEvade"
    local PRIORITY = 90

    function AutoEvade.new(movement, mapProvider, onStatus)
        return setmetatable({
            movement = movement,
            mapProvider = mapProvider,
            onStatus = onStatus or function() end,
            enabled = false,
            generation = 0,
            distance = Config.DISTANCES.KILLER_EVADE,
            nextEvade = 0,
        }, AutoEvade)
    end

    function AutoEvade:setDistance(distance)
        self.distance = math.clamp(tonumber(distance) or Config.DISTANCES.KILLER_EVADE, 15, 120)
    end

    function AutoEvade:_killerRoots()
        local roots = {}
        local nearestPlayer = nil
        local nearestDistance = math.huge
        local localRoot = Runtime.getRoot()
        if not localRoot then
            return roots, nearestPlayer, nearestDistance
        end

        for _, player in ipairs(Runtime.Players:GetPlayers()) do
            if Runtime.isKiller(player) and Runtime.isAlive(player) then
                local root = Runtime.getRoot(player)
                if root then
                    table.insert(roots, root)
                    local distance = (root.Position - localRoot.Position).Magnitude
                    if distance < nearestDistance then
                        nearestPlayer = player
                        nearestDistance = distance
                    end
                end
            end
        end
        return roots, nearestPlayer, nearestDistance
    end

    function AutoEvade:_tryEvade()
        if not Runtime.isSurvivor() or not Runtime.isAlive() or Runtime.isDowned() or Runtime.isEscaped() then
            return false
        end
        if os.clock() < self.nextEvade then
            return false
        end

        local localRoot = Runtime.getRoot()
        local killerRoots, killer, nearestDistance = self:_killerRoots()
        if not localRoot or not killer or nearestDistance > self.distance then
            return false
        end

        local destination = self.mapProvider:findSafeCFrame(
            killerRoots,
            localRoot.Position,
            Config.DISTANCES.MIN_SAFE_TRAVEL
        )
        if not destination then
            self.nextEvade = os.clock() + 0.5
            self.onStatus("Auto Fugir: nenhuma superficie segura encontrada no mapa")
            return false
        end

        local moved = self.movement:move(OWNER, PRIORITY, destination, Config.TIMING.EVADE_COOLDOWN)
        if moved then
            self.nextEvade = os.clock() + Config.TIMING.EVADE_COOLDOWN
            self.onStatus(string.format("Auto Fugir: %s estava a %.1f studs", killer.Name, nearestDistance))
            return true
        end
        return false
    end

    function AutoEvade:_loop(generation)
        while self.enabled and self.generation == generation do
            self:_tryEvade()
            task.wait(Config.TIMING.EVADE_POLL)
        end
    end

    function AutoEvade:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then
            return
        end
        self.enabled = enabled
        self.generation += 1
        self.nextEvade = 0
        if enabled then
            local generation = self.generation
            task.spawn(function()
                self:_loop(generation)
            end)
        else
            self.movement:stopOwner(OWNER)
            self.onStatus("Auto Fugir: OFF")
        end
    end

    function AutoEvade:stop()
        self:setEnabled(false)
    end

    function AutoEvade:Destroy()
        self:stop()
    end

    return AutoEvade
end

__factories["Features/AutoLoot"] = function()
    local CollectionService = game:GetService("CollectionService")
    local Workspace = game:GetService("Workspace")

    local Config = __require("Config")
    local Runtime = __require("Core/Runtime")

    local AutoLoot = {}
    AutoLoot.__index = AutoLoot

    local OWNER = "AutoLoot"
    local PRIORITY = 40

    local function touch(root, border)
        if typeof(firetouchinterest) == "function" then
            pcall(firetouchinterest, root, border, 0)
            task.wait()
            pcall(firetouchinterest, root, border, 1)
        end
    end

    function AutoLoot.new(movement, mapProvider, onStatus)
        local self = setmetatable({
            movement = movement,
            mapProvider = mapProvider,
            onStatus = onStatus or function() end,
            enabled = false,
            generation = 0,
            cooldowns = setmetatable({}, { __mode = "k" }),
            wake = false,
            connections = {},
            collected = 0,
        }, AutoLoot)

        table.insert(self.connections, CollectionService:GetInstanceAddedSignal("Loot"):Connect(function()
            self.wake = true
        end))
        return self
    end

    function AutoLoot:_nextLoot()
        local root = Runtime.getRoot()
        if not root then
            return nil
        end

        local now = os.clock()
        local selected = nil
        local selectedDistance = math.huge
        for _, loot in ipairs(self.mapProvider:getLoot()) do
            if (self.cooldowns[loot.instance] or 0) <= now then
                local distance = (loot.border.Position - root.Position).Magnitude
                if distance < selectedDistance then
                    selected = loot
                    selectedDistance = distance
                end
            end
        end
        return selected
    end

    function AutoLoot:_collect(loot)
        local root = Runtime.getRoot()
        if not root or not loot.border.Parent then
            return false
        end

        self.cooldowns[loot.instance] = os.clock() + Config.TIMING.LOOT_RETRY
        local destination = loot.border.CFrame + Vector3.new(0, 1.5, 0)
        local moved, token = self.movement:move(OWNER, PRIORITY, destination, Config.TIMING.LOOT_TOUCH)
        if not moved then
            self.cooldowns[loot.instance] = os.clock() + 0.25
            return false
        end

        root = Runtime.getRoot()
        if root and loot.border.Parent then
            touch(root, loot.border)
            task.wait(Config.TIMING.LOOT_TOUCH)
            touch(root, loot.border)
        end
        self.movement:release(OWNER, token)
        self.collected += 1
        self.onStatus(string.format("Auto Loot: %s (%d nesta execucao)", loot.id, self.collected))
        return true
    end

    function AutoLoot:_loop(generation)
        while self.enabled and self.generation == generation do
            if Runtime.isSurvivor()
                and Runtime.isAlive()
                and not Runtime.isDowned()
                and not Runtime.isEscaped()
                and Workspace:GetAttribute("ExitsOpen") ~= true
            then
                local loot = self:_nextLoot()
                if loot then
                    self:_collect(loot)
                end
            end

            local delayTime = self.wake and 0.03 or Config.TIMING.LOOT_POLL
            self.wake = false
            task.wait(delayTime)
        end
    end

    function AutoLoot:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then
            return
        end
        self.enabled = enabled
        self.generation += 1
        if enabled then
            self.wake = true
            local generation = self.generation
            task.spawn(function()
                self:_loop(generation)
            end)
        else
            self.movement:stopOwner(OWNER)
            self.onStatus("Auto Loot: OFF")
        end
    end

    function AutoLoot:stop()
        self:setEnabled(false)
    end

    function AutoLoot:Destroy()
        self:stop()
        for _, connection in ipairs(self.connections) do
            connection:Disconnect()
        end
        table.clear(self.connections)
        table.clear(self.cooldowns)
    end

    return AutoLoot
end

__factories["Features/AutoRevive"] = function()
    local Config = __require("Config")
    local Runtime = __require("Core/Runtime")

    local AutoRevive = {}
    AutoRevive.__index = AutoRevive

    local OWNER = "AutoRevive"
    local PRIORITY = 70

    function AutoRevive.new(movement, onStatus)
        return setmetatable({
            movement = movement,
            onStatus = onStatus or function() end,
            enabled = false,
            generation = 0,
            dangerDistance = Config.DISTANCES.KILLER_EVADE,
            lastTarget = nil,
        }, AutoRevive)
    end

    function AutoRevive:setDangerDistance(distance)
        self.dangerDistance = math.clamp(tonumber(distance) or Config.DISTANCES.KILLER_EVADE, 15, 120)
    end

    function AutoRevive:_nearestKillerDistance(position)
        local nearest = math.huge
        for _, player in ipairs(Runtime.Players:GetPlayers()) do
            if Runtime.isKiller(player) then
                local root = Runtime.getRoot(player)
                if root then
                    nearest = math.min(nearest, (root.Position - position).Magnitude)
                end
            end
        end
        return nearest
    end

    function AutoRevive:_targetForSelf()
        local root = Runtime.getRoot()
        if not root then
            return nil
        end

        local best = nil
        local bestScore = -math.huge
        for _, player in ipairs(Runtime.Players:GetPlayers()) do
            if player ~= Runtime.LocalPlayer
                and Runtime.isSurvivor(player)
                and Runtime.isAlive(player)
                and not Runtime.isDowned(player)
                and not Runtime.isEscaped(player)
            then
                local targetRoot = Runtime.getRoot(player)
                if targetRoot then
                    local killerDistance = self:_nearestKillerDistance(targetRoot.Position)
                    local travel = (root.Position - targetRoot.Position).Magnitude
                    local score = killerDistance - travel * 0.08
                    if score > bestScore then
                        best = player
                        bestScore = score
                    end
                end
            end
        end
        return best
    end

    function AutoRevive:_targetToRevive()
        local root = Runtime.getRoot()
        if not root then
            return nil
        end

        local best = nil
        local bestDistance = math.huge
        for _, player in ipairs(Runtime.Players:GetPlayers()) do
            if player ~= Runtime.LocalPlayer
                and Runtime.isSurvivor(player)
                and Runtime.isAlive(player)
                and Runtime.isDowned(player)
                and not player:GetAttribute("HeldByPlayer")
            then
                local targetRoot = Runtime.getRoot(player)
                if targetRoot and self:_nearestKillerDistance(targetRoot.Position) >= self.dangerDistance * 0.75 then
                    local distance = (root.Position - targetRoot.Position).Magnitude
                    if distance < bestDistance then
                        best = player
                        bestDistance = distance
                    end
                end
            end
        end
        return best
    end

    function AutoRevive:_follow(target, rescuingSelf)
        local targetRoot = Runtime.getRoot(target)
        if not targetRoot then
            return
        end

        local side = targetRoot.CFrame.RightVector * Config.DISTANCES.REVIVE_FOLLOW
        local height = Vector3.new(0, rescuingSelf and 0.8 or 1.4, 0)
        local position = targetRoot.Position + side + height
        local destination = CFrame.lookAt(position, targetRoot.Position)
        self.movement:move(OWNER, PRIORITY, destination, Config.TIMING.REVIVE_FOLLOW * 1.5)
    end

    function AutoRevive:_loop(generation)
        while self.enabled and self.generation == generation do
            if not Runtime.isSurvivor() or not Runtime.isAlive() then
                self.lastTarget = nil
                task.wait(0.20)
                continue
            end

            local rescuingSelf = Runtime.isDowned()
            local target = rescuingSelf and self:_targetForSelf() or self:_targetToRevive()
            if target then
                if self.lastTarget ~= target then
                    self.lastTarget = target
                    self.onStatus((rescuingSelf and "Auto Revive: buscando ajuda com " or "Auto Revive: revivendo ") .. target.Name)
                end
                self:_follow(target, rescuingSelf)
            else
                if self.lastTarget ~= nil then
                    self.lastTarget = nil
                    self.onStatus("Auto Revive: aguardando alvo seguro")
                end
                self.movement:stopOwner(OWNER)
            end
            task.wait(Config.TIMING.REVIVE_FOLLOW)
        end
    end

    function AutoRevive:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then
            return
        end
        self.enabled = enabled
        self.generation += 1
        self.lastTarget = nil
        if enabled then
            local generation = self.generation
            task.spawn(function()
                self:_loop(generation)
            end)
        else
            self.movement:stopOwner(OWNER)
            self.onStatus("Auto Revive: OFF")
        end
    end

    function AutoRevive:stop()
        self:setEnabled(false)
    end

    function AutoRevive:Destroy()
        self:stop()
    end

    return AutoRevive
end

__factories["Features/KillAll"] = function()
    local Config = __require("Config")
    local Runtime = __require("Core/Runtime")

    local KillAll = {}
    KillAll.__index = KillAll

    local OWNER = "KillAll"
    local PRIORITY = 80

    function KillAll.new(movement, onStatus)
        return setmetatable({
            movement = movement,
            onStatus = onStatus or function() end,
            enabled = false,
            generation = 0,
            lastMessage = "",
        }, KillAll)
    end

    function KillAll:_status(message)
        if message ~= self.lastMessage then
            self.lastMessage = message
            self.onStatus(message)
        end
    end

    function KillAll:_targets()
        local targets = {}
        for _, player in ipairs(Runtime.Players:GetPlayers()) do
            if player ~= Runtime.LocalPlayer
                and Runtime.isSurvivor(player)
                and Runtime.isAlive(player)
                and not Runtime.isDowned(player)
                and not Runtime.isEscaped(player)
            then
                table.insert(targets, player)
            end
        end
        return targets
    end

    function KillAll:_getSlashEvent()
        local character = Runtime.getCharacter()
        local knife = character and character:FindFirstChild("Knife")
        local slashEvent = knife and knife:FindFirstChild("KnifeSlashEvent")
        if slashEvent and slashEvent:IsA("RemoteEvent") then
            return slashEvent
        end
        return nil
    end

    function KillAll:_attack(target)
        local targetRoot = Runtime.getRoot(target)
        local slashEvent = self:_getSlashEvent()
        if not targetRoot or not slashEvent then
            return false
        end

        local attackPosition = targetRoot.Position + Vector3.new(0, Config.DISTANCES.KILL_OFFSET_UP, 1.5)
        local destination = CFrame.lookAt(attackPosition, targetRoot.Position)
        local moved, token = self.movement:move(OWNER, PRIORITY, destination, Config.TIMING.KNIFE_SLASH)
        if not moved then
            return false
        end

        slashEvent:FireServer()
        task.wait(Config.TIMING.KNIFE_SLASH)
        self.movement:release(OWNER, token)
        return true
    end

    function KillAll:_loop(generation)
        while self.enabled and self.generation == generation do
            if not Runtime.isKiller() then
                self:_status("Kill All: aguardando voce ser o Killer")
                task.wait(0.25)
                continue
            end

            if not self:_getSlashEvent() then
                self:_status("Kill All: aguardando a faca equipada")
                task.wait(0.20)
                continue
            end

            local targets = self:_targets()
            if #targets == 0 then
                self:_status("Kill All: nenhum Survivor ativo")
                task.wait(0.20)
                continue
            end

            for _, target in ipairs(targets) do
                if not self.enabled or self.generation ~= generation or not Runtime.isKiller() then
                    break
                end
                self:_status("Kill All: atacando " .. target.Name)
                self:_attack(target)
            end
        end
    end

    function KillAll:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then
            return
        end
        self.enabled = enabled
        self.generation += 1
        if enabled then
            local generation = self.generation
            task.spawn(function()
                self:_loop(generation)
            end)
        else
            self.movement:stopOwner(OWNER)
            self:_status("Kill All: OFF")
        end
    end

    function KillAll:stop()
        self:setEnabled(false)
    end

    function KillAll:Destroy()
        self:stop()
    end

    return KillAll
end

__factories["Features/TeamESP"] = function()
    local Runtime = __require("Core/Runtime")

    local TeamESP = {}
    TeamESP.__index = TeamESP

    local COLORS = {
        Survivor = Color3.fromRGB(0, 150, 255),
        Killer = Color3.fromRGB(255, 0, 0),
    }

    local HIGHLIGHT_NAME = "GOATHubSTK_TeamAura"

    function TeamESP.new(onStatus)
        return setmetatable({
            onStatus = onStatus or function() end,
            enabled = false,
            globalConnections = {},
            playerConnections = {},
        }, TeamESP)
    end

    function TeamESP:_removeHighlight(player)
        local character = Runtime.getCharacter(player)
        local highlight = character and character:FindFirstChild(HIGHLIGHT_NAME)
        if highlight then
            highlight:Destroy()
        end
    end

    function TeamESP:_render(player)
        self:_removeHighlight(player)
        if not self.enabled or player == Runtime.LocalPlayer then
            return
        end

        local character = Runtime.getCharacter(player)
        local color = COLORS[Runtime.getTeamName(player)]
        if not character or not color then
            return
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = HIGHLIGHT_NAME
        highlight.Adornee = character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = color
        highlight.OutlineColor = color:Lerp(Color3.new(1, 1, 1), 0.25)
        highlight.FillTransparency = player:GetAttribute("Downed") and 0.78 or 0.58
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end

    function TeamESP:_disconnectPlayer(player)
        local connections = self.playerConnections[player]
        if connections then
            for _, connection in ipairs(connections) do
                connection:Disconnect()
            end
            self.playerConnections[player] = nil
        end
        self:_removeHighlight(player)
    end

    function TeamESP:_watchPlayer(player)
        self:_disconnectPlayer(player)
        local connections = {}
        self.playerConnections[player] = connections

        table.insert(connections, player.CharacterAdded:Connect(function()
            task.defer(function()
                self:_render(player)
            end)
        end))
        table.insert(connections, player:GetPropertyChangedSignal("Team"):Connect(function()
            self:_render(player)
        end))
        table.insert(connections, player:GetAttributeChangedSignal("TeamID"):Connect(function()
            self:_render(player)
        end))
        table.insert(connections, player:GetAttributeChangedSignal("Downed"):Connect(function()
            self:_render(player)
        end))
        self:_render(player)
    end

    function TeamESP:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then
            return
        end
        self.enabled = enabled

        if enabled then
            table.insert(self.globalConnections, Runtime.Players.PlayerAdded:Connect(function(player)
                self:_watchPlayer(player)
            end))
            table.insert(self.globalConnections, Runtime.Players.PlayerRemoving:Connect(function(player)
                self:_disconnectPlayer(player)
            end))
            for _, player in ipairs(Runtime.Players:GetPlayers()) do
                self:_watchPlayer(player)
            end
            self.onStatus("Team ESP: Survivor azul / Killer vermelho")
        else
            self:stop()
            self.onStatus("Team ESP: OFF")
        end
    end

    function TeamESP:stop()
        self.enabled = false
        for _, connection in ipairs(self.globalConnections) do
            connection:Disconnect()
        end
        table.clear(self.globalConnections)

        local players = {}
        for player in pairs(self.playerConnections) do
            table.insert(players, player)
        end
        for _, player in ipairs(players) do
            self:_disconnectPlayer(player)
        end
    end

    function TeamESP:Destroy()
        self:stop()
    end

    return TeamESP
end

__factories["Providers/MapProvider"] = function()
    local CollectionService = game:GetService("CollectionService")
    local Workspace = game:GetService("Workspace")

    local Runtime = __require("Core/Runtime")

    local MapProvider = {}
    MapProvider.__index = MapProvider

    local EXCLUDED_ANCESTORS = {
        LootSpawns = true,
        FuseSpawns = true,
        Lockers = true,
        Doorway = true,
        ExitEffect = true,
    }

    local EXCLUDED_NAMES = {
        Trigger = true,
        Collider = true,
        Ceiling = true,
        Roof = true,
        Wall = true,
    }

    local function hasTaggedAncestor(instance, tag, boundary)
        local current = instance
        while current and current ~= boundary do
            if CollectionService:HasTag(current, tag) then
                return true
            end
            current = current.Parent
        end
        return false
    end

    local function hasExcludedAncestor(instance, boundary)
        local current = instance.Parent
        while current and current ~= boundary do
            if EXCLUDED_ANCESTORS[current.Name] then
                return true
            end
            current = current.Parent
        end
        return false
    end

    local function isWalkablePart(part, map)
        if not part:IsA("BasePart") or not part.Anchored or not part.CanCollide then
            return false
        end
        if part.Transparency >= 0.95 or part.Size.X < 6 or part.Size.Z < 6 then
            return false
        end
        if part.CFrame.UpVector.Y < 0.78 or EXCLUDED_NAMES[part.Name] then
            return false
        end
        if hasExcludedAncestor(part, map) then
            return false
        end
        if hasTaggedAncestor(part, "Loot", map) or hasTaggedAncestor(part, "Exit", map) then
            return false
        end
        return true
    end

    function MapProvider.new()
        local self = setmetatable({
            map = nil,
            candidates = {},
            connections = {},
            destroyed = false,
        }, MapProvider)

        table.insert(self.connections, Workspace:GetAttributeChangedSignal("Map"):Connect(function()
            self:invalidate()
        end))
        return self
    end

    function MapProvider:invalidate()
        self.map = nil
        table.clear(self.candidates)
    end

    function MapProvider:getMap()
        local map = Runtime.getCurrentMap()
        if map ~= self.map then
            self.map = map
            table.clear(self.candidates)
        end
        return map
    end

    function MapProvider:_buildCandidates()
        local map = self:getMap()
        if not map or #self.candidates > 0 then
            return
        end

        for _, descendant in ipairs(map:GetDescendants()) do
            if isWalkablePart(descendant, map) then
                table.insert(self.candidates, descendant)
            end
        end
    end

    function MapProvider:getExits()
        local map = self:getMap()
        local exits = {}
        if not map then
            return exits
        end

        for _, instance in ipairs(CollectionService:GetTagged("Exit")) do
            if instance:IsDescendantOf(map) then
                local trigger = instance:FindFirstChild("Trigger")
                if trigger and trigger:IsA("BasePart") then
                    table.insert(exits, {
                        model = instance,
                        trigger = trigger,
                        open = instance:GetAttribute("Open") == true,
                    })
                end
            end
        end
        return exits
    end

    function MapProvider:getLoot()
        local map = self:getMap()
        local loot = {}
        if not map then
            return loot
        end

        for _, instance in ipairs(CollectionService:GetTagged("Loot")) do
            if instance:IsDescendantOf(map) then
                local border = instance:FindFirstChild("Border")
                local lootID = instance.Parent and instance.Parent:GetAttribute("Loot")
                if border and border:IsA("BasePart") and typeof(lootID) == "string" and lootID ~= "" then
                    table.insert(loot, {
                        instance = instance,
                        border = border,
                        id = lootID,
                    })
                end
            end
        end
        return loot
    end

    function MapProvider:findSafeCFrame(killerRoots, currentPosition, minimumTravel)
        self:_buildCandidates()
        local map = self:getMap()
        if not map then
            return nil
        end

        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
        raycastParams.FilterDescendantsInstances = { map }
        raycastParams.IgnoreWater = true

        local bestCFrame = nil
        local bestScore = -math.huge
        local candidateCount = #self.candidates
        if candidateCount == 0 then
            return nil
        end

        local startIndex = math.random(1, candidateCount)
        local checks = math.min(candidateCount, 180)
        for offset = 0, checks - 1 do
            local index = ((startIndex + offset - 1) % candidateCount) + 1
            local part = self.candidates[index]
            if part.Parent and part:IsDescendantOf(map) and isWalkablePart(part, map) then
                local top = part.Position + part.CFrame.UpVector * (part.Size.Y / 2 + 8)
                local hit = Workspace:Raycast(top, Vector3.new(0, -28, 0), raycastParams)
                if hit and hit.Instance and hit.Normal.Y >= 0.62 then
                    local position = hit.Position + Vector3.new(0, 3.2, 0)
                    local travel = (position - currentPosition).Magnitude
                    if travel >= minimumTravel then
                        local nearestKiller = math.huge
                        for _, killerRoot in ipairs(killerRoots) do
                            if killerRoot and killerRoot.Parent then
                                nearestKiller = math.min(nearestKiller, (position - killerRoot.Position).Magnitude)
                            end
                        end

                        local score = nearestKiller + math.min(travel, 80) * 0.15
                        if score > bestScore then
                            bestScore = score
                            bestCFrame = CFrame.new(position)
                        end
                    end
                end
            end
        end

        return bestCFrame
    end

    function MapProvider:Destroy()
        self.destroyed = true
        for _, connection in ipairs(self.connections) do
            connection:Disconnect()
        end
        table.clear(self.connections)
        table.clear(self.candidates)
        self.map = nil
    end

    return MapProvider
end

__factories["UI/Layout"] = function()
    local Layout = {}

    function Layout.calculate(viewport, config)
        local padding = config.PADDING
        local availableWidth = math.max(1, viewport.X - padding * 2)
        local availableHeight = math.max(1, viewport.Y - padding * 2)
        local narrow = viewport.X <= config.NARROW_BREAKPOINT
        local compact = narrow or viewport.Y <= config.COMPACT_BREAKPOINT

        local requestedWidth
        local mode
        if narrow then
            requestedWidth = config.DESKTOP_WIDTH
            mode = "narrow"
        elseif compact then
            requestedWidth = config.COMPACT_WIDTH
            mode = "compact"
        else
            requestedWidth = config.DESKTOP_WIDTH
            mode = "desktop"
        end

        return {
            mode = mode,
            padding = padding,
            width = math.min(requestedWidth, availableWidth),
            height = math.min(config.DESKTOP_HEIGHT, availableHeight),
            centerX = viewport.X / 2,
            centerY = viewport.Y / 2,
            headerHeight = compact and 38 or 42,
            rowHeight = compact and 34 or 38,
            textSize = compact and 12 or 13,
        }
    end

    function Layout.clampCenter(centerX, centerY, width, height, viewport, padding)
        local halfWidth = width / 2
        local halfHeight = height / 2
        local minX = padding + halfWidth
        local maxX = viewport.X - padding - halfWidth
        local minY = padding + halfHeight
        local maxY = viewport.Y - padding - halfHeight

        if minX > maxX then
            centerX = viewport.X / 2
        else
            centerX = math.clamp(centerX, minX, maxX)
        end
        if minY > maxY then
            centerY = viewport.Y / 2
        else
            centerY = math.clamp(centerY, minY, maxY)
        end
        return centerX, centerY
    end

    return Layout
end

__factories["UI/UI"] = function()
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")

    local Config = __require("Config")
    local Layout = __require("UI/Layout")

    local UI = {}

    local COLORS = table.freeze({
        panel = Color3.fromRGB(20, 22, 29),
        header = Color3.fromRGB(31, 35, 45),
        card = Color3.fromRGB(39, 43, 55),
        cardHover = Color3.fromRGB(48, 53, 67),
        text = Color3.fromRGB(240, 243, 250),
        muted = Color3.fromRGB(164, 173, 194),
        accent = Color3.fromRGB(58, 135, 255),
        green = Color3.fromRGB(42, 170, 100),
        red = Color3.fromRGB(220, 67, 73),
        border = Color3.fromRGB(73, 80, 100),
    })

    local function corner(parent, radius)
        local value = Instance.new("UICorner")
        value.CornerRadius = UDim.new(0, radius)
        value.Parent = parent
        return value
    end

    local function stroke(parent, color, thickness)
        local value = Instance.new("UIStroke")
        value.Color = color
        value.Thickness = thickness or 1
        value.Parent = parent
        return value
    end

    local function makeLabel(parent, text, height)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, height or 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = COLORS.muted
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = parent
        return label
    end

    function UI.new(title)
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local previous = playerGui:FindFirstChild("GOATHubSTK")
        if previous then
            previous:Destroy()
        end

        local self = {
            colors = COLORS,
            connections = {},
            cameraConnection = nil,
            destroyed = false,
            closeCallback = nil,
            dragState = "idle",
            dragPress = nil,
            dragInput = nil,
            dragStart = nil,
            startCenter = nil,
            layout = nil,
        }

        local gui = Instance.new("ScreenGui")
        gui.Name = "GOATHubSTK"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = playerGui
        self.gui = gui

        local frame = Instance.new("Frame")
        frame.Name = "Window"
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.BackgroundColor3 = COLORS.panel
        frame.ClipsDescendants = true
        frame.Parent = gui
        corner(frame, 11)
        stroke(frame, COLORS.border, 1)
        self.frame = frame

        local topBar = Instance.new("Frame")
        topBar.Name = "TopBar"
        topBar.BackgroundColor3 = COLORS.header
        topBar.Parent = frame
        self.topBar = topBar

        local dragHandle = Instance.new("TextButton")
        dragHandle.Name = "DragHandle"
        dragHandle.Size = UDim2.new(1, -46, 1, 0)
        dragHandle.BackgroundTransparency = 1
        dragHandle.Text = "  " .. (title or Config.UI.TITLE)
        dragHandle.TextColor3 = COLORS.text
        dragHandle.Font = Enum.Font.GothamBold
        dragHandle.TextSize = 14
        dragHandle.TextXAlignment = Enum.TextXAlignment.Left
        dragHandle.AutoButtonColor = false
        dragHandle.Parent = topBar
        self.dragHandle = dragHandle

        local closeButton = Instance.new("TextButton")
        closeButton.Name = "Close"
        closeButton.AnchorPoint = Vector2.new(1, 0.5)
        closeButton.Position = UDim2.new(1, -7, 0.5, 0)
        closeButton.Size = UDim2.fromOffset(32, 28)
        closeButton.BackgroundColor3 = COLORS.card
        closeButton.Text = "×"
        closeButton.TextColor3 = COLORS.text
        closeButton.Font = Enum.Font.GothamBold
        closeButton.TextSize = 20
        closeButton.Parent = topBar
        corner(closeButton, 7)
        self.closeButton = closeButton

        local content = Instance.new("ScrollingFrame")
        content.Name = "Content"
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.CanvasSize = UDim2.new()
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.ScrollingDirection = Enum.ScrollingDirection.Y
        content.ScrollBarThickness = 4
        content.ScrollBarImageColor3 = COLORS.accent
        content.Parent = frame
        self.content = content

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 9)
        padding.PaddingRight = UDim.new(0, 9)
        padding.PaddingTop = UDim.new(0, 9)
        padding.PaddingBottom = UDim.new(0, 9)
        padding.Parent = content

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 7)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = content

        local function currentViewport()
            local camera = Workspace.CurrentCamera
            return camera and camera.ViewportSize or Vector2.new(800, 600)
        end

        function self:_applyLayout(resetCenter)
            if self.destroyed then
                return
            end
            local viewport = currentViewport()
            local calculated = Layout.calculate(viewport, Config.UI)
            local centerX = resetCenter and calculated.centerX or self.frame.Position.X.Offset
            local centerY = resetCenter and calculated.centerY or self.frame.Position.Y.Offset
            centerX, centerY = Layout.clampCenter(
                centerX,
                centerY,
                calculated.width,
                calculated.height,
                viewport,
                calculated.padding
            )

            self.layout = calculated
            self.frame.Size = UDim2.fromOffset(calculated.width, calculated.height)
            self.frame.Position = UDim2.fromOffset(centerX, centerY)
            self.topBar.Size = UDim2.new(1, 0, 0, calculated.headerHeight)
            self.content.Position = UDim2.fromOffset(0, calculated.headerHeight)
            self.content.Size = UDim2.new(1, 0, 1, -calculated.headerHeight)
        end

        function self:_bindCamera()
            if self.cameraConnection then
                self.cameraConnection:Disconnect()
                self.cameraConnection = nil
            end
            local camera = Workspace.CurrentCamera
            if camera then
                self.cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                    self:_applyLayout(false)
                end)
            end
            self:_applyLayout(false)
        end

        local function finishDrag(input)
            if self.dragPress ~= input and self.dragInput ~= input then
                return
            end
            self.dragState = "idle"
            self.dragPress = nil
            self.dragInput = nil
            self.dragStart = nil
            self.startCenter = nil
        end

        table.insert(self.connections, dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch
            then
                return
            end
            self.dragState = "pressed"
            self.dragPress = input
            self.dragInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
            self.dragStart = input.Position
            self.startCenter = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
        end))

        table.insert(self.connections, dragHandle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                self.dragInput = input
            end
        end))

        table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
            if self.dragState == "idle" or input ~= self.dragInput then
                return
            end
            local delta = input.Position - self.dragStart
            if self.dragState == "pressed" and delta.Magnitude >= 5 then
                self.dragState = "dragging"
            end
            if self.dragState ~= "dragging" then
                return
            end

            local viewport = currentViewport()
            local x, y = Layout.clampCenter(
                self.startCenter.X + delta.X,
                self.startCenter.Y + delta.Y,
                self.layout.width,
                self.layout.height,
                viewport,
                self.layout.padding
            )
            frame.Position = UDim2.fromOffset(x, y)
        end))

        table.insert(self.connections, UserInputService.InputEnded:Connect(finishDrag))
        table.insert(self.connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            self:_bindCamera()
        end))
        table.insert(self.connections, closeButton.Activated:Connect(function()
            if self.closeCallback then
                self.closeCallback()
            end
        end))

        function self:setCloseCallback(callback)
            self.closeCallback = callback
        end

        function self:Destroy()
            if self.destroyed then
                return
            end
            self.destroyed = true
            self.dragState = "idle"
            self.dragPress = nil
            self.dragInput = nil
            if self.cameraConnection then
                self.cameraConnection:Disconnect()
                self.cameraConnection = nil
            end
            for _, connection in ipairs(self.connections) do
                connection:Disconnect()
            end
            table.clear(self.connections)
            if self.gui then
                self.gui:Destroy()
                self.gui = nil
            end
        end

        self:_applyLayout(true)
        self:_bindCamera()
        return self
    end

    function UI.section(parent, text)
        local label = makeLabel(parent, text, 20)
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = COLORS.muted
        label.TextSize = 11
        return label
    end

    function UI.info(parent, text, height)
        local label = makeLabel(parent, text, height or 34)
        label.TextColor3 = COLORS.text
        label.TextWrapped = true
        label.TextYAlignment = Enum.TextYAlignment.Top
        return label
    end

    function UI.button(parent, text, color, height)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, height or 36)
        button.BackgroundColor3 = color or COLORS.card
        button.AutoButtonColor = true
        button.Text = text
        button.TextColor3 = COLORS.text
        button.Font = Enum.Font.GothamBold
        button.TextSize = 13
        button.Parent = parent
        corner(button, 7)
        return button
    end

    function UI.checkbox(parent, text, initial, callback)
        local row = UI.button(parent, "", COLORS.card, 38)
        local box = Instance.new("TextLabel")
        box.AnchorPoint = Vector2.new(0, 0.5)
        box.Position = UDim2.new(0, 10, 0.5, 0)
        box.Size = UDim2.fromOffset(20, 20)
        box.BackgroundColor3 = COLORS.panel
        box.TextColor3 = COLORS.text
        box.Font = Enum.Font.GothamBold
        box.TextSize = 15
        box.Parent = row
        corner(box, 5)
        stroke(box, COLORS.border, 1)

        local label = makeLabel(row, text, 38)
        label.Position = UDim2.fromOffset(40, 0)
        label.Size = UDim2.new(1, -48, 1, 0)
        label.TextColor3 = COLORS.text
        label.TextSize = 13

        local checked = initial == true
        local function render()
            box.Text = checked and "✓" or ""
            box.BackgroundColor3 = checked and COLORS.green or COLORS.panel
        end
        render()

        row.Activated:Connect(function()
            checked = not checked
            render()
            callback(checked)
        end)
        return row
    end

    function UI.numberInput(parent, text, initial, minimum, maximum, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 42)
        row.BackgroundColor3 = COLORS.card
        row.Parent = parent
        corner(row, 7)

        local label = makeLabel(row, text, 42)
        label.Position = UDim2.fromOffset(10, 0)
        label.Size = UDim2.new(1, -112, 1, 0)
        label.TextColor3 = COLORS.text
        label.TextSize = 12

        local box = Instance.new("TextBox")
        box.AnchorPoint = Vector2.new(1, 0.5)
        box.Position = UDim2.new(1, -8, 0.5, 0)
        box.Size = UDim2.fromOffset(92, 28)
        box.BackgroundColor3 = COLORS.panel
        box.TextColor3 = COLORS.text
        box.PlaceholderColor3 = COLORS.muted
        box.ClearTextOnFocus = false
        box.Font = Enum.Font.GothamBold
        box.TextSize = 13
        box.Text = tostring(initial)
        box.Parent = row
        corner(box, 6)
        stroke(box, COLORS.border, 1)

        local value = math.clamp(tonumber(initial) or minimum, minimum, maximum)
        local function commit()
            value = math.clamp(tonumber(box.Text) or value, minimum, maximum)
            box.Text = tostring(math.floor(value + 0.5))
            callback(value)
        end
        box.FocusLost:Connect(commit)
        return row, box
    end

    return UI
end

__factories["init"] = function()
    local Config = __require("Config")
    local MovementCoordinator = __require("Core/MovementCoordinator")
    local MapProvider = __require("Providers/MapProvider")
    local UI = __require("UI/UI")
    local AutoEscape = __require("Features/AutoEscape")
    local KillAll = __require("Features/KillAll")
    local AutoRevive = __require("Features/AutoRevive")
    local TeamESP = __require("Features/TeamESP")
    local AutoLoot = __require("Features/AutoLoot")
    local AutoEvade = __require("Features/AutoEvade")

    local Main = {}

    local GLOBAL_KEY = "__GOATHUB_STK_APP"

    local function validId(value)
        return typeof(value) == "number" and value > 0 and value % 1 == 0
    end

    local function configuredForCurrentPlace()
        if not validId(Config.GAME_ID) or game.GameId ~= Config.GAME_ID then
            return false
        end
        for _, placeId in ipairs(Config.PLACE_IDS) do
            if validId(placeId) and game.PlaceId == placeId then
                return true
            end
        end
        return false
    end

    local function environment()
        if typeof(getgenv) == "function" then
            return getgenv()
        end
        return _G
    end

    function Main.start()
        if not configuredForCurrentPlace() then
            return nil
        end

        local env = environment()
        local previous = env[GLOBAL_KEY]
        if previous and typeof(previous.Destroy) == "function" then
            pcall(function()
                previous:Destroy()
            end)
        end

        local app = {
            destroyed = false,
            controllers = {},
        }

        local movement = MovementCoordinator.new()
        local mapProvider = MapProvider.new()
        local window = UI.new(Config.UI.TITLE)
        local content = window.content
        local layoutOrder = 0

        app.movement = movement
        app.mapProvider = mapProvider
        app.window = window

        local function contentItem(instance)
            layoutOrder += 1
            instance.LayoutOrder = layoutOrder
            return instance
        end

        local status = contentItem(UI.info(content, "GOATHubSTK iniciado", 42))
        status.TextColor3 = window.colors.text
        app.status = status

        local function setStatus(message)
            if not app.destroyed and status.Parent then
                status.Text = tostring(message)
            end
        end

        local autoEscape = AutoEscape.new(movement, mapProvider, setStatus)
        local killAll = KillAll.new(movement, setStatus)
        local autoRevive = AutoRevive.new(movement, setStatus)
        local teamESP = TeamESP.new(setStatus)
        local autoLoot = AutoLoot.new(movement, mapProvider, setStatus)
        local autoEvade = AutoEvade.new(movement, mapProvider, setStatus)

        app.controllers = {
            autoEscape,
            killAll,
            autoRevive,
            teamESP,
            autoLoot,
            autoEvade,
        }

        contentItem(UI.section(content, "RODADA"))
        contentItem(UI.checkbox(content, "Auto Escape", false, function(enabled)
            autoEscape:setEnabled(enabled)
        end))
        contentItem(UI.checkbox(content, "Kill All (somente Killer)", false, function(enabled)
            killAll:setEnabled(enabled)
        end))
        contentItem(UI.checkbox(content, "Auto Revive / buscar ajuda", false, function(enabled)
            autoRevive:setEnabled(enabled)
        end))

        contentItem(UI.section(content, "VISUAL E LOOT"))
        contentItem(UI.checkbox(content, "Team ESP — azul/vermelho", false, function(enabled)
            teamESP:setEnabled(enabled)
        end))
        contentItem(UI.checkbox(content, "Auto Collect Loot", false, function(enabled)
            autoLoot:setEnabled(enabled)
        end))

        contentItem(UI.section(content, "SEGURANCA DO SURVIVOR"))
        contentItem(UI.numberInput(
            content,
            "Fugir quando Killer estiver a (studs)",
            Config.DISTANCES.KILLER_EVADE,
            15,
            120,
            function(distance)
                autoEvade:setDistance(distance)
                autoRevive:setDangerDistance(distance)
                setStatus("Distancia de seguranca: " .. tostring(math.floor(distance + 0.5)) .. " studs")
            end
        ))
        contentItem(UI.checkbox(content, "Auto Fugir do Killer", false, function(enabled)
            autoEvade:setEnabled(enabled)
        end))

        local note = contentItem(UI.info(
            content,
            "Prioridade de movimento: Escape > Fugir > Kill All > Revive > Loot.",
            34
        ))
        note.TextColor3 = window.colors.muted

        function app:Destroy()
            if self.destroyed then
                return
            end
            self.destroyed = true

            for _, controller in ipairs(self.controllers) do
                if controller.Destroy then
                    pcall(function()
                        controller:Destroy()
                    end)
                elseif controller.stop then
                    pcall(function()
                        controller:stop()
                    end)
                end
            end
            table.clear(self.controllers)

            if self.mapProvider then
                self.mapProvider:Destroy()
                self.mapProvider = nil
            end
            if self.movement then
                self.movement:Destroy()
                self.movement = nil
            end
            if self.window then
                self.window:Destroy()
                self.window = nil
            end

            if env[GLOBAL_KEY] == self then
                env[GLOBAL_KEY] = nil
            end
        end

        local closeButton = contentItem(UI.button(content, "Fechar GOAT Hub STK", window.colors.card, 36))
        closeButton.Activated:Connect(function()
            app:Destroy()
        end)
        window:setCloseCallback(function()
            app:Destroy()
        end)

        env[GLOBAL_KEY] = app
        setStatus(string.format("Pronto — GameId %d / PlaceId %d", game.GameId, game.PlaceId))
        return app
    end

    return Main
end

__require = function(name)
    if __cache[name] ~= nil then
        return __cache[name]
    end
    local factory = __factories[name]
    if not factory then
        error("[GOATHubSTK] Modulo inexistente: " .. tostring(name), 2)
    end
    local value = factory()
    if value == nil then
        value = true
    end
    __cache[name] = value
    return value
end

return __require("init").start()

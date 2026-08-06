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

        UI_STYLE = "Modern",

        -- O arquivo fica no repositorio e e armazenado pelo executor somente neste
        -- caminho fixo. Mantenha a URL raw HTTPS apontando para o arquivo ICO real.
        ICON = table.freeze({
            URL = "https://raw.githubusercontent.com/TaxD-drop/GOATSTK/refs/heads/main/GOATHubSTK/GOATHubSTKClient/UI/Ico/logo.ico",
            CACHE_DIRECTORY = "GOATHub/UI/Ico",
            CACHE_FILE = "logo.ico",
            MAX_BYTES = 512 * 1024,
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

        MODERN_UI = table.freeze({
            TITLE = "GOAT Hub — STK",
            PADDING = 6,
            DESKTOP_WIDTH = 660,
            DESKTOP_HEIGHT = 520,
            COMPACT_WIDTH = 570,
            COMPACT_BREAKPOINT = 520,
            NARROW_BREAKPOINT = 620,
            MIN_WIDTH = 300,
            DEFAULT_WIDTH_PERCENT = 50,
            HEADER_HEIGHT = 54,
            COMPACT_HEADER_HEIGHT = 48,
            TAB_HEIGHT = 44,
            STATUS_HEIGHT = 34,
        }),

        DISTANCES = table.freeze({
            KILLER_EVADE = 45,
            KILL_OFFSET_UP = 2.5,
            REVIVE_FOLLOW = 3,
            MIN_SAFE_TRAVEL = 24,
        }),

        ATTRIBUTE_OVERRIDES = table.freeze({
            GAMEPASSES = table.freeze({
                "DoubleJump",
                "DreadGamepass",
                "IncreasedKillerChange",
                "KringlerGamepass",
                "LayfaAshwellGamepass",
                "MalvusGamepass",
                "MrRisusGamepass",
                "PapaRoni",
                "SearingGuardGamepass",
                "StarterPack",
                "TradingVIP",
                "VIP",
                "VoldarGamepass",
            }),
            SETTINGS = table.freeze({
                "double_jump",
                "killer_chance_3x",
            }),
        }),

        PLAYER = table.freeze({
            DEFAULT_WALK_SPEED = 16,
            MIN_WALK_SPEED = 0,
            MAX_WALK_SPEED = 100,
            DEFAULT_JUMP_HEIGHT = 7,
            MIN_JUMP_HEIGHT = 0,
            MAX_JUMP_HEIGHT = 100,
        }),

        CAMERA = table.freeze({
            DEFAULT_FOV = 70,
            MIN_FOV = 30,
            MAX_FOV = 120,
        }),

        LOOT_ESP = table.freeze({
            MAX_DISTANCE = 350,
        }),

        SERVER_HOP = table.freeze({
            DEFAULT_LEVEL_LIMIT = 40,
            MIN_LEVEL_LIMIT = 1,
            MAX_LEVEL_LIMIT = 9999,
            MAX_VISITED_SERVERS = 10,
            MAX_SERVER_PAGES = 5,
            LEVEL_WAIT = 10,
            POLL = 1,
            RETRY_DELAY = 5,
            RELOAD_URL = "",
        }),

        TIMING = table.freeze({
            ESCAPE_POLL = 0.15,
            ESCAPE_DRAG_STEP = 0.06,
            KNIFE_SLASH = 0.31,
            REVIVE_FOLLOW = 0.10,
            LOOT_POLL = 0.20,
            LOOT_TOUCH = 0.16,
            LOOT_RETRY = 3.25,
            LOOT_ESP_POLL = 0.25,
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

__factories["Core/ExecutorSettings"] = function()
    local HttpService = game:GetService("HttpService")

    local Config = __require("Config")

    local ExecutorSettings = {}
    ExecutorSettings.__index = ExecutorSettings

    local DIRECTORY = "GOATHub"
    local FILE_PATH = DIRECTORY .. "/settings.json"
    local FILE_VERSION = 1
    local MAX_FILE_BYTES = 4096
    local WIDTH_PERCENTAGES = {
        [25] = true,
        [50] = true,
        [75] = true,
        [100] = true,
    }

    local function validWidthPercent(value)
        return typeof(value) == "number"
            and value % 1 == 0
            and WIDTH_PERCENTAGES[value] == true
    end

    function ExecutorSettings.new()
        local defaultWidth = Config.MODERN_UI.DEFAULT_WIDTH_PERCENT
        if not validWidthPercent(defaultWidth) then
            defaultWidth = 50
        end

        local self = setmetatable({
            widthPercent = defaultWidth,
            persistent = typeof(writefile) == "function" and typeof(makefolder) == "function",
            loaded = false,
        }, ExecutorSettings)
        self.loaded = self:_load()
        if not self.loaded and self.persistent then
            self:_save()
        end
        return self
    end

    function ExecutorSettings:_ensureDirectory()
        if typeof(makefolder) ~= "function" then
            return false
        end
        if typeof(isfolder) == "function" then
            local checked, exists = pcall(isfolder, DIRECTORY)
            if checked and exists then
                return true
            end
        end
        return pcall(makefolder, DIRECTORY)
    end

    function ExecutorSettings:_load()
        if typeof(readfile) ~= "function" then
            return false
        end
        local readOk, source = pcall(readfile, FILE_PATH)
        if not readOk or typeof(source) ~= "string" or #source == 0 or #source > MAX_FILE_BYTES then
            return false
        end

        local decodedOk, decoded = pcall(function()
            return HttpService:JSONDecode(source)
        end)
        if not decodedOk
            or typeof(decoded) ~= "table"
            or decoded.version ~= FILE_VERSION
            or typeof(decoded.ui) ~= "table"
            or not validWidthPercent(decoded.ui.widthPercent)
        then
            return false
        end
        self.widthPercent = decoded.ui.widthPercent
        return true
    end

    function ExecutorSettings:_save()
        if not self.persistent or not self:_ensureDirectory() then
            return false
        end
        local encodedOk, encoded = pcall(function()
            return HttpService:JSONEncode({
                version = FILE_VERSION,
                ui = {
                    widthPercent = self.widthPercent,
                },
            })
        end)
        if not encodedOk or typeof(encoded) ~= "string" or #encoded > MAX_FILE_BYTES then
            return false
        end
        return pcall(writefile, FILE_PATH, encoded)
    end

    function ExecutorSettings:getWidthPercent()
        return self.widthPercent
    end

    function ExecutorSettings:setWidthPercent(value)
        value = tonumber(value)
        if not validWidthPercent(value) then
            return false
        end
        self.widthPercent = value
        return self:_save()
    end

    function ExecutorSettings:isPersistent()
        return self.persistent
    end

    function ExecutorSettings:getPath()
        return FILE_PATH
    end

    return ExecutorSettings
end

__factories["Core/IconCache"] = function()
    -- Baixa uma unica vez o icone da UI e o converte para um asset local do executor.
    -- ImageLabel.Image precisa receber o URI retornado por getcustomasset/getsynasset,
    -- nunca os bytes do ICO nem a URL raw do GitHub.

    local Config = __require("Config")

    local IconCache = {}

    local CACHE_DIRECTORY = "GOATHub/UI/Ico"
    local CACHE_PATH = CACHE_DIRECTORY .. "/logo.ico"
    local MAX_BYTES = 512 * 1024
    local attempted = false
    local cachedAsset = nil

    local function validIco(source)
        return typeof(source) == "string"
            and #source >= 4
            and #source <= MAX_BYTES
            and source:sub(1, 4) == "\0\0\1\0"
    end

    local function cachePath()
        local iconConfig = Config.ICON
        if typeof(iconConfig) == "table"
            and iconConfig.CACHE_DIRECTORY == CACHE_DIRECTORY
            and iconConfig.CACHE_FILE == "logo.ico" then
            return CACHE_PATH
        end
        return CACHE_PATH
    end

    local function ensureCacheDirectory()
        if typeof(makefolder) ~= "function" then
            return false
        end
        for _, directory in ipairs({ "GOATHub", "GOATHub/UI", CACHE_DIRECTORY }) do
            local exists = false
            if typeof(isfolder) == "function" then
                local ok, value = pcall(isfolder, directory)
                exists = ok and value == true
            end
            if not exists then
                local ok = pcall(makefolder, directory)
                if not ok then
                    return false
                end
            end
        end
        return true
    end

    local function readCachedIcon(path)
        if typeof(readfile) ~= "function" then
            return nil
        end
        if typeof(isfile) == "function" then
            local existsOk, exists = pcall(isfile, path)
            if not existsOk or not exists then
                return nil
            end
        end
        local readOk, source = pcall(readfile, path)
        if readOk and validIco(source) then
            return source
        end
        return nil
    end

    local function downloadIcon()
        local iconConfig = Config.ICON
        local url = typeof(iconConfig) == "table" and iconConfig.URL or nil
        if typeof(url) ~= "string" or not url:match("^https://raw%.githubusercontent%.com/") then
            return nil
        end
        local downloadOk, source = pcall(function()
            return game:HttpGet(url)
        end)
        if not downloadOk or not validIco(source) then
            return nil
        end
        return source
    end

    local function cacheIcon(path, source)
        if typeof(writefile) ~= "function" or not ensureCacheDirectory() then
            return false
        end
        local writeOk = pcall(writefile, path, source)
        return writeOk
    end

    local function assetLoader()
        if typeof(getcustomasset) == "function" then
            return getcustomasset
        end
        if typeof(getsynasset) == "function" then
            return getsynasset
        end
        return nil
    end

    function IconCache.getAsset()
        if attempted then
            return cachedAsset
        end
        attempted = true

        local path = cachePath()
        local source = readCachedIcon(path)
        if not source then
            source = downloadIcon()
            if not source or not cacheIcon(path, source) then
                return nil
            end
        end

        local loader = assetLoader()
        if not loader then
            return nil
        end
        local assetOk, asset = pcall(loader, path)
        if assetOk and typeof(asset) == "string" and asset ~= "" then
            cachedAsset = asset
        end
        return cachedAsset
    end

    function IconCache.loadAsync(callback)
        task.spawn(function()
            local asset = IconCache.getAsset()
            if typeof(callback) == "function" then
                callback(asset)
            end
        end)
    end

    return IconCache
end

__factories["Core/LootPresentation"] = function()
    local LootPresentation = {}

    function LootPresentation.normalizeValue(value)
        value = tonumber(value) or 0
        return math.max(0, math.floor(value + 0.5))
    end

    function LootPresentation.tierForValue(value)
        value = LootPresentation.normalizeValue(value)
        if value >= 200 then
            return "spectrum"
        end
        if value >= 40 then
            return "legendary"
        end
        if value >= 15 then
            return "epic"
        end
        if value >= 5 then
            return "rare"
        end
        if value >= 3 then
            return "uncommon"
        end
        if value >= 1 then
            return "common"
        end
        return "unknown"
    end

    function LootPresentation.formatLabel(name, value)
        name = tostring(name or "")
        if name == "" then
            name = "Loot desconhecido"
        end
        value = LootPresentation.normalizeValue(value)
        local currency = value == 1 and "moeda" or "moedas"
        return string.format("%s\n%d %s", name, value, currency)
    end

    return LootPresentation
end

__factories["Core/LootVisibility"] = function()
    local LootVisibility = {}

    local VISIBLE_TRANSPARENCY = 0.99

    local function isVisibleVisual(instance)
        if instance:IsA("BasePart") or instance:IsA("Decal") then
            return instance.Transparency < VISIBLE_TRANSPARENCY
        end
        return false
    end

    function LootVisibility.isAvailable(instance)
        if not instance or not instance.Parent then
            return false
        end

        if isVisibleVisual(instance) then
            return true
        end
        for _, descendant in ipairs(instance:GetDescendants()) do
            if isVisibleVisual(descendant) then
                return true
            end
        end
        return false
    end

    return LootVisibility
end

__factories["Core/MovementCoordinator"] = function()
    local Runtime = __require("Core/Runtime")

    local MovementCoordinator = {}
    MovementCoordinator.__index = MovementCoordinator

    function MovementCoordinator.new()
        return setmetatable({
            destroyed = false,
            owner = nil,
            token = 0,
        }, MovementCoordinator)
    end

    function MovementCoordinator:acquire(owner)
        if self.destroyed then
            return nil
        end

        self.token += 1
        self.owner = owner
        return self.token
    end

    function MovementCoordinator:isOwner(owner, token)
        return not self.destroyed and self.owner == owner and self.token == token
    end

    function MovementCoordinator:move(owner, destination)
        local token = self:acquire(owner)
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
    end

    function MovementCoordinator:stopOwner(owner)
        if self.owner == owner then
            self:release(owner)
        end
    end

    function MovementCoordinator:Destroy()
        self.destroyed = true
        self.owner = nil
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

__factories["Core/ServerHopPolicy"] = function()
    local ServerHopPolicy = {}

    function ServerHopPolicy.parseLevel(value)
        if typeof(value) == "number" then
            return math.max(0, math.floor(value))
        end
        if typeof(value) == "string" then
            local digits = string.match(value, "%d+")
            return digits and tonumber(digits) or nil
        end
        return nil
    end

    function ServerHopPolicy.pushVisited(history, jobId, limit)
        if typeof(jobId) ~= "string" or jobId == "" then
            return history
        end
        for index = #history, 1, -1 do
            if history[index] == jobId then
                table.remove(history, index)
            end
        end
        table.insert(history, jobId)
        while #history > limit do
            table.remove(history, 1)
        end
        return history
    end

    function ServerHopPolicy.isVisited(history, jobId)
        for _, visitedId in ipairs(history) do
            if visitedId == jobId then
                return true
            end
        end
        return false
    end

    function ServerHopPolicy.shouldHop(totalPlayers, otherLevels, levelLimit, hasUnknown)
        if totalPlayers <= 1 then
            return true, "sozinho no servidor"
        end
        for playerName, level in pairs(otherLevels) do
            if level >= levelLimit then
                return true, string.format("%s esta no nivel %d", playerName, level)
            end
        end
        if hasUnknown then
            return true, "nivel de outro jogador nao identificado"
        end
        return false, nil
    end

    function ServerHopPolicy.eligibleServers(servers, currentJobId, history)
        local result = {}
        for _, server in ipairs(servers) do
            local id = server.id
            local playing = tonumber(server.playing) or 0
            local maxPlayers = tonumber(server.maxPlayers) or 0
            if typeof(id) == "string"
                and id ~= ""
                and id ~= currentJobId
                and not ServerHopPolicy.isVisited(history, id)
                and playing > 0
                and playing < maxPlayers
            then
                table.insert(result, server)
            end
        end
        return result
    end

    return ServerHopPolicy
end

__factories["Core/StateStore"] = function()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")

    local StateStore = {}
    StateStore.__index = StateStore

    local TELEPORT_KEY = "GOATHubSTK_State_v1"
    local GLOBAL_KEY = "__GOATHUB_STK_STATE_V1"

    local function environment()
        if typeof(getgenv) == "function" then
            return getgenv()
        end
        return _G
    end

    local function copySupported(source)
        local result = {}
        if typeof(source) ~= "table" then
            return result
        end
        for key, value in pairs(source) do
            local valueType = typeof(value)
            if typeof(key) == "string"
                and (valueType == "boolean" or valueType == "number" or valueType == "string")
            then
                result[key] = value
            end
        end
        return result
    end

    function StateStore.new()
        local env = environment()
        local values = nil
        local ok, stored = pcall(function()
            return TeleportService:GetTeleportSetting(TELEPORT_KEY)
        end)
        if ok and typeof(stored) == "string" and stored ~= "" then
            local decodedOk, decoded = pcall(function()
                return HttpService:JSONDecode(stored)
            end)
            if decodedOk then
                values = decoded
            end
        elseif ok and typeof(stored) == "table" then
            values = stored
        end
        if typeof(values) ~= "table" then
            values = env[GLOBAL_KEY]
        end

        local self = setmetatable({
            values = copySupported(values),
            env = env,
        }, StateStore)
        self.env[GLOBAL_KEY] = self.values
        return self
    end

    function StateStore:_save()
        self.env[GLOBAL_KEY] = self.values
        local ok, encoded = pcall(function()
            return HttpService:JSONEncode(self.values)
        end)
        if ok then
            pcall(function()
                TeleportService:SetTeleportSetting(TELEPORT_KEY, encoded)
            end)
        end
    end

    function StateStore:getBoolean(key, defaultValue)
        local value = self.values[key]
        if typeof(value) == "boolean" then
            return value
        end
        return defaultValue == true
    end

    function StateStore:has(key)
        return self.values[key] ~= nil
    end

    function StateStore:getNumber(key, defaultValue, minimum, maximum)
        local value = tonumber(self.values[key]) or tonumber(defaultValue) or 0
        if minimum ~= nil and maximum ~= nil then
            value = math.clamp(value, minimum, maximum)
        end
        return value
    end

    function StateStore:setBoolean(key, value)
        value = value == true
        if self.values[key] == value then
            return
        end
        self.values[key] = value
        self:_save()
    end

    function StateStore:setNumber(key, value, minimum, maximum)
        value = tonumber(value) or 0
        if minimum ~= nil and maximum ~= nil then
            value = math.clamp(value, minimum, maximum)
        end
        if self.values[key] == value then
            return
        end
        self.values[key] = value
        self:_save()
    end

    function StateStore:remove(key)
        if self.values[key] == nil then
            return
        end
        self.values[key] = nil
        self:_save()
    end

    function StateStore:flush()
        self:_save()
    end

    return StateStore
end

__factories["Features/AttributeOverrides"] = function()
    local Runtime = __require("Core/Runtime")

    local AttributeOverrides = {}
    AttributeOverrides.__index = AttributeOverrides

    function AttributeOverrides.new(onStatus)
        return setmetatable({
            onStatus = onStatus or function() end,
            enabled = true,
            overrides = {},
        }, AttributeOverrides)
    end

    function AttributeOverrides:_key(containerName, attribute)
        return containerName .. "\0" .. attribute
    end

    function AttributeOverrides:_container(containerName)
        return Runtime.LocalPlayer:FindFirstChild(containerName)
            or Runtime.LocalPlayer:WaitForChild(containerName, 10)
    end

    function AttributeOverrides:_restoreEntry(key, entry)
        self.overrides[key] = nil
        if entry.connection then
            entry.connection:Disconnect()
        end
        if entry.container and entry.container.Parent then
            entry.container:SetAttribute(entry.attribute, entry.original)
        end
    end

    function AttributeOverrides:setOverride(containerName, attribute, enabled, owner)
        local key = self:_key(containerName, attribute)
        local existing = self.overrides[key]
        owner = tostring(owner or "default")

        if enabled == true then
            if not self.enabled then
                return false
            end
            if existing then
                existing.owners[owner] = true
                if existing.container:GetAttribute(attribute) ~= true then
                    existing.writing = true
                    existing.container:SetAttribute(attribute, true)
                    existing.writing = false
                end
                return true
            end

            local container = self:_container(containerName)
            if not container then
                self.onStatus("Atributos: " .. containerName .. " nao encontrado")
                return false
            end

            local entry = {
                container = container,
                attribute = attribute,
                original = container:GetAttribute(attribute),
                owners = {
                    [owner] = true,
                },
                writing = false,
                connection = nil,
            }
            self.overrides[key] = entry
            entry.connection = container:GetAttributeChangedSignal(attribute):Connect(function()
                if self.overrides[key] ~= entry or entry.writing then
                    return
                end
                if container:GetAttribute(attribute) ~= true then
                    entry.writing = true
                    container:SetAttribute(attribute, true)
                    entry.writing = false
                end
            end)

            entry.writing = true
            container:SetAttribute(attribute, true)
            entry.writing = false
            self.onStatus(containerName .. "." .. attribute .. " = true (local)")
            return true
        end

        if not existing then
            return true
        end
        existing.owners[owner] = nil
        if next(existing.owners) ~= nil then
            return true
        end
        self:_restoreEntry(key, existing)
        self.onStatus(containerName .. "." .. attribute .. " restaurado")
        return true
    end

    function AttributeOverrides:_restoreAll()
        local keys = {}
        for key in pairs(self.overrides) do
            table.insert(keys, key)
        end
        for _, key in ipairs(keys) do
            local entry = self.overrides[key]
            if entry then
                self:_restoreEntry(key, entry)
            end
        end
    end

    function AttributeOverrides:setEnabled(enabled)
        self.enabled = enabled == true
        if not self.enabled then
            self:_restoreAll()
        end
    end

    function AttributeOverrides:stop()
        self:setEnabled(false)
    end

    function AttributeOverrides:Destroy()
        self:stop()
    end

    return AttributeOverrides
end

__factories["Features/AutoEscape"] = function()
    local CollectionService = game:GetService("CollectionService")
    local Workspace = game:GetService("Workspace")

    local Config = __require("Config")
    local Runtime = __require("Core/Runtime")

    local AutoEscape = {}
    AutoEscape.__index = AutoEscape

    local OWNER = "AutoEscape"

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
        local moved, token = self.movement:move(OWNER, destination)
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

        local moved = self.movement:move(OWNER, destination)
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

    local Config = __require("Config")
    local Runtime = __require("Core/Runtime")

    local AutoLoot = {}
    AutoLoot.__index = AutoLoot

    local OWNER = "AutoLoot"

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
            if (self.cooldowns[loot.instance] or 0) <= now
                and self.mapProvider:isLootAvailable(loot.instance)
            then
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
        if not root
            or not loot.border.Parent
            or not self.mapProvider:isLootAvailable(loot.instance)
        then
            return false
        end

        self.cooldowns[loot.instance] = os.clock() + Config.TIMING.LOOT_RETRY
        local destination = loot.border.CFrame + Vector3.new(0, 1.5, 0)
        local moved, token = self.movement:move(OWNER, destination)
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

    function AutoRevive.new(movement, onStatus)
        return setmetatable({
            movement = movement,
            onStatus = onStatus or function() end,
            enabled = false,
            generation = 0,
            dangerDistance = Config.DISTANCES.KILLER_EVADE,
            lastTarget = nil,
            rescueTarget = nil,
            returnCFrame = nil,
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
        self.movement:move(OWNER, destination)
    end

    function AutoRevive:_beginRescue(target)
        local character = Runtime.getCharacter()
        if not character then
            return false
        end
        self.rescueTarget = target
        self.returnCFrame = character:GetPivot()
        return true
    end

    function AutoRevive:_finishRescue(message)
        local destination = self.returnCFrame
        self.rescueTarget = nil
        self.returnCFrame = nil
        self.lastTarget = nil
        self.movement:stopOwner(OWNER)

        if destination
            and Runtime.isSurvivor()
            and Runtime.isAlive()
            and not Runtime.isDowned()
            and not Runtime.isEscaped()
        then
            if self.movement:move(OWNER, destination) then
                self.onStatus(message or "Auto Revive: voltando ao ponto anterior")
                return
            end
        end
        self.onStatus("Auto Revive: aguardando alvo seguro")
    end

    function AutoRevive:_rescueStillSafe(target)
        if target.Parent ~= Runtime.Players
            or not Runtime.isSurvivor(target)
            or not Runtime.isAlive(target)
            or Runtime.isEscaped(target)
            or target:GetAttribute("HeldByPlayer")
        then
            return false
        end
        local targetRoot = Runtime.getRoot(target)
        return targetRoot ~= nil
            and self:_nearestKillerDistance(targetRoot.Position) >= self.dangerDistance * 0.75
    end

    function AutoRevive:_loop(generation)
        while self.enabled and self.generation == generation do
            if not Runtime.isSurvivor() or not Runtime.isAlive() then
                self.lastTarget = nil
                self.rescueTarget = nil
                self.returnCFrame = nil
                task.wait(0.20)
                continue
            end

            local rescuingSelf = Runtime.isDowned()
            if rescuingSelf and self.rescueTarget then
                self.rescueTarget = nil
                self.returnCFrame = nil
                self.lastTarget = nil
            end

            if not rescuingSelf and self.rescueTarget then
                if not Runtime.isDowned(self.rescueTarget) then
                    self:_finishRescue("Auto Revive: jogador salvo; voltando ao ponto anterior")
                    task.wait(Config.TIMING.REVIVE_FOLLOW)
                    continue
                end
                if not self:_rescueStillSafe(self.rescueTarget) then
                    self:_finishRescue("Auto Revive: resgate cancelado; voltando ao ponto anterior")
                    task.wait(Config.TIMING.REVIVE_FOLLOW)
                    continue
                end
            end

            local target
            if rescuingSelf then
                target = self:_targetForSelf()
            elseif self.rescueTarget then
                target = self.rescueTarget
            else
                target = self:_targetToRevive()
                if target and not self:_beginRescue(target) then
                    target = nil
                end
            end
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
            if self.rescueTarget or self.returnCFrame then
                self:_finishRescue("Auto Revive: OFF; voltando ao ponto anterior")
            else
                self.movement:stopOwner(OWNER)
                self.onStatus("Auto Revive: OFF")
            end
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

__factories["Features/AutoServerHop"] = function()
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")

    local Config = __require("Config")
    local ServerHopPolicy = __require("Core/ServerHopPolicy")

    local AutoServerHop = {}
    AutoServerHop.__index = AutoServerHop

    local VISITED_KEY = "GOATHubSTK_VisitedServers"
    local ENABLED_KEY = "GOATHubSTK_AutoServerHop"
    local LEVEL_KEY = "GOATHubSTK_LevelLimit"

    local function getQueueFunction()
        if typeof(queue_on_teleport) == "function" then
            return queue_on_teleport
        end
        if typeof(queueonteleport) == "function" then
            return queueonteleport
        end
        if typeof(syn) == "table" and typeof(syn.queue_on_teleport) == "function" then
            return syn.queue_on_teleport
        end
        return nil
    end

    local function environment()
        if typeof(getgenv) == "function" then
            return getgenv()
        end
        return _G
    end

    function AutoServerHop.new(onStatus)
        local self = setmetatable({
            onStatus = onStatus or function() end,
            enabled = false,
            generation = 0,
            hopping = false,
            wake = false,
            nextAttempt = 0,
            connections = {},
            playerConnections = {},
            lastStatus = "",
            visited = {},
            levelLimit = Config.SERVER_HOP.DEFAULT_LEVEL_LIMIT,
            resumeRequested = false,
        }, AutoServerHop)

        local savedVisited = self:_getTeleportSetting(VISITED_KEY)
        if typeof(savedVisited) == "table" then
            for _, jobId in ipairs(savedVisited) do
                if typeof(jobId) == "string" and jobId ~= "" then
                    ServerHopPolicy.pushVisited(
                        self.visited,
                        jobId,
                        Config.SERVER_HOP.MAX_VISITED_SERVERS
                    )
                end
            end
        end

        local savedLevel = tonumber(self:_getTeleportSetting(LEVEL_KEY))
        if savedLevel then
            self.levelLimit = math.clamp(
                math.floor(savedLevel + 0.5),
                Config.SERVER_HOP.MIN_LEVEL_LIMIT,
                Config.SERVER_HOP.MAX_LEVEL_LIMIT
            )
        end
        self.resumeRequested = self:_getTeleportSetting(ENABLED_KEY) == true
        return self
    end

    function AutoServerHop:_status(message)
        if self.lastStatus ~= message then
            self.lastStatus = message
            self.onStatus(message)
        end
    end

    function AutoServerHop:_getTeleportSetting(key)
        local ok, value = pcall(function()
            return TeleportService:GetTeleportSetting(key)
        end)
        return ok and value or nil
    end

    function AutoServerHop:_setTeleportSetting(key, value)
        pcall(function()
            TeleportService:SetTeleportSetting(key, value)
        end)
    end

    function AutoServerHop:_saveState()
        self:_setTeleportSetting(VISITED_KEY, self.visited)
        self:_setTeleportSetting(LEVEL_KEY, self.levelLimit)
        self:_setTeleportSetting(ENABLED_KEY, self.enabled)
    end

    function AutoServerHop:_remember(jobId)
        ServerHopPolicy.pushVisited(
            self.visited,
            jobId,
            Config.SERVER_HOP.MAX_VISITED_SERVERS
        )
        self:_setTeleportSetting(VISITED_KEY, self.visited)
    end

    function AutoServerHop:shouldResume()
        return self.resumeRequested
    end

    function AutoServerHop:getLevelLimit()
        return self.levelLimit
    end

    function AutoServerHop:setLevelLimit(level)
        self.levelLimit = math.clamp(
            math.floor((tonumber(level) or self.levelLimit) + 0.5),
            Config.SERVER_HOP.MIN_LEVEL_LIMIT,
            Config.SERVER_HOP.MAX_LEVEL_LIMIT
        )
        self:_setTeleportSetting(LEVEL_KEY, self.levelLimit)
        self.wake = true
        self:_status("Auto Rejoin: limite ajustado para " .. tostring(self.levelLimit))
    end

    function AutoServerHop:_readGuiLevel(player)
        local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local menus = playerGui and playerGui:FindFirstChild("Menus")
        local playerList = menus and menus:FindFirstChild("PlayerList")
        local portraits = playerList and playerList:FindFirstChild("Portraits")
        local portrait = portraits and portraits:FindFirstChild(player.Name)
        local rankBadge = portrait and portrait:FindFirstChild("RankBadge")
        local levelLabel = rankBadge and rankBadge:FindFirstChild("Level")
        return levelLabel and ServerHopPolicy.parseLevel(levelLabel.Text) or nil
    end

    function AutoServerHop:_readLevel(player)
        if player == Players.LocalPlayer then
            return nil
        end
        return ServerHopPolicy.parseLevel(player:GetAttribute("Level"))
            or self:_readGuiLevel(player)
    end

    function AutoServerHop:_audit(generation)
        local deadline = os.clock() + Config.SERVER_HOP.LEVEL_WAIT
        while self.enabled and self.generation == generation and not self.hopping do
            local currentPlayers = Players:GetPlayers()
            local otherLevels = {}
            local hasUnknown = false

            for _, player in ipairs(currentPlayers) do
                if player ~= Players.LocalPlayer then
                    local level = self:_readLevel(player)
                    if level == nil then
                        hasUnknown = true
                    else
                        otherLevels[player.Name] = level
                    end
                end
            end

            local shouldHop, reason = ServerHopPolicy.shouldHop(
                #currentPlayers,
                otherLevels,
                self.levelLimit,
                false
            )
            if shouldHop then
                self:_hop(reason)
                return
            end
            if not hasUnknown then
                self:_status("Auto Rejoin: servidor aprovado; outros jogadores abaixo de " .. tostring(self.levelLimit))
                return
            end
            if os.clock() >= deadline then
                local strictHop, strictReason = ServerHopPolicy.shouldHop(
                    #currentPlayers,
                    otherLevels,
                    self.levelLimit,
                    true
                )
                if strictHop then
                    self:_hop(strictReason)
                end
                return
            end
            task.wait(0.15)
        end
    end

    function AutoServerHop:_fetchServers()
        local servers = {}
        local cursor = nil

        for _ = 1, Config.SERVER_HOP.MAX_SERVER_PAGES do
            local url = string.format(
                "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100",
                game.PlaceId
            )
            if cursor then
                url ..= "&cursor=" .. HttpService:UrlEncode(cursor)
            end

            local ok, decoded = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            if not ok or typeof(decoded) ~= "table" then
                return nil, tostring(decoded)
            end

            if typeof(decoded.data) == "table" then
                for _, server in ipairs(decoded.data) do
                    table.insert(servers, server)
                end
            end
            cursor = decoded.nextPageCursor
            if typeof(cursor) ~= "string" or cursor == "" then
                break
            end
        end
        return servers, nil
    end

    function AutoServerHop:_queueReload()
        local url = Config.SERVER_HOP.RELOAD_URL
        if typeof(url) ~= "string" or url == "" then
            url = environment().__GOATHUB_STK_RELOAD_URL
        end
        local queue = getQueueFunction()
        if not queue or typeof(url) ~= "string" or url == "" then
            return false
        end

        local source = string.format(
            "local e=typeof(getgenv)=='function' and getgenv() or _G;"
                .. "e.__GOATHUB_STK_RELOAD_URL=%q;loadstring(game:HttpGet(%q))()",
            url,
            url
        )
        return pcall(queue, source)
    end

    function AutoServerHop:_hop(reason)
        if self.hopping or os.clock() < self.nextAttempt then
            return
        end
        self.hopping = true
        self:_status("Auto Rejoin: procurando outro servidor — " .. tostring(reason))
        self:_remember(game.JobId)

        local servers, fetchError = self:_fetchServers()
        if not servers then
            self.hopping = false
            self.nextAttempt = os.clock() + Config.SERVER_HOP.RETRY_DELAY
            self:_status("Auto Rejoin: falha ao listar servidores — " .. tostring(fetchError))
            return
        end

        local candidates = ServerHopPolicy.eligibleServers(servers, game.JobId, self.visited)
        if #candidates == 0 then
            self.hopping = false
            self.nextAttempt = os.clock() + Config.SERVER_HOP.RETRY_DELAY
            self:_status("Auto Rejoin: nenhum servidor publico diferente disponivel")
            return
        end

        local selected = candidates[math.random(1, #candidates)]
        self:_remember(selected.id)
        self:_saveState()
        self:_queueReload()
        self:_status(string.format(
            "Auto Rejoin: entrando em %s (%d/%d jogadores)",
            selected.id,
            tonumber(selected.playing) or 0,
            tonumber(selected.maxPlayers) or 0
        ))

        local ok, teleportError = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, selected.id, Players.LocalPlayer)
        end)
        if not ok then
            self.hopping = false
            self.nextAttempt = os.clock() + Config.SERVER_HOP.RETRY_DELAY
            self:_status("Auto Rejoin: teleport falhou — " .. tostring(teleportError))
        end
    end

    function AutoServerHop:_watchPlayer(player)
        if player == Players.LocalPlayer or self.playerConnections[player] then
            return
        end
        self.playerConnections[player] = player:GetAttributeChangedSignal("Level"):Connect(function()
            self.wake = true
        end)
    end

    function AutoServerHop:_unwatchPlayer(player)
        local connection = self.playerConnections[player]
        if connection then
            connection:Disconnect()
            self.playerConnections[player] = nil
        end
    end

    function AutoServerHop:_disconnect()
        for _, connection in ipairs(self.connections) do
            connection:Disconnect()
        end
        table.clear(self.connections)
        for player, connection in pairs(self.playerConnections) do
            connection:Disconnect()
            self.playerConnections[player] = nil
        end
    end

    function AutoServerHop:_loop(generation)
        task.wait(0.75)
        while self.enabled and self.generation == generation do
            if not self.hopping and os.clock() >= self.nextAttempt then
                self:_audit(generation)
            end
            local delayTime = self.wake and 0.05 or Config.SERVER_HOP.POLL
            self.wake = false
            task.wait(delayTime)
        end
    end

    function AutoServerHop:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then
            return
        end
        self.enabled = enabled
        self.generation += 1
        self.hopping = false
        self.wake = true
        self.nextAttempt = 0
        self:_disconnect()
        self:_setTeleportSetting(ENABLED_KEY, enabled)

        if enabled then
            self:_remember(game.JobId)
            table.insert(self.connections, Players.PlayerAdded:Connect(function(player)
                self:_watchPlayer(player)
                self.wake = true
            end))
            table.insert(self.connections, Players.PlayerRemoving:Connect(function(player)
                self:_unwatchPlayer(player)
                self.wake = true
            end))
            table.insert(self.connections, TeleportService.TeleportInitFailed:Connect(function(player, _, message)
                if player == Players.LocalPlayer then
                    self.hopping = false
                    self.nextAttempt = os.clock() + Config.SERVER_HOP.RETRY_DELAY
                    self:_status("Auto Rejoin: teleport recusado — " .. tostring(message))
                end
            end))
            for _, player in ipairs(Players:GetPlayers()) do
                self:_watchPlayer(player)
            end
            self:_saveState()
            local generation = self.generation
            task.spawn(function()
                self:_loop(generation)
            end)
            return
        end

        self:_status("Auto Rejoin: OFF")
    end

    function AutoServerHop:stop()
        self:setEnabled(false)
    end

    function AutoServerHop:Destroy()
        self:stop()
    end

    return AutoServerHop
end

__factories["Features/FOVOverride"] = function()
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")

    local Config = __require("Config")

    local FOVOverride = {}
    FOVOverride.__index = FOVOverride

    local BIND_NAME = "GOATHubSTK_FOVOverride"

    local function clampFOV(value)
        return math.clamp(
            tonumber(value) or Config.CAMERA.DEFAULT_FOV,
            Config.CAMERA.MIN_FOV,
            Config.CAMERA.MAX_FOV
        )
    end

    function FOVOverride.new(onStatus)
        local self = setmetatable({
            onStatus = onStatus or function() end,
            enabled = false,
            cameraConnection = nil,
            workspaceConnection = nil,
            originals = setmetatable({}, { __mode = "k" }),
            writing = false,
            targetFOV = clampFOV(Config.CAMERA.DEFAULT_FOV),
            renderBound = false,
            renderConnection = nil,
        }, FOVOverride)

        self.workspaceConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            self:_bindCamera()
        end)
        return self
    end

    function FOVOverride:_apply(camera)
        if not self.enabled or not camera or self.writing then
            return
        end
        if self.originals[camera] == nil then
            self.originals[camera] = camera.FieldOfView
        end
        if camera.FieldOfView ~= self.targetFOV then
            self.writing = true
            pcall(function()
                camera.FieldOfView = self.targetFOV
            end)
            self.writing = false
        end
    end

    function FOVOverride:_unbindRender()
        if self.renderBound then
            pcall(function()
                RunService:UnbindFromRenderStep(BIND_NAME)
            end)
            self.renderBound = false
        end
        if self.renderConnection then
            self.renderConnection:Disconnect()
            self.renderConnection = nil
        end
    end

    function FOVOverride:_bindRender()
        self:_unbindRender()
        local bound = pcall(function()
            RunService:BindToRenderStep(BIND_NAME, Enum.RenderPriority.Last.Value, function()
                self:_apply(Workspace.CurrentCamera)
            end)
        end)
        if bound then
            self.renderBound = true
            return
        end
        self.renderConnection = RunService.RenderStepped:Connect(function()
            self:_apply(Workspace.CurrentCamera)
        end)
    end

    function FOVOverride:_bindCamera()
        if self.cameraConnection then
            self.cameraConnection:Disconnect()
            self.cameraConnection = nil
        end

        local camera = Workspace.CurrentCamera
        if camera and self.enabled then
            self:_apply(camera)
            self.cameraConnection = camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
                if not self.writing and camera.FieldOfView ~= self.targetFOV then
                    self.originals[camera] = camera.FieldOfView
                end
                self:_apply(camera)
            end)
        end
    end

    function FOVOverride:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then
            return
        end
        self.enabled = enabled

        if enabled then
            self:_bindCamera()
            self:_bindRender()
            self.onStatus("FOV: fixado em " .. tostring(math.floor(self.targetFOV + 0.5)))
            return
        end

        self:_unbindRender()
        if self.cameraConnection then
            self.cameraConnection:Disconnect()
            self.cameraConnection = nil
        end
        self.writing = true
        for camera, original in pairs(self.originals) do
            pcall(function()
                camera.FieldOfView = original
            end)
        end
        self.writing = false
        table.clear(self.originals)
        self.onStatus("FOV: valor anterior restaurado")
    end

    function FOVOverride:getFOV()
        return self.targetFOV
    end

    function FOVOverride:setFOV(value)
        self.targetFOV = clampFOV(value)
        self:_apply(Workspace.CurrentCamera)
        if self.enabled then
            self.onStatus("FOV: fixado em " .. tostring(math.floor(self.targetFOV + 0.5)))
        end
        return self.targetFOV
    end

    function FOVOverride:stop()
        self:setEnabled(false)
    end

    function FOVOverride:Destroy()
        self:stop()
        if self.workspaceConnection then
            self.workspaceConnection:Disconnect()
            self.workspaceConnection = nil
        end
    end

    return FOVOverride
end

__factories["Features/KillAll"] = function()
    local Config = __require("Config")
    local Runtime = __require("Core/Runtime")

    local KillAll = {}
    KillAll.__index = KillAll

    local OWNER = "KillAll"

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
        local moved, token = self.movement:move(OWNER, destination)
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

__factories["Features/LootESP"] = function()
    local CollectionService = game:GetService("CollectionService")

    local Config = __require("Config")

    local LootESP = {}
    LootESP.__index = LootESP

    local HIGHLIGHT_NAME = "GOATHubSTK_LootAura"
    local LABEL_NAME = "GOATHubSTK_LootLabel"

    function LootESP.new(mapProvider, lootCatalog, onStatus)
        local self = setmetatable({
            mapProvider = mapProvider,
            lootCatalog = lootCatalog,
            onStatus = onStatus or function() end,
            enabled = false,
            generation = 0,
            visuals = {},
            wake = false,
            connections = {},
        }, LootESP)

        table.insert(self.connections, CollectionService:GetInstanceAddedSignal("Loot"):Connect(function()
            self.wake = true
        end))
        table.insert(self.connections, CollectionService:GetInstanceRemovedSignal("Loot"):Connect(function()
            self.wake = true
        end))
        return self
    end

    function LootESP:_destroyVisual(instance)
        local visual = self.visuals[instance]
        self.visuals[instance] = nil
        if not visual then
            return
        end
        if visual.highlight then
            visual.highlight:Destroy()
        end
        if visual.billboard then
            visual.billboard:Destroy()
        end
    end

    function LootESP:_createVisual(loot, item)
        local oldHighlight = loot.instance:FindFirstChild(HIGHLIGHT_NAME)
        if oldHighlight then
            oldHighlight:Destroy()
        end
        local oldLabel = loot.border:FindFirstChild(LABEL_NAME)
        if oldLabel then
            oldLabel:Destroy()
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = HIGHLIGHT_NAME
        highlight.Adornee = loot.instance
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = item.color
        highlight.OutlineColor = item.color:Lerp(Color3.new(1, 1, 1), 0.38)
        highlight.FillTransparency = 0.62
        highlight.OutlineTransparency = 0
        highlight.Parent = loot.instance

        local billboard = Instance.new("BillboardGui")
        billboard.Name = LABEL_NAME
        billboard.Adornee = loot.border
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.fromOffset(180, 44)
        billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.1, 0)
        billboard.MaxDistance = Config.LOOT_ESP.MAX_DISTANCE
        billboard.Parent = loot.border

        local text = Instance.new("TextLabel")
        text.Size = UDim2.fromScale(1, 1)
        text.BackgroundTransparency = 1
        text.Text = item.label
        text.TextColor3 = item.color
        text.TextStrokeColor3 = Color3.fromRGB(9, 12, 19)
        text.TextStrokeTransparency = 0.18
        text.Font = Enum.Font.GothamBold
        text.TextSize = 12
        text.TextWrapped = true
        text.Parent = billboard

        self.visuals[loot.instance] = {
            border = loot.border,
            signature = item.signature,
            highlight = highlight,
            billboard = billboard,
        }
    end

    function LootESP:_sync()
        local seen = {}
        for _, loot in ipairs(self.mapProvider:getLoot()) do
            if loot.instance.Parent
                and loot.border.Parent
                and self.mapProvider:isLootAvailable(loot.instance)
            then
                seen[loot.instance] = true
                local item = self.lootCatalog:get(loot.id)
                local visual = self.visuals[loot.instance]
                if not visual
                    or visual.border ~= loot.border
                    or visual.signature ~= item.signature
                    or not visual.highlight.Parent
                    or not visual.billboard.Parent
                then
                    self:_destroyVisual(loot.instance)
                    self:_createVisual(loot, item)
                end
            end
        end

        local stale = {}
        for instance in pairs(self.visuals) do
            if not seen[instance] then
                table.insert(stale, instance)
            end
        end
        for _, instance in ipairs(stale) do
            self:_destroyVisual(instance)
        end
    end

    function LootESP:_clear()
        local instances = {}
        for instance in pairs(self.visuals) do
            table.insert(instances, instance)
        end
        for _, instance in ipairs(instances) do
            self:_destroyVisual(instance)
        end
    end

    function LootESP:_clearTaggedArtifacts()
        for _, instance in ipairs(CollectionService:GetTagged("Loot")) do
            local highlight = instance:FindFirstChild(HIGHLIGHT_NAME)
            if highlight then
                highlight:Destroy()
            end
            local border = instance:FindFirstChild("Border")
            local billboard = border and border:FindFirstChild(LABEL_NAME)
            if billboard then
                billboard:Destroy()
            end
        end
    end

    function LootESP:_loop(generation)
        while self.enabled and self.generation == generation do
            self:_sync()
            local delayTime = self.wake and 0.03 or Config.TIMING.LOOT_ESP_POLL
            self.wake = false
            task.wait(delayTime)
        end
    end

    function LootESP:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then
            return
        end
        if enabled then
            self.enabled = true
            self.generation += 1
            self.wake = true
            self:_clearTaggedArtifacts()
            local generation = self.generation
            task.spawn(function()
                self:_loop(generation)
            end)
            if self.lootCatalog:isLoaded() then
                self.onStatus("Loot ESP: nome, valor e cor por preco")
            else
                self.onStatus("Loot ESP: catalogo indisponivel; usando IDs")
            end
        else
            self:stop()
            self.onStatus("Loot ESP: OFF")
        end
    end

    function LootESP:stop()
        self.enabled = false
        self.generation += 1
        self:_clear()
        self:_clearTaggedArtifacts()
    end

    function LootESP:Destroy()
        self:stop()
        for _, connection in ipairs(self.connections) do
            connection:Disconnect()
        end
        table.clear(self.connections)
    end

    return LootESP
end

__factories["Features/PlayerOverrides"] = function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local Config = __require("Config")
    local Runtime = __require("Core/Runtime")

    local PlayerOverrides = {}
    PlayerOverrides.__index = PlayerOverrides

    local function clamp(value, minimum, maximum, fallback)
        return math.clamp(tonumber(value) or fallback, minimum, maximum)
    end

    function PlayerOverrides.new(onStatus)
        local player = Players.LocalPlayer
        local humanoid = Runtime.getHumanoid(player)
        local walkSpeed = player:GetAttribute("WalkSpeed")
        if typeof(walkSpeed) ~= "number" and humanoid then
            walkSpeed = humanoid.WalkSpeed
        end
        local jumpHeight = player:GetAttribute("JumpHeight")
        if typeof(jumpHeight) ~= "number" and humanoid then
            jumpHeight = humanoid.JumpHeight
        end

        local self = setmetatable({
            onStatus = onStatus or function() end,
            player = player,
            enabled = true,
            walkSpeedEnabled = false,
            jumpHeightEnabled = false,
            walkSpeed = clamp(
                walkSpeed,
                Config.PLAYER.MIN_WALK_SPEED,
                Config.PLAYER.MAX_WALK_SPEED,
                Config.PLAYER.DEFAULT_WALK_SPEED
            ),
            jumpHeight = clamp(
                jumpHeight,
                Config.PLAYER.MIN_JUMP_HEIGHT,
                Config.PLAYER.MAX_JUMP_HEIGHT,
                Config.PLAYER.DEFAULT_JUMP_HEIGHT
            ),
            originalAttributes = {},
            humanoidOriginals = setmetatable({}, { __mode = "k" }),
            connections = {},
            humanoidConnections = {},
            humanoid = nil,
            writing = false,
            destroyed = false,
        }, PlayerOverrides)

        table.insert(self.connections, player.CharacterAdded:Connect(function(character)
            local nextHumanoid = character:WaitForChild("Humanoid", 10)
            if nextHumanoid and nextHumanoid:IsA("Humanoid") then
                self:_bindHumanoid(nextHumanoid)
            end
        end))
        table.insert(self.connections, player:GetAttributeChangedSignal("WalkSpeed"):Connect(function()
            self:_attributeChanged("WalkSpeed")
        end))
        table.insert(self.connections, player:GetAttributeChangedSignal("JumpHeight"):Connect(function()
            self:_attributeChanged("JumpHeight")
        end))
        table.insert(self.connections, RunService.Stepped:Connect(function()
            self:_enforce()
        end))
        self:_bindHumanoid(humanoid)
        return self
    end

    function PlayerOverrides:_captureAttribute(name)
        if self.originalAttributes[name] then
            return
        end
        local value = self.player:GetAttribute(name)
        self.originalAttributes[name] = {
            existed = value ~= nil,
            value = value,
        }
    end

    function PlayerOverrides:_attributeChanged(name)
        if self.destroyed or self.writing then
            return
        end
        local isEnabled = name == "WalkSpeed"
            and self.walkSpeedEnabled
            or name == "JumpHeight" and self.jumpHeightEnabled
        if not isEnabled then
            return
        end
        local original = self.originalAttributes[name]
        if original then
            local value = self.player:GetAttribute(name)
            local target = name == "WalkSpeed" and self.walkSpeed or self.jumpHeight
            if value ~= target then
                original.existed = value ~= nil
                original.value = value
            end
        end
        self:_enforce()
    end

    function PlayerOverrides:_disconnectHumanoid()
        for _, connection in ipairs(self.humanoidConnections) do
            connection:Disconnect()
        end
        table.clear(self.humanoidConnections)
        self.humanoid = nil
    end

    function PlayerOverrides:_captureHumanoid(humanoid)
        if not humanoid or not humanoid.Parent then
            return nil
        end
        local original = self.humanoidOriginals[humanoid]
        if not original then
            original = {}
            self.humanoidOriginals[humanoid] = original
        end
        if self.walkSpeedEnabled and original.walkSpeed == nil then
            original.walkSpeed = humanoid.WalkSpeed
        end
        if self.jumpHeightEnabled and original.jumpHeight == nil then
            original.jumpHeight = humanoid.JumpHeight
        end
        return original
    end

    function PlayerOverrides:_humanoidChanged(property)
        if self.destroyed or self.writing or not self.humanoid then
            return
        end
        local isEnabled = property == "WalkSpeed"
            and self.walkSpeedEnabled
            or property == "JumpHeight" and self.jumpHeightEnabled
        if not isEnabled then
            return
        end
        local original = self.humanoidOriginals[self.humanoid]
        if original then
            if property == "WalkSpeed" then
                if self.humanoid.WalkSpeed ~= self.walkSpeed then
                    original.walkSpeed = self.humanoid.WalkSpeed
                end
            else
                if self.humanoid.JumpHeight ~= self.jumpHeight then
                    original.jumpHeight = self.humanoid.JumpHeight
                end
            end
        end
        self:_enforce()
    end

    function PlayerOverrides:_bindHumanoid(humanoid)
        self:_disconnectHumanoid()
        if not humanoid or not humanoid.Parent then
            return
        end
        self.humanoid = humanoid
        table.insert(self.humanoidConnections, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            self:_humanoidChanged("WalkSpeed")
        end))
        table.insert(self.humanoidConnections, humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
            self:_humanoidChanged("JumpHeight")
        end))
        self:_captureHumanoid(humanoid)
        self:_enforce()
    end

    function PlayerOverrides:_enforce()
        if self.destroyed or not self.enabled or self.writing then
            return
        end
        local humanoid = Runtime.getHumanoid(self.player)
        if humanoid and humanoid ~= self.humanoid then
            self:_bindHumanoid(humanoid)
            return
        end

        self.writing = true
        if self.walkSpeedEnabled then
            self:_captureAttribute("WalkSpeed")
            if self.player:GetAttribute("WalkSpeed") ~= self.walkSpeed then
                self.player:SetAttribute("WalkSpeed", self.walkSpeed)
            end
            if humanoid then
                self:_captureHumanoid(humanoid)
                if humanoid.WalkSpeed ~= self.walkSpeed then
                    humanoid.WalkSpeed = self.walkSpeed
                end
            end
        end
        if self.jumpHeightEnabled then
            self:_captureAttribute("JumpHeight")
            if self.player:GetAttribute("JumpHeight") ~= self.jumpHeight then
                self.player:SetAttribute("JumpHeight", self.jumpHeight)
            end
            if humanoid then
                self:_captureHumanoid(humanoid)
                if humanoid.JumpHeight ~= self.jumpHeight then
                    humanoid.JumpHeight = self.jumpHeight
                end
            end
        end
        self.writing = false
    end

    function PlayerOverrides:_restoreAttribute(name)
        local original = self.originalAttributes[name]
        self.originalAttributes[name] = nil
        if not original then
            return
        end
        if original.existed then
            self.player:SetAttribute(name, original.value)
        else
            self.player:SetAttribute(name, nil)
        end
    end

    function PlayerOverrides:_restoreHumanoids(property)
        for humanoid, original in pairs(self.humanoidOriginals) do
            if humanoid.Parent then
                local value = original[property]
                if value ~= nil then
                    if property == "walkSpeed" then
                        humanoid.WalkSpeed = value
                    else
                        humanoid.JumpHeight = value
                    end
                end
            end
            original[property] = nil
            if original.walkSpeed == nil and original.jumpHeight == nil then
                self.humanoidOriginals[humanoid] = nil
            end
        end
    end

    function PlayerOverrides:getWalkSpeed()
        return self.walkSpeed
    end

    function PlayerOverrides:setWalkSpeed(value)
        self.walkSpeed = clamp(
            value,
            Config.PLAYER.MIN_WALK_SPEED,
            Config.PLAYER.MAX_WALK_SPEED,
            Config.PLAYER.DEFAULT_WALK_SPEED
        )
        self:_enforce()
        return self.walkSpeed
    end

    function PlayerOverrides:getJumpHeight()
        return self.jumpHeight
    end

    function PlayerOverrides:setJumpHeight(value)
        self.jumpHeight = clamp(
            value,
            Config.PLAYER.MIN_JUMP_HEIGHT,
            Config.PLAYER.MAX_JUMP_HEIGHT,
            Config.PLAYER.DEFAULT_JUMP_HEIGHT
        )
        self:_enforce()
        return self.jumpHeight
    end

    function PlayerOverrides:setWalkSpeedEnabled(enabled)
        enabled = enabled == true
        if self.walkSpeedEnabled == enabled then
            return
        end
        if enabled then
            self.walkSpeedEnabled = true
            self:_captureAttribute("WalkSpeed")
            self:_captureHumanoid(Runtime.getHumanoid(self.player))
            self:_enforce()
            self.onStatus("Player: velocidade fixada em " .. tostring(math.floor(self.walkSpeed + 0.5)))
            return
        end

        self.walkSpeedEnabled = false
        self.writing = true
        self:_restoreAttribute("WalkSpeed")
        self:_restoreHumanoids("walkSpeed")
        self.writing = false
        self.onStatus("Player: velocidade restaurada")
    end

    function PlayerOverrides:setJumpHeightEnabled(enabled)
        enabled = enabled == true
        if self.jumpHeightEnabled == enabled then
            return
        end
        if enabled then
            self.jumpHeightEnabled = true
            self:_captureAttribute("JumpHeight")
            self:_captureHumanoid(Runtime.getHumanoid(self.player))
            self:_enforce()
            self.onStatus("Player: pulo fixado em " .. tostring(math.floor(self.jumpHeight + 0.5)))
            return
        end

        self.jumpHeightEnabled = false
        self.writing = true
        self:_restoreAttribute("JumpHeight")
        self:_restoreHumanoids("jumpHeight")
        self.writing = false
        self.onStatus("Player: pulo restaurado")
    end

    function PlayerOverrides:setEnabled(enabled)
        self.enabled = enabled == true
        if self.enabled then
            self:_enforce()
        else
            self:setWalkSpeedEnabled(false)
            self:setJumpHeightEnabled(false)
        end
    end

    function PlayerOverrides:stop()
        self:setWalkSpeedEnabled(false)
        self:setJumpHeightEnabled(false)
    end

    function PlayerOverrides:Destroy()
        if self.destroyed then
            return
        end
        self:stop()
        self.destroyed = true
        self:_disconnectHumanoid()
        for _, connection in ipairs(self.connections) do
            connection:Disconnect()
        end
        table.clear(self.connections)
    end

    return PlayerOverrides
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

__factories["Providers/LootCatalog"] = function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local LootPresentation = __require("Core/LootPresentation")

    local LootCatalog = {}
    LootCatalog.__index = LootCatalog

    local RARITY_NAMES = table.freeze({
        [0] = "Default",
        [1] = "Legacy",
        [2] = "Common",
        [3] = "Uncommon",
        [4] = "Rare",
        [5] = "Epic",
        [6] = "Legendary",
        [7] = "Spectrum",
        [8] = "Reaper",
        [9] = "Artifact",
        [10] = "Limited",
    })

    local COLORS = table.freeze({
        spectrum = Color3.fromRGB(205, 92, 255),
        legendary = Color3.fromRGB(255, 174, 62),
        epic = Color3.fromRGB(174, 104, 255),
        rare = Color3.fromRGB(80, 164, 255),
        uncommon = Color3.fromRGB(72, 214, 132),
        common = Color3.fromRGB(218, 225, 238),
        unknown = Color3.fromRGB(158, 170, 194),
    })

    function LootCatalog.new()
        local self = setmetatable({
            database = nil,
            retryAt = 0,
        }, LootCatalog)
        self:_load()
        return self
    end

    function LootCatalog:_load()
        local now = os.clock()
        if self.database or now < self.retryAt then
            return self.database ~= nil
        end
        self.retryAt = now + 2

        local databases = ReplicatedStorage:FindFirstChild("ItemDatabases")
        local lootModule = databases and databases:FindFirstChild("Loot")
        if not lootModule or not lootModule:IsA("ModuleScript") then
            return false
        end

        local ok, result = pcall(require, lootModule)
        if ok and typeof(result) == "table" then
            self.database = result
            return true
        end
        return false
    end

    function LootCatalog:isLoaded()
        return self.database ~= nil or self:_load()
    end

    function LootCatalog:get(id)
        id = tostring(id or "")
        self:_load()
        local entry = self.database and self.database[id] or nil
        local name = entry and entry.Name
        if typeof(name) ~= "string" or name == "" then
            name = id ~= "" and id or "Loot desconhecido"
        end

        local sellPrice = LootPresentation.normalizeValue(entry and entry.SellPrice)
        local rarityValue = entry and tonumber(entry.Rarity) or nil
        local rarityName = rarityValue and RARITY_NAMES[rarityValue] or "Unknown"
        local tier = LootPresentation.tierForValue(sellPrice)

        return {
            id = id,
            name = name,
            sellPrice = sellPrice,
            rarity = rarityName,
            tier = tier,
            color = COLORS[tier],
            label = LootPresentation.formatLabel(name, sellPrice),
            signature = table.concat({
                id,
                name,
                tostring(sellPrice),
                rarityName,
                tier,
            }, "\0"),
        }
    end

    return LootCatalog
end

__factories["Providers/MapProvider"] = function()
    local CollectionService = game:GetService("CollectionService")
    local PathfindingService = game:GetService("PathfindingService")
    local Workspace = game:GetService("Workspace")

    local Runtime = __require("Core/Runtime")
    local LootVisibility = __require("Core/LootVisibility")

    local MapProvider = {}
    MapProvider.__index = MapProvider

    local EXCLUDED_ANCESTORS = {
        LootSpawns = true,
        FuseSpawns = true,
        Lockers = true,
        Doorway = true,
        ExitEffect = true,
    }

    local EXCLUDED_TERMS = {
        "trigger",
        "collider",
        "ceiling",
        "roof",
        "wall",
        "barrier",
        "boundary",
        "bounds",
        "kill",
        "void",
        "invisible",
        "blocker",
        "border",
    }

    local MAX_PATH_CANDIDATES = 12

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

    local function hasExcludedIdentity(instance, boundary)
        local current = instance
        while current do
            local name = string.lower(current.Name)
            for _, term in ipairs(EXCLUDED_TERMS) do
                if string.find(name, term, 1, true) then
                    return true
                end
            end
            if current == boundary then
                break
            end
            current = current.Parent
        end
        return false
    end

    local function isWalkablePart(part, map)
        if not part:IsA("BasePart") or not part.Anchored or not part.CanCollide then
            return false
        end
        if part.Transparency >= 0.75 or part.Size.X < 6 or part.Size.Z < 6 then
            return false
        end
        if part.CFrame.UpVector.Y < 0.78 or hasExcludedIdentity(part, map) then
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

    local function raycastParamsFor(map)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Whitelist
        params.FilterDescendantsInstances = { map }
        params.IgnoreWater = true
        return params
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
                if border
                    and border:IsA("BasePart")
                    and typeof(lootID) == "string"
                    and lootID ~= ""
                    and self:isLootAvailable(instance)
                then
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

    function MapProvider:isLootAvailable(instance)
        return LootVisibility.isAvailable(instance)
    end

    function MapProvider:_pathStaysInsideMap(currentPosition, destination, map, raycastParams)
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentCanClimb = false,
            WaypointSpacing = 4,
        })
        local computed = pcall(function()
            path:ComputeAsync(currentPosition, destination)
        end)
        if not computed or path.Status ~= Enum.PathStatus.Success then
            return false
        end

        local waypoints = path:GetWaypoints()
        if #waypoints == 0 or (waypoints[#waypoints].Position - destination).Magnitude > 8 then
            return false
        end
        for _, waypoint in ipairs(waypoints) do
            local support = Workspace:Raycast(
                waypoint.Position + Vector3.new(0, 3, 0),
                Vector3.new(0, -14, 0),
                raycastParams
            )
            if not support or not support.Instance:IsDescendantOf(map) then
                return false
            end
        end
        return true
    end

    function MapProvider:findSafeCFrame(killerRoots, currentPosition, minimumTravel)
        self:_buildCandidates()
        local map = self:getMap()
        if not map then
            return nil
        end

        local raycastParams = raycastParamsFor(map)
        local scored = {}
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
                if hit
                    and hit.Instance
                    and hit.Normal.Y >= 0.62
                    and isWalkablePart(hit.Instance, map)
                then
                    local position = hit.Position + Vector3.new(0, 3.2, 0)
                    local travel = (position - currentPosition).Magnitude
                    local blockedAbove = Workspace:Raycast(
                        hit.Position + Vector3.new(0, 0.4, 0),
                        Vector3.new(0, 6, 0),
                        raycastParams
                    )
                    if travel >= minimumTravel and not blockedAbove then
                        local nearestKiller = math.huge
                        for _, killerRoot in ipairs(killerRoots) do
                            if killerRoot and killerRoot.Parent then
                                nearestKiller = math.min(nearestKiller, (position - killerRoot.Position).Magnitude)
                            end
                        end

                        local score = nearestKiller + math.min(travel, 80) * 0.15
                        table.insert(scored, {
                            score = score,
                            position = position,
                        })
                    end
                end
            end
        end

        table.sort(scored, function(first, second)
            return first.score > second.score
        end)
        for index = 1, math.min(#scored, MAX_PATH_CANDIDATES) do
            local candidate = scored[index]
            if self:_pathStaysInsideMap(currentPosition, candidate.position, map, raycastParams) then
                return CFrame.new(candidate.position)
            end
        end
        return nil
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

    local WIDTH_PERCENTAGES = {
        [25] = true,
        [50] = true,
        [75] = true,
        [100] = true,
    }

    function Layout.normalizeWidthPercent(value, defaultValue)
        value = tonumber(value)
        if WIDTH_PERCENTAGES[value] then
            return value
        end
        defaultValue = tonumber(defaultValue)
        if WIDTH_PERCENTAGES[defaultValue] then
            return defaultValue
        end
        return 50
    end

    function Layout.calculate(viewport, config, widthPercent)
        local padding = config.PADDING
        local availableWidth = math.max(1, viewport.X - padding * 2)
        local availableHeight = math.max(1, viewport.Y - padding * 2)

        local requestedWidth
        local width
        local narrow
        local compact
        local mode
        if widthPercent ~= nil then
            local normalized = Layout.normalizeWidthPercent(widthPercent, config.DEFAULT_WIDTH_PERCENT)
            requestedWidth = availableWidth * normalized / 100
            local minimumWidth = math.min(config.MIN_WIDTH or 1, availableWidth)
            width = math.clamp(math.floor(requestedWidth + 0.5), minimumWidth, availableWidth)
            narrow = width <= config.NARROW_BREAKPOINT
            compact = narrow or viewport.Y <= config.COMPACT_BREAKPOINT
            mode = narrow and "narrow" or (compact and "compact" or "desktop")
        else
            narrow = viewport.X <= config.NARROW_BREAKPOINT
            compact = narrow or viewport.Y <= config.COMPACT_BREAKPOINT
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
            width = math.min(requestedWidth, availableWidth)
        end

        return {
            mode = mode,
            padding = padding,
            width = width,
            height = math.min(config.DESKTOP_HEIGHT, availableHeight),
            centerX = viewport.X / 2,
            centerY = viewport.Y / 2,
            headerHeight = compact
                and (config.COMPACT_HEADER_HEIGHT or 38)
                or (config.HEADER_HEIGHT or 42),
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

    function Layout.clampDragCenter(centerX, centerY, width, height, viewport, padding, headerHeight)
        local halfWidth = width / 2
        local halfHeight = height / 2
        local visibleWidth = math.min(width, 112)
        local minX = padding + visibleWidth - halfWidth
        local maxX = viewport.X - padding - visibleWidth + halfWidth
        local minY = padding + halfHeight
        local maxY = viewport.Y - padding - headerHeight + halfHeight

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

__factories["UI/ModernUI"] = function()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")

    local Config = __require("Config")
    local IconCache = __require("Core/IconCache")
    local Layout = __require("UI/Layout")

    local UI = {}

    local COLORS = table.freeze({
        background = Color3.fromRGB(7, 10, 18),
        panel = Color3.fromRGB(11, 16, 29),
        header = Color3.fromRGB(14, 20, 35),
        surface = Color3.fromRGB(17, 24, 42),
        card = Color3.fromRGB(22, 31, 52),
        cardHover = Color3.fromRGB(28, 39, 65),
        text = Color3.fromRGB(242, 246, 255),
        muted = Color3.fromRGB(139, 153, 180),
        accent = Color3.fromRGB(92, 124, 250),
        accentBright = Color3.fromRGB(102, 208, 255),
        green = Color3.fromRGB(62, 211, 143),
        red = Color3.fromRGB(244, 91, 105),
        border = Color3.fromRGB(43, 57, 85),
        track = Color3.fromRGB(50, 61, 83),
    })

    local TABS = table.freeze({ "Main", "Visual", "Misc", "Settings" })
    local TWEEN_INFO = TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local function corner(parent, radius)
        local value = Instance.new("UICorner")
        value.CornerRadius = UDim.new(0, radius)
        value.Parent = parent
        return value
    end

    local function stroke(parent, color, thickness, transparency)
        local value = Instance.new("UIStroke")
        value.Color = color
        value.Thickness = thickness or 1
        value.Transparency = transparency or 0
        value.Parent = parent
        return value
    end

    local function gradient(parent, first, second, rotation)
        local value = Instance.new("UIGradient")
        value.Color = ColorSequence.new(first, second)
        value.Rotation = rotation or 0
        value.Parent = parent
        return value
    end

    local function animate(instance, properties)
        TweenService:Create(instance, TWEEN_INFO, properties):Play()
    end

    local function label(parent, text, size)
        local value = Instance.new("TextLabel")
        value.BackgroundTransparency = 1
        value.Text = text
        value.TextColor3 = COLORS.text
        value.Font = Enum.Font.GothamMedium
        value.TextSize = size or 13
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.Parent = parent
        return value
    end

    local function addPageLayout(page)
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 14)
        padding.PaddingRight = UDim.new(0, 14)
        padding.PaddingTop = UDim.new(0, 13)
        padding.PaddingBottom = UDim.new(0, 14)
        padding.Parent = page

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 9)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = page
    end

    function UI.new(title, options)
        options = typeof(options) == "table" and options or {}
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
            collapsed = false,
            dragState = "idle",
            dragKind = nil,
            dragInput = nil,
            dragStart = nil,
            startCenter = nil,
            layout = nil,
            pages = {},
            tabs = {},
            activePage = "Main",
            widthPercent = Layout.normalizeWidthPercent(
                options.widthPercent,
                Config.MODERN_UI.DEFAULT_WIDTH_PERCENT
            ),
        }

        local gui = Instance.new("ScreenGui")
        gui.Name = "GOATHubSTK"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        pcall(function()
            gui.ScreenInsets = Enum.ScreenInsets.None
        end)
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = playerGui
        self.gui = gui

        local frame = Instance.new("Frame")
        frame.Name = "ModernWindow"
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.BackgroundColor3 = COLORS.panel
        frame.ClipsDescendants = true
        frame.Parent = gui
        corner(frame, 14)
        stroke(frame, COLORS.border, 1, 0.08)
        gradient(frame, Color3.fromRGB(13, 19, 34), COLORS.panel, 90)
        self.frame = frame

        local topBar = Instance.new("Frame")
        topBar.Name = "TopBar"
        topBar.BackgroundColor3 = COLORS.header
        topBar.BorderSizePixel = 0
        topBar.Parent = frame
        self.topBar = topBar

        local dragHandle = Instance.new("TextButton")
        dragHandle.Name = "DragHandle"
        dragHandle.Size = UDim2.new(1, -94, 1, 0)
        dragHandle.BackgroundTransparency = 1
        dragHandle.Text = ""
        dragHandle.AutoButtonColor = false
        dragHandle.ZIndex = 2
        dragHandle.Parent = topBar
        self.dragHandle = dragHandle

        local brand = Instance.new("Frame")
        brand.Name = "Brand"
        brand.AnchorPoint = Vector2.new(0, 0.5)
        brand.Position = UDim2.new(0, 12, 0.5, 0)
        brand.Size = UDim2.fromOffset(32, 32)
        brand.BackgroundColor3 = COLORS.accent
        brand.Parent = topBar
        corner(brand, 9)
        gradient(brand, COLORS.accent, COLORS.accentBright, 35)

        local brandIcon = Instance.new("ImageLabel")
        brandIcon.Name = "Icon"
        brandIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        brandIcon.Position = UDim2.fromScale(0.5, 0.5)
        brandIcon.Size = UDim2.fromScale(0.82, 0.82)
        brandIcon.BackgroundTransparency = 1
        brandIcon.ScaleType = Enum.ScaleType.Fit
        brandIcon.Image = ""
        brandIcon.Parent = brand

        local brandFallback = label(brand, "G", 16)
        brandFallback.AnchorPoint = Vector2.new(0.5, 0.5)
        brandFallback.Position = UDim2.fromScale(0.5, 0.5)
        brandFallback.Size = UDim2.fromScale(1, 1)
        brandFallback.TextXAlignment = Enum.TextXAlignment.Center
        brandFallback.TextYAlignment = Enum.TextYAlignment.Center
        brandFallback.Font = Enum.Font.GothamBold
        brandFallback.Visible = true

        IconCache.loadAsync(function(asset)
            if self.destroyed or not brandIcon.Parent or not brandFallback.Parent then
                return
            end
            if typeof(asset) == "string" and asset ~= "" then
                brandIcon.Image = asset
                brandFallback.Visible = false
            end
        end)

        local titleLabel = label(topBar, title or Config.MODERN_UI.TITLE, 14)
        titleLabel.Name = "Title"
        titleLabel.Position = UDim2.fromOffset(54, 8)
        titleLabel.Size = UDim2.new(1, -150, 0, 20)
        titleLabel.Font = Enum.Font.GothamBold

        local subtitle = label(topBar, "STK  /  CLIENT HUB", 9)
        subtitle.Name = "Subtitle"
        subtitle.Position = UDim2.fromOffset(54, 27)
        subtitle.Size = UDim2.new(1, -150, 0, 15)
        subtitle.TextColor3 = COLORS.muted

        local minimizeButton = Instance.new("TextButton")
        minimizeButton.Name = "Minimize"
        minimizeButton.AnchorPoint = Vector2.new(1, 0.5)
        minimizeButton.Position = UDim2.new(1, -48, 0.5, 0)
        minimizeButton.Size = UDim2.fromOffset(34, 30)
        minimizeButton.BackgroundColor3 = COLORS.surface
        minimizeButton.Text = "–"
        minimizeButton.TextColor3 = COLORS.muted
        minimizeButton.Font = Enum.Font.GothamBold
        minimizeButton.TextSize = 19
        minimizeButton.ZIndex = 3
        minimizeButton.Parent = topBar
        corner(minimizeButton, 9)
        stroke(minimizeButton, COLORS.border, 1, 0.2)
        self.minimizeButton = minimizeButton

        local closeButton = Instance.new("TextButton")
        closeButton.Name = "Close"
        closeButton.AnchorPoint = Vector2.new(1, 0.5)
        closeButton.Position = UDim2.new(1, -10, 0.5, 0)
        closeButton.Size = UDim2.fromOffset(34, 30)
        closeButton.BackgroundColor3 = COLORS.surface
        closeButton.Text = "×"
        closeButton.TextColor3 = COLORS.red
        closeButton.Font = Enum.Font.GothamBold
        closeButton.TextSize = 19
        closeButton.ZIndex = 3
        closeButton.Parent = topBar
        corner(closeButton, 9)
        stroke(closeButton, COLORS.border, 1, 0.2)
        self.closeButton = closeButton

        local tabBar = Instance.new("Frame")
        tabBar.Name = "Navigation"
        tabBar.BackgroundColor3 = COLORS.surface
        tabBar.BorderSizePixel = 0
        tabBar.Parent = frame
        self.tabBar = tabBar

        local tabsContainer = Instance.new("Frame")
        tabsContainer.Name = "TabsContainer"
        tabsContainer.Position = UDim2.fromOffset(12, 6)
        tabsContainer.Size = UDim2.new(1, -24, 1, -11)
        tabsContainer.BackgroundTransparency = 1
        tabsContainer.Parent = tabBar

        local tabList = Instance.new("UIListLayout")
        tabList.FillDirection = Enum.FillDirection.Horizontal
        tabList.Padding = UDim.new(0, 4)
        tabList.SortOrder = Enum.SortOrder.LayoutOrder
        tabList.Parent = tabsContainer

        local pageHost = Instance.new("Frame")
        pageHost.Name = "Pages"
        pageHost.BackgroundTransparency = 1
        pageHost.ClipsDescendants = true
        pageHost.Parent = frame
        self.pageHost = pageHost

        for index, pageName in ipairs(TABS) do
            local button = Instance.new("TextButton")
            button.Name = pageName
            button.Size = UDim2.new(0.25, -3, 1, 0)
            button.BackgroundColor3 = COLORS.card
            button.BackgroundTransparency = 1
            button.Text = pageName
            button.TextColor3 = COLORS.muted
            button.Font = Enum.Font.GothamBold
            button.TextSize = 12
            button.AutoButtonColor = false
            button.LayoutOrder = index
            button.Parent = tabsContainer
            corner(button, 8)

            local indicator = Instance.new("Frame")
            indicator.Name = "Indicator"
            indicator.AnchorPoint = Vector2.new(0.5, 1)
            indicator.Position = UDim2.new(0.5, 0, 1, 0)
            indicator.Size = UDim2.new(0.42, 0, 0, 2)
            indicator.BackgroundColor3 = COLORS.accentBright
            indicator.BorderSizePixel = 0
            indicator.Visible = false
            indicator.Parent = button
            corner(indicator, 2)

            local page = Instance.new("ScrollingFrame")
            page.Name = pageName .. "Page"
            page.Size = UDim2.fromScale(1, 1)
            page.BackgroundTransparency = 1
            page.BorderSizePixel = 0
            page.CanvasSize = UDim2.new()
            page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            page.ScrollingDirection = Enum.ScrollingDirection.Y
            page.ScrollBarThickness = 3
            page.ScrollBarImageColor3 = COLORS.accent
            page.Visible = false
            page.Parent = pageHost
            addPageLayout(page)

            self.tabs[pageName] = {
                button = button,
                indicator = indicator,
            }
            self.pages[pageName] = page
            table.insert(self.connections, button.Activated:Connect(function()
                self:selectPage(pageName)
            end))
        end
        self.content = self.pages.Main

        local statusBar = Instance.new("Frame")
        statusBar.Name = "StatusBar"
        statusBar.BackgroundColor3 = COLORS.background
        statusBar.BorderSizePixel = 0
        statusBar.Parent = frame
        self.statusBar = statusBar

        local statusDot = Instance.new("Frame")
        statusDot.AnchorPoint = Vector2.new(0, 0.5)
        statusDot.Position = UDim2.new(0, 14, 0.5, 0)
        statusDot.Size = UDim2.fromOffset(7, 7)
        statusDot.BackgroundColor3 = COLORS.green
        statusDot.BorderSizePixel = 0
        statusDot.Parent = statusBar
        corner(statusDot, 7)

        local statusLabel = label(statusBar, "GOATHubSTK iniciado", 11)
        statusLabel.Name = "Status"
        statusLabel.Position = UDim2.fromOffset(29, 0)
        statusLabel.Size = UDim2.new(1, -42, 1, 0)
        statusLabel.TextColor3 = COLORS.muted
        statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
        self.statusLabel = statusLabel

        local function currentViewport()
            local camera = Workspace.CurrentCamera
            return camera and camera.ViewportSize or Vector2.new(800, 600)
        end

        function self:selectPage(pageName)
            if not self.pages[pageName] then
                return
            end
            self.activePage = pageName
            for name, page in pairs(self.pages) do
                local selected = name == pageName
                page.Visible = selected and not self.collapsed
                local tab = self.tabs[name]
                tab.indicator.Visible = selected
                animate(tab.button, {
                    BackgroundTransparency = selected and 0 or 1,
                    TextColor3 = selected and COLORS.text or COLORS.muted,
                })
            end
        end

        function self:setStatus(message)
            if not self.destroyed and self.statusLabel and self.statusLabel.Parent then
                self.statusLabel.Text = tostring(message)
            end
        end

        function self:setWidthPercent(value)
            local normalized = Layout.normalizeWidthPercent(value, Config.MODERN_UI.DEFAULT_WIDTH_PERCENT)
            if tonumber(value) ~= normalized then
                return false
            end
            if self.widthPercent ~= normalized then
                self.widthPercent = normalized
                self:_applyLayout(false)
            end
            return true
        end

        function self:_applyLayout(resetCenter)
            if self.destroyed then
                return
            end
            local viewport = currentViewport()
            local calculated = Layout.calculate(viewport, Config.MODERN_UI, self.widthPercent)
            local effectiveHeight = self.collapsed and calculated.headerHeight or calculated.height
            local centerX = resetCenter and calculated.centerX or self.frame.Position.X.Offset
            local centerY = resetCenter and calculated.centerY or self.frame.Position.Y.Offset
            if resetCenter and not self.collapsed then
                centerX, centerY = Layout.clampCenter(
                    centerX,
                    centerY,
                    calculated.width,
                    effectiveHeight,
                    viewport,
                    calculated.padding
                )
            else
                centerX, centerY = Layout.clampDragCenter(
                    centerX,
                    centerY,
                    calculated.width,
                    effectiveHeight,
                    viewport,
                    calculated.padding,
                    calculated.headerHeight
                )
            end

            self.layout = calculated
            self.frame.Size = UDim2.fromOffset(calculated.width, effectiveHeight)
            self.frame.Position = UDim2.fromOffset(centerX, centerY)
            self.topBar.Size = UDim2.new(1, 0, 0, calculated.headerHeight)
            self.tabBar.Position = UDim2.fromOffset(0, calculated.headerHeight)
            self.tabBar.Size = UDim2.new(1, 0, 0, Config.MODERN_UI.TAB_HEIGHT)
            self.pageHost.Position = UDim2.fromOffset(
                0,
                calculated.headerHeight + Config.MODERN_UI.TAB_HEIGHT
            )
            if self.collapsed then
                self.pageHost.Size = UDim2.new(1, 0, 0, 0)
            else
                self.pageHost.Size = UDim2.new(
                    1,
                    0,
                    1,
                    -(calculated.headerHeight + Config.MODERN_UI.TAB_HEIGHT + Config.MODERN_UI.STATUS_HEIGHT)
                )
            end
            self.statusBar.AnchorPoint = Vector2.new(0, 1)
            self.statusBar.Position = UDim2.fromScale(0, 1)
            self.statusBar.Size = UDim2.new(1, 0, 0, Config.MODERN_UI.STATUS_HEIGHT)
            self.tabBar.Visible = not self.collapsed
            self.pageHost.Visible = not self.collapsed
            self.statusBar.Visible = not self.collapsed
            self:selectPage(self.activePage)
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
            local finishedMouse = self.dragKind == "mouse"
                and input.UserInputType == Enum.UserInputType.MouseButton1
            local finishedTouch = self.dragKind == "touch" and input == self.dragInput
            if not finishedMouse and not finishedTouch then
                return
            end
            self.dragState = "idle"
            self.dragKind = nil
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
            self.dragKind = input.UserInputType == Enum.UserInputType.Touch and "touch" or "mouse"
            self.dragInput = self.dragKind == "touch" and input or nil
            self.dragStart = input.Position
            self.startCenter = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
        end))

        table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
            local movingMouse = self.dragKind == "mouse"
                and input.UserInputType == Enum.UserInputType.MouseMovement
            local movingTouch = self.dragKind == "touch" and input == self.dragInput
            if self.dragState == "idle" or (not movingMouse and not movingTouch) then
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
            local effectiveHeight = self.collapsed and self.layout.headerHeight or self.layout.height
            local x, y = Layout.clampDragCenter(
                self.startCenter.X + delta.X,
                self.startCenter.Y + delta.Y,
                self.layout.width,
                effectiveHeight,
                viewport,
                self.layout.padding,
                self.layout.headerHeight
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
        table.insert(self.connections, minimizeButton.Activated:Connect(function()
            local currentHeight = self.frame.Size.Y.Offset
            local top = self.frame.Position.Y.Offset - currentHeight / 2
            self.collapsed = not self.collapsed
            minimizeButton.Text = self.collapsed and "+" or "–"
            local nextHeight = self.collapsed and self.layout.headerHeight or self.layout.height
            self.frame.Position = UDim2.fromOffset(
                self.frame.Position.X.Offset,
                top + nextHeight / 2
            )
            self:_applyLayout(false)
        end))

        function self:getPage(pageName)
            return self.pages[pageName]
        end

        function self:setCloseCallback(callback)
            self.closeCallback = callback
        end

        function self:Destroy()
            if self.destroyed then
                return
            end
            self.destroyed = true
            self.dragState = "idle"
            self.dragKind = nil
            self.dragInput = nil
            if self.cameraConnection then
                self.cameraConnection:Disconnect()
                self.cameraConnection = nil
            end
            for _, connection in ipairs(self.connections) do
                connection:Disconnect()
            end
            table.clear(self.connections)
            table.clear(self.pages)
            table.clear(self.tabs)
            if self.gui then
                self.gui:Destroy()
                self.gui = nil
            end
        end

        self:_applyLayout(true)
        self:_bindCamera()
        self:selectPage("Main")
        return self
    end

    function UI.section(parent, text)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, 25)
        section.BackgroundTransparency = 1
        section.Parent = parent

        local title = label(section, string.upper(text), 10)
        title.Size = UDim2.new(0.46, 0, 1, 0)
        title.TextColor3 = COLORS.muted
        title.Font = Enum.Font.GothamBold

        local line = Instance.new("Frame")
        line.AnchorPoint = Vector2.new(1, 0.5)
        line.Position = UDim2.new(1, 0, 0.5, 0)
        line.Size = UDim2.new(0.52, 0, 0, 1)
        line.BackgroundColor3 = COLORS.border
        line.BackgroundTransparency = 0.25
        line.BorderSizePixel = 0
        line.Parent = section
        return section
    end

    function UI.info(parent, text, height)
        local value = label(parent, text, 11)
        value.Size = UDim2.new(1, 0, 0, height or 42)
        value.BackgroundColor3 = COLORS.surface
        value.BackgroundTransparency = 0.12
        value.TextColor3 = COLORS.muted
        value.TextWrapped = true
        value.TextYAlignment = Enum.TextYAlignment.Center
        value.Parent = parent
        corner(value, 9)
        stroke(value, COLORS.border, 1, 0.3)

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 12)
        padding.PaddingRight = UDim.new(0, 12)
        padding.Parent = value
        return value
    end

    function UI.button(parent, text, color, height)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, height or 42)
        button.BackgroundColor3 = color or COLORS.card
        button.AutoButtonColor = false
        button.Text = text
        button.TextColor3 = COLORS.text
        button.Font = Enum.Font.GothamBold
        button.TextSize = 12
        button.Parent = parent
        corner(button, 10)
        stroke(button, COLORS.border, 1, 0.2)

        button.MouseEnter:Connect(function()
            animate(button, { BackgroundColor3 = COLORS.cardHover })
        end)
        button.MouseLeave:Connect(function()
            animate(button, { BackgroundColor3 = color or COLORS.card })
        end)
        return button
    end

    function UI.checkbox(parent, text, initial, callback)
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundColor3 = COLORS.card
        row.AutoButtonColor = false
        row.Text = ""
        row.Parent = parent
        corner(row, 10)
        stroke(row, COLORS.border, 1, 0.22)

        local title = label(row, text, 12)
        title.Position = UDim2.fromOffset(13, 0)
        title.Size = UDim2.new(1, -82, 1, 0)
        title.TextColor3 = COLORS.text
        title.Font = Enum.Font.GothamMedium

        local track = Instance.new("Frame")
        track.AnchorPoint = Vector2.new(1, 0.5)
        track.Position = UDim2.new(1, -12, 0.5, 0)
        track.Size = UDim2.fromOffset(42, 23)
        track.BackgroundColor3 = COLORS.track
        track.Parent = row
        corner(track, 12)

        local knob = Instance.new("Frame")
        knob.AnchorPoint = Vector2.new(0, 0.5)
        knob.Size = UDim2.fromOffset(17, 17)
        knob.BackgroundColor3 = COLORS.text
        knob.Parent = track
        corner(knob, 9)

        local checked = initial == true
        local function render(animated)
            local trackColor = checked and COLORS.accent or COLORS.track
            local knobPosition = UDim2.new(0, checked and 22 or 3, 0.5, 0)
            if animated then
                animate(track, { BackgroundColor3 = trackColor })
                animate(knob, { Position = knobPosition })
            else
                track.BackgroundColor3 = trackColor
                knob.Position = knobPosition
            end
        end
        render(false)

        row.MouseEnter:Connect(function()
            animate(row, { BackgroundColor3 = COLORS.cardHover })
        end)
        row.MouseLeave:Connect(function()
            animate(row, { BackgroundColor3 = COLORS.card })
        end)
        row.Activated:Connect(function()
            checked = not checked
            render(true)
            callback(checked)
        end)
        return row
    end

    function UI.segmented(parent, text, options, initial, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 78)
        row.BackgroundColor3 = COLORS.card
        row.Parent = parent
        corner(row, 10)
        stroke(row, COLORS.border, 1, 0.22)

        local title = label(row, text, 11)
        title.Position = UDim2.fromOffset(13, 5)
        title.Size = UDim2.new(1, -26, 0, 24)
        title.TextColor3 = COLORS.text

        local selector = Instance.new("Frame")
        selector.Position = UDim2.fromOffset(13, 35)
        selector.Size = UDim2.new(1, -26, 0, 31)
        selector.BackgroundColor3 = COLORS.background
        selector.Parent = row
        corner(selector, 8)
        stroke(selector, COLORS.border, 1, 0.18)

        local list = Instance.new("UIListLayout")
        list.FillDirection = Enum.FillDirection.Horizontal
        list.Padding = UDim.new(0, 3)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = selector

        local values = {}
        for _, option in ipairs(options) do
            table.insert(values, tostring(option))
        end
        if #values == 0 then
            table.insert(values, tostring(initial))
        end

        local selected = tostring(initial)
        local buttons = {}
        local offset = -(3 * (#values - 1) / #values)
        local function render(animated)
            for value, button in pairs(buttons) do
                local active = value == selected
                local properties = {
                    BackgroundTransparency = active and 0.05 or 1,
                    TextColor3 = active and COLORS.text or COLORS.muted,
                }
                if animated then
                    animate(button, properties)
                else
                    button.BackgroundTransparency = properties.BackgroundTransparency
                    button.TextColor3 = properties.TextColor3
                end
            end
        end

        for index, value in ipairs(values) do
            local button = Instance.new("TextButton")
            button.Name = "Option" .. tostring(index)
            button.Size = UDim2.new(1 / #values, offset, 1, 0)
            button.BackgroundColor3 = COLORS.accent
            button.BackgroundTransparency = 1
            button.Text = value
            button.TextColor3 = COLORS.muted
            button.Font = Enum.Font.GothamBold
            button.TextSize = 11
            button.AutoButtonColor = false
            button.LayoutOrder = index
            button.Parent = selector
            corner(button, 7)
            buttons[value] = button
            button.Activated:Connect(function()
                if selected == value then
                    return
                end
                selected = value
                render(true)
                callback(value)
            end)
        end
        render(false)
        return row
    end

    function UI.numberInput(parent, text, initial, minimum, maximum, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 50)
        row.BackgroundColor3 = COLORS.card
        row.Parent = parent
        corner(row, 10)
        stroke(row, COLORS.border, 1, 0.22)

        local title = label(row, text, 11)
        title.Position = UDim2.fromOffset(13, 0)
        title.Size = UDim2.new(1, -126, 1, 0)
        title.TextColor3 = COLORS.text

        local box = Instance.new("TextBox")
        box.AnchorPoint = Vector2.new(1, 0.5)
        box.Position = UDim2.new(1, -11, 0.5, 0)
        box.Size = UDim2.fromOffset(98, 31)
        box.BackgroundColor3 = COLORS.background
        box.TextColor3 = COLORS.accentBright
        box.PlaceholderColor3 = COLORS.muted
        box.ClearTextOnFocus = false
        box.Font = Enum.Font.GothamBold
        box.TextSize = 12
        box.Text = tostring(initial)
        box.Parent = row
        corner(box, 8)
        stroke(box, COLORS.border, 1, 0.12)

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
            collapsed = false,
            dragState = "idle",
            dragKind = nil,
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
        dragHandle.Size = UDim2.new(1, -84, 1, 0)
        dragHandle.BackgroundTransparency = 1
        dragHandle.Text = "  " .. (title or Config.UI.TITLE)
        dragHandle.TextColor3 = COLORS.text
        dragHandle.Font = Enum.Font.GothamBold
        dragHandle.TextSize = 14
        dragHandle.TextXAlignment = Enum.TextXAlignment.Left
        dragHandle.AutoButtonColor = false
        dragHandle.Parent = topBar
        self.dragHandle = dragHandle

        local minimizeButton = Instance.new("TextButton")
        minimizeButton.Name = "Minimize"
        minimizeButton.AnchorPoint = Vector2.new(1, 0.5)
        minimizeButton.Position = UDim2.new(1, -43, 0.5, 0)
        minimizeButton.Size = UDim2.fromOffset(32, 28)
        minimizeButton.BackgroundColor3 = COLORS.card
        minimizeButton.Text = "–"
        minimizeButton.TextColor3 = COLORS.text
        minimizeButton.Font = Enum.Font.GothamBold
        minimizeButton.TextSize = 19
        minimizeButton.Parent = topBar
        corner(minimizeButton, 7)
        self.minimizeButton = minimizeButton

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
            local effectiveHeight = self.collapsed and calculated.headerHeight or calculated.height
            local centerX = resetCenter and calculated.centerX or self.frame.Position.X.Offset
            local centerY = resetCenter and calculated.centerY or self.frame.Position.Y.Offset
            if resetCenter and not self.collapsed then
                centerX, centerY = Layout.clampCenter(
                    centerX,
                    centerY,
                    calculated.width,
                    effectiveHeight,
                    viewport,
                    calculated.padding
                )
            else
                centerX, centerY = Layout.clampDragCenter(
                    centerX,
                    centerY,
                    calculated.width,
                    effectiveHeight,
                    viewport,
                    calculated.padding,
                    calculated.headerHeight
                )
            end

            self.layout = calculated
            self.frame.Size = UDim2.fromOffset(calculated.width, effectiveHeight)
            self.frame.Position = UDim2.fromOffset(centerX, centerY)
            self.topBar.Size = UDim2.new(1, 0, 0, calculated.headerHeight)
            self.content.Position = UDim2.fromOffset(0, calculated.headerHeight)
            self.content.Size = UDim2.new(1, 0, 1, -calculated.headerHeight)
            self.content.Visible = not self.collapsed
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
            local finishedMouse = self.dragKind == "mouse"
                and input.UserInputType == Enum.UserInputType.MouseButton1
            local finishedTouch = self.dragKind == "touch" and input == self.dragInput
            if not finishedMouse and not finishedTouch then
                return
            end
            self.dragState = "idle"
            self.dragKind = nil
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
            self.dragKind = input.UserInputType == Enum.UserInputType.Touch and "touch" or "mouse"
            self.dragInput = self.dragKind == "touch" and input or nil
            self.dragStart = input.Position
            self.startCenter = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
        end))

        table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
            local movingMouse = self.dragKind == "mouse"
                and input.UserInputType == Enum.UserInputType.MouseMovement
            local movingTouch = self.dragKind == "touch" and input == self.dragInput
            if self.dragState == "idle" or (not movingMouse and not movingTouch) then
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
            local effectiveHeight = self.collapsed and self.layout.headerHeight or self.layout.height
            local x, y = Layout.clampDragCenter(
                self.startCenter.X + delta.X,
                self.startCenter.Y + delta.Y,
                self.layout.width,
                effectiveHeight,
                viewport,
                self.layout.padding,
                self.layout.headerHeight
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
        table.insert(self.connections, minimizeButton.Activated:Connect(function()
            local currentHeight = self.frame.Size.Y.Offset
            local top = self.frame.Position.Y.Offset - currentHeight / 2
            self.collapsed = not self.collapsed
            minimizeButton.Text = self.collapsed and "+" or "–"
            local nextHeight = self.collapsed and self.layout.headerHeight or self.layout.height
            self.frame.Position = UDim2.fromOffset(
                self.frame.Position.X.Offset,
                top + nextHeight / 2
            )
            self:_applyLayout(false)
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
            self.dragKind = nil
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
    local LootCatalog = __require("Providers/LootCatalog")
    local UI
    if Config.UI_STYLE == "Legacy" then
        UI = __require("UI/UI")
    else
        UI = __require("UI/ModernUI")
    end
    local AutoEscape = __require("Features/AutoEscape")
    local KillAll = __require("Features/KillAll")
    local AutoRevive = __require("Features/AutoRevive")
    local TeamESP = __require("Features/TeamESP")
    local LootESP = __require("Features/LootESP")
    local AutoLoot = __require("Features/AutoLoot")
    local AutoEvade = __require("Features/AutoEvade")
    local AttributeOverrides = __require("Features/AttributeOverrides")
    local FOVOverride = __require("Features/FOVOverride")
    local PlayerOverrides = __require("Features/PlayerOverrides")
    local AutoServerHop = __require("Features/AutoServerHop")
    local StateStore = __require("Core/StateStore")
    local ExecutorSettings = __require("Core/ExecutorSettings")

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
        local lootCatalog = LootCatalog.new()
        local stateStore = StateStore.new()
        local executorSettings = ExecutorSettings.new()
        local uiConfig = Config.UI_STYLE == "Legacy" and Config.UI or Config.MODERN_UI
        local window = UI.new(uiConfig.TITLE, {
            widthPercent = executorSettings:getWidthPercent(),
        })
        local function getPage(pageName)
            if typeof(window.getPage) == "function" then
                return window:getPage(pageName)
            end
            return window.content
        end
        local mainPage = getPage("Main")
        local visualPage = getPage("Visual")
        local miscPage = getPage("Misc")
        local settingsPage = getPage("Settings")
        local layoutOrder = 0

        app.movement = movement
        app.mapProvider = mapProvider
        app.lootCatalog = lootCatalog
        app.stateStore = stateStore
        app.executorSettings = executorSettings
        app.window = window

        local function contentItem(instance)
            layoutOrder += 1
            instance.LayoutOrder = layoutOrder
            return instance
        end

        local status = window.statusLabel
        if not status then
            status = contentItem(UI.info(mainPage, "GOATHubSTK iniciado", 42))
            status.TextColor3 = window.colors.text
        end
        app.status = status

        local function setStatus(message)
            if not app.destroyed then
                if typeof(window.setStatus) == "function" then
                    window:setStatus(message)
                elseif status.Parent then
                    status.Text = tostring(message)
                end
            end
        end

        local restoreActions = {}
        local function persistentCheckbox(parent, label, key, apply, defaultValue)
            local initial = stateStore:getBoolean(key, defaultValue)
            if not stateStore:has(key) then
                stateStore:setBoolean(key, initial)
            end
            contentItem(UI.checkbox(parent, label, initial, function(enabled)
                stateStore:setBoolean(key, enabled)
                apply(enabled)
            end))
            if initial then
                table.insert(restoreActions, function()
                    apply(true)
                end)
            end
            return initial
        end

        local legacyUnlockAll = false
        for _, attribute in ipairs(Config.ATTRIBUTE_OVERRIDES.GAMEPASSES) do
            legacyUnlockAll = legacyUnlockAll
                or stateStore:getBoolean("attribute.Gamepasses." .. attribute, false)
        end
        local legacyDoubleJump = stateStore:getBoolean("attribute.Gamepasses.DoubleJump", false)
            or stateStore:getBoolean("attribute.Settings.double_jump", false)
        local legacyKillerChance = stateStore:getBoolean("attribute.Gamepasses.IncreasedKillerChange", false)
            or stateStore:getBoolean("attribute.Settings.killer_chance_3x", false)

        if not stateStore:has("feature.unlockAllGamepasses") then
            stateStore:setBoolean("feature.unlockAllGamepasses", legacyUnlockAll)
        end
        if not stateStore:has("feature.doubleJump") then
            stateStore:setBoolean("feature.doubleJump", legacyDoubleJump)
        end
        if not stateStore:has("feature.killerChance3x") then
            stateStore:setBoolean("feature.killerChance3x", legacyKillerChance)
        end
        for _, attribute in ipairs(Config.ATTRIBUTE_OVERRIDES.GAMEPASSES) do
            stateStore:remove("attribute.Gamepasses." .. attribute)
        end
        for _, attribute in ipairs(Config.ATTRIBUTE_OVERRIDES.SETTINGS) do
            stateStore:remove("attribute.Settings." .. attribute)
        end

        local autoEscape = AutoEscape.new(movement, mapProvider, setStatus)
        local killAll = KillAll.new(movement, setStatus)
        local autoRevive = AutoRevive.new(movement, setStatus)
        local teamESP = TeamESP.new(setStatus)
        local lootESP = LootESP.new(mapProvider, lootCatalog, setStatus)
        local autoLoot = AutoLoot.new(movement, mapProvider, setStatus)
        local autoEvade = AutoEvade.new(movement, mapProvider, setStatus)
        local attributeOverrides = AttributeOverrides.new(setStatus)
        local fovOverride = FOVOverride.new(setStatus)
        local playerOverrides = PlayerOverrides.new(setStatus)
        local autoServerHop = AutoServerHop.new(setStatus)

        app.controllers = {
            autoEscape,
            killAll,
            autoRevive,
            teamESP,
            lootESP,
            autoLoot,
            autoEvade,
            attributeOverrides,
            fovOverride,
            playerOverrides,
            autoServerHop,
        }

        contentItem(UI.section(mainPage, "RODADA"))
        persistentCheckbox(mainPage, "Auto Escape", "feature.autoEscape", function(enabled)
            autoEscape:setEnabled(enabled)
        end)
        persistentCheckbox(mainPage, "Kill All (somente Killer)", "feature.killAll", function(enabled)
            killAll:setEnabled(enabled)
        end)
        persistentCheckbox(mainPage, "Auto Revive / buscar ajuda", "feature.autoRevive", function(enabled)
            autoRevive:setEnabled(enabled)
        end)
        persistentCheckbox(mainPage, "Auto Collect Loot", "feature.autoLoot", function(enabled)
            autoLoot:setEnabled(enabled)
        end)

        contentItem(UI.section(mainPage, "SEGURANCA DO SURVIVOR"))
        local evadeDistance = stateStore:getNumber(
            "value.evadeDistance",
            Config.DISTANCES.KILLER_EVADE,
            15,
            120
        )
        if not stateStore:has("value.evadeDistance") then
            stateStore:setNumber("value.evadeDistance", evadeDistance, 15, 120)
        end
        autoEvade:setDistance(evadeDistance)
        autoRevive:setDangerDistance(evadeDistance)
        contentItem(UI.numberInput(
            mainPage,
            "Fugir quando Killer estiver a (studs)",
            evadeDistance,
            15,
            120,
            function(distance)
                stateStore:setNumber("value.evadeDistance", distance, 15, 120)
                autoEvade:setDistance(distance)
                autoRevive:setDangerDistance(distance)
                setStatus("Distancia de seguranca: " .. tostring(math.floor(distance + 0.5)) .. " studs")
            end
        ))
        persistentCheckbox(mainPage, "Auto Fugir do Killer", "feature.autoEvade", function(enabled)
            autoEvade:setEnabled(enabled)
        end)

        contentItem(UI.section(visualPage, "ESP E DESTAQUES"))
        persistentCheckbox(visualPage, "Team ESP — azul/vermelho", "feature.teamESP", function(enabled)
            teamESP:setEnabled(enabled)
        end)
        persistentCheckbox(visualPage, "Loot ESP — nome, valor e cor", "feature.lootESP", function(enabled)
            lootESP:setEnabled(enabled)
        end)
        local lootESPNote = contentItem(UI.info(
            visualPage,
            "Mostra nome e valor de venda. A cor muda entre 1, 3, 5, 15, 40 e 200 moedas.",
            42
        ))
        lootESPNote.TextColor3 = window.colors.muted

        contentItem(UI.section(miscPage, "DESBLOQUEIOS LOCAIS"))
        persistentCheckbox(miscPage, "Unlock All Gamepasses", "feature.unlockAllGamepasses", function(enabled)
            for _, attribute in ipairs(Config.ATTRIBUTE_OVERRIDES.GAMEPASSES) do
                attributeOverrides:setOverride("Gamepasses", attribute, enabled, "unlockAllGamepasses")
            end
        end)
        persistentCheckbox(miscPage, "Pulo Duplo 2x", "feature.doubleJump", function(enabled)
            attributeOverrides:setOverride("Gamepasses", "DoubleJump", enabled, "doubleJump")
            attributeOverrides:setOverride("Settings", "double_jump", enabled, "doubleJump")
        end)
        persistentCheckbox(miscPage, "Chance de Killer 3x", "feature.killerChance3x", function(enabled)
            attributeOverrides:setOverride("Gamepasses", "IncreasedKillerChange", enabled, "killerChance3x")
            attributeOverrides:setOverride("Settings", "killer_chance_3x", enabled, "killerChance3x")
        end)
        local localOverrideNote = contentItem(UI.info(
            miscPage,
            "Overrides locais e restauraveis; validacoes feitas pelo servidor continuam dependendo do jogo.",
            42
        ))
        localOverrideNote.TextColor3 = window.colors.muted

        contentItem(UI.section(miscPage, "PLAYER"))
        local savedWalkSpeed = stateStore:getNumber(
            "value.walkSpeed",
            playerOverrides:getWalkSpeed(),
            Config.PLAYER.MIN_WALK_SPEED,
            Config.PLAYER.MAX_WALK_SPEED
        )
        if not stateStore:has("value.walkSpeed") then
            stateStore:setNumber(
                "value.walkSpeed",
                savedWalkSpeed,
                Config.PLAYER.MIN_WALK_SPEED,
                Config.PLAYER.MAX_WALK_SPEED
            )
        end
        playerOverrides:setWalkSpeed(savedWalkSpeed)
        contentItem(UI.numberInput(
            miscPage,
            "Velocidade (WalkSpeed)",
            savedWalkSpeed,
            Config.PLAYER.MIN_WALK_SPEED,
            Config.PLAYER.MAX_WALK_SPEED,
            function(value)
                local applied = playerOverrides:setWalkSpeed(value)
                stateStore:setNumber(
                    "value.walkSpeed",
                    applied,
                    Config.PLAYER.MIN_WALK_SPEED,
                    Config.PLAYER.MAX_WALK_SPEED
                )
            end
        ))
        persistentCheckbox(
            miscPage,
            "Fixar velocidade",
            "feature.walkSpeedOverride",
            function(enabled)
                playerOverrides:setWalkSpeedEnabled(enabled)
            end
        )

        local savedJumpHeight = stateStore:getNumber(
            "value.jumpHeight",
            playerOverrides:getJumpHeight(),
            Config.PLAYER.MIN_JUMP_HEIGHT,
            Config.PLAYER.MAX_JUMP_HEIGHT
        )
        if not stateStore:has("value.jumpHeight") then
            stateStore:setNumber(
                "value.jumpHeight",
                savedJumpHeight,
                Config.PLAYER.MIN_JUMP_HEIGHT,
                Config.PLAYER.MAX_JUMP_HEIGHT
            )
        end
        playerOverrides:setJumpHeight(savedJumpHeight)
        contentItem(UI.numberInput(
            miscPage,
            "Altura do pulo (JumpHeight)",
            savedJumpHeight,
            Config.PLAYER.MIN_JUMP_HEIGHT,
            Config.PLAYER.MAX_JUMP_HEIGHT,
            function(value)
                local applied = playerOverrides:setJumpHeight(value)
                stateStore:setNumber(
                    "value.jumpHeight",
                    applied,
                    Config.PLAYER.MIN_JUMP_HEIGHT,
                    Config.PLAYER.MAX_JUMP_HEIGHT
                )
            end
        ))
        persistentCheckbox(
            miscPage,
            "Fixar altura do pulo",
            "feature.jumpHeightOverride",
            function(enabled)
                playerOverrides:setJumpHeightEnabled(enabled)
            end
        )

        local savedFOV = stateStore:getNumber(
            "value.fov",
            fovOverride:getFOV(),
            Config.CAMERA.MIN_FOV,
            Config.CAMERA.MAX_FOV
        )
        if not stateStore:has("value.fov") then
            stateStore:setNumber(
                "value.fov",
                savedFOV,
                Config.CAMERA.MIN_FOV,
                Config.CAMERA.MAX_FOV
            )
        end
        fovOverride:setFOV(savedFOV)
        contentItem(UI.numberInput(
            miscPage,
            "Campo de visao (FOV)",
            savedFOV,
            Config.CAMERA.MIN_FOV,
            Config.CAMERA.MAX_FOV,
            function(value)
                local applied = fovOverride:setFOV(value)
                stateStore:setNumber(
                    "value.fov",
                    applied,
                    Config.CAMERA.MIN_FOV,
                    Config.CAMERA.MAX_FOV
                )
            end
        ))
        persistentCheckbox(
            miscPage,
            "Fixar campo de visao",
            "feature.fovOverride",
            function(enabled)
                fovOverride:setEnabled(enabled)
            end
        )
        local playerNote = contentItem(UI.info(
            miscPage,
            "Valores locais e limitados. Ao desligar, o Hub restaura atributos, Humanoid e camera.",
            42
        ))
        playerNote.TextColor3 = window.colors.muted

        if typeof(UI.segmented) == "function" and typeof(window.setWidthPercent) == "function" then
            contentItem(UI.section(settingsPage, "INTERFACE"))
            contentItem(UI.segmented(
                settingsPage,
                "Largura da interface",
                { "25%", "50%", "75%", "100%" },
                tostring(executorSettings:getWidthPercent()) .. "%",
                function(selected)
                    local widthPercent = tonumber(string.match(selected, "^(%d+)%%$"))
                    if not widthPercent or not window:setWidthPercent(widthPercent) then
                        setStatus("Interface: largura invalida ignorada")
                        return
                    end
                    local saved = executorSettings:setWidthPercent(widthPercent)
                    if saved then
                        setStatus(string.format(
                            "Interface: largura %d%% salva em %s",
                            widthPercent,
                            executorSettings:getPath()
                        ))
                    else
                        setStatus(string.format(
                            "Interface: largura %d%% aplicada; filesystem indisponivel",
                            widthPercent
                        ))
                    end
                end
            ))
            local interfaceNote = contentItem(UI.info(
                settingsPage,
                "25% a 100% da tela. Configuracao local: GOATHub/settings.json.",
                38
            ))
            interfaceNote.TextColor3 = window.colors.muted
        end

        contentItem(UI.section(settingsPage, "AUTO REJOIN / SERVER HOP"))
        local savedLevelLimit = stateStore:getNumber(
            "value.serverHopLevel",
            autoServerHop:getLevelLimit(),
            Config.SERVER_HOP.MIN_LEVEL_LIMIT,
            Config.SERVER_HOP.MAX_LEVEL_LIMIT
        )
        if not stateStore:has("value.serverHopLevel") then
            stateStore:setNumber(
                "value.serverHopLevel",
                savedLevelLimit,
                Config.SERVER_HOP.MIN_LEVEL_LIMIT,
                Config.SERVER_HOP.MAX_LEVEL_LIMIT
            )
        end
        autoServerHop:setLevelLimit(savedLevelLimit)
        contentItem(UI.numberInput(
            settingsPage,
            "Trocar se outro jogador tiver nivel >=",
            savedLevelLimit,
            Config.SERVER_HOP.MIN_LEVEL_LIMIT,
            Config.SERVER_HOP.MAX_LEVEL_LIMIT,
            function(level)
                stateStore:setNumber(
                    "value.serverHopLevel",
                    level,
                    Config.SERVER_HOP.MIN_LEVEL_LIMIT,
                    Config.SERVER_HOP.MAX_LEVEL_LIMIT
                )
                autoServerHop:setLevelLimit(level)
            end
        ))
        persistentCheckbox(
            settingsPage,
            "Auto Rejoin por quantidade/nivel",
            "feature.autoServerHop",
            function(enabled)
                autoServerHop:setEnabled(enabled)
            end,
            autoServerHop:shouldResume()
        )
        local serverHopNote = contentItem(UI.info(
            settingsPage,
            "Ignora seu proprio nivel. Guarda os ultimos 10 JobIds e exige pelo menos outro jogador.",
            34
        ))
        serverHopNote.TextColor3 = window.colors.muted

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

        contentItem(UI.section(settingsPage, "SESSAO"))
        local closeButton = contentItem(UI.button(settingsPage, "Fechar GOAT Hub STK", window.colors.card, 42))
        closeButton.Activated:Connect(function()
            app:Destroy()
        end)
        window:setCloseCallback(function()
            app:Destroy()
        end)

        env[GLOBAL_KEY] = app
        setStatus(string.format("Pronto — GameId %d / PlaceId %d", game.GameId, game.PlaceId))
        stateStore:flush()
        for _, restore in ipairs(restoreActions) do
            pcall(restore)
        end
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

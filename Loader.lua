-- Loader remoto opcional. O bundle valida GAME_ID/PLACE_IDS antes de iniciar
-- qualquer feature, UI ou acesso a objetos do jogo.

local BUNDLE_URL = "https://raw.githubusercontent.com/TaxD-drop/GOATSTK/refs/heads/main/Distribution/GOATHubSTK.bundle.lua"
local MAX_BUNDLE_BYTES = 2 * 1024 * 1024

if BUNDLE_URL:find("COLOQUE_AQUI", 1, true) then
    warn("[GOATHubSTK] Configure BUNDLE_URL em Loader.lua ou execute o bundle local.")
    return
end

local env = if typeof(getgenv) == "function" then getgenv() else _G
env.__GOATHUB_STK_RELOAD_URL = BUNDLE_URL

local ok, source = pcall(function()
    return game:HttpGet(BUNDLE_URL)
end)
if not ok then
    warn("[GOATHubSTK] Falha ao baixar o bundle: " .. tostring(source))
    return
end
if typeof(source) ~= "string" or #source == 0 or #source > MAX_BUNDLE_BYTES then
    warn("[GOATHubSTK] Bundle vazio ou acima do limite permitido.")
    return
end

local chunk, compileError = loadstring(source)
if not chunk then
    warn("[GOATHubSTK] Bundle invalido: " .. tostring(compileError))
    return
end

return chunk()

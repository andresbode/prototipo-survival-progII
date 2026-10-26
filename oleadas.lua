-- =================== "CLASE" OLEADAS (CORRUTINA) ===================
local Class = require("librerias.hump-master.class")
local Signal = require("librerias.hump-master.signal")

local Oleadas = Class {}

-- =================== INICIALIZACION ===================
function Oleadas:init(mapa, jugador, enemigos, botiquines)
    self.jugador = jugador
    self.enemigos = enemigos
    self.botiquines = botiquines

    self.anchoMapa = mapa.width * mapa.tilewidth
    self.altoMapa = mapa.height * mapa.tileheight
    self.margen = 100
    self.distanciaMinima = 350 -- los enemigos nacen al menos a esta distancia del jugador
    self.botiquinesPorOleada = 1

    self.total = 5
    self.duracionBase = 15
    self.duracionExtra = 10
    self.pausa = 5

    self.numero = 0
    self.tiempoRestante = 0
    self.terminado = false

    -- La corrutina con toda la secuencia; Actualizar la va reanudando
    self.corrutina = coroutine.create(function() self:Secuencia() end)
end

-- =================== SECUENCIA ===================
function Oleadas:Secuencia()
    self:CrearBotiquines()

    for n = 1, self.total do
        self.numero = n
        local duracion = self.duracionBase + self.duracionExtra * (n - 1)

        self:CambiarFase("oleada")
        self:Pelear(duracion, n)

        if n < self.total then
            self:LimpiarEnemigos() -- desaparecen los enemigos de la oleada que termino
            self:CambiarFase("pausa")
            self:CrearBotiquines() -- aparecen al empezar la pausa
            self:Esperar(self.pausa)
        end
    end

    self.terminado = true
end

-- =================== ESPERAS ===================
-- Pausa la corrutina hasta que pasen "segundos"; yield devuelve el dt de cada frame
function Oleadas:Esperar(segundos)
    local t = 0
    while t < segundos do
        self.tiempoRestante = segundos - t
        t = t + coroutine.yield()
    end
    self.tiempoRestante = 0
end

-- Durante "duracion" segundos va spawneando enemigos, con un tope de enemigos vivos
function Oleadas:Pelear(duracion, n)
    local intervalo = math.max(0.5, 1.2 - 0.15 * (n - 1))
    local maxVivos = 8 + 3 * (n - 1)
    local transcurrido = 0
    local proximoSpawn = 0

    while transcurrido < duracion do
        self.tiempoRestante = duracion - transcurrido

        if transcurrido >= proximoSpawn and #self.enemigos < maxVivos then
            self:CrearEnemigo()
            proximoSpawn = transcurrido + intervalo
        end

        transcurrido = transcurrido + coroutine.yield()
    end
    self.tiempoRestante = 0
end

-- =================== SPAWN ===================
function Oleadas:CrearEnemigo()
    local x, y
    for intento = 1, 20 do
        x = love.math.random(self.margen, self.anchoMapa - self.margen)
        y = love.math.random(self.margen, self.altoMapa - self.margen)
        local dx = x - self.jugador.x
        local dy = y - self.jugador.y
        if math.sqrt(dx * dx + dy * dy) >= self.distanciaMinima then break end
    end

    local enemigo = ClaseEnemigo(x, y, "assets/animaciones/enemigo.png", 160, 2)
    enemigo.radioDeteccion = math.huge -- en las oleadas siempre detectan al jugador, sin importar donde nazcan
    table.insert(self.enemigos, enemigo)
end

function Oleadas:CrearBotiquines()
    -- Se sacan de la lista los botiquines que ya fueron recogidos
    for i = #self.botiquines, 1, -1 do
        if not self.botiquines[i].activo then
            table.remove(self.botiquines, i)
        end
    end

    -- 1 botiquin en un anillo de 250 a 450 px alrededor del jugador
    for i = 1, self.botiquinesPorOleada do
        local angulo = love.math.random() * math.pi * 2
        local distancia = love.math.random(250, 450)
        local x = self.jugador.x + math.cos(angulo) * distancia
        local y = self.jugador.y + math.sin(angulo) * distancia
        x = math.max(self.margen, math.min(x, self.anchoMapa - self.margen))
        y = math.max(self.margen, math.min(y, self.altoMapa - self.margen))
        table.insert(self.botiquines, ClaseBotiquin("assets/botiquin.png", 1, 30, x, y))
    end
end

-- =================== EVENTOS ===================
function Oleadas:CambiarFase(fase)
    Signal.emit("fase_cambiada", fase, self.numero, self.total)
end

-- =================== ACTUALIZAR ===================
function Oleadas:Actualizar(dt)
    if coroutine.status(self.corrutina) ~= "dead" then
        local ok, err = coroutine.resume(self.corrutina, dt)
        if not ok then error(err) end -- si la corrutina falla, que se vea el error
    end
end

-- =================== LIMPIEZA ===================
-- Borra los enemigos que quedan al terminar una oleada (se borra de la misma lista que usa main.lua)
function Oleadas:LimpiarEnemigos()
    for i = #self.enemigos, 1, -1 do
        table.remove(self.enemigos, i)
    end
end

-- =================== EXPORTAR ===================
return Oleadas

-- =================== "CLASE" HUD ===================
local Class = require("librerias.hump-master.class")
local Signal = require("librerias.hump-master.signal")

local HUD = Class{}

-- =================== INICIALIZACION ===================
function HUD:init(vidaInicial)
    self.vida = vidaInicial
    self.vidaMaxima = vidaInicial
    self.tiempoRestante = 0

    -- parpadeo de la barra
    self.flashTiempo = 0
    self.flashColor = {1, 1, 1}

    Signal.register("jugador_danado", function(vida)
        self.vida = vida
        self.flashTiempo = 0.15
        self.flashColor = {1, 1, 1} -- blanco al recibir dano
    end)
    Signal.register("jugador_curado", function(vida)
        self.vida = vida
        self.flashTiempo = 0.3
        self.flashColor = {0.2, 1, 0.3} -- verde al curarse
    end)
end

-- =================== ACTUALIZAR ===================
function HUD:Actualizar(tiempoRestante, dt)
    self.tiempoRestante = tiempoRestante

    if self.flashTiempo > 0 then
        self.flashTiempo = self.flashTiempo - dt
    end
end

-- =================== RENDERIZADO ===================
function HUD:Dibujar()
    local x, y = 10, 10
    local ancho, alto = 200, 20
    local proporcion = math.max(self.vida, 0) / self.vidaMaxima

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, ancho, alto)

    love.graphics.setColor(0.8, 0.1, 0.1)
    love.graphics.rectangle("fill", x, y, ancho * proporcion, alto)

    if self.flashTiempo > 0 then
        love.graphics.setColor(self.flashColor[1], self.flashColor[2], self.flashColor[3], 0.6)
        love.graphics.rectangle("fill", x, y, ancho * proporcion, alto)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, ancho, alto)
    love.graphics.print(math.floor(self.vida) .. " / " .. self.vidaMaxima, x + 70, y + 3)

    love.graphics.print("Resiste: " .. math.floor(math.max(self.tiempoRestante, 0)), 350, 10)
end

-- =================== EXPORTAR ===================
return HUD
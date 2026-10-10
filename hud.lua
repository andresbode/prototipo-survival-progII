-- =================== "CLASE" HUD ===================
local Class = require("librerias.hump-master.class")
local Signal = require("librerias.hump-master.signal")

local HUD = Class{}

-- =================== INICIALIZACION ===================
function HUD:init(vidaInicial)
    self.vida = vidaInicial
    self.vidaMaxima = vidaInicial
    self.tiempoRestante = 0

    -- El HUD escucha los eventos del jugador y guarda la vida que le llega
    Signal.register("jugador_danado", function(vida)
        self.vida = vida
    end)
    Signal.register("jugador_curado", function(vida)
        self.vida = vida
    end)
end

-- =================== ACTUALIZAR ===================
function HUD:Actualizar(tiempoRestante)
    self.tiempoRestante = tiempoRestante
end

-- =================== RENDERIZADO ===================
function HUD:Dibujar()
    local x, y = 10, 10
    local ancho, alto = 200, 20
    local proporcion = math.max(self.vida, 0) / self.vidaMaxima

    -- Fondo de la barra
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, ancho, alto)

    -- Relleno: se achica segun la vida que queda
    love.graphics.setColor(0.8, 0.1, 0.1)
    love.graphics.rectangle("fill", x, y, ancho * proporcion, alto)

    -- Borde y numero
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, ancho, alto)
    love.graphics.print(math.floor(self.vida) .. " / " .. self.vidaMaxima, x + 70, y + 3)

    love.graphics.print("Resiste: " .. math.floor(math.max(self.tiempoRestante, 0)), 350, 10)
end

-- =================== EXPORTAR ===================
return HUD
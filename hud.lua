-- =================== "CLASE" HUD ===================
local Class = require("librerias.hump-master.class")
local Signal = require("librerias.hump-master.signal")

local HUD = Class{}

-- =================== INICIALIZACION ===================
function HUD:init(vidaInicial)
    self.vida = vidaInicial
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
    love.graphics.print("Vida: " .. math.floor(self.vida), 10, 10)
    love.graphics.print("Resiste: " .. math.floor(math.max(self.tiempoRestante, 0)), 350, 10)
end

-- =================== EXPORTAR ===================
return HUD
local Class = require("librerias.hump-master.class")

local Animacion = Class{}

function Animacion:init(imagen, anchoFrame, altoFrame, cantidadFrames, duracionFrame)
    self.imagen = imagen
    self.anchoFrame = anchoFrame
    self.altoFrame = altoFrame
    self.cantidadFrames = cantidadFrames
    self.duracionFrame = duracionFrame

    self.frameActual = 1
    self.tiempoAcumulado = 0

    self.quads = {}
    for i = 0, cantidadFrames - 1 do
        self.quads[i + 1] = love.graphics.newQuad(
            i * anchoFrame, 0,
            anchoFrame, altoFrame,
            imagen:getWidth(), imagen:getHeight()
        )
    end
end

-- =================== ACTUALIZAR ===================
function Animacion:Actualizar(dt)
    self.tiempoAcumulado = self.tiempoAcumulado + dt

    if self.tiempoAcumulado >= self.duracionFrame then
        self.tiempoAcumulado = 0
        self.frameActual = self.frameActual + 1
        if self.frameActual > self.cantidadFrames then
            self.frameActual = 1 -- vuelve al primer frame, loop infinito
        end
    end
end

-- =================== RENDERIZADO ===================
function Animacion:Dibujar(x, y, escala)
    love.graphics.draw(self.imagen, self.quads[self.frameActual], x, y, 0, escala, escala)
end

-- =================== EXPORTAR ===================
return Animacion
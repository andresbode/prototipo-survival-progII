-- =================== "CLASE" ANIMACION ===================
local Animacion = {}
Animacion.__index = Animacion

-- =================== INICIALIZACION ===================
-- imagen: la imagen ya cargada (love.graphics.newImage)
-- anchoFrame, altoFrame: tamaño de un solo frame dentro del spritesheet
-- cantidadFrames: cuantos frames tiene la animacion
-- duracionFrame: cuanto tiempo (segundos) se muestra cada frame antes de pasar al siguiente
function Animacion.Nueva(imagen, anchoFrame, altoFrame, cantidadFrames, duracionFrame)
    local o = setmetatable({}, Animacion)
    o.imagen = imagen
    o.anchoFrame = anchoFrame
    o.altoFrame = altoFrame
    o.cantidadFrames = cantidadFrames
    o.duracionFrame = duracionFrame

    o.frameActual = 1
    o.tiempoAcumulado = 0

    -- Generamos un quad (recorte) por cada frame del spritesheet
    o.quads = {}
    for i = 0, cantidadFrames - 1 do
        o.quads[i + 1] = love.graphics.newQuad(
            i * anchoFrame, 0, -- posicion x,y del recorte dentro de la imagen
            anchoFrame, altoFrame, -- tamaño del recorte
            imagen:getWidth(), imagen:getHeight() -- tamaño total de la imagen 
        )
    end

    return o
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
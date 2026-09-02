-- =================== "CLASE" BOTIQUIN ===================
local Botiquin = {}
Botiquin.__index = Botiquin

-- =================== INICIALIZACION ===================
function Botiquin.Nuevo(img, escala, curacion)
    local o = setmetatable({}, Botiquin)
    o.escala = escala
    o.curacion = curacion
    o.activo = true
    o.imagen = love.graphics.newImage(img)
    o.ancho = o.imagen:getWidth() * escala
    o.alto = o.imagen:getHeight() * escala

    -- Posicion aleatoria dentro de los limites de la pantalla
    o.x = love.math.random(0, love.graphics.getWidth() - o.ancho)
    o.y = love.math.random(0, love.graphics.getHeight() - o.alto)

    return o
end

-- =================== RENDERIZADO ===================
function Botiquin:Dibujar()
    if self.activo then
        love.graphics.draw(self.imagen, self.x, self.y, 0, self.escala, self.escala)
    end
end

-- =================== EXPORTAR ===================
return Botiquin
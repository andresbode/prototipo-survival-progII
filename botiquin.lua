local Class = require("librerias.hump-master.class")

local Botiquin = Class{}

function Botiquin:init(img, escala, curacion)
    self.escala = escala
    self.curacion = curacion
    self.activo = true
    self.imagen = love.graphics.newImage(img)
    self.ancho = self.imagen:getWidth() * escala
    self.alto = self.imagen:getHeight() * escala

    self.x = love.math.random(0, love.graphics.getWidth() - self.ancho)
    self.y = love.math.random(0, love.graphics.getHeight() - self.alto)
end

-- =================== RENDERIZADO ===================
function Botiquin:Dibujar()
    if self.activo then
        love.graphics.draw(self.imagen, self.x, self.y, 0, self.escala, self.escala)
    end
end

-- =================== EXPORTAR ===================
return Botiquin
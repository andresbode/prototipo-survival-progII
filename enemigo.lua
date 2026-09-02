-- =================== "CLASE" ENEMIGO ===================
local Enemigo = {}
Enemigo.__index = Enemigo

-- =================== INICIALIZACION ===================
function Enemigo.Nuevo(x, y, img, velocidad, escala)
    local o = setmetatable({}, Enemigo)
    o.x = x
    o.y = y
    o.velocidad = velocidad
    o.escala = escala
    o.imagen = love.graphics.newImage(img)
    o.ancho = o.imagen:getWidth() * escala
    o.alto = o.imagen:getHeight() * escala
    return o
end

-- =================== ACTUALIZAR ===================
function Enemigo:Actualizar(jugadorX, jugadorY, distanciaMinima, dt)
    local dx = jugadorX - self.x
    local dy = jugadorY - self.y
    local distancia = math.sqrt(dx * dx + dy * dy)

    if distancia > distanciaMinima then
        self.x = self.x + (dx / distancia) * self.velocidad * dt
        self.y = self.y + (dy / distancia) * self.velocidad * dt
    end
end

-- =================== RENDERIZADO ===================
function Enemigo:Dibujar()
    love.graphics.draw(self.imagen, self.x, self.y, 0, self.escala, self.escala)
end

-- =================== EXPORTAR ===================
return Enemigo
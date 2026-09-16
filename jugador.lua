-- =================== "CLASE" JUGADOR ===================
local Jugador = {}
Jugador.__index = Jugador

-- =================== INICIALIZACION ===================
function Jugador.Nuevo(x, y, img, velocidad, escala, mundo)
    local o = setmetatable({}, Jugador)
    o.x = x
    o.y = y
    o.velocidad = velocidad
    o.escala = escala
    o.vida = 100
    o.flashTiempo = 0
    o.imagen = love.graphics.newImage(img)
    o.ancho = o.imagen:getWidth() * escala
    o.alto = o.imagen:getHeight() * escala
    o.mundo = mundo -- guardamos referencia al mundo de Bump

    -- Registramos al jugador como un objeto mas dentro del mundo de colisiones
    o.mundo:add(o, o.x, o.y, o.ancho, o.alto)

    return o
end

-- =================== ACTUALIZAR ===================
function Jugador:Actualizar(dt)
    local moverX, moverY = 0, 0

    if love.keyboard.isDown("w") then moverY = moverY - self.velocidad * dt end
    if love.keyboard.isDown("s") then moverY = moverY + self.velocidad * dt end
    if love.keyboard.isDown("a") then moverX = moverX - self.velocidad * dt end
    if love.keyboard.isDown("d") then moverX = moverX + self.velocidad * dt end

    local destinoX = self.x + moverX
    local destinoY = self.y + moverY

    -- Le preguntamos a Bump: si me muevo ahi, cual es mi posicion real (corregida si hay colision)
    local x, y = self.mundo:move(self, destinoX, destinoY)
    self.x = x
    self.y = y

    if self.flashTiempo > 0 then
        self.flashTiempo = self.flashTiempo - dt
    end
end

-- =================== RECIBIR DAÑO ===================
function Jugador:RecibirDano(cantidad)
    self.vida = self.vida - cantidad
    self.flashTiempo = 0.1
    if self.vida < 0 then self.vida = 0 end
end

-- =================== CURAR ===================
function Jugador:Curar(cantidad)
    self.vida = self.vida + cantidad
    if self.vida > 100 then self.vida = 100 end
end

-- =================== RENDERIZADO ===================
function Jugador:Dibujar()
    if self.flashTiempo > 0 then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.draw(self.imagen, self.x, self.y, 0, self.escala, self.escala)
    love.graphics.setColor(1, 1, 1)
end

-- =================== EXPORTAR ===================
return Jugador
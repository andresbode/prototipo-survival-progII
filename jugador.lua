-- =================== "CLASE" JUGADOR ===================
local Jugador = {}
Jugador.__index = Jugador

-- =================== INICIALIZACION ===================
function Jugador.Nuevo(x, y, img, velocidad, escala)
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
    return o
end

-- =================== ACTUALIZAR ===================
function Jugador:Actualizar(dt)
    if love.keyboard.isDown("w") then
        self.y = self.y - self.velocidad * dt
    end
    if love.keyboard.isDown("s") then
        self.y = self.y + self.velocidad * dt
    end
    if love.keyboard.isDown("a") then
        self.x = self.x - self.velocidad * dt
    end
    if love.keyboard.isDown("d") then
        self.x = self.x + self.velocidad * dt
    end

    local anchoPantalla = love.graphics.getWidth()
    local altoPantalla = love.graphics.getHeight()

    if self.x < 0 then self.x = 0 end
    if self.y < 0 then self.y = 0 end
    if self.x + self.ancho > anchoPantalla then self.x = anchoPantalla - self.ancho end
    if self.y + self.alto > altoPantalla then self.y = altoPantalla - self.alto end

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
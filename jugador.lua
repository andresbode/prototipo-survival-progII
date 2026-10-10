-- =================== "CLASE" JUGADOR ===================
local Class = require("librerias.hump-master.class")
local ClaseAnimacion = require("animacion")
local Signal = require("librerias.hump-master.signal")

local Jugador = Class{}

-- =================== INICIALIZACION ===================
function Jugador:init(x, y, img, velocidad, escala, mundo)
    self.x = x
    self.y = y
    self.velocidad = velocidad
    self.escala = escala
    self.vida = 100
    self.flashTiempo = 0
    self.imagen = love.graphics.newImage(img)
    self.ancho = 17 * escala
    self.alto = 22 * escala
    self.mundo = mundo

    -- Animaciones de caminar en las 4 direcciones
    self.animIzquierda = ClaseAnimacion(love.graphics.newImage("assets/animaciones/caminarIzquierda.png"), 17, 23, 4, 0.15)
    self.animDerecha   = ClaseAnimacion(love.graphics.newImage("assets/animaciones/caminarDerecha.png"), 17, 23, 4, 0.15)
    self.animAbajo     = ClaseAnimacion(love.graphics.newImage("assets/animaciones/caminarAbajo.png"), 20, 22, 4, 0.15)
    self.animArriba    = ClaseAnimacion(love.graphics.newImage("assets/animaciones/caminarArriba.png"), 20, 22, 4, 0.15)

    self.animando = false
    self.animacionActual = nil -- cual de las 4 animaciones se esta mostrando ahora

    self.mundo:add(self, self.x, self.y, self.ancho, self.alto)
end

-- =================== ACTUALIZAR ===================
function Jugador:Actualizar(dt)
    local moverX, moverY = 0, 0
    self.animando = false

    if love.keyboard.isDown("w") then
        moverY = -self.velocidad * dt
        self.animando = true
        self.animacionActual = self.animArriba
    elseif love.keyboard.isDown("s") then
        moverY = self.velocidad * dt
        self.animando = true
        self.animacionActual = self.animAbajo
    elseif love.keyboard.isDown("a") then
        moverX = -self.velocidad * dt
        self.animando = true
        self.animacionActual = self.animIzquierda
    elseif love.keyboard.isDown("d") then
        moverX = self.velocidad * dt
        self.animando = true
        self.animacionActual = self.animDerecha
    end

    if self.animando then
        self.animacionActual:Actualizar(dt)
    end

    local destinoX = self.x + moverX
    local destinoY = self.y + moverY

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
    Signal.emit("jugador_danado", cantidad) --avisa que el jugador recibió daño
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

    if self.animando then
        self.animacionActual:Dibujar(self.x, self.y, self.escala)
    else
        love.graphics.draw(self.imagen, self.x, self.y, 0, self.escala, self.escala)
    end

    love.graphics.setColor(1, 1, 1)
end

-- =================== EXPORTAR ===================
return Jugador
-- =================== "CLASE" JUGADOR ===================
local Class = require("librerias.hump-master.class")
local ClaseAnimacion = require("animacion")
local Signal = require("librerias.hump-master.signal")
local Timer = require("librerias.hump-master.timer")

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

    -- Dash
    self.dashActivo = false
    self.dashTiempo = 0          -- cuanto le queda al dash en curso
    self.dashDuracion = 0.15     -- segundos que dura la rafaga
    self.dashVelocidad = velocidad * 3
    self.dashCooldown = 0        -- cuanto falta para poder usarlo de nuevo
    self.dashEspera = 2          -- segundos entre dashes
    self.dashDireccionX = 0
    self.dashDireccionY = 0

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
    local dirX, dirY = 0, 0
    self.animando = false

    if love.keyboard.isDown("w") then
        dirY = -1
        self.animando = true
        self.animacionActual = self.animArriba
    elseif love.keyboard.isDown("s") then
        dirY = 1
        self.animando = true
        self.animacionActual = self.animAbajo
    elseif love.keyboard.isDown("a") then
        dirX = -1
        self.animando = true
        self.animacionActual = self.animIzquierda
    elseif love.keyboard.isDown("d") then
        dirX = 1
        self.animando = true
        self.animacionActual = self.animDerecha
    end

    -- Cooldown del dash: avisa cuando vuelve a estar listo
    if self.dashCooldown > 0 then
        self.dashCooldown = self.dashCooldown - dt
        if self.dashCooldown <= 0 then
            Signal.emit("dash_listo")
        end
    end

    -- Arranca el dash: Shift + una direccion apretada + cooldown terminado
    if love.keyboard.isDown("lshift", "rshift") and not self.dashActivo
        and self.dashCooldown <= 0 and (dirX ~= 0 or dirY ~= 0) then
        self.dashActivo = true
        self.dashTiempo = self.dashDuracion
        self.dashDireccionX = dirX
        self.dashDireccionY = dirY
        self.dashCooldown = self.dashEspera
        Signal.emit("dash_usado")
    end

    -- Movimiento: rafaga si hay dash, velocidad normal si no
    local moverX, moverY
    if self.dashActivo then
        moverX = self.dashDireccionX * self.dashVelocidad * dt
        moverY = self.dashDireccionY * self.dashVelocidad * dt
        self.dashTiempo = self.dashTiempo - dt
        if self.dashTiempo <= 0 then
            self.dashActivo = false
        end
    else
        moverX = dirX * self.velocidad * dt
        moverY = dirY * self.velocidad * dt
    end

    if self.animando then
        self.animacionActual:Actualizar(dt)
    end

    local x, y = self.mundo:move(self, self.x + moverX, self.y + moverY)
    self.x = x
    self.y = y

    if self.flashTiempo > 0 then
        self.flashTiempo = self.flashTiempo - dt
    end
end

-- =================== RECIBIR DAÑO ===================
function Jugador:RecibirDano(cantidad)
    if self.dashActivo then return false end -- dash invulnerable

    self.vida = self.vida - cantidad
    self.flashTiempo = 0.1
    if self.vida < 0 then self.vida = 0 end

    Signal.emit("jugador_danado", self.vida)
    return true -- avisa que el golpe sí entró
end

-- =================== CURAR ===================
function Jugador:Curar(cantidad)
    self.vida = self.vida + cantidad
    if self.vida > 100 then self.vida = 100 end
    Signal.emit("jugador_curado", self.vida) 
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
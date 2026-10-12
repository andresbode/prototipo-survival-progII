-- =================== "CLASE" ENEMIGO ===================
local Class = require("librerias.hump-master.class")
local ClaseAnimacion = require("animacion")

local Enemigo = Class{}

-- =================== INICIALIZACION ===================
function Enemigo:init(x, y, img, velocidad, escala)
    self.x = x
    self.y = y
    self.velocidad = velocidad
    self.escala = escala
    self.imagen = love.graphics.newImage(img)
    self.ancho = 17 * escala
    self.alto = 22 * escala
        -- Golpe propio: cada enemigo pega una vez por segundo mientras toca al jugador
    self.golpeEspera = 1
    self.golpeCooldown = 0

    self.estado = "patrulla"
    self.radioDeteccion = 250
    self.radioAtaque = 0

    self.puntoA = { x = x, y = y }
    self.puntoB = {
        x = x + love.math.random(-150, 150),
        y = y + love.math.random(-150, 150)
    }
    self.destino = self.puntoB

    self.animIzquierda = ClaseAnimacion(love.graphics.newImage("assets/animaciones/caminarIzquierdaEnemigo.png"), 17, 23, 4, 0.15)
    self.animDerecha   = ClaseAnimacion(love.graphics.newImage("assets/animaciones/caminarDerechaEnemigo.png"), 17, 23, 4, 0.15)
    self.animAbajo     = ClaseAnimacion(love.graphics.newImage("assets/animaciones/caminarAbajoEnemigo.png"), 20, 22, 4, 0.15)
    self.animArriba    = ClaseAnimacion(love.graphics.newImage("assets/animaciones/caminarArribaEnemigo.png"), 20, 22, 4, 0.15)

    self.animando = false
    self.animacionActual = self.animAbajo

    return self
end

-- =================== ACTUALIZAR ===================
function Enemigo:Actualizar(jugadorX, jugadorY, jugadorAncho, dt)
        if self.golpeCooldown > 0 then
        self.golpeCooldown = self.golpeCooldown - dt
    end
    local dx = jugadorX - self.x
    local dy = jugadorY - self.y
    local distancia = math.sqrt(dx * dx + dy * dy)

    self.radioAtaque = (jugadorAncho + self.ancho) / 2
    self.animando = false

    if distancia <= self.radioAtaque then
        self.estado = "ataca"
    elseif distancia <= self.radioDeteccion then
        self.estado = "persigue"
    else
        self.estado = "patrulla"
    end

    if self.estado == "persigue" then
        self:MoverHacia(dx, dy, distancia, self.velocidad, dt)

    elseif self.estado == "ataca" then
        -- Se queda quieto, el daño lo maneja la colision en main.lua

    elseif self.estado == "patrulla" then
        local dxPatrulla = self.destino.x - self.x
        local dyPatrulla = self.destino.y - self.y
        local distPatrulla = math.sqrt(dxPatrulla * dxPatrulla + dyPatrulla * dyPatrulla)

        if distPatrulla > 5 then
            self:MoverHacia(dxPatrulla, dyPatrulla, distPatrulla, self.velocidad / 2, dt)
        else
            if self.destino == self.puntoA then
                self.destino = self.puntoB
            else
                self.destino = self.puntoA
            end
        end
    end

    if self.animando then
        self.animacionActual:Actualizar(dt)
    end
end

-- =================== MOVER EN DIAGONAL LIBRE, ELIGIENDO ANIMACION SEGUN EJE DOMINANTE ===================
function Enemigo:MoverHacia(dx, dy, distancia, velocidad, dt)
    self.animando = true

    self.x = self.x + (dx / distancia) * velocidad * dt
    self.y = self.y + (dy / distancia) * velocidad * dt

    if math.abs(dx) > math.abs(dy) then
        if dx > 0 then
            self.animacionActual = self.animDerecha
        else
            self.animacionActual = self.animIzquierda
        end
    else
        if dy > 0 then
            self.animacionActual = self.animAbajo
        else
            self.animacionActual = self.animArriba
        end
    end
end

-- =================== RENDERIZADO ===================
function Enemigo:Dibujar()
    if self.animando then
        self.animacionActual:Dibujar(self.x, self.y, self.escala)
    else
        love.graphics.draw(self.imagen, self.x, self.y, 0, self.escala, self.escala)
    end
end

-- =================== EXPORTAR ===================
return Enemigo
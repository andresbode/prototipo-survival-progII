-- =================== "CLASE" ENEMIGO ===================
local Enemigo = {}
Enemigo.__index = Enemigo
local ClaseAnimacion = require("animacion")

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

    o.estado = "patrulla"
    o.radioDeteccion = 250
    o.radioAtaque = 0

    o.puntoA = { x = x, y = y }
    o.puntoB = {
        x = x + love.math.random(-150, 150),
        y = y + love.math.random(-150, 150)
    }
    o.destino = o.puntoB

    o.animIzquierda = ClaseAnimacion.Nueva(love.graphics.newImage("assets/animaciones/caminarIzquierdaEnemigo.png"), 17, 23, 4, 0.15)
    o.animDerecha   = ClaseAnimacion.Nueva(love.graphics.newImage("assets/animaciones/caminarDerechaEnemigo.png"), 17, 23, 4, 0.15)
    o.animAbajo     = ClaseAnimacion.Nueva(love.graphics.newImage("assets/animaciones/caminarAbajoEnemigo.png"), 20, 22, 4, 0.15)
    o.animArriba    = ClaseAnimacion.Nueva(love.graphics.newImage("assets/animaciones/caminarArribaEnemigo.png"), 20, 22, 4, 0.15)

    o.animando = false
    o.animacionActual = o.animAbajo

    return o
end

-- =================== ACTUALIZAR ===================
function Enemigo:Actualizar(jugadorX, jugadorY, jugadorAncho, dt)
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
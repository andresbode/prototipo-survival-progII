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

    o.estado = "patrulla"
    o.radioDeteccion = 250
    o.radioAtaque = 0

    -- Puntos de patrulla: A es la posicion inicial, B es un punto random cercano
    o.puntoA = { x = x, y = y }
    o.puntoB = {
        x = x + love.math.random(-150, 150),
        y = y + love.math.random(-150, 150)
    }
    o.destino = o.puntoB -- arranca yendo hacia B

    return o
end

-- =================== ACTUALIZAR ===================
function Enemigo:Actualizar(jugadorX, jugadorY, jugadorAncho, dt)
    local dx = jugadorX - self.x
    local dy = jugadorY - self.y
    local distancia = math.sqrt(dx * dx + dy * dy)

    self.radioAtaque = (jugadorAncho + self.ancho) / 2

    -- Transicion de estados segun la distancia al jugador
    if distancia <= self.radioAtaque then
        self.estado = "ataca"
    elseif distancia <= self.radioDeteccion then
        self.estado = "persigue"
    else
        self.estado = "patrulla"
    end

    -- Comportamiento segun el estado actual
    if self.estado == "persigue" then
        self.x = self.x + (dx / distancia) * self.velocidad * dt
        self.y = self.y + (dy / distancia) * self.velocidad * dt

    elseif self.estado == "ataca" then
        -- Se queda quieto, el daño lo maneja la colision en main.lua

    elseif self.estado == "patrulla" then
        local dxPatrulla = self.destino.x - self.x
        local dyPatrulla = self.destino.y - self.y
        local distPatrulla = math.sqrt(dxPatrulla * dxPatrulla + dyPatrulla * dyPatrulla)

        if distPatrulla > 5 then
            self.x = self.x + (dxPatrulla / distPatrulla) * (self.velocidad / 2) * dt
            self.y = self.y + (dyPatrulla / distPatrulla) * (self.velocidad / 2) * dt
        else
            -- Llego al destino, cambia al otro punto
            if self.destino == self.puntoA then
                self.destino = self.puntoB
            else
                self.destino = self.puntoA
            end
        end
    end
end

-- =================== RENDERIZADO ===================
function Enemigo:Dibujar()
    love.graphics.draw(self.imagen, self.x, self.y, 0, self.escala, self.escala)
end

-- =================== EXPORTAR ===================
return Enemigo
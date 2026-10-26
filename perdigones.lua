-- =================== "CLASE" PERDIGONES (OBJECT POOL) ===================
local Class = require("librerias.hump-master.class")

local Perdigones = Class{}

-- =================== INICIALIZACION ===================
function Perdigones:init(cantidadMaxima)
    self.velocidad = 600
    self.alcance = 350 -- distancia maxima que recorre cada perdigon

    -- Se crean todos una sola vez; despues solo se activan y desactivan
    self.lista = {}
    for i = 1, cantidadMaxima do
        self.lista[i] = { activo = false, x = 0, y = 0, dx = 0, dy = 0, recorrido = 0, ancho = 6, alto = 6 }
    end
end

-- =================== DISPARAR ===================
-- Activa un perdigon libre en (x, y) con el angulo dado
function Perdigones:Disparar(x, y, angulo)
    for _, p in ipairs(self.lista) do
        if not p.activo then
            p.activo = true
            p.x = x - p.ancho / 2 -- x, y son la esquina superior izquierda, como el resto de las entidades
            p.y = y - p.alto / 2
            p.dx = math.cos(angulo)
            p.dy = math.sin(angulo)
            p.recorrido = 0
            return
        end
    end
end

-- =================== ACTUALIZAR ===================
function Perdigones:Actualizar(dt)
    for _, p in ipairs(self.lista) do
        if p.activo then
            local paso = self.velocidad * dt
            p.x = p.x + p.dx * paso
            p.y = p.y + p.dy * paso
            p.recorrido = p.recorrido + paso
            if p.recorrido >= self.alcance then
                p.activo = false -- vuelve al pool
            end
        end
    end
end

-- =================== IMPACTO ===================
-- Devuelve cuantos perdigones activos tocaron al objetivo y los devuelve al pool
function Perdigones:Impacto(objetivo)
    local impactos = 0
    for _, p in ipairs(self.lista) do
        if p.activo and ComprobarColision(p, objetivo) then
            p.activo = false
            impactos = impactos + 1
        end
    end
    return impactos
end

-- =================== RENDERIZADO ===================
function Perdigones:Dibujar()
    love.graphics.setColor(1, 0.9, 0.3)
    for _, p in ipairs(self.lista) do
        if p.activo then
            love.graphics.rectangle("fill", p.x, p.y, p.ancho, p.alto)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

-- =================== EXPORTAR ===================
return Perdigones
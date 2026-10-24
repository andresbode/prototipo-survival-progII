-- =================== "CLASE" ESCOPETA ===================
local Class = require("librerias.hump-master.class")
local Signal = require("librerias.hump-master.signal")

local Escopeta = Class {}

-- =================== INICIALIZACION ===================
function Escopeta:init(img, escala)
    self.imagen = love.graphics.newImage(img)
    self.escala = escala

    -- Punto de giro dentro del sprite: la empuñadura (lado izquierdo, centro vertical)
    self.origenX = 6
    self.origenY = self.imagen:getHeight() / 2

    -- Donde se ancla respecto al centro del jugador (en pixeles de pantalla)
    self.anclajeX = 0
    self.anclajeY = 10

    self.x = 0
    self.y = 0
    self.angulo = 0
    self.espejada = false

    -- Disparo
    self.cooldown = 0
    self.cadencia = 0.6
    self.cantidadPerdigones = 5
    self.dispersion = 0.25 -- radianes a cada lado del punto de mira

    -- Retroceso
    self.retroceso = 0
    self.retrocesoMax = 6
    self.offsetX = 0
    self.offsetY = 0
end

-- =================== ACTUALIZAR ===================
function Escopeta:Actualizar(jugador, mouseX, mouseY, dt)
    self.x = jugador.x + jugador.ancho / 2 + self.anclajeX
    self.y = jugador.y + jugador.alto / 2 + self.anclajeY

    self.angulo = math.atan2(mouseY - self.y, mouseX - self.x)
    self.espejada = mouseX < self.x

    if self.cooldown > 0 then
        self.cooldown = self.cooldown - dt
    end

    -- El retroceso baja solo; mientras dura, el arma se corre hacia atras y tiembla
    if self.retroceso > 0 then
        self.retroceso = math.max(0, self.retroceso - 60 * dt)
    end
    local temblor = self.retroceso * 0.25
    self.offsetX = -math.cos(self.angulo) * self.retroceso + love.math.random(-1, 1) * temblor
    self.offsetY = -math.sin(self.angulo) * self.retroceso + love.math.random(-1, 1) * temblor
end

-- =================== DISPARAR ===================
function Escopeta:Disparar(perdigones)
    if self.cooldown > 0 then return end
    self.cooldown = self.cadencia
    self.retroceso = self.retrocesoMax

    -- La boca del arma es el extremo del sprite, en la direccion de apuntado
    local largo = (self.imagen:getWidth() - self.origenX) * self.escala
    local bocaX = self.x + math.cos(self.angulo) * largo
    local bocaY = self.y + math.sin(self.angulo) * largo

    for i = 1, self.cantidadPerdigones do
        local desvio = (love.math.random() * 2 - 1) * self.dispersion
        perdigones:Disparar(bocaX, bocaY, self.angulo + desvio)
    end

    Signal.emit("disparo")
end

-- =================== RENDERIZADO ===================
function Escopeta:Dibujar()
    local escalaY = self.escala
    if self.espejada then escalaY = -self.escala end -- espejo vertical: nunca queda dada vuelta
    love.graphics.draw(self.imagen, self.x + self.offsetX, self.y + self.offsetY, self.angulo, self.escala, escalaY,
        self.origenX, self.origenY)
    love.graphics.draw(self.imagen, self.x, self.y, self.angulo, self.escala, escalaY, self.origenX, self.origenY)
end

-- =================== EXPORTAR ===================
return Escopeta

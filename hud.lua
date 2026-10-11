-- =================== "CLASE" HUD ===================
local Class = require("librerias.hump-master.class")
local Signal = require("librerias.hump-master.signal")

local HUD = Class {}

-- =================== INICIALIZACION ===================
function HUD:init(vidaInicial, dashEspera)
    self.vida = vidaInicial
    self.vidaMaxima = vidaInicial
    self.tiempoRestante = 0

    -- parpadeo de la barra
    self.flashTiempo = 0
    self.flashColor = { 1, 1, 1 }

    -- estado del dash
    self.dashEspera = dashEspera
    self.dashCooldown = 0

    Signal.register("jugador_danado", function(vida)
        self.vida = vida
        self.flashTiempo = 0.15
        self.flashColor = { 1, 1, 1 } -- blanco al recibir dano
    end)
    Signal.register("jugador_curado", function(vida)
        self.vida = vida
        self.flashTiempo = 0.3
        self.flashColor = { 0.2, 1, 0.3 } -- verde al curarse
    end)

    Signal.register("dash_usado", function()
        self.dashCooldown = self.dashEspera
    end)
    Signal.register("dash_listo", function()
        self.dashCooldown = 0
    end)
end

-- =================== ACTUALIZAR ===================
function HUD:Actualizar(tiempoRestante, dt)
    self.tiempoRestante = tiempoRestante

    if self.flashTiempo > 0 then
        self.flashTiempo = self.flashTiempo - dt
    end

    if self.dashCooldown > 0 then
        self.dashCooldown = self.dashCooldown - dt
    end
end

-- =================== RENDERIZADO ===================
function HUD:Dibujar()
    local x, y = 10, 10
    local ancho, alto = 200, 20
    local proporcion = math.max(self.vida, 0) / self.vidaMaxima

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, ancho, alto)

    love.graphics.setColor(0.8, 0.1, 0.1)
    love.graphics.rectangle("fill", x, y, ancho * proporcion, alto)

    if self.flashTiempo > 0 then
        love.graphics.setColor(self.flashColor[1], self.flashColor[2], self.flashColor[3], 0.6)
        love.graphics.rectangle("fill", x, y, ancho * proporcion, alto)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, ancho, alto)
    love.graphics.print(math.floor(self.vida) .. " / " .. self.vidaMaxima, x + 70, y + 3)

    -- Barra del dash debajo de la de vida
    local dashY = y + alto + 6
    local dashAlto = 10
    local dashProporcion = 1 - math.max(self.dashCooldown, 0) / self.dashEspera

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, dashY, ancho, dashAlto)

    if self.dashCooldown > 0 then
        love.graphics.setColor(0.3, 0.5, 0.9) -- cargando
    else
        love.graphics.setColor(0.4, 0.9, 1)   -- listo
    end
    love.graphics.rectangle("fill", x, dashY, ancho * dashProporcion, dashAlto)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, dashY, ancho, dashAlto)

    love.graphics.print("Resiste: " .. math.floor(math.max(self.tiempoRestante, 0)), 350, 10)
end

-- =================== EXPORTAR ===================
return HUD

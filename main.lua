-- =================== DECLARACION ===================
local ClaseJugador = require("jugador")
local ClaseEnemigo = require("enemigo")
local ClaseBotiquin = require("botiquin")

JuegoTerminado = false
Tiempo = 0
TiempoParaGanar = 21
Gane = false
SonidoGolpe = nil

Jugador = nil  -- se crea en load() como instancia de la clase Jugador
Enemigo = nil  -- se crea en load() como instancia de la clase Enemigo
Botiquin = nil -- se crea en load() como instancia de la clase Botiquin

-- =================== INICIALIZACION ===================
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest") -- pixel art nitido, sin desenfoque al escalar

    Jugador = ClaseJugador.Nuevo(400, 300, "assets/personaje.png", 200, 2)
    Enemigo = ClaseEnemigo.Nuevo(100, 100, "assets/enemigo.png", 120, 2)
    Botiquin = ClaseBotiquin.Nuevo("assets/botiquin.png", 1, 30)

    SonidoGolpe = love.audio.newSource("assets/efectoGolpe.mp3", "static")
end

-- =================== INTERACCION ===================


-- =================== FUNCIONES AUXILIARES ===================

-- Comprueba colision entre dos entidades usando AABB (cajas rectangulares)
-- Recibe dos tablas con x, y, ancho, alto y devuelve true si se superponen
function ComprobarColision(a, b)
    return a.x < b.x + b.ancho
        and a.x + a.ancho > b.x
        and a.y < b.y + b.alto
        and a.y + a.alto > b.y
end

-- =================== ACTUALIZACION ===================
function love.update(dt)
    if not JuegoTerminado then
        -- Movimiento, limites de pantalla y flash: delegado al metodo Actualizar del Jugador
        Jugador:Actualizar(dt)

        -- IA del enemigo: delegada al metodo Actualizar de la clase Enemigo
        local distanciaMinima = (Jugador.ancho + Enemigo.ancho) / 2
        Enemigo:Actualizar(Jugador.x, Jugador.y, Jugador.ancho, dt)

        -- Colision jugador-enemigo: resta vida, activa flash rojo y sonido de golpe
        if ComprobarColision(Jugador, Enemigo) then
            Jugador:RecibirDano(50 * dt)
            if not SonidoGolpe:isPlaying() then
                love.audio.play(SonidoGolpe)
            end
        end

        -- Contador de tiempo para la condicion de victoria
        Tiempo = Tiempo + dt
        if Tiempo >= TiempoParaGanar then
            JuegoTerminado = true
            Gane = true
        end

        -- Condicion de derrota
        if Jugador.vida <= 0 then
            JuegoTerminado = true
        end

        -- Colision jugador-botiquin: cura y desactiva el item
        if Botiquin.activo and ComprobarColision(Jugador, Botiquin) then
            Jugador:Curar(Botiquin.curacion)
            Botiquin.activo = false
        end
    end
end

-- =================== RENDERIZADO ===================
function love.draw()
    -- Dibujar jugador, enemigo y botiquin delegado a sus propios metodos Dibujar
    Jugador:Dibujar()
    Enemigo:Dibujar()
    Botiquin:Dibujar()

    -- HUD: vida y tiempo restante
    love.graphics.print("Vida: " .. math.floor(Jugador.vida), 10, 10)
    love.graphics.print("Resiste: " .. math.floor(math.max(TiempoParaGanar - Tiempo, 0)), 350, 10)

    -- Mensaje de fin de juego (victoria o derrota)
    if JuegoTerminado then
        if Gane then
            love.graphics.print("GANASTE!", 350, 280)
        else
            love.graphics.print("GAME OVER", 350, 280)
        end
    end
end
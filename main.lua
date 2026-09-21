-- =================== DECLARACION ===================
local ClaseJugador = require("jugador")
local ClaseEnemigo = require("enemigo")
local ClaseBotiquin = require("botiquin")
local ClaseMapa = require("mapa")
local Camera = require("librerias.hump-master.camera")

Mapa = nil
Mundo = nil
Camara = nil

JuegoTerminado = false
Tiempo = 0
TiempoParaGanar = 1100
Gane = false

--Sonidos
musica = nil
SonidoGolpe = nil

Jugador = nil
Enemigos = {} -- lista de enemigos, para poder crear varios que en un futuro serán oleadas.
Botiquin = nil

-- =================== INICIALIZACION ===================
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    Mapa, Mundo = ClaseMapa.Cargar("assets/mapa/mapaPrueba.lua")

    Jugador = ClaseJugador.Nuevo(400, 300, "assets/animaciones/personaje1.png", 200, 2, Mundo) -- le pasamos Mundo

    Camara = Camera(Jugador.x + Jugador.ancho / 2, Jugador.y + Jugador.alto / 2)

    Enemigos[1] = ClaseEnemigo.Nuevo(100, 100, "assets/animaciones/enemigo.png", 120, 2)
    Enemigos[2] = ClaseEnemigo.Nuevo(600, 150, "assets/animaciones/enemigo.png", 120, 2)
    Enemigos[3] = ClaseEnemigo.Nuevo(300, 450, "assets/animaciones/enemigo.png", 120, 2)

    Botiquin = ClaseBotiquin.Nuevo("assets/botiquin.png", 1, 30)

    --Sonidos
    musica = love.audio.newSource("assets/sonidos/musica.mp3", "stream")
    musica:setLooping(true)
    love.audio.play(musica)
    musica:setVolume(0.50)
    SonidoGolpe = love.audio.newSource("assets/sonidos/efectoGolpe.mp3", "static")
end

-- =================== INTERACCION ===================


-- =================== FUNCIONES AUXILIARES ===================

function ComprobarColision(a, b)
    return a.x < b.x + b.ancho
        and a.x + a.ancho > b.x
        and a.y < b.y + b.alto
        and a.y + a.alto > b.y
end

-- =================== ACTUALIZACION ===================
function love.update(dt)
    if not JuegoTerminado then
        Jugador:Actualizar(dt)
        Camara:lookAt(Jugador.x + Jugador.ancho / 2, Jugador.y + Jugador.alto / 2)
        Mapa:update(dt)

        -- Recorremos todos los enemigos de la lista con un for, para actualizar a cada uno
        for i, enemigo in ipairs(Enemigos) do
            enemigo:Actualizar(Jugador.x, Jugador.y, Jugador.ancho, dt)

            -- Colision jugador-enemigo: se chequea para cada enemigo de la lista
            if ComprobarColision(Jugador, enemigo) then
                Jugador:RecibirDano(50 * dt)
                if not SonidoGolpe:isPlaying() then
                    love.audio.play(SonidoGolpe)
                end
            end
        end

        Tiempo = Tiempo + dt
        if Tiempo >= TiempoParaGanar then
            JuegoTerminado = true
            Gane = true
        end

        if Jugador.vida <= 0 then
            JuegoTerminado = true
        end

        if Botiquin.activo and ComprobarColision(Jugador, Botiquin) then
            Jugador:Curar(Botiquin.curacion)
            Botiquin.activo = false
        end
    end
end

-- =================== RENDERIZADO ===================
function love.draw()
    Camara:attach()

    ClaseMapa.DibujarSuelo(Mapa)
    Jugador:Dibujar()
    for i, enemigo in ipairs(Enemigos) do
        enemigo:Dibujar()
    end
    Botiquin:Dibujar()
    ClaseMapa.DibujarArboles(Mapa)

    Camara:detach()

    -- HUD: se dibuja DESPUES de detach, para que quede fijo en pantalla
    love.graphics.print("Vida: " .. math.floor(Jugador.vida), 10, 10)
    love.graphics.print("Resiste: " .. math.floor(math.max(TiempoParaGanar - Tiempo, 0)), 350, 10)

    if JuegoTerminado then
        if Gane then
            love.graphics.print("GANASTE!", 350, 280)
        else
            love.graphics.print("GAME OVER", 350, 280)
        end
    end
end
-- =================== DECLARACION ===================
local ClaseJugador = require("jugador")
local ClaseEnemigo = require("enemigo")
local ClaseBotiquin = require("botiquin")
local ClaseMapa = require("mapa")
local Camera = require("librerias.hump-master.camera")
local Signal = require("librerias.hump-master.signal")
local ClaseHUD = require("hud")

Mapa = nil
Mundo = nil
Camara = nil
Hud = nil

JuegoTerminado = false
Tiempo = 0
TiempoParaGanar = 11
Gane = false

--Sonidos
musica = nil
SonidoGolpe = nil
SonidoDash = nil
SonidoCuracion = nil

Jugador = nil
Enemigos = {} -- lista de enemigos, para poder crear varios que en un futuro serán oleadas.
Botiquin = nil

-- =================== INICIALIZACION ===================
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    Mapa, Mundo = ClaseMapa.Cargar("assets/mapa/mapaPrueba.lua")

    Jugador = ClaseJugador(400, 300, "assets/animaciones/personaje1.png", 200, 2, Mundo) -- le pasamos Mundo

    Hud = ClaseHUD(Jugador.vida)

    Camara = Camera(Jugador.x + Jugador.ancho / 2, Jugador.y + Jugador.alto / 2)

    Enemigos[1] = ClaseEnemigo(love.math.random(50, 900), love.math.random(50, 600), "assets/animaciones/enemigo.png",
        120, 2)
    Enemigos[2] = ClaseEnemigo(love.math.random(50, 900), love.math.random(50, 600), "assets/animaciones/enemigo.png",
        120, 2)
    Enemigos[3] = ClaseEnemigo(love.math.random(50, 900), love.math.random(50, 600), "assets/animaciones/enemigo.png",
        120, 2)

    Botiquin = ClaseBotiquin("assets/botiquin.png", 1, 30)

    --Sonidos
    musica = love.audio.newSource("assets/sonidos/musica.mp3", "stream")
    SonidoDash = love.audio.newSource("assets/sonidos/sonidoDash.mp3", "static")
    SonidoGolpe = love.audio.newSource("assets/sonidos/efectoGolpe.mp3", "static")
    SonidoCuracion = love.audio.newSource("assets/sonidos/sonidoCuracion.mp3", "static")
    musica:setLooping(true)
    love.audio.play(musica)
    musica:setVolume(0.2)
    SonidoGolpe:setVolume(0.3)

    Signal.register("jugador_danado", function()
        if not SonidoGolpe:isPlaying() then
            love.audio.play(SonidoGolpe)
        end
    end)

    Signal.register("dash_usado", function()
        SonidoDash:stop() -- por si todavía suena, que arranque desde el principio
        love.audio.play(SonidoDash)
    end)

    Signal.register("jugador_curado", function()
        SonidoCuracion:stop()
        love.audio.play(SonidoCuracion)
    end)
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
            end
        end
    end

    Tiempo = Tiempo + dt
    Hud:Actualizar(TiempoParaGanar - Tiempo, dt)

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

    Hud:Dibujar()

    if JuegoTerminado then
        if Gane then
            love.graphics.print("GANASTE!", 350, 280)
        else
            love.graphics.print("GAME OVER", 350, 280)
        end
    end
end

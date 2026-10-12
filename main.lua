-- =================== DECLARACION ===================
require "dependencias"

Mapa = nil
Mundo = nil
Camara = nil
Hud = nil

JuegoTerminado = false
Tiempo = 0
TiempoParaGanar = 11
Gane = false
FuenteTitulo = nil
FuenteOpciones = nil

--Sonidos
musica = nil
SonidoGolpe = nil
SonidoDash = nil
SonidoCuracion = nil
SonidoVictoria = nil
SonidoDerrota = nil

Jugador = nil
Enemigos = {} -- lista de enemigos, para poder crear varios que en un futuro serán oleadas.
Botiquines = {}

-- =================== INICIALIZACION ===================
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    Mapa, Mundo = ClaseMapa.Cargar("assets/mapa/mapaPrueba.lua")

    FuenteTitulo = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 32)
    FuenteOpciones = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 14)

    Jugador = ClaseJugador(400, 300, "assets/animaciones/personaje1.png", 200, 2, Mundo) -- le pasamos Mundo

    Hud = ClaseHUD(Jugador.vida, Jugador.dashEspera)

    Camara = Camera(Jugador.x + Jugador.ancho / 2, Jugador.y + Jugador.alto / 2)

    -- Spawn de enemigos por zonas: el mapa se divide en una grilla y cada zona recibe sus enemigos
    local anchoMapa = Mapa.width * Mapa.tilewidth
    local altoMapa = Mapa.height * Mapa.tileheight
    local columnas, filas = 3, 2
    local enemigosPorZona = 3
    local margen = 100 -- distancia minima a los bordes de cada zona

    local anchoZona = anchoMapa / columnas
    local altoZona = altoMapa / filas

    for fila = 0, filas - 1 do
        for columna = 0, columnas - 1 do
            for i = 1, enemigosPorZona do
                local x = love.math.random(math.floor(columna * anchoZona + margen),
                    math.floor((columna + 1) * anchoZona - margen))
                local y = love.math.random(math.floor(fila * altoZona + margen),
                    math.floor((fila + 1) * altoZona - margen))
                table.insert(Enemigos, ClaseEnemigo(x, y, "assets/animaciones/enemigo.png", 120, 2))
            end
        end
    end

    -- Botiquines: uno en el tercio izquierdo del mapa y otro en el derecho, para que queden lejos
    local margenBotiquin = 100
    local tercio = anchoMapa / 3

    local x1 = love.math.random(margenBotiquin, math.floor(tercio))
    local y1 = love.math.random(margenBotiquin, altoMapa - margenBotiquin)
    local x2 = love.math.random(math.floor(tercio * 2), anchoMapa - margenBotiquin)
    local y2 = love.math.random(margenBotiquin, altoMapa - margenBotiquin)

    table.insert(Botiquines, ClaseBotiquin("assets/botiquin.png", 1, 30, x1, y1))
    table.insert(Botiquines, ClaseBotiquin("assets/botiquin.png", 1, 30, x2, y2))

    --Sonidos
    musica = love.audio.newSource("assets/sonidos/musica.mp3", "stream")
    SonidoDash = love.audio.newSource("assets/sonidos/sonidoDash.mp3", "static")
    SonidoGolpe = love.audio.newSource("assets/sonidos/efectoGolpe.mp3", "static")
    SonidoCuracion = love.audio.newSource("assets/sonidos/sonidoCuracion.mp3", "static")
    SonidoVictoria = love.audio.newSource("assets/sonidos/sonidoVictoria.mp3", "static")
    SonidoDerrota = love.audio.newSource("assets/sonidos/sonidoDerrota.mp3", "static")
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

    Signal.register("juego_ganado", function()
        love.audio.play(SonidoVictoria)
    end)

    Signal.register("juego_perdido", function()
        love.audio.play(SonidoDerrota)
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
        Timer.update(dt)
        Jugador:Actualizar(dt)
        Camara:lookAt(Jugador.x + Jugador.ancho / 2, Jugador.y + Jugador.alto / 2)
        Mapa:update(dt)

        -- Recorremos todos los enemigos de la lista con un for, para actualizar a cada uno
        for i, enemigo in ipairs(Enemigos) do
            enemigo:Actualizar(Jugador.x, Jugador.y, Jugador.ancho, dt)

            -- Colision jugador-enemigo: se chequea para cada enemigo de la lista
            if ComprobarColision(Jugador, enemigo) then
                Jugador:RecibirDano(20)
            end
        end

        for i, botiquin in ipairs(Botiquines) do
            if botiquin.activo and ComprobarColision(Jugador, botiquin) then
                Jugador:Curar(botiquin.curacion)
                botiquin.activo = false
            end
        end

        Tiempo = Tiempo + dt
        Hud:Actualizar(TiempoParaGanar - Tiempo, dt)

        if Jugador.vida <= 0 then
            JuegoTerminado = true
            Signal.emit("juego_perdido")
        elseif Tiempo >= TiempoParaGanar then
            JuegoTerminado = true
            Gane = true
            Signal.emit("juego_ganado")
        end
    end
end

function love.keypressed(key)
    if not JuegoTerminado then return end

    if key == "r" then
        Reiniciar()
    elseif key == "escape" then
        love.event.quit()
    end
end

function Reiniciar()
    love.audio.stop() -- frena la musica y cualquier sonido en curso

    -- Borra los listeners: love.load() y HUD:init los vuelven a registrar
    Signal.clear("jugador_danado", "jugador_curado", "dash_usado", "dash_listo", "juego_ganado", "juego_perdido")
    Timer.clear() -- cancela la invulnerabilidad pendiente del jugador anterior

    Enemigos = {}
    Botiquines = {}
    JuegoTerminado = false
    Gane = false
    Tiempo = 0

    love.load() -- recrea mapa, jugador, HUD, enemigos, botiquines y sonidos
end

-- =================== RENDERIZADO ===================
function love.draw()
    Camara:attach()

    ClaseMapa.DibujarSuelo(Mapa)
    Jugador:Dibujar()
    for i, enemigo in ipairs(Enemigos) do
        enemigo:Dibujar()
    end
    for i, botiquin in ipairs(Botiquines) do
        botiquin:Dibujar()
    end
    ClaseMapa.DibujarArboles(Mapa)

    Camara:detach()

    Hud:Dibujar()

    if JuegoTerminado then
        local fuenteAnterior = love.graphics.getFont()
        local ancho, alto = love.graphics.getDimensions()

        -- Velo oscuro sobre el juego
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, ancho, alto)

        love.graphics.setFont(FuenteTitulo)
        if Gane then
            love.graphics.setColor(0.4, 1, 0.5)
            love.graphics.printf("GANASTE!", 0, alto / 2 - 80, ancho, "center")
        else
            love.graphics.setColor(1, 0.3, 0.3)
            love.graphics.printf("GAME OVER", 0, alto / 2 - 80, ancho, "center")
        end

        love.graphics.setFont(FuenteOpciones)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("R - Reintentar", 0, alto / 2 + 10, ancho, "center")
        love.graphics.printf("Esc - Salir", 0, alto / 2 + 40, ancho, "center")

        -- Restaurar fuente y color para no afectar al HUD del frame siguiente
        love.graphics.setFont(fuenteAnterior)
        love.graphics.setColor(1, 1, 1)
    end
end

-- =================== DECLARACION ===================
require "dependencias"

Mapa = nil
Mundo = nil
Camara = nil
Hud = nil

JuegoTerminado = false
Tiempo = 0
Gane = false
FuenteTitulo = nil
FuenteOpciones = nil
Puntaje = 0
PuntajeSegundos = 0 -- acumula dt para sumar 1 punto por segundo
Oleadas = nil

--Sonidos
musica = nil
SonidoGolpe = nil
SonidoDash = nil
SonidoCuracion = nil
SonidoVictoria = nil
SonidoDerrota = nil
SonidoDisparo = nil
SonidoImpacto = nil
SonidoMuerte = nil

Jugador = nil
Escopeta = nil
Perdigones = nil
Enemigos = {} -- lista de enemigos, para poder crear varios que en un futuro serán oleadas.
Botiquines = {}

-- =================== INICIALIZACION ===================
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    Mapa, Mundo = ClaseMapa.Cargar("assets/mapa/mapaPrueba.lua")

    FuenteTitulo = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 32)
    FuenteOpciones = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 14)

    Jugador = ClaseJugador(400, 300, "assets/animaciones/personaje1.png", 200, 2, Mundo) -- le pasamos Mundo
    Escopeta = ClaseEscopeta("assets/escopeta.png", 1.5)
    Perdigones = ClasePerdigones(30)
    Hud = ClaseHUD(Jugador.vida, Jugador.dashEspera)

    Camara = Camera(Jugador.x + Jugador.ancho / 2, Jugador.y + Jugador.alto / 2)

    Oleadas = ClaseOleadas(Mapa, Jugador, Enemigos, Botiquines)

    --Sonidos
    musica = love.audio.newSource("assets/sonidos/musica.mp3", "stream")
    SonidoDash = love.audio.newSource("assets/sonidos/sonidoDash.mp3", "static")
    SonidoGolpe = love.audio.newSource("assets/sonidos/efectoGolpe.mp3", "static")
    SonidoCuracion = love.audio.newSource("assets/sonidos/sonidoCuracion.mp3", "static")
    SonidoVictoria = love.audio.newSource("assets/sonidos/sonidoVictoria.mp3", "static")
    SonidoDerrota = love.audio.newSource("assets/sonidos/sonidoDerrota.mp3", "static")
    SonidoDisparo = love.audio.newSource("assets/sonidos/sonidoDisparo.mp3", "static")
    SonidoImpacto = love.audio.newSource("assets/sonidos/sonidoImpacto.mp3", "static")
    SonidoMuerte = love.audio.newSource("assets/sonidos/sonidoMuerte.mp3", "static")
    SonidoDisparo:setVolume(0.5)
    SonidoImpacto:setVolume(0.5)
    musica:setLooping(true)
    love.audio.play(musica)
    musica:setVolume(0.2)
    SonidoGolpe:setVolume(0.3)

    Signal.register("jugador_danado", function()
        local golpe = SonidoGolpe:clone()
        love.audio.play(golpe)
    end)

    Signal.register("dash_usado", function()
        SonidoDash:stop()
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

    Signal.register("enemigo_muerto", function()
        SumarPuntaje(5)
    end)

    Signal.register("disparo", function()
        love.audio.play(SonidoDisparo:clone())
    end)

    Signal.register("enemigo_golpeado", function()
        love.audio.play(SonidoImpacto:clone())
    end)

    Signal.register("enemigo_muerto", function()
        love.audio.play(SonidoMuerte:clone())
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

function SumarPuntaje(cantidad)
    Puntaje = Puntaje + cantidad
    Signal.emit("puntaje_cambiado", Puntaje)
end

-- =================== ACTUALIZACION ===================
function love.update(dt)
    if not JuegoTerminado then
        Jugador:Actualizar(dt)
        -- La camara sigue al jugador pero sin salirse del mapa (evita los bordes negros)
        local anchoMapa = Mapa.width * Mapa.tilewidth
        local altoMapa = Mapa.height * Mapa.tileheight
        local mitadAncho = love.graphics.getWidth() / 2
        local mitadAlto = love.graphics.getHeight() / 2

        local camaraX = math.max(mitadAncho, math.min(Jugador.x + Jugador.ancho / 2, anchoMapa - mitadAncho))
        local camaraY = math.max(mitadAlto, math.min(Jugador.y + Jugador.alto / 2, altoMapa - mitadAlto))
        Camara:lookAt(camaraX, camaraY)
        local mouseX, mouseY = Camara:mousePosition() -- posicion del mouse en el mundo, no en la pantalla
        Escopeta:Actualizar(Jugador, mouseX, mouseY, dt)

        if love.mouse.isDown(1) then
            Escopeta:Disparar(Perdigones)
        end
        Perdigones:Actualizar(dt)
        Mapa:update(dt)
        Oleadas:Actualizar(dt)


        Hud:Actualizar(Oleadas.tiempoRestante, dt)

        if Jugador.vida <= 0 then
            JuegoTerminado = true
            Signal.emit("juego_perdido")
        elseif Oleadas.terminado then
            JuegoTerminado = true
            Gane = true
            Signal.emit("juego_ganado")
        end

        -- Recorremos todos los enemigos de la lista con un for, para actualizar a cada uno
        for i, enemigo in ipairs(Enemigos) do
            enemigo:Actualizar(Jugador.x, Jugador.y, Jugador.ancho, dt)

            -- Colision jugador-enemigo: se chequea para cada enemigo de la lista
            if ComprobarColision(Jugador, enemigo) and enemigo.golpeCooldown <= 0 then
                if Jugador:RecibirDano(5) then
                    enemigo.golpeCooldown = enemigo.golpeEspera
                end
            end
        end

        -- Separacion entre enemigos: si dos estan muy cerca, se empujan para no apilarse
        local distanciaMinima = 34
        for i = 1, #Enemigos - 1 do
            for j = i + 1, #Enemigos do
                local a = Enemigos[i]
                local b = Enemigos[j]
                local dx = b.x - a.x
                local dy = b.y - a.y
                local distancia = math.sqrt(dx * dx + dy * dy)

                if distancia == 0 then dx, dy, distancia = 1, 0, 1 end

                if distancia < distanciaMinima then
                    local empuje = (distanciaMinima - distancia) / 2
                    local nx = dx / distancia
                    local ny = dy / distancia
                    a.x = a.x - nx * empuje
                    a.y = a.y - ny * empuje
                    b.x = b.x + nx * empuje
                    b.y = b.y + ny * empuje
                end
            end
        end

        -- Perdigones contra enemigos: cada perdigon que toca a un enemigo le saca 1 de vida
        for _, enemigo in ipairs(Enemigos) do
            if enemigo.vivo then
                local impactos = Perdigones:Impacto(enemigo)
                if impactos > 0 then
                    enemigo:RecibirDano(impactos)
                end
            end
        end

        -- Se sacan los enemigos muertos (de atras para adelante para no saltear ninguno)
        for i = #Enemigos, 1, -1 do
            if not Enemigos[i].vivo then
                table.remove(Enemigos, i)
            end
        end

        -- Score: 1 punto por segundo
        PuntajeSegundos = PuntajeSegundos + dt
        if PuntajeSegundos >= 1 then
            PuntajeSegundos = PuntajeSegundos - 1
            SumarPuntaje(1)
        end

        for i, botiquin in ipairs(Botiquines) do
            if botiquin.activo and ComprobarColision(Jugador, botiquin) then
                Jugador:Curar(botiquin.curacion)
                botiquin.activo = false
            end
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
    -- musica y sonidos se frenan por separado porque love.audio.stop() falla en la version web
    musica:stop()
    SonidoVictoria:stop()
    SonidoDerrota:stop()

    -- Borra los listeners: love.load() y HUD:init los vuelven a registrar
    Signal.clear("jugador_danado", "jugador_curado", "dash_usado", "dash_listo", "juego_ganado", "juego_perdido",
        "enemigo_muerto", "puntaje_cambiado", "disparo", "fase_cambiada", "enemigo_golpeado")

    Puntaje = 0
    PuntajeSegundos = 0

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
    Escopeta:Dibujar()
    Perdigones:Dibujar()

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
        love.graphics.printf("Score: " .. Puntaje, 0, alto / 2 - 30, ancho, "center")
        love.graphics.printf("R - Reintentar", 0, alto / 2 + 10, ancho, "center")
        love.graphics.printf("Esc - Salir", 0, alto / 2 + 40, ancho, "center")

        -- Restaurar fuente y color para no afectar al HUD del frame siguiente
        love.graphics.setFont(fuenteAnterior)
        love.graphics.setColor(1, 1, 1)
    end
end

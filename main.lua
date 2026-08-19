-- =================== DECLARACION ===================
JuegoTerminado = false
Tiempo = 0
TiempoParaGanar = 11
Gane = false
SonidoGolpe = nil

Jugador = {}
Jugador.vida = 100
Jugador.x = 400
Jugador.y = 300
Jugador.velocidad = 200
Jugador.imagen = nil
Jugador.escala = 2
Jugador.ancho = 0 -- se calcula en load() segun el tamaño real de la imagen
Jugador.alto = 0
Jugador.flashTiempo = 0

Enemigo = {}
Enemigo.x = 100
Enemigo.y = 100
Enemigo.velocidad = 120
Enemigo.imagen = nil
Enemigo.escala = 2
Enemigo.ancho = 0
Enemigo.alto = 0

Botiquin = {}
Botiquin.imagen = nil
Botiquin.escala = 1
Botiquin.ancho = 0
Botiquin.alto = 0
Botiquin.activo = true

-- =================== INICIALIZACION ===================
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest") -- pixel art nitido, sin desenfoque al escalar

    Jugador.imagen = love.graphics.newImage("assets/personaje.png")
    Jugador.ancho = Jugador.imagen:getWidth() * Jugador.escala
    Jugador.alto = Jugador.imagen:getHeight() * Jugador.escala

    Enemigo.imagen = love.graphics.newImage("assets/enemigo.png")
    Enemigo.ancho = Enemigo.imagen:getWidth() * Enemigo.escala
    Enemigo.alto = Enemigo.imagen:getHeight() * Enemigo.escala

    Botiquin.imagen = love.graphics.newImage("assets/botiquin.png")
    Botiquin.ancho = Botiquin.imagen:getWidth() * Botiquin.escala
    Botiquin.alto = Botiquin.imagen:getHeight() * Botiquin.escala

    SonidoGolpe = love.audio.newSource("assets/efectoGolpe.mp3", "static")

    -- Posicion aleatoria del botiquin dentro de los limites de la pantalla
    Botiquin.x = love.math.random(0, love.graphics.getWidth() - Botiquin.ancho)
    Botiquin.y = love.math.random(0, love.graphics.getHeight() - Botiquin.alto)
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
        -- Movimiento del jugador segun teclas presionadas
        if love.keyboard.isDown("w") then
            Jugador.y = Jugador.y - Jugador.velocidad * dt
        end
        if love.keyboard.isDown("s") then
            Jugador.y = Jugador.y + Jugador.velocidad * dt
        end
        if love.keyboard.isDown("a") then
            Jugador.x = Jugador.x - Jugador.velocidad * dt
        end
        if love.keyboard.isDown("d") then
            Jugador.x = Jugador.x + Jugador.velocidad * dt
        end

        -- Limitar al jugador para que no se salga de la pantalla
        local anchoPantalla = love.graphics.getWidth()
        local altoPantalla = love.graphics.getHeight()

        if Jugador.x < 0 then Jugador.x = 0 end
        if Jugador.y < 0 then Jugador.y = 0 end
        if Jugador.x + Jugador.ancho > anchoPantalla then Jugador.x = anchoPantalla - Jugador.ancho end
        if Jugador.y + Jugador.alto > altoPantalla then Jugador.y = altoPantalla - Jugador.alto end

        -- IA del enemigo: se mueve en direccion al jugador (persecucion)
        local dx = Jugador.x - Enemigo.x
        local dy = Jugador.y - Enemigo.y
        local distancia = math.sqrt(dx * dx + dy * dy)

        local distanciaMinima = (Jugador.ancho + Enemigo.ancho) / 2

        if distancia > distanciaMinima then
            Enemigo.x = Enemigo.x + (dx / distancia) * Enemigo.velocidad * dt
            Enemigo.y = Enemigo.y + (dy / distancia) * Enemigo.velocidad * dt
        end

        -- Colision jugador-enemigo: resta vida, activa flash rojo y sonido de golpe
        if ComprobarColision(Jugador, Enemigo) then
            Jugador.vida = Jugador.vida - 50 * dt
            Jugador.flashTiempo = 0.1
            if not SonidoGolpe:isPlaying() then
                love.audio.play(SonidoGolpe)
            end
        end

        -- Apaga el flash rojo con el tiempo
        if Jugador.flashTiempo > 0 then
            Jugador.flashTiempo = Jugador.flashTiempo - dt
        end

        -- Contador de tiempo para la condicion de victoria
        Tiempo = Tiempo + dt
        if Tiempo >= TiempoParaGanar then
            JuegoTerminado = true
            Gane = true
        end

        -- Condicion de derrota
        if Jugador.vida <= 0 then
            Jugador.vida = 0
            JuegoTerminado = true
        end

        -- Colision jugador-botiquin: suma vida (sin pasarse de 100) y desactiva el item
        if Botiquin.activo and ComprobarColision(Jugador, Botiquin) then
            Jugador.vida = Jugador.vida + 30
            if Jugador.vida > 100 then Jugador.vida = 100 end
            Botiquin.activo = false
        end
    end
end

-- =================== RENDERIZADO ===================
function love.draw()
    -- Tinte rojo mientras dura el flash de daño, blanco (normal) el resto del tiempo
    if Jugador.flashTiempo > 0 then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.draw(Jugador.imagen, Jugador.x, Jugador.y, 0, Jugador.escala, Jugador.escala)
    love.graphics.setColor(1, 1, 1) -- resetear color para no afectar el resto de los dibujos

    love.graphics.draw(Enemigo.imagen, Enemigo.x, Enemigo.y, 0, Enemigo.escala, Enemigo.escala)

    -- HUD: vida y tiempo restante
    love.graphics.print("Vida: " .. (Jugador.vida), 10, 10)
    love.graphics.print("Resiste: " .. math.floor(math.max(TiempoParaGanar - Tiempo, 0)), 350, 10)

    -- Mensaje de fin de juego (victoria o derrota)
    if JuegoTerminado then
        if Gane then
            love.graphics.print("GANASTE!", 350, 280)
        else
            love.graphics.print("GAME OVER", 350, 280)
        end
    end

    -- Dibuja el botiquin solo si todavia no fue recolectado
    if Botiquin.activo then
        love.graphics.draw(Botiquin.imagen, Botiquin.x, Botiquin.y, 0, Botiquin.escala, Botiquin.escala)
    end
end

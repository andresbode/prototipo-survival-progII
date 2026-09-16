-- =================== MODULO MAPA ===================
local sti = require "librerias.sti"
local Bump = require "librerias.bump"

local Mapa = {}

-- =================== INICIALIZACION ===================
function Mapa.Cargar(rutaArchivo)
    local mapa = sti(rutaArchivo)
    local mundo = Bump.newWorld(16) 

    -- Registrar los objetos de la capa "Paredes" como solidos en el mundo de Bump
    if mapa.layers["Paredes"] then
        for _, obj in ipairs(mapa.layers["Paredes"].objects) do
            obj.esPared = true
            mundo:add(obj, obj.x, obj.y, obj.width, obj.height)
        end
    end

    return mapa, mundo
end

-- =================== RENDERIZADO ===================
function Mapa.DibujarSuelo(mapa)
    if mapa.layers["suelo"] then
        mapa:drawLayer(mapa.layers["suelo"])
    end
end

function Mapa.DibujarArboles(mapa)
    if mapa.layers["arboles"] then
        mapa:drawLayer(mapa.layers["arboles"])
    end
end

-- =================== EXPORTAR ===================
return Mapa
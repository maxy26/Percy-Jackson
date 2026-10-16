-- Héroe del tridente (pixel art, 45x70): separa el tridente del personaje y
-- genera las animaciones para la página de revisión.
--
--  * heroe_base_con_tridente.png  sprite original reconstruido (no se modifica)
--  * heroe_base.png               personaje sin tridente: la pierna y la bota
--                                 izquierdas, que el tridente tapaba, se
--                                 reconstruyen reflejando las derechas
--  * tridente/tridente_en_mano.png  tridente en su posición (45x70): encima del
--                                 personaje se ve igual que el original
--  * tridente/tridente.png        tridente completo (con el tramo de mango
--                                 oculto por la mano), recortado
--  * revision/sprites + manifest  reposo del personaje y brillo del tridente
--
-- Uso: aseprite -b --script-param dir=<carpeta Heroe> --script heroe_sprites.lua

local dir = app.params.dir
local pc = app.pixelColor
local function hex(h)
  return pc.rgba(tonumber(h:sub(2,3), 16), tonumber(h:sub(4,5), 16), tonumber(h:sub(6,7), 16), 255)
end
local VACIO = pc.rgba(0, 0, 0, 0)
local NEGRO, CASI_NEGRO = hex("#000000"), hex("#161616")
local AZUL_OSCURO = hex("#181b3e")
local MADERA, MADERA_OSC = hex("#704620"), hex("#381a1c")
local BLANCO, AMARILLO, BRILLO = hex("#ffffff"), hex("#e4dd23"), hex("#fff696")
local DESTELLOS = { [hex("#e6f2db")] = true }          -- puntitos de brillo sueltos
local ORO = { [hex("#956918")] = true, [hex("#e8af20")] = true, [hex("#ac6d00")] = true,
              [hex("#fff696")] = true, [hex("#b27d32")] = true }
local LENA = { [hex("#704620")] = true, [hex("#522404")] = true, [hex("#6a3901")] = true }

local rutaOrig = app.fs.joinPath(dir, "heroe_base_con_tridente.png")
if not app.fs.isFile(rutaOrig) then
  -- primera ejecución: heroe_base.png todavía es el sprite con tridente
  Image{ fromFile = app.fs.joinPath(dir, "heroe_base.png") }:saveAs(rutaOrig)
end
local orig = Image{ fromFile = rutaOrig }
local W, H = orig.width, orig.height
local function px(img, x, y)
  if x < 0 or y < 0 or x >= W or y >= H then return VACIO end
  return img:getPixel(x, y)
end

-- Destello en "+" de los ojos, como en la referencia
local OJOS = { { x = 21, y = 29 }, { x = 32, y = 29 } }
for _, o in ipairs(OJOS) do
  orig:drawPixel(o.x, o.y, BLANCO)
  for _, d in ipairs({ {0,-1}, {-1,0}, {1,0}, {0,1} }) do orig:drawPixel(o.x + d[1], o.y + d[2], AMARILLO) end
end

------------------------------------------------------------------ tridente
-- Mango superior (fuera del cuerpo) y cabeza (sobre la pierna izquierda)
local esTridente = {}
local function marca(x, y) esTridente[y * W + x] = true end
for y = 41, 48 do for x = 0, 7 do if px(orig, x, y) ~= VACIO then marca(x, y) end end end
for y = 46, 48 do marca(8, y) end                       -- contorno derecho del mango junto al brazo
for y = 54, 66 do for x = 9, 26 do
  local p = px(orig, x, y)
  -- en la fila 54 solo está el mango; más a la derecha empieza la hebilla del cinturón
  if (ORO[p] or LENA[p]) and (y > 54 or x <= 16) then marca(x, y) end
end end
-- contorno de la cabeza: negros pegados a sus piezas doradas o de madera
local contorno = {}
for y = 54, 67 do for x = 9, 27 do
  local p = px(orig, x, y)
  if (p == NEGRO or p == CASI_NEGRO) and not esTridente[y * W + x] then
    for _, d in ipairs({ {1,0}, {-1,0}, {0,1}, {0,-1} }) do
      local k = (y + d[2]) * W + x + d[1]
      if esTridente[k] and (y + d[2]) >= 54 then contorno[#contorno+1] = y * W + x; break end
    end
  end
end end
for _, k in ipairs(contorno) do esTridente[k] = true end

local enMano = Image(W, H, ColorMode.RGB)
for y = 0, H-1 do for x = 0, W-1 do
  if esTridente[y * W + x] then enMano:drawPixel(x, y, orig:getPixel(x, y)) end
end end

-- Tridente completo: añade el tramo de mango que la mano tapaba (diagonal a 45°)
local completo = enMano:clone()
for y = 47, 54 do
  local x0 = y - 42
  for i, c in ipairs({ NEGRO, MADERA_OSC, MADERA, MADERA, NEGRO }) do
    if completo:getPixel(x0 + i - 1, y) == VACIO then completo:drawPixel(x0 + i - 1, y, c) end
  end
end

------------------------------------------------------------------ personaje
local sin = orig:clone()
for y = 41, 48 do for x = 0, 7 do sin:drawPixel(x, y, VACIO) end end
sin:drawPixel(13, 54, VACIO); sin:drawPixel(14, 54, VACIO)     -- mango bajo la mano
-- Pierna y bota izquierdas: espejo de las derechas (eje x = 24)
for y = 55, 69 do for x = 9, 23 do sin:drawPixel(x, y, px(orig, 48 - x, y)) end end
-- Costura entre las piernas
sin:drawPixel(24, 56, AZUL_OSCURO)
for y = 57, 61 do sin:drawPixel(24, y, VACIO) end
for y = 56, 61 do sin:drawPixel(23, y, NEGRO); sin:drawPixel(25, y, NEGRO) end
for y = 62, 69 do for _, x in ipairs({ 22, 23, 24, 25, 26 }) do sin:drawPixel(x, y, VACIO) end end
-- Restos de destellos sueltos
for y = 0, H-1 do for x = 0, W-1 do
  if DESTELLOS[sin:getPixel(x, y)] then sin:drawPixel(x, y, VACIO) end
end end
sin:drawPixel(15, 49, NEGRO)                                    -- destello blanco junto a la mano

sin:saveAs(app.fs.joinPath(dir, "heroe_base.png"))
local carpetaTri = app.fs.joinPath(dir, "tridente")
app.fs.makeAllDirectories(carpetaTri)
enMano:saveAs(app.fs.joinPath(carpetaTri, "tridente_en_mano.png"))
local caja = completo:shrinkBounds()
Image(completo, caja):saveAs(app.fs.joinPath(carpetaTri, "tridente.png"))

------------------------------------------------------------------ animaciones
-- Mueve 1 px hacia abajo los píxeles de la región (x, y) -> bool.
local function bajar(img, region)
  local out = img:clone()
  for y = 0, H-1 do for x = 0, W-1 do
    if region(x, y) and not region(x, y - 1) then out:drawPixel(x, y, VACIO) end
  end end
  for y = H-1, 0, -1 do for x = 0, W-1 do
    if region(x, y) and y + 1 < H then out:drawPixel(x, y + 1, img:getPixel(x, y)) end
  end end
  return out
end
-- Cabeza + torso (sin el brazo de la izquierda)
local function cabezaTorso(x, y) return y <= 36 or (y <= 48 and x >= 15) end

-- Brillo que recorre las puntas del tridente en diagonal
local function brilloTridente(img, banda)
  local out = img:clone()
  for y = 54, 66 do for x = 10, 26 do
    if ORO[img:getPixel(x, y)] then
      local d = (x - 10) + (66 - y)
      if math.abs(d - banda) <= 1 then out:drawPixel(x, y, d == banda and BLANCO or BRILLO) end
    end
  end end
  return out
end

local abajo = bajar(sin, cabezaTorso)
local propuestas = {
  { animacion = "Personaje sin tridente", descripcion =
      "Reposo: cabeza y torso bajan juntos al respirar. La pierna y la bota izquierdas se reconstruyeron.",
    variantes = {
      { id = "reposo", nombre = "Reposo",
        nota = "Mismo reposo que aprobaste (B), ahora sin el tridente.",
        fotogramas = { { sin, 360 }, { abajo, 280 }, { abajo, 360 }, { sin, 280 } } },
    } },
  { animacion = "Tridente", descripcion =
      "Sprite aparte, en la misma posición que en la mano (45x70): ponlo encima del personaje.",
    variantes = {
      { id = "tridente_brillo", nombre = "Tridente · brillo",
        nota = "Quieto y, cada 2 s, un brillo recorre las puntas (el mismo destello del reposo aprobado).",
        fotogramas = { { enMano, 1000 }, { brilloTridente(enMano, 4), 110 }, { brilloTridente(enMano, 9), 110 },
                       { brilloTridente(enMano, 14), 110 }, { brilloTridente(enMano, 19), 140 },
                       { enMano, 560 } } },
      { id = "combinado", nombre = "Vista previa: personaje + tridente",
        nota = "Las dos capas juntas, para comprobar que encajan como el original.",
        fotogramas = {} },
    } },
}
-- Vista previa combinada (no es un sprite final)
local function encima(a, b)
  local out = a:clone(); out:drawImage(b, Point(0, 0), 255, BlendMode.NORMAL); return out
end
local comb = propuestas[2].variantes[2].fotogramas
for _, f in ipairs({ { sin, enMano, 360 }, { abajo, enMano, 280 }, { abajo, enMano, 360 }, { sin, enMano, 280 },
                     { sin, brilloTridente(enMano, 4), 110 }, { abajo, brilloTridente(enMano, 9), 110 },
                     { abajo, brilloTridente(enMano, 14), 110 }, { abajo, brilloTridente(enMano, 19), 140 },
                     { sin, enMano, 280 } }) do
  comb[#comb+1] = { encima(f[1], f[2]), f[3] }
end

------------------------------------------------------------------ revisión
local salida = app.fs.joinPath(dir, "revision")
local function jsonStr(s) return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"' end
local json = { '{ "tam": ' .. math.max(W, H) .. ', "ancho": ' .. W .. ', "alto": ' .. H .. ', "animaciones": [' }
for ai, anim in ipairs(propuestas) do
  json[#json+1] = (ai > 1 and "," or "") .. '{ "nombre": ' .. jsonStr(anim.animacion)
    .. ', "descripcion": ' .. jsonStr(anim.descripcion) .. ', "variantes": ['
  for vi, v in ipairs(anim.variantes) do
    local carpeta = app.fs.joinPath(salida, "sprites", v.id)
    app.fs.makeAllDirectories(carpeta)
    local fr, dur = {}, {}
    for i, f in ipairs(v.fotogramas) do
      local nombre = string.format("%02d.png", i)
      f[1]:saveAs(app.fs.joinPath(carpeta, nombre))
      fr[#fr+1] = jsonStr("sprites/" .. v.id .. "/" .. nombre)
      dur[#dur+1] = tostring(f[2])
    end
    json[#json+1] = (vi > 1 and "," or "") .. '{ "id": ' .. jsonStr(v.id)
      .. ', "nombre": ' .. jsonStr(v.nombre) .. ', "nota": ' .. jsonStr(v.nota)
      .. ', "fotogramas": [' .. table.concat(fr, ",") .. ']'
      .. ', "duraciones": [' .. table.concat(dur, ",") .. '] }'
  end
  json[#json+1] = "] }"
end
json[#json+1] = "] }"
local fh = assert(io.open(app.fs.joinPath(salida, "manifest.json"), "w"))
fh:write(table.concat(json, "\n"))
fh:close()
print("ok", "tridente recortado", caja.width .. "x" .. caja.height)

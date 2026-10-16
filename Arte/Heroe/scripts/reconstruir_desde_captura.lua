local img = Image{ fromFile = app.params.f }
local pc = app.pixelColor
local P, FX, FY = 5.78, 3.75, 3.36
local cols = math.floor((img.width - FX) / P)
local rows = math.floor((img.height - FY) / P)
local function rgb(p) return { pc.rgbaR(p), pc.rgbaG(p), pc.rgbaB(p) } end
local function dist(a, b) return math.abs(a[1]-b[1]) + math.abs(a[2]-b[2]) + math.abs(a[3]-b[3]) end

-- 1) color representativo de cada celda: el más votado en su zona central
local celdas = {}
for r = 0, rows-1 do
  celdas[r] = {}
  for c = 0, cols-1 do
    local cx, cy = FX + (c + 0.5) * P, FY + (r + 0.5) * P
    local muestras = {}
    for dy = -1, 1 do for dx = -1, 1 do
      local x, y = math.floor(cx + dx * P * 0.22), math.floor(cy + dy * P * 0.22)
      if x >= 0 and y >= 0 and x < img.width and y < img.height then muestras[#muestras+1] = rgb(img:getPixel(x, y)) end
    end end
    local mejor, mv = muestras[1], -1
    for _, a in ipairs(muestras) do
      local v = 0
      for _, b in ipairs(muestras) do if dist(a, b) < 40 then v = v + 1 end end
      if v > mv then mv, mejor = v, a end
    end
    celdas[r][c] = mejor
  end
end

-- 2) paleta: agrupa colores parecidos (orden por frecuencia)
local freq, lista = {}, {}
for r = 0, rows-1 do for c = 0, cols-1 do
  local a = celdas[r][c]; local k = a[1]..","..a[2]..","..a[3]
  if not freq[k] then freq[k] = { a, 0 }; lista[#lista+1] = k end
  freq[k][2] = freq[k][2] + 1
end end
table.sort(lista, function(x, y) return freq[x][2] > freq[y][2] end)
local paleta = {}
local UMBRAL = tonumber(app.params.umbral or "42")
for _, k in ipairs(lista) do
  local a = freq[k][1]
  local ok = false
  for _, p in ipairs(paleta) do if dist(a, p.c) < UMBRAL then ok = true; break end end
  if not ok then paleta[#paleta+1] = { c = a } end
end
local function cercano(a)
  local bp, bd = nil, 1e9
  for _, p in ipairs(paleta) do local dd = dist(a, p.c); if dd < bd then bd, bp = dd, p end end
  return bp.c
end

-- 3) imagen nativa; solo el blanco conectado con el borde (el fondo) es transparente
local fondo = {}
local function blanco(c, r) local a = cercano(celdas[r][c]); return a[1] + a[2] + a[3] >= 720 end
local pila = {}
for c = 0, cols-1 do pila[#pila+1] = {c, 0}; pila[#pila+1] = {c, rows-1} end
for r = 0, rows-1 do pila[#pila+1] = {0, r}; pila[#pila+1] = {cols-1, r} end
while #pila > 0 do
  local q = table.remove(pila); local c, r = q[1], q[2]
  local k = r * cols + c
  if c >= 0 and r >= 0 and c < cols and r < rows and not fondo[k] and blanco(c, r) then
    fondo[k] = true
    pila[#pila+1] = {c+1, r}; pila[#pila+1] = {c-1, r}; pila[#pila+1] = {c, r+1}; pila[#pila+1] = {c, r-1}
  end
end
local out = Image(cols, rows, ColorMode.RGB)
local x0, y0, x1, y1 = 1e9, 1e9, -1, -1
for r = 0, rows-1 do for c = 0, cols-1 do
  if not fondo[r * cols + c] then
    local a = cercano(celdas[r][c])
    out:drawPixel(c, r, pc.rgba(a[1], a[2], a[3], 255))
    if c < x0 then x0 = c end if r < y0 then y0 = r end if c > x1 then x1 = c end if r > y1 then y1 = r end
  end
end end
print("rejilla", cols, rows, "contenido", x0, y0, x1-x0+1, y1-y0+1, "colores", #paleta)
for _, p in ipairs(paleta) do io.write(string.format("#%02x%02x%02x ", p.c[1], p.c[2], p.c[3])) end
print()
local rec = Image(out, Rectangle(x0, y0, x1-x0+1, y1-y0+1))
rec:saveAs(app.params.out)
local big = rec:clone(); big:resize(rec.width * 8, rec.height * 8)
local prev = Image(big.width, big.height, ColorMode.RGB)
for y = 0, prev.height-1 do for x = 0, prev.width-1 do prev:drawPixel(x, y, pc.rgba(60, 66, 80, 255)) end end
prev:drawImage(big, Point(0, 0), 255, BlendMode.NORMAL)
prev:saveAs(app.params.prev)

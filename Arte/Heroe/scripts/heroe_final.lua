-- Monta los .aseprite finales (pixel art 45x70) con las animaciones aprobadas.
-- Lee los fotogramas y duraciones de revision/manifest.json.
--
-- Uso: aseprite -b --script-param dir=<carpeta Heroe> --script heroe_final.lua

local dir = app.params.dir
-- archivo -> { id de variante = nombre de etiqueta }
local SALIDAS = {
  { archivo = "heroe.aseprite", capa = "Héroe", etiquetas = { reposo = "reposo" } },
  { archivo = "tridente/tridente.aseprite", capa = "Tridente", etiquetas = { tridente_brillo = "brillo" } },
}

local fh = assert(io.open(app.fs.joinPath(dir, "revision", "manifest.json")))
local manifiesto = json.decode(fh:read("a"))
fh:close()

for _, s in ipairs(SALIDAS) do
  local spr = Sprite(manifiesto.ancho, manifiesto.alto, ColorMode.RGB)
  spr.layers[1].name = s.capa
  local f, rangos = 0, {}
  for _, anim in ipairs(manifiesto.animaciones) do
    for _, v in ipairs(anim.variantes) do
      local etiqueta = s.etiquetas[v.id]
      if etiqueta then
        local desde = f + 1
        for i, ruta in ipairs(v.fotogramas) do
          f = f + 1
          if f > 1 then spr:newEmptyFrame() end
          spr:newCel(spr.layers[1], f, Image{ fromFile = app.fs.joinPath(dir, "revision", ruta) }, Point(0, 0))
          spr.frames[f].duration = v.duraciones[i] / 1000
        end
        rangos[#rangos+1] = { etiqueta, desde, f }
      end
    end
  end
  -- Las etiquetas se crean al final: si no, crecen al añadir fotogramas detrás
  for _, r in ipairs(rangos) do spr:newTag(r[2], r[3]).name = r[1] end
  spr:saveAs(app.fs.joinPath(dir, s.archivo))
  spr:close()
  print(s.archivo, "fotogramas", f)
end

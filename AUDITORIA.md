# AUDITORÍA

> Registro de revisiones, pruebas y decisiones. Entrada nueva arriba.

## Plantilla

```
## AUD-XXX — AAAA-MM-DD — Título
**Alcance:** · **Hallazgos:** · **Riesgos:** · **Acciones:** · **Estado:**
```

---

## AUD-001 — 2026-10-15 — Creación del proyecto con el héroe del tridente

**Alcance:** creación del proyecto de Unity, traslado del arte del héroe y primeras animaciones en el juego.

**Decisiones:**
- Sprite reconstruido desde la captura de referencia: cuadrícula detectada con escala ×5,78, color de cada celda por votación de su zona central y paleta agrupada. Resultado: 45×70 px. Se redibujó el destello en "+" de los ojos, que se perdía al reducir.
- Reposo aprobado: cabeza y torso bajan 1 px (variante "B").
- Tridente separado en su propio sprite. La pierna y la bota izquierdas, que tapaba, se reconstruyeron reflejando las derechas. Se quitaron los destellos blancos sueltos de la referencia.
- Versión dibujada a mano estilo *Hollow Knight* descartada por el usuario.
- Configuración base de Unity copiada del proyecto CazadorMonedas (URP 2D, paquetes y ajustes), con nombre y `productGUID` propios.
- Escena, prefab, clips y controladores generados por `ConstruirPercyJackson.cs`. Clips a 100 fps internos para respetar las duraciones de Aseprite (múltiplos de 10 ms).

**Pruebas:**
- Unity 6000.4.8f1 en modo consola: el proyecto importa y compila sin errores.
- Comprobaciones del constructor: `heroe_reposo` 4 sprites, `tridente_brillo` 6 sprites, ambos clips en bucle (1,29 s y 2,04 s; 10 ms de redondeo de Unity), prefab con el tridente como hijo y escena guardada.
- La combinación personaje + tridente se comprobó visualmente en la página de revisión: se ve igual que el sprite original.

**Riesgos y límites:**
- La escena no se ha abierto en el editor con ventana: falta comprobar a simple vista el encaje del tridente y la escala en la vista de juego.
- La pierna y la bota izquierdas reconstruidas son una suposición (no se veían en la referencia).

**Estado:** abierta hasta la prueba del usuario en el editor.

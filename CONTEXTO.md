# CONTEXTO

> Última actualización: 2026-10-15

## Objetivo

Videojuego 2D en **Unity 6** (nombre provisional: **Percy Jackson**). El protagonista es el **héroe del tridente**, un chico chibi de temática marina en pixel art.

El diseño del personaje está en [Docs/CONTEXTO_PERSONAJE.md](Docs/CONTEXTO_PERSONAJE.md), que es la **fuente de verdad** del personaje.

## Historia del proyecto

1. El usuario aportó una captura de su personaje en pixel art. Se reconstruyó el sprite original (45×70) a partir de la captura.
2. Se aprobó la animación de reposo y se separó el tridente en un sprite propio, con su animación de brillo.
3. Se probó una versión dibujada a mano estilo *Hollow Knight*, que se descartó: el personaje se queda en pixel art.
4. El 2026-10-15 se creó este proyecto de Unity y se trasladaron aquí todos los archivos del personaje.

Es un juego **distinto** del de Gota (proyecto de Godot "Juego Gota").

## Decisiones

- **Motor:** Unity 6000.4.8f1 con URP 2D, misma configuración base que el proyecto CazadorMonedas del usuario.
- **Pixel art nítido:** filtro *Point*, sin compresión ni mipmaps, 32 píxeles por unidad.
- **Pivote en los pies** (abajo en el centro) en todos los sprites del personaje y del tridente, para que encajen.
- **El tridente es un objeto hijo** del héroe con su propio `SpriteRenderer` (orden 1, encima) y `Animator`. El componente `Heroe` permite mostrarlo u ocultarlo.
- **Construcción por código:** `Assets/Editor/ConstruirPercyJackson.cs` crea los sprites, clips, controladores, el prefab y la escena a partir de las hojas exportadas. No se editan a mano.
- **Arte fuera de `Assets/`:** las fuentes (`.aseprite`, scripts y página de revisión) están en `Arte/`, que Unity no importa.
- **Revisión en el navegador:** cada animación nueva se enseña en una página local con varias propuestas antes de darla por buena.

## Arquitectura

```
Percy Jackson/
├── Assets/
│   ├── Sprites/Heroe/        Hojas exportadas (PNG + JSON) y tridente suelto
│   ├── Animaciones/          Clips y controladores (generados)
│   ├── Prefabs/Heroe.prefab  Héroe + Tridente (generado)
│   ├── Escenas/Principal.unity   Escena de prueba (generada)
│   ├── Scripts/Heroe.cs      Mostrar u ocultar el tridente
│   ├── Editor/ConstruirPercyJackson.cs   Construye todo lo anterior
│   └── Settings/ …           Configuración de URP 2D
├── Docs/CONTEXTO_PERSONAJE.md
└── Arte/Heroe/               Fuentes del arte (Unity no lo importa)
    ├── heroe.aseprite        Personaje sin tridente (etiqueta reposo)
    ├── tridente/             tridente.aseprite (brillo), tridente_en_mano.png, tridente.png
    ├── heroe_base*.png       Pose base con y sin tridente
    ├── scripts/              heroe_sprites.lua · heroe_final.lua · exportar_unity.py · reconstruir_desde_captura.lua
    ├── revision/             Página de revisión (index.html + servidor.py)
    └── referencia/           Captura original del personaje
```

## Entorno

Windows 11, Unity 6000.4.8f1, Aseprite compilado desde el código fuente e instalado en `C:\Herramientas\Aseprite\aseprite.exe` y Python 3.14. Equipo con 8 GB de RAM y gráfica integrada.

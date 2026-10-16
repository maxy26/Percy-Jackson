"""Exporta las animaciones del héroe y del tridente al proyecto de Unity.

Crea en Assets/Sprites/Heroe/ una hoja por animación (PNG + JSON de Aseprite)
y copia el tridente suelto. Después, en Unity: Herramientas > Construir Percy Jackson.

Uso: python -I Arte/Heroe/scripts/exportar_unity.py
     (variable ASEPRITE para indicar otro ejecutable de Aseprite)
"""
import os
import shutil
import subprocess

ARTE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROYECTO = os.path.dirname(os.path.dirname(ARTE))
ASEPRITE = os.environ.get("ASEPRITE", r"C:\Users\Usuario\Documents\aseprite\build\bin\aseprite.exe")
SPRITES = os.path.join(PROYECTO, "Assets", "Sprites", "Heroe")

# (archivo .aseprite, etiqueta, nombre de la hoja)
ANIMACIONES = [
    ("heroe.aseprite", "reposo", "heroe_reposo"),
    (os.path.join("tridente", "tridente.aseprite"), "brillo", "tridente_brillo"),
]


def main():
    os.makedirs(SPRITES, exist_ok=True)
    for archivo, etiqueta, nombre in ANIMACIONES:
        subprocess.run([ASEPRITE, "-b", "--tag", etiqueta, os.path.join(ARTE, archivo),
                        "--sheet", os.path.join(SPRITES, nombre + ".png"),
                        "--data", os.path.join(SPRITES, nombre + ".json"),
                        "--format", "json-array", "--sheet-type", "horizontal", "--list-tags"],
                       check=True, capture_output=True)
        print("ok", nombre)
    shutil.copyfile(os.path.join(ARTE, "tridente", "tridente.png"), os.path.join(SPRITES, "tridente.png"))
    print("ok tridente")


if __name__ == "__main__":
    main()

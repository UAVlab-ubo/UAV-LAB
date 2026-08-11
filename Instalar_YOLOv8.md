> 11-08-2026
---

# Instalación de YOLOv8 en WSL2 (Ubuntu)  
Guía paso a paso con comandos listos para copiar y pegar

Esta guía describe el procedimiento completo para instalar Python, configurar un entorno virtual, instalar PyTorch y Ultralytics YOLOv8, y ejecutar pruebas de inferencia en imágenes dentro de WSL2.

---

## Paso 1: Actualización del sistema e instalación de Python

Abra la terminal de Ubuntu en WSL2 y ejecute:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install python3-pip python3-venv -y
```

Esto actualiza los paquetes del sistema e instala las herramientas necesarias para crear entornos virtuales y gestionar dependencias.

---

## Paso 2: Creación y activación del entorno virtual

Cree un entorno virtual aislado para evitar conflictos entre librerías:

```bash
python3 -m venv yolo_env
source yolo_env/bin/activate
```

Al activarse, la terminal mostrará el prefijo `(yolo_env)` indicando que está dentro del entorno virtual.

---

## Paso 3: Instalación de PyTorch y Ultralytics YOLOv8

Instale PyTorch compatible con CUDA (WSL2 + GPU NVIDIA) y luego YOLOv8:

```bash
pip install torch torchvision --index-url https://pytorch.org
pip install ultralytics
```

### Validación de la instalación y detección de GPU

Ejecute:

```bash
python3 -c "import torch; import ultralytics; ultralytics.checks()"
```

Este comando verifica versiones y confirma si CUDA y la GPU están disponibles.

---

## Paso 4: Prueba de inferencia con imagen de ejemplo

YOLOv8 permite realizar inferencias desde la línea de comandos o mediante scripts en Python.

### Opción A: Inferencia desde la terminal (CLI)

```bash
yolo predict model=yolov8n.pt source=https://ultralytics.com save=True
```

El modelo `yolov8n.pt` se descargará automáticamente si no está presente.

### Opción B: Inferencia mediante script en Python

1. Crear archivo:

```bash
nano prueba_imagen.py
```

2. Insertar el siguiente contenido:

```python
from ultralytics import YOLO

model = YOLO("yolov8n.pt")

url_imagen = "https://ultralytics.com"
results = model.predict(source=url_imagen, save=True)

print("Inferencia completada con éxito.")
```

3. Guardar con `Ctrl + O`, confirmar con `Enter`, salir con `Ctrl + X`.

4. Ejecutar el script:

```bash
python3 prueba_imagen.py
```

---

## Paso 5: Visualización de resultados

YOLOv8 guarda las imágenes procesadas en:

```
runs/detect/predict/
```

Para abrir esa carpeta directamente en el explorador de Windows:

```bash
explorer.exe runs/detect/predict/
```

Esto permite visualizar las imágenes con las detecciones dibujadas.

---

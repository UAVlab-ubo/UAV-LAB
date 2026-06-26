> 26-06-2026
**Instalación recomendada y reproducible de YOLOv8 en WSL2 Ubuntu 22.04 usando conda/mamba y PyTorch con CUDA 11.8.** Sigue los pasos en orden, acepta los Terms of Service de conda cuando se solicite, y usa siempre `conda activate yolov8` y `python -m pip` dentro del entorno para evitar conflictos.

# Requisitos previos
- **Windows 11 con WSL2** y **Ubuntu 22.04** instalado.  
- **GPU NVIDIA** con drivers WSL compatibles (ver `nvidia-smi`).  
- **Conexión a Internet** para descargar paquetes y pesos.

---

# Preparación del sistema y drivers
1. En Windows instala/actualiza el driver NVIDIA para WSL (p. ej. 537+).  
2. En WSL verifica:
```bash
nvidia-smi
```
Si `nvidia-smi` funciona y muestra tu GPU, continúa. Para guía de instalación CUDA 11.8 en WSL2 sigue las instrucciones de referencia.   [Github](https://github.com/cherifsid/Setting-Up-CUDA-11.8-and-PyTorch-with-NVIDIA-537-Driver-on-WSL2/blob/main/README.md)

---

# Instalar Miniconda y crear entorno
```bash
# Descargar e instalar Miniconda (si no lo tienes)
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/miniconda3
export PATH="$HOME/miniconda3/bin:$PATH"
conda init bash
exec $SHELL

# Crear entorno limpio
conda create -n yolov8 python=3.10 -y
conda activate yolov8
```

---

# Aceptar Terms of Service de conda (si se solicita)
Si `conda` falla en modo no interactivo por TOS, acepta los canales oficiales:
```bash
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
```
Esto es necesario para instalaciones no interactivas en sistemas recientes.

---

# Instalar mamba y PyTorch binarios coherentes (recomendado)
Usar `mamba` evita conflictos binarios y resuelve dependencias CUDA correctamente.
```bash
# Instalar mamba en base (una sola vez)
conda activate base
conda install -n base -c conda-forge mamba -y

# Volver al entorno y usar mamba para PyTorch
conda activate yolov8
mamba install -y -c pytorch -c conda-forge pytorch torchvision torchaudio pytz lxml
```
Instalar `torch`, `torchvision` y `torchaudio` juntos evita incompatibilidades entre versiones.   [docs.pytorch.org](https://docs.pytorch.org/get-started/previous-versions/)  [leapcell.io](https://leapcell.io/blog/how-to-install-pytorch-using-pip)

---

# Alternativa pip para PyTorch (si no usas conda)
Si prefieres `pip`, instala las tres ruedas juntas desde el índice oficial PyTorch (ej. CUDA 11.8):
```bash
python -m pip install --upgrade pip setuptools wheel
python -m pip install --index-url https://download.pytorch.org/whl/cu118 \
  torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu118
```
Verifica la versión y CUDA con `python -c "import torch; print(torch.__version__, torch.cuda.is_available())"`.   [leapcell.io](https://leapcell.io/blog/how-to-install-pytorch-using-pip)

---

# Instalar Ultralytics YOLOv8 dentro del entorno
```bash
# dentro de conda activate yolov8
python -m pip install --upgrade pip setuptools wheel
python -m pip install ultralytics matplotlib psutil pyyaml requests
```

---

# Evitar scripts fuera del entorno y verificación final
```bash
# eliminar scripts de usuario que interfieran
rm -f ~/.local/bin/yolo 2>/dev/null || true
hash -r

# comprobar rutas y versiones
which python
which yolo
python -c "import torch, ultralytics; print('torch', torch.__version__, 'CUDA', torch.cuda.is_available()); print('ultralytics', ultralytics.__version__)"
```
La salida debe mostrar `yolo` en `.../miniconda3/envs/yolov8/bin/yolo` y `torch` con `CUDA True`.

---

# Prueba rápida de inferencia
```bash
wget -q https://ultralytics.com/images/bus.jpg -O bus.jpg
yolo detect predict model=yolov8n.pt source=bus.jpg
ls -l runs/detect/predict
```

---

# Resolución de problemas comunes
- **ModuleNotFoundError: No module named 'torch'** → asegúrate `conda activate yolov8` y reinstala con `python -m pip install --force-reinstall torch torchvision torchaudio` o usa `mamba` en el entorno.  
- **Conflictos de versiones** → desinstala `torch/torchvision/torchaudio` y reinstala las tres juntas.   [docs.pytorch.org](https://docs.pytorch.org/get-started/previous-versions/)  [leapcell.io](https://leapcell.io/blog/how-to-install-pytorch-using-pip)  
- **Scripts en `~/.local/bin`** → elimínalos para evitar que se ejecuten fuera del entorno.

---


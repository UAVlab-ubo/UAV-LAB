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



---

# 📄 **Instalación Correcta de ROS 2 Humble en WSL2 + Validación con `ros2 topic list`**

Este documento describe el proceso completo para:

- Instalar ROS 2 Humble correctamente en WSL2 (Ubuntu 22.04)  
- Reparar problemas comunes del daemon de ROS 2  
- Validar la instalación con `ros2 topic list`  
- Continuar con la configuración posterior a ROS 2  

---

# 1. Requisitos previos

Antes de instalar ROS 2 Humble, asegúrate de:

- Usar **WSL2** (no WSL1)
- Tener **Ubuntu 22.04**
- No ejecutar ROS2 desde rutas de Windows (`/mnt/c/...`)
- No tener **Conda** activado (rompe ROS2)

Verificar ubicación:

```bash
pwd
```

Debe mostrar:

```
/home/tu_usuario
```

---

# 2. Desactivar Conda (si está activo)

```bash
conda deactivate 2>/dev/null || true
conda config --set auto_activate_base false
```

Cerrar y abrir la terminal.

---

# 3. Eliminar instalaciones previas de ROS 2 (si existían)

```bash
sudo apt purge -y ros-humble-*
sudo apt autoremove -y
sudo rm -rf /opt/ros/humble
sudo rm -rf ~/.ros
sudo rm -rf ~/.colcon
```

---

# 4. Agregar el repositorio oficial de ROS 2 Humble

```bash
sudo apt update
sudo apt install -y curl gnupg2 lsb-release software-properties-common

sudo mkdir -p /etc/apt/keyrings

curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] \
  http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
```

Actualizar:

```bash
sudo apt update
```

Si aparece:

```
Get:6 http://packages.ros.org/ros2/ubuntu jammy InRelease
```

→ El repositorio está bien agregado.

---

# 5. Instalar ROS 2 Humble Desktop

```bash
sudo apt install -y ros-humble-desktop python3-rosdep
```

Inicializar rosdep:

```bash
sudo rosdep init || true
rosdep update
```

---

# 6. Activar ROS 2 automáticamente

```bash
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

---

# 7. Reparar el daemon de ROS 2 (si fallaba)

Si `ros2 topic list` daba timeout, borrar el daemon:

```bash
rm -rf ~/.ros/daemon
```

---

# 8. Reparar DNS en WSL2 (si pip o rosdep fallaban)

Crear resolv.conf:

```bash
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "nameserver 1.1.1.1" >> /etc/resolv.conf'
```

Evitar que WSL lo reemplace:

```bash
sudo bash -c 'echo "[network]" > /etc/wsl.conf'
sudo bash -c 'echo "generateResolvConf = false" >> /etc/wsl.conf'
```

Reiniciar WSL2 desde Windows PowerShell:

```powershell
wsl --shutdown
```

---

# 9. Validar la instalación de ROS 2

Asegúrate de estar en tu HOME:

```bash
cd ~
```

Ejecuta:

```bash
ros2 topic list
```

La salida correcta debe ser:

```
/parameter_events
/rosout
```

Esto confirma que:

- ROS2 está instalado correctamente  
- El daemon funciona  
- Python no está interferido  
- No hay conflictos con rutas de Windows  
- No hay conflictos con Conda  

---

# 10. ¿Qué sigue después de tener ROS 2 funcionando?

Una vez que `ros2 topic list` funciona, ya puedes continuar con:

### ✔️ Crear tu workspace de ROS 2
```bash
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws
colcon build
source install/setup.bash
```

### ✔️ Instalar paquetes adicionales de ROS 2
Ejemplo:

```bash
sudo apt install ros-humble-cv-bridge ros-humble-vision-opencv
```

### ✔️ Crear tus propios nodos en Python o C++
Ejemplo de nodo Python:

```bash
ros2 pkg create --build-type ament_python mi_paquete
```

### ✔️ Integrar ROS 2 con otras herramientas
- Gazebo (simulación)
- PX4 (autopiloto)
- MAVSDK (control de drones)
- YOLOv8 (visión artificial)
- QGroundControl (estación de control)

### ✔️ Crear launch files
```bash
ros2 launch mi_paquete mi_launch.py
```

### ✔️ Usar colcon para compilar paquetes
```bash
colcon build --symlink-install
```

---

# 11. Resumen

Este documento cubre:

- Instalación limpia de ROS 2 Humble en WSL2  
- Reparación del daemon y DNS  
- Validación con `ros2 topic list`  
- Pasos siguientes para continuar con tu entorno de desarrollo  

Con esto, tu entorno ROS 2 queda **estable, funcional y listo para integrarse con simulación, visión y control de drones**.

---

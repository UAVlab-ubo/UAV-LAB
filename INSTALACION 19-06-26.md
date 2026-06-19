
# Instalación de WSL2 - ROS2 - Gazebo - PX4 SITL - QGC

**Objetivo:** instalar y dejar operativo en **Windows 11 + WSL2 (Ubuntu 22.04 jammy)** el stack reproducible:

- **ROS 2 Humble**  
- **Ignition Gazebo Fortress 6.18.0 (gz-fortress)**  
- **PX4 SITL v1.15.0**

**Reglas clave**  
- Trabaja **siempre** desde tu **home** en WSL: `cd ~`. **No** uses `/mnt/c` para compilar o clonar.  
- Usa **Ubuntu 22.04 (jammy)** como distro por defecto.  
- Clona y compila **PX4 v1.15.0** (tag).  
- Instala **gz-fortress 6.18.0** exactamente.  
- Verifica ROS con `echo $ROS_DISTRO` (no dependas de `ros2 --version`).

---

## Índice rápido
1. Preparar WSL2 y Ubuntu 22.04  
2. Limpieza segura (si hay restos)  
3. Instalar ROS 2 Humble  
4. Instalar Ignition Fortress 6.18.0 (gz-fortress) y ros_gz  
5. Clonar y compilar PX4 v1.15.0 (SITL)  
6. Ajustes de entorno (GZ_RESOURCE_PATH, WSLg)  
7. QGroundControl (AppImage en WSL o nativo en Windows) y MAVLink  
8. Diagnóstico y recuperación rápida  
9. Script opcional de automatización  
10. Buenas prácticas

---

# 1. Preparar WSL2 y Ubuntu 22.04

### En PowerShell (Windows) — ejecutar como Administrador
```powershell
# Instalar WSL con Ubuntu 22.04 (si no está instalado)
wsl --install -d Ubuntu-22.04

# Asegurar WSL2 por defecto
wsl --set-default-version 2

# Actualizar WSL
wsl --update

# Ver distros instaladas
wsl -l -v

# Si hay otra distro y quieres forzar jammy como predeterminada:
wsl --set-default Ubuntu-22.04
```

### En la terminal WSL (Ubuntu 22.04) — **siempre en $HOME**
```bash
# Ir al home y actualizar
cd ~
sudo apt update && sudo apt upgrade -y

# Paquetes básicos
sudo apt install -y build-essential git curl wget ca-certificates gnupg lsb-release software-properties-common python3-pip python3-colcon-common-extensions cmake
```

Verifica la codename:
```bash
lsb_release -cs   # debe imprimir: jammy
```

---

# 2. Limpieza segura (si hay instalaciones previas)

> Ejecuta solo lo que necesites; revisa salidas antes de borrar rutas fuera de tu home.

```bash
# Eliminar copia local de PX4 si existe
rm -rf ~/PX4-Autopilot

# Buscar otras copias de PX4 en el sistema (revisar antes de borrar)
sudo find / -type d -name "PX4-Autopilot" 2>/dev/null

# Eliminar paquetes Python conflictivos localmente
pip3 uninstall -y genmsg genpy pyros-genmsg || true

# Limpiar caches y restos locales
find ~/.local -name "*px4*" -delete || true
find ~/.local -name "*genmsg*" -delete || true
find ~/.cache -name "*.pyc" -delete || true
find ~/.local -name "*.pyc" -delete || true

# Eliminar restos en /usr/local (solo si sabes que provienen de instalaciones previas)
sudo rm -rf /usr/local/lib/libpx4* /usr/local/include/px4* /usr/local/share/px4* /usr/local/lib/cmake/px4* || true
```

---

# 3. Instalar ROS 2 Humble (Ubuntu 22.04)

### Añadir repositorio y claves, instalar
```bash
# Dependencias
sudo apt update
sudo apt install -y curl gnupg2 lsb-release software-properties-common

# Crear keyrings y añadir repo oficial de ROS 2
sudo mkdir -p /etc/apt/keyrings
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] \
  http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update
sudo apt install -y ros-humble-desktop python3-rosdep
```

### Inicializar y configurar
```bash
sudo rosdep init || true
rosdep update

# Sourcing permanente
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### Verificación
```bash
echo $ROS_DISTRO   # salida esperada: humble
ls /opt/ros/humble # debe listar carpetas de instalación
```

**Nota:** si `echo $ROS_DISTRO` no muestra `humble`, revisa que estés en Ubuntu 22.04 y que no haya otra distro por defecto.

---

# 4. Instalar Ignition Gazebo Fortress 6.18.0 (gz-fortress)

### Añadir repositorio OSRF e instalar gz-fortress
```bash
# Dependencias y keyring
sudo apt update
sudo apt install -y wget lsb-release gnupg

# Descargar clave OSRF (guardada en /usr/share/keyrings)
sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/gazebo.gpg

# Añadir repo estable (usa jammy)
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gazebo.gpg] \
  http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

sudo apt update

# Instalar gz-fortress (Ignition Fortress 6.x)
sudo apt install -y gz-fortress
```

### Integración con ROS (ros_gz)
```bash
# Paquetes que integran ROS 2 Humble con Ignition
sudo apt install -y ros-humble-ros-gz ros-humble-gazebo-ros-pkgs
```

### Verificación y GUI
```bash
# Ver versión (puede variar según alias instalado)
gz --version
# o
ign --version

# Lanzar simulador (requiere WSLg)
gz sim -v 4
# o
ign gazebo -v 4
```

**Nota:** en WSL2 la GUI corre vía **WSLg**; no uses `sudo` para lanzar la GUI. Si la ventana no aparece, confirma que WSLg está activo.

---

# 5. Clonar y compilar PX4 SITL v1.15.0

### Clonar y fijar tag
```bash
cd ~
git clone --recursive https://github.com/PX4/PX4-Autopilot.git
cd PX4-Autopilot
git fetch --all --tags
git checkout v1.15.0
git submodule sync --recursive
git submodule update --init --recursive --force

# Verificar tag
git describe --tags --dirty
```

### Instalar dependencias oficiales (script)
```bash
# Ejecutar script oficial de setup (instala dependencias compatibles con Ubuntu 22.04)
cd Tools/setup
sudo ./ubuntu.sh --no-nuttx
```

> **Importante:** usa el script provisto por la versión clonada; evita instalar paquetes manuales que no correspondan a v1.15.

### Dependencias Python recomendadas
```bash
pip3 install --user kconfiglib pyserial empy toml numpy pyyaml packaging
```

### Compilar SITL
```bash
cd ~/PX4-Autopilot

# Compilar SITL (target por defecto)
make px4_sitl -j$(nproc)

# O compilar y lanzar con Ignition/Gazebo para un airframe (ejemplo x500)
make px4_sitl gz_x500 -j$(nproc)
```

### Lanzar mundo Ignition incluido (ejemplo)
```bash
# Listar mundos
ls Tools/simulation/ignition/worlds

# Lanzar ejemplo empty (requiere WSLg)
ign gazebo -v 4 Tools/simulation/ignition/worlds/empty.sdf
```

**Puntos críticos**
- **No** instales `genmsg` ni `genpy` para v1.15.  
- Si ves referencias a utilidades de versiones más nuevas, borra y re-clona el repo.

---

# 6. Ajustes de entorno y WSLg

### Variables de recursos (temporal o persistente)
```bash
# Temporal (sesión actual)
export GZ_RESOURCE_PATH=~/PX4-Autopilot/Tools/simulation/gz/models:$GZ_RESOURCE_PATH
export IGN_GAZEBO_RESOURCE_PATH=~/PX4-Autopilot/Tools/simulation/gz/models:$IGN_GAZEBO_RESOURCE_PATH

# Persistente (añadir a ~/.bashrc)
echo 'export GZ_RESOURCE_PATH=~/PX4-Autopilot/Tools/simulation/gz/models:$GZ_RESOURCE_PATH' >> ~/.bashrc
echo 'export IGN_GAZEBO_RESOURCE_PATH=~/PX4-Autopilot/Tools/simulation/gz/models:$IGN_GAZEBO_RESOURCE_PATH' >> ~/.bashrc
source ~/.bashrc
```

### Permisos WSLg (si aparece warning)
```bash
# Ejecutar solo si ves el warning sobre /mnt/wslg/runtime-dir
sudo chown $(id -u):$(id -g) /mnt/wslg/runtime-dir
sudo chmod 700 /mnt/wslg/runtime-dir
```

**No** uses `sudo` para lanzar la GUI de Ignition; ejecuta `ign` como usuario normal.

---

# 7. QGroundControl y MAVLink

### Opción A — AppImage en WSL (rápida, para pruebas)
```bash
cd ~
wget -O QGroundControl.AppImage "https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage"
chmod +x QGroundControl.AppImage
./QGroundControl.AppImage &
```

### Opción B — QGroundControl nativo en Windows (recomendado para USB y rendimiento)
- Descarga el instalador desde la web oficial en Windows y ejecútalo como Administrador.  
- Si la descarga por PowerShell falla, usa el navegador y verifica el tamaño/hash antes de ejecutar.

### Abrir puertos MAVLink en Windows (PowerShell como Administrador)
```powershell
New-NetFirewallRule -DisplayName "QGC MAVLink UDP 14550 In" -Direction Inbound -Protocol UDP -LocalPort 14550 -Action Allow
New-NetFirewallRule -DisplayName "QGC MAVLink UDP 14550 Out" -Direction Outbound -Protocol UDP -LocalPort 14550 -Action Allow
```

### Verificar puerto MAVLink en WSL
```bash
# Con PX4 corriendo
ss -lunp | grep 14550
# o
netstat -anu | grep 14550
```

### Obtener IP de WSL (si necesitas usarla en QGC)
```bash
ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
```

En QGroundControl añade una conexión UDP con **Host** `localhost` o la IP de WSL y **Port** `14550`.

---

# 8. Diagnóstico y recuperación rápida

### Comprobaciones útiles
```bash
# Confirmar distro
lsb_release -cs

# Confirmar ROS
echo $ROS_DISTRO

# Confirmar PX4
cd ~/PX4-Autopilot
git describe --tags --dirty
git rev-parse HEAD
```

### Recuperar repo PX4 contaminado
```bash
# Borrar y re-clonar limpio
rm -rf ~/PX4-Autopilot
git clone --recursive https://github.com/PX4/PX4-Autopilot.git
cd PX4-Autopilot
git checkout v1.15.0
git submodule update --init --recursive --force
```

### Eliminar restos globales que causan conflictos
```bash
pip3 uninstall -y genmsg genpy pyros-genmsg || true
find ~/.local -name "*px4*" -delete || true
find ~/.cache -name "*.pyc" -delete || true
sudo rm -rf /usr/local/lib/libpx4* /usr/local/include/px4* /usr/local/share/px4* || true
```

### Errores comunes y soluciones rápidas
- **Ejecutar comandos PowerShell en bash** → usa PowerShell para Windows y bash para WSL.  
- **Compilar en /mnt/c** → mueve todo a `~` y recompila.  
- **Ubuntu 24.04 instalado por error** → fija jammy como predeterminada y elimina la otra distro.  
- **Archivo QGC muy pequeño** → la URL devolvió HTML; descarga desde el navegador o usa `curl.exe -L` y verifica tamaño/hash.

---

# 9. Script de instalación automatizada (opcional)

Guarda como `~/setup_px4_v1.15.sh`, revisa y ejecuta **solo si confías** en el script:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Instalador PX4 v1.15 para Ubuntu 22.04 en WSL2"
echo "Revisa el script antes de ejecutar."

# Limpieza mínima
rm -rf ~/PX4-Autopilot || true
pip3 uninstall -y genmsg genpy pyros-genmsg || true
find ~/.local -name "*px4*" -delete || true
find ~/.cache -name "*.pyc" -delete || true

# Clonar PX4 v1.15
cd ~
git clone --recursive https://github.com/PX4/PX4-Autopilot.git
cd PX4-Autopilot
git fetch --all --tags
git checkout v1.15.0
git submodule sync --recursive
git submodule update --init --recursive --force

# Instalar dependencias del sistema
cd Tools/setup
sudo ./ubuntu.sh --no-nuttx

# Dependencias Python
pip3 install --user kconfiglib pyserial empy toml numpy pyyaml packaging

# Compilar PX4 SITL
cd ~/PX4-Autopilot
make px4_sitl

echo "Instalación completada. Revisa la salida por errores."
```

Hacer ejecutable y correr:
```bash
chmod +x ~/setup_px4_v1.15.sh
~/setup_px4_v1.15.sh
```

---

# 10. Buenas prácticas y recomendaciones finales

- **Siempre** trabajar en `~` dentro de WSL2.  
- **No** mezclar carpetas montadas de Windows para compilar.  
- **Usar tags concretos** (`v1.15.0`) para reproducibilidad.  
- **Mantener snapshots** o copias de `~/PX4-Autopilot` antes de actualizar.  
- **Usar WSLg** para la GUI de Ignition en Windows 11.  
- **Abrir firewall UDP 14550** si QGC corre en Windows.  
- **Si algo falla**, borra y re-clona en lugar de intentar arreglar una copia contaminada.

---

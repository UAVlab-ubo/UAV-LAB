**ROS2 Humble + Ubuntu 22.04 + Gazebo Ignition + PX4 SITL + QGroundControl en Windows con WSL2**
---

# DOCUMENTACIÓN COMPLETA DEL ENTORNO PX4 + ROS2 + GAZEBO + QGC EN WSL2

---

# 1️. Instalación correcta de Ubuntu 22.04 en WSL2

ROS2 Humble **solo funciona en Ubuntu 22.04**, por eso es obligatorio usar esa versión.

### 1. Ver distros instaladas
En PowerShell:

```c
wsl --list --verbose
```

### 2. Establecer Ubuntu‑22.04 como la distro por defecto
```c
wsl --set-default Ubuntu-22.04
```

### 3. Iniciar Ubuntu‑22.04
```c
wsl -d Ubuntu-22.04
```

### 4. Verificar versión
Dentro de Ubuntu:

```c
lsb_release -a
```

Debe decir:

```c
Ubuntu 22.04 LTS (jammy)
```

---

# 2️. Instalación limpia de ROS2 Humble en Ubuntu 22.04 (WSL2)

### 1. Dependencias
```c
sudo apt update
sudo apt install -y software-properties-common curl gnupg lsb-release
```

### 2. Clave GPG
```c
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
-o /usr/share/keyrings/ros-archive-keyring.gpg
```

### 3. Repositorio ROS2
```c
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
```

### 4. Actualizar
```c
sudo apt update
```

### 5. Instalar ROS2 Humble Desktop
```c
sudo apt install ros-humble-desktop -y
```

### 6. Agregar ROS2 al entorno
```c
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### 7. Verificar
```c
ros2
echo $ROS_DISTRO
```

Debe mostrar:

```
humble
```

---

# 3️. Instalación de Gazebo Ignition (Fortress)

Gazebo11 **SI existe** para Ubuntu 22.04, pero en esta ocasión se usará **Ignition Fortress**, totalmente compatible con PX4 SITL.

### 1. Dependencias
```c
sudo apt update
sudo apt install -y lsb-release wget gnupg
```

### 2. Clave
```c
sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/gazebo.gpg
```

### 3. Repositorio
```c
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gazebo.gpg] \
https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
```

### 4. Instalar Ignition Fortress
```c
sudo apt update
sudo apt install ignition-fortress -y
```

### 5. Verificar
```c
ign gazebo --versions
```

---

# 4️. Instalación de PX4-Autopilot (SITL)

### 1. Clonar PX4
```c
cd ~
git clone https://github.com/PX4/PX4-Autopilot.git --recursive
```

### 2. Instalar dependencias
```c
cd ~/PX4-Autopilot/Tools/setup
sudo ./ubuntu.sh
```

### 3. Instalar kconfiglib (obligatorio)
Si aparece el error *“No module named menuconfig”*:

```c
pip3 install kconfiglib
```

### 4. Compilar PX4 SITL con Ignition
```c
cd ~/PX4-Autopilot
make px4_sitl ignition
```

Esto abre Ignition (WSLg en Windows 11) o corre headless (Windows 10).

# 

# Instalación de PX4 SITL en Ubuntu 22.04 dentro de WSL2 

---

### 1. Preparación del entorno básico
Asegúrate de tener herramientas y Python3 pip instalados.

```c
bash
sudo apt update
sudo apt install -y build-essential git python3-pip python3-venv wget curl lsb-release
```

Si usas WSLg en Windows 11 para ver Ignition, confirma que WSLg está activo. Si no, la simulación correrá headless.

---

### 2. Clonar PX4 Autopilot
```c
bash
cd ~
git clone https://github.com/PX4/PX4-Autopilot.git --recursive
cd PX4-Autopilot
```

Si ya lo clonaste, actualiza:
```c
bash
cd ~/PX4-Autopilot
git fetch --all
git checkout main
git pull --rebase
git submodule update --init --recursive
```

---

### 3. Instalar dependencias del sistema para PX4
PX4 incluye un script que instala la mayoría de dependencias en Ubuntu.

```c
bash
cd ~/PX4-Autopilot/Tools/setup
sudo ./ubuntu.sh
```

Si el script pide confirmación o muestra errores, revisa la salida y corrige paquetes faltantes. Después reinicia la shell.

---

### 4. Instalar kconfiglib y otras dependencias Python necesarias
PX4 requiere `kconfiglib` para menuconfig y la configuración de build.

```c
bash
python3 -m pip install --user kconfiglib pyserial empy toml numpy
```

Si prefieres instalar globalmente:
```c
bash
sudo python3 -m pip install kconfiglib pyserial empy toml numpy
```

Verifica:
```c
bash
python3 -c "import kconfiglib; print('kconfiglib OK')"
```

---

### 5. Limpiar builds previos y compilar PX4 SITL con Ignition
```c
bash
cd ~/PX4-Autopilot
make clean
make px4_sitl ignition
```

Notas importantes
- Si quieres usar **Gazebo classic** usa `make px4_sitl gazebo` en lugar de `ignition`.
- Si la compilación falla, pega la salida de error; normalmente faltan paquetes del script `ubuntu.sh` o módulos Python.

---

### 6. Ejecutar PX4 SITL y abrir Ignition
Si `make px4_sitl ignition` terminó bien, el binario SITL se ejecutará y lanzará Ignition.  
Si necesitas lanzar manualmente:

```c
bash
# lanzar SITL con un mundo por defecto
cd ~/PX4-Autopilot
DONT_RUN=1 make px4_sitl ignition
# luego ejecutar el binario generado
./build/px4_sitl_default/bin/px4 ./ROMFS/px4fmu_common/init.d-posix/rcS -s etc/init.d-posix/rcS
```

En WSLg la ventana de Ignition debería aparecer en Windows. Si no ves GUI, confirma WSLg o usa `ign gazebo -v 4 <world.sdf>` en la máquina host.

---

### 7. Instalar el puente ROS2 PX4 px4_ros_com
Crea workspace ROS2 y clona los paquetes necesarios.

```c
bash
# crear workspace
mkdir -p ~/px4_ros2_ws/src
cd ~/px4_ros2_ws/src

# clonar repositorios
git clone https://github.com/PX4/px4_msgs.git
git clone https://github.com/PX4/px4_ros_com.git
# opcional: px4_ros_multirotor, px4_ros_com_interfaces según necesidad

cd ~/px4_ros2_ws

# instalar dependencias ROS2
rosdep update
rosdep install --from-paths src --ignore-src -r -y

# compilar
colcon build --symlink-install
```

Agregar al entorno:
```c
bash
echo "source ~/px4_ros2_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

---

### 8. Conectar PX4 SITL con px4_ros_com y QGroundControl
- PX4 SITL por defecto expone MAVLink en `127.0.0.1:14550`.  
- Abre **QGroundControl** en Windows; debería detectar la conexión automáticamente.  
- Para conectar ROS2, lanza los nodos de `px4_ros_com` si no se lanzaron automáticamente.

Ejemplo para lanzar el bridge (según paquetes disponibles):
```c
bash
# si el paquete incluye launch files
ros2 launch px4_ros_com px4_bridge.launch.py
```

Verifica topics ROS2:
```c
bash
ros2 topic list | grep fmu
# o
ros2 topic list
```

Deberías ver topics como `/fmu/out/vehicle_status` o `/fmu/out/vehicle_local_position`.

---

### 9. Comandos útiles de verificación y debugging
```c
bash
# verificar que PX4 está corriendo
ps aux | grep px4

# ver logs de PX4
tail -f ~/.ros/px4_sitl.log

# ver que Ignition está corriendo
ps aux | grep ignition

# ver topics ROS2
ros2 topic list
ros2 topic echo /fmu/out/vehicle_local_position

# comprobar MAVLink en puerto 14550
ss -ltnp | grep 14550
```

---

### 10. Problemas comunes y soluciones rápidas
- **Error kconfiglib**: ejecutar `pip3 install kconfiglib` como se indicó.  
- **Fallo en `make` por dependencias**: volver a ejecutar `Tools/setup/ubuntu.sh` y revisar errores.  
- **Ignition no muestra GUI**: activar WSLg o ejecutar Ignition en Windows nativo.  
- **px4_ros_com no publica topics**: verificar que `colcon build` terminó sin errores y que `source ~/px4_ros2_ws/install/setup.bash` está activo en la terminal donde lanzas el bridge.  
- **QGC no detecta SITL**: comprobar que no haya firewall bloqueando localhost y que PX4 esté enviando a `127.0.0.1:14550`.

---

### Resumen rápido de comandos en bloque
```c
bash
# preparar
sudo apt update
sudo apt install -y build-essential git python3-pip python3-venv wget curl lsb-release

# clonar PX4
cd ~
git clone https://github.com/PX4/PX4-Autopilot.git --recursive
cd PX4-Autopilot

# dependencias PX4
cd Tools/setup
sudo ./ubuntu.sh

# instalar kconfiglib
python3 -m pip install --user kconfiglib pyserial empy toml numpy

# compilar SITL con Ignition
cd ~/PX4-Autopilot
make clean
make px4_sitl ignition

# workspace ROS2 para px4_ros_com
mkdir -p ~/px4_ros2_ws/src
cd ~/px4_ros2_ws/src
git clone https://github.com/PX4/px4_msgs.git
git clone https://github.com/PX4/px4_ros_com.git
cd ~/px4_ros2_ws
rosdep update
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install
echo "source ~/px4_ros2_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

---

# 5️. Instalación del puente ROS2 ↔ PX4 (px4_ros_com)

### 1. Crear workspace
```c
mkdir -p ~/px4_ros2_ws/src
cd ~/px4_ros2_ws/src
```

### 2. Clonar repositorios
```c
git clone https://github.com/PX4/px4_msgs.git
git clone https://github.com/PX4/px4_ros_com.git
```

### 3. Instalar dependencias
```c
cd ~/px4_ros2_ws
rosdep install --from-paths src --ignore-src -y
```

### 4. Compilar
```c
colcon build
```

### 5. Agregar al entorno
```c
echo "source ~/px4_ros2_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

---

# 6️. Conectar QGroundControl (Windows)
1. Instalar QGroundControl para Windows (en nuestro caso)
2. Abrir QGroundControl en Windows  
3. PX4 SITL envía MAVLink a `127.0.0.1:14550`  
4. QGC lo detecta automáticamente  

Verás HUD, modos, parámetros, telemetría.

---

# 7️. Verificar comunicación ROS2 ↔ PX4

Con PX4 corriendo:

```c
ros2 topic list
```

Debes ver:

```c
/fmu/out/vehicle_status
/fmu/out/vehicle_local_position
```

Si aparecen → **ROS2 está conectado a PX4**.

---

# Qué falta por hacer

Se tiene:

✔ Ubuntu 22.04  
✔ ROS2 Humble  
✔ Gazebo Ignition  
✔ PX4-Autopilot  
✔ Workspace ROS2  

Falta:

### 1. Compilar PX4 correctamente (ya casi lo tienes)
Ya instalaste kconfiglib, así que la compilación debería avanzar.

### 2. Probar SITL con Ignition
`make px4_sitl ignition`

### 3. Probar px4_ros_com
`ros2 topic list`

### 4. Crear nodos ROS2 para controlar el dron
- armar  
- despegar  
- mover  
- aterrizar  
---

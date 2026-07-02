> 07-05-2026

---

# Guía completa: Instalación, uso y diagnóstico de PX4 desde cero  
**Para:** Ignacio — principiante en firmware de drones  
**Objetivo:** Pasar desde “nunca toqué PX4” hasta “vuelo un dron real con firmware compilado por mí y sé diagnosticarlo desde QGroundControl”.

---

## 0. Requisitos previos

- PC con mínimo 8 GB de RAM (ideal 16 GB).  
- 30 GB libres en disco.  
- Conexión a internet estable.  
- Tiempo estimado inicial: 2–4 horas.  
- Disposición para usar terminal.

---

## 1. Instalar Linux (Ubuntu 22.04 LTS)

Ubuntu es la distribución estándar para PX4.  
Opciones:

1. Dual boot (recomendado).  
2. Máquina virtual (más lento).  
3. WSL2 (funciona, pero simulación gráfica requiere ajustes).

---

## 2. Familiarizarse con la terminal

Abrir terminal: `Ctrl + Alt + T`.

Comandos básicos:

```bash
pwd
ls
cd carpeta
cd ..
mkdir nombre
sudo comando
```

---

## 3. Instalar Git

```bash
sudo apt update
sudo apt install git -y
git config --global user.name "Ignacio"
git config --global user.email "tu@email.com"
```

---

## 4. Clonar PX4

```bash
cd ~
git clone https://github.com/PX4/PX4-Autopilot.git --recursive
```

Si faltan submódulos:

```bash
cd PX4-Autopilot
git submodule update --init --recursive
```

---

## 5. Instalar dependencias

```bash
cd ~/PX4-Autopilot
bash ./Tools/setup/ubuntu.sh
```

Instala: toolchain ARM, CMake, Ninja, Python, Gazebo Harmonic, jMAVSim, generadores de código, etc.

Reiniciar al terminar.

---

## 6. Conocer el toolchain instalado

- `arm-none-eabi-gcc`: compilador para ARM.  
- `make`: sistema clásico de build.  
- `cmake`: generador de build.  
- `gdb-multiarch`: debugger.  
- `openocd`: flasheo y debugging hardware.

---

## 7. Primera compilación: SITL

```bash
cd ~/PX4-Autopilot
make px4_sitl
```

Si compila correctamente aparece:

```
[100%] Built target px4
```

---

## 8. Instalar y verificar Gazebo Harmonic

```bash
gz sim --version
```

Debe mostrar versión 8.x.x.

---

## 9. Primer vuelo simulado

```bash
cd ~/PX4-Autopilot
make px4_sitl gz_x500
```

En la consola `pxh>`:

```bash
commander takeoff
commander land
```

Comandos útiles:

```bash
commander arm
commander disarm
listener vehicle_attitude
listener vehicle_local_position
listener sensor_combined
top
```

---

## 10. Instalar QGroundControl

```bash
sudo usermod -a -G dialout $USER
sudo apt-get remove modemmanager -y
sudo apt install gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl -y
sudo apt install libfuse2 -y
```

Ejecutar AppImage:

```bash
chmod +x ~/Downloads/QGroundControl.AppImage
~/Downloads/QGroundControl.AppImage
```

---

## 11. Misión autónoma en simulación

1. Abrir QGC.  
2. Ir a **Plan**.  
3. Crear waypoints.  
4. Upload.  
5. En **Fly**, iniciar misión.

---

## 12. Editor de código: VS Code

```bash
sudo snap install code --classic
cd ~/PX4-Autopilot
code .
```

Extensiones recomendadas: C/C++, CMake Tools, Cortex-Debug, GitLens, PX4 Tools.

---

## 13. Compilar para hardware real

```bash
make px4_fmu-v6x_default
make px4_fmu-v6c_default
make cubepilot_cubeorange
make holybro_durandal-v1_default
```

Produce un `.px4` listo para flashear.

---

## 14. Flashear firmware al Pixhawk

### Desde QGC
1. Conectar Pixhawk por USB.  
2. Vehicle Setup → Firmware.  
3. Advanced Settings → Custom firmware file.  
4. Seleccionar `.px4`.

### Desde terminal
```bash
make px4_fmu-v6x_default upload
```

---

## 15. Configuración inicial del dron real

En QGC:

1. **Sensors**: calibrar IMU, magnetómetro, nivel.  
2. **Radio**: calibrar sticks.  
3. **Flight Modes**: asignar modos.  
4. **Power**: configurar batería.  
5. **Safety**: failsafe, geofence, RTL.  
6. **Tuning**: ajustar PID solo después de volar.

---

## 16. Primer vuelo real: precauciones

- Probar sin hélices primero.  
- Zona abierta.  
- Piloto de seguridad.  
- Usar Stabilized o Position.  
- Conocer botón RTL.  
- Batería cargada.  
- En Chile: credencial DGAC, registro aeronave, seguro.

---

## 17. Próximos pasos para desarrollo

1. Leer `px4_simple_app`.  
2. Definir parámetros con `PARAM_DEFINE_FLOAT`.  
3. Suscribirse a topics uORB.  
4. Escribir un driver.  
5. Hacer un Pull Request.

---

# 18. Diagnóstico por grupos de parámetros en QGroundControl

Esta sección permite diagnosticar fallas del dron **solo usando QGroundControl**, sin tocar código fuente.

---

## 18.1 Grupo EKF2 — Estimador de estado

Diagnostica:

- Pérdida de GPS.  
- Inconsistencias IMU–GPS.  
- Problemas de magnetómetro.  
- Vibraciones.  
- Altitud inestable.

Parámetros clave:

- `EKF2_AID_MASK`  
- `EKF2_GPS_CHECK`  
- `EKF2_MAG_NOISE`  
- `EKF2_IMU_POS_X/Y/Z`  
- `EKF2_BARO_NOISE`

---

## 18.2 Grupo MC_ — Control de actitud

Diagnostica:

- Oscilaciones.  
- Vibraciones.  
- Respuesta lenta.  
- Yaw inestable.

Parámetros clave:

- `MC_ROLL_P`, `MC_PITCH_P`  
- `MC_ROLLRATE_P`, `MC_PITCHRATE_P`  
- `MC_YAW_P`, `MC_YAWRATE_P`  
- `MC_THR_MIN`, `MC_THR_MAX`

---

## 18.3 Grupo MPC_ — Control de posición

Diagnostica:

- Altura inestable.  
- Drift horizontal.  
- Movimientos bruscos.  
- Respuesta lenta.

Parámetros clave:

- `MPC_Z_P`, `MPC_Z_VEL_P`  
- `MPC_XY_P`, `MPC_XY_VEL_P`  
- `MPC_ACC_HOR`, `MPC_ACC_UP`  
- `MPC_JERK_MAX`  
- `MPC_THR_HOVER`

---

## 18.4 Grupo SENS_ — Sensores

Diagnostica:

- IMU ruidosa.  
- Magnetómetro interferido.  
- Barómetro incorrecto.  
- GPS inestable.

Parámetros clave:

- `SENS_IMU_MODE`  
- `SENS_MAG_MODE`  
- `SENS_BARO_QNH`  
- `SENS_GPS_MASK`

---

## 18.5 Grupo BAT_ — Batería

Diagnostica:

- Caída de tensión.  
- Número de celdas incorrecto.  
- Lecturas erróneas.

Parámetros clave:

- `BAT_N_CELLS`  
- `BAT_V_EMPTY`  
- `BAT_V_CHARGED`  
- `BAT_V_LOAD_DROP`

---

## 18.6 Grupo COM_ — Failsafe y comunicación

Diagnostica:

- Pérdida de RC.  
- Failsafe por batería.  
- Failsafe por GPS.  
- Geofence.

Parámetros clave:

- `COM_RC_LOSS_T`  
- `COM_LOW_BAT_ACT`  
- `COM_OBS_AVOID`  
- `COM_GEOFENCE_ACTION`

---

# 19. Tabla de diagnóstico operativo (síntoma → grupo → qué revisar)

---

## 19.1 Síntomas relacionados con armado / failsafe

| Síntoma | Grupo | Qué revisar |
|--------|--------|-------------|
| No arma | COM_, BAT_, SENS_ | `COM_ARM_WO_GPS`, `COM_ARM_EKF_HGT`, `COM_ARM_MAG`, `BAT_N_CELLS`, calibración de sensores |
| No arma por GPS | EKF2_, GPS_, COM_ | `EKF2_GPS_CHECK`, calidad GPS, `COM_ARM_WO_GPS` |
| Failsafe al despegar | COM_, BAT_, EKF2_ | `COM_LOW_BAT_ACT`, `BAT_V_LOAD_DROP`, innovaciones EKF |

---

## 19.2 Síntomas relacionados con deriva

| Síntoma | Grupo | Qué revisar |
|--------|--------|-------------|
| Deriva lateral | MPC_, EKF2_, GPS_ | `MPC_XY_P`, `MPC_XY_VEL_P`, calidad GPS |
| Deriva en altura | MPC_, EKF2_, SENS_ | `MPC_Z_P`, barómetro, innovaciones EKF |
| Deriva en yaw | EKF2_, SENS_, MC_ | `EKF2_MAG_NOISE`, magnetómetro, `MC_YAW_P` |

---

## 19.3 Síntomas relacionados con oscilaciones

| Síntoma | Grupo | Qué revisar |
|--------|--------|-------------|
| Oscilaciones rápidas | MC_ | `MC_ROLL_P`, `MC_PITCH_P`, ganancias altas |
| Oscilaciones lentas | MPC_, MC_ | `MPC_XY_P`, `MPC_Z_P` |
| Vibraciones | SENS_, EKF2_ | IMU, innovaciones EKF |

---

## 19.4 Síntomas relacionados con control

| Síntoma | Grupo | Qué revisar |
|--------|--------|-------------|
| Respuesta lenta | MC_, MPC_ | `MC_ROLL_P`, `MPC_ACC_HOR` |
| Movimientos bruscos | MPC_ | `MPC_ACC_HOR`, `MPC_JERK_MAX` |
| No mantiene posición | EKF2_, GPS_, MPC_ | `EKF2_GPS_CHECK`, `MPC_XY_P` |

---

## 19.5 Síntomas relacionados con batería

| Síntoma | Grupo | Qué revisar |
|--------|--------|-------------|
| Caída brusca de voltaje | BAT_ | `BAT_V_LOAD_DROP`, `BAT_N_CELLS` |
| Failsafe inesperado | BAT_, COM_ | `COM_LOW_BAT_ACT`, `BAT_V_EMPTY` |
| Lecturas inconsistentes | BAT_ | calibración de batería |

---

## 19.6 Síntomas relacionados con sensores

| Síntoma | Grupo | Qué revisar |
|--------|--------|-------------|
| Altitud errática | SENS_, EKF2_, MPC_ | barómetro, innovaciones EKF |
| Posición errática | GPS_, EKF2_ | calidad GPS |
| Yaw inestable | SENS_, EKF2_, MC_ | magnetómetro, interferencias |

---

# 20. Errores comunes y soluciones

| Error | Solución |
|-------|----------|
| `make: command not found` | `sudo apt install build-essential` |
| `ModuleNotFoundError: No module named 'xxx'` | `pip3 install xxx` |
| Gazebo no abre | `HEADLESS=1 make px4_sitl gz_x500` |
| QGC no detecta SITL | revisar firewall |
| Pixhawk no detectado | `sudo usermod -aG dialout $USER` |
| Error git pull | `git stash`, `git pull`, `git stash pop` |

---

# 21. Recursos

- docs.px4.io  
- discord.gg/dronecode  
- discuss.px4.io  
- YouTube PX4 Autopilot  
- Embebidos32  
- github.com/PX4/PX4-Autopilot

---

# 22. Estimaciones de tiempo

- Vuelo simulado: 8–10 horas.  
- Primer vuelo real: 2–4 semanas.  
- Entender arquitectura: 3–6 meses.  
- Modificar módulos con confianza: 1 año.

---

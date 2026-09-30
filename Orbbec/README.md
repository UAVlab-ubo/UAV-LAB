# Orbbec Astra RGB-D Camera & RTAB-Map 3D SLAM (ROS 2)

Este repositorio contiene scripts de ejecución, herramientas de diagnóstico y plantillas de visualización para utilizar la cámara **Orbbec Astra** en **ROS 2** (distribución Jazzy), integrando transmisión en vivo, odometría visual, **RTAB-Map 3D SLAM** y visualización mediante **Foxglove Studio** y **RViz2**.

---

## 📋 Requisitos y Dependencias

- **Sistema Operativo:** Ubuntu 24.04 (o entorno Linux compatible) / WSL2
- **ROS 2:** Distribución `Jazzy Jalisco` (o compatible)
- **Middleware DDS:** `rmw_cyclonedds_cpp`
- **Paquetes ROS 2:**
  - `ros-jazzy-astra-camera` (driver de cámara Orbbec)
  - `ros-jazzy-rtabmap-ros` / `ros-jazzy-rtabmap-launch`
  - `ros-jazzy-foxglove-bridge`
  - `ros-jazzy-rmw-cyclonedds-cpp`
- **Visualizador:** [Foxglove Studio](https://foxglove.dev/) o RViz2.

---

## 📁 Estructura del Repositorio

```text
.
├── README.md                              # Documentación del proyecto
├── .gitignore                             # Filtro de archivos no deseados en git
├── astra_view.rviz                        # Configuración preestablecida para RViz2
├── orbbec_astra_foxglove_layout.json      # Layout de Foxglove para stream de cámara
├── orbbec_rtabmap_foxglove_layout.json    # Layout de Foxglove para RTAB-Map 3D SLAM
│
├── start_camera_live.sh                   # Inicia driver de cámara + Foxglove Bridge
├── start_3d_mapping.sh                    # Inicia driver + Foxglove Bridge + RTAB-Map SLAM
│
└── Scripts de Diagnóstico y Pruebas:
    ├── check_pc_fields.sh                 # Inspección de campos del PointCloud2
    ├── clean_bashrc.sh                    # Limpieza y saneamiento de variables en .bashrc
    ├── diagnose_dds.sh                    # Diagnóstico de middleware DDS (Cyclone vs FastDDS)
    ├── test_camera_stream.sh              # Prueba de inicio y tasa de publicación
    ├── test_exact_env.sh                  # Comprobación de variables de entorno de ROS 2
    ├── test_foxglove.sh                   # Verificación del puerto y servicio Foxglove Bridge
    ├── test_hz.sh                         # Medición de frecuencia (Hz) de tópicos de imagen
    ├── test_node_info.sh                  # Inspección de nodos activos
    ├── test_params.sh                     # Inspección de parámetros de la cámara
    ├── test_pointcloud.sh                 # Comprobación de nube de puntos generada
    └── test_rtabmap.sh                    # Verificación de tópicos para RTAB-Map
```

---

## 🚀 Guía de Uso

### 1. Iniciar Transmisión de Cámara en Vivo
Para activar la cámara con registro de profundidad y nube de puntos a color:

```bash
chmod +x start_camera_live.sh
./start_camera_live.sh
```

### 2. Iniciar Mapeo 3D (RTAB-Map SLAM)
Para iniciar la cámara, odometría visual RGB-D y el nodo de SLAM 3D:

```bash
chmod +x start_3d_mapping.sh
./start_3d_mapping.sh
```

### 3. Visualización

#### Con Foxglove Studio (Recomendado):
1. Abre **Foxglove Studio**.
2. Conéctate a través de WebSocket en `ws://localhost:8765`.
3. Importa el layout deseado:
   - Para cámara y nube de puntos: `orbbec_astra_foxglove_layout.json`
   - Para mapeo 3D y odometría: `orbbec_rtabmap_foxglove_layout.json`

#### Con RViz2:
```bash
rviz2 -d astra_view.rviz
```

---

## 🛠️ Diagnóstico y Solución de Problemas

Si experimentas problemas de comunicación DDS o desconexión de tópicos:
- Ejecuta `./diagnose_dds.sh` para comprobar la configuración de CycloneDDS.
- Ejecuta `./test_camera_stream.sh` para validar que la cámara publica en `/camera/color/image_raw` y `/camera/depth/image_raw`.
- Ejecuta `./test_rtabmap.sh` para verificar la sincronización de mensajes para SLAM.

> 12-06-2026

# MAVlink
**MAVLink es un protocolo ligero de mensajería diseñado para la comunicación entre drones y estaciones de control en tierra. Es eficiente, confiable y ampliamente usado en sistemas de vehículos aéreos no tripulados (UAV), permitiendo transmitir telemetría, comandos y datos entre múltiples dispositivos.**  

---

## ¿Qué es MAVLink?
- **Definición:** Protocolo de comunicación creado en 2009 por Lorenz Meier para drones y componentes relacionados.  
- **Características principales:**
  - **Ligero:** MAVLink 1 usa solo 8 bytes de sobrecarga por paquete; MAVLink 2, 14 bytes, con mayor seguridad y extensibilidad.  
  - **Confiable:** Detecta pérdidas y corrupción de paquetes, soporta autenticación.  
  - **Flexible:** Compatible con hasta **255 sistemas simultáneos** (vehículos, estaciones, cámaras, etc.).  
  - **Multiplataforma:** Funciona en microcontroladores (ARM, STM32, ATMega) y sistemas operativos como Windows, Linux, macOS, Android e iOS.  
- **Dialecto:** Los mensajes se definen en archivos XML. El más común es **common.xml**, usado por la mayoría de estaciones de control y pilotos automáticos.  [MAVLink Developer Guide](https://mavlink.io/en/)  

---

## Cómo usar MAVLink
### 1. **Instalación y librerías**
- Se generan librerías a partir de los archivos XML usando herramientas como:
  - **mavgen** (C/C++)  
  - **mavgenerate** (Python, otros lenguajes)  
  - **rust-mavlink** (Rust)  
- Estas librerías permiten enviar y recibir mensajes MAVLink en tu aplicación.  [MAVLink Developer Guide](https://mavlink.io/en/)  

### 2. **Comunicación básica**
- **Publicación/Suscripción:** Telemetría y datos de sensores se transmiten como *topics*.  
- **Punto a punto:** Protocolos de misión y parámetros se manejan con retransmisión confiable.  
- **Ejemplo de uso:**  
  - Una estación de control en tierra (GCS) envía comandos de misión al dron.  
  - El dron responde con telemetría (posición, velocidad, estado de batería).  

### 3. **Microservicios (sub-protocolos)**
- **Mission Protocol:** Define y gestiona misiones (waypoints, rutas).  
- **Parameter Protocol:** Configura parámetros del dron.  
- **File Transfer Protocol:** Envía/recibe archivos (ej. mapas, logs).  
- **Message Signing:** Seguridad y autenticación en MAVLink 2.  [MAVLink Developer Guide](https://mavlink.io/en/guide/index.html)  

---

## Comparación MAVLink 1 vs MAVLink 2

| Característica        | MAVLink 1 | MAVLink 2 |
|------------------------|-----------|-----------|
| Sobrecarga por paquete | 8 bytes   | 14 bytes  |
| Seguridad              | Básica    | Firma de mensajes, autenticación |
| Extensibilidad         | Limitada  | Alta (nuevos mensajes y dialectos) |
| Compatibilidad         | Amplia    | Compatible con MAVLink 1 |

---

<br>

# SITL
**SITL (Software In The Loop) es una técnica de simulación que permite ejecutar el firmware de un piloto automático directamente en tu computadora, sin necesidad de hardware físico. Es ampliamente usado en drones con ArduPilot y PX4 para probar algoritmos, misiones y sensores en entornos virtuales antes de volar en el mundo real.**  

---

## ¿Qué es SITL?
- **Definición:** Es una simulación del autopiloto en software, donde el código real del firmware (ArduPilot o PX4) corre en tu PC.  
- **Objetivo:** Probar el comportamiento del dron sin riesgo, reduciendo costos y evitando accidentes.  
- **Características principales:**
  - Ejecuta el mismo código que correría en el dron físico.  
  - Usa modelos dinámicos de vuelo para simular sensores (GPS, IMU, barómetro, etc.).  
  - Compatible con múltiples vehículos: **multirrotores, aviones, rovers, submarinos, gimbals, antenas**.  
  - Se integra con simuladores gráficos como **Gazebo** o **AirSim** para entornos 3D realistas.  [ArduPilot](https://ardupilot.org/dev/docs/sitl-simulator-software-in-the-loop.html)  

---

## Cómo usar SITL
### 1. **Instalación básica**
- En **ArduPilot**:  
  ```bash
  git clone https://github.com/ArduPilot/ardupilot.git
  cd ardupilot
  ./Tools/environment_install/install-prereqs-ubuntu.sh -y
  . ~/.profile
  sim_vehicle.py -v ArduCopter -f gazebo-iris
  ```
- En **PX4**:  
  ```bash
  git clone https://github.com/PX4/PX4-Autopilot.git --recursive
  cd PX4-Autopilot
  make px4_sitl gazebo
  ```

### 2. **Ejecutar simulaciones**
- Puedes lanzar un dron virtual (ej. **Iris quadcopter**) en Gazebo o en un simulador ligero.  
- SITL genera telemetría que puede visualizarse en **QGroundControl** o **Mission Planner**.  

### 3. **Control del dron**
- Conectar SITL a **MAVLink/MAVROS** para enviar comandos desde ROS.  
- Probar misiones automáticas, navegación GPS, control manual con joystick o scripts en Python.  

---

## Ventajas y desventajas

| Aspecto              | Ventajas | Desventajas |
|-----------------------|----------|-------------|
| Seguridad             | Sin riesgo de accidentes | No sustituye pruebas reales |
| Costos                | Gratis, sin hardware | Requiere PC potente |
| Flexibilidad          | Multivehículos y sensores | Configuración inicial compleja |
| Integración           | Compatible con Gazebo, ROS, QGroundControl | Puede ser difícil para principiantes |

---

<br>

# Gazebo
**Gazebo es un simulador de robots de código abierto que permite probar diseños, algoritmos de control y sensores en entornos virtuales realistas antes de implementarlos en hardware físico. Es ampliamente usado en investigación, educación y desarrollo de sistemas autónomos.**  

---

## ¿Qué es Gazebo?
- **Definición:** Plataforma de simulación 3D para robots, creada por Open Robotics.  
- **Objetivo:** Probar robots y algoritmos en escenarios seguros y realistas sin necesidad de hardware físico.  
- **Características principales:**
  - **Motores de física avanzados** (ODE, Bullet, DART, Simbody).  
  - **Gráficos realistas** con iluminación, sombras y texturas de alta calidad.  
  - **Sensores simulados**: cámaras, LIDAR, GPS, IMU, sensores de contacto, etc.  
  - **Plugins personalizables** para controlar robots, sensores y entornos.  
  - **Compatibilidad con ROS (Robot Operating System)**, lo que facilita la integración con proyectos reales.  [Gazebo](https://gazebosim.org/)  [Gazebo](https://gazebosim.org/libs/sim/)  

---

## Cómo usar Gazebo
### 1. **Instalación**
- En **Ubuntu**:  
  ```bash
  sudo apt update
  sudo apt install gz-sim
  ```
- En **Windows/macOS**: disponible vía **Homebrew** o compilación desde código fuente.  [Gazebo](https://gazebosim.org/libs/sim/)  

### 2. **Ejecutar una simulación**
- Comando básico:  
  ```bash
  gz sim
  ```
- Para ayuda y opciones:  
  ```bash
  gz sim -h
  ```

### 3. **Interacción**
- **Interfaz gráfica (GUI):** Permite crear mundos, añadir robots y sensores.  
- **Línea de comandos:** Control avanzado de simulaciones.  
- **Plugins:** Código en C++ o Python para extender funcionalidades.  

### 4. **Modelos y entornos**
- Acceso a **Gazebo Fuel**, repositorio de modelos listos para usar (robots como TurtleBot, PR2, Pioneer).  
- Creación de modelos propios con **SDF (Simulation Description Format)**.  [osrf.github.io](https://osrf.github.io/gazebo-doc-index/)  

---

## Ventajas y desventajas

| Aspecto              | Ventajas | Desventajas |
|-----------------------|----------|-------------|
| Física realista       | Motores avanzados, simulación precisa | Requiere buen hardware |
| Sensores              | Amplia variedad con modelos de ruido | Configuración inicial compleja |
| Integración con ROS   | Estándar en robótica | Curva de aprendizaje alta |
| Comunidad             | Activa, con recursos y soporte | Documentación dispersa |

---

<br>

# ROS 2
**ROS 2 (Robot Operating System 2) es un conjunto de librerías y herramientas de código abierto que permiten desarrollar aplicaciones robóticas modernas, distribuidas y seguras. Es la evolución de ROS 1, con mejoras en comunicación, soporte multiplataforma y compatibilidad con sistemas en tiempo real.**   [ROS Documentation](https://docs.ros.org/en/rolling/index.html)  [ROS Documentation](https://docs.ros.org/)  

---

## ¿Qué es ROS 2?
- **Definición:** Middleware para robótica que facilita la integración de sensores, actuadores, algoritmos y simuladores.  
- **Objetivo:** Proporcionar un entorno modular y escalable para construir robots complejos.  
- **Principales mejoras respecto a ROS 1:**
  - Basado en **DDS (Data Distribution Service)** para comunicación más robusta.  
  - **Soporte multiplataforma:** Linux, Windows, macOS.  
  - **Seguridad integrada:** autenticación y cifrado de mensajes.  
  - **Compatibilidad con tiempo real**, esencial en robótica industrial.  

---

## Cómo usar ROS 2
### 1. **Instalación**
- En Ubuntu (ejemplo con ROS 2 Humble):  
  ```bash
  sudo apt update
  sudo apt install ros-humble-desktop
  ```
- En Windows y macOS también existen instaladores oficiales.  

### 2. **Conceptos básicos**
- **Nodos:** Programas que realizan tareas específicas (ej. control de motores, lectura de sensores).  
- **Topics:** Canales de comunicación para publicar y suscribirse a mensajes.  
- **Servicios:** Comunicación síncrona (petición/respuesta).  
- **Acciones:** Para tareas largas (ej. mover un brazo robótico).  
- **Launch files:** Archivos para iniciar múltiples nodos y configuraciones.  

### 3. **Ejemplo simple**
Crear un nodo en Python que publique mensajes:
```python
import rclpy
from rclpy.node import Node
from std_msgs.msg import String

class PublisherNode(Node):
    def __init__(self):
        super().__init__('simple_publisher')
        self.publisher = self.create_publisher(String, 'chatter', 10)
        timer_period = 1.0
        self.timer = self.create_timer(timer_period, self.publish_message)

    def publish_message(self):
        msg = String()
        msg.data = 'Hola desde ROS 2'
        self.publisher.publish(msg)

def main(args=None):
    rclpy.init(args=args)
    node = PublisherNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()
```

Ejecutar con:
```bash
ros2 run my_package publisher_node
```

---

## Distribuciones ROS 2 (actuales y soporte)

| Distribución   | Tipo | Soporte hasta |
|----------------|------|---------------|
| **Lyrical Luth** | LTS | Mayo 2031 |
| **Jazzy Jalisco** | LTS | Mayo 2029 |
| **Humble Hawksbill** | LTS | Mayo 2027 |
| **Kilted Kaiju** | No LTS | Noviembre 2026 |
| **Rolling Ridley** | Rolling | Versión en desarrollo   [ROS Documentation](https://docs.ros.org/) |

---

## Consejos prácticos
- Empieza con una **distribución LTS** (ej. Humble o Jazzy) para mayor estabilidad.  
- Usa **colcon** para compilar paquetes y gestionar dependencias.  
- Integra ROS 2 con **Gazebo** para simulación de robots.  
- Explora paquetes populares como **Nav2** (navegación), **MoveIt 2** (manipulación) y **MAVROS** (drones).  

---

<br>

# SIMULACIÓN ROS 2, GAZEBO
Para simular un dron en **Gazebo**, lo más común es usarlo junto con **ROS (Robot Operating System)** y paquetes específicos que ya incluyen modelos de drones y controladores. Aquí tienes una guía clara y práctica:

---

## Pasos para simular un dron en Gazebo

### 1. **Instalar ROS y Gazebo**
- Si usas **ROS 2 Humble** (recomendado), instala Gazebo Sim:
  ```bash
  sudo apt update
  sudo apt install ros-humble-gazebo-ros-pkgs
  ```
- Esto te permitirá conectar ROS con Gazebo.

---

### 2. **Instalar un paquete de drones**
Los más usados son:
- **PX4 SITL + Gazebo**: Simulación de drones con el autopiloto PX4.
- **ArduPilot SITL + Gazebo**: Alternativa con soporte para ArduPilot.
- **TurtleBot3 + plugins de vuelo**: Para pruebas más simples.

Ejemplo con PX4:
```bash
git clone https://github.com/PX4/PX4-Autopilot.git --recursive
cd PX4-Autopilot
make px4_sitl gazebo
```

---

### 3. **Lanzar un mundo con un dron**
- PX4 trae modelos como el **Iris quadcopter**.
- Comando típico:
  ```bash
  make px4_sitl gazebo_iris
  ```
- Esto abre Gazebo con un dron Iris listo para simular.

---

### 4. **Controlar el dron**
- Puedes usar **QGroundControl** para enviar misiones y comandos.
- O bien, desde ROS:
  ```bash
  ros2 run mavros mavros_node
  ```
- Esto conecta ROS con MAVLink para controlar el dron.

---

### 5. **Sensores y plugins**
- Los drones simulados incluyen sensores como cámara, IMU, GPS y LIDAR.
- Puedes añadir plugins en el archivo **SDF/URDF** del modelo para personalizarlo.

---

<br>

# Px4
**PX4 Autopilot es un sistema de software de código abierto y hardware libre diseñado para controlar de manera autónoma vehículos no tripulados, principalmente drones (multirrotores, ala fija, VTOL). 
Sirve como el "cerebro" del dron, gestionando la estabilidad, navegación, telemetría y ejecución de misiones programadas o automáticas.**

<br>

# jMAVsim
**jMAVSim es un simulador ligero de drones desarrollado para trabajar con el autopiloto PX4. Está escrito en Java y permite probar el firmware en modo SITL (Software In The Loop) sin necesidad de un simulador 3D complejo como Gazebo.**  

---

## ¿Qué es jMAVSim?
- **Definición:** Simulador 2D/3D básico que emula la dinámica de vuelo de un dron multirrotor.  
- **Objetivo:** Probar el firmware PX4 en tu computadora, validar algoritmos de control y verificar comunicación con estaciones de control.  
- **Características principales:**
  - Simulación rápida y ligera, ideal para PCs con recursos limitados.  
  - Compatible con **PX4 SITL**.  
  - Genera telemetría y datos de sensores (GPS, IMU, barómetro).  
  - Se conecta vía **MAVLink** a estaciones de control como **QGroundControl**.  

---

## Cómo usar jMAVSim
### 1. **Instalación**
- Clona el repositorio de PX4:
  ```bash
  git clone https://github.com/PX4/PX4-Autopilot.git --recursive
  cd PX4-Autopilot
  ```
- Compila y lanza SITL con jMAVSim:
  ```bash
  make px4_sitl jmavsim
  ```

### 2. **Ejecutar la simulación**
- Al ejecutar el comando anterior, se abre una ventana con un dron virtual.  
- El dron puede controlarse desde **QGroundControl** o mediante comandos MAVLink.  

### 3. **Control del dron**
- Conecta QGroundControl para enviar misiones, armar el dron y despegar.  
- También puedes usar **MAVROS** en ROS 2 para enviar comandos desde scripts en Python o C++.  

### 4. **Configuración avanzada**
- Puedes modificar parámetros del dron en los archivos de configuración de PX4.  
- jMAVSim permite simular diferentes condiciones de vuelo (ej. viento, ruido en sensores).  

---

## Comparación jMAVSim vs Gazebo

| Aspecto              | jMAVSim | Gazebo |
|-----------------------|---------|--------|
| Complejidad           | Ligero, simple | Completo, realista |
| Recursos necesarios   | Bajos | Altos |
| Sensores simulados    | Básicos (GPS, IMU, barómetro) | Amplia variedad (cámaras, LIDAR, etc.) |
| Uso típico            | Pruebas rápidas de PX4 | Simulación avanzada de robots y drones |

---



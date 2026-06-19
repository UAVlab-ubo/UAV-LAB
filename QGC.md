> 07-05-2026 | 28-05-2026

**QGroundControl es un software de Estación Control Terrestre de código abierto, está diseñado para configurar, gestionar y pilotar drones autónomos o manuales.**

- Configuración completa de vehículos equipados con ArduPilot y PX4 Pro.
- Soporte de vuelo para vehículos que ejecutan PX4 y ArduPilot (o cualquier otro piloto automático que se comunique mediante el protocolo MAVLink).
- Planificación de misiones para vuelos autónomos.
- Visualización del mapa de vuelo que muestra la posición del vehículo, la trayectoria de vuelo, los puntos de referencia y los instrumentos del vehículo.
- Visor 3D que muestra el mapa 3D del entorno (archivo .osm OpenStreetMap), el modelo 3D del vehículo (solo multirrotores por el momento) y la trayectoria 3D de la misión (incluidos los puntos de referencia).
- Transmisión de vídeo con superposiciones en la pantalla de los instrumentos.
- Permite probar misiones, configurar parámetros y validar el comportamiento de drones sin riesgo físico, conectándose a simuladores como PX4 SITL (Software In The Loop) o Gazebo.
- Principalmente usa C++ y Qt QML como lenguajes de programación.
- QGC está diseñada para funcionar plataformas como Windows, MacOS, Linux y dispositivos iOS y Android.

### Misiones: 
Una misión es un plan de vuelo predefinido, que se puede planificar en QGroundControl y cargar en el controlador de vuelo, y luego ejecutar de forma autónoma en el modo Misión.
Las misiones suelen incluir tareas como el control del despegue, el vuelo a través de una secuencia de puntos de referencia, la captura de imágenes y/o vídeo, el despliegue de carga y el aterrizaje. 
QGroundControl permite planificar misiones de forma totalmente manual, o bien utilizar sus funciones más avanzadas para planificar estudios de terreno, de corredores o de estructuras.
Este tema ofrece una visión general de cómo planificar y llevar a cabo misiones.

### Planificación de misiones:
**Planificar misiones manualmente:** 
- Cambiar a la vista de misión.
- Seleccione el icono Agregar punto de referencia ("más") en la parte superior izquierda.
- Haz clic en el mapa para añadir puntos de referencia.
- Utilice la lista de puntos de referencia de la derecha para modificar los parámetros/tipo de los puntos de referencia. El indicador de altitud de la parte inferior proporciona una idea de la altitud relativa de cada punto de referencia.
- Una vez finalizado, haga clic en el botón Cargar (arriba a la derecha) para enviar la misión al vehículo.
- También puede utilizar la herramienta Patrones para automatizar la creación de cuadrículas de encuestas.

---

# QGroundControl
Comenzar con QGroundControl (QGC) y PX4 es un proceso sencillo. Simplemente instalas el software, conectas tu dron, actualizas el firmware, eliges el tipo de chasis y calibras los sensores principales. Completar estos pasos garantiza que tu dron esté listo para un primer vuelo seguro.

## 1. Configuración Inicial
  - Descargar QGC: Descarga e instala la aplicación QGroundControl para tu sistema operativo (Windows, macOS, Linux, Android o iOS).
  - Conectar: Conecta tu controlador de vuelo directamente a la computadora mediante USB (evita usar un concentrador o hub USB). QGC lo detectará y se conectará automáticamente.
## 2. Configuración Estándar
  - Firmware: Abre el menú de QGC (el icono "Q" arriba a la izquierda), ve a Vehicle Setup (Configuración del vehículo) y selecciona la pestaña Firmware. Desconecta y vuelve a conectar el controlador de vuelo cuando se te solicite para instalar automáticamente la última versión estable del firmware PX4.
  - Airframe (Chasis): Ve a la pestaña Airframe en Vehicle Setup. Selecciona el grupo general que coincida con tu dron (por ejemplo, Quadrotor x), elige el modelo específico, y haz clic en Apply and Restart (Aplicar y reiniciar).
## 3. Calibraciones Requeridas
  Ve a la pestaña Sensors (Sensores) en Vehicle Setup. Sigue las instrucciones en pantalla para calibrar estos componentes esenciales:
  - Acelerómetro: Sostén el dron completamente inmóvil en diferentes posiciones (por ejemplo, plano, de lado, invertido) según lo indiquen los cuadros de orientación rojos (incompletos) o amarillos y verdes (completos).
  - Brújula: Selecciona la pestaña de la brújula y gira lentamente el dron sobre sus tres ejes hasta que se complete la calibración.
## 4. Radio y Modos de Vuelo
  - Configuración de Radio: Conecta el receptor de radio control (RC) al controlador de vuelo, enciende tu transmisor y sigue el asistente de configuración de radio para calibrar las palancas y los interruptores.
  - Modos de Vuelo: En la pestaña Flight Modes, asigna interruptores de tu transmisor para activar modos específicos (por ejemplo, Position, Return to Land y Mission).

<br>


# Simulación de un dron y creación de un plan de misión en QGroundControl

## 1. Requisitos previos
- **QGroundControl** instalado en tu PC (Windows, Linux o macOS).
- **Simulador SITL** (PX4 o ArduPilot) ejecutándose en tu computadora.
- Conexión entre el simulador y QGroundControl vía **MAVLink**.

---

## 2. Conectar el simulador con QGroundControl
1. Inicia el simulador:
   - PX4 SITL con jMAVSim:
     ```bash
     make px4_sitl jmavsim
     ```
   - PX4 SITL con Gazebo:
     ```bash
     make px4_sitl gazebo
     ```
2. Abre **QGroundControl**.
3. Verifica que el dron virtual aparece conectado (telemetría en tiempo real).

---


## 3. Crear un plan de misión

1. En QGroundControl, selecciona la pestaña **Plan**.
2. Usa el mapa para añadir **waypoints**:
   - Haz clic en el mapa para colocar puntos de ruta.
   - Configura la altitud y tipo de acción (ej. tomar foto, esperar).
3. Opciones disponibles:
   - **Takeoff**: punto de despegue automático.
   - **Waypoint**: ruta intermedia con altitud definida.
   - **Loiter**: mantener posición en un área.
   - **Land**: aterrizaje automático.

---

## 4. Guardar y cargar planes
- Guarda tu misión en un archivo `.plan`:
  - Menú → **Guardar plan**.
- Puedes cargar planes existentes:
  - Menú → **Cargar plan**.

Ejemplo de archivo `.plan` (JSON simplificado):
```json
{
  "fileType": "Plan",
  "geoFence": { "version": 1 },
  "mission": {
    "items": [
      { "command": 22, "frame": 3, "params": [0,0,0,0,47.397,8.545,10] },
      { "command": 16, "frame": 3, "params": [0,0,0,0,47.398,8.546,20] },
      { "command": 21, "frame": 3, "params": [0,0,0,0,47.399,8.547,0] }
    ],
    "version": 2
  },
  "rallyPoints": { "version": 1 },
  "version": 1
}
```

---

## 5. Ejecutar la misión
1. Cambia a la pestaña **Fly** en QGroundControl.
2. Arma el dron virtual.
3. Selecciona **Start Mission**.
4. Observa cómo el dron sigue la ruta definida en el mapa.

---

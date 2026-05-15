
# 
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

Pixhawk 6X → Controlador de vuelo

# 
**PX4 Autopilot es un sistema de software de código abierto y hardware libre diseñado para controlar de manera autónoma vehículos no tripulados, principalmente drones (multirrotores, ala fija, VTOL). 
Sirve como el "cerebro" del dron, gestionando la estabilidad, navegación, telemetría y ejecución de misiones programadas o automáticas.**

https://docs.px4.io/main/en/getting_started/px4_basic_concepts#what-is-a-drone

Dron → vehiculo "robótico" controlado de forma manual o autónoma.
Comandos de enlace mediante el protocolo de comunicación MAVLink.

> **Misiones**

Una misión es un plan de vuelo predefinido, que se puede planificar en QGroundControl y cargar en el controlador de vuelo, y luego ejecutar de forma autónoma en el modo Misión .
Las misiones suelen incluir tareas como el control del despegue, el vuelo a través de una secuencia de puntos de referencia, la captura de imágenes y/o vídeo, el despliegue de carga y el aterrizaje. QGroundControl permite planificar misiones de forma totalmente manual, o bien utilizar sus funciones más avanzadas para planificar estudios de terreno, de corredores o de estructuras.
Este tema ofrece una visión general de cómo planificar y llevar a cabo misiones.

> **Planificación de misiones**

Planificar misiones manualmente:
Cambiar a la vista de misión.
Seleccione el icono Agregar punto de referencia ("más") en la parte superior izquierda.
Haz clic en el mapa para añadir puntos de referencia.
Utilice la lista de puntos de referencia de la derecha para modificar los parámetros/tipo de los puntos de referencia. El indicador de altitud de la parte inferior proporciona una idea de la altitud relativa de cada punto de referencia.
Una vez finalizado, haga clic en el botón Cargar (arriba a la derecha) para enviar la misión al vehículo.
También puede utilizar la herramienta Patrones para automatizar la creación de cuadrículas de encuestas.
# 
> https://github.com/mavlink/qgroundcontrol/releases

> https://github.com/mavlink/qgroundcontrol/tree/master

> https://youtu.be/0d23O_RUOmI?si=9JsQlUaAFN7_gw0_

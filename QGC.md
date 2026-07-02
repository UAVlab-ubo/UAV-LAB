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

## 2. Compilar PX4 SITL con QGroundControl

```bash
cd ~/PX4-Autopilot
# compilar y lanzar con Ignition/Gazebo para un airframe (ejemplo x500)
make px4_sitl gz_x500 -j$(nproc)
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





# Enlace SiK 915 MHz

Enlace SiK 915 MHz para Drones

## 1. Introducción

El enlace **SiK 915 MHz** es uno de los sistemas de telemetría más utilizados en drones basados en PX4, ArduPilot y otros autopilotos compatibles con **MAVLink**. Su función principal es proporcionar un canal de comunicación bidireccional entre el dron y la estación terrestre, permitiendo enviar comandos, recibir datos de vuelo y monitorear el estado del vehículo en tiempo real.

Este documento explica su funcionamiento, características, configuración, recomendaciones y buenas prácticas.

## 2. ¿Qué es un enlace SiK?

El término **SiK** se refiere al firmware open‑source utilizado en radios de telemetría basados en los chips **HopeRF RFM22/23** o equivalentes. Estos módulos operan en bandas **ISM**, siendo **915 MHz** la más común en América.

Los radios SiK se componen de:

- Un módulo **USB** para la estación terrestre.
- Un módulo **TTL/UART** para el autopiloto.
- Firmware SiK con soporte para MAVLink.
- Antenas omnidireccionales o direccionales según el caso.

## 3. Características principales

- **Frecuencia:** 902–928 MHz (banda ISM).
- **Potencia típica:** 100 mW (20 dBm), aunque existen versiones de mayor potencia.
- **Modulación:** GFSK.
- **Protocolos:** MAVLink, con soporte para corrección de errores (ECC).
- **Técnicas de robustez:** FHSS (Frequency Hopping Spread Spectrum).
- **Velocidad aérea:** 64–250 kbps según configuración.
- **Alcance:** 300–500 m con antenas estándar; varios kilómetros con antenas de alta ganancia.

## 4. Arquitectura del sistema

[Ground Station] ←USB→ [Radio SiK] ⇆ (915 MHz) ⇆ [Radio SiK] ←UART→ [Autopiloto]

- El PC detecta el módulo SiK como **puerto COM.**
- Mission Planner o QGroundControl se comunican por MAVLink.
- El enlace RF transmite telemetría y comandos.

**Importante:** El enlace SiK funciona en **Windows**, no dentro de WSL2.

## 5. Conexión física

### 5.1 En la estación terrestre

- Conectar el módulo SiK USB al PC.
- Windows asignará un puerto COM.

### 5.2 En el dron

Conectar el módulo SiK al puerto **TELEM1/TELEM2** del autopiloto:

- TX ↔ RX
- RX ↔ TX
- 5V
- GND

Usualmente con conector **JST‑GH de 6 pines.**

## 6. Configuración del enlace SiK

La configuración se realiza desde Mission Planner o QGroundControl.

### 6.1 Parámetros comunes

- **Baud Rate:** 57 600 o 115 200.
- **Air Speed:** 64–250 kbps.
- **Net ID:** Identificador de red para evitar interferencias.
- **TX Power:** Potencia de transmisión.
- **ECC:** Corrección de errores.
- **LBT:** Listen Before Talk (según región).
- **FHSS:** Hopping para robustez.

### 6.2 Proceso de configuración

- Abrir Mission Planner.
- Ir a Initial Setup → Sik Radio.
- Seleccionar el puerto COM.
- Leer parámetros.
- Ajustar valores.
- Escribir configuración.

## 7. Regulación y aspectos legales

La banda 915 MHz es ISM en América, pero cada país tiene límites de potencia.

En Chile:

- Banda 902–928 MHz permitida.
- Límites de potencia según SUBTEL.
- Evitar módulos de 1W sin certificación.

## 8. Alcance y rendimiento

El alcance depende de:

- Potencia del módulo.
- Ganancia de antenas.
- Línea de vista.
- Interferencias.
- Altura de las antenas.
  
Valores típicos
| Condición | Alcance aproximado |
|---|---|
| Antenas estándar 2 dBi | 300–500 m |
| Antena direccional en estación | 1–3 km |
| Condiciones ideales | 5+ km |

## 9. Buenas prácticas

- Mantener **línea de vista.**
- Usar antenas de calidad.
- Configurar **Net ID** único.
- No usar potencias ilegales.
- Probar **RSSI** antes del vuelo.
- Activar **failsafe** en el autopiloto.

## 10. Limitaciones

- No posee cifrado nativo.
- Sensible a interferencias urbanas.
- No apto para control crítico (solo telemetría).
- No funciona dentro de WSL2.

## 11. Alternativas al SiK

- Enlaces **Herelink** (2.4 GHz, video + telemetría).
- Enlaces **RFD900x** (915 MHz, largo alcance).
- Telemetría por **WiFi.**
- Telemetría por **4G/LTE.**

## 12. Conclusión

El enlace **SiK 915 MHz** es una solución confiable, económica y ampliamente compatible para telemetría MAVLink en drones. Su facilidad de uso, robustez y disponibilidad lo convierten en una excelente opción para proyectos personales, investigación y operaciones de corto a mediano alcance.

Para vuelos reales, se recomienda validar la configuración, revisar la regulación local y realizar pruebas de campo progresivas.

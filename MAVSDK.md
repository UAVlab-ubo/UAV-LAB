> 02-07-2026 || 09-07-2026
# Crear misión con MAVSDK

---

# 1. Instalar MAVSDK-Python para controlar dron

---
**Prerrequisitos**
- **Python 3.6+:**
  Si no sabes la versión de python:
  ```
  python --version
  ```
  o usa:
  ```
  python3 --version
  ```
- Una instancia de SITL en ejecución (en este caso gazebo 6.18)

## 1. Instalación limpia en un virtualenv (recomendado)
En **Terminal A**:

```bash
# crear y activar venv
python3 -m venv ~/mavsdk-venv
source ~/mavsdk-venv/bin/activate

# actualizar pip e instalar
pip install --upgrade pip
pip install mavsdk aioconsole
```

Verifica instalación:  
```bash
python -c "import pkg_resources; print(pkg_resources.get_distribution('mavsdk').version)"
```

Si esto imprime un número (por ejemplo `3.15.3`), **tu instalación está perfecta**.

---

## 2. Confirmar que MAVSDK‑Python funciona realmente
Ejecuta un script mínimo que solo importa MAVSDK:

```bash
python - << 'EOF'
from mavsdk import System
print("MAVSDK importado correctamente")
EOF
```

Si imprime eso, **todo está bien**.

---

## 3. Verificar que MAVSDK se comunica con PX4 SITL 
Antes de avanzar a misiones, OFFBOARD y MAVLink, debemos confirmar que:

1. PX4 SITL está enviando MAVLink por UDP 14540  
2. MAVSDK está recibiendo esos mensajes

Para eso, en **Terminal B (PX4 SITL)**:

```
make px4_sitl gz_x500
```

Y en **Terminal A (venv activado)**:

```bash
python - << 'EOF'
import asyncio
from mavsdk import System

async def main():
    drone = System()
    await drone.connect(system_address="udpin://0.0.0.0:14540")

    print("Esperando conexión...")
    async for state in drone.core.connection_state():
        print("Estado:", state)
        if state.is_connected:
            print("PX4 conectado correctamente a MAVSDK")
            break

asyncio.run(main())
EOF
```

Si aparece **PX4 conectado correctamente**, ya estamos listos para misiones y OFFBOARD.
Si **PX4 SITL ya está corriendo** y **MAVSDK‑Python ya se conectó**, entonces ya tenemos la base lista.

---

# 2. Escribir misiones con MAVSDK-Python

---

## ¿Qué es una misión en PX4/MAVSDK?
Una **misión** es una lista ordenada de *MissionItems* que PX4 ejecuta automáticamente:

- Waypoints (lat, lon, alt)  
- Velocidad deseada  
- Comportamientos (hover, take photo, etc.)  
- Comandos NAV (NAV_TAKEOFF, NAV_WAYPOINT, NAV_LAND)

MAVSDK te permite **crear, subir y ejecutar** misiones sin tocar QGroundControl.

---

## 1. Crear archivo de misión

En **Terminal A (WSL2, con tu venv activado)**:

```
cd ~
nano mission_raw_auto.py
```

Pega este código completo, ya adaptado para SITL y Gazebo:
```
#!/usr/bin/env python3
import asyncio
from mavsdk import System
from mavsdk import mission_raw
from mavsdk.action import ActionError
from mavsdk.telemetry import LandedState


# ---------------------------
# Esperar a que la misión RAW termine
# ---------------------------
async def wait_until_mission_finished(drone):
    async for progress in drone.mission_raw.mission_progress():
        print(f"Progreso misión RAW: {progress.current}/{progress.total}")
        if progress.current == progress.total:
            print("Misión RAW completada")
            return


# ---------------------------
# Esperar a que PX4 confirme que está en el suelo
# ---------------------------
async def wait_until_landed(drone):
    async for ls in drone.telemetry.landed_state():
        print(f"LandedState: {ls}")
        if ls == LandedState.ON_GROUND:
            print("PX4 reporta ON_GROUND")
            return


# ---------------------------
# SCRIPT PRINCIPAL
# ---------------------------
async def main():
    drone = System()
    await drone.connect(system_address="udpin://0.0.0.0:14540")

    print("Esperando conexión...")
    async for state in drone.core.connection_state():
        if state.is_connected:
            print("PX4 conectado")
            break

    # --- LIMPIAR ESTADO LAND ---
    print("Forzando HOLD...")
    try:
        await drone.action.hold()
        await asyncio.sleep(1)
        print("HOLD activado")
    except Exception as e:
        print(f"No se pudo activar HOLD: {e}")

    # --- CHEQUEAR ARMADO ---
    async for armed in drone.telemetry.armed():
        already_armed = armed
        print(f"Estado armado inicial: {armed}")
        break

    if not already_armed:
        print("Armando...")
        try:
            await drone.action.arm()
            print("Armado correctamente")
        except ActionError as e:
            print(f"ARM falló: {e}")
            return
    else:
        print("Ya estaba armado")

    # --- DESPEGAR ---
    print("Despegando...")
    await drone.action.takeoff()
    await asyncio.sleep(5)

    # --- SUBIR MISIÓN RAW ---
    print("Subiendo misión RAW...")
    mission_items = []

    mission_items.append(
        mission_raw.MissionItem(
            0, 3, 16, 1, 1,
            0, 10, 0, 0,
            int(47.398170 * 1e7),
            int(8.545649 * 1e7),
            10.0,
            0
        )
    )

    mission_items.append(
        mission_raw.MissionItem(
            1, 3, 16, 0, 1,
            0, 10, 0, 0,
            int(47.398241 * 1e7),
            int(8.545593 * 1e7),
            10.0,
            0
        )
    )

    await drone.mission_raw.upload_mission(mission_items)
    print("Misión RAW subida")

    # --- INICIAR MISIÓN ---
    print("Iniciando misión RAW...")
    await drone.mission_raw.start_mission()

    # --- ESPERAR A QUE LA MISIÓN TERMINE REALMENTE ---
    print("Esperando finalización real de misión...")
    await wait_until_mission_finished(drone)

    # --- ATERRIZAR ---
    print("Aterrizando...")
    await drone.action.land()

    # --- ESPERAR A QUE PX4 CONFIRME ATERRIZAJE ---
    await wait_until_landed(drone)

    # --- DESARMAR ---
    print("Desarmando...")
    try:
        await drone.action.disarm()
        print("Desarmado correctamente")
    except ActionError as e:
        print(f"Error al desarmar: {e}")

    # --- VOLVER A HOLD ---
    print("Volviendo a HOLD...")
    try:
        await drone.action.hold()
        print("HOLD activado")
    except Exception as e:
        print(f"No se pudo activar HOLD: {e}")

    print("Script finalizado sin errores.")


asyncio.run(main())
```
Guarda con **CTRL+O**, Enter, y sal con **CTRL+X**.

---

## 2. Ejecutar la misión

En **Terminal A (WSL2, venv activado)**:

```bash
python mission_raw_auto.py
```

En **Terminal B (PX4 SITL)** deberías ver:

```
INFO [commander] Takeoff detected
INFO [navigator] Mission starting
```

Y en **Gazebo** verás el dron despegar y seguir los waypoints.

---

## ¿Qué aprendiste aquí?
- Cómo crear MissionItems  
- Cómo subir MissionPlan  
- Cómo iniciar misión  
- Cómo monitorear progreso  
- Cómo interactúa MAVSDK con PX4 SITL  

---

# 3. Control OFFBOARD

## ¿Qué es OFFBOARD?
OFFBOARD = **control directo por comandos MAVLink enviados desde tu script**.

PX4 exige:

### **Un flujo continuo de setpoints (≥ 2 Hz)**  
Si dejas de enviar setpoints → PX4 **sale de OFFBOARD automáticamente** por seguridad.

### **Un setpoint válido ANTES de activar OFFBOARD**
Si intentas activar OFFBOARD sin haber enviado setpoints →  
PX4 responde **COMMAND_DENIED**.

---

# Ejemplo OFFBOARD mínimo (posición)

En **Terminal A**:

```bash
nano offboard_demo.py
```

Pega:

```python
import asyncio
from mavsdk import System
from mavsdk.offboard import OffboardError, PositionNedYaw
from mavsdk.action import ActionError
from mavsdk.telemetry import LandedState

async def wait_until_landed(drone):
    async for ls in drone.telemetry.landed_state():
        if ls == LandedState.ON_GROUND:
            print("PX4 reporta ON_GROUND")
            return

async def main():
    drone = System()
    await drone.connect(system_address="udpin://0.0.0.0:14540")

    print("Esperando conexión...")
    async for state in drone.core.connection_state():
        if state.is_connected:
            print("PX4 conectado")
            break

    print("Esperando health flags...")
    async for health in drone.telemetry.health():
        if health.is_home_position_ok and health.is_local_position_ok:
            print("PX4 listo para armar")
            break

    # --- LIMPIAR ESTADO LAND ---
    print("Forzando HOLD para limpiar estado LAND...")
    try:
        await drone.action.hold()
        await asyncio.sleep(1)
        print("HOLD activado")
    except Exception as e:
        print(f"No se pudo activar HOLD: {e}")

    # --- CHEQUEAR ARMADO ---
    async for armed in drone.telemetry.armed():
        already_armed = armed
        print(f"Estado armado inicial: {armed}")
        break

    if not already_armed:
        print("Armando...")
        try:
            await drone.action.arm()
            print("Armado correcto")
        except ActionError as e:
            print(f"ARM falló: {e}")
            return
    else:
        print("Ya estaba armado")

    # --- PRIMER SETPOINT ---
    print("Enviando primer setpoint...")
    await drone.offboard.set_position_ned(PositionNedYaw(0, 0, -1, 0))

    # --- ACTIVAR OFFBOARD ---
    print("Activando OFFBOARD...")
    try:
        await drone.offboard.start()
        print("OFFBOARD activado")
    except OffboardError as e:
        print(f"Error al activar OFFBOARD: {e._result.result}")
        return

    # --- MOVIMIENTOS ---
    print("Moviendo 5 m hacia adelante...")
    await drone.offboard.set_position_ned(PositionNedYaw(5, 0, -1, 0))
    await asyncio.sleep(5)

    print("Moviendo 5 m hacia la derecha...")
    await drone.offboard.set_position_ned(PositionNedYaw(5, 5, -1, 0))
    await asyncio.sleep(5)

    # --- SALIR DE OFFBOARD ---
    print("Finalizando OFFBOARD...")
    await drone.offboard.stop()
    await asyncio.sleep(1)

    # --- ATERRIZAR ---
    print("Aterrizando...")
    await drone.action.land()

    # --- ESPERAR A QUE PX4 CONFIRME ATERRIZAJE ---
    await wait_until_landed(drone)

    # --- DESARMAR ---
    print("Desarmando...")
    try:
        await drone.action.disarm()
        print("Desarmado correctamente")
    except ActionError as e:
        print(f"Error al desarmar: {e}")

    # --- VOLVER A HOLD ---
    print("Volviendo a HOLD...")
    try:
        await drone.action.hold()
        print("HOLD activado")
    except Exception as e:
        print(f"No se pudo activar HOLD: {e}")

    print("Script finalizado sin errores.")

asyncio.run(main())
```

Ejecuta:

```bash
python offboard_demo.py
```

---

## ¿Qué aprendiste aquí?
- Por qué OFFBOARD exige flujo continuo  
- Cómo enviar setpoints  
- Cómo activar OFFBOARD correctamente  
- Cómo mover el dron en NED (North-East-Down)

---

# Modelo MAVLink

Este bloque explica cómo funciona MAVLink internamente, cómo PX4 interpreta los mensajes enviados por MAVSDK, y por qué ciertos modos como OFFBOARD y AUTO.MISSION requieren secuencias específicas. Es el fundamento para desarrollar software de vuelo autónomo.

---

## 1. ¿Qué es MAVLink?

MAVLink es un protocolo de mensajería binario utilizado por autopilotos como PX4 para intercambiar información con estaciones terrestres, simuladores y controladores externos.  
Cada mensaje MAVLink contiene:

- Identificador del mensaje  
- Payload con datos específicos  
- Identificador del sistema (system_id)  
- Identificador del componente (component_id)  
- Checksum  

PX4 utiliza MAVLink para:

- Enviar telemetría  
- Recibir comandos de vuelo  
- Ejecutar misiones  
- Recibir setpoints externos (modo OFFBOARD)  
- Comunicar estado del sistema  

MAVSDK es una capa de alto nivel que abstrae el envío y recepción de mensajes MAVLink.

---

## 2. Heartbeat

PX4 envía un mensaje HEARTBEAT cada 1 Hz.  
Este mensaje indica:

- Tipo de vehículo  
- Autopiloto (PX4)  
- Modo de vuelo actual  
- Estado del sistema  

MAVSDK detecta el heartbeat y reporta la conexión mediante:

```python
state.is_connected
```

Si el heartbeat se detiene, PX4 reporta pérdida de enlace con la estación terrestre.  
El heartbeat es fundamental para que MAVSDK sepa que PX4 está activo y disponible.

---

## 3. COMMAND_LONG y COMMAND_ACK

Las acciones de alto nivel enviadas desde MAVSDK se traducen en mensajes MAVLink del tipo COMMAND_LONG.  
Ejemplos:

| Acción MAVSDK | Comando MAVLink |
|---------------|------------------|
| arm() | MAV_CMD_COMPONENT_ARM_DISARM |
| takeoff() | MAV_CMD_NAV_TAKEOFF |
| land() | MAV_CMD_NAV_LAND |
| start_mission() | MAV_CMD_MISSION_START |
| offboard.start() | MAV_CMD_DO_SET_MODE (OFFBOARD) |

Cada COMMAND_LONG debe recibir una respuesta COMMAND_ACK desde PX4.  
El ACK contiene:

- El comando original  
- Resultado (ACEPTADO, DENEGADO, FALLIDO, NO SOPORTADO)  

MAVSDK interpreta el ACK y lo expone como excepciones o resultados Python.

---

## 4. Ciclo de misión RAW (request/ack)

Las misiones RAW siguen el protocolo MAVLink puro.  
La secuencia completa es:

1. MAVSDK envía `MISSION_COUNT` indicando cuántos items tiene la misión.  
2. PX4 solicita el primer item con `MISSION_REQUEST_INT(seq=0)`.  
3. MAVSDK envía `MISSION_ITEM_INT(seq=0)`.  
4. PX4 solicita el siguiente item con `MISSION_REQUEST_INT(seq=1)`.  
5. MAVSDK envía `MISSION_ITEM_INT(seq=1)`.  
6. El proceso continúa hasta completar todos los items.  
7. PX4 envía `MISSION_ACK` indicando que la misión fue cargada correctamente.

Si esta secuencia se interrumpe, la misión no se carga y PX4 no la ejecutará.

---

## 5. OFFBOARD a nivel MAVLink

OFFBOARD es el modo donde PX4 recibe comandos externos de control.  
Estos comandos se envían como mensajes MAVLink de setpoints:

- SET_POSITION_TARGET_LOCAL_NED  
- SET_VELOCITY_NED  
- SET_ATTITUDE_TARGET  
- SET_ACTUATOR_CONTROL_TARGET  

### Requisitos del modo OFFBOARD

1. **Debe enviarse al menos un setpoint antes de activar OFFBOARD.**  
   Si no se envía un setpoint previo, PX4 responde con COMMAND_DENIED.

2. **Debe mantenerse un flujo continuo de setpoints.**  
   PX4 exige una frecuencia mínima de 2 Hz, idealmente entre 20 y 50 Hz.

3. **Si el flujo se detiene por más de 0.5 segundos, PX4 abandona OFFBOARD.**  
   El autopiloto cambia automáticamente a HOLD por seguridad.

OFFBOARD no es un modo persistente.  
Es un modo dependiente del flujo de comandos externos.

---

## 6. Diagramas de flujo MAVLink

### 6.1 Flujo de misión RAW

```
MAVSDK → MISSION_COUNT
PX4 → MISSION_REQUEST_INT(seq=0)
MAVSDK → MISSION_ITEM_INT(seq=0)
PX4 → MISSION_REQUEST_INT(seq=1)
MAVSDK → MISSION_ITEM_INT(seq=1)
...
PX4 → MISSION_ACK
PX4 → Cambio a AUTO.MISSION
PX4 → Ejecución de waypoints
```

---

### 6.2 Flujo OFFBOARD

```
MAVSDK → SET_POSITION_TARGET_LOCAL_NED (primer setpoint)
MAVSDK → COMMAND_LONG (SET_MODE: OFFBOARD)
PX4 → COMMAND_ACK (ACCEPTED)
MAVSDK → SET_POSITION_TARGET_LOCAL_NED (20–50 Hz)
PX4 → Control externo activo
```

Si el flujo se detiene:

```
PX4 → Offboard lost → HOLD
```

---

### 6.3 Flujo de armado y despegue

```
MAVSDK → COMMAND_LONG (ARM)
PX4 → COMMAND_ACK (ACCEPTED)
MAVSDK → COMMAND_LONG (NAV_TAKEOFF)
PX4 → COMMAND_ACK (ACCEPTED)
PX4 → Takeoff detected
```

---

## 7. Buenas prácticas MAVSDK/PX4

1. No activar OFFBOARD sin enviar un setpoint previo.  
2. No detener el flujo de setpoints durante OFFBOARD.  
3. No mezclar misión RAW con OFFBOARD sin cambiar explícitamente de modo.  
4. Convertir latitud y longitud a enteros multiplicados por 1e7 en misiones RAW.  
5. Comprender el sistema de coordenadas NED (North-East-Down) para OFFBOARD.  
6. No activar OFFBOARD si PX4 reporta errores del EKF2.  
7. Siempre esperar el ACK de cada COMMAND_LONG.  
8. En simulación, desactivar chequeos EKF2 si bloquean el armado.  
9. Mantener frecuencias de envío de setpoints entre 20 y 50 Hz para control estable.  
10. No asumir que PX4 ejecutará una misión si no se ha armado y despegado correctamente.

---




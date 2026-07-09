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

# PARTE 1 — ESCRIBIR MISIONES CON MAVSDK‑PYTHON 

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

# ¿Qué aprendiste aquí?
- Cómo crear MissionItems  
- Cómo subir MissionPlan  
- Cómo iniciar misión  
- Cómo monitorear progreso  
- Cómo interactúa MAVSDK con PX4 SITL  

---

# PARTE 2 — CONTROL OFFBOARD  

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

# 🧠 ¿Qué aprendiste aquí?
- Por qué OFFBOARD exige flujo continuo  
- Cómo enviar setpoints  
- Cómo activar OFFBOARD correctamente  
- Cómo mover el dron en NED (North-East-Down)

---

# 🚀 PARTE 3 — MODELO MAVLINK  
*(Heartbeat, COMMAND_LONG, ACK, request/ack)*

## ❤️ Heartbeat
PX4 envía un heartbeat MAVLink cada 1 Hz.  
MAVSDK lo interpreta automáticamente → por eso `connection_state.is_connected` funciona.

## 🧩 COMMAND_LONG
Es el mensaje MAVLink para comandos como:

- ARM  
- DISARM  
- TAKEOFF  
- LAND  
- Cambiar modos de vuelo  
- Comandos de cámara  
- Comandos de misión RAW

MAVSDK lo abstrae con:

- `drone.action.arm()`  
- `drone.action.takeoff()`  
- `drone.offboard.start()`  
- etc.

## 🔁 Ciclo request/ack
Cada comando MAVLink tiene:

1. **REQUEST** → enviado por MAVSDK  
2. **ACK** → enviado por PX4  
3. MAVSDK interpreta el ACK y te da un resultado Python

Ejemplo:

```python
await drone.action.arm()
```

Internamente envía:

```
COMMAND_LONG (ARM)
```

PX4 responde:

```
COMMAND_ACK (ARM, ACCEPTED)
```

---

# 🎯 ¿Qué quieres que hagamos ahora?

Puedo continuar con:

### 1️⃣ Misiones avanzadas  
- Loiter  
- Take photo  
- Mission RAW  
- Cambiar velocidad en vuelo  
- Añadir comandos NAV complejos

### 2️⃣ OFFBOARD avanzado  
- Control de velocidad  
- Control de actitud  
- Control de aceleración  
- Trayectorias suaves  
- Control con PID externo

### 3️⃣ MAVLink RAW  
- Enviar COMMAND_LONG manual  
- Enviar mensajes MAVLink personalizados  
- Leer mensajes MAVLink directamente  
- Crear tu propio autopiloto externo

Solo dime **qué módulo quieres ahora** y lo desarrollamos con código completo y explicación profunda.

































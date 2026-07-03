**Resumen breve y directo:** **Desinstala `mavsdk` en WSL2, reinstálalo en un entorno virtual (venv), arranca PX4 SITL + Gazebo en WSL2 y usa los ejemplos `mission.py` / `mission_raw.py` de MAVSDK‑Python para escribir y subir misiones por código.** Los pasos abajo indican exactamente qué terminal usar y comandos a ejecutar.   [mavsdk.mavlink.io](https://mavsdk.mavlink.io/develop/en/python/quickstart.html)  [docs.px4.io](https://docs.px4.io/main/en/dev_setup/dev_env_windows_wsl)

### 1. Preparación: qué terminales usar
- **Terminal A (WSL2 Ubuntu 22.04)** — para instalar/desinstalar Python, pip, crear venv, instalar MAVSDK‑Python y ejecutar scripts Python.  
- **Terminal B (WSL2 Ubuntu 22.04)** — para compilar/ejecutar PX4 SITL (make px4_sitl gz_x500).  
- **Terminal C (opcional, VSCode integrada)** — REPL interactivo o depuración; puedes abrir una terminal WSL integrada en VSCode y usarla como A o B.   [docs.px4.io](https://docs.px4.io/main/en/dev_setup/dev_env_windows_wsl)

---

### 2. Desinstalar todo lo relacionado con MAVSDK‑Python (sin tocar otros archivos)
En **Terminal A** (WSL2):

```bash
# 1) desinstalar paquetes pip
pip3 uninstall -y mavsdk aioconsole

# 2) localizar posibles restos en site-packages y eliminarlos con cuidado
python3 -c "import site,sys,os; print('\\n'.join(site.getsitepackages()+[site.getusersitepackages()]))"
# luego inspecciona las rutas listadas y borra solo carpetas relacionadas:
rm -rf ~/.local/lib/python3.*/site-packages/mavsdk*
sudo rm -rf /usr/local/lib/python3.*/dist-packages/mavsdk*
```

**Importante:** inspecciona manualmente las rutas antes de `rm -rf` para no borrar paquetes no relacionados.  

---

### 3. Reinstalación limpia en un virtualenv (recomendado)
En **Terminal A**:

```bash
# crear y activar venv
python3 -m venv ~/mavsdk-venv
source ~/mavsdk-venv/bin/activate

# actualizar pip y reinstalar
pip install --upgrade pip
pip install mavsdk aioconsole
```

Verifica instalación:  
```bash
python -c "import pkg_resources; print(pkg_resources.get_distribution('mavsdk').version)"
```

Si esto imprime un número (por ejemplo `3.15.3`), **tu instalación está perfecta**.

---

## ✅ 2. Confirmar que MAVSDK‑Python funciona realmente
Ejecuta un script mínimo que solo importa MAVSDK:

```bash
python - << 'EOF'
from mavsdk import System
print("MAVSDK importado correctamente")
EOF
```

Si imprime eso, **todo está bien**.

---

## ⚠️ 3. ¿Quieres que verifiquemos que MAVSDK se comunica con PX4 SITL?  
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
Ahora sí podemos entrar en lo que realmente querías: **misiones, OFFBOARD y MAVLink**, con explicaciones profundas y ejemplos ejecutables en tu entorno WSL2.

Voy a empezar por **MISIÓN**, porque es el flujo más sencillo y te prepara para OFFBOARD y MAVLink RAW.

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

# ✅ PASO 1 — Crear archivo de misión

En **Terminal A (WSL2, con tu venv activado)**:

```
cd ~
nano mission_raw_demo.py
```
Pega este código completo, ya adaptado para SITL y Gazebo:
```
#!/usr/bin/env python3
import asyncio
from mavsdk import System
from mavsdk import mission_raw

async def px4_connect_drone():
    drone = System()
    await drone.connect(system_address="udpin://0.0.0.0:14540")

    print("Esperando conexión...")
    async for state in drone.core.connection_state():
        if state.is_connected:
            print("-- PX4 conectado a MAVSDK")
            return drone

async def run():
    drone = await px4_connect_drone()
    await run_drone(drone)

async def run_drone(drone):
    mission_items = []

    # Waypoint 1
    mission_items.append(
        mission_raw.MissionItem(
            0,   # seq
            3,   # frame (MAV_FRAME_GLOBAL_RELATIVE_ALT_INT)
            16,  # command (MAV_CMD_NAV_WAYPOINT)
            1,   # current (1 = first/current)
            1,   # autocontinue
            0,   # param1 (hold time)
            10,  # param2 (acceptance radius)
            0,   # param3 (pass radius)
            0,   # param4 (yaw)
            int(47.398170 * 10**7),  # x: lat * 1e7
            int(8.545649 * 10**7),   # y: lon * 1e7
            10.0,                    # z: alt (m)
            0    # mission_type
        )
    )

    # Waypoint 2
    mission_items.append(
        mission_raw.MissionItem(
            1,
            3,
            16,
            0,
            1,
            0,
            10,
            0,
            0,
            int(47.398241 * 10**7),
            int(8.545593 * 10**7),
            10.0,
            0
        )
    )

    print("-- Subiendo misión RAW")
    await drone.mission_raw.upload_mission(mission_items)
    print("-- Misión RAW subida correctamente")

if __name__ == "__main__":
    asyncio.run(run())

```
Guarda con **CTRL+O**, Enter, y sal con **CTRL+X**.

---

# ✅ PASO 2 — Ejecutar la misión

En **Terminal A (WSL2, venv activado)**:

```bash
python mission_raw_demo.py
```

En **Terminal B (PX4 SITL)** deberías ver:

```
INFO [commander] Takeoff detected
INFO [navigator] Mission starting
```

Y en **Gazebo** verás el dron despegar y seguir los waypoints.

---

# 🧩 ¿Qué aprendiste aquí?
- Cómo crear MissionItems  
- Cómo subir MissionPlan  
- Cómo iniciar misión  
- Cómo monitorear progreso  
- Cómo interactúa MAVSDK con PX4 SITL  

---

# 🚀 PARTE 2 — CONTROL OFFBOARD  
*(Aquí empieza lo interesante)*

## 🧠 Concepto profundo: ¿Qué es OFFBOARD?
OFFBOARD = **control directo por comandos MAVLink enviados desde tu script**.

PX4 exige:

### 🔥 **Un flujo continuo de setpoints (≥ 2 Hz)**  
Si dejas de enviar setpoints → PX4 **sale de OFFBOARD automáticamente** por seguridad.

### 🔥 **Un setpoint válido ANTES de activar OFFBOARD**
Si intentas activar OFFBOARD sin haber enviado setpoints →  
PX4 responde **COMMAND_DENIED**.

---

# 🧪 Ejemplo OFFBOARD mínimo (posición)

En **Terminal A**:

```bash
nano offboard_demo.py
```

Pega:

```python
import asyncio
from mavsdk import System
from mavsdk.offboard import (OffboardError, PositionNedYaw)

async def main():
    drone = System()
    await drone.connect(system_address="udpin://0.0.0.0:14540")

    print("Esperando conexión...")
    async for state in drone.core.connection_state():
        if state.is_connected:
            print("PX4 conectado")
            break

    print("Armando...")
    await drone.action.arm()

    print("Enviando primer setpoint...")
    await drone.offboard.set_position_ned(PositionNedYaw(0, 0, -1, 0))

    print("Activando OFFBOARD...")
    try:
        await drone.offboard.start()
        print("OFFBOARD activado")
    except OffboardError as e:
        print(f"Error al activar OFFBOARD: {e._result.result}")
        return

    print("Moviendo 5 m hacia adelante...")
    await drone.offboard.set_position_ned(PositionNedYaw(5, 0, -1, 0))
    await asyncio.sleep(5)

    print("Moviendo 5 m hacia la derecha...")
    await drone.offboard.set_position_ned(PositionNedYaw(5, 5, -1, 0))
    await asyncio.sleep(5)

    print("Finalizando OFFBOARD...")
    await drone.offboard.stop()

    print("Aterrizando...")
    await drone.action.land()

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

































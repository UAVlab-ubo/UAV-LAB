---

# Modelo MAVLink: cómo funciona realmente

A nivel MAVLink, PX4 y MAVSDK se comunican mediante **mensajes**.  
Los más importantes para control autónomo son:

- **HEARTBEAT** → quién soy, en qué modo estoy  
- **COMMAND_LONG** → comandos de alto nivel (armar, despegar, cambiar modo)  
- **MISSION_ITEM / MISSION_ITEM_INT** → misiones clásicas  
- **SET_POSITION_TARGET_LOCAL_NED / GLOBAL_INT** → setpoints OFFBOARD  
- **COMMAND_ACK** → respuesta a un comando  
- **REQUEST / RESPONSE** → handshake de misión  
- **ODOMETRY / ATTITUDE / GPS_RAW** → sensores para el EKF2

Vamos paso por paso.

---

# 1) HEARTBEAT — el pulso del sistema

PX4 envía un **HEARTBEAT** cada 1 Hz:

```
MAV_TYPE_QUADROTOR
MAV_AUTOPILOT_PX4
base_mode
custom_mode
system_status
```

MAVSDK también envía su propio heartbeat.

### ¿Para qué sirve?

- Detectar si el dron está vivo  
- Detectar si hay GCS  
- Detectar si hay pérdida de enlace  
- Saber en qué modo está PX4 (MANUAL, OFFBOARD, AUTO.MISSION, etc.)

Si no hay heartbeat → PX4 dice:

```
Connection to ground station lost
```

Esto **no afecta OFFBOARD**, pero sí afecta misiones clásicas.

---

# 2) COMMAND_LONG — comandos de alto nivel

Cada acción de MAVSDK se traduce en un **COMMAND_LONG**:

Ejemplos:

| Acción MAVSDK | COMMAND_LONG enviado |
|---------------|----------------------|
| arm() | MAV_CMD_COMPONENT_ARM_DISARM |
| takeoff() | MAV_CMD_NAV_TAKEOFF |
| land() | MAV_CMD_NAV_LAND |
| set_mode() | MAV_CMD_DO_SET_MODE |
| start_mission() | MAV_CMD_MISSION_START |

Formato:

```
COMMAND_LONG {
    command = MAV_CMD_XXXX
    param1..param7
    target_system
    target_component
}
```

PX4 responde con:

```
COMMAND_ACK {
    command = MAV_CMD_XXXX
    result = MAV_RESULT_ACCEPTED / DENIED / FAILED / UNSUPPORTED
}
```

Si no hay ACK → MAVSDK reintenta.

---

# 3) Handshake de misión RAW

Tu script usa **mission_raw**, que es el modelo MAVLink puro:

### Secuencia real:

1. MAVSDK envía `MISSION_COUNT`
2. PX4 responde `MISSION_REQUEST_INT(seq=0)`
3. MAVSDK envía `MISSION_ITEM_INT(seq=0)`
4. PX4 responde `MISSION_REQUEST_INT(seq=1)`
5. MAVSDK envía `MISSION_ITEM_INT(seq=1)`
6. …
7. PX4 responde `MISSION_ACK`

Si esta secuencia se rompe → la misión no se carga.

---

# 4) OFFBOARD — por qué exige flujo continuo de setpoints

Este es el punto más importante.

OFFBOARD **NO es un modo persistente**.  
Es un modo **dependiente del flujo de comandos**.

PX4 exige:

```
SET_POSITION_TARGET_LOCAL_NED
SET_ATTITUDE_TARGET
SET_ACTUATOR_CONTROL_TARGET
```

**a 2 Hz mínimo**  
**idealmente 20–50 Hz**

Si el flujo se detiene por más de 0.5 segundos:

PX4 sale de OFFBOARD automáticamente:

```
WARN [commander] Offboard lost, switching to HOLD
```

### ¿Por qué?

Porque OFFBOARD significa:

> “El control está fuera del autopiloto. Si dejan de llegar comandos, el dron queda sin control.”

Por seguridad, PX4 abandona OFFBOARD si no recibe setpoints.

---

# 5) ¿Qué pasa cuando envías una misión RAW?

Tu misión RAW **no usa OFFBOARD**.  
Usa **AUTO.MISSION**.

Pero PX4 **solo inicia AUTO.MISSION si está armado y volando**.

Secuencia correcta:

1. `COMMAND_LONG(ARM)`
2. `COMMAND_LONG(TAKEOFF)`
3. PX4 detecta altura > 2 m
4. `COMMAND_LONG(MISSION_START)`
5. PX4 cambia a AUTO.MISSION
6. PX4 ejecuta los waypoints

Si PX4 no despega → no ejecuta misión.

---

# 6) ¿Por qué tu dron no se mueve?

Porque PX4 está rechazando el armado por:

```
Preflight Fail: Yaw estimate error
```

Y sin armado → no hay misión.

---

# 7) ¿Cómo se ve todo esto en MAVLink real?

### Heartbeat
```
< HEARTBEAT autopilot=PX4 mode=MANUAL >
```

### Arm
```
> COMMAND_LONG MAV_CMD_COMPONENT_ARM_DISARM param1=1
< COMMAND_ACK ACCEPTED
```

### Takeoff
```
> COMMAND_LONG MAV_CMD_NAV_TAKEOFF alt=10
< COMMAND_ACK ACCEPTED
```

### Mission upload
```
> MISSION_COUNT=2
< MISSION_REQUEST_INT seq=0
> MISSION_ITEM_INT seq=0
< MISSION_REQUEST_INT seq=1
> MISSION_ITEM_INT seq=1
< MISSION_ACK ACCEPTED
```

### Mission start
```
> COMMAND_LONG MAV_CMD_MISSION_START
< COMMAND_ACK ACCEPTED
```

### OFFBOARD (si lo usas)
```
> SET_POSITION_TARGET_LOCAL_NED (50 Hz)
> SET_POSITION_TARGET_LOCAL_NED (50 Hz)
> SET_POSITION_TARGET_LOCAL_NED (50 Hz)
...
```

Si se detiene:

```
< WARN Offboard lost
```

---

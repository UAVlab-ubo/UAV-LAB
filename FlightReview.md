```
cd ~/PX4-Autopilot/build/px4_sitl_default/rootfs/log
```

copiar archivo .ulog al escritorio para poder subirlo a Flight Review
```
cp ~/PX4-Autopilot/build/px4_sitl_default/rootfs/log/2026-07-09/14_05_45.ulg /mnt/c/Users/alumno/Desktop/
```






---

# FlightReview.md

Este documento explica cómo obtener logs `.ulog` desde PX4 SITL, cómo subirlos a FlightReview, y qué analizar primero para diagnosticar problemas típicos de vuelo (vibraciones, EKF, saturaciones, fallos de control).

---

## 1. ¿Qué es un archivo `.ulog`?

PX4 registra automáticamente todos los vuelos en un archivo binario llamado `.ulog`.  
El `.ulog` contiene:

- Estados del EKF (posición, velocidad, yaw, covarianzas)  
- Sensores (IMU, magnetómetro, barómetro, GPS)  
- Actuadores (motores, servos)  
- Estados del controlador (PID, saturaciones)  
- Mensajes del sistema (armado, modos, fallos)  
- Vibraciones  
- Eventos del autopiloto  

En SITL, PX4 genera `.ulog` igual que en hardware real.

---

## 2. ¿Dónde se guardan los `.ulog` en SITL?

En PX4 SITL, los logs se guardan en:

```
~/PX4-Autopilot/build/px4_sitl_default/rootfs/log
```

Cada vuelo crea una carpeta con fecha y hora:

```
~/PX4-Autopilot/build/px4_sitl_default/rootfs/log/2026-07-09/14_05_45.ulg
```

---

## 3. Cómo generar un `.ulog` en SITL
Para generar un `.ulog` debes ejecutar una misión ya sea mediante el propio PX4 `pxh>` o vía MAVSDK (en nuestro caso).

**Ejemplo vía `pxh>`:**
1. Abre PX4 SITL:

```
make px4_sitl gz_x500
```

2. Arma el dron:

```
commander arm
```

3. Despega o ejecuta una misión.

4. Aterriza y desarma:

```
commander disarm
```

5. Cierra PX4 SITL.

El `.ulog` aparecerá en:

```
~/PX4-Autopilot/build/px4_sitl_default/rootfs/log/<fecha>/<hora>.ulg
```

---

## 4. Cómo abrir un `.ulog` en FlightReview

FlightReview es la herramienta oficial de PX4 para analizar logs.

1. Abre:  
   [https://logs.px4.io](https://logs.px4.io)

2. Haz clic en **Upload Log File**.

3. Selecciona tu archivo `.ulg`.

FlightReview mostrará:

- Gráficos de sensores  
- Estados del EKF  
- Vibraciones  
- Controladores  
- Saturaciones  
- Modos de vuelo  
- Mensajes del sistema  

---

## 5. Qué analizar primero en FlightReview

### 5.1 Vibraciones (IMU)

En la sección **Vibration**, revisa:

- `accel_vibration`  
- `gyro_vibration`  
- `clip_count`  

Valores altos indican:

- Problemas de montaje  
- Resonancias  
- Vibraciones excesivas  
- En SITL: errores del modelo o del plugin

### 5.2 EKF (Estimador de estado)

En **Estimator Status** revisa:

- `vel_test_ratio`  
- `pos_test_ratio`  
- `hgt_test_ratio`  
- `mag_test_ratio`  
- `yaw_test_ratio`

Valores > 1 indican que el EKF está rechazando datos.

Problemas típicos:

- Yaw estimate error  
- GPS inconsistente  
- Magnetómetro saturado  
- Altitud inestable  

### 5.3 Saturación de motores

En **Actuator Controls** revisa:

- `control[0..3]`  
- `actuator_output`  

Si los motores están saturados:

- El dron no puede generar suficiente fuerza  
- El controlador está al límite  
- En SITL: parámetros incorrectos o modelo mal configurado

### 5.4 Modos de vuelo

En **Vehicle Status**, revisa:

- Cambios de modo  
- Fallos de armado  
- Failsafe  
- Offboard lost  
- Mission start  
- Mission rejected  

Esto te permite ver si PX4 rechazó:

- Armado  
- OFFBOARD  
- Misión  
- Setpoints  

### 5.5 Mensajes del sistema

En **Messages**, revisa:

- Preflight Fail  
- EKF errors  
- Sensor errors  
- Mode changes  
- Failsafe triggers  

---

## 6. Problemas típicos y cómo se ven en FlightReview

### 6.1 Error de yaw (EKF)

En FlightReview:

- `yaw_test_ratio` alto  
- `mag_test_ratio` alto  
- Mensaje: *Preflight Fail: Yaw estimate error*

### 6.2 Vibraciones excesivas

En FlightReview:

- `accel_vibration` alto  
- `gyro_vibration` alto  
- `clip_count` > 0  

### 6.3 Saturación de motores

En FlightReview:

- `actuator_output` llega a 1.0  
- `control[0..3]` al límite  

### 6.4 OFFBOARD perdido

En FlightReview:

- Mensaje: *Offboard lost*  
- `mode` cambia de OFFBOARD a HOLD  
- Setpoints dejan de aparecer en el log  

### 6.5 Misión no iniciada

En FlightReview:

- No aparece `mission_start`  
- No hay cambios de modo a AUTO.MISSION  
- No hay waypoints ejecutados  

---

## 7. Buenas prácticas para análisis de logs

1. Revisar primero vibraciones.  
2. Revisar segundo EKF.  
3. Revisar tercero saturaciones.  
4. Revisar cuarto mensajes del sistema.  
5. Revisar quinto modos de vuelo.  
6. En SITL, verificar que el modelo no genera datos inconsistentes.  
7. En OFFBOARD, verificar que los setpoints aparecen en el log.  
8. En misiones RAW, verificar que los waypoints aparecen en el log.  

---

## 8. Cómo documentar un análisis de vuelo

Para cada `.ulog`, documenta:

1. Fecha y hora del vuelo  
2. Modo de vuelo  
3. Objetivo del vuelo  
4. Vibraciones  
5. EKF  
6. Saturaciones  
7. Mensajes  
8. Conclusión  
9. Acciones correctivas  

---


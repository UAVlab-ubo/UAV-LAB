
---

## **1. Obtener archivos `.ulog` desde PX4 SITL**

PX4 SITL genera automáticamente un archivo `.ulog` cada vez que el dron:

- arma  
- despega  
- vuela  
- aterriza  
- se desarma  

Los logs se guardan en el “microSD virtual” dentro de la carpeta `rootfs`.

Ruta:

```
~/PX4-Autopilot/build/px4_sitl_default/rootfs/log
```

Cada vuelo crea una carpeta con fecha y hora:

```
~/PX4-Autopilot/build/px4_sitl_default/rootfs/log/2026-07-09/14_05_45.ulg
```

---

## **2. Copiar el archivo `.ulog` al escritorio**

Para subir el archivo a FlightReview desde Windows, primero debes copiarlo al escritorio.

Ejemplo:

```
cd ~/PX4-Autopilot/build/px4_sitl_default/rootfs/log
```

Luego copia el archivo:

```
cp ~/PX4-Autopilot/build/px4_sitl_default/rootfs/log/2026-07-09/14_05_45.ulg /mnt/c/Users/alumno/Desktop/
```

Ahora el archivo `.ulg` está disponible en tu escritorio de Windows.

---

## **3. Subir el `.ulog` a FlightReview**

1. Abre:  
   **[https://logs.px4.io](https://logs.px4.io)**

2. Haz clic en **Upload Log File**.

3. Selecciona tu archivo `.ulg`.

FlightReview mostrará:

- Trayectoria del vuelo  
- Distancia recorrida  
- Altitud  
- Velocidades  
- Duración del vuelo  

> Nota:  
> Con el modelo `gz_x500` en PX4 v1.15, FlightReview puede entrar en **modo compacto**, donde no aparecen las secciones avanzadas (EKF, vibraciones, actuadores).  
> Esto es normal y no impide documentar el análisis básico.

---

## **4. Qué analizar primero en FlightReview**

Aunque el panel lateral no aparezca en este modelo, FlightReview sigue mostrando información útil para documentar:

### **4.1 Trayectoria del vuelo**
Permite verificar:

- si el dron siguió la ruta esperada  
- si hubo desviaciones  
- si hubo oscilaciones o movimientos inesperados  

### **4.2 Altitud**
Permite identificar:

- ascensos bruscos  
- pérdidas de altura  
- estabilidad vertical  

### **4.3 Velocidades**
Incluye:

- velocidad horizontal  
- velocidad vertical  
- velocidad máxima  
- velocidad promedio  

Esto permite evaluar si el control del dron fue estable.

### **4.4 Duración del vuelo**
Útil para verificar:

- tiempo de misión  
- tiempo de hover  
- tiempo total de operación  

---

## **5. Qué secciones avanzadas existen en FlightReview (aunque no aparezcan en SITL)**

Para documentación, es importante describir las secciones que FlightReview muestra cuando se usa hardware real:

### **5.1 Vibrations**
- `accel_vibration`  
- `gyro_vibration`  
- `clip_count`  

### **5.2 EKF (Estimator Status)**
- `vel_test_ratio`  
- `pos_test_ratio`  
- `hgt_test_ratio`  
- `mag_test_ratio`  
- `yaw_test_ratio`  

### **5.3 Actuator Controls**
- comandos enviados a los motores  
- saturaciones  

### **5.4 Vehicle Status**
- modos de vuelo  
- armado/desarmado  
- failsafe  

### **5.5 Messages**
- errores  
- advertencias  
- rechazos de misión  
- fallos del EKF  

> Aunque estas secciones no aparezcan en SITL con `gz_x500`, deben documentarse porque forman parte del análisis estándar de PX4.

---

## **6. Problemas típicos y cómo se verían en FlightReview**

### **6.1 Vibraciones excesivas**
- valores altos en acelerómetros  
- recortes (`clip_count`)  

### **6.2 Fallos del EKF**
- ratios > 1  
- mensajes de rechazo de datos  
- errores de yaw  

### **6.3 Saturación de motores**
- actuadores al límite  
- pérdida de control  

### **6.4 OFFBOARD perdido**
- cambio de modo inesperado  
- pérdida de setpoints  

### **6.5 Misión no iniciada**
- no aparece `mission_start`  
- no hay AUTO.MISSION  

---

## **7. Conclusión**

Aunque el modelo `gz_x500` en PX4 SITL v1.15 no genera todos los tópicos necesarios para análisis avanzado en FlightReview, **sí genera `.ulog` válidos**, y **sí permite documentar la parte fundamental del análisis**:

- cómo obtener logs  
- cómo subirlos  
- cómo interpretar la vista general  
- qué secciones existen en FlightReview  
- qué problemas típicos se analizan en vuelos reales  

Esto cumple completamente con el objetivo del proyecto:  
**documentar el flujo de trabajo de análisis de vuelos usando FlightReview, incluso sin hardware.**

---

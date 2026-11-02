
**1. Especificaciones clave del diseño**


| Parámetro  | 	Valor |
|------|--------|
| Configuración 	|  Tricóptero tilt-rotor + ala volante (“plank”), 2 motores delanteros inclinables y 1 trasero fijo |
| Envergadura / largo	 |  800 mm / 520 mm |
| Área alar / alargamiento	 |  15.6 dm² / 4.1 |
| Perfil |	MH45 (raíz y punta, sin torsión declarada) |
| Separación de rotores	 |  círculo de 315 mm |
| Peso total	 |  1000-1200 g (la estructura sola pesa ~460 g en PLA) |
| Velocidad de crucero / pérdida	 |  19 m/s / ~15 m/s |
| CG	 |  28 mm detrás del borde de ataque (rango 26-30 mm); el punto neutro está cerca de 33 mm |

**2. Componentes**

- **Motores delanteros:** 2207 o 2306, 2300-2600 kV, campana de máximo 29 mm, con 500-800 g de empuje estático. Hélices de 5".
- **Motor trasero:** 2207 o 2306, ~2000 kV, con 700-1000 g de empuje. Hélice de 5" a 6".
- **Batería:** 4S 1300-1500 mAh (~160 g).
- **ESC:** 3 unidades de 40 A o más.
- **Servos:** 2 para elevones (tipo HS-65HB) y 2 para la inclinación (HS-5065MG, de preferencia con engranajes de metal).
- **Controlador de vuelo:** con 3 salidas de motor y 4 de servo (PixRacer Pro, Matek F405/F765-WING). Además necesitas pitot, GPS, receptor y UBEC.
- **Estructura:** larguero de fibra de carbono de hasta 640 mm y 6.5 mm de diámetro, más varillas 2-56, rótulas Dubro y bisagras de nylon.

**3. Dimensiones críticas que debes respetar si rediseñas**

- **Brazo del servo de inclinación:** 19.3 mm (agujero a centro). Si es más corto, el motor no alcanza el ángulo de hover.
- **Brazo de elevón:** ~9.5 mm. Controla el recorrido de la superficie.
- **Bahías de servo:** hasta 26 mm de ancho, 12 mm de espesor, 17.5 mm de altura bajo las orejetas.
- **Pasador del eje de inclinación:** barra de 1.84 mm. Se escaría el agujero en el soporte a ~1.95 mm y el de la góndola a 1.84 mm.
- **Inclinación:** debe llegar a más de 90° y quedar al ras hacia adelante.

**4. Impresión 3D (PLA, 0.4 mm)**

- **Alas, nariz, empenaje y tapa:** capa de 0.2 mm, pared de 0.4 mm (una sola), relleno cúbico de 5-10 %. Es una estructura de piel muy delgada.
- **Góndolas y soportes de motor:** pared de 0.8 mm y relleno de 20-30 %. Son las piezas más cargadas.
- **Bisagras de elevón:** son bisagras vivas impresas y fallan con el tiempo, por eso se refuerzan con bisagras de nylon o cinta.



**5. Configuración de vuelo (ArduPlane)**

Es la parte más reutilizable. Los parámetros base son:

- **Frame:** ```Q_FRAME_CLASS=7``` (tricóptero) y ```Q_TILT_TYPE=2``` (yaw vectorial), con ```Q_TILT_MASK=3```.
- **Ángulos de inclinación:** ```Q_TILT_MAX=55``` en transición y ```Q_TILT_YAW_ANGLE=14``` en hover.
- **Crucero:** ```TRIM_ARSPD_CM=1900```, ```ARSPD_FBW_MIN=17``` y ```ARSPD_FBW_MAX=32```.
- **Compensación de pitch:** ```Q_TRIM_PITCH=9```, porque en hover el avión queda con la nariz arriba.
- **Salidas del FC:** S1 motor derecho, S2 izquierdo, S4 trasero, S5-S6 tilt, S7-S8 elevones.

El README lista el archivo completo (más de 1100 parámetros) y un resumen de ~150 en la sección “ArduPlane Parameters”.

6. Lo que debes saber para replicarlo “a tu manera”
Licencia: CC BY-NC-SA 4.0. Puedes hacer derivados, pero con atribución, sin uso comercial y con la misma licencia.
Archivos fuente: el autor no publica el CAD original (Inventor), solo los STL y un STEP de la tapa. Para un rediseño propio tendrás que modelar tú desde cero, usando los STL como referencia dimensional. El perfil MH45 es público en mh-aerotools.de.
Regla de escala: si cambias el tamaño, el CG y el punto neutro se mueven y el empuje requerido cambia. Para mantener estabilidad conviene conservar el margen estático (~5 mm entre CG y punto neutro) y una relación empuje/peso en hover de al menos 2:1.

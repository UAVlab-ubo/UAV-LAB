> 02-07-2026

# Instalar MAVSDK-Python para controlar dron
## Prerrequisitos
- **Python 3.6+:**
  Si no sabes la versión de python:
  ```
  python --version
  ```
  o
  ```
  python3 --version
  ```
- Una instancia de SITL en ejecución (en este caso gazebo)
  
## Instalar MAVSDK-Python
```
pip3 install mavsdk
```

Para empezar rápidamente, instalaremos también el paquete ligero llamado “aioconsole”. Este proporciona un REPL (shell interactivo) `apython` que podemos usar para ejecutar código asyncio:

```
pip3 install aioconsole
```
---

## Ejecutar SITL
Siempre es recomendable asegurarse de que SITL funcione correctamente antes de intentar conectar MAVSDK. Una forma de hacerlo es ejecutar los siguientes comandos en la terminal de `pxh>` mientras SITL esté en ejecución

Ejecutamos SITL:
```
cd ~/PX4-Autopilot
make px4_sitl gz_x500 -j$(nproc)
```
Le damos comandos para asegurar su funcionamiento:
```
commander takeoff
commander land
```
El dron simulado debería despegar y aterrizar. Si no lo hace, puede significar que SITL no está listo o que hay algún problema.

---

## Despegue desde MAVSDK
Cuando sepamos que el simulador está listo, podremos abrir una nueva terminal `apython` interactiva (REPL):
```
apython
```

Importa MAVSDK al entorno introduciendo:
```
from mavsdk import System
```

Luego creamos un Systemobjeto, en este caso llamado drone, y lo conectamos al dron (este objeto es nuestro "mando" para acceder al resto de las funciones de MAVSDK):
```
drone = System()
await drone.connect()
```

Una vez conectados, podemos armar y despegar utilizando los comandos MAVSDK apropiados:
```
await drone.action.arm()
await drone.action.takeoff()
```
Si todo salió bien, tu dron debería despegar. En la terminal pxh>, deberías ver una línea de registro como esta:

`INFO [commander] Takeoff detected`





# Guía de Conexión y Control Remoto (PC 1 a PC 2)

Documentación paso a paso para la instalación del servidor SSH en el **PC 2 (Servidor)**, la conexión remota desde el **PC 1 (Cliente)** y la ejecución remota de la interfaz gráfica de **NiViewer**.

---

## Requisitos Previos
* **PC 2 (Servidor):** Conectado a la red local y con la cámara Orbbec Astra instalada.
* **PC 1 (Cliente):** Conectado a la misma red local. Se puede utilizar **PowerShell** o el entorno **WSL (Windows Subsystem for Linux / Ubuntu)**.

---

## 1. Configuración del Servidor SSH en el PC 2 (Servidor)

Todos los pasos en el PC 2 deben ejecutarse directamente en **PowerShell como Administrador**.

### Paso 1: Instalar el servicio OpenSSH Server
```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

```

### Paso 2: Iniciar y configurar el inicio automático del servicio

```powershell
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

```

### Paso 3: Configurar la regla en el Firewall de Windows

```powershell
New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (Inbound)' -Enabled True -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow

```

### Paso 4: Obtener la dirección IP local del PC 2

```powershell
Get-NetIPAddress -AddressFamily IPv4 | Select-Object InterfaceAlias, IPAddress

```

> **Nota:** Identifica la dirección IP asociada a tu interfaz de red activa (por ejemplo: `192.168.1.50`).

---

## 2. Conexión Remota desde el PC 1 (Cliente)

La conexión se realiza abriendo la consola de **PowerShell** o la terminal de **WSL** en el PC 1.

### Comando de conexión SSH:

Para obtener tus datos de conexión en el PC 2, ejecuta ahí mismo:

`whoami` (te dirá tu usuario, por ejemplo: mi-pc\juan)

`ipconfig` (busca la Dirección IPv4, por ejemplo: 192.168.1.50)

En el PC 1:
```bash
ssh usuario@<IP_DEL_PC2>

```

* **Ejemplo:**
```bash
ssh alumno@192.168.1.50

```


*(Introduce la contraseña del usuario `alumno` cuando sea solicitada).*

---

## 3. Ejecución de NiViewer con Interfaz Gráfica (`schtasks`)

Las conexiones SSH estándar ejecutan procesos en una sesión no interactiva en segundo plano, lo que impide que Windows abra ventanas gráficas en el monitor del PC 2. Para solucionar esto y forzar el renderizado en la pantalla del PC 2, se utiliza el **Programador de Tareas (`schtasks`)**.

Una vez dentro de la sesión SSH en la consola del PC 1, ejecuta los siguientes comandos de PowerShell:

### Paso 1: Crear la tarea programada

```powershell
schtasks /create /tn "IniciarNiViewer" /tr "cmd.exe /c cd /d C:\Users\alumno\Desktop\NiViewer && NiViewer.exe" /sc once /st 23:59 /f /it /ru "alumno"

```

**Desglose de parámetros clave:**

* **`cd /d C:\Users\alumno\Desktop\NiViewer`**: Establece la carpeta contenedora como el directorio de trabajo activo para que `NiViewer.exe` encuentre sus librerías `.dll` y controladores.
* **`/it`**: Indica que el proceso debe ejecutarse en modo **interactivo** (fuerza la apertura de la ventana gráfica en la pantalla del monitor físico).
* **`/ru "alumno"`**: Especifica la cuenta de usuario que ejecutará la interfaz.

### Paso 2: Iniciar la tarea de inmediato

```powershell
schtasks /run /tn "IniciarNiViewer"

```

---

## 4. Control del Proceso (Opcional)

Si necesitas cerrar la aplicación remotamente desde la consola SSH en el PC 1, ejecuta:

```powershell
taskkill /F /IM NiViewer.exe

```

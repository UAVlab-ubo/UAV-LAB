## Descargar Ubuntu 24.04 en WSL para Powershell
Abrir Powershell como administrador y escribir:
```c 
wsl --install -d Ubuntu-24.04
```

### Conexión SSH a WSL Ubuntu en PC‑2 desde PC‑1 — Paso a paso (Opción B)

**Resumen rápido**  
Configura `sshd` dentro de WSL (Ubuntu) en PC‑2, reenvía el puerto desde Windows hacia WSL y abre el firewall. Desde PC‑1 conecta con `ssh usuario@IP_PC2 -p 2222`. Usa autenticación por clave pública para evitar problemas con políticas de dominio.

---

### Requisitos previos
- **PC‑2**: Windows 10/11 con WSL2 y una distribución Ubuntu instalada y actualizada.  
- **PC‑1**: Cliente SSH (WSL, Linux, macOS o PowerShell con OpenSSH).  
- **Permisos**: acceso de administrador en PC‑2 para ejecutar `netsh` y comandos de firewall.  
- **Decisión de puerto**: usaremos **2222** en Windows y WSL para evitar conflictos con un sshd nativo en Windows.

---

### 1. Configurar SSH dentro de WSL Ubuntu en PC‑2
1. Abre tu terminal WSL en PC‑2 y actualiza paquetes:
```bash
sudo apt update && sudo apt upgrade -y
```
2. Instala el servidor OpenSSH:
```bash
sudo apt install -y openssh-server
```
3. Edita la configuración para escuchar en todas las interfaces y usar el puerto 2222:
```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sudo sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
```
4. Habilita y arranca el servicio:
```bash
sudo systemctl enable --now ssh
```
5. Verifica que `sshd` esté escuchando en el puerto 2222:
```bash
sudo ss -tlnp | grep 2222
```
Si no aparece, revisa `/var/log/auth.log` o `sudo journalctl -u ssh -n 200`.

---

### 2. Obtener la IP de WSL y configurar el reenvío de puertos en Windows
1. En WSL, anota la IP de la interfaz `eth0`:
```bash
ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1
```
Guarda ese valor como `<IP_WSL>`.

2. Abre PowerShell como **Administrador** en Windows y crea la regla de portproxy:
```powershell
# Reemplaza <IP_WSL> por la IP obtenida
netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=2222 connectaddress=<IP_WSL>
```
3. Añade una regla de firewall para permitir conexiones entrantes al puerto 2222:
```powershell
New-NetFirewallRule -Name "WSL-SSH-2222" -DisplayName "WSL SSH 2222" -Direction Inbound -Protocol TCP -LocalPort 2222 -Action Allow
```
4. Verifica el portproxy y la regla:
```powershell
netsh interface portproxy show all
Get-NetFirewallRule -Name "WSL-SSH-2222" | Select-Object Name, Enabled, Action
```

---

### 3. Configurar autenticación por clave pública (recomendado)
1. En PC‑1 genera una clave si no la tienes:
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```
2. Copia la clave pública al usuario de WSL en PC‑2 (desde PC‑1):
```bash
ssh-copy-id -p 2222 usuario_pc2@IP_de_PC2
```
Si `ssh-copy-id` no está disponible, copia manualmente:
- En PC‑1: `cat ~/.ssh/id_rsa.pub` y copia el contenido.
- En PC‑2 WSL: crea `~/.ssh` y pega en `~/.ssh/authorized_keys` con permisos correctos:
```bash
mkdir -p ~/.ssh
echo "PEGA_AQUI_LA_CLAVE_PUBLICA" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

---

### 4. Conectar desde PC‑1
- Conexión básica usando puerto 2222:
```bash
ssh usuario_pc2@IP_de_PC2 -p 2222
```
- Forzar uso de clave privada específica:
```bash
ssh -i ~/.ssh/id_rsa usuario_pc2@IP_de_PC2 -p 2222
```
- Para depuración, añade verbosidad:
```bash
ssh -vvv usuario_pc2@IP_de_PC2 -p 2222
```

---

### 5. Diagnóstico y resolución de problemas comunes
- **sshd no escucha en WSL**: en WSL ejecuta `sudo systemctl status ssh` y revisa `sudo journalctl -u ssh -n 200`.  
- **Portproxy no funciona**: en PowerShell revisa `netsh interface portproxy show all`. Si la IP de WSL cambia tras reinicio, recrea la regla con la nueva IP.  
- **Puerto bloqueado**: desde otra máquina ejecuta `nmap -p2222 IP_de_PC2` para confirmar que Windows recibe conexiones.  
- **Conexión cerrada al instante**: revisa permisos de `~/.ssh/authorized_keys` y logs en WSL `/var/log/auth.log`. Si usas OpenSSH nativo en Windows además de WSL, asegúrate de no tener conflictos de puerto.  
- **Dominio restrictivo**: si usas cuentas de dominio y la autenticación falla, coordina con TI para permisos AD o usa cuentas locales en WSL y autenticación por clave pública.

---

### Checklist final antes de probar
- **sshd en WSL**: activo y escuchando en 2222.  
- **Portproxy**: regla creada y apunta a la IP actual de WSL.  
- **Firewall**: regla `WSL-SSH-2222` habilitada.  
- **Clave pública**: `authorized_keys` configurado con permisos 700/600.  
- **Prueba**: desde PC‑1 ejecutar `ssh -vvv usuario@IP_de_PC2 -p 2222` y revisar salida.

---

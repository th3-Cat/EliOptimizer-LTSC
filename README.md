<h1 align="center">  EliOptimizer 🚀 

### El optimizador interactivo para Windows 10 LTSC mas facil de manejar 

> 🛠️ **Filosofía "By user to users"** — Desarrollada pensando cómo usuario y para el ususario. Una herramienta visual, honesta y directa, hecha para usuarios de Windows LTSC que desean optimizar aun mas su SO.

```powershell
irm https://raw.githubusercontent.com/th3-Cat/EliOptimizer-LTSC/refs/heads/main/EliOptimizerexplicated.ps1 | iex
```
> ➡️ Pégalo en una terminal PowerShell como administrador y listo. Se descarga, pide elevación y abre la ventana.
---

 ## 🌟 ¿Por qué existe EliOptimizer?

**De un usuario de PC modesta, para otros usuarios.** EliOptimizer nace de la experiencia técnica de campo combinada con el día a día de usar un equipo limitado.

  **Diseñado para hardware humilde:** Pensado específicamente en equipos con Celeron, Atom, i3 antiguos, almacenamiento eMMC/HDD y memoria RAM ajustada.
  **Optimización sin riesgo:** Desactiva con precisión solo la carga secundaria que satura tu sistema.
  **Simplicidad ante todo:** No necesitas ser ingeniero para recuperar la velocidad de tu PC. Es software con mentalidad *by users for users*: accesible, transparente y directo al grano.
  
---

## ✨ Características Principales

* 🎨 **Interfaz Moderna:** Diseño en modo oscuro con una barra de desplazamiento delgada estilo Fluent Design controlada por software.
* 🕵️ **Capa Detective Antivirus:** Un sistema inteligente de protección en 3 capas que verifica tu entorno (WMI, memoria RAM y servicios) para evitar conflictos si usas software de seguridad de terceros.
* ❄️ **El Congelador de Estado:** Genera de forma automática una captura inicial inmutable del sistema en un archivo JSON seguro. Podrás volver al estado exacto en que se encontraba tu máquina antes de utilizar EliOptimizer.
* ⚡ **Optimización Quirúrgica:** Enfocado en la prioridad de hilos del procesador y el consumo de RAM. A diferencia de otros optimizadores que solo cambian la apariencia del sistema o utilizan herramientas externas enlazadas en su codigo, EliOptimizer trabaja solo con las Politicas de grupo, registros, servicios y tareas programadas del propio sistema operativo realizando ajustes invisibles pero de impacto inmediato. Consigue la ligereza de un Windows desatendido directamente sobre tu instalación actual, o úsalo para exprimir aún más un sistema ya modificado sin generar ningún tipo de conflicto.

---

## 🖱️ Cómo usar la herramienta

Para ejecutar el optimizador en tu equipo, elige una de las siguientes opciones:

### Opción A (Recomendada):

Copia y pega el siguiente comando en PowerShell (como Administrador):

```powershell
irm https://raw.githubusercontent.com/th3-Cat/EliOptimizer-LTSC/refs/heads/main/EliOptimizerexplicated.ps1 | iex
```

### Opción B (Descarga manual):
1. Descarga el archivo `EliOptimizerexplicated.ps1` desde la sección de Releases o desde el repositorio.
2. Haz clic derecho sobre el archivo descargado y selecciona **Ejecutar con PowerShell como administrador**.
3. El script detectará tu entorno y se **auto-elevará solicitando permisos de administrador** de forma automática (esencial para detener servicios profundos del sistema).
4. Elige los interruptores que desees apagar o encender y presiona **Aplicar**.

---

## 👨‍💻 Funcionamiento de la Interfaz

La app refleja el estado real de cada característica (el que le asignes o el que venga establecido en tu equipo):

Estado | Aspecto | Significado
--- | --- | ---
🔵 Encendido | Azul, texto claro | La característica o servicio está habilitado/en ejecución en el sistema.
⚪ Apagado | Gris, texto atenuado | El servicio o función se deshabilitará/detendrá al pulsar Aplicar.
🔒 Bloqueado | Gris oscuro, deshabilitado | Protegido automáticamente por presencia de un antivirus de terceros.

> **Nota sobre la Capa Detective:** Si utilizas un antivirus externo (como Kaspersky o Avast), EliOptimizer bloqueará automáticamente las opciones de Microsoft Defender para no generar conflictos[cite: 3]. Si no tienes antivirus de terceros, la herramienta mantendrá los switches desbloqueados para que gestiones Defender a tu gusto.

El contador en la esquina superior derecha (ej. `0 / 59 a Desactivar`) indica la cantidad de funciones seleccionadas o modificadas.

### ❄️ Respaldo de Seguridad
Al abrir la herramienta por primera vez, se genera automáticamente una captura inicial en:
`%ProgramData%\EliOptimizer\BackupInicial.json`

---

## 🔘 Botones de Acción

Botón | Acción
--- | ---
**Desact. todo** | Deshabilita todos los servicios y registros no bloqueados → optimización completa en un clic.
**Activar todo** | Enciende todos los interruptores → estado activo por defecto.
**Restablecer** | Lee el respaldo JSON y restaura la configuración que tenía tu PC antes de usar EliOptimizer.
**Aplicar** | Guarda los cambios en el Registro, Servicios y Tareas programadas de Windows.

> ⚠️ **Importante sobre "Restablecer":** El botón *Restablecer* devuelve tu PC al punto exacto en el que estaba **antes** de abrir EliOptimizer por primera vez[cite: 3]. Si ya tenías configuraciones personalizadas hechas por ti o por otros programas, EliOptimizer las respetará y te devolverá a ese mismo estado[cite: 3]. No confundir con "Default" de fábrica de Windows.

---
### 🧩 Lista de Botones (y ajustes) de EliOptimizer

Los 59 interruptores de la lista funcionan tanto de forma independiente como en grupo. Aquí se presentan en bloques por un tema de afinidades entre botones y sus funciones.

>👀 **Importante:** Se recalca que la herramienta detecta el estado de configuración actual del PC, por tanto si nunca ha efectuado cambios por su cuenta, por defecto todos los botones aparecerán en azul, pero si ya hizo configuraciones previas el o los botones involucrados a esos cambios aparecerán en gris indicando que el servicio/registro/tarea ya está deshabilitado ( un ejemplo muy común sería el caso del botón para la impresora o para el bluetooth) 

#### ⚡ Fluidez de interfaz y kernel

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Prioridad Estándar de CPU | Asignación equitativa de tiempo de CPU | `Win32PrioritySeparation` |
| Retraso en Despliegue de Menús | Latencia artificial al abrir menús contextuales | `MenuShowDelay` |
| Contenido Completo al Arrastrar | Renderizado de contenido al mover ventanas | `DragFullWindows` |
| Espera Lenta al Cerrar Procesos | Tiempo de espera prolongado al apagar la PC | `WaitToKillAppTimeout` |

#### 🎮 Servicios Xbox

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Inicio de Sesión Xbox | Autenticación en segundo plano de Xbox | `XboxLiveAuthManager` |
| Guardado en la Nube de Xbox | Sincronización de partidas guardadas | `XblGameSave` |
| Accesorios y Mandos Xbox | Soporte para mandos y periféricos Xbox | `XboxGipSvc` |
| Red y Multijugador Xbox | Servicios de red multijugador de Xbox | `XboxNetApiSvc` |

#### 📡 Telemetría y privacidad

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Telemetría y Diagnósticos | Recolección y envío de datos a Microsoft | `AllowTelemetry` |
| Notificaciones y Mensajes WAP | Servicio de empuje de mensajes WAP | `dmwappushservice` |

#### 🏢 Virtualización y empresa

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Cliente Virtual App-V | Cliente de virtualización de aplicaciones | `AppVClient` |
| Sincronización de Entorno UE-V | Agente de virtualización de experiencia de usuario | `UevAgentService` |
| Gestión de Cuentas Compartidas | Gestión de configuración para PC compartidas | `shpamsvc` |

#### 🔒 Seguridad y cifrado

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Cifrado de Disco BitLocker | Servicio de encriptación de unidades de disco | `BDESVC` |

#### ☎️ Redes antiguas y remotas

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Vínculos de Red Distribuidos | Seguimiento de archivos movidos en red local | `TrkWks` |
| Conexión Remota y VPN | Administrador de conexiones de acceso remoto | `RemoteAccess` |
| Servicio de Fax | Funcionalidad de envío y recepción de Fax | `Fax`|
| Acceso Remoto al Registro | Modificación remota del registro de Windows | `RemoteRegistry` |
| Uso Compartido de Puertos TCP | Compartición de puertos mediante protocolo Net.TCP | `NetTcpPortSharing` |
| Servicios de Telefonía Fija | Control de dispositivos de telefonía (TAPI) | `TapiSrv`|

#### 🖐️ Biometría y sensores

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Agente de Autenticación SSH | Gestión de llaves de autenticación SSH | `ssh-agent` |
| Lectores de Huella y Biometría | Servicio de captura de datos biométricos | `WbioSrvc` |
| Lector de Tarjetas Inteligentes | Enumeración de lectores de tarjetas Smart Card | `ScDeviceEnum` |
| Ubicación y Geolocalización | Servicio de localización geográfica del sistema | `lfsvc` |

#### 🚀 Rendimiento y SysMain

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Precarga SysMain (Prefetcher) | Caché e indexación agresiva en RAM/Disco | `EnablePrefetcher` |
| Control Parental | Monitoreo y restricciones de cuentas infantiles | `WpcMonSvc` |
| Programa Windows Insider | Servicio de evaluación previa de Windows | `wisvc` |
| Indexación de Búsqueda en Disco | Búsqueda e indexación automática en segundo plano | `PreventIndexingOnLowDiskSpaceMB` |

#### 🔄 Windows Update y mantenimiento

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Actualizaciones Windows Update | Descarga e instalación automática de parches | `WindowsUpdateMaster` |
| Actualizar al reiniciar/apagar | Opciones forzadas de actualización al apagar | `HideUpdateInShutdownMenu` |

#### 🎨 Multimedia y accesorios

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Asistente de Búsqueda Cortana | Servicio del asistente de voz e integración | `AllowCortana` |
| Descarga de Mapas Sin Conexión | Administrador de mapas descargados | `MapsBroker` |
| Teclado Táctil y Escritura a Mano | Paneles de entrada táctil y reconocimiento | `TabletInputService` |
| Red de Windows Media Player | Compartición de bibliotecas multimedia en red | `WMPNetworkSvc` |
| Registros de Rendimiento y Alertas | Conjuntos de recopiladores de datos del sistema | `pla` |
| Servicio de Impresoras | Cola de impresión de documentos | `Spooler` |
| Soporte para Bluetooth | Servicio de compatibilidad con dispositivos Bluetooth | `bthserv` |
| Efectos Visuales Avanzados | Animaciones complejas en la interfaz | `VisualFXSetting` |
| Transparencia en las Ventanas | Efectos de acrílico y transparencia en ventanas | `EnableTransparency` |

#### 🛡️ Antivirus y seguridad integrada

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Antivirus Microsoft Defender | Servicio principal de protección del antivirus | `WinDefend` |
| Monitoreo de Amenazas Sense | Servicio de protección avanzada contra amenazas | `Sense` |
| Protección de Red de Defender | Inspección de tráfico de red en tiempo real | `WdNisSvc` |
| Centro de Seguridad de Windows | Servicio del panel de control de seguridad | `SecurityHealthService` |
| Protección AntiSpyware Basica | Módulo de análisis contra programas espía | `DisableAntiSpyware` |
| Protección en Tiempo Real | Escaneo continuo de archivos ejecutados | `DisableRealtimeMonitoring` |
| Análisis de Comportamiento | Detección de patrones sospechosos de software | `DisableBehaviorMonitoring` |
| Escaneo Rápido al Encender | Análisis rápido de arranque de la máquina | `DisableCatchupQuickScan` |
| Escaneo Profundo al Encender | Análisis completo de arranque del sistema | `DisableCatchupFullScan` |
| Filtro de Archivos SmartScreen | Verificación de archivos descargados de la red | `EnableSmartScreen` |
| Escaneo de Malware Mensual (MRT) | Descarga y ejecución de la herramienta MRT | `DontOfferThroughWUAU` |

#### 📊 Telemetría avanzada y sistema

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Análisis de Compatibilidad de Apps | Evaluación periódica de telemetría de aplicaciones | `\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser` |
| Seguimiento de Uso de Programas | Actualizador de telemetría sobre uso de apps | `\Microsoft\Windows\Application Experience\ProgramDataUpdater` |
| Sincronización de Contactos | Servicio de sincronización de contactos y datos | `OneSyncSvc` |
| Envío de Informes de Error | Generación y envío de reportes de fallos | `DisabledWER` |
| Separar procesos del sistema | Separación individual de servicios en RAM | `SvcHostSplitThresholdInKB` |
| Sugerencias de Bing en Búsqueda | Resultados web e integración con Bing | `DisableSearchBoxSuggestions` |
| Historial de Archivos Recientes | Registro de elementos abiertos recientemente | `NoRecentDocsHistory` |

#### 🛠️ Mantenimiento programado

| Característica | Qué apaga | Clave(s) de registro / Identificador |
| :--- | :--- | :--- |
| Desfragmentación de Disco | Mantenimiento y optimización de discos programado | `\Microsoft\Windows\Defrag\ScheduledDefrag` |
| Mantenimiento Automático Diario | Tareas nocturnas de diagnóstico y optimización | `MaintenanceDisabled` |

---

## ⚛️Beneficios esperados:

## 📄 Código Abierto y Transparente

Este proyecto es **100% de código abierto**. El archivo `.ps1` es texto plano y no contiene dependencias externas ni compilados opaco. Puedes auditarlo, modificarlo o usarlo libremente en tus labores de soporte técnico o mantenimiento informático diario.

*¡Gracias por usar y apoyar herramientas diseñadas de usuario para usuarios!*

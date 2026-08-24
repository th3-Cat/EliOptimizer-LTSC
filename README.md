<h1 align="center">  EliOptimizer 🚀 

### El optimizador interactivo para Windows 10 LTSC mas facil de manejar 

> 🛠️ **Filosofía "By user to users"** — Desarrollada pensando como usuario y para el usuario. Una herramienta visual, honesta y directa, hecha para usuarios de Windows LTSC que desean optimizar aún mas su SO.

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

## 🧠 ¿Por qué funciona? La ciencia detrás del Procesador y los C-States

Para entender el impacto real de EliOptimizer no hay que mirar promesas mágicas, sino la arquitectura del procesador y lo que ocurre dentro de él cuando ya no es posible mejorar a nivel de hardware:

* **Los C-States (Estados de energía):** Son los modos de descanso de la CPU.
  * **C0 (Activo):** El procesador trabaja a máxima frecuencia, voltaje y temperatura.
  * **C1 a C6/C7 (Reposo profundo):** La CPU apaga partes de sus circuitos para enfriarse y ahorrar energía.

* **El problema en procesadores de entrada (Celeron, Atom, i3):** Windows viene con decenas de servicios ejecutando llamadas invisibles (*polling*). Estas "llamadas fantasma" despiertan al chip del estado **C6** al **C0** decenas de veces por segundo. Al tener pocos núcleos e hilos, esto genera:
  * **Tirones (*Micro-stuttering*):** Pérdida de fluidez por cambios de contexto continuos.
  * **Mayor temperatura:** Los ventiladores se aceleran en reposo sin razón aparente.
  * **Pérdida de potencia (*Throttling*):** La CPU reduce su velocidad al sobrecalentarse por tareas inútiles justo cuando abres una app pesada.

* **El resultado de optimizar:** Al cortar las interrupciones inútiles no aceleras el reloj por la fuerza, sino que devuelves **eficiencia**. La CPU logra permanecer entre el **90% y 98% en estado C6/C7** al estar en reposo, reservando el 100% de sus núcleos, hilos y memoria caché para responder al instante cuando tú se lo pides.
---

## 🫶 Beneficios esperados

Tras hacer efectivos los cambios (botones en gris y click en "Aplicar" + reinicio), esté es el nuevo comportamiento del procesador derivado de cada botón elegido 

#### ⚡ Fluidez  
* Prioridad estandar del CPU→
Mejora la respuesta de las aplicaciones en primer plano al ajustar cómo Windows reparte el tiempo del procesador.
* Retraso en respuesta de menús→
Hace que los menús de Windows aparezcan más rápido al reducir la espera antes de mostrarlos.
* Contenido completo al arrastrar→
Reduce el trabajo gráfico al mover ventanas, mostrando solo su contorno en lugar de redibujar todo su contenido.
* Espera lenta al cerrar procesos→
Reduce el tiempo que Windows espera a las aplicaciones que tardan en cerrarse durante el apagado.

#### 🎮 Servicios Xbox
* Evitas el consumo innecesario de memoria RAM al impedir que los procesos de inicio de sesión y gestión de accesorios carguen controladores en segundo plano sin estar en uso.  su desactivación elimina la carga sobre el procesador, el disco y la red al detener la búsqueda de partidas guardadas y el mantenimiento de puertos para conexiones multijugador que no están incluidos en versiones LTSC.

#### 📡 Telemetría y privacidad
* Reduces la carga de trabajo sobre el procesador y disminuyes el uso del disco al detener el procesamiento y envío de informes de uso. Además, en sistemas con memoria RAM muy limitada (2GB o 4GB), ayuda a mitigar el consumo innecesario de memoria al evitar que el servicio de mensajería en desuso permanezca escuchando activamente en segundo plano.

#### 🏢 Virtualización y empresa
* Evitas el consumo innecesario de memoria RAM en sistemas con recursos muy limitados (2GB o 4GB) al impedir que procesos en desuso se ejecuten en segundo plano. Dado que estas herramientas están diseñadas exclusivamente para redes corporativas, computadoras públicas o entornos empresariales, su desactivación elimina servicios sin utilidad en una PC personal.
  
#### 🔒 Seguridad y cifrado
* BitLocker es una herramienta de seguridad de Windows que cifra tus datos en tiempo real para protegerlos en caso de robo físico del disco. Si utilizas un procesador de bajo rendimiento o antiguo (como ciertos Intel Atom, Celeron o Core i3 antiguos sin soporte de cifrado por hardware), desactivar esta función liberará una carga significativa de trabajo en tu CPU cada vez que el sistema abre, copia o modifica archivos, mejorando la fluidez general del equipo.

#### ☎️ Redes antiguas y remotas→
* Al deshabilitar estos servicios obsoletos de red y acceso remoto en equipos de gama baja (como Intel Atom, Celeron o Core i3 antiguos), reduces la superficie de ataque cerrando puertos vulnerables. Además, en sistemas con memoria RAM muy limitada (2GB o 4GB), ayuda a mitigar el consumo innecesario de memoria al evitar que procesos en desuso retengan recursos del sistema.

#### 🖐️ Biometría y sensores→
* Al apagar el monitoreo continuo de sensores y lectores (los cuales no tienes instalados), eliminas las consultas constantes a la CPU y ahorras batería y memoria RAM.

#### 🚀 Rendimiento y SysMain
* Al detener SysMain y la indexación automática, reduces significativamente los picos prolongados de uso de disco al 100%, un problema crítico en equipos con discos mecánicos (HDD) o almacenamientos eMMC lentos. Alivias la carga sobre el almacenamiento y la memoria RAM, aunque los programas que usas con mucha frecuencia podrían tardar un poco más en cargar la primera vez que los abres.

#### 🔄 Windows Update y mantenimiento
* Al pausar las actualizaciones automáticas y sus tareas de reinicio, impides que el proceso de Windows Update (wuauserv) sature por completo los núcleos del procesador y el ancho de banda de la red de forma imprevista mientras usas el equipo. También agiliza el proceso de apagado al eliminar los tiempos de espera forzados para la instalación de parches.

#### 🎨 Multimedia y accesorios
* Al desactivar los componentes visuales avanzados, la transparencia y los servicios secundarios de fondo (como el spooler de impresión o el bluetooth si no se utilizan), liberas una cantidad medible de memoria RAM (más de 100 MB en conjunto). Además, deshabilitar los efectos visuales reduce drásticamente la carga de procesamiento gráfico en las tarjetas integradas lentas, haciendo que el explorador de archivos y las transiciones de las ventanas se sientan más fluidas.

#### 🛡️ Antivirus y seguridad integrada
* Al desactivar la protección en tiempo real y los análisis continuos de Microsoft Defender, eliminas el uso intensivo de CPU y las lecturas concurrentes de disco que ocurren cada vez que se ejecuta o descarga un archivo. Esto reduce los congelamientos del sistema y acelera de forma medible la apertura de programas y juegos en procesadores de dos núcleos, aunque deja al sistema operando sin protección nativa contra software malicioso.

#### 📊 Telemetría avanzada y sistema
* Al deshabilitar las tareas programadas de evaluación de compatibilidad y los informes de errores, eliminas tareas automáticas que generan picos repentinos de uso de CPU. Asimismo, al desactivar las sugerencias de Bing en el cuadro de búsqueda, el menú Inicio responde con mayor rapidez al limitar la consulta exclusivamente a los archivos locales del equipo, eliminando la latencia de la consulta web.

#### 🛠️ Mantenimiento programado
* Al deshabilitar el mantenimiento automático diario y la desfragmentación programada, previenes caídas drásticas de rendimiento y bloqueos del sistema que ocurren cuando Windows detecta falsos tiempos de inactividad y arranca estas tareas pesadas en segundo plano mientras el usuario aún está utilizando la computadora.
---

### ✅ Tecnologías Utilizadas

Para lograr una optimización quirúrgica sin instalar software de terceros ni alterar la estabilidad del entorno, esta herramienta trabaja exclusivamente con cuatro componentes nativos del sistema operativo:

1. 📂 **Registro del Sistema (`Registry`)**
   * **Qué es:** La base de datos central que almacena las configuraciones del sistema.
   * **Ejemplo en código:** `MenuShowDelay` (Grupo: Fluidez). Al cambiar su valor de 400ms a 20ms, se elimina la latencia artificial al abrir menús contextuales.

2. 🔐 **Directivas de Grupo Local (`GPO` / Policies)**
   * **Qué es:** Reglas de administración avanzadas que dictan comportamientos obligatorios en el núcleo.
   * **Ejemplo en código:** `AllowTelemetry` (Grupo: Telemetría). Inyecta una restricción que deshabilita por completo el flujo de recolección de diagnósticos de fondo.

3. ⚙️ **Servicios de Fondo (`Services`)**
   * **Qué es:** Programas invisibles que se ejecutan en segundo plano consumiendo memoria RAM y ciclos de CPU.
   * **Ejemplo en código:** `BDESVC` (Cifrado de Disco BitLocker). Detiene el proceso en tiempo real para liberar recursos en hardware modesto.

4. ⏳ **Tareas Programadas (`Scheduled Tasks`)**
   * **Qué es:** Activadores automáticos que esperan a que el equipo entre en reposo para iniciar mantenimientos pesados.
   * **Ejemplo en código:** `Microsoft Compatibility Appraiser` (Grupo: Telemetría 2021). Desactiva el disparador automático para prevenir congelamientos sorpresa mientras usas la PC.
---

## 🤝 Créditos y Agradecimientos

* **Desarrollo y Lógica de Optimización:** Creado por **th3-Cat** pensando en la comunidad de hardware modesto.
* **Interfaz Gráfica (UI):** Este proyecto utiliza la arquitectura visual y el motor de renderizado de componentes basado en **EdgeControl**, desarrollado originalmente por **Daniel Rodríguez ([xdoofy92](https://github.com/xdoofy92))** bajo la licencia MIT. Agradecemos su contribución al software libre, la cual hizo posible la base interactiva de esta herramienta.

## 📄 Código Abierto y Transparente

Este proyecto es **100% de código abierto**. El archivo `.ps1` es texto plano y no contiene dependencias externas ni compilados opaco. Puedes auditarlo, modificarlo o usarlo libremente en tus labores de soporte técnico o mantenimiento informático diario.

*¡Gracias por usar y apoyar herramientas diseñadas de usuario para usuarios!*

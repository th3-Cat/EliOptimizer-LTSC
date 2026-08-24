# 1. PERMISOS DE JEFE (ADMINISTRADOR)-AUTO-ELEVACIÓN OBLIGATORIA
# Si el programa se abre sin permisos de administrador, se cierra solo 
# y se vuelve a abrir pidiéndole permiso a Windows. Esto es obligatorio 
# porque para apagar los servicios e hilos de Windows necesitamos el control total.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# 2. CARGAR LAS HERRAMIENTAS DE DIBUJO
# Estas dos líneas le avisan a la computadora que vamos a diseñar una ventana visual 
# (con botones, textos y cajas). Sin esto, el programa solo funcionaría en letras 
# blancas sobre fondo negro como una consola antigua.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 3. ACTIVAR EL DISEÑO MODERNO
# Le dice a Windows que use el diseño de botones redondeados y letras suaves de hoy en día. 
# Si quitamos esta línea, tu herramienta visual se vería vieja y fea, como de Windows 98.
[System.Windows.Forms.Application]::EnableVisualStyles()

# === DETECCIÓN INTELIGENTE DE ANTIVIRUS DE TERCEROS (ROBUSTO - 3 CAPAS) ===

# 1. CAPA DETECTIVE: PREGUNTAR AL CENTRO DE SEGURIDAD DE WINDOWS
# El script va directo al panel de control de Windows y le pregunta: "Oye, ¿tienes algún 
# antivirus registrado que NO sea el Defender nativo?". Si Windows tiene guardado uno 
# (como Avast o Kaspersky), nos dará su nombre oficial de inmediato.
$AV_WMI = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName "AntivirusProduct" -ErrorAction SilentlyContinue | 
    Where-Object { $_.displayName -notlike "*Windows Defender*" -and $_.displayName -notlike "*Microsoft Defender*" -and $_.displayName -ne $null } | Select-Object -First 1

# 2. CAPA RECOLECTORA: LISTA NEGRA DE PROGRAMAS FAMOSOS
# Por si las dudas (ya que en Windows LTSC el Centro de Seguridad a veces viene desactivado), 
# guardamos una lista con los nombres reales de los ejecutables de los antivirus más usados. 
# Así el script sabrá exactamente qué buscar en la memoria RAM en el siguiente paso.
$ListaProcesosAV = @(
    "PSANHost", "PSUAService", "avp", "ekrn", "AvastSvc", "avgSvc", "bdagent", "mbam",
    "mcshield", "mfevtps", "ccSvcHst", "NAV", "N360", "avguard", "SophosHealth",
    "ntrtscan", "cmdagent", "360tray", "WRSA", "vsserv", "fshoster"
)
$AV_Proceso = Get-Process -Name $ListaProcesosAV -ErrorAction SilentlyContinue | Select-Object -First 1

# 3. CAPA RADAR: BUSCAR SERVICIOS EXTRAÑOS EN SEGUNDO PLANO
# Si el antivirus es muy nuevo o raro y no apareció antes, escaneamos todos los servicios 
# ocultos de Windows buscando palabras clave como "Antivirus" o "Total Security". 
# Le ordenamos al radar ignorar los nombres del Defender para no confundirse.
$AV_Servicio = Get-Service | Where-Object { 
    ($_.DisplayName -like "*Antivirus*" -or $_.DisplayName -like "*Anti-Virus*" -or $_.DisplayName -like "*Endpoint Security*" -or $_.DisplayName -like "*Total Security*") -and
    $_.DisplayName -notlike "*Windows Defender*" -and 
    $_.DisplayName -notlike "*Microsoft Defender*" -and 
    $_.Name -notlike "*WinDefend*" -and
    $_.Name -notlike "*WdNisSvc*" -and
    $_.Name -notlike "*Sense*" -and
    $_.Name -notlike "*SecurityHealthService*"
} | Select-Object -First 1

$NombreAntivirusTerceros = $null

# 4. EVALUACIÓN Y BALANZA DE DATOS
# El script revisa los resultados de sus 3 capas en orden de importancia. Si la Capa 1 
# funcionó, usa ese nombre. Si falló pero la Capa 2 encontró el programa en la memoria, 
# extrae los datos del archivo. Si no, usa el nombre del servicio hallado en la Capa 3.
if ($AV_WMI -and $AV_WMI.displayName) {
   # Si WMI responde bien, usa el nombre oficial reportado por Windows																	   
    $NombreAntivirusTerceros = $AV_WMI.displayName
} 
elseif ($AV_Proceso) {
	# Si encuentra el .exe en memoria, lee los metadatos/firma digital del archivo en disco																					   
    try {
        $InfoArchivo = $AV_Proceso.MainModule.FileVersionInfo
        if ($InfoArchivo.ProductName) { $NombreAntivirusTerceros = $InfoArchivo.ProductName }
        elseif ($InfoArchivo.FileDescription) { $NombreAntivirusTerceros = $InfoArchivo.FileDescription }
        elseif ($InfoArchivo.CompanyName) { $NombreAntivirusTerceros = $InfoArchivo.CompanyName }
        else { $NombreAntivirusTerceros = $AV_Proceso.ProcessName }
    } catch {
        $NombreAntivirusTerceros = "Antivirus Activo"
    }
} 
elseif ($AV_Servicio) {
	# Si no estaba en la lista de ejecutables, lo captura por su servicio en segundo plano																					  
    $NombreAntivirusTerceros = $AV_Servicio.DisplayName
}

# 5. EL INTERRUPTOR DE SEGURIDAD (SÍ O NO)
# Esta línea convierte el nombre del antivirus en una respuesta simple: VERDADERO (si hay 
# un antivirus de terceros) o FALSO (si la PC está desprotegida). Con este dato, el script 
# decidirá más adelante si es seguro darte la opción de apagar Microsoft Defender.
$ThirdPartyAV = [bool]$NombreAntivirusTerceros

# ==============================================================================
# 2. BASE DE DATOS DE LA LISTA MAESTRA 
# ==============================================================================
# Este bloque es el "molde" o plano del script. En lugar de escribir código repetido 
# para cada truco, creamos una lista organizada. Cada elemento tiene su ID real de Windows, 
# el nombre amigable que saldrá en la pantalla, el tipo de elemento (Servicio, Tarea 
# o Registro) y los valores para encenderlo o apagarlo. El motor del script leerá esta 
# lista sola más adelante para dibujar los botones y aplicar los cambios.
$ListaMaestra = @(

    # === FLUIDEZ DE INTERFAZ Y KERNEL === 
    # Ajustes profundos para que Windows reaccione más rápido. Reducen los tiempos de espera 
    # artificiales de Microsoft (como la latencia al abrir menús) y cambian la prioridad 
    # del procesador (Win32PrioritySeparation = 38) para que el chip Celeron/Atom se enfoque 
    # al 100% en la aplicación o juego que tengas abierto en pantalla.
    @{ ID = "Win32PrioritySeparation"; Nombre = "Prioridad Estándar de CPU"; Tipo = "RegistroHKLM"; Ruta = "SYSTEM\CurrentControlSet\Control\PriorityControl"; ValorDefault = 2; ValorMod = 38; Grupo = "Mejora la respuesta de las aplicaciones activas" },
    @{ ID = "MenuShowDelay";           Nombre = "Retraso en Despliegue de Menús";        Tipo = "RegistroHKCU"; Ruta = "Control Panel\Desktop"; ValorDefault = 400; ValorMod = 20; Grupo = "Fluidez" },
    @{ ID = "DragFullWindows";         Nombre = "Contenido Completo al Arrastrar";       Tipo = "RegistroHKCU"; Ruta = "Control Panel\Desktop"; ValorDefault = 1; ValorMod = 0; Grupo = "Fluidez" },
    @{ ID = "WaitToKillAppTimeout";    Nombre = "Espera Lenta al Cerrar Procesos";      Tipo = "RegistroHKCU"; Ruta = "Control Panel\Desktop"; ValorDefault = 5000; ValorMod = 2000; Grupo = "Fluidez" },

    # === SERVICIOS XBOX ===
    # Apaga todo el ecosistema de juegos de Xbox de Microsoft de fondo. En entornos LTSC 
    # puros esto no viene activo, pero si juegas títulos modernos de Steam o Epic Games, 
    # es mejor mantenerlos en Azul (Encendido) para evitar problemas de conexión multijugador.
    @{ ID = "XboxLiveAuthManager";          Nombre = "Inicio de Sesión Xbox";            Tipo = "Servicio"; Grupo = "Xbox" },
    @{ ID = "XblGameSave";                  Nombre = "Guardado en la Nube de Xbox";      Tipo = "Servicio"; Grupo = "Xbox" },
    @{ ID = "XboxGipSvc";                   Nombre = "Accesorios y Mandos Xbox";         Tipo = "Servicio"; Grupo = "Xbox" },
    @{ ID = "XboxNetApiSvc";                Nombre = "Red y Multijugador Xbox";          Tipo = "Servicio"; Grupo = "Xbox" },

    # === TELEMETRÍA Y PRIVACIDAD ===
    # Bloquea los servidores y servicios de recolección de datos de Microsoft. Evita que la 
    # computadora gaste ciclos de procesamiento (CPU) empaquetando y enviando reportes 
    # invisibles de diagnóstico de fondo.
    @{ ID = "AllowTelemetry";               Nombre = "Telemetría y Diagnósticos";        Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\Windows\DataCollection"; ValorDefault = 1; ValorMod = 0; Grupo = "Telemetría" },
    @{ ID = "dmwappushservice";             Nombre = "Notificaciones y Mensajes WAP";    Tipo = "Servicio"; Grupo = "Telemetría" },

    # === VIRTUALIZACIÓN Y EMPRESA ===
    # Servicios corporativos avanzados orientados a servidores o redes de oficina masivas. 
    # Para un usuario común o una PC portátil humilde, estos procesos consumen RAM sin sentido.
    @{ ID = "AppVClient";                   Nombre = "Cliente Virtual App-V";           Tipo = "Servicio"; Grupo = "Virtualización" },
    @{ ID = "UevAgentService";               Nombre = "Sincronización de Entorno UE-V";   Tipo = "Servicio"; Grupo = "Virtualización" },
    @{ ID = "shpamsvc";                     Nombre = "Gestión de Cuentas Compartidas";   Tipo = "Servicio"; Grupo = "Virtualización" },

    # === SEGURIDAD Y CIFRADO ===
    # Gestiona el bloqueo con contraseña de los discos duros. Si no cifras tu almacenamiento, 
    # apagarlo alivia los procesos del sistema.
    @{ ID = "BDESVC";                       Nombre = "Cifrado de Disco BitLocker";       Tipo = "Servicio"; Grupo = "BitLocker" },

    # === REDES ANTIGUAS Y REMOTAS ===
    # Remueve servicios heredados del pasado que Windows LTSC mantiene por compatibilidad, 
    # como el Fax, telefonías fijas antiguas o el acceso remoto para modificar tu registro 
    # desde otra computadora (un peligro de seguridad en redes locales).
    @{ ID = "TrkWks";                       Nombre = "Vínculos de Red Distribuidos";     Tipo = "Servicio"; Grupo = "Red Antigua" },
    @{ ID = "RemoteAccess";                 Nombre = "Conexión Remota y VPN";            Tipo = "Servicio"; Grupo = "Red Antigua" },
    @{ ID = "Fax";                          Nombre = "Servicio de Fax";                  Tipo = "Servicio"; Grupo = "Red Antigua" },
    @{ ID = "RemoteRegistry";               Nombre = "Acceso Remoto al Registro";        Tipo = "Servicio"; Grupo = "Red Antigua" },
    @{ ID = "NetTcpPortSharing";            Nombre = "Uso Compartido de Puertos TCP";    Tipo = "Servicio"; Grupo = "Red Antigua" },
    @{ ID = "TapiSrv";                      Nombre = "Servicios de Telefonía Fija";      Tipo = "Servicio"; Grupo = "Red Antigua" },

    # === BIOMETRÍA Y SENSORES ===
    # Apaga los sensores de geolocalización (evita que la PC busque dónde estás físicamente) 
    # y los lectores de huellas dactilares o tarjetas inteligentes si usas una PC de escritorio común.
    @{ ID = "ssh-agent";                    Nombre = "Agente de Autenticación SSH";      Tipo = "Servicio"; Grupo = "Biometría" },
    @{ ID = "WbioSrvc";                     Nombre = "Lectores de Huella y Biometría";   Tipo = "Servicio"; Grupo = "Biometría" },
    @{ ID = "ScDeviceEnum";                 Nombre = "Lector de Tarjetas Inteligentes";  Tipo = "Servicio"; Grupo = "Biometría" },
    @{ ID = "lfsvc";                        Nombre = "Ubicación y Geolocalización";      Tipo = "Servicio"; Grupo = "Biometría" },

    # === RENDIMIENTO Y SYSMAIN ===
    # Desactiva la indexación y la precarga agresiva (SysMain) en el disco. En procesadores 
    # Atom/Celeron, estos procesos de búsqueda suelen poner el uso de CPU al 100% de la nada, 
    # congelando el teclado o el mouse mientras trabajas.
    @{ ID = "EnablePrefetcher";             Nombre = "Precarga SysMain (Prefetcher)";   Tipo = "RegistroHKLM"; Ruta = "SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"; ValorDefault = 3; ValorMod = 0; Grupo = "Sysmain" },
    @{ ID = "WpcMonSvc";                    Nombre = "Control Parental";                 Tipo = "Servicio"; Grupo = "Sysmain" },
    @{ ID = "wisvc";                        Nombre = "Programa Windows Insider";         Tipo = "Servicio"; Grupo = "Sysmain" },
    @{ ID = "PreventIndexingOnLowDiskSpaceMB"; Nombre = "Indexación de Búsqueda en Disco"; Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\Windows\Windows Search"; ValorDefault = 0; ValorMod = 1; Grupo = "Search" },

    # === WINDOWS UPDATE Y MANTENIMIENTO ===
    # Interruptores avanzados de control para pausar o congelar las actualizaciones automáticas 
    # molestas y remover los botones naranjas de "Actualizar y apagar" del menú de inicio.
    @{ ID = "WindowsUpdateMaster";          Nombre = "Actualizaciones Windows Update"; Tipo = "EspecialWinUpdate"; Grupo = "WinUpdate" },
    @{ ID = "HideUpdateInShutdownMenu";     Nombre = "Actualizar al reiniciar/apagar"; Tipo = "EspecialOcultarActualizar"; Grupo = "WinUpdate" },

    # === MULTIMEDIA Y ACCESORIOS ===
    # Gestiona los añadidos estéticos de Windows. Apaga Cortana (que no viene en LTSC pero 
    # bloquea su rastro de búsqueda), el Bluetooth (si no lo usas) y remueve las transparencias 
    # visuales de las ventanas para aliviar la débil tarjeta gráfica integrada Intel HD Graphics.
    @{ ID = "AllowCortana";                 Nombre = "Asistente de Búsqueda Cortana";    Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\Windows\Windows Search"; ValorDefault = 1; ValorMod = 0; Grupo = "Cortana" },
    @{ ID = "MapsBroker";                   Nombre = "Descarga de Mapas Sin Conexión";   Tipo = "Servicio"; Grupo = "Mapas" },
    @{ ID = "TabletInputService";           Nombre = "Teclado Táctil y Escritura a Mano";Tipo = "Servicio"; Grupo = "Táctil" },
    @{ ID = "WMPNetworkSvc";                Nombre = "Red de Windows Media Player";      Tipo = "Servicio"; Grupo = "Multimedia" },
    @{ ID = "pla";                          Nombre = "Registros de Rendimiento y Alertas"; Tipo = "Servicio"; Grupo = "Logs" },
    @{ ID = "Spooler";                      Nombre = "Servicio de Impresoras";           Tipo = "Servicio"; Grupo = "Impresión" },
    @{ ID = "bthserv";                      Nombre = "Soporte para Bluetooth";           Tipo = "Servicio"; Grupo = "Bluetooth" },
    @{ ID = "VisualFXSetting";              Nombre = "Efectos Visuales Avanzados";       Tipo = "RegistroHKCU"; Ruta = "Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; ValorDefault = 1; ValorMod = 2; Grupo = "Efectos" },
    @{ ID = "EnableTransparency";           Nombre = "Transparencia en las Ventanas";   Tipo = "RegistroHKCU"; Ruta = "SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"; ValorDefault = 1; ValorMod = 0; Grupo = "Rendimiento" },

    # === ANTIVIRUS Y SEGURIDAD INTEGRADA === 
    # Módulos profundos de Microsoft Defender. Si tu Capa Detective descubrió un antivirus 
    # de terceros, estos interruptores te permitirán deshabilitar el Defender para recuperar 
    # valiosa memoria RAM y un gran porcentaje de CPU en reposo.
    @{ ID = "WinDefend";                    Nombre = "Antivirus Microsoft Defender";     Tipo = "Servicio"; Grupo = "Antivirus" },
    @{ ID = "Sense";                        Nombre = "Monitoreo de Amenazas Sense";      Tipo = "Servicio"; Grupo = "Antivirus" },
    @{ ID = "WdNisSvc";                     Nombre = "Protección de Red de Defender";    Tipo = "Servicio"; Grupo = "Antivirus" },
    @{ ID = "SecurityHealthService";        Nombre = "Centro de Seguridad de Windows";   Tipo = "Servicio"; Grupo = "Antivirus" },
    @{ ID = "DisableAntiSpyware";           Nombre = "Protección AntiSpyware Basica";   Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\Windows Defender"; ValorDefault = 0; ValorMod = 1; Grupo = "Antivirus" },
    @{ ID = "DisableRealtimeMonitoring";    Nombre = "Protección en Tiempo Real";       Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"; ValorDefault = 0; ValorMod = 1; Grupo = "Antivirus" },
    @{ ID = "DisableBehaviorMonitoring";    Nombre = "Análisis de Comportamiento";       Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"; ValorDefault = 0; ValorMod = 1; Grupo = "Antivirus" },
    @{ ID = "DisableCatchupQuickScan";      Nombre = "Escaneo Rápido al Encender";       Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\Windows Defender\Scan"; ValorDefault = 0; ValorMod = 1; Grupo = "Antivirus" },
    @{ ID = "DisableCatchupFullScan";       Nombre = "Escaneo Profundo al Encender";     Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\Windows Defender\Scan"; ValorDefault = 0; ValorMod = 1; Grupo = "Antivirus" },
    @{ ID = "EnableSmartScreen";            Nombre = "Filtro de Archivos SmartScreen";   Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\Windows\System"; ValorDefault = 1; ValorMod = 0; Grupo = "Antivirus" },
    @{ ID = "DontOfferThroughWUAU";         Nombre = "Escaneo de Malware Mensual (MRT)"; Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\MRT"; ValorDefault = 0; ValorMod = 1; Grupo = "Antivirus" },

    # === TELEMETRÍA Y TAREAS LTSC ===
    # Tareas programadas internas que Windows LTSC ejecuta cuando dejas la PC "en reposo". 
    # Provocan que los ventiladores de las laptops Celeron se aceleren al máximo de repente. 
    # Aquí es donde va también el truco universal para evitar la fragmentación de subprocesos.
    @{ ID = "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"; Nombre = "Análisis de Compatibilidad de Apps"; Tipo = "Tarea"; Grupo = "Telemetría 2021" },
    @{ ID = "\Microsoft\Windows\Application Experience\ProgramDataUpdater";               Nombre = "Seguimiento de Uso de Programas";   Tipo = "Tarea"; Grupo = "Telemetría 2021" },
    @{ ID = "OneSyncSvc";                   Nombre = "Sincronización de Contactos";      Tipo = "Servicio"; Grupo = "Rendimiento" },
    @{ ID = "DisabledWER";                  Nombre = "Envío de Informes de Error";       Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting"; ValorDefault = 0; ValorMod = 1; Grupo = "Logs" },

    # === OPTIMIZACIONES DE MEMORIA Y SISTEMA ===
    @{ ID = "SvcHostSplitThresholdInKB"; Nombre = "Separar procesos del sistema"; Tipo = "RegistroHKLM"; Ruta = "SYSTEM\CurrentControlSet\Control"; ValorDefault = 380000; ValorMod = 4294967295; Grupo = "Rendimiento" },
    @{ ID = "DisableSearchBoxSuggestions";  Nombre = "Sugerencias de Bing en Búsqueda";   Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Policies\Microsoft\Windows\Windows Search"; ValorDefault = 0; ValorMod = 1; Grupo = "Cortana" },
    @{ ID = "NoRecentDocsHistory";          Nombre = "Historial de Archivos Recientes";  Tipo = "RegistroHKCU"; Ruta = "Software\Microsoft\Windows\CurrentVersion\Explorer"; ValorDefault = 0; ValorMod = 1; Grupo = "Rendimiento" },

    # === MANTENIMIENTO PROGRAMADO ===
    # Controla las tareas de desfragmentación automática y el mantenimiento diario de las 2:00 AM. 
    # Mantenerlos activos ayuda a los discos mecánicos lentos a no degradar su velocidad.																																																									 								  
    @{ ID = "\Microsoft\Windows\Defrag\ScheduledDefrag"; Nombre = "Desfragmentación de Disco"; Tipo = "Tarea"; Grupo = "Mantenimiento" },
    @{ ID = "MaintenanceDisabled";          Nombre = "Mantenimiento Automático Diario";  Tipo = "RegistroHKLM"; Ruta = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance"; ValorDefault = 0; ValorMod = 1; Grupo = "Mantenimiento" }
)

# ==============================================================================
# === MECANISMO DE RESPALDO Y CAPTURA DE ESTADO INICIAL DEL SO ===
# ==============================================================================

# 1. DEFINICIÓN DE LA RUTA DE GUARDADO GLOBAL
# Creamos la ruta de la carpeta dentro de "ProgramData". Al ser una carpeta global 
# de Windows, el archivo de respaldo estará a salvo de borrados accidentales 
# y se mantendrá disponible para cualquier usuario de la computadora.
$RutaDataEli = "$env:ProgramData\EliOptimizer"
$RutaBackupInicial = "$RutaDataEli\BackupInicial.json"

# 2. EL CONGELADOR DE ESTADO (LA FUNCIÓN DE CAPTURA)
# Esta función es la que se encarga de tomar la "fotografía" en frío del sistema. 
# Solo se ejecutará una vez en la vida del programa. Si el usuario modifica cosas 
# después, esta función no tocará el respaldo para no perder los valores originales.
function Capturar-EstadoInicialSO {
    
    # A. CREAR LA CARPETA DE SEGURIDAD
    # Si es la primera vez que abres EliOptimizer, esta línea crea la carpeta 
    # en el disco duro de forma forzada. Si ya existe, no hace nada.
    if (-not (Test-Path $RutaDataEli)) {
        New-Item -ItemType Directory -Path $RutaDataEli -Force | Out-Null
    }

    # B. EL CANDADO DEL RESPALDO (VERIFICACIÓN DE EXISTENCIA)
    # Aquí está el truco inteligente: el script revisa si ya existe el archivo JSON. 
    # Si ya existe, ignora todo lo de adentro. Esto garantiza que el respaldo 
    # jamás se sobrescriba con valores ya optimizados o manipulados por error.
    if (-not (Test-Path $RutaBackupInicial)) {
        $EstadoInicial = @{}

        # C. EL ESCÁNER ELEMENTO POR ELEMENTO
        # El script inicia un bucle que lee toda tu "$ListaMaestra". Va a ir a revisar 
        # tu Windows original para ver en qué estado de fábrica se encuentra cada cosa.
        foreach ($Item in $ListaMaestra) {
            $ID = $Item.ID
            $Info = @{
                Tipo   = $Item.Tipo
                Ruta   = $Item.Ruta
                Existe = $true
                Estado = $null
            }

            # D. ANALIZAR SERVICIOS NATIVOS
            # Si el elemento es un Servicio, el script revisa si existe en Windows y guarda 
            # cómo arranca de fábrica (Automático, Manual o Deshabilitado). Si el servicio 
            # fue borrado previamente de la ISO, anota que no existe.
            if ($Item.Tipo -eq "Servicio") {
                $Svc = Get-Service -Name $ID -ErrorAction SilentlyContinue
                if ($Svc) {
                    $Info.Estado = $Svc.StartType.ToString()
                } else {
                    $Info.Existe = $false
                }
            }
            
            # E. ANALIZAR TAREAS PROGRAMADAS
            # Si es una Tarea de mantenimiento de fondo, el script corta la ruta y el nombre 
            # para buscarla en el programador de Windows y archivar si está activa o apagada.
            elseif ($Item.Tipo -eq "Tarea") {
                if ($ID -like "*\*") {
                    $RutaT  = Split-Path $ID -Parent
                    $NombT = Split-Path $ID -Leaf
                } else {
                    $RutaT  = "\"
                    $NombT = $ID
                }
                if (-not $RutaT.EndsWith("\")) { $RutaT += "\" }
                if (-not $RutaT.StartsWith("\")) { $RutaT = "\" + $RutaT }

                $Sched = Get-ScheduledTask -TaskPath $RutaT -TaskName $NombT -ErrorAction SilentlyContinue
                if ($Sched) {
                    $Info.Estado = $Sched.State.ToString()
                } else {
                    $Info.Existe = $false
                }
            }
            
            # F. ANALIZAR REGISTROS PROFUNDOS (HKLM Y HKCU)
            # Si el truco es una clave del registro, el script va a la colmena correspondiente 
            # y lee el número original. Si la clave no existía de fábrica, le asigna tu "ValorDefault".
            elseif ($Item.Tipo -in @("RegistroHKLM", "RegistroHKCU")) {
                $Raiz = if ($Item.Tipo -eq "RegistroHKLM") { "HKLM:\" } else { "HKCU:\" }
                $Reg = Get-ItemProperty -Path "$Raiz$($Item.Ruta)" -Name $ID -ErrorAction SilentlyContinue
                if ($null -ne $Reg) {
                    $Info.Estado = $Reg.$ID
                } else {
                    $Info.Estado = $Item.ValorDefault
                }
            }
            
            # G. CASO ESPECIAL: ACTUALIZACIONES (AUOPTIONS)
            # Lee de forma específica las políticas complejas de Windows Update para resguardar 
            # el estado nativo de los parches de seguridad de Microsoft.
            elseif ($Item.Tipo -eq "EspecialWinUpdate") {
                $RegAU = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -ErrorAction SilentlyContinue).AUOptions
                $Info.Estado = $RegAU
            }
            
            # H. CASO ESPECIAL: OCULTAR BOTONES DE APAGADO
            # Archiva el estado original de la directiva que controla los botones naranjas 
            # de actualización del menú de inicio.
            elseif ($Item.Tipo -eq "EspecialOcultarActualizar") {
                $RegNoAU = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "NoAUAsDefaultShutdownOption" -ErrorAction SilentlyContinue).NoAUAsDefaultShutdownOption
                $Info.Estado = $RegNoAU
            }

            # I. GUARDAR EN LA MEMORIA TEMPORAL
            # Mete toda la información recolectada del elemento actual en la bolsa del Estado Inicial.
            $EstadoInicial[$ID] = $Info
        }

        # J. CREACIÓN DEL ARCHIVO FISICO (.JSON)
        # Convierte toda la lista ordenada de datos en un archivo de texto con formato estructurado 
        # JSON y lo escribe en el disco duro usando codificación limpia UTF-8.
        $EstadoInicial | ConvertTo-Json -Depth 5 | Out-File -FilePath $RutaBackupInicial -Encoding utf8 -Force
    }
}

# 3. DISPARAR LA CAPTURA INICIAL
# Ejecutamos la función de inmediato en frío. Si es la primera vez que se abre en el LTSC 
# limpio, creará el archivo JSON; si ya existía de antes, pasará de largo en milisegundos.
Capturar-EstadoInicialSO

# ==============================================================================
# 4. DISEÑO DE LA VENTANA PRINCIPAL Y CONTENEDORES GRÁFICOS (INTERFAZ VISUAL)
# ==============================================================================

# 1. EL MOLDE DEL FORMULARIO PRINCIPAL
# Instanciamos el objeto de la ventana y definimos sus propiedades estéticas de fábrica.
# Configuramos un tamaño compacto (350x480), un esquema de fondo gris oscuro estilo BraveControl 
# y letras claras para garantizar un alto contraste visual en pantallas humildes.
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "EliOptimizer LTSC"
$Form.Size = New-Object System.Drawing.Size(350, 480)
$Form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$Form.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)

# 2. BLOQUEO DE REDIMENSIONADO Y CONTROL DE VENTANA
# Fijamos los bordes de la ventana como "FixedSingle" para evitar que el usuario estire 
# o deforme la interfaz con el mouse. Apagamos el botón de maximizar, dejamos el de 
# minimizar y removemos el icono genérico de la barra para darle un aspecto de app moderna.
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$Form.MaximizeBox = $false
$Form.MinimizeBox = $true
$Form.ShowIcon = $false

# 3. CABECERA INFORMATIVA (EL CONTADOR DINÁMICO)
# Creamos una etiqueta de texto alineada a la derecha que servirá como marcador en tiempo real. 
# Mostrará cuántos elementos están seleccionados para optimizar frente al total de la lista. 
# La añadimos al formulario principal para fijarla en la parte superior.
$Header = New-Object System.Windows.Forms.Label
$Header.Text = "0 / $($ListaMaestra.Count) a Desactivar"
$Header.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$Header.ForeColor = [System.Drawing.Color]::Gray
$Header.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$Header.Size = New-Object System.Drawing.Size(310, 25)
$Header.Location = New-Object System.Drawing.Point(20, 15)
$Header.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$Form.Controls.Add($Header)

# 4. EL TÍTULO DE LA IDENTIDAD DE LA HERRAMIENTA
# Colocamos el logotipo de texto principal de tu marca (LTSC CONTROL) con una fuente en negrita 
# y color blanco sólido para que destaque de forma elegante en la esquina superior izquierda.
$TitleLbl = New-Object System.Windows.Forms.Label
$TitleLbl.Text = "ELIOPTIMIZER"
$TitleLbl.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$TitleLbl.ForeColor = [System.Drawing.Color]::White
$TitleLbl.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$TitleLbl.Size = New-Object System.Drawing.Size(150, 30)
$TitleLbl.Location = New-Object System.Drawing.Point(20, 10)
$Form.Controls.Add($TitleLbl)

# 5. EL PANEL FLOTANTE CON SCROLL (EL CONTENEDOR DE SWITCHES)
# Como la lista maestra tiene muchos trucos y no caben en una ventana pequeña de 480px, 
# creamos un panel contenedor intermedio con la propiedad "AutoScroll = $true". 
# Esto genera una barra de desplazamiento lateral suave que permite al usuario bajar 
# y subir para ver todos los interruptores cómodamente sin agrandar la ventana.
$Panel = New-Object System.Windows.Forms.Panel
$Panel.Size = New-Object System.Drawing.Size(325, 310)
$Panel.Location = New-Object System.Drawing.Point(15, 50)
$Panel.AutoScroll = $true
$Panel.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$Panel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$Panel.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)

# 6. CONFIGURACIÓN DE SENSIBILIDAD DEL DESPLAZAMIENTO
# Ajustamos la velocidad con la que responde la barra de scroll cuando el usuario mueve 
# la rueda del mouse (Scroll Wheel). Así la lista bajará de forma fluida y no a saltos bruscos.
$Panel.VerticalScroll.SmallChange = 10
$Panel.VerticalScroll.LargeChange = 50

# 7. ACOPLAR EL PANEL INTERMEDIO
# Inyectamos este panel con scroll dentro de los controles del formulario principal.
$Form.Controls.Add($Panel)

# 8. VARIABLES DE CONTROL DE POSICIÓN
# Creamos un diccionario vacío para indexar los interruptores en memoria y una variable numérica 
# de posición vertical (YPos) inicializada en 10 píxeles. Servirá como coordenada para pintar 
# el primer switch de la lista.
$ControlesSwitch = @{}
$YPos = 10

# ==============================================================================
# 5. FUNCIÓN DE DIBUJO VECTORIAL DEL INTERRUPTOR (TOGGLE SWITCH ESTILO SMARTPHONE)
# ==============================================================================
# Esta función es un motor de diseño gráfico propio. Crea un panel interactivo de 
# 40x20 píxeles que cambia de color y mueve un círculo blanco de lado a lado cuando el 
# usuario le hace clic, simulando un interruptor moderno de celular.
function Crear-ToggleSwitch {
    param ($x, $y, $estadoInicial, $deshabilitado = $false)
    
    $Pb = New-Object System.Windows.Forms.PictureBox
    $Pb.Size = New-Object System.Drawing.Size(45, 22)
    $Pb.Location = New-Object System.Drawing.Point($x, $y)
    $Pb.Cursor = if ($deshabilitado) { [System.Windows.Forms.Cursors]::Default } else { [System.Windows.Forms.Cursors]::Hand }
    $Pb.Tag = $estadoInicial
    $Pb.Enabled = -not $deshabilitado

    #2. CREACIÓN DEL MOTOR DE RENDERIZADO VECTORIAL EN TIEMPO REAL (EVENTO PAINT)
	#Escuchamos el evento Add_Paint para redibujar el control dinámicamente desde cero.
	#Activamos el suavizado de bordes (AntiAlias) para evitar píxeles serruchados y calculamos
	#la paleta de colores: azul si está activo, gris oscuro si está apagado o gris tenue si está bloqueado.
	$Pb.Add_Paint({
        param($sender, $e)
        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        
        if (-not $sender.Enabled) {
            $FondoColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
        } else {
            $FondoColor = if ($sender.Tag) { [System.Drawing.Color]::FromArgb(0, 120, 215) } else { [System.Drawing.Color]::FromArgb(75, 75, 75) }
        }
        
        $BrushFondo = New-Object System.Drawing.SolidBrush($FondoColor)
	#3. CONSTRUCCIÓN DEL FONDO REDONDEADO (CÁPSULA)
	#Trazamos una ruta geométrica uniendo cuatro arcos de 10 píxeles de radio en los bordes.
	#Rellenamos la cápsula con el color de fondo correspondiente y liberamos de inmediato
	#el objeto de dibujo para evitar fugas de memoria RAM en el sistema.
	    $Rect = New-Object System.Drawing.Rectangle(0, 0, 44, 21)
		$Path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $Radius = 10
        $Path.AddArc(0, 0, $Radius*2, $Radius*2, 180, 90)
        $Path.AddArc((44 - $Radius*2), 0, $Radius*2, $Radius*2, 270, 90)
        $Path.AddArc((44 - $Radius*2), (21 - $Radius*2), $Radius*2, $Radius*2, 0, 90)
        $Path.AddArc(0, (21 - $Radius*2), $Radius*2, $Radius*2, 90, 90)
        $Path.CloseAllFigures()
        $g.FillPath($BrushFondo, $Path)
		
	#4. DIBUJO DEL CÍRCULO DESLIZANTE (PERILLA)
	#Movemos el círculo a X=24 si el switch está activado o a X=3 si está desactivado.
	#Pintamos la perilla blanca y ejecutamos la limpieza masiva con .Dispose() de todos
	#los pinceles vectoriales utilizados durante el ciclo de renderizado.
		$PosicionX = if ($sender.Tag) { 24 } else { 3 }
        $ColorCirculo = if (-not $sender.Enabled) { [System.Drawing.Color]::Gray } else { [System.Drawing.Color]::White }
        $BrushCirculo = New-Object System.Drawing.SolidBrush($ColorCirculo)
        $g.FillEllipse($BrushCirculo, $PosicionX, 3, 15, 15)
        
        $BrushFondo.Dispose()
        $BrushCirculo.Dispose()
		$Path.Dispose()
    })
	
	#5. GESTOR DE INTERACTIVIDAD Y ACTUALIZACIÓN DE CONTADOR (EVENTO CLICK)
	#Al hacer clic sobre el control, invertimos el estado guardado en .Tag, llamamos a
	#.Invalidate() para forzar un rediseño gráfico instantáneo y recalculamos en caliente
	#la cabecera informativa con la cantidad exacta de switches marcados en falso.
		$Pb.Add_Click({
        param($sender, $e)
        if ($sender.Enabled) {
            $sender.Tag = -not $sender.Tag
            $sender.Invalidate()
            
            $Apagados = ($ControlesSwitch.Values | Where-Object { -not $_.Control.Tag }).Count
            $Header.Text = "$Apagados / $($ControlesSwitch.Count) a Desactivar"
        }
    })																							 
    return $Pb
}		
		
#==============================================================================
#5. GENERACIÓN DINÁMICA DE LA LISTA Y ESCANEO DE ESTADOS DEL SISTEMA
#==============================================================================

	# 1. BUCLE DE LECTURA DE LA LISTA MAESTRA
	#Recorremos cada objeto hashtable declarado en la lista maestra para evaluar uno por uno
	#los componentes del sistema operativo y definir las banderas de control en memoria.
	foreach ($Item in $ListaMaestra) {
    $ActivoEnSistema = $true
    $BloquearPorAV = $false
	
	# 2. ESCUDO DE SEGURIDAD PARA ANTIVIRUS DE TERCEROS
	#Si el elemento pertenece al grupo Antivirus y detectamos un software externo instalado,
	#forzamos el bloqueo ($BloquearPorAV) e inhabilitamos el switch para proteger la seguridad.
	if ($Item.Grupo -eq "Antivirus" -and $ThirdPartyAV) {
        $BloquearPorAV = $true
        $ActivoEnSistema = $false
    }
	
	# 3. VERIFICACIÓN DE POLÍTICAS ESPECIALES DE WINDOWS UPDATE
	#Inspeccionamos las claves de directivas de grupo para verificar si las actualizaciones
	#automáticas o el menú de reinicio ya se encuentran limitados en el Registro.
	if (-not $BloquearPorAV) {
        if ($Item.Tipo -eq "EspecialWinUpdate") {
            $RegAU = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -ErrorAction SilentlyContinue).AUOptions
            if ($RegAU -eq 2) { 
                $ActivoEnSistema = $false 
            } else { 
                $ActivoEnSistema = $true 
            }
        }
		
	# 4. AUDITORÍA DE SERVICIOS DEL SISTEMA
	#Consultamos si el servicio existe con Get-Service y evaluamos su tipo de arranque.
	#Si el servicio no está en el sistema o su tipo de inicio es Disabled, marcamos la casilla en falso
	elseif ($Item.Tipo -eq "EspecialOcultarActualizar") {
            $RegNoAU = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "NoAUAsDefaultShutdownOption" -ErrorAction SilentlyContinue).NoAUAsDefaultShutdownOption
            if ($RegNoAU -eq 1) {
                $ActivoEnSistema = $false
            } else {
                $ActivoEnSistema = $true
            }
        }
		
	# 5. AUDITORÍA DE TAREAS PROGRAMADAS
	#Desglosamos la ruta y el nombre de la tarea mediante Split-Path, normalizamos los separadores
	#de directorio () e interrogamos al Programador de Tareas para detectar si está deshabilitada.
	elseif ($Item.Tipo -eq "Servicio") {
            $Svc = Get-Service -Name $Item.ID -ErrorAction SilentlyContinue
            if (-not $Svc) {
                $ActivoEnSistema = $false
            } elseif ($Svc.StartType -eq "Disabled") { 
                $ActivoEnSistema = $false 
            }
        }
        elseif ($Item.Tipo -eq "Tarea") {
            if ($Item.ID -like "*\*") {
                $RutaTarea  = Split-Path $Item.ID -Parent
                $NombreTarea = Split-Path $Item.ID -Leaf
            } else {
                $RutaTarea   = "\"
                $NombreTarea = $Item.ID
            }
            if (-not $RutaTarea.EndsWith("\")) { $RutaTarea += "\" }
            if (-not $RutaTarea.StartsWith("\")) { $RutaTarea = "\" + $RutaTarea }
            $Sched = Get-ScheduledTask -TaskPath $RutaTarea -TaskName $NombreTarea -ErrorAction SilentlyContinue
            if (-not $Sched) {
                $ActivoEnSistema = $false
            } elseif ($Sched.State -eq "Disabled") { 
                $ActivoEnSistema = $false 
            }
        }
		
	# 6. COMPROBACIÓN DIRECTA DE REGISTROS HKLM Y HKCU
	#Leemos los valores modificados del Registro de Windows en la ruta asignada y los comparamos
	#directamente con el valor objetivo ($ValorMod) para reflejar la postura actual del sistema.
	elseif ($Item.Tipo -eq "RegistroHKLM") {
            $RegVal = (Get-ItemProperty -Path "HKLM:\$($Item.Ruta)" -Name $Item.ID -ErrorAction SilentlyContinue).$($Item.ID)
            if ($RegVal -eq $Item.ValorMod) { $ActivoEnSistema = $false }
        }
        elseif ($Item.Tipo -eq "RegistroHKCU") {
            $RegVal = (Get-ItemProperty -Path "HKCU:\$($Item.Ruta)" -Name $Item.ID -ErrorAction SilentlyContinue).$($Item.ID)
            if ($RegVal -eq $Item.ValorMod) { $ActivoEnSistema = $false }
        }
		
	# 7. VALIDACIÓN INTEGRAL DE SALUD DE WINDOWS DEFENDER
	#Si el grupo actual es "Antivirus", verificamos el estado real de los servicios críticos WinDefend
	#y SecurityHealthService. Si están detenidos o deshabilitados, marcamos la función como inactiva.
	if ($Item.Grupo -eq "Antivirus") {
            $SvcDefend = Get-Service -Name "WinDefend" -ErrorAction SilentlyContinue
            $SvcHealth = Get-Service -Name "SecurityHealthService" -ErrorAction SilentlyContinue
            if (-not $SvcDefend -or -not $SvcHealth -or $SvcDefend.Status -eq "Stopped" -or $SvcDefend.StartType -eq "Disabled") {
                $ActivoEnSistema = $false
            }
        }
    }
    # 8. FABRICACIÓN DEL TEXTO PRINCIPAL
    # Creamos una etiqueta visual para mostrar el nombre amigable de la optimización (ej. "Separar 
    # procesos del sistema"). Si el switch fue bloqueado por el candado del antivirus, pintamos 
    # las letras en gris apagado; si no, se muestran en un color claro de alta legibilidad.
    $LabelNombre = New-Object System.Windows.Forms.Label
    $LabelNombre.Text = $Item.Nombre
    $LabelNombre.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $LabelNombre.ForeColor = if ($BloquearPorAV) { [System.Drawing.Color]::Gray } else { [System.Drawing.Color]::FromArgb(220, 220, 220) }
    $LabelNombre.Size = New-Object System.Drawing.Size(220, 18)
    $LabelNombre.Location = New-Object System.Drawing.Point(10, $YPos)
    $Panel.Controls.Add($LabelNombre)

    # 9. FABRICACIÓN DEL SUBTEXTO (LA CATEGORÍA O ADVERTENCIA)
    # Creamos una segunda etiqueta más pequeña justo debajo del nombre. Si el truco está bloqueado, 
    # le avisa al usuario qué antivirus lo está protegiendo en ese instante. Si está libre, muestra 
    # a qué categoría pertenece el truco (ej. "Categoría: Rendimiento") para mantener el orden.
    $LabelGrupo = New-Object System.Windows.Forms.Label
    $LabelGrupo.Text = if ($BloquearPorAV) { "Protegido por: $NombreAntivirusTerceros" } else { "$($Item.Grupo)" }
    $LabelGrupo.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $LabelGrupo.ForeColor = [System.Drawing.Color]::Gray
    $LabelGrupo.Size = New-Object System.Drawing.Size(220, 15)
    $LabelGrupo.Location = New-Object System.Drawing.Point(10, ($YPos + 18))
    $Panel.Controls.Add($LabelGrupo)

    # 10. ACOPLAMIENTO DEL INTERRUPTOR DESLIZANTE
    # Invocamos a tu función de diseño "Crear-ToggleSwitch". Le pasamos la coordenada X fija en 240 
    # (para que todos los switches queden perfectamente alineados a la derecha), la coordenada Y actual, 
    # el color calculado (Azul o Gris) y si debe nacer congelado por seguridad. Lo pegamos en el panel.
    $Switch = Crear-ToggleSwitch -x 240 -y ($YPos + 4) -estadoInicial $ActivoEnSistema -deshabilitado $BloquearPorAV
    $Panel.Controls.Add($Switch)

    # 11. INDEXACIÓN EN EL DICCIONARIO DE MEMORIA
    # Guardamos el interruptor recién fabricado dentro de la lista "$ControlesSwitch" usando su ID real. 
    # Esto es vital para que más adelante los botones masivos puedan apagar o encender las cajitas en bloque.
    $ControlesSwitch[$Item.ID] = @{ Control = $Switch; Metadata = $Item; Bloqueado = $BloquearPorAV }

    # 12. CÁLCULO DE LA COORDENADA VERTICAL (EL APILADOR)
    # Aquí ocurre el truco físico del scroll: cada vez que termina una fila, le sumamos 42 píxeles 
    # a la variable "$YPos". Así, cuando el bucle vuelva a iniciar con el siguiente truco de la lista, 
    # se dibujará exactamente abajo del anterior, evitando que los textos se encimen o se pisen.
    $YPos += 42
}

# ==============================================================================
# 7. PANEL DE CONTROL DE BOTONES MASIVOS (ACCIONES EN BLOQUE)
# ==============================================================================

# 1. EL BOTÓN "DESACTIVAR TODO" (ALIGERAR MÁQUINA)
# Instanciamos el botón y definimos un estilo minimalista plano, sin bordes toscos, 
# con fondo gris oscuro y letras blancas. Lo colocamos en la esquina inferior izquierda 
# del formulario principal.
$BtnDesactivarTodo = New-Object System.Windows.Forms.Button
$BtnDesactivarTodo.Text = "Desact. todo"
$BtnDesactivarTodo.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$BtnDesactivarTodo.Size = New-Object System.Drawing.Size(68, 32)
$BtnDesactivarTodo.Location = New-Object System.Drawing.Point(12, 395)
$BtnDesactivarTodo.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnDesactivarTodo.FlatAppearance.BorderSize = 0
$BtnDesactivarTodo.ForeColor = [System.Drawing.Color]::White
$BtnDesactivarTodo.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)

# 2. LOGICA OPERATIVA DE APAGADO MASIVO
# Cuando el usuario hace clic en este botón, el programa recorre todo el diccionario 
# de interruptores. Si el interruptor no está bloqueado por el candado del antivirus, 
# cambia su estado interno forzadamente a FALSO y le ordena redibujarse en GRIS. 
# Al final, actualiza el marcador de la cabecera mostrando que todo se va a optimizar.
$BtnDesactivarTodo.Add_Click({
    foreach ($S in $ControlesSwitch.Values) { 
        if (-not $S.Bloqueado) {
            $S.Control.Tag = $false; $S.Control.Invalidate() 
        }
    }
    $Header.Text = "$($ControlesSwitch.Count) / $($ControlesSwitch.Count) a Desactivar"
})
$Form.Controls.Add($BtnDesactivarTodo)

# 3. EL BOTÓN "ACTIVAR TODO" (MANTENER ESTADO SEGURO / FÁBRICA)
# Creamos el segundo botón flotante con el mismo diseño estético y dimensiones, 
# pero desplazado un poco más a la derecha en la coordenada X (posición 86) para que 
# quede alineado perfectamente al lado del botón de apagado.
$BtnActivarTodo = New-Object System.Windows.Forms.Button
$BtnActivarTodo.Text = "Activar todo"
$BtnActivarTodo.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$BtnActivarTodo.Size = New-Object System.Drawing.Size(68, 32)
$BtnActivarTodo.Location = New-Object System.Drawing.Point(86, 395)
$BtnActivarTodo.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnActivarTodo.FlatAppearance.BorderSize = 0
$BtnActivarTodo.ForeColor = [System.Drawing.Color]::White
$BtnActivarTodo.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)

# 4. LOGICA OPERATIVA DE ENCENDIDO MASIVO
# Al hacer clic aquí, el script repite el recorrido por toda tu lista de memoria, 
# pero esta vez fuerza a todos los interruptores libres a cambiar a VERDADERO, 
# pintándolos de nuevo en AZUL. El marcador superior se reinicia inmediatamente a cero.
$BtnActivarTodo.Add_Click({
    foreach ($S in $ControlesSwitch.Values) { 
        if (-not $S.Bloqueado) {
            $S.Control.Tag = $true; $S.Control.Invalidate() 
        }
    }
    $Header.Text = "0 / $($ControlesSwitch.Count) a Desactivar"
})
$Form.Controls.Add($BtnActivarTodo)

# ==============================================================================
# 8. EL BOTÓN "RESTABLECER" (RETORNO AL ESTADO PREVIO)
# ==============================================================================

# 1. EL BOTÓN VISUAL DE RESTAURACIÓN
# Creamos la interfaz del botón manteniéndonos firmes en tu diseño de estilo plano (Flat), 
# sin bordes toscos, color gris y texto blanco. Lo ubicamos a continuación de los 
# anteriores en la coordenada X (posición 160) para mantener la simetría inferior.
$BtnRestablecer = New-Object System.Windows.Forms.Button
$BtnRestablecer.Text = "Restablecer"
$BtnRestablecer.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$BtnRestablecer.Size = New-Object System.Drawing.Size(70, 32)
$BtnRestablecer.Location = New-Object System.Drawing.Point(160, 395)
$BtnRestablecer.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnRestablecer.FlatAppearance.BorderSize = 0
$BtnRestablecer.ForeColor = [System.Drawing.Color]::White
$BtnRestablecer.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)

# 2. LÓGICA INTELIGENTE DE LECTURA DE RESPALDO
# Cuando el usuario hace clic aquí, el programa realiza una bifurcación:
# CASO A: Si el archivo "BackupInicial.json" existe en la carpeta oculta de Windows, 
# el script lo descompila en la memoria RAM y procesa la restauración selectiva.
$BtnRestablecer.Add_Click({
    if (Test-Path $RutaBackupInicial) {
        $Backup = Get-Content -Path $RutaBackupInicial -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
        
        # 3. RECORRIDO DEL RESPALDO ELEMENTO POR ELEMENTO
        # El script escanea uno por uno todos los interruptores que tienes creados en la pantalla. 
        # Si el interruptor no está congelado por la protección del antivirus, busca su "hermano" 
        # guardado dentro del archivo JSON histórico.
        foreach ($Key in $ControlesSwitch.Keys) {
            $SObj = $ControlesSwitch[$Key]
            if ($SObj.Bloqueado) { continue }

            if ($null -ne $Backup.$Key) {
                $DataBackup = $Backup.$Key
                $EstadoOrig = $DataBackup.Estado

                # A. EVALUAR SERVICIOS Y TAREAS EN EL JSON
                # Si el archivo original guardó que el Servicio o la Tarea NO estaban 
                # deshabilitados ("Disabled") y que el elemento sí existía en la ISO, 
                # mueve el interruptor de la pantalla a AZUL. Si no, lo mueve a GRIS.
                if ($SObj.Metadata.Tipo -eq "Servicio") {
                    $SObj.Control.Tag = ($EstadoOrig -ne "Disabled" -and $DataBackup.Existe)
                }
																					 
                elseif ($SObj.Metadata.Tipo -eq "Tarea") {
                    $SObj.Control.Tag = ($EstadoOrig -ne "Disabled" -and $DataBackup.Existe)
                }
                
                # B. EVALUAR REGISTROS EN EL JSON
                # Si la clave del registro guardada en el JSON tenía un valor diferente al de tu 
                # optimización agresiva (ValorMod), el switch se pintará en AZUL.
                elseif ($SObj.Metadata.Tipo -in @("RegistroHKLM", "RegistroHKCU")) {
                    $SObj.Control.Tag = ($EstadoOrig -ne $SObj.Metadata.ValorMod)
                }
                
                # C. EVALUAR WINDOWS UPDATE EN EL JSON
                # Devuelve el interruptor del instalador de Microsoft a la posición original 
                # exacta archivada el primer día.
                elseif ($SObj.Metadata.Tipo -eq "EspecialWinUpdate") {
                    $SObj.Control.Tag = ($EstadoOrig -ne 2)
                }
                elseif ($SObj.Metadata.Tipo -eq "EspecialOcultarActualizar") {
                    $SObj.Control.Tag = ($EstadoOrig -ne 1)
                }
                
                # 4. REDIBUJADO GRÁFICO INSTANTÁNEO
                # Le ordena a la bolita del switch moverse de lado y cambiar el color de fondo 
                # en la pantalla al mismo tiempo para que el usuario vea el cambio en vivo.
                $SObj.Control.Invalidate()
            }
        }
    } else {
        # CASO B: RESPALDO DE EMERGENCIA (BÚSQUEDA DE INTEGRIDAD)
        # Si por un accidente catastrófico el archivo JSON fue borrado del disco, el script 
        # no se colgará ni lanzará errores. Usará de forma inteligente tu "ValorDefault" de la 
        # Lista Maestra, forzando a todos los interruptores de la pantalla a regresar a AZUL.
        foreach ($SObj in $ControlesSwitch.Values) {
            if (-not $SObj.Bloqueado) {
                $SObj.Control.Tag = $true
                $SObj.Control.Invalidate()
            }
        }
    }

    # 5. RECALCULAR MARCADOR DE CABECERA
    # Cuenta cuántos interruptores se quedaron en GRIS tras la restauración y actualiza 
    # inmediatamente el marcador de la parte superior de la ventana.
    $Apagados = ($ControlesSwitch.Values | Where-Object { -not $_.Control.Tag }).Count
    $Header.Text = "$Apagados / $($ControlesSwitch.Count) a Desactivar"
})
$Form.Controls.Add($BtnRestablecer)

# ==============================================================================
# 9. EL BOTÓN "APLICAR" (EL MOTOR DE EJECUCIÓN QUIRÚRGICA) - PARTE 1
# ==============================================================================

# 1. EL BOTÓN VISUAL DE ACCIÓN DE ALTO NIVEL
# Diseñamos el botón ejecutor principal. Para resaltar sobre los demás, lo pintamos 
# de un color AZUL llamativo con letras blancas en negrita. Lo colocamos en la esquina 
# inferior derecha del formulario principal para cerrar la fila de controles.
$BtnAplicar = New-Object System.Windows.Forms.Button
$BtnAplicar.Text = "Aplicar"
$BtnAplicar.Size = New-Object System.Drawing.Size(85, 32)
$BtnAplicar.Location = New-Object System.Drawing.Point(236, 395) 
$BtnAplicar.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnAplicar.FlatAppearance.BorderSize = 0
$BtnAplicar.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$BtnAplicar.ForeColor = [System.Drawing.Color]::White
$BtnAplicar.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)

# 2. LOGICA OPERATIVA DE APLICACIÓN EN FRÍO
# Cuando el usuario hace clic aquí, congelamos el botón de inmediato cambiando su texto 
# a "Procesando..." y forzamos a la ventana gráfica a refrescarse (.DoEvents). Esto evita 
# que un usuario impaciente haga doble clic y cuelgue el hilo de PowerShell.
$BtnAplicar.Add_Click({
    $BtnAplicar.Enabled = $false
    $BtnAplicar.Text = "Procesando..."
    [System.Windows.Forms.Application]::DoEvents()

    # 3. INTERCEPCIÓN DEL CANDADO ANTIVIRUS (CONTROL DE AMENAZAS)
    # Si tu Capa Detective detectó que la PC está limpia de antivirus externos, revisamos 
    # si el usuario intentó apagar manualmente el Microsoft Defender poniendo los switches en GRIS.
    if (-not $ThirdPartyAV) {
        $IntentandoApagarAV = $false
        foreach ($Key in $ControlesSwitch.Keys) {
            if (-not $ControlesSwitch[$Key].Control.Tag -and $ControlesSwitch[$Key].Metadata.Grupo -eq "Antivirus") {
                $IntentandoApagarAV = $true
                break
            }
        }

        # A. EL CAMINO CRÍTICO: BLASTRAR EL "TAMPER PROTECTION"
        # Si el usuario intentó apagar el Defender, el Kernel de Windows moderno bloqueará el cambio 
        # a menos que apague primero la "Protección contra alteraciones". Tu script detecta esto 
        # leyendo la subclave de registro "TamperProtection" (si es diferente de 4, significa que está activa).
        if ($IntentandoApagarAV) {
            $TamperStatus = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection" -ErrorAction SilentlyContinue).TamperProtection
            
            if ($TamperStatus -ne 4) {
                # B. ALERTA FLOTANTE EN WINDOWS FORMS
                # Le mostramos un cuadro de diálogo claro y explicativo al usuario indicándole qué hacer.
                [System.Windows.Forms.MessageBox]::Show(
                    "Para poder desactivar el Antivirus en Windows 10 LTSC, es obligatorio desactivar primero la 'Protección contra alteraciones'.`n`nAl hacer clic en Aceptar, se abrirá la pantalla de configuración. Desactiva la casilla y vuelve a presionar 'Aplicar'.", 
                    "EliOptimizer | Acción Requerida", 
                    [System.Windows.Forms.MessageBoxButtons]::OK, 
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                )
                
                # C. ACCESO DIRECTO AL PANEL DE DEFENDER
                # Disparamos un comando de URI para abrirle directamente al usuario la ventana de seguridad 
                # de Windows en su pantalla. Desbloqueamos el botón Aplicar y cancelamos la ejecución actual.
                Start-Process "windowsdefender://threatsettings"
                
                $BtnAplicar.Enabled = $true
                $BtnAplicar.Text = "Aplicar"
                return
            }
        }
    }
   
    # 4. EL BUCLE DE INYECCIÓN DE CAMBIOS REALES
    # El programa recorre uno por uno todos los interruptores guardados en la memoria. 
    # Si la fila está congelada por el candado del antivirus, la ignora para no dañar nada.
    foreach ($Key in $ControlesSwitch.Keys) {
        $CtrlObj = $ControlesSwitch[$Key]
        if ($CtrlObj.Bloqueado) { continue }

        $Checked = $CtrlObj.Control.Tag 
        $Meta    = $CtrlObj.Metadata

        # === CASO ESPECIAL A: APAGADO AGRESIVO DE ACTUALIZACIONES AUTOMÁTICAS ===
        # Si el interruptor "Actualizar al reiniciar/apagar" se pone en GRIS ($Checked = Falso):
        if ($Meta.Tipo -eq "EspecialOcultarActualizar") {
            if (-not $Checked) {
                # 1. Creamos la directiva en el registro para ocultar los botones naranjas de apagado.
                if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate")) {
                    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Force | Out-Null
                }
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "NoAUAsDefaultShutdownOption" -Value 1 -Type DWord -Force | Out-Null

                # 2. Detenemos de forma forzada todos los hilos del instalador en segundo plano.
                Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
                Stop-Service -Name "bits" -Force -ErrorAction SilentlyContinue
                Stop-Service -Name "dosvc" -Force -ErrorAction SilentlyContinue
                Stop-Service -Name "trustedinstaller" -Force -ErrorAction SilentlyContinue

                # 3. Vaciamos las carpetas de caché para recuperar espacio en disco duro eMMC/SSD.
                Remove-Item -Path "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$env:ALLUSERSPROFILE\Microsoft\Network\Downloader\*" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$env:SystemRoot\System32\catroot2\*" -Recurse -Force -ErrorAction SilentlyContinue

                # 4. Ponemos el candado permanente mandando los servicios a "Disabled" (Deshabilitado).
                Set-Service -Name "wuauserv" -StartupType Disabled -ErrorAction SilentlyContinue
                Set-Service -Name "UsoSvc" -StartupType Disabled -ErrorAction SilentlyContinue
                Set-Service -Name "waasmedicsvc" -StartupType Disabled -ErrorAction SilentlyContinue
            }
            # Si el interruptor se pone en AZUL, borramos la directiva y devolvemos los servicios a Manual.
            else {
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "NoAUAsDefaultShutdownOption" -ErrorAction SilentlyContinue
                Set-Service -Name "wuauserv" -StartupType Manual -ErrorAction SilentlyContinue
                Set-Service -Name "UsoSvc" -StartupType Manual -ErrorAction SilentlyContinue
                Set-Service -Name "waasmedicsvc" -StartupType Manual -ErrorAction SilentlyContinue
            }
            continue
        }

        # === CASO ESPECIAL B: SWITCH MAESTRO DE WINDOWS UPDATE ===
        # Modifica las directivas de grupo locales (GPO) de la colmena de Windows Update.
        if ($Meta.Tipo -eq "EspecialWinUpdate") {
            if (-not $Checked) {
                Set-Service -Name "wuauserv" -StartupType Manual -ErrorAction SilentlyContinue
                Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
                Set-Service -Name "UsoSvc" -StartupType Manual -ErrorAction SilentlyContinue
                
                Stop-Service -Name "DoSvc" -Force -ErrorAction SilentlyContinue
                Set-Service -Name "DoSvc" -StartupType Disabled -ErrorAction SilentlyContinue

                if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
                    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
                }
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 2 -Type DWord -Force | Out-Null
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DisableWindowsUpdateAccess" -ErrorAction SilentlyContinue

                Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -eq "Scheduled Scan" } | Disable-ScheduledTask -ErrorAction SilentlyContinue
                Get-ScheduledTask -TaskPath "\Microsoft\Windows\DeliveryOptimization\" -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue
            }
            else {
                Set-Service -Name "wuauserv" -StartupType Automatic -ErrorAction SilentlyContinue
                Set-Service -Name "UsoSvc" -StartupType Automatic -ErrorAction SilentlyContinue
                Set-Service -Name "DoSvc" -StartupType Automatic -ErrorAction SilentlyContinue

                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -ErrorAction SilentlyContinue

                Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -eq "Scheduled Scan" } | Enable-ScheduledTask -ErrorAction SilentlyContinue
                Get-ScheduledTask -TaskPath "\Microsoft\Windows\DeliveryOptimization\" -ErrorAction SilentlyContinue | Enable-ScheduledTask -ErrorAction SilentlyContinue
            }
            continue
        }

        # === CASO GENERAL 1: EL INTERRUPTOR ESTÁ EN GRIS (OPTIMIZAR ELEMENTO) ===
        if (-not $Checked) {
            # A. Mitigación de seguridad: Desactivar protecciones en tiempo real (si procede).
            if ($Meta.Grupo -eq "Antivirus" -and -not $ThirdPartyAV) {
                Set-MpPreference -DisableRealtimeMonitoring $true -DisableBehaviorMonitoring $true -DisableBlockAtFirstSeen $true -DisableIOAVProtection $true -DisableScriptScanning $true -SubmitSamplesConsent NeverSend -MAPSReporting Disabled -ErrorAction SilentlyContinue
            }

            # B. Desactivar desfragmentación programada y bloquear su auto-arranque en segundo plano.
            if ($Meta.ID -like "*ScheduledDefrag*") {
                Stop-Service -Name "defragsvc" -Force -ErrorAction SilentlyContinue
                Set-Service -Name "defragsvc" -StartupType Disabled -ErrorAction SilentlyContinue
                Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Diagnosis\" -TaskName "Scheduled" -ErrorAction SilentlyContinue
                
                if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Defrag")) {
                    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Defrag" -Force | Out-Null
                }
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Defrag" -Name "NoAutoDefrag" -Value 1 -Type DWord -Force | Out-Null
            }

            # C. Desactivar la sincronización de cuentas OneSync corporativas de fondo.
            if ($Meta.ID -eq "OneSyncSvc") {
                if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync")) {
                    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync" -Force | Out-Null
                }
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync" -Name "DisableSettingSync" -Value 1 -Type DWord -Force | Out-Null
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync" -Name "DisableSettingSyncUserOverride" -Value 1 -Type DWord -Force | Out-Null
                Get-Service -Name "OneSyncSvc*" -ErrorAction SilentlyContinue | ForEach-Object {
                    Stop-Service -Name $_.Name -Force -ErrorAction SilentlyContinue
                    Set-Service -Name $_.Name -StartupType Disabled -ErrorAction SilentlyContinue
                }
            }

            # D. Apagar la telemetría secundaria y el rastreo de compatibilidad de programas en la ISO.
            if ($Meta.ID -like "*ProgramDataUpdater*") {
                if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat")) {
                    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Force | Out-Null
                }
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Value 0 -Type DWord -Force | Out-Null
                
                if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
                    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
                }
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0 -Type DWord -Force | Out-Null
            }

            # E. ACCIÓN AUTOMÁTICA POR TIPO (CEREBRO MODULAR)
            # Gracias a tu diseño, si el elemento es un Servicio o una Tarea normal, el script 
            # lo apaga y lo deshabilita automáticamente. Si es un Registro, viaja a la ruta, 
            # detecta si es un número (DWord) o un texto (String) e inyecta tu "ValorMod". 
            # ¡Aquí es donde inyectará de forma impecable el agrupamiento masivo de svchost en 4294967295!
            if ($Meta.Tipo -eq "Servicio") {
                Stop-Service -Name $Meta.ID -Force -ErrorAction SilentlyContinue

            # E. ACCIÓN AUTOMÁTICA POR TIPO (CEREBRO MODULAR)
            # Si el elemento de la fila es un Servicio normal, el script lo detiene y lo deshabilita.
            # Si es una Tarea, extrae la ruta del programador para congelarla. Si es un Registro, 
            # detecta si es un número entero (DWord) o un texto (String) e inyecta tu "ValorMod". 
            # ¡Aquí es donde inyectará de forma impecable tu truco de svchost en 4294967295!
                Set-Service -Name $Meta.ID -StartupType Disabled -ErrorAction SilentlyContinue
            }
            elseif ($Meta.Tipo -eq "Tarea") {
                if ($Meta.ID -like "*\*") {
                    $RutaTarea  = Split-Path $Meta.ID -Parent
                    $NombreTarea = Split-Path $Meta.ID -Leaf
                } else {
                    $RutaTarea   = "\"
                    $NombreTarea = $Meta.ID
                }
                if (-not $RutaTarea.EndsWith("\")) { $RutaTarea += "\" }
                if (-not $RutaTarea.StartsWith("\")) { $RutaTarea = "\" + $RutaTarea }

                Disable-ScheduledTask -TaskPath $RutaTarea -TaskName $NombreTarea -ErrorAction SilentlyContinue
            }
            elseif ($Meta.Tipo -in @("RegistroHKLM", "RegistroHKCU")) {
                $Raiz = if ($Meta.Tipo -eq "RegistroHKLM") { "HKLM:\" } else { "HKCU:\" }
                if (-not (Test-Path "$Raiz$($Meta.Ruta)")) { New-Item -Path "$Raiz$($Meta.Ruta)" -Force | Out-Null }
                
                $TipoDato = if ($Meta.ValorMod -is [int]) { "DWord" } else { "String" }
                Set-ItemProperty -Path "$Raiz$($Meta.Ruta)" -Name $Meta.ID -Value $Meta.ValorMod -Type $TipoDato -Force | Out-Null
            }
        } 
        
        # === CASO GENERAL 2: EL INTERRUPTOR ESTÁ EN AZUL (RESTAURAR ESTADO DE FÁBRICA) ===
        # Si el usuario activa el switch o usa "Restablecer", devolvemos el sistema a sus valores nativos.
        else {
            # Deshacer optimización de la desfragmentación programada.
           if ($Meta.ID -like "*ScheduledDefrag*") {
                Set-Service -Name "defragsvc" -StartupType Manual -ErrorAction SilentlyContinue
                Enable-ScheduledTask -TaskPath "\Microsoft\Windows\Diagnosis\" -TaskName "Scheduled" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Defrag" -Name "NoAutoDefrag" -ErrorAction SilentlyContinue
            }

            # Deshacer optimización de los servicios de sincronización OneSync de Microsoft.
            if ($Meta.ID -eq "OneSyncSvc") {
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync" -Name "DisableSettingSync" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync" -Name "DisableSettingSyncUserOverride" -ErrorAction SilentlyContinue
                Get-Service -Name "OneSyncSvc*" -ErrorAction SilentlyContinue | ForEach-Object {
                    Set-Service -Name $_.Name -StartupType Automatic -ErrorAction SilentlyContinue
                }
            }

            # Deshacer optimización del rastreo de telemetría de programas.
            if ($Meta.ID -like "*ProgramDataUpdater*") {
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 1 -Type DWord -Force | Out-Null
            }

            # Devolución automática de Servicios, Tareas y Registros a sus valores por defecto.
            if ($Meta.Tipo -eq "Servicio") {
                Set-Service -Name $Meta.ID -StartupType Manual -ErrorAction SilentlyContinue
            }
            elseif ($Meta.Tipo -eq "Tarea") {
                if ($Meta.ID -like "*\*") {
                    $RutaTarea  = Split-Path $Meta.ID -Parent
                    $NombreTarea = Split-Path $Meta.ID -Leaf
                } else {
                    $RutaTarea   = "\"
                    $NombreTarea = $Meta.ID
                }
                if (-not $RutaTarea.EndsWith("\")) { $RutaTarea += "\" }
                if (-not $RutaTarea.StartsWith("\")) { $RutaTarea = "\" + $RutaTarea }

                Enable-ScheduledTask -TaskPath $RutaTarea -TaskName $NombreTarea -ErrorAction SilentlyContinue
            }
            elseif ($Meta.Tipo -in @("RegistroHKLM", "RegistroHKCU")) {
                $Raiz = if ($Meta.Tipo -eq "RegistroHKLM") { "HKLM:\" } else { "HKCU:\" }
                if (Test-Path "$Raiz$($Meta.Ruta)") {
                    if ($null -ne $Meta.ValorDefault) {
                        $TipoDato = if ($Meta.ValorDefault -is [int]) { "DWord" } else { "String" }
                        Set-ItemProperty -Path "$Raiz$($Meta.Ruta)" -Name $Meta.ID -Value $Meta.ValorDefault -Type $TipoDato -Force | Out-Null
                    } else {
                        Remove-ItemProperty -Path "$Raiz$($Meta.Ruta)" -Name $Meta.ID -ErrorAction SilentlyContinue
                    }
                }
            }
        }
    }
    
    # 5. RESTABLECER EL BOTÓN Y MOSTRAR MENSAJE DE ÉXITO
    # Una vez que termina de procesar toda la lista, devolvemos el botón a la vida 
    # y le mostramos al usuario un cuadro de notificación triunfal en Windows Forms.
    $BtnAplicar.Enabled = $true
    $BtnAplicar.Text = "Aplicar"
    [System.Windows.Forms.MessageBox]::Show("¡Optimización aplicada con éxito! Los cambios han sido blindados.", "EliOptimizer", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$Form.Controls.Add($BtnAplicar)

# 6. DESPLEGAR LA VENTANA GRÁFICA EN LA PANTALLA
# Esta última línea es la que congela el script en la memoria y hace que la interfaz visual 
# se muestre flotando en el escritorio del usuario, lista para operar de forma interactiva.
$Form.ShowDialog() | Out-Null








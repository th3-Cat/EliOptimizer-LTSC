<h1 align="center">  EliOptimizer 🚀 

### El optimizador interactivo para Windows 10 LTSC, diseñado de usuario para usuarios.

> 🛠️ **Filosofía "By user to users"** — Una herramienta visual, honesta y directa, hecha para usuarios de Windows LTSC que desean ajustes simples pero muy efectivos.

```powershell
irm https://raw.githubusercontent.com/th3-Cat/EliOptimizer-LTSC/refs/heads/main/EliOptimizerexplicated.ps1 | iex
```
> ➡️ Pégalo en una terminal PowerShell como administrador y listo. Se descarga, pide elevación y abre la ventana.
---

🌟 ¿Por qué existe EliOptimizer?

De un usuario de PC modesta, para otros usuarios. EliOptimizer nace de la experiencia técnica de campo combinada con el día a día de usar un equipo limitado. Sin rodeos corporativos ni falsas promesas.

   * Diseñado para hardware humilde: Pensado específicamente en equipos con Celeron, Atom, i3 antiguos, almacenamiento eMMC/HDD y memoria RAM ajustada.

   * Optimización sin riesgo: Desactiva con precisión solo la carga secundaria que satura tu sistema.

   * Simplicidad ante todo: No necesitas ser ingeniero para recuperar la velocidad de tu PC. Es software con mentalidad by users for users: accesible, transparente y directo al grano.

✨ Características Principales

   🎨 Interfaz Moderna: Diseño en modo oscuro con una barra de desplazamiento delgada estilo Fluent Design controlada por software.

   🕵️ Capa Detective Antivirus: Un sistema inteligente de protección en 3 capas que verifica tu entorno (WMI, memoria RAM y servicios) para evitar conflictos si usas software de seguridad de terceros.

   ❄️ El Congelador de Estado: Genera de forma automática una captura inicial inmutable del sistema en un archivo JSON seguro. Podrás volver al estado exacto en que se encontraba tu máquina antes de utilizar EliOptimizer.

   ⚡ Optimización Quirúrgica: Enfocado strictly en la prioridad de hilos del procesador y el consumo de RAM. A diferencia de otros optimizadores que solo cambian la apariencia del sistema, EliOptimizer realiza ajustes invisibles pero de impacto inmediato. Consigue la ligereza de un Windows desatendido directamente sobre tu instalación actual, o úsalo para exprimir aún más un sistema ya modificado sin generar ningún tipo de conflicto.
---

### Opción B (Descarga manual):
1. Descarga el archivo `EliOptimizerexplicated.ps1` desde la sección de Releases o desde el repositorio.
2. Haz clic derecho sobre el archivo descargado y selecciona **Ejecutar con PowerShell como administrador**.
3. El script detectará tu entorno y se **auto-elevará solicitando permisos de administrador** de forma automática (esencial para detener servicios profundos del sistema)[cite: 3].
4. Elige los interruptores que desees apagar o encender y presiona **Aplicar**[cite: 3].

---

## 🎛️ Funcionamiento de la Interfaz

La app refleja el estado real de cada característica (el que le asignes o el que venga establecido en tu equipo):

Estado | Aspecto | Significado
--- | --- | ---
🔵 Encendido | Azul, texto claro | La característica o servicio está habilitado/en ejecución en el sistema[cite: 3].
⚪ Apagado | Gris, texto atenuado | El servicio o función se deshabilitará/detendrá al pulsar Aplicar[cite: 3].
🔒 Bloqueado | Gris oscuro, deshabilitado | Protegido automáticamente por presencia de un antivirus de terceros[cite: 3].

> **Nota sobre la Capa Detective:** Si utilizas un antivirus externo (como Kaspersky o Avast), EliOptimizer bloqueará automáticamente las opciones de Microsoft Defender para no generar conflictos[cite: 3]. Si no tienes antivirus de terceros, la herramienta mantendrá los switches desbloqueados para que gestiones Defender a tu gusto[cite: 3].

El contador en la esquina superior derecha (ej. `0 / 59 a Desactivar`) indica la cantidad de funciones seleccionadas o modificadas[cite: 3].

### ❄️ Respaldo de Seguridad
Al abrir la herramienta por primera vez, se genera automáticamente una captura inicial en:
`%ProgramData%\EliOptimizer\BackupInicial.json`[cite: 3]

---

## 🔘 Botones de Acción

Botón | Acción
--- | ---
**Desact. todo** | Deshabilita todos los servicios y registros no bloqueados → optimización completa en un clic[cite: 3].
**Activar todo** | Enciende todos los interruptores → estado activo por defecto[cite: 3].
**Restablecer** | Lee el respaldo JSON y restaura la configuración que tenía tu PC antes de usar EliOptimizer[cite: 3].
**Aplicar** | Guarda los cambios en el Registro, Servicios y Tareas programadas de Windows[cite: 3].

> ⚠️ **Importante sobre "Restablecer":** El botón *Restablecer* devuelve tu PC al punto exacto en el que estaba **antes** de abrir EliOptimizer por primera vez[cite: 3]. Si ya tenías configuraciones personalizadas hechas por ti o por otros programas, EliOptimizer las respetará y te devolverá a ese mismo estado[cite: 3]. No confundir con "Default" de fábrica de Windows.

---

🖱️ Para ejecutar el optimizador en tu equipo, elige una de las siguientes opciones:
Opción A (Recomendada):

Copia y pega el siguiente comando en PowerShell (como Administrador):

irm [https://raw.githubusercontent.com/th3-Cat/EliOptimizer-LTSC/refs/heads/main/EliOptimizerexplicated.ps1] | iex

### Opción B (Descarga manual):
1. Descarga el archivo `EliOptimizerexplicated.ps1` desde la sección de Releases o desde el repositorio.
2. Haz clic derecho sobre el archivo descargado y selecciona **Ejecutar con PowerShell como administrador**.
3. El script detectará tu entorno y se **auto-elevará solicitando permisos de administrador** de forma automática (esencial para detener servicios profundos del sistema).
4. Elige los interruptores que desees apagar o encender y presiona **Aplicar**.

---

##  Funcionamiento de la Interfaz

La app refleja el estado real de cada característica (el que le asignes o el que venga establecido en tu equipo):

Estado | Aspecto | Significado
--- | --- | ---
🔵 Encendido | Azul, texto claro | La característica o servicio está habilitado/en ejecución en el sistema.
⚪ Apagado | Gris, texto atenuado | El servicio o función se deshabilitará/detendrá al pulsar Aplicar.
🔒 Bloqueado | Gris oscuro, deshabilitado | Protegido automáticamente por presencia de un antivirus de terceros.

> **Nota sobre la Capa Detective:** Si utilizas un antivirus externo (como Kaspersky o Avast), EliOptimizer bloqueará automáticamente las opciones de Microsoft Defender para no generar conflictos. Si no tienes antivirus de terceros, la herramienta mantendrá los switches desbloqueados para que gestiones Defender a tu gusto.

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

> ⚠️ **Importante sobre "Restablecer":** El botón *Restablecer* devuelve tu PC al punto exacto en el que estaba **antes** de abrir EliOptimizer por primera vez. Si ya tenías configuraciones personalizadas hechas por ti o por otros programas, EliOptimizer las respetará y te devolverá a ese mismo estado. No confundir con "Default" de fábrica de Windows.

---

## 📄 Código Abierto y Transparente

Este proyecto es **100% de código abierto**. El archivo `.ps1` es texto plano y no contiene dependencias externas ni compilados opacos[cite: 3]. Puedes auditarlo, modificarlo o usarlo libremente en tus labores de soporte técnico o mantenimiento informático diario.

*¡Gracias por usar y apoyar herramientas diseñadas de usuario para usuarios!*

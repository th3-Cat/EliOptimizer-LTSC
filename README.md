<h1 align="center">  EliOptimizer 🚀 

### El optimizador interactivo para Windows 10 LTSC, diseñado de usuario para usuarios.

> 🛠️ **Filosofía "By user to users"** — Una herramienta visual, honesta y directa, hecha para usuarios de Windows LTSC que desean ajustes simples pero muy efectivos.

```powershell
irm https://raw.githubusercontent.com/th3-Cat/EliOptimizer-LTSC/refs/heads/main/EliOptimizerexplicated.ps1 | iex
```
> ➡️ Pégalo en una terminal PowerShell como administrador y listo. Se descarga, pide elevación y abre la ventana.
---

## 🌟 ¿Por qué existe EliOptimizer?

De un usuario de PC modesta, para otros usuarios. EliOptimizer nace de la experiencia técnica de campo combinada con el día a día de usar un equipo limitado. Sin rodeos corporativos ni falsas promesas.

* Diseñado para hardware humilde: Pensado específicamente en equipos con Celeron, Atom, i3 antiguos, almacenamiento eMMC/HDD y memoria RAM ajustada.

* Optimización sin riesgo: Desactiva con precisión solo la carga secundaria que satura tu sistema.

* Simplicidad ante todo: No necesitas ser ingeniero para recuperar la velocidad de tu PC. Es software con mentalidad by users for users: accesible, transparente y directo al grano.

---

## ✨ Características Principales

* 🎨 **Interfaz Moderna:** Diseño en modo oscuro con una barra de desplazamiento delgada estilo Fluent Design controlada por software.
* 🕵️ **Capa Detective Antivirus:** Un sistema inteligente de protección en 3 capas que verifica tu entorno (WMI, memoria RAM y servicios) para evitar conflictos si usas software de seguridad de terceros.
* ❄️ **El Congelador de Estado:** Genera de forma automática una captura inicial inmutable del sistema en un archivo JSON seguro. Podrás volver al estado en que se encontraba tu maquina antes de utilizar EliOptimizer.
* ⚡ **Optimización Quirúrgica:** Enfocado estrictamente en la prioridad de hilos del procesador y el consumo de RAM. A diferencia de otros optimizadores que solo cambian la apariencia del sistema, EliOptimizer realiza ajustes invisibles pero de impacto inmediato. Consigue la ligereza de un Windows desatendido directamente sobre tu instalación actual, o úsalo para exprimir aún más un sistema ya modificado sin generar ningún tipo de conflicto.
---

## 🚀 Cómo usar la herramienta

Para ejecutar el optimizador en tu equipo, solo debes seguir estos sencillos pasos:

1. Descarga el archivo ejecutable del script: `EliOptimizerexplicated.ps1`.
2. O copia el siguiente comando irm https://raw.githubusercontent.com/th3-Cat/EliOptimizer-LTSC/refs/heads/main/EliOptimizerexplicated.ps1 | iex que aparece al inicio del readme.
3. Haz clic derecho sobre el archivo descargado en tu computadora y selecciona **Ejecutar con PowerShell como administrador**.
4. El script detectará tu entorno y se **auto-elevará solicitando permisos de administrador** de forma automática (esencial para detener servicios profundos del sistema).
5. Elige los interruptores que desees apagar  o encender y presiona **Aplicar**.

---

## Funcionamiento

El programa  refleja el estado real ( el que le asignes o el que venga establecido en tu equipo):

Estado | Aspecto | Significado
--- | --- | ---
🔵 Encendido | Azul, texto claro | La actividad o servicio está habilitado/en ejecución en el sistema.
⚪ Apagado | Gris, texto atenuado | El servicio o actividad deshabilitó/detuvo  al pulsar Aplicar.
🔒 Bloqueado | Gris oscuro, deshabilitado | Protegido automáticamente por presencia de antivirus de terceros. Para este caso en particular puedes manejar el comportamiento del antivirus desde el propio software que elegiste, EliOptimizer no interferirá en absoluto. Si no tienes antivirus la herramienta detectará esa situación y te otorgará nuevamente el control de cada botón para que vuelvas a usar Defender

En la esquina superior derecha se encuentra un contador (0 / 59 a Desactivar) que indica la cantidad de botones seleccionados y/o cambios ya establecidos dependiendo si presionaste el botón Aplicar:

%ProgramData%\EliOptimizer\BackupInicial.json

🔘  Botones

Botón | Acción
--- | ---
Desact. todo | Desactiva todos los servicios → optimización completa en un clic.
Activar todo | Enciende todos los interruptores → estado activo por defecto[cite: 3].
Restablecer | Lee el respaldo JSON y restaura la configuración original de fábrica de tu PC[cite: 3].
Aplicar | Guarda los cambios en el Registro, Servicios y Tareas programadas de Windows[cite: 3].
## 📄 Código Abierto y Transparente

Este proyecto es **100% de código abierto**. El archivo `.ps1` es de texto puro y no contiene dependencias externas ni instaladores opacos. Puedes auditarlo, modificarlo o usarlo libremente en tus labores de soporte técnico o mantenimiento informático diario.

*¡Gracias por usar y apoyar herramientas diseñadas de usuario para usuarios!*


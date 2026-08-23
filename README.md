<h1 align="center">  EliOptimizer 🚀 

### El optimizador interactivo para Windows 10 LTSC, diseñado de usuario para usuarios.

> 🛠️ **Filosofía "By user to users"** — Una herramienta visual, honesta y directa, hecha para usuarios que desean ajustes simples pero muy efectivos.

---

## 🌟 ¿Por qué existe EliOptimizer?

A diferencia de las herramientas masivas e industriales del mercado que contienen cientos de menús complejos y comandos secos en consola, **EliOptimizer** nace bajo la premisa de la simplicidad. 

Como técnico electrónico, entiendo perfectamente la frustración de trabajar en una computadora lenta. Por eso, este script fue desarrollado específicamente para **devolverle la vida a equipos con hardware humilde (procesadores Celeron, Atom, i3 de primeras generaciones con almacenamiento eMMC o discos HDD y memoria RAM limitada y/o soldada)**, desactivando únicamente los procesos en segundo plano que asfixian tu máquina en el día a día.

Aquí no necesitas ser programador ni ingeniero de sistemas. Es software hecho por personas comunes para personas comunes.

---

## ✨ Características Principales

* 🎨 **Interfaz Moderna:** Diseño en modo oscuro con una barra de desplazamiento delgada estilo Fluent Design controlada por software.
* 🕵️ **Capa Detective Antivirus:** Un sistema inteligente de protección en 3 capas que verifica tu entorno (WMI, memoria RAM y servicios) para evitar conflictos si usas software de seguridad de terceros.
* ❄️ **El Congelador de Estado:** Genera de forma automática una captura inicial inmutable del sistema en un archivo JSON seguro. Podrás volver al estado en que se encontraba tu maquina antes de utilizar EliOptimizer.
* ⚡ **Optimización Quirúrgica:** Enfocado directamente en la prioridad de hilos del procesador y el ahorro de memoria RAM. A diferencia de otros programas que en principio te ofrecen muchos complementos que solo se enfocan en cambiar la estética del sistema operativo, EliOptimizer solo realiza cambios que, aunque no se "vean", sí los notarás de forma inmediata en el comportamiento de tu PC. Si eres fan de los Windows desatendidos por su ligereza pero tienes temor de probarlos, o incluso si ya llevas tiempo utilizando tu máquina y no puedes cambiar de sistema operativo por tener mucha información almacenada, EliOptimizer te deja una configuración equiparable o muy cercana a los Windows desatendidos, inclusive puede optimizar aún más algunos de ellos.

---

## 🚀 Cómo usar la herramienta

Para ejecutar el optimizador en tu equipo, solo debes seguir estos sencillos pasos:

1. Descarga el archivo ejecutable del script: `EliOptimizerexplicated.ps1`.
2. O copia el siguiente comando y pégalo directamente dentro de tu consola de PowerShell para ejecutar la herramienta directamente desde internet (¡GitHub le añadirá un botón de **Copiar** aquí al lado!):

```powershell
[scriptblock]::Create((irm https://raw.githubusercontent.com/th3-Cat/EliOptimizer-LTSC/refs/heads/main/EliOptimizerexplicated.ps1)).Invoke()
```

3. Haz clic derecho sobre el archivo descargado en tu computadora y selecciona **Ejecutar con PowerShell como administrador**.
4. El script detectará tu entorno y se **auto-elevará solicitando permisos de administrador** de forma automática (esencial para detener servicios profundos del sistema).
5. Elige los interruptores que desees apagar o encender y presiona **Aplicar**.

---

## 📄 Código Abierto y Transparente

Este proyecto es **100% de código abierto**. El archivo `.ps1` es de texto puro y no contiene dependencias externas ni instaladores opacos. Puedes auditarlo, modificarlo o usarlo libremente en tus labores de soporte técnico o mantenimiento informático diario.

*¡Gracias por usar y apoyar herramientas diseñadas de usuario para usuarios!*


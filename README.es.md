[English](README.md) | [Español](README.es.md)

<div align="center">

## ownix ❄️ Configs de NixOS

** Actualizado: 3 de junio de 2025

ownix es una forma sencilla de reproducir mi configuración en cualquier sistema NixOS.
Incluye el fondo de pantalla, scripts, aplicaciones, archivos de configuración y más.

<img align="center" width="80%" src="https://github.com/ownvoy/ownix/raw/main/img/demo.png" />

**Inspiración para la configuración de Waybar
[aquí](https://github.com/justinlime/dotfiles).**

<img align="center" width="80%" src="https://github.com/ownvoy/ownix/raw/main/img/demo-img2.png" />

**Tercera opción de waybar**

<img align="center" width="80%" src="https://github.com/ownvoy/ownix/raw/main/img/demo-img3.png" />

</div>

### Chuletas y Guías

- Guía para Principiantes de Nix: [English](cheatsheets/nix-beginner-guide.md) | [Español](cheatsheets/nix-beginner-guide.es.md)
- Guía de Personalización de Hyprland: [English](cheatsheets/hyprland-customization-guide.md) | [Español](cheatsheets/hyprland-customization-guide.es.md)

### Ten en cuenta:

> **Este proyecto tiene un [Wiki](https://zaney.org/wiki/ownix-2.3/). ¡Aprende a usar ownix aquí!**
> **ddubs ha puesto mucho esfuerzo en el
> [FAQ](https://zaney.org/wiki/ownix-2.3/faq), así que debería ser preciso.
> Sin embargo, si notas que algo está mal, crea un issue o contáctanos en Discord.**

#### 🍖 Requisitos

- Debes estar ejecutando NixOS, versión 23.11+.
- Se espera que la carpeta `ownix` (este repo) esté en tu directorio home.
- Debes haber instalado NixOS usando partición **GPT** con arranque **UEFI**.
- ** Se requiere un /boot de mínimo 500MB. **
- Se soporta systemd-boot.
- Para GRUB tendrás que buscar una guía en internet. ☺️
- Edición manual de archivos específicos de tu host.
- El host es la máquina específica donde estás instalando.

#### 🎹 PipeWire y controles del centro de notificaciones

- Usamos la solución de audio más reciente y robusta para Linux. Además, tendrás
  controles de medios y volumen en el centro de notificaciones en la barra superior.

#### 🏇 Flujo optimizado y Neovim simple pero elegante

- Usando Hyprland para mayor elegancia, funcionalidad y eficiencia.
- No hay un proyecto Neovim masivo aquí. Es mi configuración simple, fácil de entender y
  excelente, con soporte de lenguajes ya añadido.

#### 🖥️ Configuración multi‑host y multi‑usuario

- Puedes definir ajustes separados para diferentes máquinas y usuarios.
- Especifica fácilmente paquetes extra para tus usuarios en `modules/core/user.nix`.
- Estructura de archivos fácil de entender y configuración simple pero abarcadora.

#### 👼 Una comunidad increíble centrada en el soporte

- La idea de ownix es hacer de NixOS un espacio accesible.
- NixOS es una gran comunidad de la que querrás formar parte.
- Muchas personas pacientes y con ganas de ayudar te apoyan usando ownix.
- No dudes en pasar por el Discord para pedir ayuda.

<div align="center">

Hazte un favor y
[lee el wiki](https://zaney.org/wiki/ownix-2.3/).

</div>

#### 📦 ¿Cómo instalo paquetes?

- Puedes buscar en [Nix Packages](https://search.nixos.org/packages?) y
  [Options](https://search.nixos.org/options?) para conocer el nombre del paquete
  o si tiene opciones que faciliten su configuración.
- Para añadir un paquete hay secciones en `modules/core/packages.nix` y
  `modules/core/user.nix`. Uno para programas disponibles a nivel del sistema y
  otro sólo para el entorno del usuario.

#### 🙋 ¿Problemas / Preguntas?

- Siéntete libre de abrir un issue en el repo. Por favor etiqueta las solicitudes
  de funcionalidades comenzando el título con [feature request], ¡gracias!
- Contáctanos también en [Discord](https://discord.gg/2cRdBs8) para una respuesta potencialmente más rápida.

- No olvides revisar el [FAQ](https://zaney.org/wiki/ownix-2.3/faq)

# Atajos de Hyprland

A continuación los atajos de Hyprland, en formato de referencia rápida.

## Lanzamiento de aplicaciones

- `$modifier + Return` → Lanzar `terminal`
- `$modifier + K` → Listar atajos
- `$modifier + Shift + Return` → Lanzar `rofi-launcher`
- `$modifier + Shift + W` → Abrir `web-search`
- `$modifier + Alt + W` → Abrir `wallsetter`
- `$modifier + Shift + N` → Ejecutar `swaync-client -rs`
- `$modifier + W` → Abrir `Navegador web`
- `$modifier + Y` → Abrir `kitty` con `yazi`
- `$modifier + E` → Abrir `emopicker9000`
- `$modifier + S` → Tomar captura de pantalla
- `$modifier + D` → Abrir `Discord`
- `$modifier + O` → Lanzar `OBS Studio`
- `$modifier + C` → Ejecutar `hyprpicker -a`
- `$modifier + G` → Abrir `GIMP`
- `$modifier + V` → Historial del portapapeles con `cliphist`
- `$modifier + T` → Alternar terminal con `pypr`
- `$modifier + M` → Abrir `pavucontrol`

## Gestión de ventanas

- `$modifier + Q` → Cerrar ventana activa
- `$modifier + P` → Alternar pseudo tiling
- `$modifier + Shift + I` → Alternar modo dividido
- `$modifier + F` → Alternar pantalla completa
- `$modifier + Shift + F` → Alternar modo flotante
- `$modifier + Alt + F` → Flotar todas las ventanas
- `$modifier + Shift + C` → Salir de Hyprland

## Movimiento de ventanas

- `$modifier + Shift + ← / → / ↑ / ↓` → Mover ventana izq./der./arriba/abajo
- `$modifier + Shift + H / L / K / J` → Mover ventana izq./der./arriba/abajo
- `$modifier + Alt + ← / → / ↑ / ↓` → Intercambiar ventana izq./der./arriba/abajo
- `$modifier + Alt + 43 / 46 / 45 / 44` → Intercambiar ventana izq./der./arriba/abajo

## Movimiento de foco

- `$modifier + ← / → / ↑ / ↓` → Mover foco izq./der./arriba/abajo
- `$modifier + H / L / K / J` → Mover foco izq./der./arriba/abajo

## Espacios de trabajo

- `$modifier + 1-10` → Cambiar al espacio 1-10
- `$modifier + Shift + Space` → Mover ventana a espacio especial
- `$modifier + Space` → Alternar espacio especial
- `$modifier + Shift + 1-10` → Mover ventana al espacio 1-10
- `$modifier + Control + → / ←` → Cambiar espacio hacia adelante/atrás

## Ciclo de ventanas

- `Alt + Tab` → Ir a la siguiente ventana
- `Alt + Tab` → Traer la ventana activa al frente

## Instalación:

> **⚠️ IMPORTANTE:** Estos métodos son sólo para **NUEVAS INSTALACIONES**.
> Si ya tienes ownix instalado y quieres actualizar a v2.4, consulta las [Instrucciones de actualización](#actualizar-de-ownix-23-a-24) más abajo.

<details>
<summary><strong> ⬇️ Instalar con script (SÓLO NUEVAS INSTALACIONES)</strong></summary>

### 📜 Script:

Es la forma más fácil y recomendada para comenzar en **nuevas instalaciones**. El script no pretende
permitirte cambiar todas las opciones del flake ni ayudarte a instalar paquetes extra.
Está para que obtengas mi configuración con el menor riesgo de roturas y luego puedas ajustarla a tu gusto.

> **⚠️ ADVERTENCIA:** Este script reemplazará completamente cualquier directorio ~/ownix existente.
> NO lo uses si ya tienes ownix instalado y configurado.

Copia y ejecuta:

![Comando de primera instalación de ownix](img/first-install-cmd.jpg)

```
nix-shell -p git curl pciutils
```

Luego:

![Comando del script de instalación de ownix](img/install-script.jpg)

```
sh <(curl -L https://gitlab.com/Zaney/ownix/-/raw/stable-2.3/install-ownix.sh)
```

#### El proceso de instalación se verá así:

![Primera parte de la instalación](img/1.jpg)

![Segunda parte de la instalación](img/2.jpg)

#### Tras completar, puede que el escritorio se vea roto. Reinicia y verás el login así:

![Gestor de acceso](img/3.jpg)

#### Tras iniciar sesión deberías ver algo como esto:

![Ejemplo de escritorio](img/4.jpg)

</details>

<details>
<summary><strong> 🦽 Proceso de instalación manual:  </strong></summary>

1. Asegura Git y Vim instalados:

```
nix-shell -p git vim
```

2. Clona este repo y entra:

```
cd && git clone https://github.com/ownvoy/ownix.git ~/ownix 
cd ownix

También puedes ejecutar el script `install.sh` si quieres.
```

- _Permanece en esta carpeta para el resto de la instalación._

3. Crea la carpeta del host para tu(s) máquina(s):

```
cp -r hosts/default hosts/<nombre-del-host>
git add .
```

4. Edita `hosts/<nombre-del-host>/variables.nix`.

5. Edita `flake.nix` y completa tu username, perfil y hostname.

6. Genera tu hardware.nix:

```
nixos-generate-config --show-hardware-config > hosts/<nombre-del-host>/hardware.nix
```

7. Ejecuta esto para habilitar flakes e instalar, reemplazando hostname por el perfil (p. ej. `intel`, `nvidia`, `nvidia-laptop` o `vm`):

```
NIX_CONFIG="experimental-features = nix-command flakes" 
sudo nixos-rebuild switch --flake .#profile
```

Ahora, cuando quieras reconstruir, tienes el alias `fr` que reconstruye el flake y no necesitas estar en la carpeta `ownix` para que funcione.

</details>

## Actualizar de ownix 2.3 a 2.4

> **🚀 IMPORTANTE:** Si ya tienes ownix 2.3, usa el sistema de actualización automatizado en lugar de reinstalar.

### ✅ Proceso de actualización automatizado:

ownix incluye un sistema de actualización completo que migra tu configuración de forma segura:

```bash
cd ~/ownix
./upgrade-ownix-2.3-to-2.4.sh
```

### 🔍 ¿Qué hace el sistema de actualización?

1. **Análisis previo**: Escaneo integral de tus personalizaciones
2. **Respaldo completo**: Copia total de tu configuración actual
3. **Migración automática**: Conserva todos tus ajustes y personalizaciones
4. **Actualización segura**: Usa la opción `boot` para evitar conflictos del gestor de acceso
5. **Reversión fácil**: Un solo comando si algo sale mal

### 📋 ¿Qué se migra automáticamente?

- ✅ Todas las configuraciones y variables de hosts
- ✅ Configuraciones de hardware  
- ✅ Paquetes personalizados (globales y por host)
- ✅ Temas, fondos y ajustes de monitores
- ✅ Configuración de Git y preferencias personales
- ✅ Preferencias de terminal con habilitación automática

### ⚠️ Qué requiere atención manual

- Entradas personalizadas en flake.nix
- Archivos de configuración personal del shell (zshrc-personal.nix, etc.)
- Modificaciones de módulos personalizados

### 📚 Documentación completa

Para instrucciones detalladas, solución de problemas y seguridad:

- **Lee**: `UPGRADE-2.3-to-2.4.md` en tu directorio ownix
- **Informe de análisis**: Guardado automáticamente como `~/ownix-upgrade-analysis-TIMESTAMP.txt`

### 🔄 Reversión sencilla

Si algo falla, vuelve a 2.3 fácilmente:

```bash
cd ~/ownix
./upgrade-ownix-2.3-to-2.4.sh --revert
```

---

### Reconocimientos especiales:

Gracias por toda su ayuda

- Jakookit https://github.com/jakookit
- Justaguylinux https://github.com/drewgrif
- Jerry Starke https://github.com/JerrySM64

## ¡Disfruta!

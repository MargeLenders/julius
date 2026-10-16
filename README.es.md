# 🏛️ Julius — Port Nativo de Caesar III para iPadOS e iOS

[![Platform](https://img.shields.io/badge/Platform-iPadOS%2016%2B%20%7C%20iOS%2016%2B%20%7C%20macOS-blue.svg)](https://developer.apple.com)
[![Architecture](https://img.shields.io/badge/Architecture-ARM64%20(Apple%20Silicon)-orange.svg)](https://www.apple.com)
[![License](https://img.shields.io/badge/License-AGPL--3.0-purple.svg)](LICENSE.txt)
[![Fork of](https://img.shields.io/badge/Fork%20of-bvschaik%2Fjulius-brightgreen.svg)](https://github.com/bvschaik/julius)
[![Language: English](https://img.shields.io/badge/Language-English-blue.svg)](README.md)

> 🏛️ **Este repositorio es un fork mejorado de [bvschaik/julius](https://github.com/bvschaik/julius)** que añade soporte nativo para iPadOS, escalado de interfaz y menús de borde a borde, bloqueo a pantalla completa en horizontal, integración con el ciclo de vida `UIWindowScene` y gestión de archivos directa con la app Archivos de Apple.
>
> 📖 *Read in [English](README.md)*

Julius es una reimplementación open-source del legendario juego de gestión y construcción de ciudades **Caesar III (Impressions Games, 1998)**. Este fork te permite compilar e instalar Julius de forma totalmente nativa en tu **iPad o iPhone** utilizando Xcode y una cuenta gratuita de Apple ID, con control táctil completo, menús adaptados a toda la pantalla y sin emuladores intermediarios.

---

## ✨ Características Principales en este Fork para iPadOS

* **📺 Ciclo de Vida Moderno `UIWindowScene` (iOS 16+)**:
  * Integración con la arquitectura moderna de escenas de Apple, eliminando el fallo de pantalla negra al arrancar en iOS 16+.
  * Bloqueo nativo a pantalla completa en orientación horizontal (`LandscapeLeft` / `LandscapeRight`).
* **📐 Escalado de Interfaz y Menús de Borde a Borde**:
  * La pantalla de título, los informes de misión, los intermezzos y los menús de campaña se escalan dinámicamente para ocupar toda la pantalla del iPad sin bandas negras ni distorsión.
* **📁 Gestión de Archivos Directa con la app Archivos de iPadOS**:
  * Parámetros `UIFileSharingEnabled` y `LSSupportsOpeningDocumentsInPlace` activados de serie.
  * Transfiere tu carpeta original de Caesar 3 directamente a `En mi iPad > Julius` usando la app **Archivos** de iPadOS o el **Finder** de tu Mac, sin herramientas complejas.
* **🎮 Controles Táctiles y Soporte de Periféricos**:
  * Control táctil 1:1 para construir carreteras, acueductos y delimitar zonas.
  * Arrastre con dos dedos para desplazarse suavemente por el mapa.
  * Compatibilidad total con **Apple Pencil**, **Magic Keyboard**, ratón y trackpad Bluetooth.
* **💾 Compatibilidad Total de Partidas Guardadas**:
  * Las partidas son 100% compatibles con Caesar III original y las versiones de escritorio de Julius.
  * Se guardan directamente en la carpeta accesible de Documentos para que puedas respaldarlas fácilmente.
* **⚡ Compilación Limpia en Xcode Moderno**:
  * Eliminadas todas las advertencias de compilador, libtool (`-no_warning_for_no_symbols`) y alineación del enlazador (`-fno-common`) para Xcode 15/16+ y Apple Clang.

---

## 🏛️ Arquitectura del Sistema

```
┌────────────────────────────────────────────────────────┐
│             Capa Anfitrión iPadOS (UIKit)              │
│   • UIWindowSceneDelegate y bloqueo horizontal         │
│   • Compartición de sandbox con Archivos de Apple      │
│   • Enrutado de eventos multitáctiles y Apple Pencil   │
└──────────────────────────┬─────────────────────────────┘
                           │ Backend SDL2 SysWM / UIKit
                           ▼
┌────────────────────────────────────────────────────────┐
│          Capa Multimedia SDL2 y SDL2_mixer             │
│   • Presentación de vídeo acelerada ARM64 Metal/GL     │
│   • Motor de audio CoreAudio de ultra-baja latencia    │
│   • Escalado dinámico de superficie gráfica            │
└──────────────────────────┬─────────────────────────────┘
                           │ Llamadas nativas en C
                           ▼
┌────────────────────────────────────────────────────────┐
│             Motor de Juego Julius (AGPL-3.0)           │
│   • Simulación y lógica original de Caesar III         │
│   • Carga de recursos desde ~/Documents/C3/            │
│   • Motor de guardado compatible a nivel de byte       │
└──────────────────────────┘
```

---

## 📋 Requisitos Previos

1. **Mac (Apple Silicon o Intel)**:
   * macOS 14 (Sonoma) o macOS 15 (Sequoia) o superior.
   * **Xcode 15 o superior** instalado desde el Mac App Store.
   * Herramientas de línea de comandos de Xcode (`xcode-select --install`).
   * **Homebrew** instalado ([brew.sh](https://brew.sh)).
2. **iPad (o iPhone)**:
   * Con **iPadOS 16.0 o superior**.
   * Cable USB-C o Lightning para conectarlo al Mac.
3. **Cuenta gratuita de Apple ID**:
   * Tu cuenta de Apple estándar sirve; no necesitas una cuenta de desarrollador de pago (\$99/año).
4. **Archivos originales de Caesar III**:
   * Una copia digital original de [GOG.com](https://www.gog.com/game/caesar_3) (parcheada a la versión 1.0.1.0).

---

## 🚀 Tutorial Paso a Paso: Desde GOG a tu iPad

Sigue estos pasos para extraer los archivos, compilar el proyecto e instalar Caesar III en tu iPad:

### Paso 1: Instalar Herramientas de Compilación en tu Mac

Abre la aplicación **Terminal** en tu Mac e instala `cmake` y el extractor `innoextract` con Homebrew:

```bash
brew install cmake innoextract
```

---

### Paso 2: Descargar y Extraer Caesar III desde GOG

1. Inicia sesión en [GOG.com](https://www.gog.com), ve a tu biblioteca, selecciona **Caesar 3** y en **Download Offline Backup Game Installers** descarga el instalador `.exe` (por ejemplo `setup_caesar_3_1.0.1.0_(...).exe`).
2. En la Terminal, extrae los archivos del instalador de GOG:
   ```bash
   cd ~/Downloads
   innoextract setup_caesar_3*.exe -d c3_extraido
   ```
3. Prepara la carpeta de datos del juego nombrada **`C3`** en tu Escritorio:
   ```bash
   mv c3_extraido/app ~/Desktop/C3
   ```
   *(Si los archivos están en la raíz de `c3_extraido`, simplemente mueve la carpeta completa: `mv c3_extraido ~/Desktop/C3`).*

---

### Paso 3: Clonar este Repositorio

```bash
git clone https://github.com/MargeLenders/julius.git
cd julius
```

---

### Paso 4: Descargar las Dependencias SDL2 y SDL2_mixer

Descarga los paquetes de código fuente de SDL2 directamente en la carpeta `ext/SDL2/`:

```bash
mkdir -p ext/SDL2
curl -L https://github.com/libsdl-org/SDL/releases/download/release-2.32.8/SDL2-2.32.8.tar.gz | tar xz -C ext/SDL2
curl -L https://github.com/libsdl-org/SDL_mixer/releases/download/release-2.8.1/SDL2_mixer-2.8.1.tar.gz | tar xz -C ext/SDL2
```

---

### Paso 5: Generar el Proyecto de Xcode

Genera el proyecto de Xcode para iOS/iPadOS con CMake:

```bash
mkdir build_ios && cd build_ios
cmake .. -DTARGET_PLATFORM=ios -G Xcode
open julius.xcodeproj
```

---

### Paso 6: Configurar la Firma en Xcode

1. En el navegador izquierdo de Xcode, haz clic en el icono azul del proyecto **julius** (arriba del todo).
2. En la lista **TARGETS**, selecciona **julius**.
3. Ve a la pestaña **Signing & Capabilities**.
4. Marca la casilla **Automatically manage signing**.
5. En el desplegable **Team**, selecciona tu cuenta personal (*Personal Team*). Si no aparece, haz clic en *Add Account...* e inicia sesión con tu Apple ID gratuito.
6. En **Bundle Identifier**, cambia `com.github.bvschaik.julius` por un identificador único propio:
   ```text
   com.tuapodo.julius
   ```

```
┌────────────────────────────────────────────────────────────────────────┐
│ Signing & Capabilities                                                │
├────────────────────────────────────────────────────────────────────────┤
│ [✓] Automatically manage signing                                      │
│                                                                        │
│ Team:              [ Tu Nombre (Personal Team)               ▼ ]      │
│ Bundle Identifier: [ com.tuapodo.julius                              ] │
└────────────────────────────────────────────────────────────────────────┘
```

---

### Paso 7: Activar el Modo Desarrollador en el iPad (Solo la primera vez)

En tu iPad con iPadOS 16+:
1. Ve a **Ajustes** $\rightarrow$ **Privacidad y seguridad**.
2. Desplázate hasta abajo del todo y toca en **Modo desarrollador**.
3. Activa la casilla y pulsa **Reiniciar**.
4. Al reiniciar, desbloquea el iPad, pulsa **Activar** e introduce el código de bloqueo de tu dispositivo.

---

### Paso 8: Compilar e Instalar en el iPad

1. Conecta tu iPad al Mac por cable (toca **Confiar en este ordenador** en el iPad si aparece el aviso).
2. En la barra superior de Xcode, selecciona **julius** como esquema y elige **tu iPad físico** como destino.
3. Pulsa el botón **Run (▶)** o presiona `Cmd + R`.
4. Xcode compilará Julius, enlazará las librerías SDL2 e instalará la aplicación en tu iPad.

---

### Paso 9: Autorizar el Certificado de Desarrollador en el iPad

Si al abrir la app aparece el aviso de *"Desarrollador no confiable"*:
1. En tu iPad, abre **Ajustes** $\rightarrow$ **General**.
2. Toca en **VPN y gestión de dispositivos**.
3. En la sección *App de desarrollador*, toca sobre tu **Apple ID** y selecciona **Confiar**.

---

### Paso 10: Copiar la Carpeta `C3` al iPad

Al tener la compartición de documentos activada, transferir los archivos toma segundos:

#### Opción A: Desde el Finder del Mac (Recomendada)
1. En el **Finder** de tu Mac, haz clic sobre tu **iPad** en la barra lateral.
2. Haz clic en la pestaña superior **Archivos (Files)**.
3. Localiza la carpeta **julius** en la lista.
4. Arrastra la carpeta **`C3`** desde tu Escritorio (`~/Desktop/C3`) y suéltala directamente encima del icono de **julius**.

#### Opción B: Desde la app Archivos del iPad (AirDrop / iCloud)
1. Envía la carpeta **`C3`** al iPad mediante AirDrop o colócala en iCloud Drive.
2. Abre la app **Archivos** en tu iPad.
3. Mueve la carpeta **`C3`** dentro de **En mi iPad** $\rightarrow$ **julius**.

---

### Paso 11: ¡A Gobernar Roma! 🍇

Abre **Julius** en la pantalla de inicio de tu iPad. El juego detectará automáticamente la carpeta `C3`, inicializará el audio y arrancará directamente a pantalla completa.

---

## 🎮 Controles Táctiles y Gestos

| Gesto / Entrada | Acción en Caesar III | Descripción |
| :--- | :--- | :--- |
| **Toque con 1 dedo** | **Clic Izquierdo** | Seleccionar edificios, colocar carreteras/acueductos, pulsar botones. |
| **Arrastrar con 1 dedo** | **Construir / Arrastrar** | Construir tramos de carreteras, acueductos, murallas y demoler. |
| **Arrastrar con 2 dedos** | **Mover el Mapa** | Desplazar suavemente la cámara por toda la ciudad. |
| **Toque con 2 dedos / Pulsación larga** | **Clic Derecho** | Consultar ciudadanos, inspeccionar edificios o cancelar acción. |
| **Apple Pencil** | **Puntero de Precisión** | Colocación exacta de infraestructuras y botones pequeños. |
| **Magic Keyboard** | **Atajos de Teclado** | Tecla `P` para pausar, `Espacio` para capas, números `1`–`5` para velocidad. |
| **Ratón / Trackpad Bluetooth** | **Ratón de Escritorio** | Comportamiento estándar de ratón con clic izquierdo y derecho. |

---

## ❓ Preguntas Frecuentes y Solución de Problemas

#### P: ¿Cuánto tiempo dura la app instalada con un Apple ID gratuito?
**R:** Los certificados personales gratuitos de Apple duran **7 días**. Cuando caduque, **no borres la app** (para no perder tus partidas guardadas). Conecta de nuevo el iPad al Mac, abre Xcode y pulsa **Run (▶)** (`Cmd + R`). La firma se renovará por otros 7 días manteniendo todas tus partidas intactas.

#### P: ¿Dónde se guardan las partidas?
**R:** Dentro de la carpeta `C3` en `En mi iPad > Julius`. Puedes copiarlas, respaldarlas o pasarlas a tu ordenador en cualquier momento desde la app Archivos de iPadOS o el Finder.

#### P: Xcode muestra el error *"Failed to register bundle identifier"*.
**R:** Los identificadores de paquete deben ser únicos a nivel mundial. Cambia `com.tuapodo.julius` por otro texto en **Signing & Capabilities** (por ejemplo `com.tuapodo.caesar3`).

#### P: ¿Puedo ajustar el zoom o escala visual del mapa?
**R:** ¡Sí! Dentro de una partida, abre **Opciones** $\rightarrow$ **Ajustes de pantalla** para cambiar la escala y el zoom a tu gusto.

---

## ℹ️ Acerca del Proyecto Original Julius

* **Repositorio Original:** [bvschaik/julius](https://github.com/bvschaik/julius)
* **Desarrolladora Principal:** Bianca van Schaik ([@bvschaik](https://github.com/bvschaik))
* **Wiki Oficial de Julius:** [bvschaik/julius/wiki](https://github.com/bvschaik/julius/wiki)
* **Discord de la Comunidad:** [Discord](http://www.discord.gg/GamerZakh)

---

## ⚖️ Aviso Legal y Licencias

* **Caesar III**: © 1998 Sierra On-Line, Inc. / Activision. Todos los derechos reservados. Ni este repositorio ni sus colaboradores distribuyen archivos comerciales, gráficos ni música con copyright. Debes suministrar tu propia copia legítima de Caesar III.
* **Julius**: Publicado bajo la licencia **GNU Affero General Public License v3.0 (AGPL-3.0)**. Consulta [LICENSE.txt](LICENSE.txt) para más detalles.

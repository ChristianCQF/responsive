# Responsive

Sistema de diseño responsivo para Flutter basado en el tamaño real de la ventana.

`Responsive` permite construir interfaces adaptativas para **Mobile, Tablet, Desktop, Large Desktop, Extra Large, Foldables y diferentes orientaciones**, incorporando escalado independiente por eje, escalado proporcional, control del tamaño de texto del sistema, Safe Area e interpolación fluida.

El sistema utiliza diferentes referencias de diseño según el tamaño de la ventana y aplica límites de escala para evitar tamaños extremos y problemas de overflow.

---

## Características

* 📱 Soporte para Mobile
* 📲 Soporte para Tablet
* 🖥️ Soporte para Desktop
* 🖥️ Soporte para Large Desktop
* 🖥️ Soporte para Extra Large / 4K
* 🔄 Portrait / Landscape
* 📐 Escalado horizontal y vertical independiente
* 🔠 Escalado proporcional de fuentes
* 🔲 Escalado proporcional para iconos, avatares y otros elementos
* 🔒 Límites mínimos y máximos de escala
* ♿ Control del escalado de texto del sistema
* 📏 Cálculo de Safe Area
* 📱 Detección de dispositivos Foldable
* 🔀 Detección de Hinge / Fold
* 🪟 Window Size Classes
* 🎛️ Selección automática de layouts
* 📈 Interpolación fluida mediante `range()`
* 🎯 Referencias de diseño independientes por categoría
* 🧩 Extensiones para `BuildContext`
* 🧩 Extensiones para valores numéricos

---

# Contenido

* [Instalación](#instalación)
* [Configuración](#configuración)
* [Uso](#uso)
* [Breakpoints](#breakpoints)
* [Referencias de diseño](#referencias-de-diseño)
* [Escalado](#escalado)
* [Escalado de fuentes](#escalado-de-fuentes)
* [Text Scale del sistema](#text-scale-del-sistema)
* [WindowSizeClass](#windowsizeclass)
* [ResponsiveLayout](#responsivelayout)
* [ResponsiveBuilder](#responsivebuilder)
* [Selección de valores](#selección-de-valores)
* [Safe Area](#safe-area)
* [Foldables](#foldables)
* [Interpolación con range](#interpolación-con-range)
* [Adaptive Mobile](#adaptive-mobile)
* [Adaptive Tablet](#adaptive-tablet)
* [Adaptive Desktop](#adaptive-desktop)
* [API](#api)
* [Ejemplo completo](#ejemplo-completo)
* [Filosofía del sistema](#filosofía-del-sistema)

---

# Instalación

Si `Responsive` forma parte directamente de tu proyecto Flutter, agrega el archivo en una estructura similar a:

```text
lib/
└── core/
    └── responsive/
        └── responsive.dart
```

Después importa el archivo:

```dart
import 'package:tu_app/core/responsive/responsive.dart';
```

> Si posteriormente conviertes esta clase en un paquete Flutter independiente, puedes utilizarla como una dependencia mediante `pubspec.yaml`.

---

# Configuración

La configuración principal se encuentra en:

```dart
ResponsiveConfig
```

Los valores actuales son:

```dart
class ResponsiveConfig {
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  static const double largeDesktopBreakpoint = 1440.0;
  static const double extraLargeBreakpoint = 1920.0;
}
```

---

# Breakpoints

El sistema utiliza los siguientes breakpoints:

| Categoría     | Ancho de ventana |
| ------------- | ---------------: |
| Mobile        |       `< 600 px` |
| Tablet        |  `600 - 1023 px` |
| Desktop       |     `>= 1024 px` |
| Large Desktop |     `>= 1440 px` |
| Extra Large   |     `>= 1920 px` |

Los breakpoints de `600` y `1024` son los responsables de las propiedades:

```dart
context.isMobile
context.isTablet
context.isDesktop
```

Los breakpoints de `1440` y `1920` permiten realizar una clasificación más precisa de las ventanas grandes mediante `WindowSizeClass`.

---

# Referencias de diseño

El sistema no utiliza una única pantalla de referencia.

Cada categoría tiene su propia referencia:

| Categoría     |    Referencia |
| ------------- | ------------: |
| Mobile        |   `411 × 832` |
| Tablet        |   `851 × 882` |
| Desktop       |  `1280 × 800` |
| Large Desktop |  `1440 × 900` |
| Extra Large   | `1920 × 1080` |

Esto permite evitar que, por ejemplo, una pantalla de `1024 px` y un monitor 4K utilicen exactamente la misma referencia de escalado.

---

# Límites de escala

Para evitar tamaños extremos, el sistema utiliza:

```dart
static const double minScaleFactor = 0.75;
static const double maxScaleFactor = 1.6;
```

Por lo tanto, los tamaños escalados están limitados a:

```text
75% ─────────────── 100% ─────────────── 160%
```

Esto funciona como una protección adicional para dispositivos o ventanas con dimensiones extremas.

Es especialmente útil para:

* teléfonos pequeños
* foldables
* ventanas redimensionables
* monitores ultrawide
* monitores 4K

---

# Uso

La aplicación debe estar dentro de `ResponsiveWrapper`.

```dart
void main() {
  runApp(
    ResponsiveWrapper(
      child: const MyApp(),
    ),
  );
}
```

Después puedes utilizar las extensiones desde cualquier widget descendiente.

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      height: 100.h,
    );
  }
}
```

---

# Escalado

El sistema proporciona las siguientes extensiones numéricas:

```dart
.w
.h
.sp
.size
```

---

## `.w`

Escalado horizontal.

```dart
Container(
  width: 200.w,
)
```

Utiliza el `widthScaleFactor` correspondiente al tamaño actual de la ventana.

---

## `.h`

Escalado vertical.

```dart
Container(
  height: 100.h,
)
```

Utiliza el `heightScaleFactor` correspondiente al tamaño actual de la ventana.

---

## `.size`

Escalado proporcional.

```dart
Icon(
  Icons.home,
  size: 32.size,
)
```

Está pensado para elementos que deben mantener una proporción uniforme:

* iconos
* avatares
* imágenes
* radios
* controles cuadrados
* elementos proporcionales

Utiliza el menor factor entre el escalado horizontal y vertical.

---

# Escalado de fuentes

Para fuentes utiliza:

```dart
.sp
```

Ejemplo:

```dart
Text(
  'Responsive',
  style: TextStyle(
    fontSize: 18.sp,
  ),
)
```

`.sp` utiliza el `uniformScaleFactor`.

Esto significa que la fuente utiliza el factor más restrictivo entre ancho y alto.

Por ejemplo, una ventana extremadamente ancha pero muy baja no provocará que el texto crezca únicamente porque existe mucho espacio horizontal.

---

# Text Scale del sistema

El sistema obtiene el tamaño de fuente configurado por el usuario en el sistema operativo.

Puedes consultar el valor mediante:

```dart
final scale = context.responsive.systemTextScale;
```

El valor se limita actualmente entre:

```dart
static const double minSystemTextScale = 0.95;
static const double maxSystemTextScale = 1.3;
```

Puedes decidir si el escalado de accesibilidad del sistema debe aplicarse:

```dart
ResponsiveConfig.respectSystemTextScale = true;
```

o desactivarlo:

```dart
ResponsiveConfig.respectSystemTextScale = false;
```

Cuando está desactivado, `.sp` utiliza únicamente el escalado geométrico de la pantalla.

---

# WindowSizeClass

Además de:

```dart
isMobile
isTablet
isDesktop
```

el sistema proporciona:

```dart
enum WindowSizeClass {
  compact,
  medium,
  expanded,
  large,
  extraLarge,
}
```

Puedes obtenerlo mediante:

```dart
context.windowSizeClass
```

Las categorías son:

| WindowSizeClass |            Ancho |
| --------------- | ---------------: |
| `compact`       |       `< 600 px` |
| `medium`        |  `600 - 1023 px` |
| `expanded`      | `1024 - 1439 px` |
| `large`         | `1440 - 1919 px` |
| `extraLarge`    |     `>= 1920 px` |

Ejemplo:

```dart
switch (context.windowSizeClass) {
  case WindowSizeClass.compact:
    return const MobileHome();

  case WindowSizeClass.medium:
    return const TabletHome();

  case WindowSizeClass.expanded:
    return const DesktopHome();

  case WindowSizeClass.large:
    return const LargeDesktopHome();

  case WindowSizeClass.extraLarge:
    return const ExtraLargeHome();
}
```

---

# ResponsiveLayout

Cuando necesitas seleccionar automáticamente una pantalla completa puedes utilizar:

```dart
ResponsiveLayout(
  mobile: const MobileHome(),
  tablet: const TabletHome(),
  desktop: const DesktopHome(),
  largeDesktop: const LargeDesktopHome(),
)
```

La selección se realiza automáticamente según el tamaño actual de la ventana.

## Fallback

Los valores no definidos utilizan automáticamente el tier anterior.

Por ejemplo:

```dart
ResponsiveLayout(
  mobile: const MobileHome(),
  tablet: const TabletHome(),
  desktop: const DesktopHome(),
)
```

En `large` y `extraLarge`, se utilizará automáticamente `desktop`.

---

# ResponsiveBuilder

`ResponsiveBuilder` proporciona acceso directo al `ResponsiveData`.

```dart
ResponsiveBuilder(
  builder: (context, responsive) {
    return Text(
      'Ancho: ${responsive.width}',
    );
  },
)
```

También puedes acceder a:

```dart
responsive.width
responsive.height

responsive.safeWidth
responsive.safeHeight

responsive.widthScaleFactor
responsive.heightScaleFactor
responsive.uniformScaleFactor

responsive.devicePixelRatio
responsive.systemTextScale

responsive.isMobile
responsive.isTablet
responsive.isDesktop

responsive.isPortrait
responsive.isLandscape

responsive.windowSizeClass
```

---

# Selección de valores

Puedes seleccionar diferentes valores dependiendo del tamaño de ventana mediante:

```dart
context.pickValue()
```

Ejemplo:

```dart
final columns = context.pickValue(
  mobile: 1,
  tablet: 2,
  desktop: 4,
  largeDesktop: 6,
);
```

Resultado:

| Tamaño        | Columnas |
| ------------- | -------: |
| Mobile        |      `1` |
| Tablet        |      `2` |
| Desktop       |      `4` |
| Large Desktop |      `6` |
| Extra Large   |      `6` |

Si un valor no está definido, se utiliza automáticamente el tier inmediatamente inferior.

---

# Adaptive

También puedes utilizar:

```dart
context.adaptive()
```

Ejemplo:

```dart
final padding = context.adaptive(
  mobile: 12.0,
  tablet: 20.0,
  desktop: 32.0,
);
```

La selección se realiza entre:

```text
Mobile
Tablet
Desktop
```

---

# Safe Area

El sistema obtiene automáticamente el `safePadding` del dispositivo.

Puedes acceder a:

```dart
context.responsive.safePadding
```

También existen:

```dart
context.safeWidth
context.safeHeight
```

Ejemplo:

```dart
final width = context.safeWidth;
final height = context.safeHeight;
```

`safeWidth` descuenta las áreas seguras horizontales.

`safeHeight` descuenta las áreas seguras verticales.

Esto permite trabajar con el espacio disponible después de considerar elementos como:

* Status Bar
* Navigation Bar
* Gesture Area
* Notch
* Punch-hole
* otras áreas no seguras

---

# Foldables

El sistema detecta automáticamente dispositivos con:

```dart
DisplayFeatureType.hinge
```

o:

```dart
DisplayFeatureType.fold
```

Puedes consultar:

```dart
context.isFoldable
```

Ejemplo:

```dart
if (context.isFoldable) {
  return const FoldableLayout();
}

return const NormalLayout();
```

---

# Split Regions

En dispositivos Foldable con una bisagra vertical puedes obtener las regiones disponibles mediante:

```dart
final regions = context.splitRegions;
```

El resultado contiene:

```dart
regions?.left
regions?.right
```

Ejemplo:

```dart
final regions = context.splitRegions;

if (regions != null) {
  print('Left: ${regions.left}');
  print('Right: ${regions.right}');
}
```

Esto permite diseñar interfaces independientes para ambos lados de un dispositivo plegable.

---

# Interpolación con `range`

`range()` permite interpolar un valor entre un mínimo y un máximo según el ancho de la ventana.

Ejemplo:

```dart
final fontSize = 18.range(14, 28);
```

También puedes utilizarlo directamente:

```dart
Text(
  'Responsive Text',
  style: TextStyle(
    fontSize: 18.range(14, 28),
  ),
)
```

La interpolación utiliza:

```dart
rangeMinW = 360.0;
rangeMaxW = 1920.0;
```

y utiliza la referencia mobile como punto de transición.

Conceptualmente se comporta de forma similar a un:

```css
clamp()
```

de CSS.

---

# Adaptive Mobile

Permite realizar una interpolación específica para Mobile/Tablet.

```dart
final value = 16.adaptiveMobile(
  12,
  20,
);
```

El comportamiento es:

```text
< 360 px
    ↓
min

360 → 600
    ↓
min → base

600 → 1024
    ↓
base → max

>= 1024
    ↓
max
```

El escalado se detiene al alcanzar el breakpoint desktop.

---

# Adaptive Tablet

Permite realizar una interpolación específica para Tablet.

```dart
final value = 16.adaptiveTablet(
  14,
  22,
);
```

Utiliza:

```text
600 px
   ↓
851 px
   ↓
1024 px
```

donde `851 px` corresponde a la referencia tablet.

El resultado permanece limitado al intervalo definido.

---

# Adaptive Desktop

Permite realizar una interpolación específica para Desktop.

```dart
final value = 24.adaptiveDesktop(
  20,
  32,
);
```

El valor se interpola a partir de:

```text
1024 px
```

hasta:

```text
1920 px
```

Después de `1920 px`, se alcanza el valor máximo.

---

# API

## ResponsiveConfig

Configuración global:

```dart
ResponsiveConfig.mobileBreakpoint
ResponsiveConfig.tabletBreakpoint

ResponsiveConfig.largeDesktopBreakpoint
ResponsiveConfig.extraLargeBreakpoint

ResponsiveConfig.mobileRefW
ResponsiveConfig.mobileRefH

ResponsiveConfig.tabletRefW
ResponsiveConfig.tabletRefH

ResponsiveConfig.desktopRefW
ResponsiveConfig.desktopRefH

ResponsiveConfig.largeDesktopRefW
ResponsiveConfig.largeDesktopRefH

ResponsiveConfig.extraLargeRefW
ResponsiveConfig.extraLargeRefH

ResponsiveConfig.minScaleFactor
ResponsiveConfig.maxScaleFactor

ResponsiveConfig.minSystemTextScale
ResponsiveConfig.maxSystemTextScale

ResponsiveConfig.respectSystemTextScale
```

---

## ResponsiveData

Datos responsivos actuales:

```dart
context.responsive.width
context.responsive.height

context.responsive.isMobile
context.responsive.isTablet
context.responsive.isDesktop

context.responsive.isPortrait
context.responsive.isLandscape

context.responsive.devicePixelRatio
context.responsive.systemTextScale

context.responsive.safePadding

context.responsive.safeWidth
context.responsive.safeHeight

context.responsive.windowSizeClass

context.responsive.widthScaleFactor
context.responsive.heightScaleFactor
context.responsive.uniformScaleFactor

context.responsive.referenceWidth
context.responsive.referenceHeight

context.responsive.isFoldable
context.responsive.splitRegions
```

---

# Extensiones numéricas

| Extensión                    | Descripción           |
| ---------------------------- | --------------------- |
| `.w`                         | Escalado horizontal   |
| `.h`                         | Escalado vertical     |
| `.sp`                        | Escalado de fuente    |
| `.size`                      | Escalado proporcional |
| `.range(min, max)`           | Interpolación fluida  |
| `.adaptiveMobile(min, max)`  | Escalado Mobile       |
| `.adaptiveTablet(min, max)`  | Escalado Tablet       |
| `.adaptiveDesktop(min, max)` | Escalado Desktop      |

---

# Extensiones de BuildContext

| Extensión                 | Descripción                     |
| ------------------------- | ------------------------------- |
| `context.responsive`      | Obtiene `ResponsiveData`        |
| `context.isMobile`        | Detecta Mobile                  |
| `context.isTablet`        | Detecta Tablet                  |
| `context.isDesktop`       | Detecta Desktop                 |
| `context.isPortrait`      | Detecta Portrait                |
| `context.isLandscape`     | Detecta Landscape               |
| `context.orientation`     | Obtiene la orientación          |
| `context.windowSizeClass` | Obtiene la clase de ventana     |
| `context.safeWidth`       | Ancho seguro disponible         |
| `context.safeHeight`      | Alto seguro disponible          |
| `context.isFoldable`      | Detecta Foldable                |
| `context.splitRegions`    | Obtiene regiones del Foldable   |
| `context.adaptive()`      | Selección Mobile/Tablet/Desktop |
| `context.pickValue()`     | Selección por tamaño de ventana |

---

# Ejemplo completo

```dart
import 'package:flutter/material.dart';

import 'core/responsive/responsive.dart';

void main() {
  runApp(
    ResponsiveWrapper(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const MobileHome(),
      tablet: const TabletHome(),
      desktop: const DesktopHome(),
      largeDesktop: const LargeDesktopHome(),
    );
  }
}
```

---

## Mobile

```dart
class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              'Mobile',
              style: TextStyle(
                fontSize: 24.sp,
              ),
            ),

            SizedBox(height: 20.h),

            Icon(
              Icons.phone_android,
              size: 48.size,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Tablet

```dart
class TabletHome extends StatelessWidget {
  const TabletHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Tablet',
          style: TextStyle(
            fontSize: 28.sp,
          ),
        ),
      ),
    );
  }
}
```

---

## Desktop

```dart
class DesktopHome extends StatelessWidget {
  const DesktopHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Desktop',
          style: TextStyle(
            fontSize: 32.sp,
          ),
        ),
      ),
    );
  }
}
```

---

## Large Desktop

```dart
class LargeDesktopHome extends StatelessWidget {
  const LargeDesktopHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Large Desktop',
          style: TextStyle(
            fontSize: 36.sp,
          ),
        ),
      ),
    );
  }
}
```

---

# Ejemplo de Grid adaptativo

Puedes combinar `pickValue()` con las extensiones de escalado:

```dart
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = context.pickValue(
      mobile: 2,
      tablet: 3,
      desktop: 4,
      largeDesktop: 6,
    );

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          child: Icon(
            Icons.shopping_bag,
            size: 36.size,
          ),
        );
      },
    );
  }
}
```

---

# Ejemplo utilizando orientación

Puedes consultar:

```dart
context.isPortrait
```

y:

```dart
context.isLandscape
```

Ejemplo:

```dart
Widget build(BuildContext context) {
  if (context.isPortrait) {
    return const PortraitLayout();
  }

  return const LandscapeLayout();
}
```

También:

```dart
switch (context.orientation) {
  case Orientation.portrait:
    return const PortraitLayout();

  case Orientation.landscape:
    return const LandscapeLayout();
}
```

---

# Filosofía del sistema

El sistema está diseñado para separar dos conceptos:

### 1. Layout

Determina **qué estructura debe utilizar la interfaz**.

Por ejemplo:

```text
Mobile
Tablet
Desktop
Large Desktop
```

Esto se controla mediante:

```dart
ResponsiveLayout
context.isMobile
context.isTablet
context.isDesktop
context.windowSizeClass
context.pickValue()
```

### 2. Scaling

Determina **qué tamaño deben tener los elementos dentro de esa estructura**.

Esto se controla mediante:

```dart
.w
.h
.sp
.size
.range()
.adaptiveMobile()
.adaptiveTablet()
.adaptiveDesktop()
```

De esta forma puedes tener:

```text
              RESPONSIVE
                   │
          ┌────────┴────────┐
          │                 │
        LAYOUT           SCALING
          │                 │
     ┌────┼────┐       ┌────┼────┐
   Mobile Tablet       .w  .h  .sp
   Desktop             .size
   Large               range()
   Extra Large         adaptive()
```

---

# Recomendaciones de uso

### Para anchos

Utiliza:

```dart
200.w
```

### Para alturas

Utiliza:

```dart
100.h
```

### Para fuentes

Utiliza:

```dart
16.sp
```

### Para iconos

Utiliza:

```dart
24.size
```

### Para layouts diferentes

Utiliza:

```dart
ResponsiveLayout(...)
```

### Para obtener información responsiva

Utiliza:

```dart
context.responsive
```

### Para seleccionar valores

Utiliza:

```dart
context.pickValue(...)
```

### Para tamaños fluidos

Utiliza:

```dart
16.range(12, 24)
```

### Para detectar Foldables

Utiliza:

```dart
context.isFoldable
```

---

# Arquitectura

El sistema está dividido conceptualmente en:

```text
ResponsiveConfig
        │
        ▼
ResponsiveData
        │
        ▼
ResponsiveWrapper
        │
        ├── ResponsiveBuilder
        │
        ├── ResponsiveLayout
        │
        ├── ResponsiveNumExt
        │
        └── ResponsiveCtxExt
```

### `ResponsiveConfig`

Contiene los breakpoints, referencias y límites de escalado.

### `ResponsiveData`

Contiene toda la información calculada de la ventana actual.

### `ResponsiveWrapper`

Calcula y proporciona los datos responsivos al árbol de widgets.

### `ResponsiveBuilder`

Permite trabajar directamente con `ResponsiveData`.

### `ResponsiveLayout`

Permite seleccionar diferentes widgets según el tamaño de ventana.

### `ResponsiveNumExt`

Proporciona `.w`, `.h`, `.sp`, `.size`, `range()` y los métodos adaptive.

### `ResponsiveCtxExt`

Proporciona acceso sencillo mediante `BuildContext`.

---

# Consideraciones

`ResponsiveWrapper` debe estar por encima de los widgets que utilizan:

```dart
.w
.h
.sp
.size
```

Por ejemplo:

```dart
void main() {
  runApp(
    ResponsiveWrapper(
      child: const MyApp(),
    ),
  );
}
```

Se recomienda utilizar:

```dart
context.responsive
```

en lugar de acceder directamente a:

```dart
ResponsiveWrapper.instance
```

cuando sea posible.

El acceso mediante `instance` existe como mecanismo global, pero el acceso mediante `BuildContext` es más seguro para escenarios como tests, hot reload y aplicaciones con múltiples ventanas.

---

# Licencia

Agrega aquí la licencia que corresponda a tu proyecto.

Por ejemplo:

```text
MIT License
```

---

# Autor

Desarrollado para aplicaciones Flutter multiplataforma con interfaces adaptativas.

---

## Roadmap

Posibles mejoras futuras:

* [ ] Soporte para más clases de tamaño de ventana
* [ ] Helpers para layouts de múltiples columnas
* [ ] Widgets responsivos adicionales
* [ ] Soporte avanzado para múltiples ventanas
* [ ] Tests automatizados para breakpoints
* [ ] Tests para Foldables
* [ ] Documentación de API generada automáticamente
* [ ] Publicación como paquete en `pub.dev`

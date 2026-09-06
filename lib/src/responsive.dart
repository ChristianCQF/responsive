import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureType, DisplayFeatureState;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

// ════════════════════════════════════════════════════════════════
// 1. CONFIGURACIÓN
// ════════════════════════════════════════════════════════════════
//
// Estándares usados:
// - Breakpoints originales (600 / 1024) para NO romper diseños ya
//   calibrados con isMobile / isTablet / isDesktop.
// - Sub-breakpoints extra (1440 / 1920) inspirados en las "window size
//   classes" de Material 3, usados solo para afinar el clamping de
//   escala en monitores grandes / 4K.
// - Límites de escala (min/max) para que NINGÚN valor `.w`, `.h`, `.sp`
//   o `.size` pueda crecer o encogerse más allá de lo razonable: esto es
//   lo que evita overflow en pantallas extremas (plegables angostos,
//   ultrawide) y texto ilegible en pantallas muy chicas.
class ResponsiveConfig {
  const ResponsiveConfig._();

  // 📏 BREAKPOINTS: para LÓGICA DE LAYOUT (columnas, visibilidad)
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  // 📏 Sub-breakpoints adicionales (no alteran isMobile/isTablet/isDesktop,
  // solo se usan para WindowSizeClass y clamping fino de escala).
  static const double largeDesktopBreakpoint = 1440.0;
  static const double extraLargeBreakpoint = 1920.0;

  // 📐 REFERENCIAS: dispositivo "base" de diseño por categoría.
  static const double mobileRefW = 411.0;
  static const double mobileRefH = 832.0;

  static const double tabletRefW = 851.0;
  static const double tabletRefH = 882.0;

  static const double desktopRefW = 1440.0;
  static const double desktopRefH = 900.0;

  // 🔒 LÍMITES DE ESCALA: el corazón del "estándar real" anti-overflow.
  // Ningún tamaño escalado puede salir de este rango relativo al valor
  // de diseño original, sin importar cuán extremo sea el dispositivo.
  static const double minScaleFactor = 0.75;
  static const double maxScaleFactor = 1.6;

  // 🔠 Límite para el factor de accesibilidad del sistema (Ajustes >
  // Tamaño de letra). Permite respetar la accesibilidad sin que un
  // usuario con fuente 3x rompa completamente el layout.
  static const double minSystemTextScale = 0.85;
  static const double maxSystemTextScale = 1.3;

  // ✅ Límites del método `range` (interpolación explícita min↔max)
  static const double rangeMinW = 360.0;
  static const double rangeMaxW = 1920.0;
}

/// Clasificación de tamaño de ventana, alineada al espíritu de Material 3
/// (compact / medium / expanded / large / extra-large). Es un dato extra:
/// no reemplaza a isMobile/isTablet/isDesktop, los complementa.
enum WindowSizeClass { compact, medium, expanded, large, extraLarge }

// ════════════════════════════════════════════════════════════════
// 2. RESPONSIVE DATA
// ════════════════════════════════════════════════════════════════
@immutable
class ResponsiveData {
  final double width;
  final double height;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool isPortrait;
  final bool isLandscape;
  final List<DisplayFeature> displayFeatures;

  /// Densidad de píxeles físicos del dispositivo.
  final double devicePixelRatio;

  /// Factor de escala de texto del sistema operativo (accesibilidad),
  /// ya acotado entre [ResponsiveConfig.minSystemTextScale] y
  /// [ResponsiveConfig.maxSystemTextScale].
  final double systemTextScale;

  /// Áreas no seguras del dispositivo (notch, barra de estado, gestos,
  /// cámara en punch-hole, etc.). Útil para calcular espacio real
  /// disponible sin que el contenido quede tapado o desbordado.
  final EdgeInsets safePadding;

  const ResponsiveData({
    required this.width,
    required this.height,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isPortrait,
    required this.isLandscape,
    this.displayFeatures = const <DisplayFeature>[],
    this.devicePixelRatio = 1.0,
    this.systemTextScale = 1.0,
    this.safePadding = EdgeInsets.zero,
  });

  // ───────────────────── Referencias internas ─────────────────────
  double get _refW => isMobile
      ? ResponsiveConfig.mobileRefW
      : isTablet
      ? ResponsiveConfig.tabletRefW
      : ResponsiveConfig.desktopRefW;

  double get _refH => isMobile
      ? ResponsiveConfig.mobileRefH
      : isTablet
      ? ResponsiveConfig.tabletRefH
      : ResponsiveConfig.desktopRefH;

  // ───────────────────── Window size class ─────────────────────
  WindowSizeClass get windowSizeClass {
    if (width < ResponsiveConfig.mobileBreakpoint) {
      return WindowSizeClass.compact;
    }
    if (width < ResponsiveConfig.tabletBreakpoint) {
      return WindowSizeClass.medium;
    }
    if (width < ResponsiveConfig.largeDesktopBreakpoint) {
      return WindowSizeClass.expanded;
    }
    if (width < ResponsiveConfig.extraLargeBreakpoint) {
      return WindowSizeClass.large;
    }
    return WindowSizeClass.extraLarge;
  }

  // ───────────────────── Espacio seguro disponible ─────────────────────
  /// Ancho disponible real, descontando notch/status bar/gestos.
  double get safeWidth => math.max(0.0, width - safePadding.horizontal);

  /// Alto disponible real, descontando notch/status bar/gestos.
  double get safeHeight => math.max(0.0, height - safePadding.vertical);

  // ───────────────────── Factores de escala (clamped) ─────────────────────
  //
  // Este es el cambio central respecto a la versión anterior: en vez de
  // escalar linealmente sin límite (lo que provoca texto microscópico en
  // pantallas muy chicas o botones gigantes en monitores 4K/ultrawide),
  // cada factor se acota a [minScaleFactor, maxScaleFactor].
  //
  // Además, para elementos que deben mantener proporción (fuentes,
  // íconos, avatares, radios) se usa el MÍNIMO entre el factor de ancho
  // y el de alto: así, en un aspect ratio extremo (por ejemplo una
  // ventana muy ancha pero baja, o un plegable angosto) el elemento
  // jamás desborda el eje más restrictivo.

  /// Factor de escala horizontal, acotado.
  double get widthScaleFactor => (width / _refW).clamp(
    ResponsiveConfig.minScaleFactor,
    ResponsiveConfig.maxScaleFactor,
  );

  /// Factor de escala vertical, acotado.
  double get heightScaleFactor => (height / _refH).clamp(
    ResponsiveConfig.minScaleFactor,
    ResponsiveConfig.maxScaleFactor,
  );

  /// Factor "uniforme" (el más restrictivo de los dos ejes). Es el que
  /// garantiza "ver igual diseño sin desborde" en cualquier proporción.
  double get uniformScaleFactor =>
      math.min(widthScaleFactor, heightScaleFactor);

  /// Escala horizontal (paddings, márgenes, anchos de widgets).
  double scaleWidth(double size) => size * widthScaleFactor;

  /// Escala vertical (alturas, espaciados verticales).
  double scaleHeight(double size) => size * heightScaleFactor;

  /// Escala de fuente: usa el factor uniforme (nunca desborda por eje) y
  /// respeta -acotada- la preferencia de accesibilidad del sistema.
  double scaleFont(double size) => size * uniformScaleFactor * systemTextScale;

  /// Escala para elementos "cuadrados"/proporcionales (íconos, avatares,
  /// radios de borde) que no deben deformarse ni desbordar ningún eje.
  double scaleSize(double size) => size * uniformScaleFactor;

  // ───────────────────── Foldables ─────────────────────
  bool get isFoldable => displayFeatures.any(
    (f) =>
        f.type == DisplayFeatureType.hinge || f.type == DisplayFeatureType.fold,
  );

  ({double left, double right})? get splitRegions {
    final fold = displayFeatures.firstWhere(
      (f) =>
          (f.type == DisplayFeatureType.hinge ||
              f.type == DisplayFeatureType.fold) &&
          f.bounds.height > f.bounds.width,
      orElse: () => const DisplayFeature(
        type: DisplayFeatureType.unknown,
        bounds: Rect.zero,
        state: DisplayFeatureState.unknown,
      ),
    );
    if (fold.type == DisplayFeatureType.unknown) return null;
    final left = fold.bounds.left;
    final right = width - fold.bounds.right;
    return (left <= 0 || right <= 0) ? null : (left: left, right: right);
  }

  /// Elige un valor distinto según [windowSizeClass] actual, cayendo al
  /// tier inmediato inferior si uno específico no fue definido. Permite
  /// construir layouts adaptativos sin `if/else` repetidos:
  ///
  /// ```dart
  /// final columns = context.responsive.pick(mobile: 1, tablet: 2, desktop: 4);
  /// ```
  T pick<T>({required T mobile, T? tablet, T? desktop, T? largeDesktop}) {
    switch (windowSizeClass) {
      case WindowSizeClass.compact:
        return mobile;
      case WindowSizeClass.medium:
        return tablet ?? mobile;
      case WindowSizeClass.expanded:
        return desktop ?? tablet ?? mobile;
      case WindowSizeClass.large:
      case WindowSizeClass.extraLarge:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  ResponsiveData copyWith({
    double? width,
    double? height,
    bool? isMobile,
    bool? isTablet,
    bool? isDesktop,
    bool? isPortrait,
    bool? isLandscape,
    List<DisplayFeature>? displayFeatures,
    double? devicePixelRatio,
    double? systemTextScale,
    EdgeInsets? safePadding,
  }) {
    return ResponsiveData(
      width: width ?? this.width,
      height: height ?? this.height,
      isMobile: isMobile ?? this.isMobile,
      isTablet: isTablet ?? this.isTablet,
      isDesktop: isDesktop ?? this.isDesktop,
      isPortrait: isPortrait ?? this.isPortrait,
      isLandscape: isLandscape ?? this.isLandscape,
      displayFeatures: displayFeatures ?? this.displayFeatures,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
      systemTextScale: systemTextScale ?? this.systemTextScale,
      safePadding: safePadding ?? this.safePadding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResponsiveData &&
        other.width == width &&
        other.height == height &&
        other.isMobile == isMobile &&
        other.isTablet == isTablet &&
        other.isDesktop == isDesktop &&
        other.isPortrait == isPortrait &&
        other.isLandscape == isLandscape &&
        other.devicePixelRatio == devicePixelRatio &&
        other.systemTextScale == systemTextScale &&
        other.safePadding == safePadding &&
        listEquals(other.displayFeatures, displayFeatures);
  }

  @override
  int get hashCode => Object.hash(
    width,
    height,
    isMobile,
    isTablet,
    isDesktop,
    isPortrait,
    isLandscape,
    devicePixelRatio,
    systemTextScale,
    safePadding,
    Object.hashAll(displayFeatures),
  );
}

// ════════════════════════════════════════════════════════════════
// 3. RESPONSIVE WRAPPER
// ════════════════════════════════════════════════════════════════
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  static ResponsiveData? _data;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fallback robusto usando MediaQuery antes que valores hardcodeados.
        final mqSize = MediaQuery.sizeOf(context);
        double w = constraints.maxWidth;
        double h = constraints.maxHeight;

        if (!w.isFinite || w <= 0) {
          w = mqSize.width > 0 ? mqSize.width : ResponsiveConfig.mobileRefW;
        }
        if (!h.isFinite || h <= 0) {
          h = mqSize.height > 0 ? mqSize.height : ResponsiveConfig.mobileRefH;
        }

        final features =
            View.maybeOf(context)?.displayFeatures ??
            MediaQuery.maybeOf(context)?.displayFeatures ??
            const <DisplayFeature>[];

        final isMobile = w < ResponsiveConfig.mobileBreakpoint;
        final isTablet =
            w >= ResponsiveConfig.mobileBreakpoint &&
            w < ResponsiveConfig.tabletBreakpoint;
        final isDesktop = w >= ResponsiveConfig.tabletBreakpoint;

        // Orientación real del sistema (más fiable en foldables).
        final orientation = MediaQuery.orientationOf(context);
        final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final safePadding = MediaQuery.paddingOf(context);

        // El textScaler del sistema se acota para que la accesibilidad del
        // usuario no rompa el layout con fuentes desproporcionadas.
        final rawTextScale = MediaQuery.textScalerOf(context).scale(1.0);
        final systemTextScale = rawTextScale.clamp(
          ResponsiveConfig.minSystemTextScale,
          ResponsiveConfig.maxSystemTextScale,
        );

        final newData = ResponsiveData(
          width: w,
          height: h,
          isMobile: isMobile,
          isTablet: isTablet,
          isDesktop: isDesktop,
          isPortrait: orientation == Orientation.portrait,
          isLandscape: orientation == Orientation.landscape,
          displayFeatures: features,
          devicePixelRatio: devicePixelRatio,
          systemTextScale: systemTextScale.toDouble(),
          safePadding: safePadding,
        );

        _data = newData;
        return _ResponsiveInherited(data: newData, child: child);
      },
    );
  }

  /// ⚠️ ADVERTENCIA:
  /// Usar `instance` es frágil en tests unitarios, hot-reload o entornos
  /// multi-ventana. Prefiere siempre `context.responsive` o
  /// `ResponsiveWrapper.of(context)`.
  static ResponsiveData get instance {
    if (_data == null) {
      throw FlutterError(
        'ResponsiveWrapper no está inicializado.\n'
        'Asegúrate de que runApp() sea llamado con ResponsiveWrapper como raíz.\n'
        'Considera usar context.responsive en su lugar.',
      );
    }
    return _data!;
  }

  static ResponsiveData of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<_ResponsiveInherited>();
    if (widget == null) {
      throw FlutterError(
        'No se encontró ResponsiveWrapper en el árbol de widgets.',
      );
    }
    return widget.data;
  }
}

class _ResponsiveInherited extends InheritedWidget {
  final ResponsiveData data;
  const _ResponsiveInherited({required this.data, required super.child});

  @override
  bool updateShouldNotify(covariant _ResponsiveInherited oldWidget) {
    return data != oldWidget.data;
  }
}

// ════════════════════════════════════════════════════════════════
// 4. WIDGETS DE ALTO NIVEL (framework real: builders declarativos)
// ════════════════════════════════════════════════════════════════

/// Entrega el [ResponsiveData] vigente dentro de un `builder`, útil cuando
/// se necesita lógica más compleja que un simple `context.responsive`.
///
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, r) => Text('Ancho seguro: ${r.safeWidth}'),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveData responsive)
  builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => builder(context, context.responsive);
}

/// Selecciona un widget completo según el tamaño de ventana actual.
/// Si un tier no se define, cae al inmediato inferior (igual que
/// [ResponsiveData.pick]).
///
/// ```dart
/// ResponsiveLayout(
///   mobile: _MobileHome(),
///   tablet: _TabletHome(),
///   desktop: _DesktopHome(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return context.responsive.pick<Widget>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

// ════════════════════════════════════════════════════════════════
// 5. EXTENSIONES DE NÚMEROS
// ════════════════════════════════════════════════════════════════
extension ResponsiveNumExt on num {
  /// Ancho escalado, acotado a [minScaleFactor, maxScaleFactor].
  double get w => ResponsiveWrapper.instance.scaleWidth(toDouble());

  /// Alto escalado, acotado a [minScaleFactor, maxScaleFactor].
  double get h => ResponsiveWrapper.instance.scaleHeight(toDouble());

  /// Tamaño de fuente escalado con factor uniforme + accesibilidad, acotado.
  double get sp => ResponsiveWrapper.instance.scaleFont(toDouble());

  /// Tamaño proporcional (íconos, avatares, radios) con factor uniforme.
  double get size => ResponsiveWrapper.instance.scaleSize(toDouble());

  /// Interpola explícitamente este valor entre [min] y [max] según el
  /// ancho de pantalla actual, usando [ResponsiveConfig.rangeMinW],
  /// [ResponsiveConfig.rangeMaxW] y el ancho de referencia móvil como
  /// punto de quiebre. El resultado siempre queda dentro de [min, max].
  double range(double min, double max) {
    final w = ResponsiveWrapper.instance.width;
    final base = toDouble();

    const double minW = ResponsiveConfig.rangeMinW;
    const double maxW = ResponsiveConfig.rangeMaxW;
    final double refW = ResponsiveConfig.mobileRefW;

    if (w <= minW) return min;
    if (w >= maxW) return max;

    if (w <= refW) {
      final t = (w - minW) / (refW - minW);
      return min + (base - min) * t;
    } else {
      final t = (w - refW) / (maxW - refW);
      return base + (max - base) * t;
    }
  }

  double range2(double min, double max) {
    final w = ResponsiveWrapper.instance.width;
    final base = toDouble();

    const double minW = ResponsiveConfig.rangeMinW; // 360.0
    const double maxW = ResponsiveConfig.rangeMaxW; // 1920.0
    const double refW = ResponsiveConfig.mobileRefW; // 411.0 (pivote fijo)

    // 1. Límites absolutos
    if (w <= minW) return min;
    if (w >= maxW) return max;

    // 2. Interpolación en dos tramos con pivote fijo en 411px
    if (w <= refW) {
      // TRAMO 1: De 360px a 411px → de `min` a `base`
      final t = (w - minW) / (refW - minW);
      return min + (base - min) * t;
    } else {
      // TRAMO 2: De 411px a 1920px → de `base` a `max`
      final t = (w - refW) / (maxW - refW);
      return base + (max - base) * t;
    }
  }

  double range3(double min, double max) {
    final base = toDouble();
    final data = ResponsiveWrapper.instance;

    // 1. ✅ LA CLAVE: La referencia cambia según el dispositivo actual.
    // Si estamos en Desktop, usa 1440. Si es Tablet, 851. Si es Móvil, 411.
    final refW = data.isMobile
        ? ResponsiveConfig.mobileRefW
        : data.isTablet
        ? ResponsiveConfig.tabletRefW
        : ResponsiveConfig.desktopRefW;

    // 2. Escalar proporcionalmente desde la referencia natural del dispositivo
    final scaledValue = base * (data.width / refW);

    // 3. Aplicar los límites absolutos (piso y techo) de forma segura
    return scaledValue.clamp(min, max);
  }
}

// ════════════════════════════════════════════════════════════════
// 6. EXTENSIONES DE BUILDCONTEXT
// ════════════════════════════════════════════════════════════════
extension ResponsiveCtxExt on BuildContext {
  /// Forma preferida y segura de acceder a los datos responsivos.
  ResponsiveData get responsive => ResponsiveWrapper.of(this);

  bool get isMobile => responsive.isMobile;
  bool get isTablet => responsive.isTablet;
  bool get isDesktop => responsive.isDesktop;
  bool get isPortrait => responsive.isPortrait;
  bool get isLandscape => responsive.isLandscape;
  Orientation get orientation =>
      isPortrait ? Orientation.portrait : Orientation.landscape;

  /// Clasificación de tamaño de ventana (compact/medium/expanded/large/xl).
  WindowSizeClass get windowSizeClass => responsive.windowSizeClass;

  /// Ancho/alto disponibles descontando áreas seguras del dispositivo.
  double get safeWidth => responsive.safeWidth;
  double get safeHeight => responsive.safeHeight;

  T adaptive<T>({required T mobile, required T tablet, required T desktop}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  /// Igual que [adaptive] pero delegando en [ResponsiveData.pick], con un
  /// tier extra opcional para monitores muy grandes.
  T pickValue<T>({required T mobile, T? tablet, T? desktop, T? largeDesktop}) {
    return responsive.pick<T>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  bool get isFoldable => responsive.isFoldable;
  ({double left, double right})? get splitRegions => responsive.splitRegions;
}

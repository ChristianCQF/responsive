# Responsive Wrapper

Un sistema completo y profesional de diseño responsivo para Flutter. Adapta automáticamente tu UI a cualquier tamaño de pantalla (móvil, tablet, desktop, 4K) con una API simple y poderosa.

## ✨ Características

- 🎯 **5 breakpoints inteligentes**: Compact, Medium, Expanded, Large y Extra Large (basado en Material Design 3)
- 📐 **Extensiones intuitivas**: `.w`, `.h`, `.sp`, `.size`, `.range()` para escalado automático
- ️ **Límites de escala**: Previene overflow en pantallas extremas (0.75x - 1.6x)
- 📱 **Soporte foldables**: Detección de dispositivos plegables y split-screen
-  **Referencias múltiples**: Diferentes puntos de referencia según el tamaño de pantalla
-  **100% personalizable**: Configura breakpoints, referencias y límites de escala
-  **Alto rendimiento**: Sin rebuilds innecesarios, InheritedWidget optimizado
-  **Responsive real**: Mismo diseño proporcional en cualquier dispositivo

## 🚀 Getting started

### Instalación

Agrega esto a tu `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  responsive: ^1.0.0

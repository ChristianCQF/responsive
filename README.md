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

<table>
  <tr>
    <td align="center"><img src="https://via.placeholder.com/300x600/FF6B6B/FFFFFF?text=Sin+Plugin" alt="Sin Responsive Wrapper" width="250"/></td>
    <td align="center"><img src="https://via.placeholder.com/300x600/4ECDC4/FFFFFF?text=Con+Plugin" alt="Con Responsive Wrapper" width="250"/></td>
  </tr>
  <tr>
    <td align="center"><strong>Sin Responsive Wrapper</strong><br/>Layout roto en diferentes dispositivos</td>
    <td align="center"><strong>Con Responsive Wrapper</strong><br/>UI perfecta en cualquier pantalla</td>
  </tr>
</table>

## 🚀 Getting started

### Instalación

Agrega esto a tu `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  responsive: ^1.0.0

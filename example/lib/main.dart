import 'package:flutter/material.dart';
import 'package:responsive/responsive.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Activa que .sp y los Text del árbol respeten (de forma acotada)
  // el tamaño de letra del sistema operativo.

  runApp(ResponsiveWrapper(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Material App', home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScalerOf(context);
    print(textScaleFactor);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenidos', style: TextStyle(fontSize: 14)),
            Text('Bienvenidos', style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}

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
    final textScaleFactor = MediaQuery.of(context).size.width;
    String screenState = context.isMobile
        ? 'MOBILE'
        : context.isTablet
        ? 'TABLET'
        : 'DESKTOP';
    print(textScaleFactor);
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                screenState,
                style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.bold),
              ),
              Text('Bienvenidos', style: TextStyle(fontSize: 14.sp)),

              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 50.h,
                  horizontal: context.adaptive(
                    mobile: 20.adaptiveMobile(15, 25),
                    tablet: 45.adaptiveTablet(30, 50),
                    desktop: 150.adaptiveDesktop(80, 800),
                  ),
                ),
                height: 200.h,
                //width: 350.w,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20.size),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 50.h,
                  horizontal: 150.adaptiveDesktop(80, 800),
                ),
                height: 200.h,
                //width: 350.w,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20.size),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

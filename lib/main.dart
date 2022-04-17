import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sharewallpaper/pages/home.dart';
import 'package:sharewallpaper/pages/profile.dart';
import 'package:sharewallpaper/pages/upload.dart';
import 'package:sharewallpaper/util/SizeConfig.dart';
import 'firebase_options.dart';

Widget myApp() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const HomePage(),
      '/upload': (context) => const UploadPage(),
      '/profile': (context) => const ProfilePage(),
    },
    builder: EasyLoading.init(),
  );
}

Widget Loading() {
  return const Center(
    child: Text('Loading', textDirection: TextDirection.ltr),
  );
}

Widget SomethingWentWrong() {
  return const Center(
    child: Text("SomethingWentWrong", textDirection: TextDirection.ltr),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeConfig().init(constraints, orientation);
            WidgetsFlutterBinding.ensureInitialized();
            return FutureBuilder(
              future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform),
              builder: (context, snapshot) {
                // Check for errors
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return SomethingWentWrong();
                }

                // Once complete, show your application
                if (snapshot.connectionState == ConnectionState.done) {
                  return myApp();
                }

                // Otherwise, show something whilst waiting for initialization to complete
                return Loading();
              },
            );
          },
        );
      },
    ),
  );
}

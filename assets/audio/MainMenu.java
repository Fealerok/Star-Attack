import 'package:flutter/material.dart';

import '../main.dart';
import 'settings_menu.dart';
import 'select_spaceship.dart';

import 'package:provider/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nasaData = Provider.of<NasaDataProvider>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: Text(
                'star attak',
                style: TextStyle(
                  fontSize: 50.0,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: Colors.white,
                      offset: Offset(0, 0),
                    )
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: FutureBuilder(
              future: Future.delayed(Duration(seconds: 2)), // Пример асинхронного ожидания
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Показать индикатор загрузки
                } else if (snapshot.hasError) {
                  return Text("Ошибка при загрузке данных");
                } else {
                  return Image.asset(
                    'images/nasa.png',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.width / 3,
                  );
                }
              },
            ),),

            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                onPressed: () {
                  // Push and replace current screen (i.e MainMenu) with
                  // SelectSpaceship(), so that player can select a spaceship.
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SelectSpaceship(),
                    ),
                  );
                },
                child: const Text('Play'),
              ),
            ),

            // Settings button.
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsMenu(),
                    ),
                  );
                },
                child: const Text('Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

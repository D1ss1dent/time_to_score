import 'package:flutter/material.dart';
import 'package:time_to_score/menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    home: MenuScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

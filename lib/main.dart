import 'package:attendence/homescreen.dart';
import 'package:attendence/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'model/user.dart';

Future<void> main() async{
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendence',
      theme: ThemeData(
        primarySwatch: Colors.blue,

      ),
      home: const KeyboardVisibilityProvider(child: AuthCheck(),),
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],
    );
  }
}
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool userAvailable = false;
  late SharedPreferences sharedPreferences;
  void initState(){
    super.initState();
    _getCurrentUser();
  }
  void _getCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    try{
      if(sharedPreferences.getString('employeeId') !=null){
        setState(() {
          User.EmployeeId = sharedPreferences.getString("employeeId")!;
          userAvailable = true;
        });
      }
    } catch(e){
      setState(() {
        userAvailable = false;
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return userAvailable ? const HomeScreen(): LoginScreen();
  }
}




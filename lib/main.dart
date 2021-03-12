import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';

import 'dashboard.dart';
import 'login.dart';
import 'views/slider_showcase.dart';

const colorButton = const Color(0xff676767);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shu Guo Yin Xiang',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(title: 'Shu Guo Yin Xiang'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _getPref();
  }

  _getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var _checkIsFirst = preferences.getString("isFirst");
    if (_checkIsFirst == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SliderShowcase()));
      _savePrefIsFirstLaunching("1");
    } else {
      _checkSession();
//      Navigator.pushReplacement(
//          context,
//          MaterialPageRoute(
//              builder: (context) => LoginPage()));
    }
  }

  _checkSession() async {
    CheckSessionAPI _checkSession = CheckSessionAPI();
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    int _memberId = _preferences.getInt("idMember");
    String _codeToken = _preferences.getString("token");
    if (_memberId != null && _codeToken != null) {
      var _result = await _checkSession.checkSession(_memberId, _codeToken);
      if (_result['status']) {
        Navigator.pushReplacement(
            context, SlideRightRoute(page: DashBoard(isRegister: false)));
      } else {
        Navigator.pushReplacement(context, SlideRightRoute(page: LoginPage()));
      }
    } else {
      Navigator.pushReplacement(context, SlideRightRoute(page: LoginPage()));
    }
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }

  _savePrefIsFirstLaunching(String isFirstLaunch) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    _preferences.setString("isFirst", isFirstLaunch);
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

import 'dashboard.dart';
import 'main.dart';
import 'register.dart';
import 'resource/check_session_api_provider.dart';
import 'views/forgot_password.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _key = new GlobalKey<FormState>();
  String email,password;
  bool _secureText = true;
  var _autoValidate = false;
  var _loginProcess = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _txtEditControllerEmail = TextEditingController();
  final _txtEditControllerPassword = TextEditingController();

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      _login();
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  _login() async{
    setState(() {
      _loginProcess = true;
    });

    var _envelope =
    '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
    <CekLogin xmlns="http://tempuri.org/">
      <email>$email</email>
      <pass>$password</pass>
    </CekLogin>
  </soap:Body>
  </soap:Envelope>''';

    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/CekLogin",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);

      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _resultLogin = parsedXml.findAllElements('string');
      var mapResultLogin = _resultLogin.map((node) => node.text).toList();
      if(mapResultLogin[0]== "Berhasil"){
        _savePrefEmailAndToken(_txtEditControllerEmail.text,mapResultLogin[1]);
        setState(() {
          _loginProcess = false;
        });
      }
      else if(mapResultLogin[0] == "Email dan pass salah"){
        _showSnackBar("Incorrect email or password");
        setState(() {
          _loginProcess = false;
        });
      }
      else{
        _showSnackBar("Login Failed");
        setState(() {
          _loginProcess = false;
        });
      }
    }
    catch(e){
      _showSnackBar(e.toString());
      setState(() {
        _loginProcess = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  _checkSession() async{
    CheckSessionAPI _checkSession = CheckSessionAPI();
    setState(() {
      _loginProcess = true;
    });
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    int _memberId = _preferences.getInt("idMember");
    String _codeToken = _preferences.getString("token");
    if(_memberId != null && _codeToken != null){
      var _result = await _checkSession.checkSession(_memberId, _codeToken);
      if(_result['status']){
        setState(() {
          _loginProcess = false;
        });
        Navigator.pushReplacement(
            context, SlideRightRoute(page: DashBoard(isRegister: false)));
      }
      else{
        setState(() {
          _loginProcess = false;
        });
        _showSnackBar(_result['message']);
      }
    }
    else{
      setState(() {
        _loginProcess = false;
      });
      return;
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  _savePrefEmailAndToken(String email,String token) async{
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    _preferences.setString("email", email);
    _preferences.setString("token", token);
    Navigator.pushReplacement(context, SlideRightRoute(page: DashBoard(isRegister: false)));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(primaryColor: Colors.white,accentColor: Colors.white),
      child: Scaffold(
        key: _scaffoldKey,
        body: Form(
          key: _key,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("img/Login.webp"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                    child: Image.asset('img/logo_shu_guo_white.webp'),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        TextFormField(
                          controller: _txtEditControllerEmail,
                          style: new TextStyle(color: Color(0xffeab981)),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(fontFamily: "Kano",color: Color(0xffeab981)),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffeab981)),
                            ) ,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffeab981)),
                              //  when the TextFormField in focused
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autovalidate: _autoValidate,
                          validator: _validateEmail,
                          onSaved: (e) => email = e,
                        ),
                        TextFormField(
                          controller: _txtEditControllerPassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(fontFamily: "Kano",color: Color(0xffeab981)),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffeab981)),
                              //  when the TextFormField in unfocused
                            ) ,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffeab981)),
                              //  when the TextFormField in focused
                            ),
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    _secureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Color(0xffeab981),
                                  ),
                                  onPressed: _showHidePass)
                          ),
                          style: new TextStyle(color: Color(0xffeab981)),
                          autovalidate: _autoValidate,
                          validator: _validatePassword,
                          obscureText: _secureText,
                          onSaved: (e) => password = e,
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 8),
                            child: InkWell(
                              onTap: (){
                                Navigator.push(
                                    context, SlideRightRoute(page: ForgotPassword()));
                              },
                              child: Text('Forgot Password?',
                                  style: TextStyle(fontFamily: "Kano",color: Color(0xffeab981))
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 32,left: 32,right: 32),
                    child: Center(
                      child:
                      _loginProcess
                          ?
                      CircularProgressIndicator()
                          :
                      RaisedButton(
                        onPressed: (){
                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          check();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                'Sign In',
                                style: TextStyle(fontFamily:'Kano',color: Colors.white)
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        color: colorButton,
                        padding: EdgeInsets.only(top: 12,bottom: 12),
                      ),
                    ),
                  ),
                  Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Don't you have account?",
                              style: TextStyle(fontFamily: "Kano",color: Color(0xffeab981))),
                          SizedBox(
                            width: 3,
                          ),
                          InkWell(
                            child: Text('Sign Up',
                                style: TextStyle(fontFamily: "Kano",color: Color(0xffeab981))),
                            onTap: () {
                              Navigator.push(
                                  context, SlideRightRoute(page: RegisterPage()));
                            },
                          )
                        ],
                      )
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      // The form is empty
      return "Enter email address";
    }
    // This is just a regular expression for email addresses
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      // So, the email is valid
      return null;
    }
    // The pattern of the email didn't match the regex above.
    return 'Email is not valid';
  }

  String _validatePassword(String value) {
    if (value.length < 7) {
      password = value;
      return 'Password must be upto 8 characters';
    } else {
      password = value;
      return null;
    }
  }

  _showHidePass() {
    setState(() {
      _secureText = !_secureText;
    });
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightRoute({this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
  );
}

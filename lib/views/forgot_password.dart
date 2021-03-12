import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

import '../main.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  var email;
  var _autoValidate = false;
  final _key = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _processReset = false;
  final _forgotControllerForm = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Forgot Password",style: TextStyle(fontFamily: "OpenSans",color: Colors.black)),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 8,left: 16,right: 16),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 8),
                child: Text("Insert your email",style: TextStyle(fontFamily: "OpenSans",color: Colors.black)),
              ),
              SizedBox(height: 16),
              Container(
                child: TextFormField(
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (e)=>email = e,
                  validator: _validateEmail,
                  autovalidate: _autoValidate,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  controller: _forgotControllerForm,
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: _processReset ? CircularProgressIndicator() :RaisedButton(
                  onPressed: (){
                    check();
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 32,right: 32),
                    child: Text(
                        'Reset Password',
                        style: TextStyle(fontFamily:'OpenSans',color: Colors.white)
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  color: colorButton,
                  padding: EdgeInsets.only(top: 12,bottom: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _resetEmail() async{
    setState(() {
      _processReset = true;
    });

    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <ForgetPassword xmlns="http://tempuri.org/">
      <email>$email</email>
    </ForgetPassword>
  </soap:Body>
</soap:Envelope>''';

    try{
      http.Response _response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/ForgetPassword",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);

      var rawXmlResponse = _response.body;
      var parsedXml = xml.parse(rawXmlResponse);
      var _resultReset = parsedXml.findAllElements('ForgetPasswordResult');
      var mapResultLogin = _resultReset.map((node) => node.text).toList();
      _showSnackBar(mapResultLogin[0]);
      setState(() {
        _processReset = false;
      });
      if(mapResultLogin[0] == "Password anda telah berhasil di reset,mohon cek email anda"){
        _forgotControllerForm.clear();
      }
    }catch(e){
      setState(() {
        _processReset = false;
      });
      _showSnackBar("Failed because ${e.toString()}");
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      _resetEmail();
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
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
}

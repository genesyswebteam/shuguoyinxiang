import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuguoyinxiang/gender_model.dart';
import 'package:shuguoyinxiang/resource/check_exist_email_api_provider.dart';
import 'package:shuguoyinxiang/views/how_to_use.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

import 'dashboard.dart';
import 'views/slider_showcase.dart';

const colorBlueDark = const Color(0xff162633);

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  File imageFile;
  int radioValue = 1;
  var dateSelected, monthSelected, yearSelected;
  var _autoValidate = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _key = new GlobalKey<FormState>();
  var fullName, password, email, phone, address;
  var cekBulan;
  var bulan;
  var regProcess = false;
  bool _secureText = true;
  bool _secureTextConfirmPass = true;

  final txtEditControllerFullName = TextEditingController();
  final txtEditControllerEmail = TextEditingController();
  final txtEditControllerAddress = TextEditingController();
  final txtEditControllerPhoneNumber = TextEditingController();
  final txtEditControllerPassword = TextEditingController();
  final txtEditControllerConfirmPass = TextEditingController();
  final _focusEmail = FocusNode();
  final _focusName = FocusNode();
  final _focusPassword = FocusNode();
  final _focusConfirmPassword = FocusNode();
  final _controllerCountryCode = TextEditingController();
  final _focusNodeAddress = FocusNode();
  List<Gender> _genderList = [];
  Gender _genderSelected;
  String _phone;
  bool sudahDicek = false;

  check() {
    final form = _key.currentState;
    setState(() {
      sudahDicek = false;
    });
    if (form.validate()) {
      if(_genderSelected == null || yearSelected == null || monthSelected == null || dateSelected == null
          || txtEditControllerAddress.text == "" || txtEditControllerPhoneNumber.text == "" || _controllerCountryCode.text == ""){
        _showUnCompleteDataDialog();
        _checkAddress();
        _checkGender();
        _checkBirthDate();
        _checkPhone();
      }
      else{
        print("masuk sini");
        _checkIsExistEmailAndHP();
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  _showUnCompleteDataDialog(){
    showDialog(
        context: context,
      barrierDismissible: false,
      builder: (context) {
        return Theme(
          data: ThemeData(
            fontFamily: "Kano",
          ),
          child: AlertDialog(
            title: Text("Complete Data Warning!"),
            content: Text("Just a few empty fields more to fill for you to get your 5 Welcoming Points worth for IDR 500,000!"),
            actions: <Widget>[
              FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("CANCEL",style: TextStyle(color: Colors.black),)
              ),
              FlatButton(
                  onPressed: (){
                    _checkIsExistEmailAndHP();
                    Navigator.pop(context);
                  },
                  child: Text("CONTINUE",style: TextStyle(color: Colors.black),)
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: Text(text, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating));
  }

  void handleRadioValueChange(int value) {
    setState(() {
      radioValue = value;
    });
  }

  List<String> dateKu = [];
  List<String> month = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  List<String> years = [];
  List<String> monthBeforeSelectedYear = [];
  List<String> dayBeforeSelected = [];

  addYear() {
    for (var i = 1945; i < 2019; i++) {
      years.add(i.toString());
    }
  }

  cekDate() {
    var tahun = int.parse(yearSelected);

    if (monthSelected == "January") {
      cekBulan = 2;
      bulan = 1;
    } else if (monthSelected == "February") {
      cekBulan = 3;
      bulan = 2;
    } else if (monthSelected == "March") {
      cekBulan = 4;
      bulan = 3;
    } else if (monthSelected == "April") {
      cekBulan = 5;
      bulan = 4;
    } else if (monthSelected == "May") {
      cekBulan = 6;
      bulan = 5;
    } else if (monthSelected == "June") {
      cekBulan = 7;
      bulan = 6;
    } else if (monthSelected == "July") {
      cekBulan = 8;
      bulan = 7;
    } else if (monthSelected == "August") {
      cekBulan = 9;
      bulan = 8;
    } else if (monthSelected == "September") {
      cekBulan = 10;
      bulan = 9;
    } else if (monthSelected == "October") {
      cekBulan = 11;
      bulan = 10;
    } else if (monthSelected == "November") {
      cekBulan = 12;
      bulan = 11;
    } else if (monthSelected == "December") {
      cekBulan = 1;
      bulan = 12;
    }
    var date = new DateTime(tahun, cekBulan, 0);

    setState(() {
      dateKu.clear();
    });
    for (var i = 1; i <= date.day; i++) {
      dateKu.add(i.toString());
    }
    dateSelected = "1";
  }

  _checkIsExistEmailAndHP() async {
    setState(() {
      regProcess = true;
    });
    try {
      var _rnd = Random();
      if(_controllerCountryCode.text == "" || txtEditControllerPhoneNumber.text == ""){
        _phone = _rnd.nextInt(1000000000).toString();
      }
      else{
        _phone = "${_controllerCountryCode.text}${txtEditControllerPhoneNumber.text}";
      }
      CheckExistEmailAPI _checkExistEmail = CheckExistEmailAPI();
      var _result = await _checkExistEmail.checkExistEmailInRegister(
          txtEditControllerEmail.text,_phone);
      if (_result) {
        register();
      } else {
        setState(() {
          regProcess = false;
        });
        _showSnackBar("Email or handphone already exist");
      }
    } catch (e) {
      setState(() {
        regProcess = false;
      });
      _showSnackBar(e.toString());
    }
  }

  register() async {
    String tahunSelected = "";
    var daySelected = 0;
    var parsedDate;
    var envelope;
    String formatTanggal = "";
    String formatBulan = "";
    String _birthDate = "";
    if(yearSelected != null && bulan != null && daySelected != null) {
      tahunSelected = yearSelected.toString();
      daySelected = int.parse(dateSelected);
      parsedDate = DateTime(int.parse(yearSelected), bulan, daySelected);
      if (parsedDate.day.toString().length < 2 &&
          parsedDate.month.toString().length < 2) {
        formatTanggal = "0${parsedDate.day}";
        formatBulan = "0${parsedDate.month}";
      } else if (parsedDate.day.toString().length < 2) {
        formatTanggal = "0${parsedDate.day}";
        formatBulan = "${parsedDate.month}";
      } else if (parsedDate.month.toString().length < 2) {
        formatTanggal = "${parsedDate.day}";
        formatBulan = "0${parsedDate.month}";
      } else {
        formatTanggal = "${parsedDate.day}";
        formatBulan = "${parsedDate.month}";
      }

      _birthDate = "$tahunSelected-$formatBulan-$formatTanggal";
    }
    else{
      DateFormat _dateFormat = DateFormat("yyyy-MM-dd");
      _birthDate = _dateFormat.format(DateTime.now());
    }

    int _gender;

    if(_genderSelected == null){
      _gender = 4;
    }
    else{
      _gender = _genderSelected.id;
    }

    if (imageFile != null) {
      List<int> imageBytes = imageFile.readAsBytesSync();
      String base64Image = base64.encode(imageBytes);
      envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <insertMembershipcard xmlns="http://tempuri.org/">
      <membershipcard>
        <MemberName>${txtEditControllerFullName.text}</MemberName>
        <MemberCard></MemberCard>
        <Password>${txtEditControllerPassword.text}</Password>
        <Gender>$_gender</Gender>
        <BirthDay>$_birthDate</BirthDay>
        <HandPhone>$_phone</HandPhone>
        <Email>${txtEditControllerEmail.text}</Email>
        <Points>0</Points>
        <Address>${txtEditControllerAddress.text}</Address>
        <PictureFile></PictureFile>
      </membershipcard>
      <byteArrayIn>$base64Image</byteArrayIn>
    </insertMembershipcard>
  </soap:Body>
</soap:Envelope>''';
    }
    else {
      envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <insertMembershipcard xmlns="http://tempuri.org/">
      <membershipcard>
        <MemberName>${txtEditControllerFullName.text}</MemberName>
        <MemberCard></MemberCard>
        <Password>${txtEditControllerPassword.text}</Password>
        <Gender>$_gender</Gender>
        <BirthDay>$_birthDate</BirthDay>
        <HandPhone>$_phone</HandPhone>
        <Email>${txtEditControllerEmail.text}</Email>
        <Points>0</Points>
        <Address>${txtEditControllerAddress.text}</Address>
        <PictureFile></PictureFile>
      </membershipcard>
      <byteArrayIn></byteArrayIn>
    </insertMembershipcard>
  </soap:Body>
</soap:Envelope>''';
    }

    print(envelope);
    try {
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/insertMembershipcard",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: utf8.encode(envelope));
      var rawXmlResponse = response.body;

      print(response.statusCode);
      if (response.statusCode == 200) {
        var parsedXml = xml.parse(rawXmlResponse);
        var result = parsedXml.findAllElements('insertMembershipcardResult');
        var mapResult = result.map((node) => node.text).toList();
        print(mapResult);
        if (mapResult[0] == "Data Berhasil Masuk") {
          _savePref(txtEditControllerEmail.text);
          setState(() {
            regProcess = false;
          });
        }
      } else {
        setState(() {
          regProcess = false;
        });
        _showSnackBar("Failed register");
      }
    } catch (e) {
      setState(() {
        regProcess = false;
      });
      _showSnackBar("Failed ${e.toString()}");
    }

//    }
  }

  @override
  void initState() {
    super.initState();
    addYear();
    _genderList.add(Gender(1, "Male"));
    _genderList.add(Gender(2, "Female"));
    _genderList.add(Gender(3, "Rather not say"));
  }

  _savePref(String email) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("email", email);

    var _checkIsFirst = preferences.getString("isFirstHowTouse");
    if (_checkIsFirst == null) {
      preferences.setString("isFirstHowTouse", "1");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HowToUse(isFromRegister: true)),
              (Route<dynamic> route) => false);
    }
    else{
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => DashBoard(
                isRegister: true,
              )),
              (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Create Account',
            style: TextStyle(fontFamily: 'Kano', color: colorBlueDark)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorBlueDark),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("img/Login.webp"),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _key,
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Text('Please fill in a few details below',
                    style: TextStyle(
                        fontFamily: 'Kano',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xffeab981))),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if(Platform.isIOS){
                          _chooseActionSheet(context);
                        }
                        else{
                          _settingModalBottomSheet(context);
                        }
                      },
                      child: Container(
                        height: 75,
                        width: 75,
                        decoration: new BoxDecoration(
                          image: DecorationImage(
                            image: imageFile == null
                                ? AssetImage('img/akun_user_white.webp')
                                : FileImage(imageFile),
                            fit: BoxFit.cover,
                          ),
                          borderRadius:
                          new BorderRadius.all(new Radius.circular(50.0)),
                          border: new Border.all(
                            color: Color(0xffeab981),
                            width: 3.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Full Name',
                        style: TextStyle(
                            fontFamily: 'Kano', color: Color(0xffeab981))),
                    TextFormField(
                      style: new TextStyle(color: Color(0xffeab981)),
                      controller: txtEditControllerFullName,
                      onSaved: (e) => fullName = e,
                      autovalidate: _autoValidate,
                      validator: (value){
                        var _val = value.trim().isEmpty ? "Can't be empty" : null;
                        if(_val != null && sudahDicek == false){
                          FocusScope.of(context).requestFocus(_focusName);
                          setState(() {
                            sudahDicek = true;
                          });
                        }
                        if (value.isEmpty) {
                          return "Can't be empty";
                        }
                        else {
                          return null;
                        }
                      },
                      textCapitalization: TextCapitalization.sentences,
                      onTap: (){
                        _checkData();
                      },
                      focusNode: _focusName,
                      decoration: InputDecoration(
                        hintText: 'e.g Name',
                        hintStyle: TextStyle(
                            fontFamily: 'Kano', color: Color(0xffeab981)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffeab981)),
                          //  when the TextFormField in unfocused
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffeab981)),
                          //  when the TextFormField in focused
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Email',
                        style: TextStyle(
                            fontFamily: 'Kano', color: Color(0xffeab981))),
                    TextFormField(
                      focusNode: _focusEmail,
                      style: new TextStyle(color: Color(0xffeab981)),
                      controller: txtEditControllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value){
                        var _val = value.trim().isEmpty ? "Can't be empty" : null;
                        if(_val != null && sudahDicek == false){
                          FocusScope.of(context).requestFocus(_focusEmail);
                          setState(() {
                            sudahDicek = true;
                          });
                        }
                        if (value.isEmpty) {
                          return "Can't be empty";
                        }
                        else {
                          return null;
                        }
                      },
                      autovalidate: _autoValidate,
                      decoration: InputDecoration(
                        hintText: 'e.g name@email.com',
                        hintStyle: TextStyle(
                            fontFamily: 'Kano', color: Color(0xffeab981)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffeab981)),
                          //  when the TextFormField in unfocused
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffeab981)),
                          //  when the TextFormField in focused
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Password',
                        style: TextStyle(
                            fontFamily: 'Kano', color: Color(0xffeab981))),
                    TextFormField(
                      focusNode: _focusPassword,
                      style: new TextStyle(color: Color(0xffeab981)),
                      controller: txtEditControllerPassword,
                      autovalidate: _autoValidate,
                      validator: (value){
                        var _val = value.trim().isEmpty ? "Can't be empty" : value.length < 7 ?  "Password must be upto 8 characters" : null;
                        if(_val != null && sudahDicek == false){
                          FocusScope.of(context).requestFocus(_focusPassword);
                          setState(() {
                            sudahDicek = true;
                          });
                        }
                        if (value.isEmpty) {
                          return "Can't be empty";
                        }
                        else if(value.length < 7){
                          return "Password must be upto 8 characters";
                        }
                        else {
                          return null;
                        }
                      },
                      onSaved: (e) => password = e,
                      obscureText: _secureText,
                      decoration: InputDecoration(
                        hintText: 'enter password',
                        hintStyle: TextStyle(
                            fontFamily: 'Kano', color: Color(0xffeab981)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffeab981)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffeab981)),
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
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      focusNode: _focusConfirmPassword,
                      style: new TextStyle(color: Color(0xffeab981)),
                      controller: txtEditControllerConfirmPass,
                      validator: (value){
                        var _val = value.trim().isEmpty ? "Can't be empty" : value != txtEditControllerPassword.text ? "Password not match" : null;
                        if(_val != null && sudahDicek == false){
                          FocusScope.of(context).requestFocus(_focusConfirmPassword);
                          setState(() {
                            sudahDicek = true;
                          });
                        }
                        if (value.isEmpty) {
                          return "Can't be empty";
                        }
                        if (value != txtEditControllerPassword.text) {
                          return "Password not match";
                        } else {
                          return null;
                        }
                      },//_validateConfirmPass,
                      autovalidate: _autoValidate,
                      obscureText: _secureTextConfirmPass,
                      decoration: InputDecoration(
                        hintText: 're-enter password',
                        hintStyle: TextStyle(
                            fontFamily: 'Kano', color: Color(0xffeab981)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffeab981)),
                          //  when the TextFormField in unfocused
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffeab981)),
                          //  when the TextFormField in focused
                        ),
                          suffixIcon: IconButton(
                              icon: Icon(
                                _secureTextConfirmPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Color(0xffeab981),
                              ),
                              onPressed: _showHidePassConfirmPassword)
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Address (Optional)',
                        style: TextStyle(
                            fontFamily: 'Kano', color: Color(0xffeab981))),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      focusNode: _focusNodeAddress,
                      style: new TextStyle(color: Color(0xffeab981)),
                      controller: txtEditControllerAddress,
                      // autovalidate: _autoValidate,
                      // validator: validateAddress,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Color(0xffeab981))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Color(0xffeab981))),
                      ),
                      maxLines: 3,
                      onChanged: (e){
                        _checkAddress();
                      },
                    ),
                  ],
                ),
              ),
              _showMessageEmptyAddress
                  ?
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Text("* Upss you will miss our welcoming 5 points worth IDR 500K",
                      style: TextStyle(color: Colors.red,fontSize: 12)
                  )
              )
                  :
              SizedBox(),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Gender (Optional)',
                    style: TextStyle(
                        fontFamily: 'Kano', color: Color(0xffeab981))),
              ),
              // Container(
              //   margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: <Widget>[
              //       Text('Gender',
              //           style: TextStyle(
              //               fontFamily: 'Kano', color: Color(0xffeab981))),
              //       Theme(
              //         data: ThemeData(unselectedWidgetColor: Color(0xffeab981)),
              //         child: Row(
              //           children: <Widget>[
              //             Row(
              //               children: <Widget>[
              //                 Radio<int>(
              //                   value: 1,
              //                   groupValue: radioValue,
              //                   onChanged: handleRadioValueChange,
              //                   activeColor: Color(0xffeab981),
              //                 ),
              //                 SizedBox(width: 4),
              //                 Text(
              //                   "Male",
              //                   style: TextStyle(
              //                       fontFamily: 'Kano',
              //                       color: Color(0xffeab981)),
              //                 )
              //               ],
              //             ),
              //             Row(
              //               children: <Widget>[
              //                 Radio<int>(
              //                     value: 2,
              //                     groupValue: radioValue,
              //                     onChanged: handleRadioValueChange,
              //                     activeColor: Color(0xffeab981)),
              //                 SizedBox(width: 4),
              //                 Text("Female",
              //                     style: TextStyle(
              //                         fontFamily: 'Kano',
              //                         color: Color(0xffeab981)))
              //               ],
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: DropdownButtonFormField<Gender>(
                  style: new TextStyle(color: Color(0xffeab981)),
                  value: _genderSelected,
                  onTap: (){
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _checkAddress();
                  },
                  onChanged: (newVal) {
                    setState(() {
                      _genderSelected = newVal;
                    });
                    _checkGender();
                  },
                  // validator: validateYear,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                          BorderSide(color: Color(0xffeab981))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                          BorderSide(color: Color(0xffeab981))),
                      hintText: 'Gender',
                      hintStyle: TextStyle(
                          fontFamily: 'Kano',
                          color: Color(0xffeab981)),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 1.0, horizontal: 10),
                  ),
                  items: _genderList
                      .map((value) {
                    return DropdownMenuItem<Gender>(
                      value: value,
                      child: Text(
                        value.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
              _showMessageEmptyGender
                  ?
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Text("* Upss you will miss our welcoming 5 points worth IDR 500K",
                      style: TextStyle(color: Colors.red,fontSize: 12)
                  )
              )
                  :
              SizedBox(),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Date of Birth (Optional)',
                        style: TextStyle(
                            fontFamily: 'Kano', color: Color(0xffeab981))),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            style: new TextStyle(color: Color(0xffeab981)),
                            value: yearSelected,
                            onChanged: (String newVal) {
                              setState(() {
                                yearSelected = newVal;
                              });
                              _checkBirthDate();
                            },
                            onTap: (){
                              FocusScope.of(context).requestFocus(new FocusNode());
                              _checkAddress();
                              _checkGender();
                            },
                            // validator: validateYear,
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                    BorderSide(color: Color(0xffeab981))),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                    BorderSide(color: Color(0xffeab981))),
                                hintText: 'Year',
                                hintStyle: TextStyle(
                                    fontFamily: 'Kano',
                                    color: Color(0xffeab981)),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 1.0, horizontal: 10),
                            ),
                            items: years
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                          flex: 2,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            style: new TextStyle(color: Color(0xffeab981)),
                            value: monthSelected,
                            onChanged: (String newVal) {
                              setState(() {
                                monthSelected = newVal;
                              });
//                              FocusManager.instance.primaryFocus.unfocus();
                              cekDate();
                              _checkBirthDate();
                            },
                            onTap: (){
                              FocusScope.of(context).requestFocus(new FocusNode());
                              _checkAddress();
                              _checkGender();
                            },
                            // validator: validateMonth,
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                    BorderSide(color: Color(0xffeab981))),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                    BorderSide(color: Color(0xffeab981))),
                                hintText: 'Month',
                                hintStyle: TextStyle(
                                    fontFamily: 'Kano',
                                    color: Color(0xffeab981)),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 1.0, horizontal: 10)),
                            items: yearSelected == null
                                ? monthBeforeSelectedYear
                                .map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList()
                                : month.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                          ),
                          flex: 3,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            child: DropdownButtonFormField<String>(
                              style: new TextStyle(color: Color(0xffeab981)),
                              value: dateSelected,
                              onChanged: (String newVal) {
                                setState(() {
                                  dateSelected = newVal;
                                });
                                _checkData();
                                _checkBirthDate();
                              },
                              onTap: (){
                                FocusScope.of(context).requestFocus(new FocusNode());
                                _checkAddress();
                                _checkGender();
                              },
                              // validator: validateDay,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide:
                                      BorderSide(color: Color(0xffeab981))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide:
                                      BorderSide(color: Color(0xffeab981))),
                                  hintText: 'Day',
                                  hintStyle: TextStyle(
                                      fontFamily: 'Kano',
                                      color: Color(0xffeab981)),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 1.0, horizontal: 10)),
                              items: dateKu.isEmpty
                                  ? dayBeforeSelected
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList()
                                  : dateKu.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                          flex: 2,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: _showMessageEmptyDateOfBirth
                      ?
                  Text("* Upss you will miss our double points on your birthday week",style: TextStyle(color: Colors.red,fontSize: 12))
                      :
                  SizedBox(width: 0.0,height: 0.0,)
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Mobile Phone Number (Optional)',
                        style: TextStyle(
                            fontFamily: 'Kano', color: Color(0xffeab981))),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            style: new TextStyle(color: Color(0xffeab981)),
                            controller: _controllerCountryCode,
                            onTap: (){
                              _checkAddress();
                              _checkGender();
                              _checkBirthDate();
                            },
                            onChanged: (e){
                             _checkPhone();
                            },
                            // validator: (e) {
                            //   if (e.isEmpty) {
                            //     return "Can't be empty";
                            //   } else {
                            //     return null;
                            //   }
                            // },
                            // autovalidate: _autoValidate,
                            decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    fontFamily: 'Kano',
                                    color: Color(0xffeab981)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Color(0xffeab981)),
                                  //  when the TextFormField in unfocused
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Color(0xffeab981))
                                ),
                                labelText: "Country Code",
                                labelStyle: TextStyle(color: Color(0xffeab981)),
                                prefixText: "+",
                                prefixStyle: TextStyle(color: Color(0xffeab981))
//                                disabledBorder: OutlineInputBorder(
//                                    borderRadius: BorderRadius.circular(8.0),
//                                    borderSide:
//                                        BorderSide(color: Color(0xffeab981))),
//                                prefixIcon: Container(
//                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.center,
//                                    children: <Widget>[
//                                      Image.asset('img/indonesia.png'),
//                                      SizedBox(width: 4),
//                                      Text('+62',
//                                          style: TextStyle(
//                                              fontFamily: 'Kano',
//                                              color: Color(0xffeab981)))
//                                    ],
//                                  ),
//                                ),
//                                contentPadding: EdgeInsets.symmetric(
//                                    horizontal: 10, vertical: 8
//                                )
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          flex: 4,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            style: new TextStyle(color: Color(0xffeab981)),
                            controller: txtEditControllerPhoneNumber,
                            // validator: validatePhone,
                            // autovalidate: _autoValidate,
                            onTap: (){
                              _checkAddress();
                              _checkGender();
                              _checkBirthDate();
                            },
                            onChanged: (e){
                              _checkPhone();
                            },
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              WhitelistingTextInputFormatter(RegExp(r"^[1-9][0-9]*$"))
                            ],
                            decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    fontFamily: 'Kano',
                                    color: Color(0xffeab981)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Color(0xffeab981)),
                                  //  when the TextFormField in unfocused
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Color(0xffeab981)),
                                  //  when the TextFormField in focused
                                ),
                                labelText: "Phone Number",
                                labelStyle: TextStyle(
                                  color: Color(0xffeab981),
                                )),
                          ),
                          flex: 6,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _showMessageEmptyPhone
                  ?
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Text("* Upss you will miss our welcoming 5 points worth IDR 500K",
                      style: TextStyle(color: Colors.red,fontSize: 12)
                  )
              )
                  :
              SizedBox(),
              regProcess
                  ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                        valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.white70)),
                  ))
                  : Container(
                margin:
                EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: RaisedButton(
                  onPressed: () {
                    check();
                  },
                  child: Text('Continue',
                      style: TextStyle(
                          fontFamily: "Kano", color: Colors.black)),
                  color: Color(0xffeab981),
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      _focusEmail.requestFocus();
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
    else{
      _focusEmail.requestFocus();
    }
    // The pattern of the email didn't match the regex above.
    return 'Email is not valid';
  }

  String _validatePassword(String value) {
    if (value.isEmpty) {
      _focusPassword.requestFocus();
      // The form is empty
      return "Can't be empty";
    }
//    String p = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\$";
//    RegExp regExp = new RegExp(p);
    if (value.length < 7) {
      _focusPassword.requestFocus();
      password = value;
      return 'Password must be upto 8 characters';
    } else {
      password = value;
      return null;
    }
//    if(regExp.hasMatch(value)){
//      return null;
//    }
//    return "Password must have capital";
  }

  String _validateConfirmPass(String value) {
    if (value.isEmpty) {
      // _focusConfirmPassword.requestFocus();
      return "Can't be empty";
    }
    if (value != password) {
      // _focusConfirmPassword.requestFocus();
      return "Password not match";
    } else {
      return null;
    }
  }

  String validateName(String value) {
    if (value.isEmpty) {
      _focusName.requestFocus();
      return "Can't be empty";
    } else {
      return null;
    }
  }

  String validatePhone(String value) {
    if (value.isEmpty) {
      return "Phone can't be empty";
    } else {
      return null;
    }
  }

  String validateAddress(String value) {
    if (value.isEmpty) {
      return "Address can't be empty";
    } else {
      return null;
    }
  }

  String validateYear(String value) {
    if (value == null) {
      return "Can't be empty";
    } else {
      return null;
    }
  }

  String validateMonth(String value) {
    if (value == null) {
      return "Can't be empty";
    } else {
      return null;
    }
  }

  String validateDay(String value) {
    if (value == null) {
      return "Can't be empty";
    } else {
      return null;
    }
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      _pilihKamera();
                      Navigator.pop(context);
                    },
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.photo_camera,
                            color: colorBlueDark,
                            size: 22.0,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Text(
                            "Camera",
                            style: TextStyle(fontSize: 18.0),
                          )
                        ])),
                FlatButton(
                    onPressed: () {
                      _loadAsset();
                      Navigator.pop(context);
                    },
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.photo,
                            color: colorBlueDark,
                            size: 22.0,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Text(
                            "Gallery",
                            style: TextStyle(fontSize: 18.0),
                          )
                        ])),
              ],
            ),
          );
        });
  }

  void _chooseActionSheet(context){
    showCupertinoModalPopup(
        context: context,
        builder: (context){
          return CupertinoActionSheet(
            title: Text("Choose Image"),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: (){
                    _loadAsset();
                    Navigator.pop(context);
                  },
                  child: Text("Gallery",style: TextStyle(color: Colors.blue))
              ),
              CupertinoActionSheetAction(
                  onPressed: (){
                    _pilihKamera();
                    Navigator.pop(context);
                  },
                  child: Text("Camera",style: TextStyle(color: Colors.blue),)
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Cancel",style: TextStyle(color: Colors.blue)),
                isDefaultAction: true
            ),
          );
        }
    );
  }

  _pilihKamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 1920.0, maxWidth: 1080.0);
    if (image != null) {
      setState(() {
        imageFile = image;
//        imageListFile.add(image);
      });
    } else {
      return;
    }
  }

  _loadAsset() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 1920.0, maxWidth: 1080.0);
    if (image != null) {
      setState(() {
        imageFile = image;
//        imageListFile.add(image);
      });
    } else {
      return;
    }
  }

  bool _showMessageEmptyAddress = false;
  bool _showMessageEmptyDateOfBirth = false;
  bool _showMessageEmptyGender = false;
  bool _showMessageEmptyPhone = false;

  _checkData(){
    if(txtEditControllerEmail.text != "" && txtEditControllerFullName.text != ""
        && txtEditControllerPassword.text != "" && txtEditControllerConfirmPass.text != ""){

      if(txtEditControllerAddress.text == ""){
        setState(() {
          _showMessageEmptyAddress = true;
        });
      }
      else{
        setState(() {
          _showMessageEmptyAddress = false;
        });
      }

      if(yearSelected == null || monthSelected == null || dateSelected == null){
        setState(() {
          _showMessageEmptyDateOfBirth = true;
        });
      }
      else{
        setState(() {
          _showMessageEmptyDateOfBirth = false;
        });
      }

      if(_genderSelected == null){
        setState(() {
          _showMessageEmptyGender = true;
        });
      }
      else{
        setState(() {
          _showMessageEmptyGender = false;
        });
      }

      if(txtEditControllerPhoneNumber.text == "" || _controllerCountryCode.text == ""){
        setState(() {
          _showMessageEmptyPhone = true;
        });
      }
      else{
        setState(() {
          _showMessageEmptyPhone = false;
        });
      }
    }
  }

  _checkAddress(){
    if(txtEditControllerAddress.text == ""){
      setState(() {
        _showMessageEmptyAddress = true;
      });
    }
    else{
      setState(() {
        _showMessageEmptyAddress = false;
      });
    }
  }
  
  _checkGender(){
    if(_genderSelected == null){
      setState(() {
        _showMessageEmptyGender = true;
      });
    }
    else{
      setState(() {
        _showMessageEmptyGender = false;
      });
    }
  }
  
  _checkBirthDate(){
    if(yearSelected == null || monthSelected == null || dateSelected == null){
      setState(() {
        _showMessageEmptyDateOfBirth = true;
      });
    }
    else{
      setState(() {
        _showMessageEmptyDateOfBirth = false;
      });
    }
  }

  _checkPhone(){
    if(txtEditControllerPhoneNumber.text == "" || _controllerCountryCode.text == ""){
      setState(() {
        _showMessageEmptyPhone = true;
      });
    }
    else{
      setState(() {
        _showMessageEmptyPhone = false;
      });
    }
  }
  _showHidePass() {
    setState(() {
      _secureText = !_secureText;
    });
  }
  _showHidePassConfirmPassword() {
    setState(() {
      _secureTextConfirmPass = !_secureTextConfirmPass;
    });
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shuguoyinxiang/gender_model.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_membership_card_by_email.dart';
import 'package:shuguoyinxiang/resource/send_data_update_member.dart';

import '../dashboard.dart';
import '../login.dart';

class UpdateMembershipCard extends StatefulWidget {
  final Function onRefreshData;
  UpdateMembershipCard({this.onRefreshData});

  @override
  _UpdateMembershipCardState createState() => _UpdateMembershipCardState();
}

class _UpdateMembershipCardState extends State<UpdateMembershipCard> {
  final txtEditControllerIdMember = TextEditingController();
  final txtEditControllerMembershipCard = TextEditingController();
  final txtEditControllerFullName = TextEditingController();
  final txtEditControllerEmail = TextEditingController();
  final txtEditControllerAddress = TextEditingController();
  final txtEditControllerPhoneNumber = TextEditingController();
  final txtEditControllerNewPassword = TextEditingController();
  final txtEditControllerConfirmPass = TextEditingController();
  final txtEditControllerOldPassword = TextEditingController();
  final _controllerCountryCode = TextEditingController();

  var fullName, password, oldPassword, email, phone, address, idMember;
  var _autoValidate = false;
  int radioValue;
  bool changePassword = false;
  File imageFile;
  RetrieveMembershipcardByEmail _retrieveMembershipcardByEmail;
  SendDataUpdateMember _sendDataUpdateMember;
  var loadDataPocess = false;
  String imageUrl;
  String _base64;
  var oldPasswordNotMatch = false;
  String oldPasswordFromServer;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _key = new GlobalKey<FormState>();
  var sendDataProcess = false;
  var _result;
  List<Gender> _genderList = [];
  Gender _genderSelected;

  @override
  void initState() {
    super.initState();
    _retrieveMembershipcardByEmail = RetrieveMembershipcardByEmail();
    _sendDataUpdateMember = SendDataUpdateMember();
    imageCache.clear();
    _genderList.add(Gender(1, "Male"));
    _genderList.add(Gender(2, "Female"));
    _genderList.add(Gender(3, "Rather not say"));
    _retrieveMembershipCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Update Member Card',
            style: TextStyle(fontFamily: 'Kano', color: colorBlueDark)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("img/Login.webp"),
            fit: BoxFit.cover,
          ),
        ),
        child: loadDataPocess
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _key,
          child: ListView(
            padding:
            EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
            children: <Widget>[
              Text('Member Card',
                  style: TextStyle(
                      fontFamily: 'Kano',
                      fontWeight: FontWeight.bold,
                      color: Color(0xffeab981))),
              TextFormField(
                style: new TextStyle(color: Color(0xffeab981)),
                decoration: InputDecoration(
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffeab981)),
                  ),
                ),
                controller: txtEditControllerMembershipCard,
                enabled: false,
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 47),
              Text('Image User',
                  style: TextStyle(
                      fontFamily: 'Kano',
                      fontWeight: FontWeight.bold,
                      color: Color(0xffeab981))),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
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
                            image: getImage(),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: new BorderRadius.all(
                              new Radius.circular(50.0)),
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
              SizedBox(height: MediaQuery.of(context).size.height / 47),
              Text('Full Name',
                  style: TextStyle(
                      fontFamily: 'Kano',
                      fontWeight: FontWeight.bold,
                      color: Color(0xffeab981))),
              TextFormField(
                style: new TextStyle(color: Color(0xffeab981)),
                controller: txtEditControllerFullName,
                onSaved: (e) => fullName = e,
                autovalidate: _autoValidate,
                validator: validateName,
                textCapitalization: TextCapitalization.sentences,
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
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 47),
              Text('Email',
                  style: TextStyle(
                      fontFamily: 'Kano',
                      fontWeight: FontWeight.bold,
                      color: Color(0xffeab981))),
              TextFormField(
                style: new TextStyle(color: Color(0xffeab981)),
                controller: txtEditControllerEmail,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                autovalidate: _autoValidate,
                onSaved: (e) => email = e,
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
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 47),
              Text('Password',
                  style: TextStyle(
                      fontFamily: 'Kano',
                      fontWeight: FontWeight.bold,
                      color: Color(0xffeab981))),
              Theme(
                data: ThemeData(unselectedWidgetColor: Color(0xffeab981)),
                child: Row(
                  children: <Widget>[
                    Checkbox(
                        activeColor: Color(0xffeab981),
                        value: changePassword,
                        onChanged: (bool newVal) {
                          setState(() {
                            changePassword = newVal;
                          });
                        }),
                    Text("Change Password",
                        style: TextStyle(
                            fontFamily: "Kano", color: Color(0xffeab981)))
                  ],
                ),
              ),
              changePassword
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    style: new TextStyle(color: Color(0xffeab981)),
                    controller: txtEditControllerOldPassword,
                    autovalidate: _autoValidate,
                    validator: _validateOldPassword,
                    onSaved: (e) => oldPassword = e,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'old password',
                      hintStyle: TextStyle(
                          fontFamily: 'Kano',
                          color: Color(0xffeab981)),
                      errorText: oldPasswordNotMatch
                          ? "Old password not match"
                          : null,
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
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    style: new TextStyle(color: Color(0xffeab981)),
                    controller: txtEditControllerNewPassword,
                    autovalidate: _autoValidate,
                    validator: _validatePassword,
                    onSaved: (e) => password = e,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'new password',
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
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    style: new TextStyle(color: Color(0xffeab981)),
                    controller: txtEditControllerConfirmPass,
                    validator: _validateConfirmPass,
                    autovalidate: _autoValidate,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 're-enter new password',
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
                    ),
                  ),
                  SizedBox(
                      height:
                      MediaQuery.of(context).size.height / 47),
                ],
              )
                  : SizedBox(height: 0.0, width: 0.0),
              Text('Address (Optional)',
                  style: TextStyle(
                      fontFamily: 'Kano',
                      fontWeight: FontWeight.bold,
                      color: Color(0xffeab981))),
              SizedBox(
                height: 8,
              ),
              TextFormField(
                style: new TextStyle(color: Color(0xffeab981)),
                controller: txtEditControllerAddress,
                // autovalidate: _autoValidate,
                // validator: validateAddress,
                onSaved: (e) => address = e,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Color(0xffeab981))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Color(0xffeab981))),
                ),
                maxLines: 3,
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                child: Text('Gender (Optional)',
                    style: TextStyle(
                        fontFamily: 'Kano', color: Color(0xffeab981))),
              ),
              SizedBox(
                height: 8,
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
                child: DropdownButtonFormField<Gender>(
                  style: new TextStyle(color: Color(0xffeab981)),
                  value: _genderSelected,
                  onTap: (){
                    FocusScope.of(context)
                        .requestFocus(new FocusNode());
                  },
                  onChanged: (newVal) {
                    setState(() {
                      _genderSelected = newVal;
                    });
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
                          vertical: 1.0, horizontal: 10)),
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
              // Text('Gender',
              //     style: TextStyle(
              //         fontFamily: 'Kano', color: Color(0xffeab981))),
              // Theme(
              //   data: ThemeData(unselectedWidgetColor: Color(0xffeab981)),
              //   child: Row(
              //     children: <Widget>[
              //       Row(
              //         children: <Widget>[
              //           Radio<int>(
              //               value: 1,
              //               groupValue: radioValue,
              //               onChanged: handleRadioValueChange,
              //               activeColor: Color(0xffeab981)),
              //           SizedBox(width: 4),
              //           Text("Male",
              //               style: TextStyle(
              //                   fontFamily: 'Kano',
              //                   color: Color(0xffeab981)))
              //         ],
              //       ),
              //       Row(
              //         children: <Widget>[
              //           Radio<int>(
              //               value: 2,
              //               groupValue: radioValue,
              //               onChanged: handleRadioValueChange,
              //               activeColor: Color(0xffeab981)),
              //           SizedBox(width: 4),
              //           Text("Female",
              //               style: TextStyle(
              //                   fontFamily: 'Kano',
              //                   color: Color(0xffeab981)))
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: MediaQuery.of(context).size.height / 47),
              Text('Mobile Phone Number (Optional)',
                  style: TextStyle(
                      fontFamily: 'Kano', color: Color(0xffeab981))),
              SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      style: new TextStyle(color: Color(0xffeab981)),
                      controller: _controllerCountryCode,
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
                            BorderSide(color: Color(0xffeab981)),
                            //  when the TextFormField in focused
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
                      // onSaved: (e) => phone = e,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(
                            RegExp(r"^[1-9][0-9]*$"))
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
              SizedBox(height: MediaQuery.of(context).size.height / 47),
              sendDataProcess
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                child: RaisedButton(
                  onPressed: () {
                    check();
                  },
                  child: Text('Continue',
                      style: TextStyle(
                          color: Colors.black, fontFamily: "Kano")),
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

  void handleRadioValueChange(int value) {
    setState(() {
      radioValue = value;
    });
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      return "Enter email address";
    }
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
    if (value.isEmpty) {
      // The form is empty
      return "Can't be empty";
    }
//    String p = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}\$";
//    RegExp regExp = new RegExp(p);
    if (value.length < 7) {
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
      return "Can't be empty";
    }
    if (value != password) {
      return "Password not match";
    } else {
      return null;
    }
  }

  String _validateOldPassword(String value) {
    if (value.isEmpty) {
      return "Can't be empty";
    } else {
      return null;
    }
  }

  String validateName(String value) {
    if (value.isEmpty) {
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

  _pilihKamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 1920.0, maxWidth: 1080.0);
    if (image != null) {
      setState(() {
        imageFile = image;
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
      });
    } else {
      return;
    }
  }

  getImage() {
    if (imageFile != null) {
      return FileImage(imageFile);
    } else if (imageUrl != "") {
      return NetworkImage(imageUrl);
    } else {
      return AssetImage('img/akun_user.webp');
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  _retrieveMembershipCard() async {
    imageUrl = "";
    setState(() {
      loadDataPocess = true;
    });

    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _resultSession = await _checkSession.checkSessionAfterLogin();
    if (_resultSession[0] == "valid code") {
      _result = await _retrieveMembershipcardByEmail.retrieveMembershipCard();

      List _phoneSplitNumber = [];

      if(_result['phone'] != "" ){
        _result['phone'].runes.forEach((int rune) {
          String character = new String.fromCharCode(rune);
          _phoneSplitNumber.add(character);
        });
      }

      if(_result['gender'] != "4"){
        int _gender = int.parse(_result['gender']);
        for(int i = 0; i <_genderList.length; i++){
          if(_genderList[i].id == _gender){
            print(" cek gender ${_result['gender']}");
            setState(() {
              _genderSelected = _genderList[i];
            });
          }
        }
      }

      setState(() {
        txtEditControllerMembershipCard.text = _result['memberCard'];
        txtEditControllerFullName.text = _result['memberName'];
        txtEditControllerEmail.text = _result['email'];
        txtEditControllerAddress.text = _result['address'];
        if(_phoneSplitNumber.isNotEmpty){
          _controllerCountryCode.text =
          "${_phoneSplitNumber[0]}${_phoneSplitNumber[1]}";
        }
        //
        if(_result['phone'] != ""){
          txtEditControllerPhoneNumber.text =
              _result['phone'].toString().replaceRange(0, 2, "");
        }

        radioValue = int.parse(_result['gender']);
        oldPasswordFromServer = _result['password'];
        idMember = _result['idMember'];
      });

      if (_result['imageUser'] != "") {
        setState(() {
          imageUrl = _result['imageUser'];
        });
      } else {
        setState(() {
          imageUrl = "";
        });
      }
      setState(() {
        loadDataPocess = false;
      });
    } else if (_resultSession[0] == "invalid code") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
    } else {
      setState(() {
        loadDataPocess = false;
      });
      _showSnackBar(_resultSession[0]);
    }
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      checkPassword();
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  checkPassword() {

    int _gender;

    if(_genderSelected == null){
      _gender = 4;
    }
    else{
      _gender = _genderSelected.id;
    }

    if (changePassword) {
      if (oldPassword != oldPasswordFromServer) {
        setState(() {
          oldPasswordNotMatch = true;
        });
      } else {
        setState(() {
          oldPasswordNotMatch = false;
        });
        _sendData(
          idMember,
          txtEditControllerMembershipCard.text,
          txtEditControllerFullName.text,
          txtEditControllerNewPassword.text,
          _gender,
          txtEditControllerPhoneNumber.text,
          txtEditControllerEmail.text,
          txtEditControllerAddress.text,
          _controllerCountryCode.text,
        );
      }
    } else {
      _sendData(
          idMember,
          txtEditControllerMembershipCard.text,
          txtEditControllerFullName.text,
          oldPasswordFromServer,
          _gender,
          txtEditControllerPhoneNumber.text,
          txtEditControllerEmail.text,
          txtEditControllerAddress.text,
          _controllerCountryCode.text);
    }
  }

  void _sendData(
      String idMember,
      String memberCard,
      String memberName,
      String password,
      int gender,
      String phone,
      String email,
      String address,
      String countryCode) async {
    setState(() {
      sendDataProcess = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if (_result[0] == "valid code") {
      if (imageFile != null) {
        List<int> imageBytes = imageFile.readAsBytesSync();
        String base64Image = base64.encode(imageBytes);
        var _result = await _sendDataUpdateMember.sendUpdateMemberWithImage(
            idMember,
            memberCard,
            memberName,
            password,
            gender,
            phone,
            email,
            address,
            base64Image,
            countryCode);
        if (_result['message'] == "Data Berhasil Update") {
          widget.onRefreshData();
          setState(() {
            sendDataProcess = false;
          });
          _showSnackBar(_result['message']);
        } else {
          setState(() {
            sendDataProcess = false;
          });
          _showSnackBar(_result['message']);
        }
      } else {
        if (imageUrl != "") {
          _convertImage(idMember, memberCard, memberName, password, gender,
              phone, email, address, imageUrl, countryCode);
        } else {
          _sendDataEmptyImageProfile(idMember, memberCard, memberName, password,
              gender, phone, email, address, countryCode);
        }
      }
    } else if (_result[0] == "invalid code") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
    } else {
      setState(() {
        sendDataProcess = false;
      });
      _showSnackBar(_result[0]);
    }
  }

  _convertImage(
      String idMember,
      String memberCard,
      String memberName,
      String password,
      int gender,
      String phone,
      String email,
      String address,
      String imageUrl,
      String countryCode) async {
    var imageConvert =
    await _retrieveMembershipcardByEmail.getFotoAndConvert(imageUrl);
    if (imageConvert != "0") {
      _sendDataWithoutImage(idMember, memberCard, memberName, password, gender,
          phone, email, address, imageConvert, countryCode);
    } else {
      _showSnackBar("Failed update member please re-send");
      setState(() {
        sendDataProcess = false;
      });
    }
  }

  _sendDataWithoutImage(
      String idMember,
      String memberCard,
      String memberName,
      String password,
      int gender,
      String phone,
      String email,
      String address,
      String imageConvert,
      String countryCode) async {
    var _result = await _sendDataUpdateMember.sendUpdateMemberWithoutImage(
        idMember,
        memberCard,
        memberName,
        password,
        gender,
        phone,
        email,
        address,
        imageConvert,
        countryCode);

    if (_result['message'] == "Data Berhasil Update") {
      widget.onRefreshData();
      setState(() {
        sendDataProcess = false;
      });
      _showSnackBar(_result['message']);
    } else {
      setState(() {
        sendDataProcess = false;
      });
      _showSnackBar(_result['message']);
    }

    setState(() {
      sendDataProcess = false;
    });
  }

  _sendDataEmptyImageProfile(
      String idMember,
      String memberCard,
      String memberName,
      String password,
      int gender,
      String phone,
      String email,
      String address,
      String countryCode) async {
    var _result = await _sendDataUpdateMember.sendUpdateMemberWithEmptyImage(
        idMember,
        memberCard,
        memberName,
        password,
        gender,
        phone,
        email,
        address,
        countryCode);

    if (_result['message'] == "Data Berhasil Update") {
      widget.onRefreshData();
      setState(() {
        sendDataProcess = false;
      });
      _showSnackBar(_result['message']);
    } else {
      setState(() {
        sendDataProcess = false;
      });
      _showSnackBar(_result['message']);
    }

    setState(() {
      sendDataProcess = false;
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
}

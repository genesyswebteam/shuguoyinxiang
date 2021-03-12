import 'package:flutter/material.dart';
import 'package:shuguoyinxiang/class_font/custom_icon_icons.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_image_cook_book_and_catering_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dashboard.dart';
import '../login.dart';

class CateringServicePage extends StatefulWidget {
  @override
  _CateringServicePageState createState() => _CateringServicePageState();
}

class _CateringServicePageState extends State<CateringServicePage> {
  RetrieveCookBookCateringService _retrieveCookBookCateringService;
  List<String> _listCateringService = [];
  var _loadImageCateringService = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Delivery Service",
              style: TextStyle(color: colorBlueDark, fontFamily: "Kano")),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: colorBlueDark),
          actions: <Widget>[
            IconButton(
                icon: Icon(CustomIcon.contact_us),
                onPressed: (){
                  _launchURL();
                }
            )
          ],
        ),
        body: _loadImageCateringService
            ? Center(
          child: CircularProgressIndicator(),
        )
            : ListView.builder(
          padding: EdgeInsets.all(0.0),
          itemBuilder: (context, index) {
            return Center(
              child: Image.network(
                _listCateringService[index],
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
              ),
            );
          },
          itemCount: _listCateringService.length,
        ));
  }

  @override
  void initState() {
    super.initState();
    _retrieveCookBookCateringService = RetrieveCookBookCateringService();
    _checkSession();
  }

  _checkSession() async {
    setState(() {
      _loadImageCateringService = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if (_result[0] == "valid code") {
      getImageCateringService();
    } else if (_result[0] == "invalid code") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
    } else {
      setState(() {
        _loadImageCateringService = true;
      });
    }
  }

  Future<void> getImageCateringService() async {
    var _result = await _retrieveCookBookCateringService
        .getImageCookBookCateringService();
    for (int i = 0; i < _result['data'].length; i++) {
      if (_result['data'][i]['type'] == "1") {
        _listCateringService.add(_result['data'][i]['picture']);
      }
    }
    setState(() {
      _loadImageCateringService = false;
    });
  }

  _launchURL() async {
    const url = 'https://shuguoyinxiang.contactin.bio/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

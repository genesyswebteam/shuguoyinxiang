import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

import '../dashboard.dart';
import '../login.dart';

class PromoPage extends StatefulWidget {
  @override
  _PromoPageState createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  var _isLoadData = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var promoList = [];

  List<MyItem> _items = <MyItem>[
    MyItem(header: 'Terms and Condition', body: 'body')
  ];

  var envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrievePromoAll xmlns="http://tempuri.org/" />
  </soap:Body>
</soap:Envelope>''';

  getDataPromo() async {
    try {
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrievePromoAll",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: envelope);
      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _dataGambar = parsedXml.findAllElements('Picture');
      var _gambarMap = _dataGambar.map((node) => node.text).toList();

      var _dataHeader = parsedXml.findAllElements('PromoHeader');
      var _headerMap = _dataHeader.map((node) => node.text).toList();

      var _dataDesc = parsedXml.findAllElements('Description');
      var _descMap = _dataDesc.map((node) => node.text).toList();

      var _dataTermAndCond = parsedXml.findAllElements('TermAndCondition');
      var _termAndCondMap = _dataTermAndCond.map((node) => node.text).toList();

      var _dataValidDate = parsedXml.findAllElements('ValidFrom');
      var _mapDataValidDate = _dataValidDate.map((node) => node.text).toList();

      var _mapData;
      for (var i = 0; i < _headerMap.length; i++) {
        _mapData = {
          "image": "img/logo_red_sgyx.webp",
          "image_promo": _gambarMap[i],
          "header": _headerMap[i],
          "descriptionItem": _descMap[i],
          "term_condition": _termAndCondMap[i],
          "valid": _mapDataValidDate[i],
          "isExpanded": true
        };
        promoList.add(_mapData);
      }
      setState(() {
        _isLoadData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadData = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  _checkSession() async {
    setState(() {
      _isLoadData = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if (_result[0] == "valid code") {
      getDataPromo();
    } else if (_result[0] == "invalid code") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
    } else {
      setState(() {
        _isLoadData = false;
      });
      _showSnackBar(_result[0]);
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(text), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("What\'s New",
            style: TextStyle(fontFamily: "OpenSans", color: colorBlueDark)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorBlueDark),
      ),
      body: _isLoadData
          ? Center(
          child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(colorBlueDark)))
          : Container(
        child: ListView.builder(
          itemBuilder: (context, indexList) {
            String _validDate = promoList[indexList]['valid'];
            List _listDate = _validDate.split("T");
            var _dateTime = DateTime.parse(_listDate[0]);
            var _formatted = DateFormat("EEEE, MMM dd,yyyy");
            String _dateFormat = _formatted.format(_dateTime);
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
//                Row(
//                  children: <Widget>[
//                    Expanded(
//                      child: Container(
//                          margin: EdgeInsets.only(left: 8),
//                          child: Image.asset(
//                            promoList[index]['image'],height: 45,width: 45,)),
//                      flex: 2,
//                    ),
//                    Expanded(
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          Container(
//                            margin: EdgeInsets.only(left: 8),
//                            child: Text(
//                                promoList[index]['header'],
//                                style: TextStyle(fontFamily: "OpenSansBold",fontSize: 16)
//                            ),
//                          ),
//                          SizedBox(height: MediaQuery.of(context).size.height/90),
//                          Container(
//                            margin: EdgeInsets.only(left: 8),
//                            child: Text(
//                                _dateFormat,
//                                style: TextStyle(fontFamily: "OpenSans")
//                            ),
//                          ),
//                        ],
//                      ),flex: 10,
//                    ),
//                  ],
//                ),
//                SizedBox(height: MediaQuery.of(context).size.height/46),
//                Row(
//                  children: <Widget>[
//                    SizedBox(width: MediaQuery.of(context).size.width/5.3,),
//                    Expanded(
//                      child: Container(
//                        margin: EdgeInsets.only(right: 8),
//                        child: Text(promoList[index]['descriptionItem']),
//                      ),
//                    ),
//                  ],
//                ),
//                SizedBox(height: MediaQuery.of(context).size.height/37),
//                Row(
//                  children: <Widget>[
//                    SizedBox(width: MediaQuery.of(context).size.width/5.3),
//                    Expanded(
//                        child: Container(
//                          margin: EdgeInsets.only(right: MediaQuery.of(context).size.width/21),
//                          child: CachedNetworkImage(
//                              imageUrl: promoList[index]['image_promo'],
//                              imageBuilder: (context,imageProvider){
//                                return Container(
//                                  height: MediaQuery.of(context).size.height/3.7,
////                                  width: MediaQuery.of(context).size.width/3,
//                                  decoration:BoxDecoration(
//                                    image: DecorationImage(
//                                      fit: BoxFit.cover,
//                                      image: imageProvider,
//                                    ),
//                                  ),
//                                );
//                                },
//                              placeholder: (context,url) {
//                                return Center(
//                                    child: CircularProgressIndicator(
//                                        valueColor: new AlwaysStoppedAnimation<Color>(colorBlueDark)
//                                    )
//                                );
//                              },),
//                        )
//                    )
//                  ],
//                ),
                  Container(
                    child: Image.network(
                      promoList[indexList]['image_promo'],
                      filterQuality: FilterQuality.low,
                    ),
                    margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                  ),
                  SizedBox(height: 24),
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: ExpansionPanelList(
                        expansionCallback: (int index, bool isExpanded) {
                          setState(() {
                            promoList[indexList]['isExpanded'] = !promoList[indexList]['isExpanded'];
//                                  _items[indexList].isExpanded =
//                                      !_items[indexList].isExpanded;
                          });
                        },
                        children: _expansionPanelList(promoList[indexList], indexList)
//                            _items.map((MyItem item) {
//                              return ExpansionPanel(
//                                  headerBuilder:
//                                      (BuildContext context, bool isExpanded) {
//                                    return ListTile(
//                                      title: Text(
//                                        item.header,
//                                        style: TextStyle(
//                                            fontFamily: "OpenSansBold",
//                                            fontSize: 18),
//                                      ),
//                                    );
//                                  },
//                                  isExpanded: !item.isExpanded,
//                                  body: Column(
//                                    crossAxisAlignment:
//                                        CrossAxisAlignment.start,
//                                    children: <Widget>[
//                                      Container(
//                                        child: Text(
//                                            promoList[indexList]['header'],
//                                            style: TextStyle(
//                                                fontFamily: "Kano",
//                                                fontSize: 20,
//                                                fontWeight: FontWeight.bold)),
//                                        margin: EdgeInsets.symmetric(
//                                            horizontal: 16),
//                                      ),
//                                      Container(
//                                        child: Text(
//                                            promoList[indexList]
//                                                ['descriptionItem'],
//                                            style: TextStyle(
//                                                fontFamily: "Kano",
//                                                fontSize: 16,
//                                                fontWeight: FontWeight.bold)),
//                                        margin: EdgeInsets.symmetric(
//                                            horizontal: 16),
//                                      ),
//                                      SizedBox(
//                                        height:
//                                            MediaQuery.of(context).size.height /
//                                                37,
//                                      ),
//                                      ListTile(
//                                        title: Container(
//                                            margin: EdgeInsets.only(bottom: 16),
//                                            child: Text(
//                                              promoList[indexList]
//                                                  ['term_condition'],
//                                              style:
//                                                  TextStyle(fontFamily: "Kano"),
//                                            )),
//                                      ),
//                                    ],
//                                  ),
//                                  canTapOnHeader: true);
//                            }).toList(),
                    ),
                  ),
                  SizedBox(height: 22),
                  Divider(height: 1, color: Colors.black)
                ],
              ),
            );
          },
          itemCount: promoList.length,
          padding: EdgeInsets.only(top: 8),
        ),
      ),
    );
  }

  List<ExpansionPanel> _expansionPanelList(Map data, int indexList) {
    List<ExpansionPanel> _list = [];
    _list.add(ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return Theme(
            data: ThemeData(fontFamily: "Kano"),
            child: ListTile(
                title: Text("Terms and Condition",
                    style:
                    TextStyle(fontFamily: "NunitoSansBold", fontSize: 18))),
          );
        },
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(promoList[indexList]['header'],
                  style: TextStyle(
                      fontFamily: "Kano",
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              margin: EdgeInsets.symmetric(horizontal: 16),
            ),
            Container(
              child: Text(promoList[indexList]['descriptionItem'],
                  style: TextStyle(
                      fontFamily: "Kano",
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              margin: EdgeInsets.symmetric(horizontal: 16),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 37,
            ),
            ListTile(
              title: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Text(
                    promoList[indexList]['term_condition'],
                    style: TextStyle(fontFamily: "Kano"),
                  )),
            ),
          ],
        ),
        isExpanded: !data['isExpanded'],
        canTapOnHeader: true));
    return _list;
  }
}

class MyItem {
  MyItem({this.isExpanded: true, this.header, this.body});

  bool isExpanded;
  final String header;
  final String body;
}

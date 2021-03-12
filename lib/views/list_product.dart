import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import '../login.dart';
import 'detail_product.dart';
const colorBlueDark = const Color(0xff162633);

class ListProduct extends StatefulWidget {
  final String title,idCategory;
  const ListProduct(this.title, this.idCategory);


  @override
  _ListProductState createState() => _ListProductState();
}

class _ListProductState extends State<ListProduct> {
  var beefList = [];
  var listKategory= [];
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  var descriptionMap;
  var descriptionItemMap;
  var isLoadData = false;

  getData() async {
    var envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveItemMasterDetailAll xmlns="http://tempuri.org/" />
  </soap:Body>
</soap:Envelope>''';

    http.Response response = await http.post(
        'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
        headers: {
          "Content-Type": "text/xml; charset=utf-8",
          "SOAPAction": "http://tempuri.org/RetrieveItemMasterDetailAll",
          "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
          //"Accept": "text/xml"
        },
        body: envelope);
    try{
      if(response.statusCode == 200){
        var rawXmlResponse = response.body;

        var parsedXml = xml.parse(rawXmlResponse);

        var dataGambar = parsedXml.findAllElements('Picture');
        var gambarMap = dataGambar.map((node) => node.text).toList();

        var dataGambar2 = parsedXml.findAllElements('Picture2');
        var gambarMap2 = dataGambar2.map((node) => node.text).toList();

        var dataDescription = parsedXml.findAllElements('Description');
        descriptionMap = dataDescription.map((node) => node.text).toList();

        var dataDescriptionItem = parsedXml.findAllElements('DescriptionItem');
        descriptionItemMap = dataDescriptionItem.map((node) => node.text).toList();

        var idCategory = parsedXml.findAllElements("CategoryID");
        var idCategoryMap = idCategory.map((node) => node.text).toList();

        var itemMasterId = parsedXml.findAllElements("ItemMasterId");
        var itemMasterIdMap = itemMasterId.map((node) => node.text).toList();

        for(var i =0; i< gambarMap.length; i++){
          var mapData = {
            "picture":gambarMap[i],
            "name":descriptionMap[i],
            "descriptionItem": descriptionItemMap[i],
            "CategoryID": idCategoryMap[i],
            "itemMasterId": itemMasterIdMap[i]
          };
          beefList.add(mapData);
        }

        for(int i= 0; i<beefList.length; i++){
          if(beefList[i]["CategoryID"] == widget.idCategory){
            listKategory.add(beefList[i]);
          }
        }

        if(mounted){
          setState(() {
            isLoadData = false;
          });
        }
//    var allData = parsedXml.findAllElements('RetrieveItemMasterDetailAllResult');
//    var mapAllData = allData.map((node) => node.text).toList();
//    print(mapAllData);
//        var data = jsonDecode(jsonData);
//        var dataku = data["soap\$Envelope"]['soap\$Body']['RetrieveItemMasterDetailAllResponse']['RetrieveItemMasterDetailAllResult']['ItemMasterDetail'];
//        print(dataku[0]);

//        var textual = parsedXml.descendants
//            .where((node) => node is xml.XmlText && node.text.trim().isNotEmpty).toList();
//        print(textual);
//
//        var titles = parsedXml.findElements('ItemMasterDetail');
//        print(titles
//            .map((node) => node is xml.XmlText)
//            .toList());
//        print("Cek attribute ${parsedXml.attributes}");
      }else{
        setState(() {
          isLoadData = false;
        });
      }
    }catch(e){
      setState(() {
        isLoadData = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  _checkSession() async{
    setState(() {
      isLoadData = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if(_result[0]=="valid code"){
      getData();
    }
    else if(_result[0]== "invalid code"){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
          LoginPage()),(Route <dynamic> route) => false);
    }
    else{
      setState(() {
        isLoadData = false;
      });
      _showSnackBar(_result[0]);
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text),behavior: SnackBarBehavior.floating));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title,style: TextStyle(color: colorBlueDark,fontFamily: 'OpenSans')),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: colorBlueDark),
        ),
        body: Container(
          margin: EdgeInsets.all(MediaQuery.of(context).size.height/50),
          child: isLoadData
              ?
          Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(colorBlueDark),))
              :
          GridView.builder(
              itemCount: listKategory.length,
              gridDelegate:
              new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: MediaQuery.of(context).size.height/50,
                  mainAxisSpacing: MediaQuery.of(context).size.height/50
              ),
              itemBuilder: (BuildContext context, int index) {
                print(listKategory[index]['name']);
                return InkWell(
                  onTap: widget.idCategory != "3" ? null : (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DetailProductPage(
                            listKategory[index]['itemMasterId'], listKategory[index]['name'])));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                          child: listKategory[index]['picture'] != "-"
                              ?
                          CachedNetworkImage(
                              imageUrl: listKategory[index]['picture'],
                              imageBuilder: (context,imageProvider){
                                return Container(
                                  decoration:BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: imageProvider,
                                    ),
                                  ),
                                );
                              },
                              placeholder: (context,url) {
                                return Center(
                                    child: CircularProgressIndicator(
                                        valueColor: new AlwaysStoppedAnimation<Color>(colorBlueDark)
                                    )
                                );
                              }
                          )
                              :
                          SizedBox(),
                          flex: 6
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/101),
                          child: Text(
                              listKategory[index]['name'],
                              style: TextStyle(
                                  fontFamily: 'Kano',
                                  fontSize: 16
                              )
                          ),
                        )
                        ,flex: 3,)
                    ],
                  ),
                );
              }),
        )
    );
  }
}

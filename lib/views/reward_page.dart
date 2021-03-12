import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_category_reward.dart';
import 'package:shuguoyinxiang/resource/retrieve_membership_card_by_email.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

import '../login.dart';
import 'choose_outlet_page.dart';

const colorBlueDark = const Color(0xff162633);

class RewardPage extends StatefulWidget {
  final Function onRefreshBadgeNotif;
  const RewardPage({Key key, this.onRefreshBadgeNotif}) : super(key: key);

  @override
  _RewardPageState createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  var point = 0;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var rewardList = [];
  var rewardListByCategory = [];
  var loadData = false;
  var loadFilter = false;
  RetrieveCategoryReward _retrieveCategoryReward;
  CategoryPopUpMenu _selectedCategory;
  RetrieveMembershipcardByEmail _retrieveMembershipcardByEmail;

  var envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveItemMasterRewardAll xmlns="http://tempuri.org/" />
  </soap:Body>
</soap:Envelope>''';

  getData() async {
    rewardList.clear();

    try {
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveItemMasterRewardAll",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: envelope);
      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var idReward = parsedXml.findAllElements('ID');
      var mapIdReward = idReward.map((node) => node.text).toList();

      var namaReward = parsedXml.findAllElements('ItemMasterDescription');
      var mapNamaReward = namaReward.map((node) => node.text).toList();

      var gambarReward = parsedXml.findAllElements('Picture');
      var mapGambarReward = gambarReward.map((node) => node.text).toList();

      var rewardPoint = parsedXml.findAllElements('Rewardpoint');
      var mapRewardPoint = rewardPoint.map((node) => node.text).toList();

      var notes = parsedXml.findAllElements('Notes');
      var mapNotes = notes.map((node) => node.text).toList();

      var _rewardCategoryId = parsedXml.findAllElements('RewardCategoryID');
      var mapRewardCategoryId =
      _rewardCategoryId.map((node) => node.text).toList();

      var _rewardItemMasterId = parsedXml.findAllElements('Itemmasterid');
      var _mapItemMasterId =
      _rewardItemMasterId.map((node) => node.text).toList();

      for (var i = 0; i < mapNamaReward.length; i++) {
        var mapData = {
          "itemMasterId": _mapItemMasterId[i],
          "idReward": mapIdReward[i],
          "image": mapGambarReward[i],
          "mercahndise_name": mapNamaReward[i],
          "warna": mapNotes[i],
          "point_value": mapRewardPoint[i],
          "rewardCategoryId": mapRewardCategoryId[i]
        };
        rewardList.add(mapData);
      }
      if (mounted) {
        setState(() {
          loadData = false;
        });
      }
    } catch (e) {
      setState(() {
        loadData = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _retrieveCategoryReward = RetrieveCategoryReward();
    _retrieveMembershipcardByEmail = RetrieveMembershipcardByEmail();
    _checkSession();
  }

  _checkSession() async {
    setState(() {
      loadData = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if (_result[0] == "valid code") {
      getCategoryReward();
      getPoint();
      getData();
    } else if (_result[0] == "invalid code") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
    } else {
      setState(() {
        loadData = false;
      });
      _showSnackBar(_result[0]);
    }
  }

//  var setCategory = 'Merchandise';
  var setPoint = 'Filtered by point';
  var variantSelected;

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(text), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
//      backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Reward',
              style: TextStyle(fontFamily: 'Kano', color: colorBlueDark)),
          iconTheme: IconThemeData(color: colorBlueDark),
          backgroundColor: Colors.white,
          bottom: PreferredSize(
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: PopupMenuButton<CategoryPopUpMenu>(
                        itemBuilder: (BuildContext context) {
                          return listDrop.map((CategoryPopUpMenu choice) {
                            return PopupMenuItem<CategoryPopUpMenu>(
                                value: choice, child: Text(choice.title));
                          }).toList();
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 24, bottom: 16),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text('Category',
                                        style: TextStyle(
                                            fontFamily: 'Kano',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                    flex: 6,
                                  ),
                                  Expanded(
                                    child: Icon(Icons.keyboard_arrow_down),
                                    flex: 2,
                                  )
                                ],
                              ),
                              _selectedCategory != null
                                  ? Text(_selectedCategory.title,
                                  style: TextStyle(
                                      fontFamily: 'Kano',
                                      fontWeight: FontWeight.bold,
                                      color: colorBlueDark))
                                  : Text("Filter by category",
                                  style: TextStyle(
                                      fontFamily: 'Kano',
                                      fontWeight: FontWeight.bold,
                                      color: colorBlueDark))
                            ],
                          ),
                        ),
                        offset: Offset(10, 25),
                        onSelected: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                          filterByCategory(value.idCategory);
                        },
                      ),
                      flex: 5,
                    ),
                    Expanded(
                      child: Container(
                          height: 40,
                          child: VerticalDivider(color: colorBlueDark)),
                      flex: 0,
                    ),
                    Expanded(
                      child: PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: "Highest Point",
                            child: Text(
                              "Highest Point",
                              style: TextStyle(
                                  color: colorBlueDark,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          PopupMenuItem(
                            value: "Lowest Point",
                            child: Text(
                              "Lowest Point",
                              style: TextStyle(
                                  color: colorBlueDark,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                        child: Container(
                          margin: EdgeInsets.only(left: 24, bottom: 16),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text('Sort and Filter',
                                        style: TextStyle(
                                            fontFamily: 'Kano',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                    flex: 6,
                                  ),
                                  Expanded(
                                    child: Icon(Icons.keyboard_arrow_down),
                                    flex: 2,
                                  )
                                ],
                              ),
                              Text(setPoint,
                                  style: TextStyle(
                                      fontFamily: 'Kano',
                                      fontWeight: FontWeight.bold,
                                      color: colorBlueDark))
                            ],
                          ),
                        ),
                        onSelected: (value) {
                          setState(() {
                            setPoint = value;
                          });
                          filterByPoint(value);
                        },
                        offset: Offset(35, 25),
                      ),
                      flex: 5,
                    ),
                  ],
                ),
              ),
              preferredSize: Size.fromHeight(75.0)),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Center(
              child: Container(
                  margin: EdgeInsets.only(right: 12),
                  child: Text('Points Balance : $point',
                      style: TextStyle(
                          fontFamily: 'Kano',
                          fontWeight: FontWeight.bold,
                          color: colorBlueDark,
                          fontSize: 18))),
            )
          ],
        ),
        body: loadData
            ? Center(child: CircularProgressIndicator())
            : rewardListByCategory.isEmpty
            ? ListView.builder(
          itemBuilder: (context, index) {
            int pointReward =
            int.parse(rewardList[index]['point_value']);
            int idReward = int.parse(rewardList[index]['idReward']);
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5.0,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: Container(
                                child: ClipRRect(
                                  child: Image.network(
                                    rewardList[index]['image'],
                                    height: MediaQuery.of(context)
                                        .size
                                        .height /
                                        4.4,
                                    fit: BoxFit.fill,
                                  ),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8)),
                                )),
                            flex: 7),
                        SizedBox(width: 7.7),
                        Expanded(
                          flex: 6,
                          child: Container(
                            margin: EdgeInsets.only(
                                left: 4, right: 8, bottom: 4, top: 4),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    rewardList[index]
                                    ['mercahndise_name'],
                                    style: TextStyle(
                                        fontFamily: "Kano",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 8),
//                                          Container(
//                                            child: Text(
//                                              rewardList[index]['warna'],
//                                              style:
//                                                  TextStyle(fontFamily: "Kano"),
//                                              maxLines: 2,
//                                              overflow: TextOverflow.ellipsis,
//                                            ),
//                                          ),
//                                          SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                          "${rewardList[index]['point_value']} pts",
                                          style: TextStyle(
                                              fontFamily: "Kano",
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 14)),
                                      flex: 4,
                                    ),
                                    Expanded(
                                      child: OutlineButton(
                                          shape:
                                          RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  8)),
                                          onPressed: () {
                                            print(rewardList[index]);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => ChooseOutletPage(
                                                        rewardList[
                                                        index]
                                                        [
                                                        'mercahndise_name'],
                                                        pointReward,
                                                        idReward,
                                                        widget
                                                            .onRefreshBadgeNotif,
                                                        rewardList[
                                                        index]
                                                        ['warna'],
                                                        rewardList[
                                                        index]
                                                        ['image'],
                                                        rewardList[
                                                        index]
                                                        [
                                                        'itemMasterId']))).then(
                                                    (value) =>
                                                    getPoint());
                                          },
                                          borderSide: BorderSide(
                                              color:
                                              Color(0xffeab981)),
                                          child: Text('Redeem',
                                              style: TextStyle(
                                                  fontFamily: "Kano",
                                                  fontSize: 11,
                                                  color: Color(
                                                      0xffeab981),
                                                  fontWeight:
                                                  FontWeight
                                                      .bold))),
                                      flex: 5,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: rewardList.length,
          padding:
          EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 16),
        )
            : ListView.builder(
          itemBuilder: (context, index) {
            int pointReward =
            int.parse(rewardListByCategory[index]['point_value']);
            int idReward =
            int.parse(rewardListByCategory[index]['idReward']);
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5.0,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                              child: ClipRRect(
                                child: Image.network(
                                  rewardListByCategory[index]['image'],
                                  fit: BoxFit.fill,
                                  height:
                                  MediaQuery.of(context).size.height /
                                      4.4,
                                ),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8)),
                              )),
                          flex: 7),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 6,
                        child: Container(
                          margin: EdgeInsets.only(left: 4, right: 8),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                    rewardListByCategory[index]
                                    ['mercahndise_name'],
                                    style: TextStyle(
                                        fontFamily: "Kano",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              SizedBox(height: 8),
//                                        Container(
//                                          child: Text(
//                                              rewardListByCategory[index]
//                                                  ['warna'],
//                                              style:
//                                                  TextStyle(fontFamily: "Kano"),
//                                              maxLines: 2,
//                                              overflow: TextOverflow.ellipsis),
//                                        ),
//                                        SizedBox(height: 8),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                        "${rewardListByCategory[index]['point_value']} pts",
                                        style: TextStyle(
                                            fontFamily: "Kano",
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 14)),
                                    flex: 4,
                                  ),
                                  Expanded(
                                    child: OutlineButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                8)),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ChooseOutletPage(
                                                      rewardListByCategory[
                                                      index][
                                                      'mercahndise_name'],
                                                      pointReward,
                                                      idReward,
                                                      widget
                                                          .onRefreshBadgeNotif,
                                                      rewardListByCategory[
                                                      index]
                                                      ['warna'],
                                                      rewardList[
                                                      index]
                                                      ['image'],
                                                      rewardList[
                                                      index][
                                                      'itemMasterId']))).then(
                                                  (value) => getPoint());
                                        },
                                        borderSide: BorderSide(
                                            color: Color(0xffeab981)),
                                        child: Text('Redeem',
                                            style: TextStyle(
                                                fontFamily: "Kano",
                                                fontSize: 11,
                                                color:
                                                Color(0xffeab981),
                                                fontWeight: FontWeight
                                                    .bold))),
                                    flex: 6,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          itemCount: rewardListByCategory.length,
          padding:
          EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 16),
        ));
  }

  List<CategoryPopUpMenu> listDrop = [];

  filterByPoint(String filterPoint) {
    if (filterPoint == "Highest Point") {
      if (rewardListByCategory.isNotEmpty) {
        setState(() {
          loadData = true;
          rewardListByCategory.sort((a, b) {
            var aPoint = int.parse(a['point_value']);
            var bPoint = int.parse(b['point_value']);
            return bPoint.compareTo(aPoint);
          });
          loadData = false;
        });
      } else {
        setState(() {
          loadData = true;
          rewardList.sort((a, b) {
            var aPoint = int.parse(a['point_value']);
            var bPoint = int.parse(b['point_value']);
            return bPoint.compareTo(aPoint);
          });
          loadData = false;
        });
      }
    } else if (setPoint == "Lowest Point") {
      if (rewardListByCategory.isNotEmpty) {
        setState(() {
          loadData = true;
          rewardListByCategory.sort((a, b) {
            var aPoint = int.parse(a['point_value']);
            var bPoint = int.parse(b['point_value']);
            return aPoint.compareTo(bPoint);
          });
          loadData = false;
        });
      } else {
        setState(() {
          loadData = true;
          rewardList.sort((a, b) {
            var aPoint = int.parse(a['point_value']);
            var bPoint = int.parse(b['point_value']);
            return aPoint.compareTo(bPoint);
          });
          loadData = false;
        });
      }
    }
  }

  filterByCategory(String idReward) {
    if (idReward == "0") {
      getData();
      setState(() {
        rewardListByCategory.clear();
      });
    } else {
      setState(() {
        loadData = true;
      });
      rewardListByCategory.clear();
      for (var i = 0; i < rewardList.length; i++) {
        if (rewardList[i]['rewardCategoryId'] == idReward) {
          rewardListByCategory.add(rewardList[i]);
        }
      }
      setState(() {
        loadData = false;
      });
    }
  }

  getCategoryReward() async {
    var _result = await _retrieveCategoryReward.getCategoryReward();
    CategoryPopUpMenu _categoryPopUpMenu;
    listDrop.add(CategoryPopUpMenu("All Reward", "0"));
    for (var u in _result) {
      _categoryPopUpMenu =
          CategoryPopUpMenu(u['mapItemCategory'], u['idRewardCategory']);
      listDrop.add(_categoryPopUpMenu);
    }
  }

  void getPoint() async {
    var _result = await _retrieveMembershipcardByEmail.retrieveMembershipCard();
    setState(() {
      point = int.parse(_result['points']);
    });
  }

//  void _showDialog(String mercahndiseName,String variant) {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: Text("Redeem reward",style: TextStyle(fontFamily: "OpenSans",color: Colors.black),),
//          content: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              Text("Redeem this merchandise?",style: TextStyle(fontFamily: "OpenSans")),
//              SizedBox(height: 8),
//              Text("Mercahndise name : $mercahndiseName",style: TextStyle(fontFamily: "OpenSans")),
//              SizedBox(height: 4),
//              Text("Variant : $variant",style: TextStyle(fontFamily: "OpenSans")),
//            ],
//          ),
//          actions:
//          <Widget>[
//            FlatButton(
//              child: new Text("Close"),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//            FlatButton(
//              child: new Text("Redeem"),
//              onPressed: () {
//                Navigator.pop(context);
//                kurangiPoin();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

//  kurangiPoin(){
//    if(point > 1000){
//      setState(() {
//        point -=1000;
//      });
//      _showSnackBar("Redeem reward succesfull");
//    }else{
//      _showSnackBar("Can't redeem because minimum point");
//    }
//  }
}

class CategoryPopUpMenu {
  final String title;
  final String idCategory;

  CategoryPopUpMenu(this.title, this.idCategory);
}

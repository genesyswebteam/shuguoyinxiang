import 'package:flutter/material.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/process_claim_reward.dart';
import 'package:shuguoyinxiang/resource/retrieve_outlet_api_provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

import '../dashboard.dart';
import '../login.dart';

class ChooseOutletPage extends StatefulWidget {
  final String namaItem, itemDetail, imageUrl, itemMasterId;
  final int pointRewardValue, idReward;
  final Function onRefreshBadgeNotif;
  const ChooseOutletPage(
      this.namaItem,
      this.pointRewardValue,
      this.idReward,
      this.onRefreshBadgeNotif,
      this.itemDetail,
      this.imageUrl,
      this.itemMasterId);
  @override
  _ChooseOutletPageState createState() => _ChooseOutletPageState();
}

class _ChooseOutletPageState extends State<ChooseOutletPage> {
//  var listOutlet =["Pantai Indah Kapuk","Lokasari", "Senayan City"];
  var _listMerchant = [];
  List<String> _merchantList = [];
  List<String> _availableMerchantList = [];
  var _availableMerchant = [];
  String outletSelected;
  String remarkText;
  var _autoValidate = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _txtRemarkController = new TextEditingController();
  final _key = new GlobalKey<FormState>();
  var loadData = false;
  ProcessClaimReward _processClaimReward;
  List<ItemDetailReward> _items = [];

  RetrieveOutletApiProvider _retrieveOutletApiProvider =
  RetrieveOutletApiProvider();

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      if (outletSelected == null) {
        _showSnackBar("Please choose pickup location");
      } else {
        processClaim();
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  getOutlet() async {
    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveOutlet xmlns="http://tempuri.org/" />
  </soap:Body>
</soap:Envelope>''';
    setState(() {
      loadData = true;
    });
    try {
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveOutlet",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);

      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var namaMerchant = parsedXml.findAllElements('MerchantName');
      var mapNamaMerchant = namaMerchant.map((node) => node.text).toList();

      var _merchantId = parsedXml.findAllElements('ID');
      var _mapMerchantId = _merchantId.map((node) => node.text).toList();

      for (var i = 0; i < _mapMerchantId.length; i++) {
        var _mapData = {
          "status": -1,
          "merchantId": _mapMerchantId[i],
          "merchantName": mapNamaMerchant[i]
        };
        _listMerchant.add(_mapData);
      }
      int _itemMasterId = int.parse(widget.itemMasterId);
      var _result = await _retrieveOutletApiProvider
          .retrieveItemMasterRewardAllperOutlet(_itemMasterId);
      if (_result['result']) {
        for (var i = 0; i < _listMerchant.length; i++) {
          for (var j = 0; j < _result['data'].length; j++) {
            if (_listMerchant[i]['merchantId'] ==
                _result['data'][j]['merchantId']) {
              _listMerchant[i]['status'] = 0;
            }
          }
        }
      }
      setState(() {
        loadData = false;
      });
//      _cekAvailableMerchant();
    } catch (e) {
      setState(() {
        loadData = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _processClaimReward = ProcessClaimReward();
    _checkSession();
    _items.add(ItemDetailReward(header: 'Reward detail', body: '${widget.itemDetail}'));
  }

  _checkSession() async {
    setState(() {
      loadData = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if (_result[0] == "valid code") {
      getOutlet();
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

  String _oldSelected = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Reward",
            style: TextStyle(fontFamily: "Kano", color: colorBlueDark)),
        actions: <Widget>[
          processSendDataClaim
              ? Center(
              child: Container(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: CircularProgressIndicator()))
              : Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: OutlineButton(
                onPressed: () {
                  check();
                },
                child: Text("Proceed",
                    style: TextStyle(
                        fontFamily: "Kano",
                        color: Color(0xffeab981),
                        fontWeight: FontWeight.bold)),
                borderSide: BorderSide(color: Color(0xffeab981)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        ],
      ),
      body: Form(
        key: _key,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: ListView(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  widget.imageUrl,
//                  height: 150.0,
//                  width: MediaQuery.of(context).size.width,
                ),
              ),
              SizedBox(height: 16),
              Text("Reward Name",
                  style: TextStyle(
                      fontFamily: "Kano",
                      color: colorBlueDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text("${widget.namaItem}",
                  style: TextStyle(
                      fontFamily: "Kano", color: colorBlueDark, fontSize: 18)),
              SizedBox(height: 16),
              Text("Pick up location",
                  style: TextStyle(
                      fontFamily: "Kano",
                      color: colorBlueDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Theme(
                data: ThemeData(canvasColor: Colors.white),
                child: DropdownButton<String>(
                  value: outletSelected,
                  isExpanded: true,
                  style: TextStyle(
                      fontFamily: "Kano",
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                  hint: Text("Choose Outlet"),
                  onChanged: (newVal) {
                    if (_isAvailableMerchant(newVal)) {
                      setState(() {
                        outletSelected = newVal;
                      });
                    }
                  },
//                  decoration: InputDecoration(
//                      border: OutlineInputBorder(),
//                      hintText: 'Choose Outlet',
//                      hintStyle: TextStyle(fontFamily: 'Kano'),
//                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0)),
//                  validator: validateOutlet,
                  items: _listMerchant.map((map) {
                    return DropdownMenuItem<String>(
                      value: map['merchantId'],
                      child: Text(map['merchantName'],
                          style: TextStyle(
                              color: map['status'] != -1
                                  ? Colors.black
                                  : Colors.grey)),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              ExpansionPanelList(
                expansionCallback: (index, isExpand){
                  setState(() {
                    _items[index].isExpanded = !_items[index].isExpanded;
                  });
                },
                children: _items.map((ItemDetailReward item) {
                  return  ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return  Theme(
                        data: ThemeData(fontFamily: "Kano"),
                        child: ListTile(
                            title: Text("${item.header}",
                                style:
                                TextStyle(fontFamily: "NunitoSansBold", fontSize: 18))),
                      );
                    },
                    isExpanded: item.isExpanded,
                    body:  Theme(
                      data: ThemeData(fontFamily: "Kano"),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child:  Text("${item.body}"),
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Text("${widget.itemDetail}",
              //     style: TextStyle(
              //         fontFamily: "Kano", color: colorBlueDark, fontSize: 18)),
              SizedBox(height: 16),
//              Text("Remark",
//                  style: TextStyle(
//                      fontFamily: "Kano",
//                      color: colorBlueDark,
//                      fontSize: 18,
//                      fontWeight: FontWeight.bold)),
//              SizedBox(height: 8),
//              TextFormField(
//                autovalidate: _autoValidate,
//                validator: validateRemark,
//                onSaved: (e) => remarkText = e,
//                decoration: InputDecoration(
//                  border: OutlineInputBorder(
//                    borderRadius: new BorderRadius.circular(8.0),
//                  ),
//                ),
//                maxLines: 3,
//              ),
            ],
          ),
        ),
      ),
    );
  }

  String validateRemark(String value) {
    if (value.isEmpty) {
      return "Can't be empty";
    } else {
      return null;
    }
  }

  String validateOutlet(String value) {
    if (value == null) {
      return "Can't be empty";
    } else {
      return null;
    }
  }

  var processSendDataClaim = false;

  processClaim() async {
    setState(() {
      processSendDataClaim = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if (_result[0] == "valid code") {
      int merchantId = int.parse(outletSelected);
      var _result = await _processClaimReward.claimReward(
          widget.pointRewardValue, widget.idReward, remarkText, merchantId);
      _showSnackBar(_result['message']);
      setState(() {
        processSendDataClaim = false;
      });
      widget.onRefreshBadgeNotif();
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

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(text, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating));
  }

  bool _isAvailableMerchant(String value) {
    bool _isAvailable = false;
    for (int i = 0; i < _listMerchant.length; i++) {
      if (_listMerchant[i]["merchantId"] == value) {
        if (_listMerchant[i]['status'] != -1) {
          _isAvailable = true;
        } else {
          _isAvailable = false;
        }
      }
    }
    return _isAvailable;
  }
}

class ItemDetailReward {
  ItemDetailReward({ this.isExpanded: false, this.header, this.body });

  bool isExpanded;
  final String header;
  final String body;
}

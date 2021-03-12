import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

import '../login.dart';
import 'add_point_history.dart';
import 'package:flutter/services.dart';
import 'claim_reward.dart';
import 'member_page.dart';

const colorBlueDark = const Color(0xff162633);

class AddPoint extends StatefulWidget {
  final Function(int) index;
  final int receiveIndex;
  const AddPoint(this.index, this.receiveIndex);

  @override
  _AddPointState createState() => _AddPointState();
}

class _AddPointState extends State<AddPoint> {
  final oCcy = new NumberFormat("#,##0", "en_US");
  ScanResult scanResult;
  var insertPointProcess = false;

  final _flashOnController = TextEditingController(text: "Flash on");
  final _flashOffController = TextEditingController(text: "Flash off");
  final _cancelController = TextEditingController(text: "Cancel");

  var _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [];

  @override
  // ignore: type_annotate_public_apis
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      scan();
//      _numberOfCameras = await BarcodeScanner.numberOfCameras;
//      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
//    var contentList = <Widget>[
//      if (scanResult != null)
//        Card(
//          child: Column(
//            children: <Widget>[
//              ListTile(
//                title: Text("Result Type"),
//                subtitle: Text(scanResult.type?.toString() ?? ""),
//              ),
//              ListTile(
//                title: Text("Raw Content"),
//                subtitle: Text(scanResult.rawContent ?? ""),
//              ),
//              ListTile(
//                title: Text("Format"),
//                subtitle: Text(scanResult.format?.toString() ?? ""),
//              ),
//              ListTile(
//                title: Text("Format note"),
//                subtitle: Text(scanResult.formatNote ?? ""),
//              ),
//            ],
//          ),
//        ),
//      ListTile(
//        title: Text("Camera selection"),
//        dense: true,
//        enabled: false,
//      ),
//      RadioListTile(
//        onChanged: (v) => setState(() => _selectedCamera = -1),
//        value: -1,
//        title: Text("Default camera"),
//        groupValue: _selectedCamera,
//      ),
//    ];
//
//    for (var i = 0; i < _numberOfCameras; i++) {
//      contentList.add(RadioListTile(
//        onChanged: (v) => setState(() => _selectedCamera = i),
//        value: i,
//        title: Text("Camera ${i + 1}"),
//        groupValue: _selectedCamera,
//      ));
//    }
//
//    contentList.addAll([
//      ListTile(
//        title: Text("Button Texts"),
//        dense: true,
//        enabled: false,
//      ),
//      ListTile(
//        title: TextField(
//          decoration: InputDecoration(
//            hasFloatingPlaceholder: true,
//            labelText: "Flash On",
//          ),
//          controller: _flashOnController,
//        ),
//      ),
//      ListTile(
//        title: TextField(
//          decoration: InputDecoration(
//            hasFloatingPlaceholder: true,
//            labelText: "Flash Off",
//          ),
//          controller: _flashOffController,
//        ),
//      ),
//      ListTile(
//        title: TextField(
//          decoration: InputDecoration(
//            hasFloatingPlaceholder: true,
//            labelText: "Cancel",
//          ),
//          controller: _cancelController,
//        ),
//      ),
//    ]);
//
//    if (Platform.isAndroid) {
//      contentList.addAll([
//        ListTile(
//          title: Text("Android specific options"),
//          dense: true,
//          enabled: false,
//        ),
//        ListTile(
//          title:
//          Text("Aspect tolerance (${_aspectTolerance.toStringAsFixed(2)})"),
//          subtitle: Slider(
//            min: -1.0,
//            max: 1.0,
//            value: _aspectTolerance,
//            onChanged: (value) {
//              setState(() {
//                _aspectTolerance = value;
//              });
//            },
//          ),
//        ),
//        CheckboxListTile(
//          title: Text("Use autofocus"),
//          value: _useAutoFocus,
//          onChanged: (checked) {
//            setState(() {
//              _useAutoFocus = checked;
//            });
//          },
//        )
//      ]);
//    }
//
//    contentList.addAll([
//      ListTile(
//        title: Text("Other options"),
//        dense: true,
//        enabled: false,
//      ),
//      CheckboxListTile(
//        title: Text("Start with flash"),
//        value: _autoEnableFlash,
//        onChanged: (checked) {
//          setState(() {
//            _autoEnableFlash = checked;
//          });
//        },
//      )
//    ]);
//
//    contentList.addAll([
//      ListTile(
//        title: Text("Barcode formats"),
//        dense: true,
//        enabled: false,
//      ),
//      ListTile(
//        trailing: Checkbox(
//          tristate: true,
//          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//          value: selectedFormats.length == _possibleFormats.length
//              ? true
//              : selectedFormats.length == 0 ? false : null,
//          onChanged: (checked) {
//            setState(() {
//              selectedFormats = [
//                if (checked ?? false) ..._possibleFormats,
//              ];
//            });
//          },
//        ),
//        dense: true,
//        enabled: false,
//        title: Text("Detect barcode formats"),
//        subtitle: Text(
//          'If all are unselected, all possible platform formats will be used',
//        ),
//      ),
//    ]);
//
//    contentList.addAll(_possibleFormats.map(
//          (format) => CheckboxListTile(
//        value: selectedFormats.contains(format),
//        onChanged: (i) {
//          setState(() => selectedFormats.contains(format)
//              ? selectedFormats.remove(format)
//              : selectedFormats.add(format));
//        },
//        title: Text(format.toString()),
//      ),
//    ));
//
//    return MaterialApp(
//      debugShowCheckedModeBanner: false,
//      home: Scaffold(
//        appBar: AppBar(
//          title: Text('Barcode Scanner Example'),
//          actions: <Widget>[
//            IconButton(
//              icon: Icon(Icons.camera),
//              tooltip: "Scan",
//              onPressed: scan,
//            )
//          ],
//        ),
//        body: ListView(
//          scrollDirection: Axis.vertical,
//          shrinkWrap: true,
//          children: contentList,
//        ),
//      ),
//    );
  }

  Future scan() async {
    try {
      var options = ScanOptions(
        strings: {
          "cancel": "Cancel",
          "flash_on": "Flash on",
          "flash_off": "Flash off",
        },
        restrictFormat: selectedFormats,
        useCamera: -1,
        autoEnableFlash: true,
        android: AndroidOptions(
          aspectTolerance: 0.00,
          useAutoFocus: true,
        ),
      );

      var result = await BarcodeScanner.scan(options: options);
      setState(() {
        scanResult = result;
      });
      if (scanResult.type.toString() == "Cancelled") {
        // Navigator.pop(context);
        widget.index(widget.receiveIndex);
      } else {
        insertPoint(scanResult.rawContent);
      }
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }

  insertPoint(String point) async {
    setState(() {
      insertPointProcess = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var idMember = preferences.getInt("idMember");
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if (_result[0] == "valid code") {
      var envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <InsertAddPoints xmlns="http://tempuri.org/">
      <invoice>$point</invoice>
      <Membercardid>$idMember</Membercardid>
    </InsertAddPoints>
  </soap:Body>
</soap:Envelope>''';
      try {
        http.Response response = await http.post(
            'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
            headers: {
              "Content-Type": "text/xml; charset=utf-8",
              "SOAPAction": "http://tempuri.org/InsertAddPoints",
              "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
              //"Accept": "text/xml"
            },
            body: utf8.encode(envelope));
        var rawXmlResponse = response.body;
        var parsedXml = xml.parse(rawXmlResponse);

        var _resultInsert = parsedXml.findAllElements("InsertAddPointsResult");
        var mapResultInsert = _resultInsert.map((node) => node.text).toList();

        if (mapResultInsert[0] ==
            "Qr Code already scanned, Please Contact your Administrator") {
          setState(() {
            insertPointProcess = false;
          });
          _showDialog(0, mapResultInsert[0]);
        } else {
          setState(() {
            insertPointProcess = false;
          });
          _showDialog(1, mapResultInsert[0]);
        }
      } catch (e) {
        setState(() {
          insertPointProcess = false;
        });
        _showDialog(0, "Error during add point");
      }
    } else if (_result[0] == "invalid code") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
    } else {
      setState(() {
        insertPointProcess = true;
      });
      _showDialog(0, "");
    }
  }

  void _showDialog(int status, String message) {
    String pesanSukses = "Add point successfull";
    String pesanGagal = "";
    String titleSukses = "Add point successfull";
    String titleGagal = "Failed";
    List _split = [];
    double _amount;
    if(status == 1){
      _split = message.split(",");
      _amount = double.parse(_split[2]);
    }
    else{
      pesanGagal = message;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Theme(
          data: ThemeData(fontFamily: "NunitoSans"),
          child: AlertDialog(
            title: status == 1 ? Text(titleSukses) : Text(titleGagal),
            content: status == 1
                ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text("Transaction Date"), flex: 4),
                    Text(" : "),
                    Expanded(child: Text(_split[0]), flex: 6),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(child: Text("Outlet"), flex: 4),
                    Text(" : "),
                    Expanded(child: Text("${_split[1]}"), flex: 6),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text("Bill Number"), flex: 4),
                    Text(" : "),
                    Expanded(child: Text(_split[5]), flex: 6),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text("Transaction Amount"),
                      flex: 4,
                    ),
                    Text(" : "),
                    Expanded(
                        child: Text("Rp ${oCcy.format(_amount)}"),
                        flex: 6),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(child: Text("Points Obtained"), flex: 4),
                    Text(" : "),
                    Expanded(child: Text(_split[3]), flex: 6),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Expanded(child: Text("Points Balance"), flex: 4),
                    Text(" : "),
                    Expanded(child: Text(_split[4]), flex: 6),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            )
                : Text(pesanGagal),
            actions: status == 1
                ? <Widget>[
              FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  backToPage();
                },
              ),
//                    FlatButton(
//                      child: new Text("Check point"),
//                      onPressed: () {
//                        Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                                builder: (context) => MemberPage()));
//                      },
//                    ),
            ]
                : <Widget>[
              FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  backToPage();
                },
              ),
              FlatButton(
                child: new Text("Re-Scan"),
                onPressed: () {
                  Navigator.pop(context);
                  scan();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  backToPage() {
    // Navigator.pop(context);
    widget.index(widget.receiveIndex);
  }

//  var insertPointProcess = false;
//
//  @override
//  void dispose() {
//    super.dispose();
//  }
//
//  Future<void> scanQR() async {
//    String barcodeScanRes;
//    try {
//      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
//          "#ff162633", "Cancel", true, ScanMode.QR);
//      if (barcodeScanRes != "-1") {
//        insertPoint(barcodeScanRes);
//      }else{
//        widget.index(widget.receiveIndex);
//      }
//    } on PlatformException {
//      barcodeScanRes = 'Failed to get platform version.';
//    }
//    if (!mounted) return;
//  }
//
//  @override
//  void initState() {
//    super.initState();
//    scanQR();
//  }
//
//  insertPoint(String point) async {
//    setState(() {
//      insertPointProcess = true;
//    });
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//    var idMember = preferences.getInt("idMember");
//    CheckSessionAPI _checkSession = CheckSessionAPI();
//    var _result = await _checkSession.checkSessionAfterLogin();
//    if(_result[0]=="valid code"){
//      var envelope = '''<?xml version="1.0" encoding="utf-8"?>
//<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//  <soap:Body>
//    <InsertAddPoints xmlns="http://tempuri.org/">
//      <invoice>$point</invoice>
//      <Membercardid>$idMember</Membercardid>
//    </InsertAddPoints>
//  </soap:Body>
//</soap:Envelope>''';
//      try{
//        http.Response response = await http.post(
//            'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
//            headers: {
//              "Content-Type": "text/xml; charset=utf-8",
//              "SOAPAction": "http://tempuri.org/InsertAddPoints",
//              "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
//              //"Accept": "text/xml"
//            },
//            body: utf8.encode(envelope));
//        var rawXmlResponse = response.body;
//        var parsedXml = xml.parse(rawXmlResponse);
//
//        var _resultInsert = parsedXml.findAllElements("InsertAddPointsResult");
//        var mapResultInsert = _resultInsert.map((node) => node.text).toList();
//
//        if(mapResultInsert[0] == " Thank you for adding Points SGYX"){
//          setState(() {
//            insertPointProcess = false;
//          });
//          _showDialog(1);
//        }
//        else{
//          setState(() {
//            insertPointProcess = false;
//          });
//          _showDialog(0);
//        }
//      }
//      catch(e){
//        setState(() {
//          insertPointProcess = false;
//        });
//        _showDialog(0);
//      }
//    }
//    else if(_result[0]== "invalid code"){
//      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
//          LoginPage()),(Route <dynamic> route) => false);
//    }
//    else{
//      setState(() {
//        insertPointProcess = true;
//      });
//      _showDialog(0);
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: Center(
//        child: insertPointProcess ? CircularProgressIndicator() : SizedBox(),
//      ),
//    );
//  }
//
//  void _showDialog(int status) {
//
//    String pesanSukses = "Add point successfull";
//    String pesanGagal = "Add point failed";
//    String titleSukses = "Succes";
//    String titleGagal = "Failed";
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: status == 1 ? Text(titleSukses): Text(titleGagal),
//          content: status == 1 ? Text(pesanSukses): Text(pesanGagal),
//          actions: status == 1 ?<Widget>[
//            FlatButton(
//              child: new Text("Close"),
//              onPressed: () {
//                Navigator.of(context).pop();
//                backToPage();
//              },
//            ),
//            FlatButton(
//              child: new Text("Check point"),
//              onPressed: () {
//                Navigator.push(context, MaterialPageRoute(builder: (context) => MemberPage()));
//              },
//            ),
//          ]
//              :
//          <Widget>[
//            FlatButton(
//              child: new Text("Close"),
//              onPressed: () {
//                Navigator.of(context).pop();
//                backToPage();
//              },
//            ),
//            FlatButton(
//              child: new Text("Re-Scan"),
//              onPressed: () {
//                Navigator.pop(context);
//                scanQR();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }
//
//  backToPage(){
//    widget.index(widget.receiveIndex);
//  }
}


// import 'dart:convert';
// import 'dart:io';
//
// import 'package:barcode_scan/barcode_scan.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
// import 'package:xml/xml.dart' as xml;
// import 'package:http/http.dart' as http;
//
// import '../login.dart';
// import 'add_point_history.dart';
// import 'package:flutter/services.dart';
// import 'claim_reward.dart';
// import 'member_page.dart';
//
// const colorBlueDark = const Color(0xff162633);
//
// class AddPoint extends StatefulWidget {
//   final Function(int) index;
//   final int receiveIndex;
//   const AddPoint(this.index, this.receiveIndex);
//
//   @override
//   _AddPointState createState() => _AddPointState();
// }
//
// class _AddPointState extends State<AddPoint> {
//   final oCcy = new NumberFormat("#,##0", "en_US");
//   ScanResult scanResult;
//   var insertPointProcess = false;
//
//   final _flashOnController = TextEditingController(text: "Flash on");
//   final _flashOffController = TextEditingController(text: "Flash off");
//   final _cancelController = TextEditingController(text: "Cancel");
//
//   var _aspectTolerance = 0.00;
//   var _numberOfCameras = 0;
//   var _selectedCamera = -1;
//   var _useAutoFocus = true;
//   var _autoEnableFlash = false;
//
//   static final _possibleFormats = BarcodeFormat.values.toList()
//     ..removeWhere((e) => e == BarcodeFormat.unknown);
//
//   List<BarcodeFormat> selectedFormats = [];
//
//   @override
//   // ignore: type_annotate_public_apis
//   initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () {
//       scan();
// //      _numberOfCameras = await BarcodeScanner.numberOfCameras;
// //      setState(() {});
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(),
//     );
// //    var contentList = <Widget>[
// //      if (scanResult != null)
// //        Card(
// //          child: Column(
// //            children: <Widget>[
// //              ListTile(
// //                title: Text("Result Type"),
// //                subtitle: Text(scanResult.type?.toString() ?? ""),
// //              ),
// //              ListTile(
// //                title: Text("Raw Content"),
// //                subtitle: Text(scanResult.rawContent ?? ""),
// //              ),
// //              ListTile(
// //                title: Text("Format"),
// //                subtitle: Text(scanResult.format?.toString() ?? ""),
// //              ),
// //              ListTile(
// //                title: Text("Format note"),
// //                subtitle: Text(scanResult.formatNote ?? ""),
// //              ),
// //            ],
// //          ),
// //        ),
// //      ListTile(
// //        title: Text("Camera selection"),
// //        dense: true,
// //        enabled: false,
// //      ),
// //      RadioListTile(
// //        onChanged: (v) => setState(() => _selectedCamera = -1),
// //        value: -1,
// //        title: Text("Default camera"),
// //        groupValue: _selectedCamera,
// //      ),
// //    ];
// //
// //    for (var i = 0; i < _numberOfCameras; i++) {
// //      contentList.add(RadioListTile(
// //        onChanged: (v) => setState(() => _selectedCamera = i),
// //        value: i,
// //        title: Text("Camera ${i + 1}"),
// //        groupValue: _selectedCamera,
// //      ));
// //    }
// //
// //    contentList.addAll([
// //      ListTile(
// //        title: Text("Button Texts"),
// //        dense: true,
// //        enabled: false,
// //      ),
// //      ListTile(
// //        title: TextField(
// //          decoration: InputDecoration(
// //            hasFloatingPlaceholder: true,
// //            labelText: "Flash On",
// //          ),
// //          controller: _flashOnController,
// //        ),
// //      ),
// //      ListTile(
// //        title: TextField(
// //          decoration: InputDecoration(
// //            hasFloatingPlaceholder: true,
// //            labelText: "Flash Off",
// //          ),
// //          controller: _flashOffController,
// //        ),
// //      ),
// //      ListTile(
// //        title: TextField(
// //          decoration: InputDecoration(
// //            hasFloatingPlaceholder: true,
// //            labelText: "Cancel",
// //          ),
// //          controller: _cancelController,
// //        ),
// //      ),
// //    ]);
// //
// //    if (Platform.isAndroid) {
// //      contentList.addAll([
// //        ListTile(
// //          title: Text("Android specific options"),
// //          dense: true,
// //          enabled: false,
// //        ),
// //        ListTile(
// //          title:
// //          Text("Aspect tolerance (${_aspectTolerance.toStringAsFixed(2)})"),
// //          subtitle: Slider(
// //            min: -1.0,
// //            max: 1.0,
// //            value: _aspectTolerance,
// //            onChanged: (value) {
// //              setState(() {
// //                _aspectTolerance = value;
// //              });
// //            },
// //          ),
// //        ),
// //        CheckboxListTile(
// //          title: Text("Use autofocus"),
// //          value: _useAutoFocus,
// //          onChanged: (checked) {
// //            setState(() {
// //              _useAutoFocus = checked;
// //            });
// //          },
// //        )
// //      ]);
// //    }
// //
// //    contentList.addAll([
// //      ListTile(
// //        title: Text("Other options"),
// //        dense: true,
// //        enabled: false,
// //      ),
// //      CheckboxListTile(
// //        title: Text("Start with flash"),
// //        value: _autoEnableFlash,
// //        onChanged: (checked) {
// //          setState(() {
// //            _autoEnableFlash = checked;
// //          });
// //        },
// //      )
// //    ]);
// //
// //    contentList.addAll([
// //      ListTile(
// //        title: Text("Barcode formats"),
// //        dense: true,
// //        enabled: false,
// //      ),
// //      ListTile(
// //        trailing: Checkbox(
// //          tristate: true,
// //          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
// //          value: selectedFormats.length == _possibleFormats.length
// //              ? true
// //              : selectedFormats.length == 0 ? false : null,
// //          onChanged: (checked) {
// //            setState(() {
// //              selectedFormats = [
// //                if (checked ?? false) ..._possibleFormats,
// //              ];
// //            });
// //          },
// //        ),
// //        dense: true,
// //        enabled: false,
// //        title: Text("Detect barcode formats"),
// //        subtitle: Text(
// //          'If all are unselected, all possible platform formats will be used',
// //        ),
// //      ),
// //    ]);
// //
// //    contentList.addAll(_possibleFormats.map(
// //          (format) => CheckboxListTile(
// //        value: selectedFormats.contains(format),
// //        onChanged: (i) {
// //          setState(() => selectedFormats.contains(format)
// //              ? selectedFormats.remove(format)
// //              : selectedFormats.add(format));
// //        },
// //        title: Text(format.toString()),
// //      ),
// //    ));
// //
// //    return MaterialApp(
// //      debugShowCheckedModeBanner: false,
// //      home: Scaffold(
// //        appBar: AppBar(
// //          title: Text('Barcode Scanner Example'),
// //          actions: <Widget>[
// //            IconButton(
// //              icon: Icon(Icons.camera),
// //              tooltip: "Scan",
// //              onPressed: scan,
// //            )
// //          ],
// //        ),
// //        body: ListView(
// //          scrollDirection: Axis.vertical,
// //          shrinkWrap: true,
// //          children: contentList,
// //        ),
// //      ),
// //    );
//   }
//
//   Future scan() async {
//     try {
//       var options = ScanOptions(
//         strings: {
//           "cancel": "Cancel",
//           "flash_on": "Flash on",
//           "flash_off": "Flash off",
//         },
//         restrictFormat: selectedFormats,
//         useCamera: -1,
//         autoEnableFlash: true,
//         android: AndroidOptions(
//           aspectTolerance: 0.00,
//           useAutoFocus: true,
//         ),
//       );
//
//       var result = await BarcodeScanner.scan(options: options);
//       setState(() {
//         scanResult = result;
//       });
//       if (scanResult.type.toString() == "Cancelled") {
//         widget.index(widget.receiveIndex);
//       } else {
//         insertPoint(scanResult.rawContent);
//       }
//     } on PlatformException catch (e) {
//       var result = ScanResult(
//         type: ResultType.Error,
//         format: BarcodeFormat.unknown,
//       );
//
//       if (e.code == BarcodeScanner.cameraAccessDenied) {
//         setState(() {
//           result.rawContent = 'The user did not grant the camera permission!';
//         });
//       } else {
//         result.rawContent = 'Unknown error: $e';
//       }
//       setState(() {
//         scanResult = result;
//       });
//     }
//   }
//
//   insertPoint(String point) async {
//     setState(() {
//       insertPointProcess = true;
//     });
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var idMember = preferences.getInt("idMember");
//     CheckSessionAPI _checkSession = CheckSessionAPI();
//     var _result = await _checkSession.checkSessionAfterLogin();
//     if (_result[0] == "valid code") {
//       var envelope = '''<?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <InsertAddPoints xmlns="http://tempuri.org/">
//       <invoice>$point</invoice>
//       <Membercardid>$idMember</Membercardid>
//     </InsertAddPoints>
//   </soap:Body>
// </soap:Envelope>''';
//       try {
//         http.Response response = await http.post(
//             'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
//             headers: {
//               "Content-Type": "text/xml; charset=utf-8",
//               "SOAPAction": "http://tempuri.org/InsertAddPoints",
//               "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
//               //"Accept": "text/xml"
//             },
//             body: utf8.encode(envelope));
//         var rawXmlResponse = response.body;
//         var parsedXml = xml.parse(rawXmlResponse);
//
//         var _resultInsert = parsedXml.findAllElements("InsertAddPointsResult");
//         var mapResultInsert = _resultInsert.map((node) => node.text).toList();
//
//         if (mapResultInsert[0] ==
//             "Qr Code already scanned, Please Contact your Administrator") {
//           setState(() {
//             insertPointProcess = false;
//           });
//           _showDialog(0, "");
//         } else {
//           setState(() {
//             insertPointProcess = false;
//           });
//           _showDialog(1, mapResultInsert[0]);
//         }
//       } catch (e) {
//         setState(() {
//           insertPointProcess = false;
//         });
//         _showDialog(0, "");
//       }
//     } else if (_result[0] == "invalid code") {
//       Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => LoginPage()),
//               (Route<dynamic> route) => false);
//     } else {
//       setState(() {
//         insertPointProcess = true;
//       });
//       _showDialog(0, "");
//     }
//   }
//
//   void _showDialog(int status, String message) {
//     String pesanSukses = "Add point successfull";
//     String pesanGagal = "Add point failed";
//     String titleSukses = "Add point successfull";
//     String titleGagal = "Failed";
//     List _split = [];
//     if (message != "") {
//       _split = message.split(",");
//     }
//     double _amount = double.parse(_split[2]);
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         // return object of type Dialog
//         return Theme(
//           data: ThemeData(fontFamily: "NunitoSans"),
//           child: AlertDialog(
//             title: status == 1 ? Text(titleSukses) : Text(titleGagal),
//             content: status == 1
//                 ? Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(child: Text("Transaction Date"), flex: 4),
//                     Text(" : "),
//                     Expanded(child: Text(_split[0]), flex: 6),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 8,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(child: Text("Outlet"), flex: 4),
//                     Text(" : "),
//                     Expanded(child: Text("${_split[1]}"), flex: 6),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Expanded(child: Text("Bill Number"), flex: 4),
//                     Text(" : "),
//                     Expanded(child: Text(_split[5]), flex: 6),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 8,
//                 ),
//                 SizedBox(
//                   height: 8,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text("Transaction Amount"),
//                       flex: 4,
//                     ),
//                     Text(" : "),
//                     Expanded(
//                         child: Text("Rp ${oCcy.format(_amount)}"),
//                         flex: 6),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 8,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(child: Text("Points Obtained"), flex: 4),
//                     Text(" : "),
//                     Expanded(child: Text(_split[3]), flex: 6),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 4,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(child: Text("Points Balance"), flex: 4),
//                     Text(" : "),
//                     Expanded(child: Text(_split[4]), flex: 6),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 8,
//                 ),
//               ],
//             )
//                 : Text(pesanGagal),
//             actions: status == 1
//                 ? <Widget>[
//               FlatButton(
//                 child: new Text("OK"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   backToPage();
//                 },
//               ),
// //                    FlatButton(
// //                      child: new Text("Check point"),
// //                      onPressed: () {
// //                        Navigator.push(
// //                            context,
// //                            MaterialPageRoute(
// //                                builder: (context) => MemberPage()));
// //                      },
// //                    ),
//             ]
//                 : <Widget>[
//               FlatButton(
//                 child: new Text("OK"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   backToPage();
//                 },
//               ),
//               FlatButton(
//                 child: new Text("Re-Scan"),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   scan();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   backToPage() {
//     widget.index(widget.receiveIndex);
//   }
//
// //  var insertPointProcess = false;
// //
// //  @override
// //  void dispose() {
// //    super.dispose();
// //  }
// //
// //  Future<void> scanQR() async {
// //    String barcodeScanRes;
// //    try {
// //      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
// //          "#ff162633", "Cancel", true, ScanMode.QR);
// //      if (barcodeScanRes != "-1") {
// //        insertPoint(barcodeScanRes);
// //      }else{
// //        widget.index(widget.receiveIndex);
// //      }
// //    } on PlatformException {
// //      barcodeScanRes = 'Failed to get platform version.';
// //    }
// //    if (!mounted) return;
// //  }
// //
// //  @override
// //  void initState() {
// //    super.initState();
// //    scanQR();
// //  }
// //
// //  insertPoint(String point) async {
// //    setState(() {
// //      insertPointProcess = true;
// //    });
// //    SharedPreferences preferences = await SharedPreferences.getInstance();
// //    var idMember = preferences.getInt("idMember");
// //    CheckSessionAPI _checkSession = CheckSessionAPI();
// //    var _result = await _checkSession.checkSessionAfterLogin();
// //    if(_result[0]=="valid code"){
// //      var envelope = '''<?xml version="1.0" encoding="utf-8"?>
// //<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
// //  <soap:Body>
// //    <InsertAddPoints xmlns="http://tempuri.org/">
// //      <invoice>$point</invoice>
// //      <Membercardid>$idMember</Membercardid>
// //    </InsertAddPoints>
// //  </soap:Body>
// //</soap:Envelope>''';
// //      try{
// //        http.Response response = await http.post(
// //            'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
// //            headers: {
// //              "Content-Type": "text/xml; charset=utf-8",
// //              "SOAPAction": "http://tempuri.org/InsertAddPoints",
// //              "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
// //              //"Accept": "text/xml"
// //            },
// //            body: utf8.encode(envelope));
// //        var rawXmlResponse = response.body;
// //        var parsedXml = xml.parse(rawXmlResponse);
// //
// //        var _resultInsert = parsedXml.findAllElements("InsertAddPointsResult");
// //        var mapResultInsert = _resultInsert.map((node) => node.text).toList();
// //
// //        if(mapResultInsert[0] == " Thank you for adding Points SGYX"){
// //          setState(() {
// //            insertPointProcess = false;
// //          });
// //          _showDialog(1);
// //        }
// //        else{
// //          setState(() {
// //            insertPointProcess = false;
// //          });
// //          _showDialog(0);
// //        }
// //      }
// //      catch(e){
// //        setState(() {
// //          insertPointProcess = false;
// //        });
// //        _showDialog(0);
// //      }
// //    }
// //    else if(_result[0]== "invalid code"){
// //      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
// //          LoginPage()),(Route <dynamic> route) => false);
// //    }
// //    else{
// //      setState(() {
// //        insertPointProcess = true;
// //      });
// //      _showDialog(0);
// //    }
// //  }
// //
// //  @override
// //  Widget build(BuildContext context) {
// //    return Scaffold(
// //      body: Center(
// //        child: insertPointProcess ? CircularProgressIndicator() : SizedBox(),
// //      ),
// //    );
// //  }
// //
// //  void _showDialog(int status) {
// //
// //    String pesanSukses = "Add point successfull";
// //    String pesanGagal = "Add point failed";
// //    String titleSukses = "Succes";
// //    String titleGagal = "Failed";
// //    showDialog(
// //      context: context,
// //      builder: (BuildContext context) {
// //        // return object of type Dialog
// //        return AlertDialog(
// //          title: status == 1 ? Text(titleSukses): Text(titleGagal),
// //          content: status == 1 ? Text(pesanSukses): Text(pesanGagal),
// //          actions: status == 1 ?<Widget>[
// //            FlatButton(
// //              child: new Text("Close"),
// //              onPressed: () {
// //                Navigator.of(context).pop();
// //                backToPage();
// //              },
// //            ),
// //            FlatButton(
// //              child: new Text("Check point"),
// //              onPressed: () {
// //                Navigator.push(context, MaterialPageRoute(builder: (context) => MemberPage()));
// //              },
// //            ),
// //          ]
// //              :
// //          <Widget>[
// //            FlatButton(
// //              child: new Text("Close"),
// //              onPressed: () {
// //                Navigator.of(context).pop();
// //                backToPage();
// //              },
// //            ),
// //            FlatButton(
// //              child: new Text("Re-Scan"),
// //              onPressed: () {
// //                Navigator.pop(context);
// //                scanQR();
// //              },
// //            ),
// //          ],
// //        );
// //      },
// //    );
// //  }
// //
// //  backToPage(){
// //    widget.index(widget.receiveIndex);
// //  }
// }

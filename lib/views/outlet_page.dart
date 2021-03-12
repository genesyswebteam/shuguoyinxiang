import 'package:flutter/material.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_outlet_api_provider.dart';

import '../login.dart';

const colorBlueDark = const Color(0xff162633);

class OutletPage extends StatefulWidget {
  @override
  _OutletPageState createState() => _OutletPageState();
}

class _OutletPageState extends State<OutletPage> {
  RetrieveOutletApiProvider _retrieveOutletApiProvider;
  var _loadGetOutlet = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  var _listOutlet = [];

  @override
  void initState() {
    super.initState();
    _retrieveOutletApiProvider = RetrieveOutletApiProvider();
    _checkSession();
  }

  _checkSession() async {
    setState(() {
      _loadGetOutlet = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if (_result[0] == "valid code") {
      _getOutlet();
    } else if (_result[0] == "invalid code") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
    } else {
      setState(() {
        _loadGetOutlet = false;
      });
      _showSnackBar(_result[0]);
    }
  }

  _getOutlet() async {
    var _result = await _retrieveOutletApiProvider.getAllOutlet();
    if (_result['result']) {
      _listOutlet = _result['data'];
      setState(() {
        _loadGetOutlet = false;
      });
    } else {
      setState(() {
        _loadGetOutlet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
//      decoration:new BoxDecoration(
//        image: new DecorationImage(
//          image: new AssetImage("img/home.webp"),
//          fit: BoxFit.cover,
//        ),
//      ),
      child: Scaffold(
//        backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text('Outlets',
                style: TextStyle(color: colorBlueDark, fontFamily: 'OpenSans')),
            iconTheme: IconThemeData(color: colorBlueDark),
          ),
          body: Container(
            child: _loadGetOutlet
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 50,
                      bottom: MediaQuery.of(context).size.height / 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Image.asset('img/logo_red_sgyx.webp',
                                scale: 6),
                            flex: 1,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                                _listOutlet[index]['merchantName'],
                                style: TextStyle(
                                    fontFamily: 'Kano',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            flex: 9,
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: SizedBox(),
                            flex: 1,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(_listOutlet[index]['address'],
                                style: TextStyle(fontFamily: 'Kano')),
                            flex: 9,
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
//                  mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Expanded(child: SizedBox(), flex: 1),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                                'Operational Hours : ${_listOutlet[index]['jamBuka']} - ${_listOutlet[index]['jamTutup']}',
                                style: TextStyle(fontFamily: 'Kano')),
                            flex: 9,
                          )
                        ],
                      ),
                      Row(
//                  mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Expanded(child: SizedBox(), flex: 1),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(_listOutlet[index]['phone'],
                                style: TextStyle(fontFamily: 'Kano')),
                            flex: 9,
                          )
                        ],
                      ),
                      Divider(
                        color: Colors.black12,
                        height: 32,
                      )
                    ],
                  ),
                );
              },
              itemCount: _listOutlet.length,
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 24,
                  vertical: MediaQuery.of(context).size.height / 50),
            ),
          )),
    );
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(text), behavior: SnackBarBehavior.floating));
  }
}

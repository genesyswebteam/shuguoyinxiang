import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_point_transaction_sgyx_api_provider.dart';

import '../login.dart';

class AddPointHistory extends StatefulWidget {
  @override
  _AddPointHistoryState createState() => _AddPointHistoryState();
}

class _AddPointHistoryState extends State<AddPointHistory> {
  RetrievePointTransaction _retrievePointTransaction;
  var _loadData = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refresh =
  GlobalKey<RefreshIndicatorState>();

  var addHistoryPointList = [];

  @override
  void initState() {
    super.initState();
    _retrievePointTransaction = RetrievePointTransaction();
    _checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _loadData
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        key: _refresh,
        onRefresh: getHistoryTransaction,
        child: ListView.builder(
            itemBuilder: (context, index) {
              DateTime _dateTimeFormat = DateTime.parse(
                  addHistoryPointList[index]['trans_date']);
              DateFormat _formatted = DateFormat("yyyy MMM dd HH:mm");
              String _dateTime = _formatted.format(_dateTimeFormat);
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Image.asset("img/logo_red_sgyx.webp",
                                scale: 8),
                          ),
                          flex: 2,
                        ),
                        Expanded(
                          flex: 6,
                          child: Container(
                            margin: EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                      "${addHistoryPointList[index]['outlet_name']}",
                                      style: TextStyle(
                                          fontFamily: "Kano",
                                          fontSize: 18)),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  child: Text(
                                      "${addHistoryPointList[index]['bill_no']}",
                                      style: TextStyle(
                                          fontFamily: "Kano",
                                          fontSize: 18)),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  child: Text(
                                      "Rp ${addHistoryPointList[index]['total_amount']}",
                                      style: TextStyle(
                                          fontFamily: "Kano",
                                          fontSize: 18)),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  child: Text(
                                    _dateTime,
                                    style: TextStyle(
                                        fontFamily: "NunitoSans"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "",
                                  style: TextStyle(
                                      fontFamily: "Kano", fontSize: 18),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "Point : ${addHistoryPointList[index]['point']}",
                                  style: TextStyle(
                                      fontFamily: "OpenSansBold"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: Colors.black,
                    )
                  ],
                ),
              );
            },
            itemCount: addHistoryPointList.length,
            padding:
            EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8)),
      ),
    );
  }

  _checkSession() async {
    setState(() {
      _loadData = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if (_result[0] == "valid code") {
      getHistoryTransaction();
    } else if (_result[0] == "invalid code") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
    } else {
      setState(() {
        _loadData = false;
      });
      _showSnackBar(_result[0]);
    }
  }

  Future<void> getHistoryTransaction() async {
    var _result = await _retrievePointTransaction.getPointTransactionHistory();
    if (_result['result']) {
      setState(() {
        addHistoryPointList = _result['data'];
        addHistoryPointList.sort((a, b) {
          var aPoint = a['trans_date'];
          var bPoint = b['trans_date'];
          return bPoint.compareTo(aPoint);
        });
        _loadData = false;
      });
    } else {
      _showSnackBar(_result['message']);
      setState(() {
        _loadData = false;
      });
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }
}

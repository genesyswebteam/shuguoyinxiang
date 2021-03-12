import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuguoyinxiang/db/database_helper.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/inbox_api_provider.dart';

import '../login.dart';
import 'detail_inbox.dart';

const colorBlueDark = const Color(0xff162633);

class InboxPage extends StatefulWidget {
  final Function onRefreshBadgeInboxNotif;
  const InboxPage({Key key, this.onRefreshBadgeInboxNotif}) : super(key: key);

  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  InboxApiProvider _inboxApiProvider;
  var loadInbox = false;
  final dbHelper = DatabaseHelper.instance;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  var inboxListFromServer =[];
  var _inboxListFromSqlite = [];

  @override
  void initState() {
    super.initState();
    _inboxApiProvider = InboxApiProvider();
    _checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: SafeArea(child: Text("Inbox",style: TextStyle(color: colorBlueDark,fontFamily: "Kano"))),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body:
      loadInbox
          ?
      Center(child: CircularProgressIndicator())
          :
      ListView.builder(
          itemBuilder: (context,index){
            return InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => DetailInbox(
                    _inboxListFromSqlite[index]['templateName'],
                    _inboxListFromSqlite[index]['templateDescription'],
                    _inboxListFromSqlite[index]['templateBodyMessage'],
                    _inboxListFromSqlite[index]['idPesan'],
                    widget.onRefreshBadgeInboxNotif,_refreshInboxList
                )));
              },
              child: Container(
                margin: EdgeInsets.only(left: 8,bottom: 8,right: 8),
                child: Column(
                  children: <Widget>[
                    _inboxListFromSqlite[index]['isRead'] == 0
                        ?
                    Row(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 19,
                              backgroundColor: Colors.greenAccent,
                              child:  Icon(Icons.mail,color: Colors.white),
                            ),
                            Positioned(
                              right: 1,
                              top: 1,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: new BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 8,
                                  minHeight: 8,
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 8,bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(_inboxListFromSqlite[index]['templateName'],
                                  style: TextStyle(
                                      fontSize: 18,fontFamily: "Kano",
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4,),
                              Text(_inboxListFromSqlite[index]['templateDescription'],
                                style: TextStyle(fontFamily: "Kano"),)
                            ],
                          ),
                        )
                      ],
                    )
                        :
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 19,
                          backgroundColor: Colors.greenAccent,
                          child: Icon(Icons.mail,color: Colors.white),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 8,bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(_inboxListFromSqlite[index]['templateName'],
                                  style: TextStyle(
                                      fontSize: 18,fontFamily: "Kano")),
                              SizedBox(height: 4,),
                              Text(_inboxListFromSqlite[index]['templateDescription'],
                                style: TextStyle(fontFamily: "Kano"),)
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 8,),
                    Divider(
                      height: 1,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            );
          },
          itemCount: _inboxListFromSqlite.length,
        padding: EdgeInsets.only(top: 16),
      ),
    );
  }

  _checkSession() async{
    setState(() {
      loadInbox = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if(_result[0]=="valid code"){
      _getInbox();
    }
    else if(_result[0]== "invalid code"){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
          LoginPage()),(Route <dynamic> route) => false);
    }
    else{
      _showSnackBar(_result[0]);
    }
  }

  _getInbox() async{
    var _result = await _inboxApiProvider.getInbox();
    setState(() {
      inboxListFromServer = _result;
    });
    _cekDataMessage();
  }

  _cekDataMessage() async{
    var _result = await dbHelper.checkData(inboxListFromServer);
    _displayInboxList(_result);
//    final allRows = await dbHelper.queryAllRows();
//
//    if(allRows.isNotEmpty){
//      var _result = await dbHelper.checkData(inboxListFromServer);
//      setState(() {
//        _inboxListFromSqlite = allRows;
//        loadInbox = false;
//      });
//      _showSnackBar(_result);
//    }
//    else{
//      var _data;
//      for(var u in inboxListFromServer){
//        _data = {
//          DatabaseHelper.columnIdPesan : u['idPesan'],
//          DatabaseHelper.columnIdMembercard  : u['membershipCardID'],
//          DatabaseHelper.columnTemplateName : u['templateName'],
//          DatabaseHelper.columnTemplateDescription : u['templateDescription'],
//          DatabaseHelper.columnTemplateBodyMessage : u['templateBodyMassage'],
//          DatabaseHelper.columnIsRead : 0
//        };
//        await dbHelper.insert(_data);
//      }
//
//      final _allData = await dbHelper.queryAllRows();
//      setState(() {
//        _inboxListFromSqlite = _allData;
//        loadInbox = false;
//      });
//    }
  }

  _displayInboxList(String message) async{
    SharedPreferences _getIdMember = await SharedPreferences.getInstance();
    var _idMember = _getIdMember.getInt("idMember");

    final allRows = await dbHelper.getInboxByIdMember(_idMember.toString());
    setState(() {
      _inboxListFromSqlite = allRows;
      loadInbox = false;
    });
    for(var i=0; i<_inboxListFromSqlite.length; i++){

    }
    widget.onRefreshBadgeInboxNotif();
  }

  _refreshInboxList() async{
    SharedPreferences _getIdMember = await SharedPreferences.getInstance();
    var _idMember = _getIdMember.getInt("idMember");
    final allRows = await dbHelper.getInboxByIdMember(_idMember.toString());
    setState(() {
      _inboxListFromSqlite = allRows;
    });
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: new Text(text),behavior: SnackBarBehavior.floating,));
  }

}

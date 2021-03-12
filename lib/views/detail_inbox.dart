import 'package:flutter/material.dart';
import 'package:shuguoyinxiang/db/database_helper.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_membership_card_by_email.dart';

import '../dashboard.dart';
import '../login.dart';
class DetailInbox extends StatefulWidget {
  final String title,subtitle,content,idPesan;
  final Function onRefreshBadgeMessageUnread;
  final Function onRefreshInboxList;
  const DetailInbox(
      this.title,
      this.subtitle,
      this.content,
      this.idPesan,
      this.onRefreshBadgeMessageUnread,
      this.onRefreshInboxList
      );

  @override
  _DetailInboxState createState() => _DetailInboxState();
}

class _DetailInboxState extends State<DetailInbox> {

  RetrieveMembershipcardByEmail _retrieveMembershipcardByEmail;
  String hasil;
  var loadData = false;
  final dbHelper = DatabaseHelper.instance;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _retrieveMembershipcardByEmail = RetrieveMembershipcardByEmail();
    getDataMember();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: SafeArea(child: Text("Detail Inbox",style: TextStyle(color: colorBlueDark,fontFamily: "OpenSans"))),
        backgroundColor: Colors.white,
//        actions: <Widget>[
//          IconButton(icon: Icon(FontAwesomeIcons.trashAlt,color: colorBlueDark,), onPressed: (){})
//        ],
        centerTitle: true,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: colorBlueDark),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            }),
      ),
      body:
          loadData
              ?
          Center(child: CircularProgressIndicator())
              :
          Container(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: <Widget>[
                Text(widget.title,style: TextStyle(color: colorBlueDark,fontFamily: "OpenSans")),
                SizedBox(height: 16),
                Text(widget.subtitle,style: TextStyle(color: colorBlueDark,fontFamily: "OpenSans")),
                SizedBox(height: 32),
                Text(hasil,style: TextStyle(color: colorBlueDark,fontFamily: "OpenSans")),
              ],
            ),
          ),
    );
  }

  getDataMember() async{
    setState(() {
      loadData = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if(_result[0]=="valid code"){
      var _result = await _retrieveMembershipcardByEmail.retrieveMembershipCard();
      var memberName = _result['memberName'];
      var contentMessage = widget.content;
      setState(() {
        hasil = contentMessage.replaceAll("member_name", memberName);
        _updateMessage();
        loadData = false;
      });
    }
    else if(_result[0]== "invalid code"){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
          LoginPage()),(Route <dynamic> route) => false);
    }
    else{
      setState(() {
        loadData = false;
      });
      _showSnackBar(_result[0]);
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text),behavior: SnackBarBehavior.floating));
  }

  _updateMessage() async{
    await dbHelper.updateMessage(widget.idPesan);
    widget.onRefreshBadgeMessageUnread();
    widget.onRefreshInboxList();
  }
}

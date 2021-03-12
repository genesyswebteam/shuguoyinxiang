import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_membership_card_by_email.dart';

import '../login.dart';
import 'add_point.dart';
import 'history_point.dart';

const colorBlueDark = const Color(0xff162633);

class MemberPage extends StatefulWidget {
  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  var size;
  RetrieveMembershipcardByEmail _retrieveMembershipcardByEmail;
  bool _loadData = false;
  String _name,_memberCardId,_point;

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  void initState() {
    super.initState();
    _retrieveMembershipcardByEmail = RetrieveMembershipcardByEmail();
    _getDataMember();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Membership Card',style: TextStyle(fontFamily: 'OpenSans',color: colorBlueDark)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorBlueDark),
      ),
      body:
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("img/border_revisi.webp"),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
              Positioned(
                child: IconButton(
                    icon: Icon(Icons.content_copy,color: Colors.white),
                    onPressed: (){
                      Clipboard.setData(new ClipboardData(text: 'Test'));
                      _showSnackBar('Text dicopy');
                    }),
                right: MediaQuery.of(context).size.width/6,
                top:  MediaQuery.of(context).size.height/12 ,
              ),
              Positioned(
                  top: MediaQuery.of(context).size.height/6.3,
                  child: Container(
//                      height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/9.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/4.7),
                          child: Text(
                              _loadData ? '' : '$_name',
                              style: TextStyle(
                                  fontFamily: 'OpenSansBold',
                                  fontSize: 17.5,color: Colors.white
                              )
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/4.7),
                          child: Text(
                              _loadData ? 'Card: #' : 'Card: # $_memberCardId',
                              style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 17.5,color: Colors.white
                              )
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/4.7),
                          child: Text(
                            'Membership Card',
                            style: TextStyle(
                                fontFamily: 'OpenSansBold',
                                fontSize: 17.5,
                                color: Colors.white
                            )
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width/5,
                            top: MediaQuery.of(context).size.height/24,
                          ),
                          child: Row(
                            children: <Widget>[
//                              Expanded(
//                                child:
                                Card(
                                  elevation: 5.0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  color: Colors.grey[600],
                                  child: Container(
                                    height: MediaQuery.of(context).size.height/17,
                                    width: MediaQuery.of(context).size.width/2.8,
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
//                                            padding: EdgeInsets.only(top: 16,bottom: 16),
                                            child: Center(
                                                child: Text(
                                                  'Points',
                                                  style: TextStyle(fontFamily: 'OpenSans',color: Colors.white),)),
                                          ),flex: 5,
                                        ),
                                        Expanded(
                                          child: Container(height: 40,child: VerticalDivider(color: Colors.white)),
                                          flex: 0,
                                        ),
                                        Expanded(
                                          child: Container(
//                                            padding: EdgeInsets.only(top: 16,bottom: 16),
                                            child: Center(child: Text(_loadData ? '' : _point,style: TextStyle(fontFamily: 'OpenSansBold',fontSize: 20,color: Colors.white),)),
                                          ),flex: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
//                                flex: 1,
//                              )

//                              Expanded(
//                                child:
                            SizedBox(width: MediaQuery.of(context).size.width/34,),
                                InkWell(
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset('img/icon_history.webp',color: Colors.white,scale: 37),
                                      Text('History',style: TextStyle(fontFamily: 'OpenSans',color: Colors.white),)
                                    ],
                                  ),
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPointPage()));
                                  },
                                ),
//                                flex: 1,
//                              )
                            ],
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height/24),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Card(
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                color: Colors.white,
                                child: Container(
                                  height: MediaQuery.of(context).size.height/5,
                                  width: MediaQuery.of(context).size.height/5,
                                  child: Center(
                                    child: Container(
                                        margin: EdgeInsets.all(4),
                                        child: Image.asset('img/qr_code.png')),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height/24),
                        Container(
                          child: Center(
                            child: Image.asset('img/barcode.png',width: MediaQuery.of(context).size.width/2.2,),
                          ),
                        )
                      ],
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  _getDataMember() async{

    setState(() {
      _loadData = true;
    });

    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if(_result[0]=="valid code"){
      var _result =  await _retrieveMembershipcardByEmail.retrieveMembershipCard();
      setState(() {
        _name = _result['memberName'];
        _memberCardId = _result['memberCard'];
        _point = _result['points'];
      });

      setState(() {
        _loadData = false;
      });
    }
    else if(_result[0]== "invalid code"){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
          LoginPage()),(Route <dynamic> route) => false);
    }
    else{
      setState(() {
        _loadData = false;
      });
      _showSnackBar(_result[0]);
    }


  }
}

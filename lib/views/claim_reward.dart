import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_claim_list_api_provider.dart';

import '../login.dart';
import 'custom_alert_dialog_claim_reward.dart';
class ClaimReward extends StatefulWidget {
  @override
  _ClaimRewardState createState() => _ClaimRewardState();
}

class _ClaimRewardState extends State<ClaimReward> {

  RetrieveClaimListApiProvider _retrieveClaimListApiProvider;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var loadClaimList = false;

  var historyRewardList = [];
  final GlobalKey<RefreshIndicatorState> _refresh =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _retrieveClaimListApiProvider = RetrieveClaimListApiProvider();
    getClaimList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: loadClaimList
          ?
      Center(child: CircularProgressIndicator())
          :
      RefreshIndicator(
        key: _refresh,
        onRefresh: getClaimList,
        child: ListView.builder(itemBuilder: (context,index){
          DateTime _dateTimeFormat = DateTime.parse(historyRewardList[index]['createdTime']);
          DateFormat _formatted = DateFormat("yyyy MMM dd HH:mm");
          String _dateTime = _formatted.format(_dateTimeFormat);
          return InkWell(
            onTap: (){
              if(historyRewardList[index]['checkClaim'] == "0"){
                _myDialog(historyRewardList[index]);
              }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: Image.asset("img/logo_red_sgyx.webp",scale: 8),
                        ),flex: 2,
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          margin: EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(historyRewardList[index]['itemMasterDescription'],
                                    style: TextStyle(fontFamily: "OpenSans",fontSize: 18)
                                ),
                              ),
                              SizedBox(height: 4,),
                              Container(
                                child: Text(_dateTime,style: TextStyle(fontFamily: "NunitoSans"),),
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
                              Text("",style: TextStyle(fontFamily: "OpenSans",fontSize: 18),),
                              SizedBox(height: 4,),
                              Text("Point : ${historyRewardList[index]['pointRedeem']}",
                                style: TextStyle(fontFamily: "OpenSansBold"),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(
                    height: 1,color: Colors.black,
                  )
                ],
              ),
            ),
          );
        },itemCount: historyRewardList.length,
            padding: EdgeInsets.only(top: 8,left: 8,right: 8,bottom: 8)),
      ),
    );
  }



  Future<void> getClaimList() async{
    setState(() {
      loadClaimList = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if(_result[0]=="valid code"){
      var _result = await _retrieveClaimListApiProvider.getClaimList();
      if(_result['result']){
        historyRewardList = _result["data"];
        historyRewardList.sort((a,b) {
          var aPoint = a['createdTime'];
          var bPoint = b['createdTime'];
          return bPoint.compareTo(aPoint);
        });
        setState(() {
          loadClaimList = false;
        });
      }
      else{
        setState(() {
          loadClaimList = false;
        });
        _showSnackBar(_result['message']);
      }
    }
    else if(_result[0]== "invalid code"){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
          LoginPage()),(Route <dynamic> route) => false);
    }
    else{
      setState(() {
        loadClaimList = false;
      });
      _showSnackBar(_result[0]);
    }

  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  _myDialog(var historyRewardClaim){
    showDialog(
      context: context,
      builder: (context){
        return CustomAlertDialog(
          title: "Insert password",
          pointTransactionId: historyRewardClaim['pointTransactionId'],
          itemRewardID: historyRewardClaim['itemRewardID'],
          noteRedeem: historyRewardClaim['noteRedeem'],
          sendAddress: historyRewardClaim['sendAddress'],
          expiredDate: historyRewardClaim['expiredDate'],
          itemMasterDescription: historyRewardClaim['itemMasterDescription'],
          itemMasterName: historyRewardClaim['itemMasterName'],
          pointRedeem: historyRewardClaim['pointRedeem'],
          points: historyRewardClaim['points'],
          createdBy: historyRewardClaim['createdBy'],
          createdTime: historyRewardClaim['createdTime'],
          id: historyRewardClaim['id'],
          showMessage: _showSnackBar,
        );
      },
    );
  }
}




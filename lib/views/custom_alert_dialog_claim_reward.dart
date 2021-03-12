import 'package:flutter/material.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_outlet_api_provider.dart';
import 'package:shuguoyinxiang/resource/update_claim_reward_api_provider.dart';

import '../dashboard.dart';
import '../login.dart';

class CustomAlertDialog extends StatefulWidget {

  final String title,id,pointTransactionId,itemRewardID,createdBy,createdTime,noteRedeem,sendAddress,
      expiredDate,itemMasterDescription,itemMasterName,pointRedeem,points;

  final ValueChanged<String> showMessage;

  const CustomAlertDialog({Key key, this.title, this.pointTransactionId, this.itemRewardID,
    this.noteRedeem, this.sendAddress, this.expiredDate, this.itemMasterDescription,
    this.itemMasterName, this.pointRedeem, this.points, this.createdBy, this.createdTime, this.id, this.showMessage}) : super(key: key);

  @override
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {

  final _claimReward = GlobalKey<FormState>();
  final _claimRewardPasswordController = TextEditingController();
  var _autoValidate = false;
  RetrieveOutletApiProvider _retrieveOutletApiProvider;
  UpdateClaimRewardApiProvider _updateClaimRewardApiProvider;
  List _listPassword = [];
  var _loadData = false;


  @override
  void initState() {
    super.initState();
    _retrieveOutletApiProvider = RetrieveOutletApiProvider();
    _updateClaimRewardApiProvider = UpdateClaimRewardApiProvider();
    getPassword();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title,style: TextStyle(fontFamily: "OpenSansBold")),
      content: Form(
        key: _claimReward,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration: new InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontFamily: "OpenSans"),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              controller: _claimRewardPasswordController,
              obscureText: true,
              autovalidate: _autoValidate,
              validator: (e) {
                if (e.isEmpty) {
                  return "Can not be empty";
                }else{
                  return null;
                }},
            ),
            SizedBox(height: 16),
            _loadData
                ?
            SizedBox(height: 0.0,width: 0.0)
                :
            _listPassword.isEmpty
                ?
            Text("*Failed get data please close and tap again",style: TextStyle(fontFamily: "OpenSans",color: Colors.red))
                :
            SizedBox(height: 0.0,width: 0.0)
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text("Close",style: TextStyle(fontFamily: "NunitoSans",color: colorBlueDark))),
        FlatButton(
            onPressed: (){
              check();
            },
            child: _loadData ? CircularProgressIndicator() : Text("Proceed",style: TextStyle(fontFamily: "NunitoSans",color: colorBlueDark))),
      ],
    );
  }

  check() {
    final form = _claimReward.currentState;
    if (form.validate()) {
      form.save();
      checkPassword();
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  getPassword() async{
    setState(() {
      _loadData = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if(_result[0]=="valid code"){
      var _result = await _retrieveOutletApiProvider.retrieveOutletPassword();
      if(_result['result']){
        _listPassword = _result['data'];
        setState(() {
          _loadData = false;
        });
      }
      else{
        setState(() {
          _loadData = false;
        });
      }
    }
    else if(_result[0]== "invalid code"){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
          LoginPage()),(Route <dynamic> route) => false);
    }
    else{
      setState(() {
        _loadData = false;
      });
    }
  }

  checkPassword() async{
    setState(() {
      _loadData = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if(_result[0]=="valid code"){
      if(_listPassword.contains(_claimRewardPasswordController.text)){
        var _result = await _updateClaimRewardApiProvider.updateClaimReward(widget.id,widget.pointTransactionId,
            widget.itemRewardID, widget.createdBy, widget.createdTime, widget.noteRedeem,
            widget.sendAddress, widget.expiredDate, widget.itemMasterDescription,
            widget.itemMasterName, widget.pointRedeem, widget.points);

        if(_result['result']){
          widget.showMessage(_result['data'].toString().substring(1,21));
          Navigator.pop(context);
        }
        else{
          widget.showMessage(_result['message']);
          Navigator.pop(context);
        }
      }
      else{
        setState(() {
          _loadData = false;
        });
      }
    }
    else if(_result[0]== "invalid code"){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
          LoginPage()),(Route <dynamic> route) => false);
    }
    else{
      setState(() {
        _loadData = false;
      });
      widget.showMessage("Failed claim reward please check connection");
      Navigator.pop(context);
    }
  }
}
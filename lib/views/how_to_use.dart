import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:shuguoyinxiang/resource/retrieve_image_how_to_use.dart';

import '../dashboard.dart';

class HowToUse extends StatefulWidget {
  final bool isFromRegister;

  const HowToUse({this.isFromRegister});
  @override
  _HowToUseState createState() => _HowToUseState();
}

class _HowToUseState extends State<HowToUse> {
  bool _loadData = false;
  List<Map> _listData = [];
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async{
    setState(() {
      _loadData = true;
    });
    Map _data = await retrieveImageHowToUse();
    if(_data['result']){
      print(_data);
      for(int i=0; i < _data['data'].length; i++){
        _listData.add(
          {
            "id":_data['data'][i]['idImage'],
            "picture":Image.network(_data['data'][i]['picture'],
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            )
          }
        );
      }
      setState(() {
        _loadData = false;
      });
    }
    else{
      _showSnackBar(_data['message']);
      setState(() {
        _loadData = false;
      });
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(text), behavior: SnackBarBehavior.floating));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("How to use",style: TextStyle(color: colorBlueDark,fontFamily: "Kano")),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorBlueDark),
      ),
      body: _loadData ?
      Center(
          child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey))
      )
          :
      SafeArea(
        child: Swiper(
          itemCount: _listData.length,
          itemBuilder: (context,i){
            return widget.isFromRegister
                ?
            Container(
              child: Stack(
                children: <Widget>[
                  _listData[i]['picture'],
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashBoard(isRegister: true)));
                        },
                        child: Image.asset("img/close_button.webp",width: 27,height: 27),
                      ),
                    ),
                  )
                ],
              ),
            )
                :
            Container(
              child: _listData[i]['picture'],
            );
          },
          autoplay: false,
          loop: false,
        ),
      ),
    );
  }
}

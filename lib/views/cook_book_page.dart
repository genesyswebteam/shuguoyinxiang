import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_image_cook_book_and_catering_service.dart';

import '../dashboard.dart';
import '../login.dart';

class CookBookPage extends StatefulWidget {
  @override
  _CookBookPageState createState() => _CookBookPageState();
}

class _CookBookPageState extends State<CookBookPage> {
  RetrieveCookBookCateringService _retrieveCookBookCateringService;
  List<String> _listCookBook = [];

  var _loadImageCookBook = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      appBar: AppBar(
        title: SafeArea(child: Text("Cook Book",style: TextStyle(color: colorBlueDark,fontFamily: "Kano"))),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorBlueDark),
      ),
      body:_loadImageCookBook
          ?
      Center(
        child: CircularProgressIndicator(),
      )
          :
      Column(
        children: <Widget>[
          Image.asset("img/JudulCookbook.webp"),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 37,
                vertical: MediaQuery.of(context).size.height/77
              ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: MediaQuery.of(context).size.height/50,
                    mainAxisSpacing: MediaQuery.of(context).size.height/50
                ),
                itemBuilder: (BuildContext context, int index){
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                        imageUrl: _listCookBook[index],
                        imageBuilder: (context,imageProvider){
                          return Container(
                            decoration:BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: imageProvider,
                              ),
                            ),
                          );
                        },
                        placeholder: (context,url) {
                          return Center(
                              child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(colorBlueDark)
                              )
                          );
                        }
                    ),
                  );
                },
                itemCount:_listCookBook.length
            ),
          ),
        ],
      )
//      ListView.builder(
//        itemBuilder: (context,index){
//          return Image.network(_listCookBook[index]);
//        },
//        itemCount: _listCookBook.length,
//      )
    );
  }

  @override
  void initState() {
    super.initState();
     _retrieveCookBookCateringService = RetrieveCookBookCateringService();
     getImageCookBook();
  }

  Future<void> getImageCookBook() async{
    setState(() {
      _loadImageCookBook = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if(_result[0]=="valid code"){
      var _result = await _retrieveCookBookCateringService.getImageCookBookCateringService();
      for(int i=0; i<_result['data'].length;i++){
        if(_result['data'][i]['type'] == "2"){
          _listCookBook.add(_result['data'][i]['picture']);
        }
      }
      setState(() {
        _loadImageCookBook = false;
      });
    }
    else if(_result[0]== "invalid code"){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
          LoginPage()),(Route <dynamic> route) => false);
    }
    else{
      setState(() {
        _loadImageCookBook = false;
      });
      _showSnackBar(_result[0]);
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text),behavior: SnackBarBehavior.floating));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuguoyinxiang/resource/check_login.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_image_cook_book_and_catering_service.dart';

import '../login.dart';
import 'catering_service_page.dart';
import 'cook_book_page.dart';
import 'list_category_product.dart';
import 'outlet_page.dart';
import 'promo_page.dart';

const colorBlueDark = const Color(0xff162633);

class HomePage extends StatefulWidget {
  final bool isRegister;
  final String password;

  const HomePage({this.isRegister, this.password});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  RetrieveCookBookCateringService _retrieveCookBookCateringService;
  List<String> _listImageSlider = [];
  var _loadImageSlider = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _checkLogin = CheckLogin();
  CheckSessionAPI _checkSessionAPI = CheckSessionAPI();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height / 2.7,
              width: MediaQuery.of(context).size.width,
              child: _loadImageSlider
                  ?
              Center(child: CircularProgressIndicator())
                  :
              buildSwiper()
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 50,
          ),
          Container(
            margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.height / 50,
                right: MediaQuery.of(context).size.height / 50),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PromoPage()));
                    },
                    child: ClipRRect(
                      child: Stack(
                        children: <Widget>[
                          Image.asset(
                            'img/promotion_revisi2.webp',
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height / 6,
                            width: MediaQuery.of(context).size.width / 2,
                          ),
                          Positioned(
                            child: Text('What\'s New',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontFamily: 'Kano',fontWeight: FontWeight.bold)),
                            right: 8,
                            bottom: 8,
                          )
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                    flex: 5,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListCategoryProduct()),
                        );
                      },
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height / 6,
                            width: MediaQuery.of(context).size.width / 2,
                            child: ClipRRect(
                              child: Image.asset(
                                'img/product_revisi2.webp',
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          Positioned(
                            child: Text('Products',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontFamily: 'Kano',fontWeight: FontWeight.bold)),
                            left: 8,
                            bottom: 8,
                          )
                        ],
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 50,
          ),
          Container(
            margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.height / 50,
                right: MediaQuery.of(context).size.height / 50),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CookBookPage()));
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height / 7,
                          width: MediaQuery.of(context).size.width / 2,
                          child: ClipRRect(
                            child: Image.asset(
                              'img/cook_book.webp',
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        Positioned(
                          child: Text('Cook\nBook',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'Kano',fontWeight: FontWeight.bold)),
                          left: 8,
                          bottom: 8,
                        )
                      ],
                    ),
                  )
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.height / 50,
                ),
                Expanded(
                    flex: 3,
                    child: InkWell(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height / 7,
                            width: MediaQuery.of(context).size.width / 2,
                            child: ClipRRect(
                              child: Image.asset(
                                'img/outlet_revisi2.webp',
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          Positioned(
                            child: Text('Outlets',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontFamily: 'Kano',fontWeight: FontWeight.bold)),
                            left: 8,
                            bottom: 8,
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OutletPage()));
                      },
                    )),
                SizedBox(
                  width: MediaQuery.of(context).size.height / 50,
                ),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CateringServicePage()));
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height / 7,
                          width: MediaQuery.of(context).size.width / 2,
                          child: ClipRRect(
                            child: Image.asset(
                              'img/catering_service_revisi2.webp',
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        Positioned(
                          child: Text('Delivery\nService',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'Kano',fontWeight: FontWeight.bold)),
                          left: 8,
                          bottom: 8,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _retrieveCookBookCateringService = RetrieveCookBookCateringService();
    _checkIdMember();
  }

  _checkIdMember() async{
    setState(() {
      _loadImageSlider = true;
    });
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    var _idMember = _preferences.getInt("idMember");
    if(_idMember != null){
      _checkSession();
    }
    else{
      getImageCateringService();
    }
  }

  _checkSession() async{
    if(widget.isRegister){
      var _result = await _checkLogin.loginCheck(widget.password);
      SharedPreferences _preferences = await SharedPreferences.getInstance();
      if(_result['result']){
        _preferences.setString("token", _result['data']);
        getImageCateringService();
      }
      else{
        _showSnackBar(_result['message']);
      }
    }
    else{
      var _result = await _checkSessionAPI.checkSessionAfterLogin();
      if(_result[0]=="valid code"){
        getImageCateringService();
      }
      else if(_result[0]== "invalid code"){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>
            LoginPage()),(Route <dynamic> route) => false);
      }
      else{
        setState(() {
          _loadImageSlider = false;
        });
        _showSnackBar(_result[0]);
      }
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: new Text(text),behavior: SnackBarBehavior.floating,));
  }

  Widget buildSwiper() {
    return Swiper(
//      outer: false,
      itemBuilder: (context, i) {
        return Image.network(_listImageSlider[i], fit: BoxFit.fill,filterQuality: FilterQuality.medium,);
      },
      autoplay: true,
      autoplayDelay: 5000,
      duration: 1500,
      pagination: new SwiperPagination(margin: new EdgeInsets.all(5.0)),
      itemCount: _listImageSlider.length,
    );
  }

  getImageCateringService() async{
    var _result = await _retrieveCookBookCateringService.getImageCookBookCateringService();
    for(int i=0; i<_result['data'].length;i++){
      if(_result['data'][i]['type'] == "0"){
        _listImageSlider.add(_result['data'][i]['picture']);
      }
    }
    setState(() {
      _loadImageSlider = false;
    });
  }
}

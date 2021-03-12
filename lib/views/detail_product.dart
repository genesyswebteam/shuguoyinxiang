import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shuguoyinxiang/resource/retrieve_detail_premium.dart';

const colorBlueDark = const Color(0xff162633);

class DetailProductPage extends StatefulWidget {
  final String idCategory,name;
  const DetailProductPage(this.idCategory, this.name);
  @override
  _DetailProductPageState createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
  RetrieveDetailPremiumMenu _retrieveDetailPremiumMenu;
  var _loadPremiumMenuPage = false;
  var _imageUrl = "";

  @override
  void initState() {
    super.initState();
    _retrieveDetailPremiumMenu = RetrieveDetailPremiumMenu();
    _getDetailPremiumMenu();
  }

  _getDetailPremiumMenu() async{
    setState(() {
      _loadPremiumMenuPage = true;
    });
    int id = int.parse(widget.idCategory);
    var _result = await _retrieveDetailPremiumMenu.getDetailPremiumMenu(id);
    if(_result['result']){
      setState(() {
        _imageUrl = _result['data'];
      });
    }
    setState(() {
      _loadPremiumMenuPage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: colorBlueDark),
          title: Text(
            widget.name,
            style: TextStyle(fontFamily: 'OpenSans', color: colorBlueDark),
          ),
        ),
        body:
//        Image.asset("img/edited.webp",
////          fit: BoxFit.fill,
//          width: MediaQuery.of(context).size.width,
//          height: MediaQuery.of(context).size.height,
//          ),


        _loadPremiumMenuPage
            ?
        Center(child: CircularProgressIndicator())
            :
        Image.network(
          _imageUrl,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.fill,
        )
//        Container(
//          height: MediaQuery.of(context).size.height,
//          width: MediaQuery.of(context).size.width,
//          child: ListView(
//            children: <Widget>[
//              Hero(
//                  child: Material(
//                    child: CachedNetworkImage(
//                      imageUrl: widget.picture,
//                      fit: BoxFit.contain,
//                      height: MediaQuery.of(context).size.height/3
//                    )
//                  ),
//                tag: widget.title,
//              ),
//              Row(
//                children: <Widget>[
//                  Expanded(
//                    child: Container(
//                      decoration: BoxDecoration(
//                        color: Colors.white,
//                      ),
//                      height: MediaQuery.of(context).size.height / 10,
//                      child: Center(
//                        child: Text('Product Detail',
//                            style: TextStyle(
//                                fontFamily: 'OpenSans', fontSize: 20)),
//                      ),
//                    ),
//                    flex: 5,
//                  ),
//                  Expanded(
//                    child: Container(
//                      decoration: BoxDecoration(
//                        color: const Color(0xffF0F0F0),
//                      ),
//                      height: MediaQuery.of(context).size.height / 10,
//                    ),
//                    flex: 5,
//                  ),
//                ],
//              ),
//              SizedBox(height: MediaQuery.of(context).size.height/24,),
//              Container(
//                margin: EdgeInsets.only(
//                    left: MediaQuery.of(context).size.width / 24,
//                  bottom: MediaQuery.of(context).size.height / 50
//                ),
//                child: Row(
//                  mainAxisSize: MainAxisSize.max,
//                  mainAxisAlignment: MainAxisAlignment.start,
//                  children: <Widget>[
//                    Text(widget.title,style: TextStyle(fontFamily: 'OpenSans')),
//                  ],
//                ),
//              ),
//              Container(
//                  margin: EdgeInsets.symmetric(
//                    horizontal: MediaQuery.of(context).size.width / 24,
//                    vertical: MediaQuery.of(context).size.height / 50,
//                  ),
//                  child: Text(
//                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit,sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.Excepteur sint occaecat cupidatat non proident, '
//                    'sunt in culpa qui officia deserunt mollit anim id est laborum.',
//                    style: TextStyle(fontFamily: 'OpenSans'),
//                  )
//              )
//            ],
//          ),
//        )
    );
  }
}

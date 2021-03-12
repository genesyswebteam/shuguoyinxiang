import 'package:flutter/material.dart';
import 'package:shuguoyinxiang/resource/check_session_api_provider.dart';
import 'package:shuguoyinxiang/resource/retrieve_category_all.dart';
import 'dart:ui' as ui;
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

import '../login.dart';
import 'list_product.dart';

const colorBlueDark = const Color(0xff162633);

class ListCategoryProduct extends StatefulWidget {
  @override
  _ListCategoryProductState createState() => _ListCategoryProductState();
}

class _ListCategoryProductState extends State<ListCategoryProduct> {
  var _categoryProductAll = [];
  RetrieveCategoryAll _retrieveCategoryAll;
  var _isLoadData = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  getData() async {
    var _result = await _retrieveCategoryAll.getCategoryAll();
    if (_result['status']) {
      setState(() {
        _categoryProductAll = _result['categoryList'];
        _isLoadData = false;
      });
    } else {
      _showSnackBar(_result['message']);
    }
  }

  @override
  void initState() {
    super.initState();
    _retrieveCategoryAll = RetrieveCategoryAll();
    _checkSession();
  }

  _checkSession() async {
    setState(() {
      _isLoadData = true;
    });
    CheckSessionAPI _checkSession = CheckSessionAPI();
    var _result = await _checkSession.checkSessionAfterLogin();
    if (_result[0] == "valid code") {
      getData();
    } else if (_result[0] == "invalid code") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
    } else {
      setState(() {
        _isLoadData = false;
      });
      _showSnackBar(_result[0]);
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(text), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Products',
            style: TextStyle(fontFamily: 'OpenSans', color: colorBlueDark)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorBlueDark),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("img/bg_products_menu.webp"),
            fit: BoxFit.fill,
          ),
        ),
        child: _isLoadData
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemBuilder: (context, index) {
            return InkWell(
              child: Container(
                height: MediaQuery.of(context).size.height / 8.5,
                child: Center(
                  child: Text(_categoryProductAll[index]['codeCategory'],
                      style: TextStyle(
                          fontFamily: "OpenSansBold",
                          fontSize: 22,
                          color: Colors.white)),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListProduct(
                          _categoryProductAll[index]['codeCategory'],
                          _categoryProductAll[index]['idCategory'])),
                );
              },
            );
          },
          itemCount: _categoryProductAll.length,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 36),
        ),
      ),
    );
  }
}

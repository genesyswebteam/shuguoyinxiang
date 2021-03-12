import 'package:flutter/material.dart';

import '../dashboard.dart';

class AboutLoyaltyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Loyalty",style: TextStyle(color: colorBlueDark,fontFamily: "Kano")),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorBlueDark),
      ),
      body: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          Image.asset('img/about_loyalty.webp',width: MediaQuery.of(context).size.width)
        ],
      ),
    );
  }
}

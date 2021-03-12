import 'package:flutter/material.dart';

import '../dashboard.dart';
import 'add_point_history.dart';
import 'claim_reward.dart';

class HistoryPointPage extends StatefulWidget {
  @override
  _HistoryPointPageState createState() => _HistoryPointPageState();
}

class _HistoryPointPageState extends State<HistoryPointPage> with SingleTickerProviderStateMixin{
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    )..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Point History",style: TextStyle(fontFamily: "OpenSans",color: colorBlueDark)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: colorBlueDark),
        bottom: TabBar(
          indicatorColor: colorBlueDark,
          labelStyle: TextStyle(fontFamily: "OpenSans"),
          labelColor: colorBlueDark,
          tabs: <Tab>[
            new Tab(text: "Add Point"),
            new Tab(text: "Claim reward"),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          AddPointHistory(),
          ClaimReward(),
        ],
      ),
    );
  }
}

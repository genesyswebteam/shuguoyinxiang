import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuguoyinxiang/login.dart';
import 'package:shuguoyinxiang/views/about_loyalty.dart';
import 'package:shuguoyinxiang/views/how_to_use.dart';
import 'package:url_launcher/url_launcher.dart';
import 'class_font/icon_add_point_icons.dart';
import 'class_font/icon_id_card_icons.dart';
import 'class_font/my_flutter_app_icons.dart';
import 'class_font/custom_icon_icons.dart';
import 'db/database_helper.dart';
import 'resource/inbox_api_provider.dart';
import 'resource/retrieve_membership_card_by_email.dart';
import 'views/add_point.dart';
import 'views/contact_us_page.dart';
import 'views/home_page.dart';
import 'views/inbox_page.dart';
import 'views/member_page.dart';
import 'views/reward_page.dart';
import 'package:flutter/services.dart';

import 'views/update_membership_card.dart';

const colorBlueDark = const Color(0xff162633);

class DashBoard extends StatefulWidget {
  final bool isRegister;

  const DashBoard({this.isRegister});
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int _selectedIndex = 0;
  int _lastIndex = 0;
  String _nameUserDrawer, _emailUserDrawer;
  var loadDataPocess = false;
  var imageUrl;
  var loadInbox = false;
  int _messageUnread = 0;
  final dbHelper = DatabaseHelper.instance;
  RetrieveMembershipcardByEmail _retrieveMembershipcardByEmail;
  InboxApiProvider _inboxApiProvider;
  String _pass = "";

  void _onItemTapped(int index) {
    if (index != 2 && index != 4) {
      setState(() {
        _selectedIndex = index;
        _lastIndex = index;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void changeIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    imageCache.clear();
    _inboxApiProvider = InboxApiProvider();
//    _getInboxList();
    getPhotoDrawer();
  }

  getPhotoDrawer() async {
    setState(() {
      loadDataPocess = true;
    });

    _retrieveMembershipcardByEmail = RetrieveMembershipcardByEmail();
    var _result = await _retrieveMembershipcardByEmail.retrieveMembershipCard();
    int idMember = int.parse(_result['idMember']);
    setState(() {
      _pass = _result['password'];
    });
    _savePref(idMember, _result['memberCard']);

    setState(() {
      _nameUserDrawer = _result['memberName'];
      _emailUserDrawer = _result['email'];
    });

    if (_result['imageUser'] != "") {
      setState(() {
        imageUrl = _result['imageUser'];
      });
    }

    setState(() {
      loadDataPocess = false;
    });
    _getInboxList();
  }

  _savePref(int idMember, String memberCard) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("idMember", idMember);
      preferences.setString("memberCard", memberCard);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      HomePage(isRegister: widget.isRegister, password: _pass),
      InboxPage(onRefreshBadgeInboxNotif: _getMessageUnread),
      AddPoint(changeIndex, _lastIndex),
      RewardPage(onRefreshBadgeNotif: _refreshAfterAddAndClaim),
      ContactUsPage(changeIndex, _lastIndex),
    ];

    return Stack(
      children: <Widget>[
        Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("img/bg_home.webp"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: _selectedIndex == 0
              ? AppBar(
            iconTheme: IconThemeData(color: colorBlueDark),
            leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                }),
            backgroundColor: Colors.white,
            title: Container(
              child: Image.asset(
                'img/logo_red_sgyx.webp',
                scale: 12,
              ),
              margin: EdgeInsets.only(top: 2, bottom: 2),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                  icon: Icon(IconIdCard.id_card),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MemberPage()));
                  })
            ],
          )
              : null,
          body: loadDataPocess
              ? Center(child: CircularProgressIndicator())
              : Container(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: loadInbox
              ? null
              :
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.home),
                title: Text(
                  'Home',
                  style: TextStyle(fontFamily: 'Kano'),
                ),
              ),
              BottomNavigationBarItem(
                icon: _messageUnread != 0
                    ? Stack(
                  children: <Widget>[
                    Icon(MyFlutterApp.inbox),
                    Positioned(
                      right: 0,
                      child: new Container(
                        padding: EdgeInsets.all(2.1),
                        decoration: new BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 13,
                          minHeight: 13,
                        ),
                        child: new Text(
                          '$_messageUnread',
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                )
                    : Icon(MyFlutterApp.inbox),
                title:
                Text('Inbox', style: TextStyle(fontFamily: 'Kano')),
              ),
              BottomNavigationBarItem(
                icon: Center(child: Icon(IconAddPoint.pluss,size: 42,color: Color(0xffe9353c))),
                title: Text('', style: TextStyle(fontFamily: 'Kano')),
              ),
              BottomNavigationBarItem(
                icon: Icon(MyFlutterApp.card_giftcard),
                title:
                Text('Reward', style: TextStyle(fontFamily: 'Kano')),
              ),
              BottomNavigationBarItem(
                icon: Icon(CustomIcon.contact_us),
                title: Text('Contact us',
                    style: TextStyle(fontFamily: 'Kano')),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: colorBlueDark,
            onTap: _onItemTapped,
            unselectedItemColor: Colors.grey[600],
            showUnselectedLabels: true,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          // BottomAppBar(
          //   // color: Colors.transparent,
          //   child: BottomNavigationBar(
          //     type: BottomNavigationBarType.fixed,
          //     items: [
          //       BottomNavigationBarItem(
          //         icon: Icon(FontAwesomeIcons.home),
          //         title: Text(
          //           'Home',
          //           style: TextStyle(fontFamily: 'Kano'),
          //         ),
          //       ),
          //       BottomNavigationBarItem(
          //         icon: _messageUnread != 0
          //             ? Stack(
          //           children: <Widget>[
          //             Icon(MyFlutterApp.inbox),
          //             Positioned(
          //               right: 0,
          //               child: new Container(
          //                 padding: EdgeInsets.all(2.1),
          //                 decoration: new BoxDecoration(
          //                   color: Colors.red,
          //                   borderRadius: BorderRadius.circular(6),
          //                 ),
          //                 constraints: BoxConstraints(
          //                   minWidth: 13,
          //                   minHeight: 13,
          //                 ),
          //                 child: new Text(
          //                   '$_messageUnread',
          //                   style: new TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 8,
          //                   ),
          //                   textAlign: TextAlign.center,
          //                 ),
          //               ),
          //             )
          //           ],
          //         )
          //             : Icon(MyFlutterApp.inbox),
          //         title:
          //         Text('Inbox', style: TextStyle(fontFamily: 'Kano')),
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Center(child: Icon(IconAddPoint.pluss,size: 42,color: Color(0xffe9353c))),
          //         title: Text('', style: TextStyle(fontFamily: 'Kano')),
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(MyFlutterApp.card_giftcard),
          //         title:
          //         Text('Reward', style: TextStyle(fontFamily: 'Kano')),
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(CustomIcon.contact_us),
          //         title: Text('Contact us',
          //             style: TextStyle(fontFamily: 'Kano')),
          //       ),
          //     ],
          //     currentIndex: _selectedIndex,
          //     selectedItemColor: colorBlueDark,
          //     onTap: _onItemTapped,
          //     unselectedItemColor: Colors.grey[600],
          //     showUnselectedLabels: true,
          //     backgroundColor: Colors.transparent,
          //     elevation: 0.0,
          //   ),
          //   shape: CircularNotchedRectangle(),
          // ),
          drawer: Drawer(
            child: Column(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(loadDataPocess ? '' : _nameUserDrawer,
                      style:
                      TextStyle(color: Colors.black, fontFamily: "Kano")),
                  accountEmail: Text(loadDataPocess ? '' : _emailUserDrawer,
                      style:
                      TextStyle(color: Colors.black, fontFamily: 'Kano')),
                  currentAccountPicture: InkWell(
                    child: CircleAvatar(
                      backgroundImage: loadDataPocess
                          ? AssetImage(
                        'img/akun_user.webp',
                      )
                          : setImageUser(),
                      backgroundColor: Colors.white,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateMembershipCard(
                                  onRefreshData: getPhotoDrawer)));
                    },
                  ),
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [Colors.grey[400], Colors.white])),
                ),
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListTile(
                    leading: Icon(Icons.collections_bookmark),
                    title: Text('About Our Loyalty Programme'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AboutLoyaltyPage()));
                    },
                  ),
                ),
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListTile(
                    leading: Icon(Icons.book),
                    title: Text('How to use'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HowToUse(isFromRegister: false,)));
                      // Navigator.pop(context);
                    },
                  ),
                ),
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListTile(
                    leading: Icon(Icons.security),
                    title: Text('Privacy Policy'),
                    onTap: () {
                      _launchURL();
                    },
                  ),
                ),
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListTile(
                    leading: Icon(Icons.input),
                    title: Text('Logout'),
                    onTap: () {
                      _logOut();
                    },
                  ),
                ),
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //     onPressed: (){
          //       Navigator.push(context, MaterialPageRoute(builder: (context) => AddPoint()));
          //     },
          //   backgroundColor: Colors.white,
          //   child: Icon(IconAddPoint.pluss,color: Color(0xffe9353c),size: 33),
          //   // backgroundColor: Colors.transparent,
          // ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        )
      ],
    );
//      Stack(
//      children: <Widget>[
//        Container(
//          decoration:new BoxDecoration(
//            image: new DecorationImage(
//              image: new AssetImage("img/home.webp"),
//              fit: BoxFit.cover,
//            ),
//          ),
//        ),
//        Scaffold(
//          key: _scaffoldKey,
////          backgroundColor: Colors.transparent,
//          appBar: _selectedIndex == 0 ?
//          AppBar(
//            iconTheme: IconThemeData(color: colorBlueDark),
//            leading: IconButton(
//                icon: Icon(Icons.menu),
//                onPressed: (){
//                  _scaffoldKey.currentState.openDrawer();
//                }),
//            backgroundColor: Colors.white,
//            title: Container(
//              child: Image.asset('img/logo_red_sgyx.webp',scale: 12,),
//              margin: EdgeInsets.only(top: 2,bottom: 2),
//            ),
//            centerTitle: true,
//            actions: <Widget>[
//              IconButton(icon: Icon(IconIdCard.id_card), onPressed: (){
//                Navigator.push(context, MaterialPageRoute(builder: (context) => MemberPage()));
//              })
//            ],
//          ) : null,
//          body:loadDataPocess
//              ?
//          Center(child: CircularProgressIndicator())
//              :
//          Container(
//            child: _widgetOptions.elementAt(_selectedIndex),
//          ),
//          bottomNavigationBar:
//          loadInbox
//              ?
//          null
//              :
//          BottomNavigationBar(
//            type: BottomNavigationBarType.fixed ,
//            items: [
//              BottomNavigationBarItem(
//                icon: Icon(FontAwesomeIcons.home),
//                title: Text('Home',style: TextStyle(fontFamily: 'Kano'),),
//              ),
//              BottomNavigationBarItem(
//                icon: _messageUnread != 0
//                    ?
//                Stack(
//                  children: <Widget>[
//                    Icon(MyFlutterApp.inbox),
//                    Positioned(
//                      right: 0,
//                      child: new Container(
//                        padding: EdgeInsets.all(2.1),
//                        decoration: new BoxDecoration(
//                          color: Colors.red,
//                          borderRadius: BorderRadius.circular(6),
//                        ),
//                        constraints: BoxConstraints(
//                          minWidth: 13,
//                          minHeight: 13,
//                        ),
//                        child: new Text(
//                          '$_messageUnread',
//                          style: new TextStyle(
//                            color: Colors.white,
//                            fontSize: 8,
//                          ),
//                          textAlign: TextAlign.center,
//                        ),
//                      ),
//                    )
//                  ],
//                ) : Icon(MyFlutterApp.inbox),
//                title: Text('Inbox',style: TextStyle(fontFamily: 'Kano')),
//              ),
//              BottomNavigationBarItem(
//                icon: Icon(IconAddPoint.pluss),
//                title: Text('Add',style: TextStyle(fontFamily: 'Kano')),
//              ),
//              BottomNavigationBarItem(
//                icon: Icon(MyFlutterApp.card_giftcard),
//                title: Text('Reward',style: TextStyle(fontFamily: 'Kano')),
//              ),
//              BottomNavigationBarItem(
//                icon: Icon(CustomIcon.contact_us),
//                title: Text('Contact us',style: TextStyle(fontFamily: 'Kano')),
//              ),
//            ],
//            currentIndex: _selectedIndex,
//            selectedItemColor: colorBlueDark,
//            onTap: _onItemTapped,
//            unselectedItemColor: Colors.grey[600],
//            showUnselectedLabels: true,
//            backgroundColor: Colors.transparent,
//            elevation: 0.0,
//          ),
//          drawer: Drawer(
//            child: Column(
//              children: <Widget>[
//                UserAccountsDrawerHeader(
//                  accountName: Text(loadDataPocess ? '' : _nameUserDrawer,
//                      style: TextStyle(
//                          color: Colors.black,fontFamily: "Kano"
//                      )
//                  ),
//                  accountEmail: Text( loadDataPocess ? '' : _emailUserDrawer,
//                      style: TextStyle(
//                          color: Colors.black,
//                          fontFamily: 'Kano'
//                      )
//                  ),
//                  currentAccountPicture:
//                  InkWell(
//                    child: CircleAvatar(
//                      backgroundImage:
//                      loadDataPocess
//                          ?
//                      AssetImage('img/akun_user.webp',)
//                          :
//                      setImageUser(),
//                      backgroundColor: Colors.white,
//                    ),
//                    onTap: (){
//                      Navigator.push(context, MaterialPageRoute(
//                          builder: (context) => UpdateMembershipCard(
//                              onRefreshData: getPhotoDrawer)));
//                    },
//                  ),
//                  margin: EdgeInsets.zero,
//                  decoration: BoxDecoration(
//                      gradient: LinearGradient(
//                          begin: Alignment.bottomLeft,
//                          end: Alignment.topRight,
//                          colors: [Colors.grey[400], Colors.white]
//                      )),
//                ),
//                MediaQuery.removePadding(
//                  context: context,
//                  removeTop: true,
//                  child: ListTile(
//                    leading: Icon(Icons.security),
//                    title: Text('Privacy Policy'),
//                    onTap: () {
//                      _launchURL();
//                    },
//                  ),
//                ),
//              ],
//            ),
//          ),
//        )
//      ],
//    );
  }

  setImageUser() {
    if (imageUrl != null) {
      return NetworkImage(imageUrl);
    } else {
      return AssetImage('img/akun_user.webp');
    }
  }

  _getInboxList() async {
    setState(() {
      loadInbox = true;
    });
    final _getMessageFromSqlite = await dbHelper.queryAllRows();
    if (_getMessageFromSqlite.isEmpty) {
      var _inboxDataFromServer = await _inboxApiProvider.getInbox();
      var _data;
      for (var u in _inboxDataFromServer) {
        _data = {
          DatabaseHelper.columnIdPesan: u['idPesan'],
          DatabaseHelper.columnIdMembercard: u['membershipCardID'],
          DatabaseHelper.columnTemplateName: u['templateName'],
          DatabaseHelper.columnTemplateDescription: u['templateDescription'],
          DatabaseHelper.columnTemplateBodyMessage: u['templateBodyMassage'],
          DatabaseHelper.columnIsRead: 0
        };
        await dbHelper.insert(_data);
      }
      _getMessageUnread();
    } else {
      SharedPreferences _getIdMember = await SharedPreferences.getInstance();
      var _cekData = await dbHelper
          .getInboxByIdMember(_getIdMember.getInt("idMember").toString());
      if (_cekData.isEmpty) {
        var _inboxDataFromServer = await _inboxApiProvider.getInbox();
        var _data;
        for (var u in _inboxDataFromServer) {
          _data = {
            DatabaseHelper.columnIdPesan: u['idPesan'],
            DatabaseHelper.columnIdMembercard: u['membershipCardID'],
            DatabaseHelper.columnTemplateName: u['templateName'],
            DatabaseHelper.columnTemplateDescription: u['templateDescription'],
            DatabaseHelper.columnTemplateBodyMessage: u['templateBodyMassage'],
            DatabaseHelper.columnIsRead: 0
          };
          await dbHelper.insert(_data);
        }
        _getMessageUnread();
      } else {
        _getMessageUnread();
      }
    }
  }

  _getMessageUnread() async {
    SharedPreferences _getIdMember = await SharedPreferences.getInstance();
    var _idMember = _getIdMember.getInt("idMember");
    var _resultMessageUnread =
    await dbHelper.getMessageUnread(_idMember.toString());
    setState(() {
      _messageUnread = _resultMessageUnread;
      loadInbox = false;
    });
  }

  _refreshAfterAddAndClaim() async {
    var _getInboxFromServer = await _inboxApiProvider.getInbox();
    await dbHelper.checkData(_getInboxFromServer);
    _getMessageUnread();
  }

  _launchURL() async {
    const url = 'http://shuguoyinxianghotpot.com/privacy.policy.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _logOut() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    _preferences.getKeys();
    for (String key in _preferences.getKeys()) {
      if (key != "isFirst") {
        _preferences.remove(key);
      }
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
  }
}

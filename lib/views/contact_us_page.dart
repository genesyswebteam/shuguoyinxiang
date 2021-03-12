import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  final Function(int) index;
  final int receiveIndex;
  const ContactUsPage(this.index, this.receiveIndex);
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    _launchURL();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      backToPage();
    }
  }

  _launchURL() async {
    const url = 'https://shuguoyinxiang.contactin.bio/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  backToPage(){
    widget.index(widget.receiveIndex);
  }
}
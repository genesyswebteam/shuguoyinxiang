import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';

class SliderShowcase extends StatefulWidget {
  final String email;

  const SliderShowcase({Key key, this.email}) : super(key: key);

  @override
  _SliderShowcaseState createState() => _SliderShowcaseState();
}

class _SliderShowcaseState extends State<SliderShowcase> {

  List<Slide> slides = new List();

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: buildSwiper(_height),
      ),
    );
  }


  _savePrefSessionValue() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", 1);
    });
  }

  Widget buildSwiper(double height) {
    List<String> imgs = [
      "img/opening_page_1.webp",
      "img/opening_page_2.webp",
      "img/opening_page_3.webp",
      "img/opening_page_4.webp"
    ];

    return Swiper(
//      outer: false,
      itemBuilder: (context, i) {
        return
          i != 3
            ?
        Image.asset(imgs[i], fit: BoxFit.cover)
            :
        Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(imgs[i], fit: BoxFit.cover),
            Positioned(
              child:
              InkWell(
                onTap: (){
                  _onTap();
                },
                child: Row(
                  children: <Widget>[
                    Text("Go to Home",style: TextStyle(color: Colors.white,fontFamily: "Kano")),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward,color: Colors.white)
                  ],
                ),
              ),
              right: 16,
              top: height > 650 ? 32 : 24,
            )
          ],
        );
      },
      autoplay: false,
      loop: false,
      itemCount: imgs.length,
    );
  }

  _onTap(){
    _savePrefSessionValue();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage()));
  }
}

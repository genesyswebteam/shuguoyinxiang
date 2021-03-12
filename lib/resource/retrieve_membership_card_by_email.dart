import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class RetrieveMembershipcardByEmail{

  Future<Map> retrieveMembershipCard() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var email = preferences.getString("email");

    var dataMembership;
    var _envelope =
    '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
    <RetrieveMembershipcardByEmail xmlns="http://tempuri.org/">
      <email>$email</email>
    </RetrieveMembershipcardByEmail>
    </soap:Body>
    </soap:Envelope>''';

    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveMembershipcardByEmail",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);

      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var idMember = parsedXml.findAllElements("ID");
      var mapId = idMember.map((node) => node.text).toList();

      var memberName = parsedXml.findAllElements("MemberName");
      var mapMemberName = memberName.map((node) => node.text).toList();

      var memberCard = parsedXml.findAllElements("MemberCard");
      var mapMemberCard = memberCard.map((node) => node.text).toList();

      var password = parsedXml.findAllElements("Password");
      var mapPassword = password.map((node) => node.text).toList();

      var gender = parsedXml.findAllElements("Gender");
      var mapGender = gender.map((node) => node.text).toList();

      var address = parsedXml.findAllElements("Address");
      var mapAddress = address.map((node) => node.text).toList();

      var handPhone = parsedXml.findAllElements("HandPhone");
      var mapHandPhone = handPhone.map((node) => node.text).toList();

      var email = parsedXml.findAllElements("Email");
      var mapEmail = email.map((node) => node.text).toList();

      var pictureFile = parsedXml.findAllElements("PictureFile");
      var mapPictureFile = pictureFile.map((node) => node.text).toList();

      var _points = parsedXml.findAllElements("Points");
      var mapPoints = _points.map((node) => node.text).toList();

      dataMembership = {
        "idMember": mapId[0],
        "memberCard":mapMemberCard[0],
        "imageUser":mapPictureFile[0],
        "memberName":mapMemberName[0],
        "email":mapEmail[0],
        "password":mapPassword[0],
        "address":mapAddress[0],
        "gender":mapGender[0],
        "phone":mapHandPhone[0],
        "points":mapPoints[0]
      };
      return dataMembership;
    }catch(e){
      var _errorMessage = {"message": e.toString()};
      return _errorMessage;
    }
  }

  Future<String> getFotoAndConvert(String imageUrl) async{

    try{
      final response = await http.get(imageUrl);
      String imageConvert = base64Encode(response.bodyBytes);
      return imageConvert;

    }catch(e){
      return "0";
    }
  }

  Future<Map> retrieveMembershipCardForSession() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var email = preferences.getString("email");

    var _envelope =
    '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
    <RetrieveMembershipcardByEmail xmlns="http://tempuri.org/">
      <email>$email</email>
    </RetrieveMembershipcardByEmail>
    </soap:Body>
    </soap:Envelope>''';

    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveMembershipcardByEmail",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);

      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var idMember = parsedXml.findAllElements("ID");
      var mapId = idMember.map((node) => node.text).toList();

      var _dataMembership = {
        "status":true,
        "idMember": mapId[0]
      };
      return _dataMembership;
    }catch(e){
      var _errorMessage = {"status":false, "message": e.toString()};
      return _errorMessage;
    }
  }
}
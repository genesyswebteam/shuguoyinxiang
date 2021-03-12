import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

  class CheckLogin{
  Future<Map> loginCheck(String password) async{
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    String _email = _preferences.getString("email");
    var _envelope =
    '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
    <CekLogin xmlns="http://tempuri.org/">
      <email>$_email</email>
      <pass>$password</pass>
    </CekLogin>
  </soap:Body>
  </soap:Envelope>''';

    http.Response response = await http.post(
        'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
        headers: {
          "Content-Type": "text/xml; charset=utf-8",
          "SOAPAction": "http://tempuri.org/CekLogin",
          "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
          //"Accept": "text/xml"
        },
        body: _envelope);

    var rawXmlResponse = response.body;
    var parsedXml = xml.parse(rawXmlResponse);

    var _resultLogin = parsedXml.findAllElements('string');
    var mapResultLogin = _resultLogin.map((node) => node.text).toList();
    var _result;
    if(mapResultLogin[0]== "Berhasil"){
      _result = {"result":true,"data":mapResultLogin[1]};
      return _result;
    }
    else{
      _result = {"result":false,"message":"Failed check session"};
      return _result;
    }
  }
}
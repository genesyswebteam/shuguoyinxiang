import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
class CheckSessionAPI{
  Future<Map> checkSession(int idMember,String token) async{
    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveByCekLogin xmlns="http://tempuri.org/">
        <MembercardID>$idMember</MembercardID>
        <LoginCode>$token</LoginCode> 
    </RetrieveByCekLogin>
  </soap:Body>
</soap:Envelope>''';

    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveByCekLogin",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);
      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _result = parsedXml.findAllElements("RetrieveByCekLoginResult");
      var mapResult = _result.map((node) => node.text).toList();
      print(mapResult[0]);
      if(mapResult[0]=="valid code"){
        var _result = {"status": true};
        return _result;
      }
      else if(mapResult[0] == "invalid code"){
        var _result = {"status": false,"message": "Session expired"};
        return _result;
      }
    }
    catch(_){
      var _result = {"status": false,"message": "Failed check session"};
      return _result;
    }
  }

  Future<List> checkSessionAfterLogin() async{
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    int _memberId = _preferences.getInt("idMember");
    String _codeToken = _preferences.getString("token");
    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveByCekLogin xmlns="http://tempuri.org/">
        <MembercardID>$_memberId</MembercardID>
        <LoginCode>$_codeToken</LoginCode> 
    </RetrieveByCekLogin>
  </soap:Body>
</soap:Envelope>''';

    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveByCekLogin",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);
      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _result = parsedXml.findAllElements("RetrieveByCekLoginResult");
      var mapResult = _result.map((node) => node.text).toList();
      return mapResult;
    }
    catch(_){
      var _result = ["Failed check session"];
      return _result;
    }
  }
}
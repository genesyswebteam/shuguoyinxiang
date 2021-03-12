import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class CheckExistEmailAPI{
  Future<bool> checkExistEmailInRegister(String email, String hp) async{

    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveMembershipcardByEmailAndHP xmlns="http://tempuri.org/">
        <email>$email</email>
        <hp>$hp</hp> 
    </RetrieveMembershipcardByEmailAndHP>
  </soap:Body>
</soap:Envelope>''';

      http.Response _response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveMembershipcardByEmailAndHP",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);

      print(_response.statusCode);

      if(_response.statusCode == 200){
        var _rawXmlResponse = _response.body;
        var _parsedXml = xml.parse(_rawXmlResponse);
        var _resultID = _parsedXml.findAllElements("ID");
        var _mapIdResult = _resultID.map((node) => node.text).toList();
        print(_mapIdResult);

        if(_mapIdResult[0] == "0"){
          return true;
        }
        else{
          return false;
        }
      }
      else{
        throw Exception("Error ${_response.statusCode}");
      }
  }
}
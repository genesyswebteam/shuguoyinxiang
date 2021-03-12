import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class RetrieveCategoryAll{

  Future<Map> getCategoryAll() async{

    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveCategoryAll xmlns="http://tempuri.org/" />
  </soap:Body>
</soap:Envelope>''';

    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveCategoryAll",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);
      var rawXmlResponse = response.body;

      var parsedXml = xml.parse(rawXmlResponse);

      var idCategory = parsedXml.findAllElements('ID');
      var mapId = idCategory.map((node) => node.text).toList();

      var codeCategory = parsedXml.findAllElements('Codecategory');
      var mapCategory = codeCategory.map((node) => node.text).toList();

      var _categoryList = [];

      for(var i =0; i< idCategory.length; i++){
        var mapData = {"idCategory":mapId[i],"codeCategory":mapCategory[i]};
        _categoryList.add(mapData);
      }

      var _result = {"status": true,"categoryList": _categoryList};
      return _result;

    }
    catch(e){
      var _listError = {"status":false,"message":e.toString()};
      return _listError;
    }

  }
}
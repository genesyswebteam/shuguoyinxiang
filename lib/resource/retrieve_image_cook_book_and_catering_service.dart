import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class RetrieveCookBookCateringService{
  Future<Map> getImageCookBookCateringService() async{
    var _envelope =
    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrievePictureSGYXAll xmlns="http://tempuri.org/"/>
  </soap:Body>
</soap:Envelope>''';
    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrievePictureSGYXAll",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);
      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var idImage = parsedXml.findAllElements("ID");
      var mapIdImage = idImage.map((node) => node.text).toList();

      var picture = parsedXml.findAllElements("Picture");
      var mapPicture = picture.map((node) => node.text).toList();

      var type = parsedXml.findAllElements("Type");
      var mapType = type.map((node) => node.text).toList();

      var _listPictureCookBookCateringService = [];

      for(int i=0; i < mapIdImage.length; i++){
        var _data = {"idImage":mapIdImage[i],"picture":mapPicture[i],"type":mapType[i]};
        _listPictureCookBookCateringService.add(_data);
      }

      var _result = {"result": true, "data":_listPictureCookBookCateringService};

      return _result;
    }catch(e){
      var  message = {"result":false,"message":"Failed get data"};
      return message;
    }
  }
}
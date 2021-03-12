import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class RetrieveDetailPremiumMenu{
  Future<Map> getDetailPremiumMenu(int id) async{
    var _envelope =
    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveItemMasterDetailAllByItemMasterID xmlns="http://tempuri.org/">
            <itemmasterid>$id</itemmasterid>
        </RetrieveItemMasterDetailAllByItemMasterID>
  </soap:Body>
</soap:Envelope>''';

    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveItemMasterDetailAllByItemMasterID",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);
      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _picture =  parsedXml.findAllElements("Picture2");
      var _mapPicture = _picture.map((node) => node.text).toList();
      var _result = {"result":true,"data":_mapPicture[0]};

      return _result;
    }
    catch(e){
      var _result = {"result":false,"message":"Failed get image"};
      return _result;
    }
  }
}
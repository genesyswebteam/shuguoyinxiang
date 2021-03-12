import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class RetrieveCategoryReward{

  Future<List> getCategoryReward() async{

    var _envelope =
    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetreiveRewardCategoryAll xmlns="http://tempuri.org/" />
  </soap:Body>
</soap:Envelope>''';
    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetreiveRewardCategoryAll",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);

      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var idRewardCategory = parsedXml.findAllElements("ID");
      var mapIdRewardCategory = idRewardCategory.map((node) => node.text).toList();

      var itemCategory = parsedXml.findAllElements("ItemCategory");
      var mapItemCategory = itemCategory.map((node) => node.text).toList();

      var listRewardCategory = [];

      for(var i =0; i<mapIdRewardCategory.length; i++){
        var mapResult = {"idRewardCategory": mapIdRewardCategory[i],"mapItemCategory":mapItemCategory[i]};
        listRewardCategory.add(mapResult);
      }

      return listRewardCategory;
    }catch(e){
      var messageError = [{"message":e.toString()}];
      return messageError;
    }
  }
}
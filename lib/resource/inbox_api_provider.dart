import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class InboxApiProvider{

  Future<List> getInbox() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int idMember = preferences.getInt("idMember");
    var _envelope =
    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveMobileInboxAllByMembershipCardID xmlns="http://tempuri.org/">
      <membershipcardid>$idMember</membershipcardid>
    </RetrieveMobileInboxAllByMembershipCardID>
  </soap:Body>
</soap:Envelope>''';
    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveMobileInboxAllByMembershipCardID",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);

      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var templateHeaderID = parsedXml.findAllElements("ID");
      var maptemplateHeaderID = templateHeaderID.map((node) => node.text).toList();

      var membershipCardID = parsedXml.findAllElements("MembershipCardID");
      var mapMembershipCardID = membershipCardID.map((node) => node.text).toList();

      var templateName = parsedXml.findAllElements("TemplateName");
      var mapTemplateName = templateName.map((node) => node.text).toList();

      var templateDescription = parsedXml.findAllElements("TemplateDescription");
      var mapTemplateDescription = templateDescription.map((node) => node.text).toList();

      var templateBodyMassage = parsedXml.findAllElements("TemplateBodyMassage");
      var mapTemplateBodyMassage = templateBodyMassage.map((node) => node.text).toList();

      var listRewardCategory = [];

      for(var i =0; i<maptemplateHeaderID.length; i++){
        var mapResult = {
          "idPesan": maptemplateHeaderID[i],
          "membershipCardID":mapMembershipCardID[i],
          "templateName":mapTemplateName[i],
          "templateDescription":mapTemplateDescription[i],
          "templateBodyMassage":mapTemplateBodyMassage[i]
        };
        listRewardCategory.add(mapResult);
      }

      return listRewardCategory;
    }catch(e){
      var messageError = [{"message":e.toString()}];
      return messageError;
    }
  }
}
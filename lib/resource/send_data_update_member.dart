import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class SendDataUpdateMember {
  Future<Map> sendUpdateMemberWithoutImage(
      String idMember,
      String memberCard,
      String memberName,
      String password,
      int gender,
      String phone,
      String email,
      String address,
      String image,
      String countryCode) async {
    int idMemberFormat = int.parse(idMember);
    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <UpdateMembershipcard xmlns="http://tempuri.org/">
      <membershipcard>
        <ID>$idMemberFormat</ID>
        <MemberCard>$memberCard</MemberCard>
        <LastModifiedBy></LastModifiedBy>
        <MemberName>$memberName</MemberName>
        <Password>$password</Password>
        <Gender>$gender</Gender>
        <HandPhone>$countryCode$phone</HandPhone>
        <Email>$email</Email>
        <Address>$address</Address>
        <PictureFile></PictureFile>
      </membershipcard>
      <byteArrayIn>$image</byteArrayIn>
    </UpdateMembershipcard>
  </soap:Body>
 </soap:Envelope>''';
    try {
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/UpdateMembershipcard",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);
      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _messageResult =
      parsedXml.findAllElements("UpdateMembershipcardResult");
      var mapMessageResult = _messageResult.map((node) => node.text).toList();

      var result = {"message": mapMessageResult[0]};

      return result;
    } catch (e) {
      var result = {"message": e.toString()};
      return result;
    }
  }

  Future<Map> sendUpdateMemberWithImage(
      String idMember,
      String memberCard,
      String memberName,
      String password,
      int gender,
      String phone,
      String email,
      String address,
      String imageUser,
      String countryCode) async {
    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <UpdateMembershipcard xmlns="http://tempuri.org/">
      <membershipcard>
        <ID>$idMember</ID>
        <MemberCard>$memberCard</MemberCard>
        <LastModifiedBy></LastModifiedBy>
        <MemberName>$memberName</MemberName>
        <Password>$password</Password>
        <Gender>$gender</Gender>
        <HandPhone>$countryCode$phone</HandPhone>
        <Email>$email</Email>
        <Address>$address</Address>
        <PictureFile></PictureFile>
      </membershipcard>
      <byteArrayIn>$imageUser</byteArrayIn>
    </UpdateMembershipcard>
  </soap:Body>
 </soap:Envelope>''';
    try {
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/UpdateMembershipcard",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);
      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _messageResult =
      parsedXml.findAllElements("UpdateMembershipcardResult");
      var mapMessageResult = _messageResult.map((node) => node.text).toList();

      var result = {"message": mapMessageResult[0]};
      return result;
    } catch (e) {
      var result = {"message": e.toString()};
      return result;
    }
  }

  Future<Map> sendUpdateMemberWithEmptyImage(
      String idMember,
      String memberCard,
      String memberName,
      String password,
      int gender,
      String phone,
      String email,
      String address,
      String countryCode) async {
    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <UpdateMembershipcard xmlns="http://tempuri.org/">
      <membershipcard>
        <ID>$idMember</ID>
        <MemberCard>$memberCard</MemberCard>
        <LastModifiedBy></LastModifiedBy>
        <MemberName>$memberName</MemberName>
        <Password>$password</Password>
        <Gender>$gender</Gender>
        <HandPhone>$countryCode$phone</HandPhone>
        <Email>$email</Email>
        <Address>$address</Address>
        <PictureFile></PictureFile>
      </membershipcard>
      <byteArrayIn></byteArrayIn>
    </UpdateMembershipcard>
  </soap:Body>
 </soap:Envelope>''';
    try {
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/UpdateMembershipcard",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);
      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _messageResult =
      parsedXml.findAllElements("UpdateMembershipcardResult");
      var mapMessageResult = _messageResult.map((node) => node.text).toList();

      var result = {"message": mapMessageResult[0]};
      return result;
    } catch (e) {
      var result = {"message": e.toString()};
      return result;
    }
  }
}

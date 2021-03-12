import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'dart:async';

class RetrievePointTransaction{
  Future<Map> getPointTransactionHistory() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int _memberId = preferences.getInt("idMember");

    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrievePointTransactionSGYXByMembercardID xmlns="http://tempuri.org/">
      <membercardid>$_memberId</membercardid>
    </RetrievePointTransactionSGYXByMembercardID>
  </soap:Body>
</soap:Envelope>''';

    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrievePointTransactionSGYXByMembercardID",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope).timeout(const Duration(seconds: 30));

      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _iD = parsedXml.findAllElements("ID");
      var _mapId = _iD.map((node) => node.text).toList();

      var _points = parsedXml.findAllElements("Points");
      var _mapPoints = _points.map((node) => node.text).toList();

      var _createdTime = parsedXml.findAllElements("CreatedTime");
      var _mapCreatedTime = _createdTime.map((node) => node.text).toList();

      var _merchantID = parsedXml.findAllElements("MerchantID");
      var _mapMerchantID = _merchantID.map((node) => node.text).toList();

      var _merchantName = parsedXml.findAllElements("MerchantName");
      var _mapMerchantName = _merchantName.map((node) => node.text).toList();

      var _listTransaction = [];

      for(int i=0; i<_mapId.length; i++){
        var data = {
          "id":_mapId[i],
          "point":_mapPoints[i],
          "trans_date":_mapCreatedTime[i],
          "outlet_id":_mapMerchantID[i],
          "outlet_name":_mapMerchantName[i]
        };
        _listTransaction.add(data);
      }

      var _result = {"result":true,"data":_listTransaction};
      return _result;
    }
    on TimeoutException catch(_){
      var  message = {"result":false,"message":"Connection timeout"};
      return message;
    }
    catch(e){
      var  message = {"result":false,"message":"Connection timeout"};
      return message;
    }
  }
}
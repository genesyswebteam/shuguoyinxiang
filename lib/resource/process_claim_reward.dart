import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class ProcessClaimReward{

  Future<Map> claimReward(int redeemPoint,int itemRewardId,String remark,int merchantid) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var idMember = preferences.getInt("idMember");
    String memberId = idMember.toString();
    var _envelope =
    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <insertClaimReward xmlns="http://tempuri.org/">
      <membercardid>$memberId</membercardid>
      <redeemPoint>$redeemPoint</redeemPoint>
      <itemrewardid>$itemRewardId</itemrewardid>
      <Remarks>$remark</Remarks>
      <merchantid>$merchantid</merchantid>
    </insertClaimReward>
  </soap:Body>
</soap:Envelope>''';

    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/insertClaimReward",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);
      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);
      
      var _result = parsedXml.findAllElements("insertClaimRewardResult");
      var mapResult = _result.map((node) => node.text).toList();

      var resultMessage = {"message": mapResult[0]};
      return resultMessage;
    }catch(e){
      var resultMessage = {"message":e.toString()};
      return resultMessage;
    }
  }

}
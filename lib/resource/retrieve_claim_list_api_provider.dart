import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class RetrieveClaimListApiProvider{

  Future<Map> getClaimList() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int _memberId = preferences.getInt("idMember");

    var _envelope =
    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveClaimListAllByMembercardID xmlns="http://tempuri.org/">
      <membercardid>$_memberId</membercardid>
    </RetrieveClaimListAllByMembercardID>
  </soap:Body>
</soap:Envelope>''';

    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveClaimListAllByMembercardID",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope).timeout(const Duration(seconds: 30));

      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _iD = parsedXml.findAllElements("ID");
      var _mapId = _iD.map((node) => node.text).toList();

      var _pointTransactionId = parsedXml.findAllElements("PointTransactionID");
      var _mapPointTransactionId = _pointTransactionId.map((node) => node.text).toList();

      var _createdBy  = parsedXml.findAllElements("CreatedBy");
      var _mapCreatedBy  = _createdBy.map((node) => node.text).toList();

      var _createdTime  = parsedXml.findAllElements("CreatedTime");
      var _mapCreatedTime  = _createdTime.map((node) => node.text).toList();

      var _itemRewardID = parsedXml.findAllElements("ItemRewardID");
      var _mapItemRewardID = _itemRewardID.map((node) => node.text).toList();

      var _membershipCardID = parsedXml.findAllElements("MembershipCardID");
      var _mapMembershipCardID = _membershipCardID.map((node) => node.text).toList();

      var _checkClaim = parsedXml.findAllElements("CheckClaim");
      var _mapCheckClaim = _checkClaim.map((node) => node.text).toList();

      var _noteRedeem = parsedXml.findAllElements("NoteRedeem");
      var _mapNoteRedeem = _noteRedeem.map((node) => node.text).toList();

      var _sendAddress = parsedXml.findAllElements("SendAddress");
      var _mapSendAddress = _sendAddress.map((node) => node.text).toList();

      var _expiredDate = parsedXml.findAllElements("ExpiredDate");
      var _mapExpiredDate = _expiredDate.map((node) => node.text).toList();

      var _itemMasterDescription = parsedXml.findAllElements("ItemMasterDescription");
      var _mapItemMasterDescription = _itemMasterDescription.map((node) => node.text).toList();

      var _itemMasterName = parsedXml.findAllElements("ItemMasterName");
      var _mapItemMasterName = _itemMasterName.map((node) => node.text).toList();

      var _pointRedeem = parsedXml.findAllElements("PointRedeem");
      var _mapPointRedeem = _pointRedeem.map((node) => node.text).toList();

      var _points = parsedXml.findAllElements("Points");
      var _mapPoints = _points.map((node) => node.text).toList();

      var dataClaimList =[];

      for(int i=0; i<_pointTransactionId.length; i++){
        var data =
        {
          "id":_mapId[i],
          "pointTransactionId": _mapPointTransactionId[i],
          "createdBy":_mapCreatedBy[i],
          "createdTime": _mapCreatedTime[i],
          "itemRewardID": _mapItemRewardID[i],
          "membershipCardID": _mapMembershipCardID[i],
          "checkClaim": _mapCheckClaim[i],
          "noteRedeem": _mapNoteRedeem[i],
          "sendAddress": _mapSendAddress[i],
          "expiredDate": _mapExpiredDate[i],
          "itemMasterDescription": _mapItemMasterDescription[i],
          "itemMasterName": _mapItemMasterName[i],
          "pointRedeem": _mapPointRedeem[i],
          "points": _mapPoints[i]
        };
        dataClaimList.add(data);
      }

      var _result = {"result":true, "data":dataClaimList};
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
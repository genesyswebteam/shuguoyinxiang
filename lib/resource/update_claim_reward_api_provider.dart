import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class UpdateClaimRewardApiProvider{

  Future<Map> updateClaimReward(String id,String pointTransactionId,String itemRewardID,String createdBy,
      String createdTime, String noteRedeem,String sendAddress,String expiredDate,
      String itemMasterDescription, String itemMasterName,String pointRedeem,
      String points) async{

    SharedPreferences preferences = await SharedPreferences.getInstance();
    int _memberId = preferences.getInt("idMember");
    int statusCheckClaim = 1;
    int idInteger = int.parse(id);
    int pointTransactionIdInteger = int.parse(pointTransactionId);
    int itemRewardIdInteger = int.parse(itemRewardID);
    int pointRedeemInteger = int.parse(pointRedeem);
    int pointsInteger = int.parse(points);

    var _envelope =
    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <updateClaimList xmlns="http://tempuri.org/">
     <ClaimList>
                <ID>$idInteger</ID>
                <RowStatus>0</RowStatus>
                <CreatedBy>$createdBy</CreatedBy>
                <CreatedTime>$createdTime</CreatedTime>
                <LastModifiedBy>$createdBy</LastModifiedBy>
                <LastModifiedTime>$createdTime</LastModifiedTime>
                <PointTransactionID>$pointTransactionIdInteger</PointTransactionID>
                <ItemRewardID>$itemRewardIdInteger</ItemRewardID>
                <MembershipCardID>$_memberId</MembershipCardID>
                <CheckClaim>$statusCheckClaim</CheckClaim>
                <NoteRedeem>$noteRedeem</NoteRedeem>
                <SendAddress>$sendAddress</SendAddress>
                <ExpiredDate>$expiredDate</ExpiredDate>
                <ItemMasterDescription>$itemMasterDescription</ItemMasterDescription>
                <ItemMasterName>$itemMasterName</ItemMasterName>
                <PointRedeem>$pointRedeemInteger</PointRedeem>
                <Points>$pointsInteger</Points>
            </ClaimList>
    </updateClaimList>
  </soap:Body>
</soap:Envelope>''';

    try{
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/updateClaimList",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);

      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _result = parsedXml.findAllElements("updateClaimListResult");
      var mapResult = _result.map((node) => node.text).toList();

      var _resultData = {"result":true,"data":mapResult};

      return _resultData;
    }catch(e){
      var message = {"result":false,"message":"Failed insert"};
      return message;
    }

  }
}
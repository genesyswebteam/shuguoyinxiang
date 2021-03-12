import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

class RetrieveOutletApiProvider {
  Future<Map> retrieveOutletPassword() async {
    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveOutlet xmlns="http://tempuri.org/" />
  </soap:Body>
  </soap:Envelope>''';

    try {
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveOutlet",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);

      var rawXmlResponse = response.body;
      var parsedXml = xml.parse(rawXmlResponse);

      var _passwordOutlet = parsedXml.findAllElements("Password");
      var _mapPasswordOutlet =
      _passwordOutlet.map((node) => node.text).toList();

      List password = [];

      for (int i = 0; i < _mapPasswordOutlet.length; i++) {
        password.add(_mapPasswordOutlet[i]);
      }

      var result = {"result": true, "data": password};

      return result;
    } catch (_) {
      var message = {"result": false, "message": "Failed get data"};
      return message;
    }
  }

  Future<Map> getAllOutlet() async {
    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RetrieveOutlet xmlns="http://tempuri.org/" />
  </soap:Body>
</soap:Envelope>''';

    try {
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/RetrieveOutletNoDisplay",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);
      var rawXmlResponse = response.body;

      var parsedXml = xml.parse(rawXmlResponse);

      var _idOutlet = parsedXml.findAllElements('ID');
      var mapId = _idOutlet.map((node) => node.text).toList();

      var _merchantName = parsedXml.findAllElements('MerchantName');
      var mapMerchantName = _merchantName.map((node) => node.text).toList();

      var _address = parsedXml.findAllElements('Address');
      var mapAddress = _address.map((node) => node.text).toList();

      var _phone = parsedXml.findAllElements('Phone');
      var mapPhone = _phone.map((node) => node.text).toList();

      var _jamBuka = parsedXml.findAllElements('Buka');
      var mapJamBuka = _jamBuka.map((node) => node.text).toList();

      var _jamTutup = parsedXml.findAllElements('Tutup');
      var mapJamTutup = _jamTutup.map((node) => node.text).toList();

      var _categoryList = [];

      for (var i = 0; i < mapId.length; i++) {
        var mapData = {
          "idOutlet": mapId[i],
          "merchantName": mapMerchantName[i],
          "address": mapAddress[i],
          "phone": mapPhone[i],
          "jamBuka": mapJamBuka[i],
          "jamTutup": mapJamTutup[i]
        };
        _categoryList.add(mapData);
      }

      var _result = {"result": true, "data": _categoryList};
      return _result;
    } catch (e) {
      var _result = {"result": false, "message": e.toString()};
      return _result;
    }
  }

  Future<Map> retrieveItemMasterRewardAllperOutlet(int itemMaterId) async {
    var _envelope = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
    <RetrieveItemMasterRewardAllperOutlet xmlns="http://tempuri.org/">
    <ItemMasterID>$itemMaterId</ItemMasterID>
    </RetrieveItemMasterRewardAllperOutlet>
    </soap:Body>
    </soap:Envelope>''';
    try {
      http.Response response = await http.post(
          'http://aevislinkcsp.southeastasia.cloudapp.azure.com:9090/Service.asmx',
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction":
            "http://tempuri.org/RetrieveItemMasterRewardAllperOutlet",
            "Host": "aevislinkcsp.southeastasia.cloudapp.azure.com"
            //"Accept": "text/xml"
          },
          body: _envelope);

      var rawXmlResponse = response.body;
      print(response.statusCode);

      var parsedXml = xml.parse(rawXmlResponse);

      var _namaMerchant = parsedXml.findAllElements('NamaMerchant');
      var _mapMerchantName = _namaMerchant.map((node) => node.text).toList();
      print(_mapMerchantName);

      var _merchantId = parsedXml.findAllElements('MerchantID');
      var _mapMerchantId = _merchantId.map((node) => node.text).toList();

      var _listMerchant = [];

      for (var i = 0; i < _mapMerchantId.length; i++) {
        var _mapData = {
          "merchantId": _mapMerchantId[i],
          "merchantName": _mapMerchantName[i]
        };
        _listMerchant.add(_mapData);
      }
      var _result = {"result": true, "data": _listMerchant};
      print(_result);
      return _result;
    } catch (e) {
      var _result = {"result": false, "message": e.toString()};
      return _result;
    }
  }
}

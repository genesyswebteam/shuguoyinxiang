import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper{
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'message';

  static final columnId = '_id';
  static final columnIdPesan = 'idPesan';
  static final columnIdMembercard = 'idMemberCard';
  static final columnTemplateName = 'templateName';
  static final columnTemplateDescription = 'templateDescription';
  static final columnTemplateBodyMessage = 'templateBodyMessage';
  static final columnIsRead = 'isRead';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnIdPesan TEXT,
            $columnIdMembercard TEXT,
            $columnTemplateName TEXT,
            $columnTemplateDescription TEXT,
            $columnTemplateBodyMessage TEXT,
            $columnIsRead INTEGER NOT NULL
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> getAllData() async{
    Database db = await instance.database;
    var _result = await db.rawQuery("select * from $table order by $columnId DESC");
    return _result;
  }

  Future<List> getInboxByIdMember(String idMember) async{
    Database db = await instance.database;
    var _result = await db.rawQuery("select * from $table where $columnIdMembercard = $idMember");
    return _result;
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<String> checkData(List data) async{

    Database db = await instance.database;

    var _resultCheck = [];
    var _resultInsert = [];

    for(int i = 0; i<data.length; i++){
      List result =  await db.rawQuery("Select $columnIdPesan from message where $columnIdPesan = ${data[i]['idPesan']}");
      if(result.isNotEmpty){
        _resultCheck.add({"tidakDimasukkan": result[0]['idPesan']});
      }
      else{
        var _newData = {
          DatabaseHelper.columnIdPesan : data[i]['idPesan'],
          DatabaseHelper.columnIdMembercard  : data[i]['membershipCardID'],
          DatabaseHelper.columnTemplateName : data[i]['templateName'],
          DatabaseHelper.columnTemplateDescription : data[i]['templateDescription'],
          DatabaseHelper.columnTemplateBodyMessage : data[i]['templateBodyMassage'],
          DatabaseHelper.columnIsRead : 0
        };
        final id = await instance.insert(_newData);
        _resultInsert.add({"dimasukkan": id});
      }
    }
    if(_resultInsert.length == 0){
      return "Tidak ada pesan baru";
    }
    else{
      return "Berhasil get data baru";
    }
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  updateMessage(String idPesan) async{

    Database db = await instance.database;
    var _result = await db.rawQuery("UPDATE message SET isRead = 1 WHERE idPesan = $idPesan");
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
  
  Future<int> getMessageUnread(String idMember) async{
    Database db = await instance.database;
    var _result = await db.rawQuery("SELECT COUNT(*) FROM message WHERE isRead = 0 and $columnIdMembercard = $idMember");
    return Sqflite.firstIntValue(_result);
  }
}
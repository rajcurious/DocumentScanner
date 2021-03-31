import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:cscanner/menu.dart';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  final String title='title';
  final String imgs='imgs';
  final String original='original';
  final String createdDate='createdDate';
  final String modDate='modDate';


  DatabaseHelper._createInstance();

  factory DatabaseHelper(){
    if(_databaseHelper==null)
      {
      _databaseHelper=DatabaseHelper._createInstance();
      }
    return _databaseHelper;
  }

  Future<Database> get database async{
    if(_database==null){
      _database=await initializeDb();
    }
    return _database;
  }

  Future<Database> initializeDb() async{
    Directory dir=await getApplicationDocumentsDirectory();
    String path=dir.path+'docs1.db';
    print("Database path $path");
    var docDb=await openDatabase(path,version: 1,onCreate: _createDb);
    return  docDb;
  }

  void _createDb(Database db,int ver) async{
    await db.execute('CREATE TABLE DOC($title TEXT PRIMARY KEY ,$imgs TEXT,$original TEXT ,$createdDate INTEGER,$modDate INTEGER)');
  }

  Future<List<ImgObj>> getImgList() async {
    final Database db = await this.database;
    final maps = await db.query('DOC');
    return List.generate(maps.length, (i) {
      return ImgObj(
        title: maps[i]['title'],
        imgs: maps[i]['imgs'],
        original:maps[i]['original'],
        createdDate: maps[i]['createdDate'],
        modDate:maps[i]['modDate'],
      );
    });
  }

  Future<void> insertDoc(ImgObj obj) async {
    // Get a reference to the database.
    final Database db = await database;
    await db.insert(
      'doc',
      obj.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDoc(ImgObj obj) async {
    final db = await database;
    await db.update(
      'doc',
      obj.toMap(),
      where: "title = ?",
      whereArgs: [obj.title],
    );
  }

//Delete Image
  Future<void> deleteDoc(String title) async {
    final db = await database;
    await db.delete(
      'doc',
      where: "title = ?",
      whereArgs: [title],
    );
  }

  Future<int> getTotal() async{
    Database db=await this.database;
    List<Map<String,String>> doclist=await db.rawQuery('SELECT COUNT(*) FROM DOC');
    int res=Sqflite.firstIntValue(doclist);
    return res;
  }
}
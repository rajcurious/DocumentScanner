import 'dart:io';
import 'dart:async';

import 'package:cscanner/model/PageRoute.dart';
import 'package:cscanner/model/database_helper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:sqflite/sqflite.dart';
import 'package:cscanner/Screens/splashScreen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cscanner/commonWidget/common_nav_drawer.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_search_delgates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cscanner/Screens/listDetailed.dart';
import 'menu.dart';
import 'package:cscanner/commonWidget/scanner.dart';
void main() => runApp(MaterialApp(
  home: splashScreen(),
));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{
  int count;
  DatabaseHelper databaseHelper=DatabaseHelper();
  bool _inProgress=false;
  bool grid;
  bool _selected=false;
  List<ImgObj> _selectedimgs=List<ImgObj>();
  List<ImgObj> homeobj;
  //SharedPreferences sharedPreferences;
  final picker=ImagePicker();

  @override
  void initState(){
    updateList();
    grid=false;
    super.initState();
  }

  void updateList(){
    final Future<Database> db=databaseHelper.initializeDb();
    db.then((database) {
      print("Datanase initializd!");
      Future<List<ImgObj>> list=databaseHelper.getImgList();
      list.then((value) {
        setState(() {
          homeobj=value;
          count=value.length;
        });
      });
    });
  }

  getBar1(){
    return AppBar(
      title: Text("App Bar"),
      backgroundColor: Colors.blueGrey[800],
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right:20.0),
          child: IconButton(icon:Icon(Icons.search),onPressed: _showSearch),
        ),
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: (){
              setState(() {
                grid=!grid;
              });
            },
            child: grid?Icon(Icons.list):Icon(Icons.grid_on),
          ),
        ),
      ],
    );
  }

  getBar2(){
    return AppBar(
        actions: <Widget>[
          IconButton(icon: Icon(Icons.share),onPressed: (){},),
          IconButton(icon: Icon(Icons.delete),onPressed: (){setState(() {
            _selected=false;
            _removefromList(_selectedimgs);
            _selectedimgs=[];
            count=homeobj.length;
          });
          },)],
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
          setState(() {
            _selected=false;
            _selectedimgs.removeRange(0, _selectedimgs.length);
            print("slected:$_selectedimgs");
          });
        }
          ,), title: Text("You Selected", style: TextStyle(fontSize: 24),));
  }

  /*initSharedPref() async{
    sharedPreferences=await SharedPreferences.getInstance();
    loadData();
  } */

  margin(int x,int y){
    if(x==0)
      return EdgeInsets.only(top:20,bottom: 10);
    else if(x==y-1)
      return EdgeInsets.only(top:10,bottom: 20);
    else
      return EdgeInsets.only(top: 10,bottom: 10);
  }

  Widget buildListView() {
    List<ImgObj> listimg=homeobj;
      if (listimg.isNotEmpty) {
        return ListView.separated(
          itemCount: listimg.length,
          itemBuilder: (context, index) {
            final ind = listimg.length - index;
            final item = listimg.elementAt(ind - 1);
            return Container(
              margin: margin(index, listimg.length),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.file(
                    File(item.imgs.split('|').map((String x) => x).toList()[0]),
                    width: 75,
                    height: 100,
                    fit: BoxFit.fill,
                  ),
                ),
                title: Text(item.title,
                  style: TextStyle(letterSpacing: 1.5, fontSize: 18.0),),
                onTap: () {
                  if (!_selected) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ListTap(item),
                    ),
                    );
                  }
                  else {
                    setState(() {
                      _selectedimgs.contains(item)
                          ? _selectedimgs.remove(item)
                          : _selectedimgs.add(item);
                    });
                    if (_selectedimgs.length == 0) {
                      setState(() {
                        _selected = false;
                      });
                    }
                    print('Selected : $_selectedimgs');
                  }
                },
                onLongPress: () {
                  setState(() {
                    _selected = true;
                    _selectedimgs.add(item);
                  });
                  print('Selected : $_selectedimgs');
                },
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(thickness: 1.0, color: Colors.grey,);
          },
        );
      }
    else return Center(
        child: const Text(
          'Nothing to show',
        ),
      );
    }

  Widget buildGrid() {
    List<ImgObj> gridimg = homeobj;
      if (gridimg.isNotEmpty) {
        return GridView.builder(
          shrinkWrap: true,
          itemCount: gridimg.length,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final int ind = gridimg.length - index;
            final item = gridimg.elementAt(ind - 1);
            return new Stack(children: <Widget>[
              new Positioned.fill(
                bottom: 0.0,
                top: 5.0,
                child: new GridTile(
                  footer: new GridTileBar(
                    title: new Text(item.title),
                    backgroundColor: Colors.transparent.withOpacity(0.3),
                    trailing: new Icon(
                      Icons.launch,
                      color: Colors.white,
                    ),
                  ),
                  child: new Image.file(File(item.imgs.split('|').map((String x) => x).toList()[0]),fit: BoxFit.fill,),
                ),
              ),
              new Positioned.fill(
                  child: new Material(
                      color: Colors.transparent,
                      child: new InkWell(
                        splashColor: Colors.transparent.withOpacity(0.7),
                        onTap: () {
                          if (!_selected) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>
                                  ListTap(item),
                            ),
                            );
                          }
                          else {
                            setState(() {
                              _selectedimgs.contains(item) ? _selectedimgs.remove(item) : _selectedimgs.add(item);
                            });
                            if (_selectedimgs.length == 0) {
                              setState(() {
                                _selected = false;
                                _selectedimgs = [];
                              });
                            }
                            print('Selected : $_selectedimgs');
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            _selected = true;
                            _selectedimgs.add(item);
                            print('Selected : $_selectedimgs');
                          });
                        },
                      ))),
              Positioned(
                  right: 5,
                  top: 10,
                  height: 15,
                  child: _selected ?
                  _selectedimgs.contains(item) ? Icon(
                    Icons.check_box, color: Colors.white,) : Icon(
                    Icons.check_box_outline_blank, color: Colors.white,)
                      : Container()),
            ]);
          },
        );
      }
    else {
      return
        Center(child: Text('Nothing Scanned yet :)'));
    }
  }

  getImage(ImageSource source) async{
    final picker=ImagePicker();
    //Navigator.of(this.context).pop();
    ImgObj temp,org;
   /* this.setState(() {
      _inProgress=true;
    });*/
     PickedFile img = await picker.getImage(source: source);
    File imgq=await testCompressAndGetFile(File(img.path));
    if(imgq!=null)
    {

      /*File cropped= await ImageCropper.cropImage(
          sourcePath: img.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.blue[700],
            toolbarTitle: 'Scanned Image',
            statusBarColor: Colors.white30,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            backgroundColor: Colors.white,
          )
      );*/
      print("image path: ${img.path} ");
    Navigator.push(this.context,ElasticPageRoute(
     child:Scanner(height: 350,padX: 20,imagePath: imgq.path)
    ));
      /*{
        Directory tempDir = await getApplicationDocumentsDirectory();
        final String path=tempDir.path;
        final fileName = basename(img.path);
        //final File localImage = await img.copy('$path/$fileName');
        //final orgName = basename(img.path);
        //final File orgImage = await img.copy('$path/$orgName');
        count++;
        temp=new ImgObj(title: 'Image $count',imgs: img.path, original: img.path);
        _savetolist(temp);
        this.setState(() {
          _inProgress=false;
          Navigator.push(this.context,MaterialPageRoute(
            builder: (context) => ListTap(temp),
          ),);
        });
      }*/
    }
    /*else{
      this.setState(() {
        _inProgress=false;
      });
    }*/
  }


  Future<File> testCompressAndGetFile(File file) async {
    print(file.path);
    String targetPath=await getTemporaryDirectory().then((value){return value.path.toString()+'/temp.jpg';});
    print("target path  $targetPath");
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 25,
      //rotate: 180,
    );

    print("result $result");

    return result;
  }


  Future<void> _createAlert(BuildContext context){
    return showDialog(context: context,builder: (BuildContext context){
      return AlertDialog(
        title: Row(
          children: <Widget>[
            Text("Pick an Image from",
              style: GoogleFonts.getFont('Lora'),
            )
          ],
        ),
        titlePadding: EdgeInsets.all(20.0),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text("Import from Gallery"),
                onTap: () => getImage(ImageSource.gallery),
              ),
              Divider(
                color: Colors.white24,
                thickness: 5.0,
              ),
              Padding(padding: EdgeInsets.all(7.0)),
              GestureDetector(
                child: Text("Open Camera"),
                onTap: () => getImage(ImageSource.camera),
              )
            ],
          ),
        ),
      );
    });
  }

  Future<void> _showSearch() async {
    final searchText = await showSearch<String>(
      context: this.context,
      delegate: SearchWithSuggestionDelegate(
        onSearchChanged: _getRecentSearchesLike,
      ),
    );

    //Save the searchText to SharedPref so that next time you can use them as recent searches.
    await _saveToRecentSearches(searchText);

    //Do something with searchText. Note: This is not a result.
  }





  Future<List<String>> _getRecentSearchesLike(String query) async {
    final pref = await SharedPreferences.getInstance();
    final allSearches = pref.getStringList("recentSearches");
    return allSearches.where((search) => search.startsWith(query)).toList();
  }

  Future<void> _saveToRecentSearches(String searchText) async {
    if (searchText == null) return; //Should not be null
    final pref = await SharedPreferences.getInstance();

    //Use `Set` to avoid duplication of recentSearches
    Set<String> allSearches =
        pref.getStringList("recentSearches")?.toSet() ?? {};

    //Place it at first in the set
    allSearches = {searchText, ...allSearches};
    pref.setStringList("recentSearches", allSearches.toList());
  }

  void _savetolist(ImgObj imgobj){
    databaseHelper.insertDoc(imgobj);
    updateList();
  }

 /* void saveData(){
    List<String> splist= homeobj.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList('homelist', splist);
  }*/

 /* void loadData(){
    List<String> splist=sharedPreferences.getStringList('homelist');
    homeobj=splist.map((item) => ImgObj.fromMap(json.decode(item))).toList();
    setState(() {});
  }*/

  void _removefromList(List<ImgObj> list){
    for(var i=0;i<list.length;i++)
    {
      databaseHelper.deleteDoc(list[i].title);
    }
    updateList();
  }

  @override
  Widget build(BuildContext context) {
    if(homeobj==null){
      homeobj=List<ImgObj>();
    }
    return Scaffold(
      appBar: _selected?getBar2():getBar1(),
      drawer: CollapsingNavDrawer(),
      body:Column(
        children: <Widget>[
          Expanded(
            child: grid?buildGrid():buildListView(),
          ),
          (_inProgress)?Container(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          ):Center()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _createAlert(context);
        },
        child: Icon(Icons.camera),
        backgroundColor: Colors.blueGrey[800],
      ),
    );
  }
}

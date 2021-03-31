import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cscanner/commonWidget/scanner.dart';
import 'package:cscanner/model/PageRoute.dart';
import 'package:cscanner/model/database_helper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:cscanner/main.dart';
import 'package:cscanner/menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

import 'insideImg.dart';

class ListTap extends StatefulWidget {
  final ImgObj currentObj;
  ListTap(this.currentObj);

  @override
  _ListTapState createState() => _ListTapState(currentObj);
}

class _ListTapState extends State<ListTap> {
  final ImgObj Obj;
  DatabaseHelper databaseHelper=DatabaseHelper();
  String title;
  bool _selected;
 // SharedPreferences sharedPreferences;
  List<String> _selectedList=[];
  List<String> _originalList=[];
  List<String> insideImg=List<String>();
  List<String> orgImg=List<String>();
  final picker=ImagePicker();
  _ListTapState(this.Obj);

  @override
  void initState() {
    updateList();
    super.initState();
    _selected = false;
    title=Obj.title;
  }

  updateList(){
    insideImg=Obj.imgs.split('|').map((String x) => x).toList();
    //orgImg=Obj.original.split('|').map((String x) => x).toList();
  }

  getBar1(){
    return AppBar(
      backgroundColor: Colors.blueGrey[800],
      title: Text("$title"),);
  }

  getBar2(BuildContext context){
    return AppBar(
        backgroundColor: Colors.blueGrey[800],
        actions: <Widget>[
          IconButton(icon: Icon(Icons.share),onPressed: (){
         /* setState(() {
              _shareImage(_selectedList);
              _selected=false;
              _selectedList=[];
            }); */
          },),
          IconButton(icon: Icon(Icons.delete),onPressed: (){setState(() {
            _removefromlist(_selectedList,_originalList);
            _selected = false;
            _selectedList = [];
            _originalList=[];
            if(insideImg.isEmpty){
              Navigator.push(context,MaterialPageRoute(builder: (context) => Home()),);
            }
          });
          },)],
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
          setState(() {
            _selected=false;
            _selectedList.removeRange(0, _selectedList.length);
            _originalList.removeRange(0,_originalList.length);
            print("slected:$_selectedList");
          });
        }
          ,), title: Text("Selected", style: TextStyle(fontSize: 24),));
  }

/*  initSharedPref() async{
    sharedPreferences=await SharedPreferences.getInstance();
    loadData();
  } */

  void _removefromlist(List<String> list,List<String> org){
    for(var i=0;i<list.length;i++){
      insideImg.remove(list[i]);
      orgImg.remove(org[i]);
    }
    setState(() {
      this.Obj.imgs=insideImg.join('|');
      this.Obj.original=orgImg.join('|');
      databaseHelper.updateDoc(Obj);
    });
    updateList();
  }

 /* void loadData(){
    List<String> inside=sharedPreferences.getStringList('$title');
    if(inside==null)
      {
        inside.add(src);
      }
    else{
      if(!inside.contains(src))
        inside.add(src);
    }
    insideImg=inside;
    setState(() {});
  } */

  void _savetolist(String imgpath,String original) {
    insideImg.add(imgpath);
    orgImg.add(original);
    setState(() {
      this.Obj.imgs=insideImg.join('|');
      this.Obj.original=orgImg.join('|');
      databaseHelper.updateDoc(Obj);
    });
    updateList();
  }

  getImage(ImageSource source,BuildContext context,ImgObj object) async {
    final pickedFile = await picker.getImage(source: source);
    print("image path: ${pickedFile.path} ");
    Navigator.push(context,ElasticPageRoute(child:Scanner(height: 350,padX: 20,imagePath: pickedFile.path,docInstance:object,)
    ));





    /*if (img != null) {
      File cropped = await ImageCropper.cropImage(
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
            toolbarColor: Colors.blueGrey[800],
            toolbarTitle: 'Scanned Image',
            statusBarColor: Colors.white30,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            backgroundColor: Colors.white,
          )
      );
      if(cropped!=null)
      {
        Directory temp = await getApplicationDocumentsDirectory();
        final String path=temp.path;
        final fileName = basename(cropped.path);
        final File localImage = await cropped.copy('$path/$fileName');
        final orgName = basename(img.path);
        final File orgImage = await img.copy('$path/$orgName');
        this.setState(() {
          _savetolist(localImage.path,orgImage.path);
        });
      }
    }*/
  }

  Future<void> _shareImage(List<String> path) async {
    for(var i=0;i<path.length;i++)
      {
        try {
          final ByteData bytes = await rootBundle.load(path[i]);
          await Share.file(
              'Share Via...', 'Image$i.png', bytes.buffer.asUint8List(), 'image/png', text: 'Shared Image!');
        } catch (e) {
          print('error: $e');
        }
      }
  }

  Widget  createGridView() {
    List<String> gridimg=insideImg;
    List<String> originalimg=orgImg;
    if(gridimg!=null){
      return GridView.builder(
        shrinkWrap: true,
        itemCount: gridimg.length,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3/4,//changed from 1
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context,index){
          final num=index+1;
          return new Stack(children: <Widget>[
            new Positioned.fill(
              bottom: 0.0,
              top: 5.0,
              child: new GridTile(
                footer: new GridTileBar(
                  title: new Text('$num'),
                  backgroundColor: Colors.transparent.withOpacity(0.3),
                ),
                child: new Image.file(File(gridimg.elementAt(index)),fit: BoxFit.cover,),
                //new Image.asset(gridimg.elementAt(index), fit: BoxFit.cover),
              ),
            ),
            new Positioned.fill(
                child: new Material(
                    color: Colors.transparent,
                    child: new InkWell(
                        onTap: (){
                          if(!_selected){
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>
                                  viewImage(imgs: gridimg, ind: num, originals: originalimg,),
                            ),
                            );
                          }
                          else if (_selected)
                          {
                            setState(() {
                              _selectedList.contains(gridimg.elementAt(index))?
                              {_selectedList.remove(gridimg.elementAt(index)),_originalList.remove(originalimg.elementAt(index))}:
                              {_selectedList.add(gridimg.elementAt(index)),_originalList.add(originalimg.elementAt(index))};
                            });
                            if(_selectedList.isEmpty)
                              {
                                setState(() {
                                  _selected=false;
                                  _selectedList=[];
                                  _originalList=[];
                                });
                              }
                            print('Original : $_originalList');
                            print('List : $_selectedList');
                          }
                          },
                        onLongPress: (){
                          this.setState(() {
                            _selectedList.add(gridimg.elementAt(index));
                            _originalList.add(originalimg.elementAt(index));
                            _selected=true;
                          });
                          print('Original : $_originalList');
                          print("List : $_selectedList");
                        }
                    ))),
            Positioned(
              right: 5,
              top:10,
              height: 15,
              child:_selected?
              _selectedList.contains(gridimg.elementAt(index))?Icon(Icons.check_box,color: Colors.white,):Icon(Icons.check_box_outline_blank,color: Colors.white,)
            :Container()),
          ]);
        },
      );
    }
    else
      return Center(
        child: Text(
          'Nothing To Show :(',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _selected?getBar2(context):getBar1(),
      body: createGridView(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          getImage(ImageSource.camera,context,widget.currentObj);
          },
        child: Icon(Icons.camera),
        backgroundColor: Colors.blueGrey[800],
        ),
    );
  }
}


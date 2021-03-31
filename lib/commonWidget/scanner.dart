

import 'dart:io';
import 'dart:ui' as ui;
import 'package:cscanner/Screens/listDetailed.dart';
import 'package:cscanner/menu.dart';
import 'package:cscanner/model/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'dart:math';



import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:async';

import 'package:path_provider/path_provider.dart';
class Scanner extends StatefulWidget {
  Scanner({Key key,this.marginTop,this.height,this.padX,this.imagePath,this.docInstance}) : super(key: key);



  final double marginTop;
  final double padX;
  final double height;
  final String imagePath;
  final ImgObj docInstance;




  @override
  ScannerState createState() => ScannerState();
}

class ScannerState extends State< Scanner> {

  File _image;
  final picker = ImagePicker();
  DatabaseHelper databaseHelper=DatabaseHelper();
  ui.Image ui_img;
  ui.Image ui_img1;
  ui.Image ui_img2;
  ui.Image ui_img3;
  ui.Image ui_img4;

  Image img;
  Image img1;
  Image img2;
  Image img3;
  Image img4;


  final double vicinity=20;

  double marginTop=160;
  Offset one;
  Offset two;
  Offset three;
  Offset four;


  Offset mid1;
  Offset mid2;
  Offset mid3;
  Offset mid4;



  double scale_x;
  double scale_y;

  double _imHeight;
  double _imWidth;
  bool _showZoom=false;
  double _height;
  bool _croppable=true;
  double _angleSum=360;
  List<int> _data;
  double  rotate_angle=0;
  bool rotateSetted=false;
  double _absHeightContainer;


  Future<ui.Image> _loadImg(File file)async{
    final data=await file.readAsBytes();
    return await decodeImageFromList(data);
  }


  void _initWithImagePath(String path) async{
    File f = File(path);


    final List<int> data=await f.readAsBytes();

    ui.Image im=await decodeImageFromList(data);
    Image tempImg=Image.file(f);

    setState(() {
      rotate_angle=0;
      _image = f;

      img1=tempImg;
      ui_img = im;

      //_data=data;
      img=tempImg;
      _imHeight=ui_img.height.toDouble();
      _imWidth=ui_img.width.toDouble();
      scale_x=_imWidth/(360-2*widget.padX);
      _height=_imHeight/scale_x;
      _absHeightContainer=_height;
      _imgScale=1;
      marginTop=160;


      scale_y=_imHeight/_height;

      one=Offset(20,20);
      two=Offset(280,20);
      three=Offset(280,_height-20);
      four=Offset(20,_height-20);

      mid1=(one+two)/2;
      mid2=(two+three)/2;
      mid3=(three+four)/2;
      mid4=(four+one)/2;

      _slopeOne = (two.dy - one.dy) / (two.dx - one.dx);
      _slopeTwo=(three.dy-two.dy)/(three.dx-two.dx);
      _slopeThree=(three.dy-four.dy)/(three.dx-four.dx);
      _slopeFour=(four.dy-one.dy)/(four.dx-one.dx);


    });
  }

  Future<void> getImage() async {
    setState(() {

      statusDone=false;
    });
    final pickedFile = await picker.getImage(source: ImageSource.camera);
     _initWithImagePath(pickedFile.path);
  }




  /*List<Object> tempList;compute(Rotate,data).then((value) async{
       tempList=value;
       ui.Image temp1=await decodeImageFromList(tempList[1]);
       ui.Image temp2= await decodeImageFromList(tempList[3]);
       ui.Image temp3=await decodeImageFromList(tempList[5]);

       setState(() {

         img2=tempList[0];
         ui_img2=temp1;
         img3=tempList[2];
         ui_img3=temp2;
         img4=tempList[4];
         ui_img4=temp3;
         rotateSetted=true;
         print("noError");
       });
       },onError: (e){print("Error!$e");});*/




  bool _isSelectedOne(double x,double y){

    return (x-widget.padX)>=one.dx-vicinity &&(x-widget.padX)<=one.dx+vicinity &&(y-marginTop)>=one.dy-vicinity &&(y-marginTop)<=one.dy+vicinity;
  }

  bool _isSelectedTwo(double x,double y){
    return (x-widget.padX)>=two.dx-vicinity &&(x-widget.padX)<=two.dx+vicinity &&(y-marginTop)>=two.dy-vicinity &&(y-marginTop)<=two.dy+vicinity;
  }

  bool _isSelectedThree(double x,double y){
    return (x-widget.padX)>=three.dx-vicinity &&(x-widget.padX)<=three.dx+vicinity &&(y-marginTop)>=three.dy-vicinity &&(y-marginTop)<=three.dy+vicinity;
  }

  bool _isSelectedFour(double x,double y){

    return (x-widget.padX)>=four.dx-vicinity &&(x-widget.padX)<=four.dx+vicinity &&(y-marginTop)>=four.dy-vicinity &&(y-marginTop)<=four.dy+vicinity;
  }

  bool _isSelectedMidOne(double x,double y){

    return (x-widget.padX)>=mid1.dx-vicinity &&(x-widget.padX)<=mid1.dx+vicinity &&(y-marginTop)>=mid1.dy-vicinity &&(y-marginTop)<=mid1.dy+vicinity;
  }

  bool _isSelectedMidTwo(double x,double y){
    return (x-widget.padX)>=mid2.dx-vicinity &&(x-widget.padX)<=mid2.dx+vicinity &&(y-marginTop)>=mid2.dy-vicinity &&(y-marginTop)<=mid2.dy+vicinity;
  }

  bool _isSelectedMidThree(double x,double y){
    return (x-widget.padX)>=mid3.dx-vicinity &&(x-widget.padX)<=mid3.dx+vicinity &&(y-marginTop)>=mid3.dy-vicinity &&(y-marginTop)<=mid3.dy+vicinity;
  }

  bool _isSelectedMidFour(double x,double y){

    return (x-widget.padX)>=mid4.dx-vicinity &&(x-widget.padX)<=mid4.dx+vicinity &&(y-marginTop)>=mid4.dy-vicinity &&(y-marginTop)<=mid4.dy+vicinity;
  }




  bool _checkBoundary(Offset off){

    if (off.dx>0 && off.dx<320 && off.dy>0 && off.dy<_height){

      return true;
    }
    else{
      print("crossed");
      return false;
    }
  }

  Offset getSelectedOffset(){
    if(draggingOne){
      return one;
    }
    else if(draggingTwo){
      return two;
    }
    else if(draggingThree){
      return three;
    }
    else{
      return four;
    }
  }


  Offset getSelectedZoomPos(Offset selected){
    if ((selected-Offset(70,90)).distance>70){
      return Offset(70,90);
    }
    else{
      return Offset(290,90);
    }
  }


  bool draggingOne=false;
  bool draggingTwo=false;
  bool draggingThree=false;
  bool draggingFour=false;

  bool draggingMidOne=false;
  bool draggingMidTwo=false;
  bool draggingMidThree=false;
  bool draggingMidFour=false;

  double  scale=1;

  void _incrementScale(){
    setState(() {
      scale+=0.2;
    });
  }

  void _DecrementScale(){
    setState(() {
      scale-=0.2;
    });
  }


  @override
  void initState(){
    // TODO: implement initState
    super.initState();
     if(widget.imagePath!=null){
      _initWithImagePath(widget.imagePath);
    }/*
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) =>  _updateChild());
    }*/

  }
  Offset selectedZoomPos;
  double  top;
  Offset selected;
  double left;
  Color color;
  double _slopeOne;
  double _midSlopeOne;
  double _slopeTwo;
  double _midSlopeTwo;
  double _slopeThree;
  double _midSlopeThree;
  double _slopeFour;
  double _midSlopeFour;



  bool lineChangedOne=false;
  bool lineChangedTwo=false;
  bool lineChangedThree=false;
  bool lineChangedFour=false;

  double _imgScale;
  bool statusDone=false;



  double _abs(double x){
    return x>0?x:-x;
  }

  double _getSlopeOne(){

    return (two.dy - one.dy) / (two.dx - one.dx);


  }
  double _getSlopeTwo(){

    return (two.dy-three.dy)/(two.dx-three.dx);

  }
  double _getSlopeThree(){

    return (three.dy-four.dy)/(three.dx-four.dx);

  }
  double _getSlopeFour(){

    return (one.dy-four.dy)/(one.dx-four.dx);

  }

  double _slope(Offset one,Offset two){
    return (two.dy-one.dy)/(two.dx-one.dx);
  }

  //angle between two line
  double abtl(slope1,slope2){
    double slope=(slope1-slope2)/(1+slope1*slope2);
    double an=atan(slope);
    if(!an.isNaN){
      an=an>0?an:an+pi;}
    else{an=slope.isNegative?-pi/2:pi/2;}


    //print("angle${an/pi}");
    return an;
  }

  void rotateLeft ()async{


    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).




    // Save the thumbnail as a PNG.
    double temp=_imHeight;
    _imHeight=_imWidth;
    _imWidth=temp;
    double new_scale = _imWidth / (360 - 2 * widget.padX);

    Offset tempOne;
    Offset tempTwo;
    Offset tempThree;
    Offset tempFour;
    _height=_imHeight/new_scale;
    tempOne=Offset((one.dy*scale_x)/new_scale,_height-((one.dx*scale_x)/new_scale));
    tempTwo=Offset((two.dy*scale_x)/new_scale,_height-((two.dx*scale_x)/new_scale));
    tempThree=Offset((three.dy*scale_x)/new_scale,_height-((three.dx*scale_x)/new_scale));
    tempFour=Offset((four.dy*scale_x)/new_scale,_height-((four.dx*scale_x)/new_scale));


    setState(() {
      rotate_angle=((rotate_angle-pi/2)%(2*pi));
      _height=_imHeight/new_scale;
      if(rotate_angle%pi!=0){
        _imgScale=320/_absHeightContainer;
        marginTop=marginTop+(_absHeightContainer/2-_height/2);

      }
      else{
        _imgScale=1;
        marginTop=160;
      }



      //ui_img=im;
      scale_x=new_scale;
      scale_y=new_scale;
      //img=tempImg;
      one=tempOne;
      two=tempTwo;
      three=tempThree;
      four=tempFour;
      mid1=(tempOne+tempTwo)/2;
      mid2=(tempTwo+tempThree)/2;
      mid3=(tempThree+tempFour)/2;
      mid4=(tempFour+tempOne)/2;
      lineChangedFour=true;lineChangedTwo=true;lineChangedThree=true;lineChangedOne=true;
    });
    print("completed");
  }

  Future<void>  rotate(List<int> byteData) async{
    List<int> data;
    print("here");
    var image = await compute(imglib.decodeImage,byteData);
    var  rotated_90= imglib.copyRotate(image,90);
    var rotated_180=imglib.copyRotate(image,180);
    var rotated_270=imglib.copyRotate(image,270);
    data=imglib.encodeJpg(rotated_90);
    img2=Image.memory(data);
    ui_img2=await decodeImageFromList(data);
    print("here");
    data=imglib.encodeJpg(rotated_180);
    img3=Image.memory(data);
    ui_img3=await decodeImageFromList(data);
    print("here");
    data=imglib.encodeJpg(rotated_270);
    img4=Image.memory(data);
    ui_img4=await decodeImageFromList(data);
    print("completed loading rotated instances");
  }

  void rotateRight ()async{
    print("ENterd Right");
    //var image = imglib.decodeImage(_data);

    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).


    //var  rotated= imglib.copyRotate(image,90);




    // Save the thumbnail as a PNG.
    //List<int> data=imglib.encodeJpg(rotated);
    /*ui.Image im;
    Image tempImg;//await decodeImageFromList(data);

    switch(rotate_angle){
      case 0:
        im=ui_img2;
        tempImg=img2;
        break;
        case 1:
      im=ui_img3;
      tempImg=img3;
      break;
      case 2:
        im=ui_img4;
        tempImg=img4;
        break;
      case 3:
        im=ui_img1;
        tempImg=img1;
        break;
    }*/

    double temp=_imHeight;
    _imHeight=_imWidth;
    _imWidth=temp;
    double new_scale = _imWidth / (360 - 2 * widget.padX);

    //Image tempImg=Image.memory(data);

    Offset tempOne;
    Offset tempTwo;
    Offset tempThree;
    Offset tempFour;

    tempOne=Offset(320-((one.dy*scale_x)/new_scale),(one.dx*scale_x)/new_scale);
    tempTwo=Offset(320-((two.dy*scale_x)/new_scale),(two.dx*scale_x)/new_scale);
    tempThree=Offset(320-((three.dy*scale_x)/new_scale),(three.dx*scale_x)/new_scale);
    tempFour=Offset(320-((four.dy*scale_x)/new_scale),(four.dx*scale_x)/new_scale);

    setState(() {
      rotate_angle=((rotate_angle+pi/2)%(2*pi));
      _height=_imHeight/new_scale;
      if(rotate_angle%pi!=0){
        _imgScale=320/_absHeightContainer;
        marginTop=marginTop+(_absHeightContainer/2-_height/2);

      }
      else{
        _imgScale=1;
        marginTop=160;
      }



      //ui_img=im;
      scale_x=new_scale;
      scale_y=new_scale;
      //img=tempImg;
      one=tempOne;
      two=tempTwo;
      three=tempThree;
      four=tempFour;
      mid1=(tempOne+tempTwo)/2;
      mid2=(tempTwo+tempThree)/2;
      mid3=(tempThree+tempFour)/2;
      mid4=(tempFour+tempOne)/2;
      lineChangedFour=true;lineChangedTwo=true;lineChangedThree=true;lineChangedOne=true;
    });
    print("completed");

  }




  List<Object> _isCroppable(){
    double theta1=abtl(_slopeFour,_slopeOne);
    double theta2=abtl(_slopeOne,_slopeTwo);
    double theta3=abtl(_slopeTwo,_slopeThree);
    double theta4=abtl(_slopeThree,_slopeFour);
    double sum=(theta1+theta2+theta3+theta4);
    sum=(180/pi)*sum;
    if (theta1>2*pi/3 || theta1<pi/6){
      return [false,sum];
    }
    else if (theta2>2*pi/3 || theta2<pi/6) {
      return [false,sum];
    }
    else if (theta3>2*pi/3 || theta3<pi/6){
      return [false,sum];
    }
    else if (theta4>2*pi/3 || theta4<pi/6){
      return [false,sum];
    }
    else{
      return [true,sum];
    }
  }

  void distReconfigure(int index){
    List<Offset> points = [one, two, three, four];
    one=points[index];
    two=points[(index+2)%4];
    Offset temp1=points[(index+1)%4];
    Offset temp2=points[(index-1)%4];
    double One1=(one-temp1).distance;
    double One2=(one-temp2).distance;
    double Two1=(two-temp1).distance;
    double Two2=(two-temp2).distance;

  }
  void  reconfigure(int index) {

    List<Offset> points = [one, two, three, four];
    int i;
    points.insert((index - 1) % 4, points.removeAt(index));
    List<double> sloped=[];
    for(i=0;i<4;i++){
      sloped.add(_slope(points[(i-1)%4],points[i%4]));
    }

    double sum=0;
    for(i=0;i<4;i++){
      sum+=abtl(sloped[(i-1)%4],sloped[i%4]);
    }
    if(sum<356 || sum>364){
      Offset temp=points[(index-1)%4];
      points[(index-1)%4]=points[(index-2)%4];
      points[(index-2)%4]=temp;

    }

    one=points[0];
    two=points[1];
    three=points[2];
    four=points[3];
    mid1=(one+two)/2;
    mid2=(two+three)/2;
    mid3=(three+four)/2;
    mid4=(four+one)/2;
    lineChangedOne=true;lineChangedTwo=true;lineChangedThree=true;lineChangedFour=true;


  }


  void _onBottomTap(int index){
    switch(index){
      case 2:
        getImage();
        break;
      case 1:rotateRight();
      break;
      case 3:
        break;
      case 0:_incrementScale();
      break;
      case 4:
        _DecrementScale();
        break;


    }
  }
  //






  _routeToListTap () async{
    Directory tempDir = await getApplicationDocumentsDirectory();
    final String path=tempDir.path;
    final fileName = basename(widget.imagePath);
    final File localImage = await File(widget.imagePath).copy('$path/$fileName');
    final File orgImage = await File(widget.imagePath).copy('$path/org$fileName');

    DateTime currDate=DateTime.now();
    ImgObj temp;
    if(widget.docInstance==null){
      String  title ="NewDoc ${currDate.toString()}";
      temp=new ImgObj(title: title,imgs:localImage.path, original: orgImage.path,createdDate:currDate.millisecondsSinceEpoch,modDate:currDate.millisecondsSinceEpoch);
    }
    else{
     temp=new ImgObj(title:widget.docInstance.title,imgs:"${widget.docInstance.imgs}|${localImage.path}", original:"${widget.docInstance.original}|${orgImage.path}",createdDate:widget.docInstance.createdDate,modDate:currDate.millisecondsSinceEpoch);
    }

    await databaseHelper.insertDoc(temp);

    Navigator.push(_context, MaterialPageRoute(builder: (context) => ListTap(temp),));



  }




  BuildContext _context;
  @override
  Widget build(BuildContext context){
    _context=context;
    Widget gestureDetector;

    if(img!=null){
      color=Theme.of(context).accentColor;
      selected=getSelectedOffset();
      selectedZoomPos=getSelectedZoomPos(selected);
      if(!(rotate_angle%pi==0)){
        top=selectedZoomPos.dy-(_height/2-scale*_height/2+scale*(selected.dy+(_absHeightContainer/2-_height/2)));
        left=selectedZoomPos.dx-(180-scale*180+scale*(selected.dx+widget.padX));
      }
      else{
        top=selectedZoomPos.dy-(_height/2-scale*_height/2+scale*selected.dy);
        left=selectedZoomPos.dx-(180-scale*180+scale*(selected.dx+widget.padX));}}

    gestureDetector=Padding(
      padding: EdgeInsets.only(left:widget.padX,right: widget.padX),
      child:img!=null? Container(
        margin: EdgeInsets.only(top:marginTop),
        child: GestureDetector(
            onPanStart: (details) {
              print("${details.globalPosition.dx},${details.globalPosition.dy}");
              if(_isSelectedOne(details.globalPosition.dx, details.globalPosition.dy)){draggingOne=true;lineChangedFour=true;lineChangedOne=true;lineChangedTwo=false;lineChangedThree=false;print("one_selected");}
              else if(_isSelectedTwo(details.globalPosition.dx, details.globalPosition.dy)){draggingTwo=true;lineChangedOne=true;lineChangedTwo=true;lineChangedThree=false;lineChangedFour=false;print("two_selected");}
              else if(_isSelectedThree(details.globalPosition.dx, details.globalPosition.dy)){draggingThree=true;lineChangedTwo=true;lineChangedThree=true;lineChangedFour=false;lineChangedOne=false;print("three_selected");}
              else if(_isSelectedFour(details.globalPosition.dx, details.globalPosition.dy)){draggingFour=true;lineChangedThree=true;lineChangedFour=true;lineChangedOne=false;lineChangedTwo=false;print("four_selected");}
              else if(_isSelectedMidOne(details.globalPosition.dx, details.globalPosition.dy)){
                draggingMidOne=true;
                if(lineChangedFour){
                  _slopeFour=(one.dy-four.dy)/(one.dx-four.dx);
                  //_interceptFour=(four.dy*one.dx-one.dy*four.dx)/(one.dx-four.dx);
                }
                if(lineChangedTwo){
                  _slopeTwo=(two.dy-three.dy)/(two.dx-three.dx);
                  //_interceptTwo=(three.dy*two.dx-two.dy*three.dx)/(two.dx-three.dx);
                }
                _midSlopeOne=(_abs(atan(_slopeFour))+_abs(atan(_slopeOne)))/2;

                print("oneMid_selected");
                lineChangedOne=true;}
              else if(_isSelectedMidTwo(details.globalPosition.dx, details.globalPosition.dy)){
                draggingMidTwo=true;print("twoMid_selected");
                if(lineChangedOne) {
                  _slopeOne = (two.dy - one.dy) / (two.dx - one.dx);

                  //_interceptOne=(one.dy*two.dx-two.dy*one.dx)/(two.dx-one.dx);
                }
                if(lineChangedThree){
                  _slopeThree=(three.dy-four.dy)/(three.dx-four.dx);
                  //_interceptThree=(four.dy*three.dx-three.dy*four.dx)/(three.dx-four.dx);
                }
                _midSlopeTwo=(_abs(atan(_slopeOne))+_abs(atan(_slopeThree)))/2;

                lineChangedTwo=true;
              }
              else if(_isSelectedMidThree(details.globalPosition.dx, details.globalPosition.dy)){
                draggingMidThree=true;print("threeMid_selected");
                if(lineChangedTwo){
                  _slopeTwo=(three.dy-two.dy)/(three.dx-two.dx);
                  //_interceptTwo=(two.dy*three.dx-three.dy*two.dx)/(three.dx-two.dx);
                }
                if(lineChangedFour){
                  _slopeFour=(four.dy-one.dy)/(four.dx-one.dx);
                  //_interceptFour=(one.dy*four.dx-four.dy*one.dx)/(four.dx-one.dx);
                }
                _midSlopeThree=(_abs(atan(_slopeTwo))+_abs(atan(_slopeFour)))/2;

                lineChangedThree=true;
              }
              else if(_isSelectedMidFour(details.globalPosition.dx, details.globalPosition.dy)) {
                draggingMidFour = true;
                print("fourMid_selected");
                if (lineChangedThree) {
                  _slopeThree = (four.dy - three.dy) / (four.dx - three.dx);
                  //_interceptThree=(three.dy*four.dx-four.dy*three.dx)/(four.dx-three.dx);
                }
                if (lineChangedOne) {
                  _slopeOne = (one.dy - two.dy) / (one.dx - two.dx);
                  //_interceptOne=(two.dy*one.dx-one.dy*two.dx)/(one.dx-two.dx);
                }
                _midSlopeFour=(_abs(atan(_slopeThree))+_abs(atan(_slopeOne)))/2;

                lineChangedFour=true;
              }

            }
            ,onPanEnd:(details) {
          print(" pan down");
          setState(() {
            _showZoom=false;
            draggingOne=draggingThree=draggingFour=draggingTwo=draggingMidOne=draggingMidTwo=draggingMidThree=draggingMidFour=false;

          });
        } ,onPanUpdate:(details) {
          if(draggingOne){
            Offset temp=Offset(one.dx+details.delta.dx,one.dy+details.delta.dy);
            setState(() {

              if(_checkBoundary(temp)){
                one=temp;
                mid1=(one+two)/2;
                mid4=(four+one)/2;

                _showZoom=true;
              }
              List<Object> list=_isCroppable();
              _slopeOne=_getSlopeOne();
              _slopeFour=_getSlopeFour();
              _croppable=list[0];
              _angleSum=list[1];


              print('_angleSum$_angleSum');


            });
          }
          else if(draggingTwo){

            Offset temp=Offset(two.dx+details.delta.dx,two.dy+details.delta.dy);

            setState(() {

              if(_checkBoundary(temp)){
                two=temp;
                mid2=(two+three)/2;
                mid1=(one+two)/2;
                _showZoom=true;
              }
              List<Object> list=_isCroppable();
              _slopeOne=_getSlopeOne();
              _slopeTwo=_getSlopeTwo();
              _croppable=list[0];
              _angleSum=list[1];
              print('_angleSum$_angleSum');



            });

          }
          else if(draggingThree){

            Offset temp=Offset(three.dx+details.delta.dx,three.dy+details.delta.dy);
            setState(() {

              if(_checkBoundary(temp)){
                three=temp;
                mid3=(three+four)/2;
                mid2=(two+three)/2;
                _showZoom=true;
              }
              List<Object> list=_isCroppable();
              _slopeTwo=_getSlopeTwo();
              _slopeThree=_getSlopeThree();
              _croppable=list[0];
              _angleSum=list[1];
              print('_angleSum$_angleSum');



            });
          }
          else if(draggingFour){

            Offset temp=Offset(four.dx+details.delta.dx,four.dy+details.delta.dy);
            setState(() {

              if(_checkBoundary(temp)){
                four=temp;
                mid4=(four+one)/2;
                mid3=(three+four)/2;
                _showZoom=true;
              }
              List<Object> list=_isCroppable();
              _slopeThree=_getSlopeThree();
              _slopeFour=_getSlopeFour();
              _croppable=list[0];
              _angleSum=list[1];
              print('_angleSum$_angleSum');



            });                                                                                                                  //60-1.5*(30+20)   300-1.5*(30+20)
          }
          //Mid Points

          else if(draggingMidOne){
            Offset temp1;
            Offset temp2;
            print("_midSlopeOne$_midSlopeOne");

            if (_midSlopeOne<pi/6) {
              temp1=Offset(one.dx+details.delta.dx,one.dy+_slopeFour*details.delta.dx);
              temp2=Offset(two.dx+details.delta.dx,two.dy+_slopeTwo*details.delta.dx);
            }
            else{
              print("inside vertical");
              temp1=Offset(one.dx+details.delta.dy/_slopeFour,one.dy+details.delta.dy);
              temp2=Offset(two.dx+details.delta.dy/_slopeTwo,two.dy+details.delta.dy);
            }
            setState(() {

              if(_checkBoundary(temp1)){
                one=temp1;
                mid4=(four+one)/2;



              }

              if(_checkBoundary(temp2)){
                two=temp2;
                mid2=(three+two)/2;


              }
              mid1=(one+two)/2;
              List<Object> list=_isCroppable();
              _croppable=list[0];
              _angleSum=list[1];

              _slopeOne=_getSlopeOne();
            }
            );
          }
          else if(draggingMidTwo){

            Offset temp1;
            Offset temp2;
            if (_midSlopeTwo<pi/6) {
              temp1=Offset(two.dx+details.delta.dx,two.dy+_slopeOne*details.delta.dx);
              temp2=Offset(three.dx+details.delta.dx,three.dy+_slopeThree*details.delta.dx);
            }
            else{
              print("inside vertical");
              temp1=Offset(two.dx+details.delta.dy/_slopeOne,two.dy+details.delta.dy);
              temp2=Offset(three.dx+details.delta.dy/_slopeThree,three.dy+details.delta.dy);
            }
            setState(() {

              if(_checkBoundary(temp1)){
                two=temp1;
                mid1=(one+two)/2;


              }

              if(_checkBoundary(temp2)){
                three=temp2;
                mid3=(three+four)/2;

              }
              mid2=(two+three)/2;
              List<Object> list=_isCroppable();
              _croppable=list[0];
              _angleSum=list[1];


              _slopeTwo=_getSlopeTwo();
            }
            );
          }
          else if(draggingMidThree){

            Offset temp1;
            Offset temp2;
            if (_midSlopeThree<pi/6) {
              temp1=Offset(three.dx+details.delta.dx,three.dy+_slopeTwo*details.delta.dx);
              temp2=Offset(four.dx+details.delta.dx,four.dy+_slopeFour*details.delta.dx);
            }
            else{
              print("inside vertical");
              temp1=Offset(three.dx+details.delta.dy/_slopeTwo,three.dy+details.delta.dy);
              temp2=Offset(four.dx+details.delta.dy/_slopeFour,four.dy+details.delta.dy);
            }
            setState(() {

              if(_checkBoundary(temp1)){
                three=temp1;
                mid2=(three+two)/2;



              }

              if(_checkBoundary(temp2)){
                four=temp2;
                mid4=(four+one)/2;


              }
              mid3=(three+four)/2;
              List<Object> list=_isCroppable();
              _croppable=list[0];
              _angleSum=list[1];

              _slopeThree=_getSlopeThree();
            }
            );
          }
          else if(draggingMidFour){
            Offset temp1;
            Offset temp2;

            if (_midSlopeFour<pi/6) {
              temp1=Offset(four.dx+details.delta.dx,four.dy+_slopeThree*details.delta.dx);
              temp2=Offset(one.dx+details.delta.dx,one.dy+_slopeOne*details.delta.dx);
            }else{
              print("inside vertical");
              temp1=Offset(four.dx+details.delta.dy/_slopeThree,four.dy+details.delta.dy);
              temp2=Offset(one.dx+details.delta.dy/_slopeOne,one.dy+details.delta.dy);
            }
            setState(() {

              if(_checkBoundary(temp1)){
                four=temp1;
                mid3=(four+three)/2;



              }

              if(_checkBoundary(temp2)){
                one=temp2;
                mid1=(one+two)/2;


              }
              mid4=(four+one)/2;
              List<Object> list=_isCroppable();
              _croppable=list[0];
              _angleSum=list[1];

              _slopeFour=_getSlopeFour();
            }
            );                                                                                                          //60-1.5*(30+20)   300-1.5*(30+20)
          }

        } ,
            child: FittedBox(child: SizedBox(width:_imWidth,height:_imHeight,child: CustomPaint(painter: myPainter(scale:scale_x,croppable:_croppable,color:color,one:Offset(one.dx*scale_x,one.dy*scale_y),two:Offset(two.dx*scale_x,two.dy*scale_y),three:Offset(three.dx*scale_x,three.dy*scale_y),four:Offset(four.dx*scale_x,four.dy*scale_y),mid1:mid1*scale_x,mid2: mid2*scale_x,mid3: mid3*scale_x,mid4: mid4*scale_x),child: Container(),)))),
      )
          :Container(),
    );

    /*else{
       gestureDetector= Padding(
        padding: const EdgeInsets.only(left:20,right: 20),
        child:Container(margin:EdgeInsets.only(top:160),child:Transform.rotate(angle:rotate_angle,child: Transform.scale(scale:_imgScale,child:Center(child: CircularProgressIndicator(),)))),
      );
    }*/
    Widget croppedzoomed=croppedZoomed(statusDone: statusDone,imgScale:_imgScale,angle:rotate_angle,child: gestureDetector,image:img,posCenter:selectedZoomPos,posWidth: 120,posHeight:120,top:top,left:left,scale:scale,showZoom: _showZoom,);

    if (croppedzoomed!=null){
      print("herer");statusDone=true;}
    return Scaffold(
      backgroundColor: Colors.black,
      //SizedBox(width:double.infinity,height: marginTop,),
      body: Column(

          children:[ui_img!=null?statusDone?
          croppedzoomed:CircularProgressIndicator():Container(),
            /*Row(children: <Widget>[CircleAvatar(child:IconButton(icon: Icon(Icons.zoom_in),onPressed: _incrementScale,)),
           CircleAvatar(child:IconButton(icon: Icon(Icons.zoom_out),onPressed: _DecrementScale,)),
           CircleAvatar(child:rotateSetted?IconButton(icon:Icon(Icons.rotate_right),onPressed: rotateRight,):CircularProgressIndicator())]),
            */]),

      bottomNavigationBar:BottomAppBar(
        color: Colors.black,
        child:  Stack(
            children:<Widget>[Container(height: 80,child:ClipPath(
              clipper: NavBarClipper1(),
              child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.teal,
                          Colors.teal.shade900,
                        ])),
              ),
            )),
              Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width,

                  child: Row(
                    mainAxisAlignment:MainAxisAlignment.spaceAround,
                    children:<Widget>[
                      Flexible(flex: 1,child: Container(width: 40,)),
                      Flexible(flex: 1,child: Container(width: 40,)),
                      Flexible(flex:2,child: _buildNavItem(onPressed:getImage,radius:40,active:false,icon:Icons.camera_alt,)),
                      Flexible(flex:1,child: _buildNavItem(onPressed:_incrementScale,radius:20,active:true,icon:Icons.zoom_in,)),
                      Flexible(flex:1,child: _buildNavItem(onPressed:  _routeToListTap,radius:20,active:true,icon:Icons.arrow_forward,)),

                    ],)
              ),
              Positioned(bottom: 25,left:10,child:_buildNavItem(onPressed: rotateRight,radius:20,active:true,icon:Icons.rotate_right,)),
              Positioned(bottom: 25,left:70,child:_buildNavItem(onPressed:rotateLeft,radius:20,active:true,icon:Icons.rotate_left,)),

            ]

        ),
      ),
    );

    /*BottomNavigationBar(items:const<BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon:Icon(Icons.zoom_in),
          title:Text("")

        ),
        BottomNavigationBarItem(
          icon:Icon(Icons.rotate_right),
            title:Text("right")
        ),
        BottomNavigationBarItem(
          icon:Icon(Icons.add_a_photo),
            title:Text("camera")
        ),
        BottomNavigationBarItem(
          icon:Icon(Icons.rotate_left),
            title:Text("left")
        ),
        BottomNavigationBarItem(
          icon:Icon(Icons.zoom_out),
            title:Text("Zoom Out")

          ),

      ],onTap: _onBottomTap,),*/

  }


}

class NavBarClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    var sw = size.width;
    var sh = size.height;
    double btc=(4*sw/12+sw/2-40*(cos(pi/6)))/2;
    print(sw);
    path.moveTo(0,sh/2);
    path.cubicTo(sw/24, sh/2, sw/24, 3*sh/4, sw/12, 3*sh/4);
    path.cubicTo( 3*sw/24, 3*sh/4, 3*sw/24, sh/2, sw/6,  sh/2);
    path.cubicTo( 5*sw/24, sh/2, 5*sw/24, 3*sh/4, 3*sw/12, 3*sh/4);
    path.cubicTo( 7*sw/24, 3*sh/4, 7*sw/24, sh/2, 4*sw/12, sh/2);

    //path.lineTo(sw/4,sh/6);
    //path.cubicTo(sw/3,sh/6 , sw/3, sh/2, sw/2-40,  sh/2);
    path.cubicTo(btc,sh/2, btc, sh/2+40*sin(pi/6),sw/2-40*(cos(pi/6)), sh/2+40*sin(pi/6));
    path.arcToPoint(Offset(sw/2+40*(cos(pi/6)),sh/2-40*sin(pi/6)),radius:Radius.circular(40));
    path.arcToPoint(Offset(sw, 0),radius:Radius.circular(1040));
    //path.cubicTo(2*sw/3,sh/6 , sw/3, sh/2, sw/2+40,  sh/2);
    //path.lineTo(2*sw/3,sh/6);


    path.lineTo(sw,sh);
    path.lineTo(0, sh);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class getBottomNavBar extends StatelessWidget{
  final List<Widget> children;
  final BuildContext context;
  getBottomNavBar({this.context,this.children});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0,
          child: ClipPath(
            clipper: NavBarClipper(),
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.teal,
                        Colors.teal.shade900,
                      ])),
            ),
          ),
        ),
        Positioned(
          bottom: 45,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:children,
          ),
        ),
        Positioned(
          bottom: 10,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text('Zoom In',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500)),
              SizedBox(
                width: 1,
              ),
              Text('Capture',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500)),
              SizedBox(
                width: 1,
              ),
              Text('Zoom Out ',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }

}



class _buildNavItem  extends StatelessWidget{
  final IconData icon;
  final bool active;
  final Function onPressed;
  final double radius;
  _buildNavItem({this.radius,this.icon,this.active,this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).accentColor,
        child: CircleAvatar(
          radius: radius-5,
          backgroundColor:
          active ? Colors.white.withOpacity(0.9) : Colors.transparent,
          child: Icon(
            icon,
            color:  Colors.black ,
          ),
        ),
      ),
    );
  }

}



class NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    var sw = size.width;
    var sh = size.height;

    path.cubicTo(sw / 12, 0, sw / 12, 2 * sh / 5, 2 * sw / 12, 2 * sh / 5);
    path.cubicTo(3 * sw / 12, 2 * sh / 5, 3 * sw / 12, 0, 4 * sw / 12, 0);
    path.cubicTo(
        5 * sw / 12, 0, 5 * sw / 12, 2 * sh / 5, 6 * sw / 12, 2 * sh / 5);
    path.cubicTo(7 * sw / 12, 2 * sh / 5, 7 * sw / 12, 0, 8 * sw / 12, 0);
    path.cubicTo(
        9 * sw / 12, 0, 9 * sw / 12, 2 * sh / 5, 10 * sw / 12, 2 * sh / 5);
    path.cubicTo(11 * sw / 12, 2 * sh / 5, 11 * sw / 12, 0, sw, 0);
    path.lineTo(sw, sh);
    path.lineTo(0, sh);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class myPainter extends CustomPainter{



  Color color;
  Offset one;
  Offset two;
  Offset three;
  Offset four;
  Offset mid1;
  Offset mid2;
  Offset mid3;
  Offset mid4;
  bool croppable;
  double count=0;
  final double scale;


  myPainter({this.scale,this.croppable,this.one,this.two,this.three,this.four,this.color,this.mid1,this.mid2,this.mid3,this.mid4});


  @override
  void paint(Canvas canvas, Size size) {
    //print("x${one.dx},y${one.dy}");
    Color cropped=croppable?color:Colors.deepOrangeAccent;
    /*if (!croppable && count==0){Fluttertoast.showToast(
        msg: "Cannot Crop Image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0
    );
    count++;}*/


    final my_paint=Paint()..style=PaintingStyle.stroke..color=cropped..strokeWidth=2*scale;
    final filled=Paint()..style=PaintingStyle.fill..color=Colors.white70;
    final pathFilled=Paint()..style=PaintingStyle.fill..color=Color.fromRGBO(0,0,0, 0.2);
    //canvas.drawImage(image,Offset(0,0) , Paint());

    canvas.drawCircle(one,10*scale, filled);
    canvas.drawCircle(two,10*scale, filled);
    canvas.drawCircle(three,10*scale, filled);
    canvas.drawCircle(four,10*scale, filled);

    canvas.drawCircle(one,10*scale, my_paint);
    canvas.drawCircle(two,10*scale, my_paint);
    canvas.drawCircle(three,10*scale, my_paint);
    canvas.drawCircle(four,10*scale, my_paint);


    canvas.drawCircle(mid1,10*scale, filled);
    canvas.drawCircle(mid2,10*scale, filled);
    canvas.drawCircle(mid3,10*scale, filled);
    canvas.drawCircle(mid4,10*scale, filled);
    canvas.drawCircle(mid1,10*scale, my_paint);
    canvas.drawCircle(mid2,10*scale, my_paint);
    canvas.drawCircle(mid3,10*scale, my_paint);
    canvas.drawCircle(mid4,10*scale, my_paint);

    canvas.drawLine(one, two,my_paint);
    canvas.drawLine(two, three, my_paint);
    canvas.drawLine(three, four, my_paint);
    canvas.drawLine(four,one,my_paint);



    Path path1=Path();
    Path path2=Path();
    path1.lineTo(one.dx, one.dy);
    path1.lineTo(two.dx,two.dy);
    path1.lineTo(three.dx,three.dy);
    path1.lineTo(four.dx,four.dy);
    path1.lineTo(one.dx,one.dy);
    path1.lineTo(0, 0);
    path1.close();


    path2.lineTo(size.width, 0);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.lineTo(0, 0);
    path2.close();

    canvas.drawPath(Path.combine(PathOperation.difference, path2, path1),pathFilled);



  }

  @override
  bool shouldRepaint(myPainter oldDelegate) =>true;

}

class zoomer extends CustomClipper<ui.Path>{
  final Offset center;
  final double width;
  final double height;

  zoomer({this.center,this.width,this.height});

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }

  @override
  ui.Path getClip(ui.Size size) {
    // TODO: implement getClip
    return Path()..addOval(Rect.fromCenter(center: center,width: width,height: height));
  }

}


class  ZoomWidget extends StatelessWidget{

  final Widget child ;
  final double top;
  final double left;
  final double width;
  final double height;
  final Offset center;

  const ZoomWidget({this.child,this.top,this.left,this.center,this.width,this.height});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(children: <Widget>[child,Positioned(top:top,left:left,child:Transform.scale(
      scale: 2.5,
      child: ClipPath(
          clipper:zoomer(center: center,width:width,height: height) ,
          clipBehavior: ui.Clip.hardEdge,
          child:child
      ),
    ),)],);
  }

}


class croppedZoomed extends StatefulWidget{
  final  Image image;
  final Offset posCenter;
  final double posWidth;
  final double posHeight;
  final double posRight;
  final double top;
  final double left;
  final double angle;
  final Widget child;
  final double scale;
  final bool showZoom;
  final double imgScale;
  final bool statusDone;





  const croppedZoomed({this.statusDone,this.imgScale,this.angle,this.image,this.posCenter,this.posWidth,this.posHeight,this.posRight,this.top,this.left,this.child,this.scale,this.showZoom});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return czState(statusDone:this.statusDone);
  }

}

class czState extends State<croppedZoomed>{

  @override

  bool statusDone;
  Widget ProgressWidget;
  bool loaded=false;


  czState({this.statusDone});


  void initState() {
    // TODO: implement initState
    super.initState();
    stack=_getStack();

  }


  Stack stack;
  Stack _getStack() {
    Widget clipPath=widget.showZoom?ClipPath(clipper: zoomer(center:widget.posCenter,width:widget.posWidth,height:widget.posHeight),child: Transform.translate(offset:Offset(widget.left,widget.top),child:Transform.scale(scale:widget.scale,child:Padding(
      padding: const EdgeInsets.only(left:20,right: 20),
      child: Container(child: Transform.rotate(angle:widget.angle,child: Transform.scale(scale:widget.imgScale,child:widget.image, )))),
    ))):Container();

    Widget border=widget.showZoom?Positioned(left:widget.posCenter.dx-60,top:widget.posCenter.dy-60,child: Container(width:120,height: 120,child:Icon(Icons.add,color:Colors.blue,),decoration: BoxDecoration(borderRadius:BorderRadius.circular(66),border: Border.all(width: 2,color: Colors.white),))):Container(width: 0,height: 0,);

    Widget image= Padding(
      padding: const EdgeInsets.only(left:20,right: 20),
      child:Container(margin:EdgeInsets.only(top:160),child:Transform.rotate(angle:widget.angle,child: Transform.scale(scale:widget.imgScale,child:widget.image))),
    );
    Stack stack= Stack(children: [image
     ,widget.child,clipPath
      ,
      border,
    ]);
    return  stack;
}

  @override
  Widget build(BuildContext context) {

    if(!statusDone){

         setState(() {
           statusDone=true;

         });
  return stack;

    }
    else{
      return _getStack();
    }

  }


}


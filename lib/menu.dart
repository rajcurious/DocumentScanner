import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

class ImgObj {
  String title;
  String imgs;
  String original;
  int createdDate;
  int modDate;

  ImgObj({this.title, this.imgs, this.original,this.createdDate,this.modDate});

  Map<String, dynamic> toMap() {
    var map=Map<String, dynamic>();
    map['title']=title;
    map['imgs']=imgs;
    map['original']=original;
    map["createdDate"]=createdDate;
    map["modDate"]=modDate;
    return map;
  }

  ImgObj.fromMapObj(Map<String, dynamic> map){
    this.title=map['title'];
    this.imgs=map['imgs'];
    this.original=map['original'];
    this.createdDate=map["createdDate"];
    this.modDate=map["modDate"];
  }
}

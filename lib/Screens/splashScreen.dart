import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cscanner/main.dart';
import 'dart:async';

import 'package:cscanner/model/nav_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splashScreen extends StatefulWidget {
  @override
  _splashScreenState createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    startTimer();
  }

  startTimer() async{
    var duration=Duration(milliseconds: 500);
    return Timer(duration, route);
  }

  /*appInitializer() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    if(prefs.getBool("initialized")==null){
      prefs.setBool("initialized",true);

    }
    else{

    }
}


  OnFirstTimeStart() async{
    Directory dir=await getExternalStorageDirectory();

  }*/




  route(){

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => Home(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xffFDCF09),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/docScanner.jpg'),
                ),
              )
            ),
            Padding(padding: EdgeInsets.only(top:20)),
            Text('ScanIt',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.white),),
            Padding(padding: EdgeInsets.all(3.0),),
            Text('Indian Scanner App',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 20.0,
        color: Colors.transparent,
        child: Center(child: Padding(
          padding: const EdgeInsets.only(bottom:5.0),
          child: Text('Choojie Developers Co. ,Ltd.',style: TextStyle(color: Colors.white70,fontSize: 12.0),),
        )),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

class viewImage extends StatefulWidget {
  final List<String> imgs;
  final List<String> originals;
  final int ind;
  viewImage({@required this.imgs,@required this.ind,@required this.originals});

  @override
  _viewImageState createState() => _viewImageState(index: ind);
}

class _viewImageState extends State<viewImage> {
  PageController controller;
 final int index;
 int ind=0;
 File image;

 _viewImageState({this.index});

 @override
  void initState() {
    controller=PageController(initialPage: this.index-1,viewportFraction: 0.95);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    imageSlider(int index){
      int total=widget.imgs.length;
      int current=index+1;
      return AnimatedBuilder(
        animation: controller,
        builder: (context,widget){
          double value=1;
          if(controller.position.haveDimensions){
            value=controller.page-index;
            value=(1-(value.abs()*0.3)).clamp(0, 1);
          }
          return Center(
              child: SizedBox(
                width: Curves.easeInOut.transform(value)*600,
                height: Curves.easeInOut.transform(value)*350,
                child: widget,
              ),
          );
        },
        child: new Stack(
          children: <Widget>[
            new Positioned.fill(
                child: Center(
                  child: Container(
                    child: Image.file(File(widget.imgs[index]),fit: BoxFit.fill,),
                    margin: EdgeInsets.all(8.0),
                  ),
                )),
            new Positioned(
              left: MediaQuery.of(context).size.width/2-30.0,
              right: MediaQuery.of(context).size.width/2-30.0,
              bottom: 20.0,
                  child: Center(
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Colors.transparent.withOpacity(0.4),
                      child: Text('$current/$total'),
                    ),
                  ),
                )
          ],
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        leading:IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
          Navigator.pop(context);
        }),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.share), onPressed: (){}),
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert),
            offset: Offset(0,100),
            itemBuilder: (context) {
              var list = List<PopupMenuEntry<Object>>();
              list.add(PopupMenuItem(
                child: Text('Re-take'),
                value: 1,
              ));
              list.add(PopupMenuDivider(
                height: 10,
              ));
              list.add(PopupMenuItem(
                child: Text('Page No'),
                value: 2,
              ));
              return list;
              }
          ),
        ],
      ),
      body:PageView.builder(
        controller: controller,
        itemCount: widget.imgs.length,
        itemBuilder: (context,position){
          return imageSlider(position);
        }),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey[800],
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 16.0,
        selectedItemColor: Colors.white,
        unselectedFontSize: 12.0,
        unselectedItemColor: Colors.white70,
        currentIndex: ind,
        onTap: (int i){
          setState((){ind = i;});},
        items: [
          new BottomNavigationBarItem(
            icon: new Icon(Icons.rotate_90_degrees_ccw),
            title: new Text("Rotate"),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.crop),
            title: new Text("Re-Crop"),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.speaker_notes),
            title: new Text("Note"),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.edit),
            title: new Text("Edit"),
          )
        ],
      ),
    );
  }
}

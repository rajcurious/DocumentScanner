import 'package:cscanner/model/nav_model.dart';
import 'package:flutter/material.dart';

import '../themes.dart';
import 'collapsing_list_tile.dart';

class CollapsingNavDrawer extends StatefulWidget {
  @override
  _CollapsingNavDrawerState createState() => _CollapsingNavDrawerState();
}

class _CollapsingNavDrawerState extends State<CollapsingNavDrawer> {
  double maxWidth=220;
  double minWidth=70;
  int currentSelectedIndex;



  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220.0,
      color: drawerBackgroudColor,
      child: Column(
        children: <Widget>[
          DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image:  AssetImage('images/back.jpg'))),
              child: Stack(children: <Widget>[
                Positioned(
                    bottom: 12.0,
                    left: 16.0,
                    child: Text("Account Info",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500))),
              ]
              )
          ),
          Expanded(
            child: ListView.separated(separatorBuilder: (context,counter){
              return Divider(height: 12.0);
            },
              itemBuilder: (context, counter){
              return CollapsingListTile(
                onTap: (){
                  setState(() {
                    currentSelectedIndex = counter;
                  });
                },
                isSelected: currentSelectedIndex == counter,
                title: navItems[counter].title,
                icon : navItems[counter].icon,
              );
            },
            itemCount: navItems.length,
            ),
          ),
        ],
      ),
    );
  }
}

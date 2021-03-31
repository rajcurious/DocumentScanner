import 'package:flutter/material.dart';

class NavigationModel{
  String title;
  IconData icon;

  NavigationModel({this.title,this.icon});
}

List<NavigationModel> navItems = [
  NavigationModel(title: "Dashboard",icon: Icons.insert_chart),
  NavigationModel(title: "Error",icon: Icons.error),
  NavigationModel(title: "Search",icon: Icons.search),
  NavigationModel(title: "Notification",icon: Icons.notifications),
  NavigationModel(title: "Settings",icon: Icons.settings),
];
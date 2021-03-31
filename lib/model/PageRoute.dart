import 'package:flutter/cupertino.dart';

class ElasticPageRoute extends PageRouteBuilder {
  final Widget child;
  ElasticPageRoute({this.child})
      : super(
    transitionDuration: Duration(seconds: 1),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      animation =
          CurvedAnimation(parent: animation, curve: Curves.elasticInOut);
      return ScaleTransition(
        scale: animation,
        alignment: Alignment.center,
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) => child,
  );
}

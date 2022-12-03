import 'package:flutter/material.dart';

class UnsolPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Unsol Page'),
        ),
        body: Text('testing'),
        //ListView.separated(itemBuilder: itemBuilder, separatorBuilder: separatorBuilder, itemCount: itemCount),
      );
    });
  }
}

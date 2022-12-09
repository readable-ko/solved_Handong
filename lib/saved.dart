import 'package:flutter/material.dart';
import 'package:solved_handong/unsolved.dart';
import 'package:styled_widget/styled_widget.dart';

import 'main.dart';

class SavedPage extends StatelessWidget {
  Widget leadingTitle(FirebaseItems item) {
    return Text(
      '${item.problemId}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  Widget leadingdescrip(FirebaseItems item) {
    String level = 'Tier ';
    if (item.level % 5 == 0) {
      level += '1';
    } else {
      level += '${6 - (item.level % 5)}';
    }
    return Text(
      level,
      style: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 10,
      ),
    );
  }

  Widget title(FirebaseItems item) {
    return <Widget>[
      Text(
        item.titleKo,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ).padding(bottom: 5),
    ].toRow(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget description(FirebaseItems item) {
    return Text(
      '맞춘사람 : ${item.acceptedUserCount}',
      style: const TextStyle(
        color: Colors.black26,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<FirebaseItems> lfsv = [];
    aps.savedList.forEach((k, e) {
      lfsv.add(e);
    });
    return Scaffold(
        body: ListView.builder(
      itemCount: lfsv.length,
      itemBuilder: (context, i) {
        return ListTile(
          leading: <Widget>[
            leadingTitle(lfsv[i]),
            leadingdescrip(lfsv[i]),
          ].toColumn(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          title: <Widget>[
            title(lfsv[i]),
            description(lfsv[i]),
          ].toColumn(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
      },
    ));
  }
}

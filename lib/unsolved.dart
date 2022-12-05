import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

class UnsolPage extends StatelessWidget {
  UnsolPage({Key? key, required this.range}) : super(key: key);
  final int range;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    ApplicationState aps = Provider.of<ApplicationState>(context, listen: false);
    List<FirebaseItems> list = [];
    if(range > 3) {
      for(int key in aps.userSolvedProblem.keys) {
        list.add(aps.userSolvedProblem[key]!);
      }
    }
    else {
      list = aps.unsolvedProblem(range);
      log('ranged list length ${list.length}');
    }

    Widget leadingTitle(FirebaseItems item) {
      return Text('${item.problemId}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }

    Widget leadingdescrip(FirebaseItems item) {
      String level = 'Tier ';
      if(item.level % 5 == 0) {
        level += '1';
      } else {
        level += '${6 - (item.level % 5)}';
      }
      return Text(level,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 10,
        ),
      );
    }

    Widget title(FirebaseItems item) {
      return Text(
      item.titleKo,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ).padding(bottom: 5);
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

    return Consumer<ApplicationState>(
      builder: (context, appState, child) {
        return OrientationBuilder(builder: (context, orientation) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Unsol Page'),
            ),
            body: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                return Column(
                  children: [
                    ListTile(
                      leading: <Widget>[
                        leadingTitle(list[i]),
                        leadingdescrip(list[i]),
                      ].toColumn(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      title: <Widget>[
                        title(list[i]),
                        description(list[i]),
                      ].toColumn(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          final url = Uri.parse('https://www.acmicpc.net/problem/${list[i].problemId}');
                          if(await canLaunchUrl(url)) {
                            launchUrl(url);
                          }
                        },
                        child: Text('풀러가기'),
                      ),
                    ),
                    const Divider(thickness: 1,),
                  ],
                );
              }
            )
            //ListView.separated(itemBuilder: itemBuilder, separatorBuilder: separatorBuilder, itemCount: itemCount),
          );
        });
      }
    );
  }
}



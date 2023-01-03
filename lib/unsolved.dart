import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'saved.dart';
import 'home.dart';
import 'main.dart';

late ApplicationState aps;

class UnsolPage extends StatefulWidget {
  UnsolPage({Key? key, required this.range}) : super(key: key);
  final int range;

  @override
  State<UnsolPage> createState() => _UnsolPageState();
}

class _UnsolPageState extends State<UnsolPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    aps = Provider.of<ApplicationState>(context, listen: false);
    List<FirebaseItems> list = [];
    if (widget.range > 3) {
      for (int key in aps.userSolvedProblem.keys) {
        list.add(aps.userSolvedProblem[key]!);
      }
    } else {
      list = aps.unsolvedProblem(widget.range);
      log('ranged list length ${list.length}');
    }

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
        aps.savedList.containsKey(item.problemId) ? const Icon(Icons.star, color: Color(0xffDAA520),) : const Icon(Icons.star_border_outlined),
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

    List<SideMenuItem> sideRail = [
      SideMenuItem(
        // Priority of item to show on SideMenu, lower value is displayed at the top
        priority: 0,
        title: 'Home',
        onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
        icon: const Icon(Icons.home),
        // badgeContent: Text(
        //   '3',
        //   style: TextStyle(color: Colors.white),
        // ),
      ),
      SideMenuItem(
        priority: 1,
        title: 'Profile',
        onTap: () => Navigator.of(context).pushNamed('/profile'),
        icon: const Icon(Icons.account_circle_rounded),
      ),
      SideMenuItem(
        priority: 2,
        title: 'Saved',
        onTap: () => Navigator.of(context).pushNamed('/saved'),
        icon: const Icon(Icons.save),
      ),
      SideMenuItem(
        priority: 2,
        title: 'Exit',
        onTap: () => print('hee'),
        icon: const Icon(Icons.exit_to_app),
      ),
    ];

    PageController pagecontroller = PageController();
    Widget _buildPC() {
      return Consumer<ApplicationState>(
        builder: (context, appState, child) => Scaffold(
          appBar: AppBar(
            title: const Text('Main Page'),
          ),
          body: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flexible(
              //   flex: 1,
              //   child: SideMenu(
              //     items: sideRail,
              //     controller: pagecontroller,
              //
              //   ),
              // ),
              Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0,10,15,0),
                    child: Column(
                      children: [
                        const UserCard(),
                        const ActionsRow(),
                        Expanded(child: SavedPage()),
                      ],
                    ),
                  )),
              Flexible(
                flex: 3,
                child: ListView.builder(
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
                            trailing: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  final url = Uri.parse(
                                      'https://www.acmicpc.net/problem/${list[i].problemId}');
                                  if (await canLaunchUrl(url)) {
                                    launchUrl(url);
                                  }
                                },
                                child: const Text('풀러가기'),
                              ),
                              SizedBox(
                                height: 20,
                                child: TextButton(
                                  onPressed: () async {
                                    if (!(FirebaseAuth
                                        .instance.currentUser!.isAnonymous)) {
                                      aps.savedList.containsKey(list[i].problemId)
                                          ? aps.savedList.remove(list[i].problemId)
                                          : aps.savedList[list[i].problemId] = list[i];
                                      aps.setUserInfo();
                                      setState(() {
                                      });
                                    }
                                  },
                                  child: const Text('찜하기'),
                                ),
                              )
                            ].toColumn(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                            )),
                        const Divider(
                          thickness: 1,
                        ),
                      ],
                    );
                  }),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildMobile() {
      return Scaffold(
          resizeToAvoidBottomInset: false,
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
                    trailing: <Widget>[
                      TextButton(
                        onPressed: () async {
                          final url = Uri.parse(
                              'https://www.acmicpc.net/problem/${list[i].problemId}');
                          if (await canLaunchUrl(url)) {
                            launchUrl(url);
                          }
                        },
                        child: const Text('풀러가기'),
                      ),
                      SizedBox(
                        height: 20,
                        child: TextButton(
                          onPressed: () async {
                            if (!(FirebaseAuth
                                .instance.currentUser!.isAnonymous)) {
                              aps.savedList.containsKey(list[i].problemId)
                                  ? aps.savedList.remove(list[i].problemId)
                                  : aps.savedList[list[i].problemId] = list[i];
                              aps.setUserInfo();
                              setState(() {
                              });
                            }
                          },
                          child: const Text('찜하기'),
                        ),
                      )
                    ].toColumn(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                    )),
                const Divider(
                  thickness: 1,
                ),
              ],
            );
          }),
        //ListView.separated(itemBuilder: itemBuilder, separatorBuilder: separatorBuilder, itemCount: itemCount),
      );
    }

    return Consumer<ApplicationState>(builder: (context, appState, child) {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints constrained) {
        return Container(
          width: constrained.maxWidth,
          height: constrained.maxHeight,
          child: (constrained.maxWidth / constrained.maxHeight) >= 1.1
              ? _buildPC()
              : _buildMobile(),
        );
      });
    });
  }
}

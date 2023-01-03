import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:solved_handong/unsolved.dart';
import 'package:styled_widget/styled_widget.dart';

import 'main.dart';

class RankPage extends StatelessWidget {
  const RankPage({super.key});

  Widget leadingTitle(int rank) {
    return Text(
      '$rank 등',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  Widget title(HGUer item) {
    return Text(
      '${item.handle}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ).padding(bottom: 5);
  }

  Widget trail(HGUer item) {
    return Text(
      '${item.solvedCount.toString()} 해결',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ).padding(bottom: 5);
  }

  @override
  Widget build(BuildContext context) {
    List<HGUer> userRankList = aps.userList;
    return Scaffold(
      body: ListView.separated(
        shrinkWrap: true,
        itemCount: userRankList.length,
        itemBuilder: (context, i) {
          return ListTile(
            leading: leadingTitle(i + 1),
            title: title(userRankList[i]),
            trailing: trail(userRankList[i]),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          height: 10.0,
        ),
      ),
    );
  }
}

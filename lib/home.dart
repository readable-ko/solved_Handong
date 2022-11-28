// App design: https://dribbble.com/shots/6459693-Creative-layout-design
//This main page is Ref from https://github.com/ReinBentdal/styled_widget/wiki/demo_app git example.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    page({required Widget child}) => Styled.widget(child: child)
        .padding(vertical: 30, horizontal: 20)
        .constrained(minHeight: MediaQuery.of(context).size.height - (2 * 30))
        .scrollable();

    return Consumer<ApplicationState>(
      builder: (context, appState, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Main Page'),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text('Main Menu'),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: (){Navigator.of(context).pushReplacementNamed('/home');},
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_rounded),
                title: const Text('Profile'),
                onTap: (){Navigator.of(context).pushNamed('/profile');},
              )
            ],
          ),
        ),
        body: Column(
          children: const [
            UserCard(),
            ActionsRow(),
            Settings(),
          ],
        ).parent(page),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({super.key});

  Widget _buildUserRow() {
    return Consumer<ApplicationState>(
        builder: (context, appState, child) => <Widget>[
              const Icon(Icons.account_circle)
                  .decorated(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  )
                  .constrained(height: 50, width: 50)
                  .padding(right: 10),
              <Widget>[
                Text(
                  '${(appState.loggedIn) ? FirebaseAuth.instance.currentUser!.displayName : "Anonymous"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ).padding(bottom: 5),
                Text(
                  '${(appState.loggedIn) ? FirebaseAuth.instance.currentUser!.email : "sample@handong.edu"}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
            ].toRow());
  }

  Widget _buildUserStats() {
    return <Widget>[
      _buildUserStatsItem('846', '해결함'),
      _buildUserStatsItem('51', '등'),
      _buildUserStatsItem('267', '포인트'),
      _buildUserStatsItem('39', '출석'),
    ]
        .toRow(mainAxisAlignment: MainAxisAlignment.spaceAround)
        .padding(vertical: 10);
  }

  Widget _buildUserStatsItem(String value, String text) => <Widget>[
        Text(value).fontSize(20).textColor(Colors.white).padding(bottom: 5),
        Text(text).textColor(Colors.white.withOpacity(0.6)).fontSize(12),
      ].toColumn();

  @override
  Widget build(BuildContext context) {
    return <Widget>[_buildUserRow(), _buildUserStats()]
        .toColumn(mainAxisAlignment: MainAxisAlignment.spaceAround)
        .padding(horizontal: 20, vertical: 10)
        .decorated(
            color: const Color(0xff3977ff), borderRadius: BorderRadius.circular(20))
        .elevation(
          5,
          shadowColor: const Color(0xff3977ff),
          borderRadius: BorderRadius.circular(20),
        )
        .height(175)
        .alignment(Alignment.center);
  }
}

class ActionsRow extends StatelessWidget {
  const ActionsRow({super.key});

  Widget _buildActionItem(String name, IconData icon) {
    final Widget actionIcon = Icon(icon, size: 20, color: const Color(0xFF42526F))
        .alignment(Alignment.center)
        .ripple()
        .constrained(width: 50, height: 50)
        .backgroundColor(const Color(0xfff6f5f8))
        .clipOval()
        .padding(bottom: 5);

    final Widget actionText = Text(
      name,
      style: TextStyle(
        color: Colors.black.withOpacity(0.8),
        fontSize: 12,
      ),
    );

    return <Widget>[
      actionIcon,
      actionText,
    ].toColumn().padding(vertical: 20);
  }

  @override
  Widget build(BuildContext context) => <Widget>[
        _buildActionItem('Point', Icons.attach_money),
        _buildActionItem('Saved', Icons.favorite),
        _buildActionItem('Message', Icons.message),
        _buildActionItem('Service', Icons.room_service),
      ].toRow(mainAxisAlignment: MainAxisAlignment.spaceAround);
}

class SettingsItemModel {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  const SettingsItemModel({
    required this.color,
    required this.description,
    required this.icon,
    required this.title,
  });
}

const List<SettingsItemModel> settingsItems = [
  SettingsItemModel(
    icon: Icons.arrow_circle_right_outlined,
    color: Colors.brown, //Color(0xff8D7AEE),
    title: '브론즈',
    description: '우리학교에서 풀지 못한 브론즈 문제',
  ),
  SettingsItemModel(
    icon: Icons.arrow_circle_right_outlined,
    color: Color(0xffC0C0C0), //Color(0xffF468B7),
    title: '실버',
    description: '우리학교에서 풀지 못한 실버 문제',
  ),
  SettingsItemModel(
    icon: Icons.arrow_circle_right_outlined,
    color: Color(0xffFEC85C),
    title: '골드',
    description: '우리학교에서 풀지 못한 골드 문제',
  ),
  SettingsItemModel(
    icon: Icons.arrow_circle_right_outlined,
    color: Color(0xff5FD0D3),
    title: 'HOT',
    description: '우리학교에서 많이 풀린 문제',
  ),
  SettingsItemModel(
    icon: Icons.question_answer,
    color: Color(0xffBFACAA),
    title: 'Support',
    description: 'We are here to help',
  ),
];

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) => settingsItems
      .map((settingsItem) => SettingsItem(
            settingsItem.icon,
            settingsItem.color,
            settingsItem.title,
            settingsItem.description,
          ))
      .toList()
      .toColumn();
}

class SettingsItem extends StatefulWidget {
  const SettingsItem(this.icon, this.iconBgColor, this.title, this.description, {super.key});

  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String description;

  @override
  _SettingsItemState createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    settingsItem({required Widget child}) => Styled.widget(child: child)
        .alignment(Alignment.center)
        .borderRadius(all: 15)
        .ripple()
        .backgroundColor(Colors.white, animate: true)
        .clipRRect(all: 25) // clip ripple
        .borderRadius(all: 25, animate: true)
        .elevation(
          pressed ? 0 : 20,
          borderRadius: BorderRadius.circular(25),
          shadowColor: Color(0x30000000),
        ) // shadow borderRadius
        .constrained(height: 80)
        .padding(vertical: 12) // margin
        .gestures(
          onTapChange: (tapStatus) => setState(() => pressed = tapStatus),
          onTapDown: (details) => print('tapDown'),
          onTap: () => print('onTap'),
        )
        .scale(all: pressed ? 0.95 : 1.0, animate: true)
        .animate(const Duration(milliseconds: 150), Curves.easeOut);

    final Widget icon = Icon(widget.icon, size: 20, color: Colors.white)
        .padding(all: 12)
        .decorated(
          color: widget.iconBgColor,
          borderRadius: BorderRadius.circular(30),
        )
        .padding(left: 15, right: 10);

    final Widget title = Text(
      widget.title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ).padding(bottom: 5);

    final Widget description = Text(
      widget.description,
      style: const TextStyle(
        color: Colors.black26,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );

    return settingsItem(
      child: <Widget>[
        icon,
        <Widget>[
          title,
          description,
        ].toColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ].toRow(),
    );
  }
}

//This code is Ref by https://firebase.google.com/codelabs/firebase-get-to-know-flutter#4

// 유저가 푼 문제에 cnt++ 해서 학교에서 가장 많이 푼 찾기 가능.
// 한동대학교 유저 https://solved.ac/api/v3/ranking/in_organization?organizationId=412
// 사용자가 푼 문제 https://solved.ac/api/v3/search/problem?query=s%40fpqpsxh
// 사용자가 푼 문제 https://solved.ac/api/v3/search/problem?query=s%40fpqpsxh&page=7 페이지가 있다 스벌.
// 사용자가 푼 문제 https://solved.ac/api/v3/search/problem?query=solved_by%3A{user_id}&sort=level&direction=desc
// 사용자 정보 https://solved.ac/api/v3/user/show?handle=fpqpsxh (여기 토탈 문 문제수랑 대학 순위도 있음)
// https://solved.ac/api/v3/search/user?query=fpqpsxh
// 로그인된 유저 https://solved.ac/api/v3/account/verify_credentials
// 난이도 별 문제 긁어오기 https://solved.ac/api/v3/search/problem?query=tier%3A{level}
import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:solved_handong/src/provider.dart';
import 'package:solved_handong/unsolved.dart';
import 'package:styled_widget/styled_widget.dart';

import 'firebase_options.dart';
import 'package:flutter/material.dart';

import 'home.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: ((context, child) => const App()),
    ),
  ]));
}

class App extends StatelessWidget {
  const App({super.key});
  // final Stream<ApplicationState> _checker = (() {
  //   late final StreamController<ApplicationState> controller;
  //   controller = StreamController<ApplicationState>(
  //     onListen: () async {
  //       ApplicationState().loggedIn;
  //       FirebaseAuth.instance.authStateChanges();
  //     },
  //   );
  //   return controller.stream;
  // })();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) {
          return const SafeArea(child: HomePage());
        },
        '/profile': (context) {
          return ProfileScreen(
            appBar: AppBar(
              title: const Text('User Profile'),
            ),
            actions: [
              SignedOutAction((context) {
                Navigator.of(context).pop();
              })
            ],
            children: const [
              Divider(),
              Padding(
                padding: EdgeInsets.all(2),
                child: Text('Test'),
              ),
              Divider(),
            ],
          );
        },
        '/unsol': (context) {
          return UnsolPage();
        }
      },
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SignInScreen(
              providerConfigs: const [
                EmailProviderConfiguration(),
                GoogleProviderConfiguration(
                    clientId:
                        '231870076850-mhut750a5il7hqim52d5g646b474uht1.apps.googleusercontent.com'),
              ],
              headerBuilder: (context, constraints, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Lottie.asset('asset/ball.json'),
                  ),
                );
              },
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: action == AuthAction.signIn
                      ? const Text('Welcome to Solved-Handong, please Sign In!')
                      : const Text('Welcome to Solved-Handong, please Sign Up!'),
                );
              },
              footerBuilder: (context, action) {
                return const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    '로그인을 통해 약관 동의를 대신하며, 서비스를 이용할 수 있습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
              sideBuilder: (context, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Lottie.asset('asset/ball.json'),
                  ),
                );
              },
            );
          }

          return const HomePage();
        },
      ),
    );
  }
}

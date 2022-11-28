//This code is Ref by https://firebase.google.com/codelabs/firebase-get-to-know-flutter#4
import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'firebase_options.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseAuth.instance.authStateChanges();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }

      notifyListeners();
    });
  }
}

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

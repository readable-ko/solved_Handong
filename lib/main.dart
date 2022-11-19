import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:google_fonts/google_fonts.dart';
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

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: ((context, child) => const App()),
    ),
  ]));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) {
          return HomePage();
        },
        '/sign-in': ((context) {
          return SignInScreen(
            actions: [
              ForgotPasswordAction((context, email) {
                Navigator.of(context).pushNamed('/forgot-password', arguments: {'email': email});
              }),
              AuthStateChangeAction((context, state) {
                if(state is SignedIn || state is UserCreated) {
                  var user = (state is SignedIn)
                      ? state.user
                      : (state as UserCreated).credential.user;
                  if(user == null) {
                    return;
                  }
                  if(state is UserCreated) {
                    user.updateDisplayName(user.email!.split('@')[0]);
                  }
                  if(!user.emailVerified) {
                    user.sendEmailVerification();
                    const snackbar = SnackBar(
                      content: Text(
                          'Please check your email to verify your email address.\n'
                              '이메일 등록 확인을 위해 이메일을 확인해주세요.'));
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  }
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              }),
            ],
          );
        }),
        '/forgot-password': ((context) {
          final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

          return ForgotPasswordScreen(
            email: arguments?['email'] as String,
            headerMaxExtent: 200,
          );
        }),
        '/profile': ((context) {
          return ProfileScreen(
            providers: [],
            actions: [
              SignedOutAction((context) {Navigator.of(context).pushReplacementNamed('/home');}),
            ],
          );
        }),
      },
      title: 'Handong Solved',

    );
  }
}
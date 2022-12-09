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
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
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
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ApplicationState(),
        builder: ((context, child) => const App()),
      ),
    ],
  ),
  );
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
      theme: ThemeData(
        primaryColor: const Color(0xff3977ff),
      ),
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
                      : const Text(
                          'Welcome to Solved-Handong, please Sign Up!'),
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

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  RefreshTime firebaseTime = RefreshTime(
      time: Timestamp.fromDate(DateTime.now()), userName: 'fpqpsxh');
  bool apiRest = false;
  Map<String, int> _changedUser = {};
  List<HGUer> _userList = [];
  List<HGUer> get userList => _userList;
  Map<int, FirebaseItems> _userSolvedProblem = {};
  Map<int, FirebaseItems> get userSolvedProblem => _userSolvedProblem;
  List<List <FirebaseItems>> _unsolvedProblem = [[],[],[],[]];
  List<FirebaseItems> unsolvedProblem(int idx) => _unsolvedProblem[idx];
  Map<int, FirebaseItems> savedList = {} ;

  Future setUserInfo() async {
    if(!FirebaseAuth.instance.currentUser!.isAnonymous) {
      FirebaseFirestore.instance.collection('loginuser').doc(FirebaseAuth.instance.currentUser!.uid)
          .set(<String, dynamic>{
        "email": FirebaseAuth.instance.currentUser!.email,
        "name": FirebaseAuth.instance.currentUser!.displayName,
        "uid": FirebaseAuth.instance.currentUser!.uid,
        "saved": savedList.keys
      });
    }
  }

  Future getUserInfo() async {
    if(!FirebaseAuth.instance.currentUser!.isAnonymous) {
      FirebaseFirestore.instance.collection('loginuser').snapshots().listen(
          (snapshot) {
            for(final document in snapshot.docs) {
              if(document.data()['uid'] == FirebaseAuth.instance.currentUser!.uid.toString()) {
                List<dynamic> tmp = document.data()['saved'] as List<dynamic>;
                log('tmp length is ${tmp.length}');
                if(tmp.isEmpty || tmp == null) return;
                for(final prob in tmp) {
                  log('prob is ${prob}');
                  for(int lev = 0 ; lev < 4 ; lev++) {
                    for(final probUn in _unsolvedProblem[lev]) {
                      if(probUn.problemId == prob) {
                        savedList[prob] = probUn;
                      }
                    }
                  }
                }
              }
            }
          }
      );
      notifyListeners();
    }
  }

  Future setUserinfo() async{
    final User? user_login = FirebaseAuth.instance.currentUser;
    final fsi = FirebaseFirestore.instance;
    final QuerySnapshot result = await fsi.collection('loginuser').get();
    final List<DocumentSnapshot> documents = result.docs;
    List<String> localUserId = [];
    documents.forEach((data) {
      localUserId.add(data['uid']);
    });
    if(!(user_login!.isAnonymous)){
      if(!localUserId.contains(user_login.uid)) {
        await FirebaseFirestore.instance.collection("loginuser").add({
          "email": user_login.email,
          "name": user_login.displayName,
          "uid": user_login.uid,
        });
      }
      // name_user= user_login.displayName!;
      // url_user = user_login.photoURL!;
      // email_user = user_login.email!;
      // uid_google = user_login.uid;
    }
    else{
      if(!localUserId.contains(user_login.uid)) {
        await FirebaseFirestore.instance.collection("loginuser").add({
          "uid": user_login.uid,
        });
      }
      // name_user= user_login.uid;
      // url_user =  'http://handong.edu/site/handong/res/img/logo.png';
      // email_user= "Anonymous";
      // hashtag = "";
    }
  }

  Future<void> getUnsolvedList() async {
    //https://solved.ac/api/v3/search/problem?query=*s5..s1&page=2
    List<String> problemLevel = ['b5...b1', 's5...s1', 'g5...g1', 'p5...p1'];
    for(String matcher in problemLevel) {
      for(int i = 1 ; i <= 5 ; i++) {
        final response = await http.get(Uri.parse(
          'https://solved.ac/api/v3/search/problem?query=*$matcher&page=$i'
        ));

        log("[getUnsolvedList] tier: $matcher page: $i");
        if(response.statusCode == 200) {
          final parse = jsonDecode(response.body);

          List<Items> tmp = (parse['items'] as List).map((json) => Items.fromJson(json)).toList();

          for(Items document in tmp) {
            List<String> tagsName = [];
            List<int> tagsId = [];
            if (document.tags != null) {
              for (Tags tag in document.tags!) {
                tagsName.add(tag.displayNames![0].name.toString());
                tagsId.add(tag.bojTagId!.toInt());
              }
            }

            //somebody doesn't solved this problem.
            if(!(_userSolvedProblem.containsKey(document.problemId))) {
              FirebaseFirestore.instance
                  .collection('unsolved$matcher')
                  .doc(document.problemId.toString())
                  .set(<String, dynamic>{
                'title': document.titleKo,
                'problemId': document.problemId,
                'acceptedUserCount': document.acceptedUserCount,
                'level': document.level,
                'tagsName': tagsName,
                'tagsId': tagsId,
              });
            } else {
              FirebaseFirestore.instance.collection('unsolved$matcher').doc(document.problemId.toString()).delete();
            }
          }
        }
        else {
          log('error:${response.statusCode}');
          apiRest = false;
          FirebaseFirestore.instance
              .collection('Info')
              .doc('refresh')
              .set(<String, dynamic>{
            'time': FieldValue.serverTimestamp(),
            'userName': 'get unsolved problem',
          });
          return;
        }
      }
    }
  }

  //get the user list for get each user's solved problem list.
  Future<void> getUserList() async {
    //https://solved.ac/api/v3/ranking/in_organization?organizationId=412

    final response = await http.get(Uri.parse(
        'https://solved.ac/api/v3/ranking/in_organization?organizationId=412&page=1'));
    _changedUser = {};
    if (response.statusCode == 200) {
      final parser = jsonDecode(response.body);
      int loopTime = (parser['count']);
      List<HGUer> tmp = (parser['items'] as List)
          .map((json) => HGUer.fromJson(json))
          .toList();

      for (HGUer document in tmp) {
        FirebaseFirestore.instance
            .collection('user')
            .doc(document.handle)
            .snapshots()
            .listen((value) {
          if (value.data() == null) {
            log('value is null');
          } else if (document.solvedCount != value.data()!['solvedCount']) {
            log('[getUserList] data is diff, get the solvedCount from user');
            _changedUser[document.handle.toString()] =
                document.solvedCount!.toInt();
          }
        });

        FirebaseFirestore.instance
            .collection('user')
            .doc(document.handle.toString())
            .set(<String, dynamic>{
          'handle': document.handle,
          'solvedCount': document.solvedCount,
          'maxStreak': document.maxStreak,
          'rank': document.rank,
          'reverseRivalCount': document.reverseRivalCount,
        });
      }

      for (int i = 2; i <= (loopTime / 50).ceil(); i++) {
        final subresponse = await http.get(Uri.parse(
            'https://solved.ac/api/v3/ranking/in_organization?organizationId=412&page=$i'));

        if (subresponse.statusCode == 200) {
          final subparser = jsonDecode(subresponse.body);
          int loopTime = (subparser['count']);
          List<HGUer> subtmp = (subparser['items'] as List)
              .map((json) => HGUer.fromJson(json))
              .toList();

          for (HGUer document in subtmp) {
            final dbCount = FirebaseFirestore.instance
                .collection('user')
                .doc(document.handle)
                .snapshots()
                .listen((value) {
              if (value.data() == null) {
                log('value is null');
              } else if (document.solvedCount != value.data()!['solvedCount']) {
                log('[getUserList] data is diff, get the solvedCount from user ${document.handle}');
                _changedUser[document.handle.toString()] =
                    document.solvedCount!.toInt();
              }
            });
            FirebaseFirestore.instance
                .collection('user')
                .doc(document.handle.toString())
                .set(<String, dynamic>{
              'handle': document.handle,
              'solvedCount': document.solvedCount,
              'maxStreak': document.maxStreak,
              'rank': document.rank,
              'reverseRivalCount': document.reverseRivalCount,
            });
          }
        }
      }
    }
    log('changedUserlist length: ${_changedUser.length}');
  }

  Future<void> getUserSolvedAPI(String handle, int solvedCount) async {
    for (int i = 1; i <= (solvedCount / 50).ceil(); i++) {
      final response = await http.get(Uri.parse(
          'https://solved.ac/api/v3/search/problem?query=s%40$handle&page=$i'));

      log("[getUserSolvedAPI] handle: $handle count: ${solvedCount.toString()}");
      if (response.statusCode == 200) {
        final parser = jsonDecode(response.body);

        List<Items> tmp = (parser['items'] as List)
            .map((json) => Items.fromJson(json))
            .toList();

        // Map<String, dynamic> parsed = jsonDecode(response.body);
        //var resJson = UserSolved.fromJson(parsed);
        // log('This is  ${tmp[0].problemId}');
        // log('${tmp[0].tags![0].displayNames![0].name}');
        // log('${tmp[0].tags![0].bojTagId}');

        for (Items document in tmp) {
          List<String> tagsName = [];
          List<int> tagsId = [];
          if (document.tags != null) {
            for (Tags tag in document.tags!) {
              tagsName.add(tag.displayNames![0].name.toString());
              tagsId.add(tag.bojTagId!.toInt());
            }
          }

          FirebaseFirestore.instance
              .collection('usersolved')
              .doc(document.problemId.toString())
              .set(<String, dynamic>{
            'title': document.titleKo,
            'problemId': document.problemId,
            'acceptedUserCount': document.acceptedUserCount,
            'level': document.level,
            'tagsName': tagsName,
            'tagsId': tagsId,
          });
        }
      } else {
        log('error:${response.statusCode}');
        apiRest = false;
        FirebaseFirestore.instance
            .collection('Info')
            .doc('refresh')
            .set(<String, dynamic>{
          'time': FieldValue.serverTimestamp(),
          'userName': handle,
        });
        return;
      }
    }
  }

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

    RefreshTime rftime = RefreshTime(
        time: Timestamp.fromDate(DateTime.now()), userName: 'fpqpsxh');

    FirebaseFirestore.instance
        .collection('Info')
        .snapshots()
        .listen((snapshot) {
      for (final document in snapshot.docs) {
        rftime = RefreshTime(
            time: document.data()['time'] as Timestamp,
            userName: document.data()['userName'] as String);
      }
      firebaseTime = rftime;
      //If recent updated API time is more than 15.
      if (rftime.time.toDate().difference(DateTime.now()).inMinutes.abs() >
          5) {
        apiRest = true;
        log("[init] firebase log time - now is more than 15 min");
      }
      notifyListeners();
    });

    //TODO user info.
    setUserinfo();

    //check fire base time
    if(firebaseTime.time.toDate().difference(DateTime.now()).inMinutes.abs() > 5) {
      log('[checking Time]');
      apiRest = true;
      notifyListeners();
    }
    else {
      log('Time is less than 5 min');
    }

    //TODO: just stoped for firebase read
    //if time, start loop
    // if(apiRest == true) {
    //   //getUserList();
    //   log(_changedUser.keys.toString());
    //   String lastFixedHandle = "";
    //
    //   if(_changedUser.isNotEmpty) {
    //     for (var value in _changedUser.keys) {
    //       log("[changedUser] ${value}value is :${_changedUser[value]!}");
    //       lastFixedHandle = value;
    //       getUserSolvedAPI(value, _changedUser[value]!.toInt());
    //     }
    //
    //     FirebaseFirestore.instance.collection('Info').doc('refresh')
    //         .set(<String, dynamic>{
    //     'time': FieldValue.serverTimestamp(),
    //     'userName': lastFixedHandle,});
    //     apiRest = false;
    //   }
    //
    //   getUnsolvedList();
    //   notifyListeners();
    // }

    //this is get for user solved problem list
    FirebaseFirestore.instance
        .collection('usersolved')
        .snapshots()
        .listen((snapshot) {
      _userSolvedProblem = {};
      log('[userSolvedProblemList] : ${_userSolvedProblem.length}');
      for (final document in snapshot.docs) {
        _userSolvedProblem[document.data()['problemId'] as int]=
          FirebaseItems(
            titleKo: document.data()['title'] as String,
            problemId: document.data()['problemId'] as int,
            acceptedUserCount: document.data()['acceptedUserCount'] as int,
            tagsName: document.data()['tagsName'] as List<dynamic>,
            tagsId: document.data()['tagsId'] as List<dynamic>,
            level: document.data()['level'] as int,
          );
      }
      log('[userSolvedProblemList] : ${_userSolvedProblem.length}');
      notifyListeners();
    });

    //this is for get the user list
    FirebaseFirestore.instance
        .collection('user').orderBy('solvedCount', descending: true)
        .snapshots()
        .listen((snapshot) {
      _userList = [];
      //log(_userList.length.toString());
      for (final document in snapshot.docs) {
        _userList.add(
          HGUer(
            handle: document.data()['handle'] as String,
            solvedCount: document.data()['solvedCount'] as int,
            reverseRivalCount: document.data()['reverseRivalCount'] as int,
            maxStreak: document.data()['maxStreak'] as int,
            rank: document.data()['rank'] as int,
          ),
        );
      }
      for(HGUer user in _userList) {
        //log(user.handle.toString() + user.solvedCount!.toString());
      }
      //log(_userList.length.toString());
      notifyListeners();
    });


    for(int idx = 0 ; idx < 4 ; idx++) {
      List<String> matchLevel = ['b5...b1', 's5...s1', 'g5...g1', 'p5...p1'];

      FirebaseFirestore.instance.collection('unsolved${matchLevel[idx]}').snapshots().listen((snapshot) {
        List<FirebaseItems> tmp = [];

        for(final document in snapshot.docs) {
          tmp.add(
            FirebaseItems(
                problemId: document.data()['problemId'] as int,
                titleKo: document.data()['title'] as String,
                acceptedUserCount: document.data()['acceptedUserCount'] as int,
                level: document.data()['level'] as int,
                tagsName: document.data()['tagsName'] as List<dynamic>,
                tagsId: document.data()['tagsId'] as List<dynamic>,
            )
          );
        }
        _unsolvedProblem[idx] = tmp;
        log('[unsovledList] : ${_unsolvedProblem[idx].length}');
        notifyListeners();
      });

    }

    getUserInfo();
  }
}

class FirebaseItems {
  int problemId;
  String titleKo;
  int acceptedUserCount;
  int level;
  List<dynamic> tagsName;
  List<dynamic> tagsId;

  FirebaseItems(
      {required this.problemId,
      required this.titleKo,
      required this.acceptedUserCount,
      required this.level,
      required this.tagsName,
      required this.tagsId});
}

class RefreshTime {
  Timestamp time;
  String? userName;

  RefreshTime({required this.time, this.userName});
}

class UserSolved {
  int? count;
  List<Items>? items;

  UserSolved({this.count, this.items});

  UserSolved.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['count'] = count;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  int? problemId;
  String? titleKo;
  int? acceptedUserCount;
  int? level;
  List<Tags>? tags;

  Items(
      {this.problemId,
      this.titleKo,
      this.acceptedUserCount,
      this.level,
      this.tags});

  Items.fromJson(Map<String, dynamic> json) {
    problemId = json['problemId'];
    titleKo = json['titleKo'];
    acceptedUserCount = json['acceptedUserCount'];
    level = json['level'];
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(Tags.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['problemId'] = problemId;
    data['titleKo'] = titleKo;
    data['acceptedUserCount'] = acceptedUserCount;
    data['level'] = level;
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tags {
  String? key;
  int? bojTagId;
  int? problemCount;
  List<DisplayNames>? displayNames;

  Tags({this.key, this.bojTagId, this.problemCount, this.displayNames});

  Tags.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    bojTagId = json['bojTagId'];
    problemCount = json['problemCount'];
    if (json['displayNames'] != null) {
      displayNames = <DisplayNames>[];
      json['displayNames'].forEach((v) {
        displayNames!.add(DisplayNames.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['key'] = key;
    data['bojTagId'] = bojTagId;
    data['problemCount'] = problemCount;
    if (displayNames != null) {
      data['displayNames'] = displayNames!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DisplayNames {
  String? name;
  String? short;

  DisplayNames({this.name, this.short});

  DisplayNames.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    short = json['short'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['short'] = short;
    return data;
  }
}

class HGUer {
  String? handle;
  List<Organizations>? organizations;
  int? solvedCount;
  int? reverseRivalCount;
  int? maxStreak;
  int? rank;

  HGUer(
      {this.handle,
      this.organizations,
      this.solvedCount,
      this.reverseRivalCount,
      this.maxStreak,
      this.rank});

  HGUer.fromJson(Map<String, dynamic> json) {
    handle = json['handle'];
    if (json['organizations'] != null) {
      organizations = <Organizations>[];
      json['organizations'].forEach((v) {
        organizations!.add(new Organizations.fromJson(v));
      });
    }
    solvedCount = json['solvedCount'];
    reverseRivalCount = json['reverseRivalCount'];
    maxStreak = json['maxStreak'];
    rank = json['rank'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['handle'] = handle;
    if (organizations != null) {
      data['organizations'] = organizations!.map((v) => v.toJson()).toList();
    }
    data['solvedCount'] = solvedCount;
    data['reverseRivalCount'] = reverseRivalCount;
    data['maxStreak'] = maxStreak;
    data['rank'] = rank;
    return data;
  }
}

class Organizations {
  int? organizationId;
  String? name;
  int? rating;
  int? userCount;

  Organizations({this.organizationId, this.name, this.rating, this.userCount});

  Organizations.fromJson(Map<String, dynamic> json) {
    organizationId = json['organizationId'];
    name = json['name'];
    rating = json['rating'];
    userCount = json['userCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['organizationId'] = organizationId;
    data['name'] = name;
    data['rating'] = rating;
    data['userCount'] = userCount;
    return data;
  }
}

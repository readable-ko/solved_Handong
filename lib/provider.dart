// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import '../firebase_options.dart';
//
// class ApplicationState extends ChangeNotifier {
//   ApplicationState() {
//     init();
//   }
//
//   bool _loggedIn = false;
//   bool get loggedIn => _loggedIn;
//
//   Future<void> init() async {
//     log("HERE?");
//     await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform);
//
//     FirebaseAuth.instance.authStateChanges();
//     FirebaseAuth.instance.userChanges().listen((user) {
//       if (user != null) {
//         _loggedIn = true;
//       } else {
//         _loggedIn = false;
//       }
//
//       notifyListeners();
//     });
//   }
// }
//
// class APIState extends ChangeNotifier {
//   APIState() {
//     init();
//   }
//
//   bool apiRest = false;
//   List<UserSolved> _userSolvedProblem = [];
//
//   Future<void> getAPI(String handle, int solvedCount) async {
//     for (int i = 1; i < (solvedCount / 50).floor(); i++) {
//       final response = await http.get(Uri.parse(
//           'https://solved.ac/api/v3/search/problem?query=s%40$handle&page=$i'));
//       if (response.statusCode == 200) {
//         final parsed = jsonDecode("[${response.body}]");
//         final parser = jsonDecode(response.body);
//         List<UserSolved> resJson =
//             (parsed as List).map((json) => UserSolved.fromJson(json)).toList();
//         List<Items> tmp = (parser['items'] as List).map((json) => Items.fromJson(json)).toList();
//
//         // Map<String, dynamic> parsed = jsonDecode(response.body);
//         //var resJson = UserSolved.fromJson(parsed);
//         log('This is me ${resJson[0].items![2].problemId}');
//         log('This is me ${tmp[0].problemId}');
//       } else {
//         apiRest = false;
//         FirebaseFirestore.instance
//             .collection('Info')
//             .doc('refresh')
//             .set(<String, dynamic>{
//           'time': FieldValue.serverTimestamp(),
//           'userName': handle,
//         });
//       }
//     }
//   }
//
//   Future<void> init() async {
//     log("THERE");
//     await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform);
//
//     DocumentSnapshot<RefreshTime> tmp = FirebaseFirestore.instance
//         .collection('Info')
//         .doc('refresh')
//         .get() as DocumentSnapshot<RefreshTime>;
//
//     if (tmp.data()!.time!.toDate().difference(DateTime.now()).inMinutes.abs() >
//         15) {
//       apiRest = true;
//       //api로 fire 정보 수정.
//     }
//
//     getAPI('fpqpsxh', 285);
//
//     FirebaseFirestore.instance
//         .collection('usersolved')
//         .snapshots()
//         .listen((snapshot) {
//       _userSolvedProblem = [];
//       for (final document in snapshot.docs) {
//         _userSolvedProblem.add(
//           UserSolved(
//             count: document.data()['count'] as int,
//             items: document.data()['problem'] as List<Items>,
//           ),
//         );
//       }
//     });
//   }
// }
//
// class RefreshTime {
//   Timestamp? time;
//   String? userName;
// }
//
// class UserSolved {
//   int? count;
//   List<Items>? items;
//
//   UserSolved({this.count, this.items});
//
//   UserSolved.fromJson(Map<String, dynamic> json) {
//     count = json['count'];
//     if (json['items'] != null) {
//       items = <Items>[];
//       json['items'].forEach((v) {
//         items!.add(Items.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['count'] = count;
//     if (items != null) {
//       data['items'] = items!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Items {
//   int? problemId;
//   String? titleKo;
//   int? acceptedUserCount;
//   int? level;
//   List<Tags>? tags;
//
//   Items(
//       {this.problemId,
//       this.titleKo,
//       this.acceptedUserCount,
//       this.level,
//       this.tags});
//
//   Items.fromJson(Map<String, dynamic> json) {
//     problemId = json['problemId'];
//     titleKo = json['titleKo'];
//     acceptedUserCount = json['acceptedUserCount'];
//     level = json['level'];
//     if (json['tags'] != null) {
//       tags = <Tags>[];
//       json['tags'].forEach((v) {
//         tags!.add(Tags.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['problemId'] = problemId;
//     data['titleKo'] = titleKo;
//     data['acceptedUserCount'] = acceptedUserCount;
//     data['level'] = level;
//     if (tags != null) {
//       data['tags'] = tags!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Tags {
//   String? key;
//   int? bojTagId;
//   int? problemCount;
//   List<DisplayNames>? displayNames;
//
//   Tags({this.key, this.bojTagId, this.problemCount, this.displayNames});
//
//   Tags.fromJson(Map<String, dynamic> json) {
//     key = json['key'];
//     bojTagId = json['bojTagId'];
//     problemCount = json['problemCount'];
//     if (json['displayNames'] != null) {
//       displayNames = <DisplayNames>[];
//       json['displayNames'].forEach((v) {
//         displayNames!.add(DisplayNames.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['key'] = key;
//     data['bojTagId'] = bojTagId;
//     data['problemCount'] = problemCount;
//     if (displayNames != null) {
//       data['displayNames'] = displayNames!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class DisplayNames {
//   String? name;
//   String? short;
//
//   DisplayNames({this.name, this.short});
//
//   DisplayNames.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//     short = json['short'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['name'] = name;
//     data['short'] = short;
//     return data;
//   }
// }
//
// class HGUser {
//   int? count;
//   List<UserItems>? userItems;
//
//   HGUser({this.count, this.userItems});
//
//   HGUser.fromJson(Map<String, dynamic> json) {
//     count = json['count'];
//     if (json['items'] != null) {
//       userItems = <UserItems>[];
//       json['items'].forEach((v) {
//         userItems!.add(UserItems.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['count'] = count;
//     if (userItems != null) {
//       data['items'] = userItems!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class UserItems {
//   String? handle;
//   List<Organizations>? organizations;
//   int? solvedCount;
//   int? reverseRivalCount;
//   int? maxStreak;
//   int? rank;
//
//   UserItems(
//       {this.handle,
//       this.organizations,
//       this.solvedCount,
//       this.reverseRivalCount,
//       this.maxStreak,
//       this.rank});
//
//   UserItems.fromJson(Map<String, dynamic> json) {
//     handle = json['handle'];
//     if (json['organizations'] != null) {
//       organizations = <Organizations>[];
//       json['organizations'].forEach((v) {
//         organizations!.add(new Organizations.fromJson(v));
//       });
//     }
//     solvedCount = json['solvedCount'];
//     reverseRivalCount = json['reverseRivalCount'];
//     maxStreak = json['maxStreak'];
//     rank = json['rank'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['handle'] = handle;
//     if (organizations != null) {
//       data['organizations'] = organizations!.map((v) => v.toJson()).toList();
//     }
//     data['solvedCount'] = solvedCount;
//     data['reverseRivalCount'] = reverseRivalCount;
//     data['maxStreak'] = maxStreak;
//     data['rank'] = rank;
//     return data;
//   }
// }
//
// class Organizations {
//   int? organizationId;
//   String? name;
//   int? rating;
//   int? userCount;
//
//   Organizations({this.organizationId, this.name, this.rating, this.userCount});
//
//   Organizations.fromJson(Map<String, dynamic> json) {
//     organizationId = json['organizationId'];
//     name = json['name'];
//     rating = json['rating'];
//     userCount = json['userCount'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['organizationId'] = organizationId;
//     data['name'] = name;
//     data['rating'] = rating;
//     data['userCount'] = userCount;
//     return data;
//   }
// }

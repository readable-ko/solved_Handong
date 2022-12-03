import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

import '../firebase_options.dart';

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

class APIState extends ChangeNotifier {
  APIState() {
    init();
  }

  List<UserSolved> _userSolvedProblem= [];
  Future<void> init() async {
    FirebaseFirestore.instance.collection('usersolved').snapshots().listen((snapshot) {
      _userSolvedProblem = [];
      for(final document in snapshot.docs) {
        _userSolvedProblem.add(
          UserSolved(
            count: document.data()['count'] as int,
          )
        );
      }
    });
  }
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

  Tags(
      {this.key,
        this.bojTagId,
        this.problemCount,
        this.displayNames});

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

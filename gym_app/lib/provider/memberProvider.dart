import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_app/API_services/api_service.dart';
import 'package:gym_app/models/member_model.dart';
import 'package:http/http.dart';

List<MemberModel> sortByDayRemaining(List<MemberModel> memberList) {
  memberList.sort((a, b) => a.daysRemaining!.compareTo(b.daysRemaining!));
  return memberList;
}

class MemberProvider with ChangeNotifier {
  List<MemberModel> _members = [];
  List<MemberModel> _mainList = [];

  List<MemberModel> get members => _members;
  List<MemberModel> get mainList => _mainList;

  // Call this function whenever you make changes in DB so that updated data will be reflected
  Future<void> setMembers() async {
    List<MemberModel> fetchedMembers = [];
    final Response res = await ApiService().getAllMembers();
    final responseData = jsonDecode(res.body);
    if (res.statusCode == 200) {
      List<dynamic> jsonList = responseData["members"];
      for (var jsonMember in jsonList) {
        MemberModel member =
            MemberModel.fromJson(jsonMember); //using factory function here
        fetchedMembers.add(member);
      }
      _members = sortByDayRemaining(fetchedMembers);
      _mainList = sortByDayRemaining(fetchedMembers);
      notifyListeners();
    }

    // void addMember(MemberModel member) {
    //   _members.add(member);
    //   notifyListeners();
    // }

    // void removeMember(String id) {
    //   _members.removeWhere((member) => member.id == id);
    //   notifyListeners();
    // }
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_app/API_services/api_service.dart';
import 'package:gym_app/API_services/api_service_membership.dart';
import 'package:gym_app/models/member_model.dart';
import 'package:gym_app/models/membership_model.dart';
import 'package:http/http.dart';

List<MemberModel> sortByDayRemaining(List<MemberModel> memberList) {
  memberList.sort((a, b) => a.daysRemaining!.compareTo(b.daysRemaining!));
  return memberList;
}

class MemberProvider with ChangeNotifier {
  //Initialization
  bool _loading = true;
  List<MemberModel> _members =
      []; // List which will be provided to display after applying filter options
  List<MemberModel> _mainList = []; //Base list which will never be altered

  List<Membership> _activeMemberships = [];
  String _searchText = '';
  int _currentMonthIncome = 0;

  //Available membershipPeriod
  final List<String> _membershipPeriod = ['All', '1', '2', '4', '6', '8'];
  final List<String> _planStatus = ['Active', 'Expired', 'past due'];

  String _selectedMembershipPeriod = 'All';
  String _selectedPlanStatus = 'Active';

  // Getter Functions:
  bool get loading => _loading;
  List<MemberModel> get members => _members;
  List<MemberModel> get mainList => _mainList;
  List<Membership> get activeMemberships => _activeMemberships;

  List<String> get planStatus => _planStatus;
  List<String> get membershipPeriod => _membershipPeriod;

  String get selectedPlanStatus => _selectedPlanStatus;
  String get selectedMembershipPeriod => _selectedMembershipPeriod;

  int get currentMonthIncome => _currentMonthIncome;
// -----------------------------------------------------------------------------------------

  // Function to sort member list by daysRemaining in ascending order
  List<MemberModel> sortByDayRemaining(List<MemberModel> memberList) {
    memberList.sort((a, b) => a.daysRemaining!.compareTo(b.daysRemaining!));
    return memberList;
  }

  //Dashboard Funtions
  List<MemberModel> newMembersThisMonth() {
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;
    List<MemberModel> result = _mainList.where((element) {
      if (element.joinOn != null) {
        return element.joinOn!.month == currentMonth &&
            element.joinOn!.year == currentYear;
      }
      return false;
    }).toList();
    return result;
  }

  void getCurrentMonthIncome() async {
    const monthNames = [
      "jan",
      "feb",
      "mar",
      "apr",
      "may",
      "jun",
      "jul",
      "aug",
      "sep",
      "oct",
      "nov",
      "dec",
    ];
    DateTime now = DateTime.now();
    var currentMonth = now.month;
    Response res = await ApiService().getIncomeValues(now.year);
    var resData = jsonDecode(res.body);
    var allIncomes = resData['data'];
    _currentMonthIncome = allIncomes[monthNames[currentMonth - 1]];
    notifyListeners();
  }

// FUNCTIONS FOR HANDLING SEARCH AND MEMBERSHIP MONTH FILTER ------------------------------
  void updateSearchText(String newText) {
    _searchText = newText;
    // notifyListeners();
  }

  void updateSelectedMembershipPeriod(String newPeriod) {
    _selectedMembershipPeriod = newPeriod;
    // notifyListeners();
  }

  void filterMembers() {
    // print(_mainList);
    List<MemberModel> searchResult = _mainList;

    if (_selectedMembershipPeriod.isNotEmpty) {
      // print(selectedMembershipPeriod);
      if (_selectedMembershipPeriod == "All") {
        print("inside all");
        searchResult = sortByDayRemaining(_mainList);
      } else {
        searchResult = searchResult
            .where((element) => element.membershipPeriod
                .toString()
                .contains(_selectedMembershipPeriod))
            .toList();
      }
    }

    if (_searchText.isNotEmpty) {
      searchResult = searchResult
          .where((element) =>
              element.firstName!.toLowerCase().contains(
                  _searchText.toLowerCase()) || //change here name to firstName

              element.gender!
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()) ||
              element.medicalIssue!
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()))
          .toList();
    }

    _members = searchResult;
    notifyListeners();
  }

  // FUNCTIONS FOR HANDLING MEMBERSHIP STATUS DROP-DOWN-----------------------------------
  void updateSelectedPlanStatus(String newStatus) {
    _selectedPlanStatus = newStatus;
    // notifyListeners(); // Notify listeners to rebuild dependent widgets
  }

  void displayMembersByStatus(String status) {
    List<MemberModel> result = [];
    if (status == 'Active') {
      result = _mainList.where((element) => element.expired == false).toList();
    } else if (status == 'Expired') {
      result = _mainList.where((element) => element.expired!).toList();
    } else if (status == 'past due') {
      result = _mainList.where((element) => element.dueAmount! > 0).toList();
    }
    _members = sortByDayRemaining(result); //sort here if want
    notifyListeners();
  }

// ----------------------------------------------------------------------------------------

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
      _loading = false;

      notifyListeners();
    }
  }

  Future setMemberships() async {
    List<Membership> fetchedMemberships =
        await ApiServiceMembership().fetchActiveMemberships();
    _activeMemberships = fetchedMemberships;
    notifyListeners();
  }
}

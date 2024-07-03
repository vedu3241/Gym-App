import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_app/API_services/api_service.dart';
import 'package:gym_app/components/member_tile.dart';
import 'package:gym_app/components/my_app_bar.dart';
import 'package:gym_app/models/member_model.dart';
import 'package:http/http.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

// updating code
class _MembersScreenState extends State<MembersScreen> {
  bool loading = true;
  //member Search Result
  // List<MemberData> _foundMembers = [];
  //Fetched list of members
  List<MemberModel> _members =
      []; // List which will be provided to display after applying filter options

  List<MemberModel> _mainList = []; //Base list which will never be altered

  String searchText = '';

  final List<String> planStatus = ['Active', 'Expired', 'past due'];
  String _selectedPlanStatus = 'Active';

  //Available membershipPeriod
  final List<String> membershipPeriod = ['All', '1', '2', '4', '6', '8'];
  String selectedMembershipPeriod = 'All';

  // Function to sort member list by daysRemaining in ascending order
  List<MemberModel> sortByDayRemaining(List<MemberModel> memberList) {
    memberList.sort((a, b) => a.daysRemaining!.compareTo(b.daysRemaining!));
    return memberList;
  }

  void getMembers() async {
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
      setState(() {
        _members = sortByDayRemaining(
            fetchedMembers); // List for displaying the result of filters
        _mainList = sortByDayRemaining(fetchedMembers); //Original data
        loading = false;
      });
      // print(_members);
    }
  }

  @override
  void initState() {
    print("init called");
    getMembers();
    // _members = sortByDayRemaining(_members);
    super.initState();
  }

  //Function to get the expired plab members
  List<MemberModel> getExpired(List<MemberModel> memberList) {
    return memberList.where((element) => element.expired!).toList();
  }

  //Function to get the Active plan members
  List<MemberModel> getActive(List<MemberModel> memberList) {
    return memberList.where((element) => element.expired == false).toList();
  }

  List<MemberModel> getPastDue(List<MemberModel> memberList) {
    return memberList.where((element) => element.dueAmount! > 0).toList();
  }

  void _displayMembersByStatus(String status) {
    List<MemberModel> result = [];
    if (status == 'Active') {
      result = getActive(_mainList);
    } else if (status == 'Expired') {
      result = getExpired(_mainList);
    } else if (status == 'past due') {
      result = getPastDue(_mainList);
    }
    setState(() {
      _members = result; //sort here if want
    });
  }

  // Method to filter items based on search text and selected package duration
  void filterMembers() {
    // print(_mainList);
    List<MemberModel> searchResult = _mainList;

    if (selectedMembershipPeriod.isNotEmpty) {
      // print(selectedMembershipPeriod);
      if (selectedMembershipPeriod == "All") {
        searchResult = sortByDayRemaining(_mainList);
      } else {
        searchResult = searchResult
            .where((element) => element.membershipPeriod
                .toString()
                .contains(selectedMembershipPeriod))
            .toList();
      }
    }

    if (searchText.isNotEmpty) {
      searchResult = searchResult
          .where((element) =>
              element.firstName!.toLowerCase().contains(
                  searchText.toLowerCase()) || //change here name to firstName

              element.gender!
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
              element.medicalIssue!
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
          .toList();
    }

    setState(() {
      _members = searchResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //top div color = 0xFF36393B
      appBar: const MyAppBar(
        text: "Members",
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          //Search Bar + Filters
          Container(
            // color: const Color(0xFF36393B),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 0, 0, 0),
                  Color.fromARGB(255, 99, 137, 152),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            height: 135,
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                //Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: SizedBox(
                    // Adjust width as needed
                    height: 46, // Adjust height as needed
                    child: TextField(
                      decoration: InputDecoration(
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                        ),
                        prefixIconColor: Colors.white,
                        hintText: "Search",
                        hintStyle: TextStyle(
                          color: Colors.grey[300],
                        ),
                        alignLabelWithHint: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      onChanged: (value) {
                        // _runSearchFilter(value);
                        searchText = value;
                        // print(searchText);
                        filterMembers();
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                //Filters section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Display dropdown button here

                        SizedBox(
                          width: 110,
                          child: DropdownButtonFormField(
                            value: selectedMembershipPeriod,
                            decoration: const InputDecoration(
                              labelText: "Select Membeship",
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                            ),
                            iconEnabledColor: Colors.white,
                            dropdownColor: const Color.fromARGB(255, 32, 44, 49)
                                .withOpacity(.8),
                            items: membershipPeriod.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              // _packageFilter(value.toString());
                              setState(() {
                                selectedMembershipPeriod = value!;
                              });
                              filterMembers();
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        // Exprired members DD
                        SizedBox(
                          width: 115,
                          child: DropdownButtonFormField(
                            value: _selectedPlanStatus,
                            decoration: const InputDecoration(
                              labelText: "Membership Status",
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                            ),
                            iconEnabledColor: Colors.white,
                            dropdownColor: const Color.fromARGB(255, 32, 44, 49)
                                .withOpacity(.8),
                            items: planStatus.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              print(value);
                              // // _packageFilter(value.toString());
                              setState(() {
                                _selectedPlanStatus = value!;
                              });
                              // filterMembers();
                              _displayMembersByStatus(value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          loading
              ? const CircularProgressIndicator()
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Total : ${_members.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
          const SizedBox(
            height: 10,
          ),
          //if no result found
          _members.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Text(
                    "No members found.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      return MemberTile(
                        obj: _members[index],
                      );
                    },
                  ),
                )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gym_app/components/member_tile.dart';
import 'package:gym_app/components/my_app_bar.dart';
import 'package:gym_app/models/membership_model.dart';
import 'package:gym_app/provider/memberProvider.dart';
import 'package:provider/provider.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

// updating code
class _MembersScreenState extends State<MembersScreen> {
  @override
  void initState() {
    print("Inside M.S init");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<MemberProvider>();
    return Scaffold(
      //top div color = 0xFF36393B
      appBar: const MyAppBar(
        text: "Members",
      ),
      backgroundColor: Colors.grey[200],
      body: Consumer<MemberProvider>(
        builder: (context, memberprovider, child) {
          return Column(
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
                            memberprovider.updateSearchText(value);
                            memberprovider.filterMembers();
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
                            // membership dropdown
                            SizedBox(
                              width: 110,
                              child: DropdownButtonFormField(
                                value: memberprovider.selectedMembershipPeriod,
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
                                dropdownColor:
                                    const Color.fromARGB(255, 32, 44, 49)
                                        .withOpacity(.8),
                                items: memberprovider.membershipPeriod
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  memberprovider
                                      .updateSelectedMembershipPeriod(value!);
                                  memberprovider.filterMembers();
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            // STATUS DD
                            SizedBox(
                              width: 115,
                              child: DropdownButtonFormField(
                                value: memberprovider.selectedPlanStatus,
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
                                dropdownColor:
                                    const Color.fromARGB(255, 32, 44, 49)
                                        .withOpacity(.8),
                                items: memberprovider.planStatus
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  memberprovider
                                      .updateSelectedPlanStatus(value!);
                                  memberprovider.displayMembersByStatus(value);
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
              memberprovider.loading
                  ? const CircularProgressIndicator()
                  //MEMBER COUNT
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "Total : ${memberprovider.members.length}",
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
              memberprovider.members.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(25.0),
                      child: Text(
                        "No members found.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: memberprovider.members.length,
                        itemBuilder: (context, index) {
                          final member = memberprovider.members[index];
                          Membership? membership;

                          try {
                            membership = memberprovider.activeMemberships
                                .firstWhere((activeMembership) =>
                                    activeMembership.memberId == member.id);
                          } catch (e) {
                            membership = null;
                          }
                          return MemberTile(
                            obj: member,
                            membership: membership,
                          );
                        },
                      ),
                    )
            ],
          );
        },
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:gym_app/API_services/api_service.dart';
import 'package:gym_app/Screens/membershipHistoryScreen.dart';
import 'package:gym_app/Screens/renewMembershipScreen.dart';
import 'package:gym_app/components/my_app_bar.dart';
import 'package:gym_app/models/member_model.dart';
import 'package:gym_app/models/membership_model.dart';
import 'package:gym_app/provider/memberProvider.dart';
import 'package:http/http.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberProfile extends StatelessWidget {
  MemberProfile({super.key, required this.userId});

  final String userId;

  // Text Controllers
  final TextEditingController _paidDueController = TextEditingController();

  _launchDialPad(String phoneNumber) async {
    try {
      Uri dialnumber = Uri(scheme: 'tel', path: phoneNumber);
      await launchUrl(dialnumber);
    } catch (err) {
      print("Error in Call: $err");
    }
  }

  _callUser(String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (err) {
      print("Error in Call: " + err.toString());
    }
  }

  _openWhatsapp(String phoneNumber, MemberModel member) async {
    try {
      String reminderText =
          "Hello ${member.firstName}! We wanted to remind you that your gym membership is expired.\nWe truly value your dedication and commitment to your fitness journey with us.\n\nIf you have any questions or wish to renew your membership, please don't hesitate to reach out to us. We look forward to continuing to support you in achieving your fitness goals.\n\nRegards- S.K Fitness";

      String url =
          'https://wa.me/$phoneNumber/?text=${Uri.encodeComponent(reminderText)}';
      Uri uri = Uri.parse(url);
      await launchUrl(uri);
    } catch (err) {
      print('Error launching WhatsApp: $err');
    }
  }

  // void _sendSms() {
  //   // Implement SMS sending functionality
  // }

  void removeMember(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Removing member!!'),
          content: const Text('Are you sure?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Response res = await ApiService().removeMember(id);
                if (res.statusCode == 200) {
                  Provider.of<MemberProvider>(context, listen: false)
                      .setMembers();
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                }
                print(res.body);
              },
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("cancel"))
          ],
        );
      },
    );
  }

  void updateMemberDue(
      BuildContext context, MemberModel member, Membership membership) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Pay Due',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Due Amount: ${membership.dueAmount}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _paidDueController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field can't be empty";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    label: Text("Paid due"),
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    contentPadding: EdgeInsets.all(15),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                Response res = await ApiService().updateMemberDue(
                    _paidDueController.text, membership.dueAmount!, member.id!);
                if (res.statusCode == 200) {
                  var jsonResponse = jsonDecode(res.body);
                  context.read<MemberProvider>().setMemberships();
                  _paidDueController.clear();
                  print(jsonResponse['message']);
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("cancel"))
          ],
        );
      },
    );
  }

  String formattedDate(DateTime dateString) {
    DateTime dateTime = DateTime.parse(dateString.toString());
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        text: "Profile",
      ),
      backgroundColor: Colors.grey[200],
      body: Consumer<MemberProvider>(
        builder: (context, memberProvider, child) {
          final member = memberProvider.members.firstWhere(
            (member) => member.id == userId,
            orElse: () => MemberModel(id: '', firstName: 'Not Found'),
          );

          if (member.id!.isEmpty) {
            return const Center(child: Text('Member not found'));
          }

          Membership? membership;

          try {
            membership = memberProvider.activeMemberships.firstWhere(
                (activeMembership) => activeMembership.memberId == member.id);
          } catch (e) {
            membership = null;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InstaImageViewer(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  'http://192.168.0.103:6666/public/profile_img/${member.profileImg}',
                                  width: 90,
                                  height: 90,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member.firstName!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text(member.phoneNum!.toString()),
                                const SizedBox(height: 10),
                                Text("Medical Issue",
                                    style: TextStyle(color: Colors.grey[500])),
                                Text(member.medicalIssue!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Gender",
                                    style: TextStyle(color: Colors.grey[500])),
                                const Text("Male",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(height: 10),
                                Text("Batch Name",
                                    style: TextStyle(color: Colors.grey[500])),
                                const Text("Morning",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            )
                          ],
                        ),
                        Container(
                          height: 1.5,
                          width: 300,
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          color: Colors.grey[300],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Call button
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    content: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Text(
                                          "Are you sure you want to make this call?",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await _callUser(
                                                  member.phoneNum.toString());
                                            },
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                              child: const Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 18,
                                    child: Icon(Icons.phone,
                                        color: Colors.white, size: 20),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Call",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  )
                                ],
                              ),
                            ),
                            //WHATSAPP BUTTON
                            GestureDetector(
                              onTap: () {
                                _openWhatsapp(
                                    member.phoneNum.toString(), member);
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 18,
                                    child: Image.asset(
                                      'assets/member_profile/whatsapp.png',
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "Whatsapp",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  )
                                ],
                              ),
                            ),
                            //SMS BUTTON
                            // GestureDetector(
                            //   onTap: _sendSms,
                            //   child: const Column(
                            //     children: [
                            //       CircleAvatar(
                            //         backgroundColor: Colors.blue,
                            //         radius: 18,
                            //         child: Icon(Icons.sms,
                            //             color: Colors.white, size: 20),
                            //       ),
                            //       SizedBox(height: 5),
                            //       Text(
                            //         "SMS",
                            //         style: TextStyle(
                            //             fontWeight: FontWeight.w500,
                            //             color: Colors.black),
                            //       )
                            //     ],
                            //   ),
                            // ),

                            //remove member
                            GestureDetector(
                              onTap: () {
                                removeMember(context, userId);
                              },
                              child: const Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 18,
                                    child: Icon(Icons.delete,
                                        color: Colors.white, size: 20),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Delete",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Padding(
                  //   padding: EdgeInsets.only(top: 20),
                  //   child: Align(
                  //     alignment: Alignment.topLeft,
                  //     child: Text(
                  //       "Membership",
                  //       style: TextStyle(
                  //           color: Colors.grey[500],
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.bold),
                  //     ),
                  //   ),
                  // ),
                  if (membership != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Active Plan",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              Text(
                                "₹ ${membership.membershipAmount}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Start Date",
                                  style: TextStyle(color: Colors.grey)),
                              Text(
                                formattedDate(membership.planStartDate!),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("End Date",
                                  style: TextStyle(color: Colors.grey)),
                              Text(
                                formattedDate(membership.planExpiryDate!),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Paid Amount",
                                  style: TextStyle(color: Colors.grey)),
                              Text(
                                membership.paidAmount.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Due Amount",
                                  style: TextStyle(color: Colors.grey)),
                              Text(
                                membership.dueAmount.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Status",
                                  style: TextStyle(color: Colors.grey)),
                              Text("Active",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              membership.dueAmount! > 0
                                  ? GestureDetector(
                                      onTap: () {
                                        updateMemberDue(
                                            context, member, membership!);
                                      },
                                      child: const Text("Pay Due",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500)),
                                    )
                                  : const SizedBox(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RenewMembershipScreen(
                                        userId: userId,
                                        member: member,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Renew Plan",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500)),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 40),
                      child: Column(
                        children: [
                          const Center(
                            child: Text(
                              "No active membership found.",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RenewMembershipScreen(
                                      member: member, userId: userId),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Renew Plan",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  //HISTORY
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MembershipHistoryScreen(
                            memberId: member.id!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "View Membership History",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(Icons.history),
                            ],
                          ),
                          Icon(Icons.chevron_right)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

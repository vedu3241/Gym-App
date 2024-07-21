import 'dart:convert';

import 'package:flutter/material.dart';
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

// ignore: must_be_immutable
class MemberProfile extends StatelessWidget {
  MemberProfile({super.key, required this.userId});

  String userId;

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
      // Uri dialnumber = Uri(scheme: 'tel', path: phoneNumber);
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (err) {
      print("Error in Call: " + err.toString());
    }
  }

  //open whatsapp with pre-define text
  _openWhatsapp(
      String phoneNumber, MemberModel member, Membership membership) async {
    try {
      String reminderText =
          "Hello ${member.firstName}! We wanted to remind you that your gym membership is set to expire on ${formattedDate(membership.planExpiryDate!)}.\n\nWe truly value your dedication and commitment to your fitness journey with us.\n\nIf you have any questions or wish to renew your membership, please don't hesitate to reach out to us. We look forward to continuing to support you in achieving your fitness goals.\n\nRegards- S.K Fitness";

      String url =
          'https://wa.me/$phoneNumber/?text=${Uri.encodeComponent(reminderText)}';
      Uri uri = Uri.parse(url); // Parse the url string to create a Uri object
      await launchUrl(uri);
    } catch (err) {
      print('Error launching WhatsApp: $err');
    }
  }

  void _sendSms() {
    // String recipientNumber = user.phoneNum.toString();
    // String messageBody = "Your membership is been expired";
    // SmsSender sender = SmsSender();
    // String address = recipientNumber;
    // sender.sendSms(SmsMessage(address, messageBody));
  }

  //remove member
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

  //update member's Due amount
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
              mainAxisSize: MainAxisSize
                  .min, // Ensures the AlertDialog takes only the space it needs

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
                    // hintText: "First Name",
                  ),
                ),
                // Save button
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
                  // Provider.of<MemberProvider>(context, listen: false)
                  //     .setMembers();
                  context.read<MemberProvider>().setMemberships();
                  //clearing controller
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
    // Format the date
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
            // fetching member from provider by using ID
            final member = memberProvider.members.firstWhere(
              (member) => member.id == userId,
              orElse: () => MemberModel(id: '', firstName: 'Not Found'),
            );

            if (member.id!.isEmpty) {
              return const Center(child: Text('Member not found'));
            }

            final membership = memberProvider.activeMemberships.firstWhere(
              (element) => element.memberId == userId,
            );
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Profile Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      child: Column(
                        children: [
                          // Info Card
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
                                      style:
                                          TextStyle(color: Colors.grey[500])),
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
                                      style:
                                          TextStyle(color: Colors.grey[500])),
                                  const Text("Male",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 10),
                                  Text("Batch Name",
                                      style:
                                          TextStyle(color: Colors.grey[500])),
                                  const Text("Morning",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ],
                              )
                            ],
                          ),
                          // Horizontal Divider line
                          Container(
                            height: 1.5,
                            width: 300,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            color: Colors.grey[300],
                          ),
                          // Contact Icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              //Call button
                              GestureDetector(
                                onTap: () {
                                  // _launchDialPad(user.phoneNumber);
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
                                        TextButton(
                                          onPressed: () {
                                            _callUser(
                                                member.phoneNum!.toString());
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Yes"),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  'assets/member_profile/phone-call.png',
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                              //whatsapp
                              InkWell(
                                onTap: () async {
                                  _openWhatsapp(member.phoneNum!.toString(),
                                      member, membership);
                                },
                                child: Image.asset(
                                  'assets/member_profile/whatsapp.png',
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                              //sms
                              InkWell(
                                onTap: () {
                                  _sendSms();
                                },
                                child: Image.asset(
                                  'assets/member_profile/sms.png',
                                  height: 40,
                                  width: 40,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              //Extra ICON
                              //To renew due paid in between the on going membership
                              InkWell(
                                onTap: () {
                                  updateMemberDue(context, member, membership);
                                },
                                child: Image.asset(
                                  'assets/member_profile/attendance.png',
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                              //Renew Membership
                              InkWell(
                                onTap: () {
                                  // print(user.id);
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => RenewMembershipScreen(
                                      member: member,
                                    ),
                                  ));
                                },
                                child: Image.asset(
                                  'assets/member_profile/renew.png',
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                              //Remove Member
                              InkWell(
                                onTap: () {
                                  print("remove tapped");
                                  removeMember(context, member.id!);
                                },
                                child: Image.asset(
                                  'assets/member_profile/block.png',
                                  height: 40,
                                  width: 40,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    // Text - Membership
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Active Membership Details",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Packages Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${membership.membershipPeriod} month plan",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 227, 173, 10)),
                          ),
                          Row(
                            children: [
                              // Col 1
                              _PackageColumn(
                                label1: "Total Amount",
                                value1: membership.membershipAmount.toString(),
                                label2: "Paid",
                                value2: membership.paidAmount.toString(),
                              ),
                              const SizedBox(width: 20),
                              // Col 2
                              _PackageColumn(
                                label1: "Discount",
                                value1: "0",
                                label2: "Due amount",
                                value2: membership.dueAmount.toString(),
                              ),
                              const SizedBox(width: 20),
                              // Col 3
                              _PackageColumn(
                                label1: "Purchase Date",
                                value1:
                                    formattedDate(membership.planStartDate!),
                                label2: "Expiry Date",
                                value2:
                                    formattedDate(membership.planExpiryDate!),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MembershipHistoryScreen(memberId: userId),
                            ));
                      },
                      child: const Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                "History",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(Icons.history),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}

class _PackageColumn extends StatelessWidget {
  const _PackageColumn({
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
  });

  final String label1;
  final String value1;
  final String label2;
  final String value2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label1,
          style: TextStyle(color: Colors.grey[500]),
        ),
        const SizedBox(height: 10),
        Text(
          value1,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Text(
          label2,
          style: TextStyle(color: Colors.grey[500]),
        ),
        Text(
          value2,
          style: const TextStyle(fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}

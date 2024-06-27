import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:gym_app/Screens/renewMembershipScreen.dart';
import 'package:gym_app/components/my_app_bar.dart';
import 'package:gym_app/models/member_model.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class MemberProfile extends StatelessWidget {
  MemberProfile({super.key, required this.user});

  MemberModel user;
  _launchDialPad(String phoneNumber) async {
    try {
      Uri dialnumber = Uri(scheme: 'tel', path: phoneNumber);
      await launchUrl(dialnumber);
    } catch (err) {
      print("Error in Call: " + err.toString());
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

  String formattedDate(DateTime dateString) {
    DateTime dateTime = DateTime.parse(dateString.toString());
    // Define a DateFormat
    final DateFormat formatter = DateFormat.yMd();

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
      body: SingleChildScrollView(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                              'http://192.168.0.103:6666/public/profile_img/${user.profileImg}',
                              width: 90,
                              height: 90,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.firstName!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(user.phoneNum!.toString()),
                            const SizedBox(height: 10),
                            Text("Medical Issue",
                                style: TextStyle(color: Colors.grey[500])),
                            Text(user.medicalIssue!,
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
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 10),
                            Text("Batch Name",
                                style: TextStyle(color: Colors.grey[500])),
                            const Text("Morning",
                                style: TextStyle(fontWeight: FontWeight.w500)),
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
                        GestureDetector(
                          onTap: () {
                            print("call button clicked");
                            // _launchDialPad(user.phoneNumber);
                            _callUser(user.phoneNum!.toString());
                          },
                          child: Image.asset(
                            'assets/member_profile/phone-call.png',
                            height: 40,
                            width: 40,
                          ),
                        ),
                        Image.asset(
                          'assets/member_profile/whatsapp.png',
                          height: 40,
                          width: 40,
                        ),
                        Image.asset(
                          'assets/member_profile/sms.png',
                          height: 40,
                          width: 40,
                        )
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset(
                          'assets/member_profile/attendance.png',
                          height: 40,
                          width: 40,
                        ),
                        InkWell(
                          onTap: () {
                            // print(user.id);
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RenewMembershipScreen(
                                member: user,
                              ),
                            ));
                          },
                          child: Image.asset(
                            'assets/member_profile/renew.png',
                            height: 40,
                            width: 40,
                          ),
                        ),
                        Image.asset(
                          'assets/member_profile/block.png',
                          height: 40,
                          width: 40,
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
                  "Membership Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              // Packages Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user.membershipPeriod} month plan",
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
                          value1: user.actualAmount.toString(),
                          label2: "Paid",
                          value2: user.paidAmount.toString(),
                        ),
                        const SizedBox(width: 20),
                        // Col 2
                        _PackageColumn(
                          label1: "Discount",
                          value1: "0",
                          label2: "Due amount",
                          value2: user.dueAmount.toString(),
                        ),
                        const SizedBox(width: 20),
                        // Col 3
                        _PackageColumn(
                            label1: "Purchase Date",
                            value1: formattedDate(user.planStartDate!),
                            label2: "Expiry Date",
                            value2: "27"),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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

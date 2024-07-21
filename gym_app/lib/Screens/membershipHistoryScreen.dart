import 'package:flutter/material.dart';
import 'package:gym_app/API_services/api_service_membership.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class MembershipHistoryScreen extends StatelessWidget {
  MembershipHistoryScreen({super.key, required this.memberId});
  String memberId;

  Future<List<dynamic>> fetchMembershipHistory() async {
    final response = await http
        .get(Uri.parse('http://your-node-server-url/api/membership/history'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['history'];
    } else {
      throw Exception('Failed to load membership history');
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = ApiServiceMembership(); // Instantiate the class

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership History'),
      ),
      backgroundColor: Colors.grey[200],
      body: FutureBuilder<List<dynamic>>(
        future: apiService.getMembershipHistory(memberId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No membership history found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var membership = snapshot.data![index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${membership['membership_Period']} month plan",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 227, 173, 10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _PackageColumn(
                            label1: "Total Amount",
                            value1: membership['membershipAmount'].toString(),
                            label2: "Paid",
                            value2: membership['paidAmount'].toString(),
                          ),
                          const SizedBox(width: 20),
                          _PackageColumn(
                            label1: "Discount",
                            value1: "0", // Assuming no discount for simplicity
                            label2: "Due amount",
                            value2: membership['dueAmount'].toString(),
                          ),
                          const SizedBox(width: 20),
                          _PackageColumn(
                            label1: "Purchase Date",
                            value1: formattedDate(
                                DateTime.parse(membership['planStartDate'])),
                            label2: "Expiry Date",
                            value2: formattedDate(
                                DateTime.parse(membership['planExpiryDate'])),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String formattedDate(DateTime dateString) {
    DateTime dateTime = DateTime.parse(dateString.toString());
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    // Format the date
    return formatter.format(dateTime);
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym_app/API_services/api_service_membership.dart';
import 'package:gym_app/models/membershipPlan_model.dart';
import 'package:http/http.dart' as http;

class MembershipPlansScreen extends StatefulWidget {
  const MembershipPlansScreen({super.key});

  @override
  _MembershipPlansScreenState createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  late Future<List<MembershipPlan>> futurePlans;
  Map<String, String> _priceChanges = {};

  @override
  void initState() {
    super.initState();
    futurePlans = ApiServiceMembership().fetchMembershipPlans();
  }

  void _submitPriceChanges() async {
    List<Map<String, String>> updates = _priceChanges.entries.map((entry) {
      return {'id': entry.key, 'price': entry.value};
    }).toList();

    try {
      final response = await http.put(
        Uri.parse('http://192.168.0.103:6666/updatePlans'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        // Successfully updated all prices
        setState(() {
          futurePlans = ApiServiceMembership().fetchMembershipPlans();
        });
      } else {
        // Handle error
        print('Failed to update plans: ${response.body}');
      }
    } catch (e) {
      // Handle error
      print('Failed to update plans: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membership Plans')),
      body: FutureBuilder<List<MembershipPlan>>(
        future: futurePlans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error in builder: ${snapshot.error}'));
          } else {
            final plans = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      final _priceController =
                          TextEditingController(text: plan.price.toString());

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('${plan.months} months'),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  _priceChanges[plan.id] = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                //to edit the plans
                ElevatedButton(
                  onPressed: _submitPriceChanges,
                  child: const Text('Update plans'),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlanDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Dialog box to add new plan
  void _showAddPlanDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final monthController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Plan'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: monthController,
                  decoration: const InputDecoration(labelText: 'Months'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of months';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  ApiServiceMembership()
                      .addNewPlan(monthController.text, priceController.text);
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

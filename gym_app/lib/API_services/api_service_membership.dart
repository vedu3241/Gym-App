import 'dart:convert';

import 'package:gym_app/models/membershipPlan_model.dart';
import 'package:gym_app/models/membership_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiServiceMembership {
  final baseUrl = 'http://192.168.0.103:6666'; //Enter IPV4 add from CMD
  var headers = {'Content-Type': 'application/json'};

  // to fetch the month-price plan available
  Future<List<MembershipPlan>> fetchMembershipPlans() async {
    final response = await http.get(Uri.parse('$baseUrl/plans'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List plansJson = jsonResponse['plans'];

      return plansJson.map((plan) => MembershipPlan.fromJson(plan)).toList();
    } else {
      throw Exception('Failed to load plans');
    }
  }

  //New plan
  void addNewPlan(String months, String price) async {
    Response response = await http.post(Uri.parse('$baseUrl/newPlan'),
        headers: headers,
        body: jsonEncode(<String, String>{
          'months': months,
          'price': price,
        }));
  }

  //get active membership
  Future<List<Membership>> fetchActiveMemberships() async {
    Response res = await http.get(Uri.parse('$baseUrl/activeMemberships'),
        headers: headers);
    final jsonResponse = json.decode(res.body);
    List activeMemberships = jsonResponse['activeMemberships'];
    return activeMemberships.map((plan) => Membership.fromJson(plan)).toList();
  }

  Future<List<dynamic>> getMembershipHistory(String id) async {
    Response res =
        await http.get(Uri.parse('$baseUrl/membershipHistory?memberId=$id'));
    if (res.statusCode == 200) {
      return json.decode(res.body)['history'];
    } else {
      throw Exception('Failed to load membership history');
    }
  }

  Future<Membership> getMostRecentMembership(String id) async {
    Response res =
        await http.get(Uri.parse('$baseUrl/recent-membership?memberId=$id'));
    final responseData = jsonDecode(res.body);
    final jsonMembership = responseData['recentMembership'];
    Membership recentMembership = Membership.fromJson(jsonMembership);
    print(recentMembership);
    return recentMembership;
  }
}

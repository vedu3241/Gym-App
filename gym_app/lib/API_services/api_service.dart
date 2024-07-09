import 'dart:convert';
import 'dart:io';

import 'package:gym_app/models/member_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiService {
  final baseUrl = 'http://192.168.0.103:6666'; //Enter IPV4 add from CMD

  //Adding new member
  Future<Response> addMember(MemberModel member, File img) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/addMember'),
    );

    request.fields['fname'] = member.firstName.toString();
    request.fields['lname'] = member.lastName.toString();
    request.fields['phoneNum'] = member.phoneNum.toString();
    request.fields['gender'] = member.gender!;
    request.fields['medicalIssue'] = member.medicalIssue!;
    request.fields['membershipPeriod'] = member.membershipPeriod.toString();
    request.fields['actual_amount'] = member.actualAmount.toString();
    request.fields['paid_amount'] = member.paidAmount.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'profileImage',
        img.path,
      ),
    );

    var streamedResponse = await request.send();
    var res = await http.Response.fromStream(streamedResponse);

    return res;
  }

  //To retrieve all members
  Future<Response> getAllMembers() async {
    var res = await http.get(Uri.parse('$baseUrl/getMembers'));

    print("Inside service getMember");
    return res;
  }

  //update membership
  Future<Response> updateMembership(MemberModel member) async {
    var headers = {'Content-Type': 'application/json'};

    var res = await http.post(Uri.parse('$baseUrl/updateMembership'),
        headers: headers,
        body: jsonEncode(
          <String, dynamic>{
            'id': member.id,
            'membershipPeriod': member.membershipPeriod,
            'actualAmount': member.actualAmount,
            'paidAmount': member.paidAmount,
            'dueAmount': member.dueAmount,
            'paidDueAmount': member.paidDueAmount,
          },
        ));
    return res;
  }

  //remove member
  Future<Response> removeMember(String memberId) async {
    var res = await http.get(
      Uri.parse('$baseUrl/removeMember?memberId=$memberId'),
    );
    return res;
  }

  //To update memberdue anytime
  Future<Response> updateMemberDue(
      String paidDue, int due, String memberId) async {
    var headers = {'Content-Type': 'application/json'};

    var res = await http.post(Uri.parse('$baseUrl/updateMemberDue'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          'memberId': memberId,
          'paidDue': paidDue,
          'due': due,
        }));

    return res;
  }

  // To retrieve monthly income history
  Future<Response> getIncomeValues(int year) async {
    var res = await http.get(Uri.parse('$baseUrl/getIncome?year=$year'));
    // print(res.body);
    return res;
  }

  Future<List<int>> getAvailableYears() async {
    String url = '$baseUrl/getAvailIncomeYears';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      List<int> years = List<int>.from(jsonData['years']);
      print(years);
      return years;
    } else {
      throw Exception('Failed to load years');
    }
  }
}

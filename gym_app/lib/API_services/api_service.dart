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

  Future<Response> getAllMembers() async {
    var res = await http.get(Uri.parse('$baseUrl/getMembers'));

    print("Inside service getMember");
    return res;
  }

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
}

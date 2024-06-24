class MemberModel {
  String? firstName;
  String? lastName;
  int? phoneNum;
  String? gender;
  String? profileImg;
  String? medicalIssue;
  int? membershipPeriod;
  int? amount; // mentioned as "package" somewhere
  DateTime? planStartDate;
  DateTime? planExpiryDate;
  int? daysRemaining;
  bool? expired;

  MemberModel({
    this.firstName,
    this.lastName,
    this.phoneNum,
    this.gender,
    this.profileImg,
    this.medicalIssue,
    this.membershipPeriod,
    this.amount,
    this.planStartDate,
    this.planExpiryDate,
    this.daysRemaining,
    this.expired,
  });

  //Converts JSON object into member model
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      profileImg: json['profile_img'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNum: json['phone_num'],
      gender: json['gender'],
      medicalIssue: json['medicalIssue'],
      membershipPeriod: json['membership_Period'],
      amount: json['amount'],
      planStartDate: DateTime.parse(json['planStartDate']),
      planExpiryDate: DateTime.parse(json['planExpiryDate']),
      daysRemaining: json['daysRemaining'],
      expired: json['expired'],
    );
  }
}

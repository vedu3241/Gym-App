class MemberModel {
  String? id;
  String? firstName;
  String? lastName;
  int? phoneNum;
  String? gender;
  String? profileImg;
  String? medicalIssue;
  int? membershipPeriod;
  int? actualAmount; // mentioned as "package" somewhere
  int? paidAmount;
  int? dueAmount;
  int? paidDueAmount;
  DateTime? planStartDate;
  DateTime? planExpiryDate;
  int? daysRemaining;
  bool? expired;

  MemberModel({
    this.id,
    this.firstName,
    this.lastName,
    this.phoneNum,
    this.gender,
    this.profileImg,
    this.medicalIssue,
    this.membershipPeriod,
    this.actualAmount,
    this.paidAmount,
    this.paidDueAmount,
    //auto calc
    this.dueAmount,
    this.planStartDate,
    this.planExpiryDate,
    this.daysRemaining,
    this.expired,
  });

  //Converts JSON object into member model
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['_id'],
      profileImg: json['profile_img'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNum: json['phone_num'],
      gender: json['gender'],
      medicalIssue: json['medicalIssue'],
      membershipPeriod: json['membership_Period'],
      actualAmount: json['actual_amount'],
      paidAmount: json['paid_amount'],
      dueAmount: json['due_amount'],
      // paidDueAmount: json['paidDueAmount'],
      planStartDate: DateTime.parse(json['planStartDate']),
      planExpiryDate: DateTime.parse(json['planExpiryDate']),
      daysRemaining: json['daysRemaining'],
      expired: json['expired'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'membershipPeriod': membershipPeriod,
      'actualAmount': actualAmount,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'paidDueAmount': paidDueAmount,
    };
  }
}

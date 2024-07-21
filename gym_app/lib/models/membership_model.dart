class Membership {
  String? memberId;
  int? membershipPeriod;
  int? membershipAmount; //actual amount
  int? paidAmount;
  int? dueAmount;
  int? daysRemaining;
  DateTime? planStartDate;
  DateTime? planExpiryDate;
  bool? expired;

  Membership({
    required this.memberId,
    required this.membershipAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.membershipPeriod,
    required this.daysRemaining,
    required this.expired,
    this.planStartDate,
    this.planExpiryDate,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      memberId: json['memberId'],
      membershipAmount: json['membershipAmount'],
      paidAmount: json['paidAmount'],
      membershipPeriod: json['membership_Period'],
      dueAmount: json['dueAmount'],
      daysRemaining: json['daysRemaining'],
      expired: json['expired'],
      planStartDate: DateTime.parse(json['planStartDate']),
      planExpiryDate: DateTime.parse(json['planExpiryDate']),
    );
  }
}

class MembershipPlan {
  final String id;
  final int months;
  final int price;

  MembershipPlan({required this.id, required this.months, required this.price});

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['_id'],
      months: json['months'],
      price: json['price'],
    );
  }
}

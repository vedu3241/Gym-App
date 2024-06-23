class MemberData {
  final String name;
  final String lname;
  final String phoneNumber;
  final String gender;
  final String medicalIssue;
  final int planMonths;

  //auto generated
  final String planStartDate;
  final String planExpiryDate;
  final int daysRemaining;
  final bool exprired; // Stores bool for exprired or not

  MemberData({
    required this.name,
    required this.lname,
    required this.phoneNumber,
    required this.gender,
    required this.medicalIssue,
    required this.planMonths,
    required this.planStartDate,
    required this.planExpiryDate,
    required this.daysRemaining,
    required this.exprired,
  });
}

List<MemberData> memberList = [
  MemberData(
    name: "Vedant",
    lname: "parulekar",
    phoneNumber: "8828059825",
    planMonths: 6,
    planStartDate: "10-05-2024",
    planExpiryDate: "10-05-2024",
    daysRemaining: 0,
    exprired: true,
    //Profile Screen Details

    gender: "Male",
    medicalIssue: "Neck Pain",
  ),
  MemberData(
    name: "Zubair",
    lname: "patel",
    phoneNumber: "9321647276",
    planMonths: 4,
    planStartDate: "10-05-2024",
    planExpiryDate: "21-05-2024",
    daysRemaining: 20,
    exprired: false,
    gender: "Male",
    medicalIssue: "None",
  ),
  MemberData(
    name: "zeel",
    lname: "Patel",
    phoneNumber: "9321647276",
    planMonths: 6,
    planStartDate: "10-05-2024",
    planExpiryDate: "21-05-2024",
    daysRemaining: 22,
    exprired: false,
    gender: "Male",
    medicalIssue: "None",
  ),
  MemberData(
    name: "Jane",
    lname: "Smith",
    phoneNumber: "9876543210",
    planMonths: 6,
    planStartDate: "10-05-2024",
    planExpiryDate: "18-06-2024",
    daysRemaining: 30,
    exprired: false,
    gender: "Male",
    medicalIssue: "heart issue",
  ),
  MemberData(
    name: "Black",
    lname: "widow",
    phoneNumber: "5556667777",
    planMonths: 2,
    planStartDate: "10-05-2024",
    planExpiryDate: "10-07-2024",
    daysRemaining: 36,
    exprired: false,
    gender: "Female",
    medicalIssue: "Hand Fracture",
  ),
  MemberData(
    name: "Abhishek",
    lname: "yadav",
    phoneNumber: "5556667777",
    planMonths: 2,
    planStartDate: "10-05-2024",
    planExpiryDate: "10-07-2024",
    daysRemaining: 40,
    exprired: false,
    gender: "Female",
    medicalIssue: "Hand Fracture",
  ),

  MemberData(
    name: "Bot",
    lname: "xyz",
    phoneNumber: "5556667777",
    planMonths: 2,
    planStartDate: "10-05-2024",
    planExpiryDate: "10-07-2024",
    daysRemaining: 56,
    exprired: false,
    gender: "Female",
    medicalIssue: "Hand Fracture",
  ),
  MemberData(
    name: "Govind",
    lname: "parulekar",
    phoneNumber: "3377389409",
    planMonths: 4,
    planStartDate: "10-05-2024",
    planExpiryDate: "10-07-2024",
    daysRemaining: 0,
    exprired: true,
    gender: "Male",
    medicalIssue: "Hand Fracture",
  ),
  // Add more member data as needed
];

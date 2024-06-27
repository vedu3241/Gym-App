import 'package:flutter/material.dart';
import 'package:gym_app/API_services/api_service.dart';
import 'package:gym_app/components/my_app_bar.dart';
import 'package:gym_app/models/member_model.dart';
import 'package:http/http.dart';

class RenewMembershipScreen extends StatefulWidget {
  const RenewMembershipScreen({super.key, required this.member});
  final MemberModel member;

  @override
  State<RenewMembershipScreen> createState() => _RenewMembershipScreenState();
}

class _RenewMembershipScreenState extends State<RenewMembershipScreen> {
  //Form key
  final _formKey = GlobalKey<FormState>();

  int? _selectedPackage = 1;
  //Available Packages
  final List<int> packages = [1, 2, 4, 6, 8];

  int amount = 100;
  // Text Controllers

  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _dueAmountPaidController =
      TextEditingController(text: "0");

  int calculateAmount(int months) {
    // Example pricing logic, replace with your own
    switch (months) {
      case 1:
        return 100;
      case 2:
        return 180;
      case 4:
        return 250;
      case 6:
        return 300;
      case 8:
        return 350;
      default:
        return 200; // Default
    }
  }

  //Methods
  Future _updateMembership() async {
    try {
      MemberModel member = MemberModel(
        id: widget.member.id,
        membershipPeriod: _selectedPackage!,
        actualAmount: amount,
        paidAmount: int.parse(_amountPaidController.text),

        // Due fields
        dueAmount: widget.member.dueAmount,
        paidDueAmount: int.parse(_dueAmountPaidController.text),
      );

      final Response res = await ApiService().updateMembership(member);
      // final responseData = jsonDecode(res.body);
      print(res.body);
      if (res.statusCode == 200) {}
    } catch (err) {
      print("C_Error In updateMembership: ${err}");
    }
  }

  @override
  Widget build(BuildContext context) {
    amount.toString();

    return Scaffold(
      appBar: const MyAppBar(text: "New Member"),
      // backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(150.0),
                        child: Image.network(
                          'http://192.168.0.103:6666/public/profile_img/${widget.member.profileImg}',
                          width: 150,
                          height: 150,
                        )),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),

                  const SizedBox(
                    height: 20.0,
                  ),
                  // Full Name
                  Text(
                    "Full Name: ${widget.member.firstName!}${widget.member.lastName}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text("Number: ${widget.member.phoneNum}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500)),

                  const SizedBox(
                    height: 10,
                  ),
                  widget.member.dueAmount! > 0
                      ? Text(
                          "Due amount: ${widget.member.dueAmount}",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 20,
                  ),

                  // Drop down for package
                  DropdownButtonFormField<int>(
                    value: _selectedPackage,
                    decoration: const InputDecoration(
                      labelText: "Membership Duration",
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    iconEnabledColor: Colors.white,
                    items: packages.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          '${value.toString()} Month${value > 1 ? 's' : ''}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        _selectedPackage = value!;
                        amount = calculateAmount(value);
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  //Actual amount
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text(
                          "Amount: ",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        const Icon(
                          Icons.currency_rupee,
                          size: 20,
                        ),
                        Text(
                          amount.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
                  ),

                  //Input field for actual amount paid
                  TextFormField(
                    controller: _amountPaidController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field can't be empty";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text("Paid Amount"),
                      contentPadding: EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  // Input for due paid (if there any)
                  widget.member.dueAmount! > 0
                      ? TextFormField(
                          controller: _dueAmountPaidController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Field can't be empty";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            label: Text("Paid Due"),
                            contentPadding: EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 20,
                  ),
                  // Save button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Processing data"),
                            ),
                          );
                          _updateMembership();
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gym_app/Sample_Data/Member_data.dart';
import 'package:gym_app/Screens/member_profile.dart';
import 'package:gym_app/models/member_model.dart';
import 'package:intl/intl.dart';

class MemberTile extends StatelessWidget {
  const MemberTile({super.key, required this.obj});

  final MemberModel obj;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberProfile(
              user: obj,
            ),
          )),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: obj.expired!
              ? Border.all(color: const Color(0xFFE72929))
              : Border.all(color: Colors.white),
        ),
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //profile image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/icons/user_img.jpg',
                height: 60,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  obj.firstName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  obj.gender!,
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          "Plan Expiry",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        Text(
                          DateFormat.yMMMd().format(obj.planExpiryDate!),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Day Remaining",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        Text(
                          obj.daysRemaining.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
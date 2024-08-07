import 'package:flutter/material.dart';
import 'package:gym_app/Screens/member_profile.dart';
import 'package:gym_app/models/member_model.dart';
import 'package:gym_app/models/membership_model.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';

class MemberTile extends StatelessWidget {
  const MemberTile({super.key, required this.obj, this.membership});

  final MemberModel obj;
  final Membership? membership;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemberProfile(userId: obj.id!),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (membership == null || membership!.expired!)
                ? const Color(0xFFE72929)
                : Colors.white,
          ),
        ),
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image
            InstaImageViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'http://192.168.0.103:6666/public/profile_img/${obj.profileImg}',
                  width: 90,
                  height: 90,
                ),
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
                if (membership != null) ...[
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            "Plan Expiry",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          Text(
                            DateFormat.yMMMd()
                                .format(membership!.planExpiryDate!),
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
                            "Days Left",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          Text(
                            membership!.daysRemaining.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    ],
                  )
                ] else ...[
                  Text(
                    "No Membership",
                    style: TextStyle(
                      color: Colors.red[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}

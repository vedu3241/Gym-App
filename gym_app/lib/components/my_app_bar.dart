import 'package:flutter/material.dart';
import 'package:gym_app/Screens/add_member.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //heading
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            text == "Members"
                ? Row(
                    children: [
                      //bell icon
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      // Add member ICON
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddMemberScreen(),
                              ));
                        },
                        icon: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            'assets/icons/add_member_1.png',
                            width: 22,
                            height: 22,
                          ),
                        ),
                      )
                    ],
                  )
                : const SizedBox()
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 99, 137, 152),
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

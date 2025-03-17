import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../service/storage_service.dart';
import '../shared/consts.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool notificationPref = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: whiteColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100),
                // border: Border.all(color: whiteColor, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: whiteColor, size: 16),
                  Text(
                    " \$ 27.84",
                    style: textStyleS16W600.copyWith(
                      color: primaryLightColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        title:
            const Text("Profile Page", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                        "https://www.w3schools.com/w3images/avatar2.png"),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "John Doe",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const Center(
                  child: Text(
                    "johndoe@example.com",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "+1 (123) 456-7890",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Restaurant Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                const SizedBox(height: 10),
                const ListTile(
                  leading: Icon(Icons.restaurant, color: primaryColor),
                  title: Text(
                    "Green Bistro",
                    style: textStyleS16W700,
                  ),
                  subtitle: Text("A cozy place for gourmet food"),
                ),
                const ListTile(
                  leading: Icon(Icons.location_on, color: primaryColor),
                  title: Text("Address: 123 Green Street, NY"),
                ),
                const ListTile(
                  leading: Icon(Icons.fastfood, color: primaryColor),
                  title: Text("Cuisine Type: Italian"),
                ),
                const ListTile(
                  leading: Icon(Icons.phone, color: primaryColor),
                  title: Text("Restaurant Phone: +1 (987) 654-3210"),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Settings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications, color: primaryColor),
                  title: const Text("Notification Preferences"),
                  trailing: Switch(
                    value: notificationPref,
                    onChanged: (val) {
                      setState(() {
                        notificationPref = !notificationPref;
                      });
                    },
                    activeColor: primaryColor,
                    inactiveTrackColor: secondaryColor,
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.payment, color: primaryColor),
                  title: Text("Payment Methods"),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Edit Profile"),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          surfaceTintColor: whiteColor,
                          backgroundColor: whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 26,
                                color: loginBlackColor),
                          ),
                          content: const Text(
                            'Are you sure you want to logout?',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: hintTextColor),
                          ),
                          actions: [
                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    StorageService().deleteTokenStorage();
                                    // StorageService()
                                    //     .deleteAllValuesFromStorage();
                                    // StorageService()
                                    //     .createAndUpdateKeyValuePairInStorage('isFirstLogin', 'true');
                                    context.go('/');
                                  },
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: whiteColor),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'No',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: loginBlackColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: otpErrorColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

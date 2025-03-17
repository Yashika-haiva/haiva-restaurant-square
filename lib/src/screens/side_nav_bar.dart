import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../service/auth_service.dart';
import '../service/storage_service.dart';
import '../shared/consts.dart';
import '../shared/enum.dart';

class SideNavBar extends StatefulWidget {
  const SideNavBar({super.key});

  @override
  State<SideNavBar> createState() => _SideNavBarState();
}

class _SideNavBarState extends State<SideNavBar> with RestorationMixin {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showLogoutConfirmationDialog() async {
    final authService = Provider.of<AuthService>(context);
    return showDialog(
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
              fontWeight: FontWeight.w500, fontSize: 18, color: hintTextColor),
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
                onPressed: () async {
                  await authService.logout();
                  await StorageService().deleteTokenStorage();
                  // StorageService().deleteAllValuesFromStorage();
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
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double drawerWidth = screenWidth * 0.8;

    return Drawer(
      width: drawerWidth,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Center(
                  child: ListTile(
                    onTap: () {
                      context.push('/${Routes.editProfile.name}');
                    },
                    leading: ClipOval(
                      child: Image.asset(
                        "assets/images/no-profile.png",
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Agent for Restaurant",
                          style: textStyleS24W600.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(
                Icons.contact_support_outlined,
                size: 32,
              ),
              title: const Text(
                'Help',
                style: textStyleS20W400,
              ),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(
                Icons.exit_to_app_outlined,
                size: 32,
              ),
              title: const Text(
                'Logout',
                style: textStyleS20W400,
              ),
              onTap: () {
                _showLogoutConfirmationDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  String? get restorationId => "side_nav";

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {}
}

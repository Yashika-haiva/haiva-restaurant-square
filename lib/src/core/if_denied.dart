part of 'request_permissions.dart';

class IfDenied extends StatelessWidget {
  const IfDenied({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: whiteColor,
      surfaceTintColor: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: const Text(
        "Enable permission",
        style: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w500,
          color: primaryColor, // Use your color here
        ),
      ),
      content: const Text(
        "It looks like you haven’t enabled all the permissions that are required to access the app. Please go to settings to enable the required permissions.",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6A6A6A), // Use your color here
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            openAppSettings();
            Navigator.of(context).pop();
          },
          child: const Text(
            "Go to settings",
            style: TextStyle(
              color: primaryColor, // Customize color
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

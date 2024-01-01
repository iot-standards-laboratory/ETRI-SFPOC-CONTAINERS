import 'package:flutter/material.dart';

// add the warning icon
Future<bool> makeDialog(BuildContext context) async {
  var result = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
            ),
            SizedBox(width: 8),
            Text('Unsupported service'),
          ],
        ),
        backgroundColor:
            Theme.of(context).colorScheme.background.withOpacity(0.8),
        content: const Text(
            'This function requires a pro version. Please install the pro version.',
            style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Okay'),
          )
        ],
      );
    },
  );

  return (result as bool);
}

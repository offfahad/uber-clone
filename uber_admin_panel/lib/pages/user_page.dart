import 'package:flutter/material.dart';
import 'package:uber_admin_panel/methods/common_methods.dart';
import 'package:uber_admin_panel/widgets/users_data_list.dart';

class UserPage extends StatefulWidget {
  static const String id = "\webPageUsers";
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  CommonMethods commonMethods = CommonMethods();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Manage Users",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  //commonMethods.header(2, "USERS ID"),
                  commonMethods.header(1, "USER NAME"),
                  commonMethods.header(1, "USER EMAIL"),
                  commonMethods.header(1, "PHONE"),
                  commonMethods.header(1, "ACTIONS"),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              UsersDataList()
            ],
          ),
        ),
      ),
    );
  }
}

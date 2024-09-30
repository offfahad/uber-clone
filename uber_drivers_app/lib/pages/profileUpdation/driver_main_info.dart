import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/pages/profileUpdation/basic_driver_info_update_screen.dart';
import 'package:uber_drivers_app/pages/profileUpdation/cninc_update_screen.dart';
import 'package:uber_drivers_app/pages/profileUpdation/driving_license_update_screen.dart';
import 'package:uber_drivers_app/pages/profileUpdation/selfie_with_cninc_update_screen.dart';
import 'package:uber_drivers_app/pages/profileUpdation/vehicle_info_update_screen.dart';
import 'package:uber_drivers_app/providers/registration_provider.dart';

class DriverMainInfo extends StatefulWidget {
  @override
  _DriverMainInfoState createState() => _DriverMainInfoState();
}

class _DriverMainInfoState extends State<DriverMainInfo> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchUserData();
    });
  }

  Future<void> _fetchUserData() async {
    try {
      await Provider.of<RegistrationProvider>(context, listen: false)
          .fetchUserData();
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(builder: (context, provider, child) {

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile Updation',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: provider.isFetchLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Wait fetching your record..."),
                    SizedBox(height: 12,),
                    CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 6.0),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: 5,
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.grey,
                            thickness: 0.3,
                            indent: 0,
                            endIndent: 0,
                          ),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildListTile(
                                title: 'Basic info',
                                subtitle: 'Your basic information',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BasicDriverInfoUpdateScreen(),
                                    ),
                                  );
                                },
                              );
                            } else if (index == 1) {
                              return _buildListTile(
                                title: 'CNIC',
                                subtitle: 'Enter CNIC detail and images',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CnincUpdateScreen(),
                                    ),
                                  );
                                },
                              );
                            } else if (index == 2) {
                              return _buildListTile(
                                title: 'Selfie with CNIC',
                                subtitle: 'Take a selfie with your CNIC',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SelfieWithCnincUpdateScreen(),
                                    ),
                                  );
                                },
                              );
                            } else if (index == 3) {
                              return _buildListTile(
                                title: 'Driving License Info',
                                subtitle:
                                    'Enter driving license number and images',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DrivingLicenseUpdateScreen(),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return _buildListTile(
                                title: 'Vehicle Info',
                                subtitle: 'Enter vehicle details and images',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const VehicleInfoUpdateScreen(),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }

  // Build ListTile method
  Widget _buildListTile({
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}

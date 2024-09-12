import 'package:flutter/material.dart';
import 'package:uber_drivers_app/pages/driver_registration/basic_info_screen.dart';
import 'package:uber_drivers_app/pages/driver_registration/cninc_screen.dart';
import 'package:uber_drivers_app/pages/driver_registration/driving_license_screen.dart';
import 'package:uber_drivers_app/pages/driver_registration/selfie_screen.dart';
import 'vehicle_info_screen.dart';

class DriverRegistration extends StatefulWidget {
  @override
  _DriverRegistrationState createState() => _DriverRegistrationState();
}

class _DriverRegistrationState extends State<DriverRegistration> {
  bool isBasicInfoComplete = false;
  bool isCnicComplete = false;
  bool isSelfieComplete = false;
  bool isReferralCodeComplete = false;
  bool isVehicleInfoComplete = false;
  bool isDrivingLicenseInfoComplete = false;

  @override
  Widget build(BuildContext context) {
    bool isAllComplete = isBasicInfoComplete &&
        isCnicComplete &&
        isSelfieComplete &&
        isReferralCodeComplete &&
        isVehicleInfoComplete &&
        isDrivingLicenseInfoComplete;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registration',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Column(
          children: [
            // Container holding the ListView
            Container(
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
              width: MediaQuery.of(context).size.width *
                  0.9, // 90% of screen width
              // height: MediaQuery.of(context).size.height *
              //     0.5, // 45% of screen height
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: 5, // You have 4 items
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
                      isCompleted: isBasicInfoComplete,
                      onTap: () async {
                        bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BasicInfoScreen(),
                          ),
                        );
                        if (result != null && result) {
                          setState(() {
                            isBasicInfoComplete = true;
                          });
                        }
                      },
                    );
                  } else if (index == 1) {
                    return _buildListTile(
                      title: 'CNIC',
                      subtitle: 'Enter CNIC detail and images',
                      isCompleted: isCnicComplete,
                      onTap: () async {
                        bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CNICScreen(),
                          ),
                        );
                        if (result != null && result) {
                          setState(() {
                            isCnicComplete = true;
                          });
                        }
                      },
                    );
                  } else if (index == 2) {
                    return _buildListTile(
                      title: 'Selfie with CNIC',
                      subtitle: 'Take a selfie with your CNIC',
                      isCompleted: isSelfieComplete,
                      onTap: () async {
                        bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelfieScreen(),
                          ),
                        );
                        if (result != null && result) {
                          setState(() {
                            isSelfieComplete = true;
                          });
                        }
                      },
                    );
                  } else if (index == 3) {
                    return _buildListTile(
                      title: 'Driving License Info',
                      subtitle: 'Enter driving license number and images',
                      isCompleted: isDrivingLicenseInfoComplete,
                      onTap: () async {
                        bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DrivingLicenseScreen(),
                          ),
                        );
                        if (result != null && result) {
                          setState(() {
                            isDrivingLicenseInfoComplete = true;
                          });
                        }
                      },
                    );
                  } else {
                    return _buildListTile(
                      title: 'Vehicle Info',
                      subtitle: 'Enter vehicle details and images',
                      isCompleted: isVehicleInfoComplete,
                      onTap: () async {
                        bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VehicleInfoScreen(),
                          ),
                        );
                        if (result != null && result) {
                          setState(() {
                            isVehicleInfoComplete = true;
                          });
                        }
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            // Done button
            SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.9, // 90% of screen width
              height: MediaQuery.of(context).size.height *
                  0.09, // 9% of screen height
              child: ElevatedButton(
                onPressed: isAllComplete
                    ? () {
                        // Submit all the data
                      }
                    : null, // Disable button if not all sections are complete
                child:
                    const Text('Done', style: TextStyle(color: Colors.black87)),
              ),
            ),
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'By tapping "Submit" you agree to our Terms and Conditions and Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build ListTile method
  Widget _buildListTile(
      {required String title,
      required String subtitle,
      required bool isCompleted,
      required Function() onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
      ),
      subtitle: Text(subtitle),
      trailing: isCompleted
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}

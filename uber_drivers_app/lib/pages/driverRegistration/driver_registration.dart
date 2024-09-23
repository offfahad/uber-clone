import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/methods/common_method.dart';
import 'package:uber_drivers_app/pages/dashboard.dart';
import 'package:uber_drivers_app/pages/driverRegistration/basic_info_screen.dart';
import 'package:uber_drivers_app/pages/driverRegistration/cninc_screen.dart';
import 'package:uber_drivers_app/pages/driverRegistration/driving_license_screen.dart';
import 'package:uber_drivers_app/pages/driverRegistration/selfie_screen.dart';
import 'package:uber_drivers_app/providers/registration_provider.dart';
import 'vehicle_info_screen.dart';

class DriverRegistration extends StatefulWidget {
  @override
  _DriverRegistrationState createState() => _DriverRegistrationState();
}

class _DriverRegistrationState extends State<DriverRegistration> {
  bool isBasicInfoComplete = false;
  bool isCnicComplete = false;
  bool isSelfieComplete = false;
  bool isVehicleInfoComplete = false;
  bool isDrivingLicenseInfoComplete = false;

  // Function to recalculate 'isAllComplete'
  void _recalculateAllComplete() {
    setState(() {
      isAllComplete = isBasicInfoComplete &&
          isCnicComplete &&
          isSelfieComplete &&
          isVehicleInfoComplete &&
          isDrivingLicenseInfoComplete;
    });
  }

  bool isAllComplete = false;

  @override
  Widget build(BuildContext context) {
    
    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Registration',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                                _recalculateAllComplete();
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
                                _recalculateAllComplete();
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
                                _recalculateAllComplete();
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
                                builder: (context) =>
                                    const DrivingLicenseScreen(),
                              ),
                            );
                            if (result != null && result) {
                              setState(() {
                                isDrivingLicenseInfoComplete = true;
                                _recalculateAllComplete();
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
                                builder: (context) => VehicleInfoScreen(),
                              ),
                            );
                            if (result != null && result) {
                              setState(() {
                                isVehicleInfoComplete = true;
                                _recalculateAllComplete();
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
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.09,
                  child: ElevatedButton(
                    onPressed: isAllComplete && !registrationProvider.isLoading
                        ? () async {
                            registrationProvider.startLoading();
                            try {
                              await registrationProvider.saveUserData(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => const Dashboard(),
                                ),
                              );
                              CommonMethods commonMethods = CommonMethods();
                              commonMethods.displaySnackBar(
                                  "Your account created successfully.",
                                  context);
                            } catch (e) {
                              print("Error while saving data: $e");
                            } finally {
                              registrationProvider.stopLoading();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isAllComplete ? Colors.green : Colors.grey,
                    ),
                    child: registrationProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Done',
                            style: TextStyle(color: Colors.white)),
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
        ),
      ),
    );
  }

  // Build ListTile method
  Widget _buildListTile({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required Function() onTap,
  }) {
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

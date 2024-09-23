import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/pages/driverRegistration/cninc_screen.dart';
import 'package:uber_drivers_app/pages/driverRegistration/selfie_screen.dart';
import 'package:uber_drivers_app/pages/driverRegistration/vehicle_registration/driver_car_image_screeen.dart';
import 'package:uber_drivers_app/pages/driverRegistration/vehicle_registration/vehicle_baisc_info.dart';
import 'package:uber_drivers_app/pages/driverRegistration/vehicle_registration/vehicle_registration_screen.dart';
import 'package:uber_drivers_app/providers/registration_provider.dart';

class VehicleInfoScreen extends StatefulWidget {
  @override
  _VehicleInfoScreenState createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  bool isBasicInfoComplete = false;
  bool isVehiclePictureComplete = false;
  bool isCertificateOfVehicleComplete = false;

  @override
  Widget build(BuildContext context) {
    bool isAllComplete = isBasicInfoComplete &&
        isVehiclePictureComplete &&
        isCertificateOfVehicleComplete;

    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Vehicle Info',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 15.0), // Adjust vertical padding
          child: Center(
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
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width *
                      0.9, // 90% of screen width
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: 3, // Number of items
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey,
                      thickness: 0.3,
                    ),
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _buildListTile(
                            title: 'Basic Vehicle Info',
                            subtitle:
                                'Enter vehicle type, brand name, registration number',
                            isCompleted: isBasicInfoComplete,
                            onTap: () async {
                              bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VehicleBasicInfoScreen(),
                                ),
                              );
                              if (result != null && result) {
                                setState(() {
                                  isBasicInfoComplete = true;
                                });
                              }
                            },
                          );
                        case 1:
                          return _buildListTile(
                            title: 'Vehicle Picture',
                            subtitle: 'Upload your vehicle picture',
                            isCompleted: isVehiclePictureComplete,
                            onTap: () async {
                              bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DriverCarImageScreeen(),
                                ),
                              );
                              if (result != null && result) {
                                setState(() {
                                  isVehiclePictureComplete = true;
                                });
                              }
                            },
                          );
                        case 2:
                          return _buildListTile(
                            title: 'Certificate Of Vehicle Registration',
                            subtitle:
                                'Upload registration certificate images of your vehicle',
                            isCompleted: isCertificateOfVehicleComplete,
                            onTap: () async {
                              bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VehicleRegistrationScreen(),
                                ),
                              );
                              if (result != null && result) {
                                setState(() {
                                  isCertificateOfVehicleComplete = true;
                                });
                              }
                            },
                          );
                        default:
                          return const SizedBox
                              .shrink(); // Return an empty widget for out-of-bounds
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isAllComplete ? Colors.green : Colors.grey,
                    ),
                    onPressed: isAllComplete
                        ? () async {
                            // Submit all the data
                            Navigator.pop(context, true);
                          }
                        : null, // Disable button if not all sections are complete
                    child: Text('Done',
                        style: TextStyle(
                            color:
                                isAllComplete ? Colors.white : Colors.black)),
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
    required VoidCallback onTap,
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

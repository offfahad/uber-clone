import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/pages/profileUpdation/vehicleUpdation/driver_car_image_update_screen.dart';
import 'package:uber_drivers_app/pages/profileUpdation/vehicleUpdation/vehicle_baisc_info_update_screen.dart';
import 'package:uber_drivers_app/pages/profileUpdation/vehicleUpdation/vehicle_registration_update_screen.dart';
import 'package:uber_drivers_app/providers/registration_provider.dart';

class VehicleInfoUpdateScreen extends StatefulWidget {
  const VehicleInfoUpdateScreen({super.key});

  @override
  State<VehicleInfoUpdateScreen> createState() =>
      _VehicleInfoUpdateScreenState();
}

class _VehicleInfoUpdateScreenState extends State<VehicleInfoUpdateScreen> {
  @override
  Widget build(BuildContext context) {
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
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VehicleBaiscInfoUpdateScreen(),
                                ),
                              );
                            },
                          );
                        case 1:
                          return _buildListTile(
                            title: 'Vehicle Picture',
                            subtitle: 'Upload your vehicle picture',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DriverCarImageUpdateScreeen(),
                                ),
                              );
                            },
                          );
                        case 2:
                          return _buildListTile(
                            title: 'Certificate Of Vehicle Registration',
                            subtitle:
                                'Upload registration certificate images of your vehicle',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VehicleRegistrationUpdateScreen(),
                                ),
                              );
                            },
                          );
                        default:
                          return const SizedBox
                              .shrink(); // Return an empty widget for out-of-bounds
                      }
                    },
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

// Build ListTile method
Widget _buildListTile({
  required String title,
  required String subtitle,
  required VoidCallback onTap,
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

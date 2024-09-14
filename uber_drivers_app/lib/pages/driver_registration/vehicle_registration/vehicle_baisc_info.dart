import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/providers/registration_provider.dart';

class VehicleBasicInfoScreen extends StatefulWidget {
  const VehicleBasicInfoScreen({super.key});

  @override
  State<VehicleBasicInfoScreen> createState() => _VehicleBasicInfoScreenState();
}

class _VehicleBasicInfoScreenState extends State<VehicleBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  // String? _selectedVehicle;
  // bool _isFormValid = false;

  // final TextEditingController _modelController = TextEditingController();
  // final TextEditingController _colorController = TextEditingController();
  // final TextEditingController _numberPlateController = TextEditingController();
  // final TextEditingController _productionYear = TextEditingController();

  // void _checkFormValidity() {
  //   setState(() {
  //     _isFormValid =
  //         _formKey.currentState?.validate() == true && _selectedVehicle != null;
  //   });
  // }

  // @override
  // void dispose() {
  //   _modelController.dispose();
  //   _colorController.dispose();
  //   _numberPlateController.dispose();
  //   _productionYear.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle Info"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            onChanged: () {
              registrationProvider.checkVehicleBasicFormValidity();
            }, // Check form validity on changes
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
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
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Row(
                          children: [
                            Image.asset(
                              "assets/vehicles/home_car.png",
                              height: 50,
                              width: 100,
                            ),
                            const SizedBox(width: 10),
                            const Text("Car"),
                          ],
                        ),
                        value: registrationProvider.selectedVehicle == "Car",
                        onChanged: (bool? value) {
                          if (value == true) {
                            registrationProvider.setSelectedVehicle("Car");
                          }
                        },
                      ),
                      const SizedBox(height: 5),
                      CheckboxListTile(
                        title: Row(
                          children: [
                            Image.asset(
                              "assets/vehicles/bike.png",
                              height: 50,
                              width: 100,
                            ),
                            const SizedBox(width: 10),
                            const Text("Bike"),
                          ],
                        ),
                        value: registrationProvider.selectedVehicle == "Bike",
                        onChanged: (bool? value) {
                          if (value == true) {
                            registrationProvider.setSelectedVehicle("bike");
                          }
                        },
                      ),
                      const SizedBox(height: 5),
                      CheckboxListTile(
                        title: Row(
                          children: [
                            Image.asset(
                              "assets/vehicles/auto.png",
                              height: 50,
                              width: 100,
                            ),
                            const SizedBox(width: 10),
                            const Text("Auto"),
                          ],
                        ),
                        value: registrationProvider.selectedVehicle == "Auto",
                        onChanged: (bool? value) {
                          if (value == true) {
                            registrationProvider.setSelectedVehicle("Auto");
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: registrationProvider.brandController,
                        decoration: const InputDecoration(
                          labelText: 'Brand Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Brand Name is required';
                          }
                          return null;
                        },
                        onChanged: (_) => registrationProvider
                            .checkVehicleBasicFormValidity(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: registrationProvider.colorController,
                        decoration: const InputDecoration(
                          labelText: 'Color',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Color is required';
                          }
                          return null;
                        },
                        onChanged: (_) => registrationProvider
                            .checkVehicleBasicFormValidity(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller:
                            registrationProvider.productionYearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Production Year',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Production Year is required';
                          }
                          return null;
                        },
                        onChanged: (_) => registrationProvider
                            .checkVehicleBasicFormValidity(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: registrationProvider.numberPlateController,
                        decoration: const InputDecoration(
                          labelText: 'Number Plate',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Number Plate is required';
                          }
                          return null;
                        },
                        onChanged: (_) => registrationProvider
                            .checkVehicleBasicFormValidity(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.09,
                  child: ElevatedButton(
                    onPressed: registrationProvider.isVehicleBasicFormValid
                        ? () async {
                            if (_formKey.currentState?.validate() == true) {
                              try {
                                //await registrationProvider.saveUserData();
                                Navigator.pop(context, true);
                              } catch (e) {
                                print("Error while saving data: $e");
                              } finally {}
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          registrationProvider.isVehicleBasicFormValid
                              ? Colors.green
                              : Colors.grey,
                    ),
                    child: const Text('Done',
                        style: TextStyle(color: Colors.white)),
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

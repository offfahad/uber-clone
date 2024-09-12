import 'package:flutter/material.dart';

class VehicleBasicInfoScreen extends StatefulWidget {
  const VehicleBasicInfoScreen({super.key});

  @override
  State<VehicleBasicInfoScreen> createState() => _VehicleBasicInfoScreenState();
}

class _VehicleBasicInfoScreenState extends State<VehicleBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVehicle;
  bool _isFormValid = false;

  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _numberPlateController = TextEditingController();
  final TextEditingController _productionYear = TextEditingController();

  void _checkFormValidity() {
    setState(() {
      _isFormValid =
          _formKey.currentState?.validate() == true && _selectedVehicle != null;
    });
  }

  @override
  void dispose() {
    _modelController.dispose();
    _colorController.dispose();
    _numberPlateController.dispose();
    _productionYear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            onChanged: _checkFormValidity, // Check form validity on changes
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
                        value: _selectedVehicle == "Car",
                        onChanged: (bool? value) {
                          if (value == true) {
                            setState(() {
                              _selectedVehicle = "Car";
                            });
                            //_checkFormValidity();
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
                        value: _selectedVehicle == "Bike",
                        onChanged: (bool? value) {
                          if (value == true) {
                            setState(() {
                              _selectedVehicle = "Bike";
                            });
                            //_checkFormValidity();
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
                        value: _selectedVehicle == "Auto",
                        onChanged: (bool? value) {
                          if (value == true) {
                            setState(() {
                              _selectedVehicle = "Auto";
                            });
                            //_checkFormValidity();
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
                        controller: _modelController,
                        decoration: const InputDecoration(
                          labelText: 'Brand Name',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Brand Name is required';
                          }
                          return null;
                        },
                        //onChanged: (_) => _checkFormValidity(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(
                          labelText: 'Color',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Color is required';
                          }
                          return null;
                        },
                        //onChanged: (_) => _checkFormValidity(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _productionYear,
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
                        //onChanged: (_) => _checkFormValidity(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _numberPlateController,
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
                        //onChanged: (_) => _checkFormValidity(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.9, // 90% of screen width
                  height: MediaQuery.of(context).size.height *
                      0.09, // 9% of screen height
                  child: ElevatedButton(
                    onPressed: _isFormValid
                        ? () {
                            // Submit all the data
                          }
                        : null, // Disable button if not all sections are complete
                    child: const Text('Done',
                        style: TextStyle(color: Colors.black87)),
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

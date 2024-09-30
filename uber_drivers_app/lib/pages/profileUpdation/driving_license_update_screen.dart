import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/pages/profileUpdation/cninc_update_screen.dart';

import '../../providers/registration_provider.dart';

class DrivingLicenseUpdateScreen extends StatefulWidget {
  const DrivingLicenseUpdateScreen({super.key});

  @override
  State<DrivingLicenseUpdateScreen> createState() =>
      _DrivingLicenseUpdateScreenState();
}

class _DrivingLicenseUpdateScreenState
    extends State<DrivingLicenseUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Driving License'),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CNIC Front Side Upload
                  _buildImagePickerFront(
                      context,
                      'License (Front Side - First Capture Then Crop)',
                      registrationProvider.drivingLicenseFrontImage,
                      () => registrationProvider
                          .pickAndCropDrivingLicenseImage(true)),
                  const SizedBox(height: 16),

                  // CNIC Back Side Upload
                  _buildImagePickerBack(
                      context,
                      'License (Back Side - First Capture Then Crop)',
                      registrationProvider.drivingLicenseBackImage,
                      () => registrationProvider
                          .pickAndCropDrivingLicenseImage(false)),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: TextFormField(
                      controller: registrationProvider.drivingLicenseController,
                      decoration: const InputDecoration(
                        labelText: 'License Number',
                        helperText: 'Format: ST-24-7174',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'License Number is required';
                        }
                        if (!registrationProvider.licenseRegExp
                            .hasMatch(value)) {
                          return 'Please enter a valid license number in ST-24-7174 format';
                        }
                        return null;
                      },
                      onChanged: (value) => registrationProvider
                          .checkDrivingLicenseFormValidity(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ElevatedButton(
                      onPressed: registrationProvider
                                  .isFormValidDrivingLicnese &&
                              registrationProvider.isLoading == false
                          ? () async {
                              if (_formKey.currentState?.validate() == true) {
                                try {
                                  await registrationProvider
                                      .updatedriverLicenseInfo(context);

                                  commonMethods.displaySnackBar(
                                      "Data has been updated", context);
                                } catch (e) {
                                  print("Error while saving data: $e");
                                } finally {}
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            registrationProvider.isFormValidDrivingLicnese
                                ? Colors.green
                                : Colors.grey,
                      ),
                      child: registrationProvider.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                          : const Text('Update',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildImagePickerFront(BuildContext context, String label,
    XFile? imageFile, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 6.0),
      ],
    ),
    child: Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(label),
        ),
        const SizedBox(height: 16),
        imageFile != null
            ? Image.file(File(imageFile.path), height: 150)
            : Image.asset('assets/auth/license-front.png', height: 150),
        const SizedBox(height: 16),
        Container(
          width: 200,
          height: 40,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(12)),
          child: TextButton.icon(
            onPressed: onPressed,
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.black87,
            ),
            label: const Text(
              'Add a photo',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    ),
  );
}

Widget _buildImagePickerBack(BuildContext context, String label,
    XFile? imageFile, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 6.0),
      ],
    ),
    child: Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(label),
        ),
        imageFile != null
            ? Image.file(File(imageFile.path), height: 150)
            : Image.asset('assets/auth/license-back.png', height: 150),
        const SizedBox(height: 16),
        Container(
          width: 200,
          height: 40,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(12)),
          child: TextButton.icon(
            onPressed: onPressed,
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.black87,
            ),
            label: const Text(
              'Add a photo',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}

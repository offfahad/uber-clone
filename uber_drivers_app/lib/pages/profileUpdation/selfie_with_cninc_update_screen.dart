import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/methods/common_method.dart';

import '../../providers/registration_provider.dart';

class SelfieWithCnincUpdateScreen extends StatefulWidget {
  const SelfieWithCnincUpdateScreen({super.key});

  @override
  State<SelfieWithCnincUpdateScreen> createState() =>
      _SelfieWithCnincUpdateScreenState();
}

CommonMethods commonMethods = CommonMethods();

class _SelfieWithCnincUpdateScreenState
    extends State<SelfieWithCnincUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Selfie With CNIC'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CNIC Front Side Upload
                _buildImagePicker(
                    context,
                    'ID Confirmation',
                    registrationProvider.cnicWithSelfieImage,
                    registrationProvider.pickCnincImageWithSelfie,
                    'Bring your CNIC in front of you and take a photo as an example. The photo should clerly show face and ID card. The photo must be taken in good light and good quality.' // Pick image when button is pressed
                    ),
                const SizedBox(height: 16),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: ElevatedButton(
                    onPressed:
                        registrationProvider.cnicWithSelfieImage != null &&
                                registrationProvider.isLoading == false
                            ? () async {
                                try {
                                  await registrationProvider
                                      .updateSelfieWithCnincInfo(context);
                                  commonMethods.displaySnackBar(
                                      "Data has been updated.", context);
                                } catch (e) {
                                  print("Error while saving data: $e");
                                } finally {}
                              }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          registrationProvider.cnicWithSelfieImage != null
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
            : Image.asset('assets/auth/cnic-front.png', height: 150),
        const SizedBox(height: 16),
        Container(
          width: 200,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(12),
          ),
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

Widget _buildImagePicker(BuildContext context, String label, XFile? imageFile,
    VoidCallback onPressed, String description) {
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
        const SizedBox(height: 16),
        imageFile != null
            ? Image.file(File(imageFile.path), height: 200)
            : Image.asset('assets/auth/selfie-with-id.png', height: 200),
        const SizedBox(height: 16),
        Container(
          width: 200,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.camera_alt, color: Colors.black87),
            label: const Text(
              'Add a photo',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            description,
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

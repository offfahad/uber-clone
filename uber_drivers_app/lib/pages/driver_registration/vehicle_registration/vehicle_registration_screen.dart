import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uber_drivers_app/methods/image_picker_service.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  _VehicleRegistrationScreenState createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  XFile? _frontImage;
  XFile? _backImage;
  bool _isFormValid = false;

  // Check if the form is valid
  void _checkFormValidity() {
    setState(() {
      _isFormValid = _frontImage != null && _backImage != null;
    });
  }

  // Pick and crop image from gallery or camera
  Future<void> _pickAndCropImage(bool isFrontImage) async {
    final pickedFile = await ImagePickerService().pickCropImage(
      cropAspectRatio: CropAspectRatio(ratioX: 20, ratioY: 20),
      imageSource: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        if (isFrontImage) {
          _frontImage = pickedFile;
        } else {
          _backImage = pickedFile;
        }
        _checkFormValidity();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vehicle Registration Certificate',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
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
                    'Vehicle Certificate (Front Side)',
                    _frontImage,
                    () => _pickAndCropImage(true)),
                const SizedBox(height: 16),

                // CNIC Back Side Upload
                _buildImagePickerBack(
                    context,
                    'Vehicle Certificate (Back Side)',
                    _backImage,
                    () => _pickAndCropImage(false)),
                const SizedBox(height: 16),

                // Submit button
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.9, // 90% of screen width
                  height: MediaQuery.of(context).size.height *
                      0.09, // 9% of screen height
                  child: ElevatedButton(
                    onPressed: _isFormValid
                        ? () {
                            // Handle form submission
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isFormValid ? Colors.green : Colors.grey,
                    ), // Disable if form is not valid
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerFront(BuildContext context, String label,
      XFile? imageFile, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, offset: Offset(0, 2), blurRadius: 6.0),
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

  Widget _buildImagePickerBack(BuildContext context, String label,
      XFile? imageFile, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, offset: Offset(0, 2), blurRadius: 6.0),
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
              : Image.asset('assets/auth/cnic-back.png', height: 150),
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
}

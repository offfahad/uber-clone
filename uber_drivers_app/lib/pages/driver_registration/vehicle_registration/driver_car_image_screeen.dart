import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber_drivers_app/methods/image_picker_service.dart';

class DriverCarImageScreeen extends StatefulWidget {
  const DriverCarImageScreeen({super.key});

  @override
  State<DriverCarImageScreeen> createState() => _DriverCarImageScreeenState();
}

class _DriverCarImageScreeenState extends State<DriverCarImageScreeen> {
  XFile? _vehicleImage; // Store the image
  bool _isImageSelected = false; // Check if image is selected

  // Pick and crop image from gallery or camera
  Future<void> _pickAndCropImage() async {
    final pickedFile = await ImagePickerService().pickCropImage(
      cropAspectRatio: CropAspectRatio(ratioX: 20, ratioY: 20),
      imageSource: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        _vehicleImage = pickedFile;
        _isImageSelected = true; // Enable button when an image is selected
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Pitcure'),
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
                'Photo of your vehicle',
                _vehicleImage,
                _pickAndCropImage,
                // Pick image when button is pressed
              ),
              const SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.9, // 90% of screen width
                height: MediaQuery.of(context).size.height *
                    0.09, // 9% of screen height
                child: ElevatedButton(
                  onPressed: _isImageSelected
                      ? () {
                          // Handle the action when the image is selected
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Image uploaded successfully!')),
                          );
                        }
                      : null, // Disable button if no image is selected
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isImageSelected ? Colors.green : Colors.grey,
                  ),
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
    );
  }

  Widget _buildImagePicker(BuildContext context, String label, XFile? imageFile,
      VoidCallback onPressed) {
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
          const SizedBox(height: 16),
          imageFile != null
              ? Image.file(File(imageFile.path), height: 150)
              : Image.asset('assets/vehicles/civic.jpg', height: 150),
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
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../methods/image_picker_service.dart';

class CNICScreen extends StatefulWidget {
  const CNICScreen({super.key});

  @override
  _CNICScreenState createState() => _CNICScreenState();
}

class _CNICScreenState extends State<CNICScreen> {
  final _formKey = GlobalKey<FormState>();

  XFile? _frontImage;
  XFile? _backImage;
  final TextEditingController _cnicController = TextEditingController();
  bool _isFormValid = false;

  // Check if the form is valid
  void _checkFormValidity() {
    setState(() {
      _isFormValid = _frontImage != null &&
          _backImage != null &&
          _cnicController.text.isNotEmpty &&
          _cnicController.text.length == 13;
    });
  }

  // Pick and crop image from gallery or camera
  Future<void> _pickAndCropImage(bool isFrontImage) async {
    final pickedFile = await ImagePickerService().pickCropImage(
      cropAspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
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
        title: const Text('CNIC'),
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
                    'CNIC (Front Side - First Capture Then Crop)',
                    _frontImage,
                    () => _pickAndCropImage(true)),
                const SizedBox(height: 16),

                // CNIC Back Side Upload
                _buildImagePickerBack(
                    context,
                    'CNIC (Back Side - First Capture Then Crop)',
                    _backImage,
                    () => _pickAndCropImage(false)),
                const SizedBox(height: 16),

                // CNIC Number TextField
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
                          blurRadius: 6.0),
                    ],
                  ),
                  child: TextFormField(
                    controller: _cnicController,
                    decoration: const InputDecoration(
                        labelText: 'CNIC Number',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                            borderSide: BorderSide())),
                    keyboardType: TextInputType.number,
                    maxLength: 13,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'CNIC Number is required';
                      }
                      if (value.length != 13) {
                        return 'CNIC Number must be 13 digits';
                      }
                      return null;
                    },
                    onChanged: (value) => _checkFormValidity(),
                  ),
                ),
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

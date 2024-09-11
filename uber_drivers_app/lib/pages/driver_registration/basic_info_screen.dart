import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  _BasicInfoScreenState createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPhotoAdded = false;
  bool _isFormValid = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  XFile? _photo;

  // Check if all fields are filled
  void _checkFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() == true && _isPhotoAdded;
    });
  }

  // Handle picking image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _photo = image;
        _isPhotoAdded = true;
      });
    }

    _checkFormValidity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Basic info',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Close',
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image upload section
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(31, 255, 239, 239),
                          offset: Offset(0, 2),
                          blurRadius: 6.0),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width *
                      0.9, // 90% of screen width
                  height: MediaQuery.of(context).size.height *
                      0.5, // 45% of screen height
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _photo != null
                          ? Image.file(File(_photo!.path), height: 150)
                          : Image.asset('assets/auth/user.jpg', height: 150),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextButton.icon(
                          onPressed: _pickImage,
                          //icon: const Icon(Icons.camera_alt),
                          label: const Text('Add a photo*', style: TextStyle(color: Colors.green),),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• Clearly visible face', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                          Text('• Without sunglasses', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          Text('• Good lighting and without filters', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // First Name field
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name field
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date of Birth field
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of birth (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dobController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      });
                    }
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 32),

                // Submit button
                ElevatedButton(
                  onPressed: _isFormValid
                      ? () {
                          // Handle form submission
                        }
                      : null, // Button is disabled until the form is valid
                  child: const Text('OK'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid
                        ? Colors.blue
                        : Colors.grey, // Color change based on form status
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

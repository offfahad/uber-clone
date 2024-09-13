import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber_drivers_app/methods/image_picker_service.dart';
import 'package:uber_drivers_app/models/driver.dart';
import 'package:uber_drivers_app/models/vehicleInfo.dart';
import 'package:uber_drivers_app/providers/auth_provider.dart';

class RegistrationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  XFile? _profilePhoto;
  bool _isPhotoAdded = false;
  bool _isFormValidBasic = false;
  bool _isFormValidCninc = false;
  XFile? _cnicFrontImage;
  XFile? _cnicBackImage;
  XFile? _cnicWithSelfieImage;

  // TextEditingControllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  // Getters
  XFile? get profilePhoto => _profilePhoto;
  bool get isPhotoAdded => _isPhotoAdded;
  bool get isFormValidBasic => _isFormValidBasic;
  bool get isLoading => _isLoading;
  XFile? get cnincFrontImage => _cnicFrontImage;
  XFile? get cnincBackImage => _cnicBackImage;
  bool get isFormValidCninc => _isFormValidCninc;
  XFile? get cnicWithSelfieImage => _cnicWithSelfieImage;

  Timer? _debounce;

  void checkBasicFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isFormValidBasic = firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          dobController.text.isNotEmpty &&
          _isPhotoAdded;
      notifyListeners();
    });
  }

  void checkCNICFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isFormValidCninc = _cnicFrontImage != null &&
          _cnicBackImage != null &&
          cnicController.text.isNotEmpty &&
          cnicController.text.length == 13;
      notifyListeners();
    });
  }

  void checkCNICWithSelfieFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isFormValidCninc = _cnicFrontImage != null &&
          _cnicBackImage != null &&
          cnicController.text.isNotEmpty &&
          cnicController.text.length == 13;
      notifyListeners();
    });
  }

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _profilePhoto = image;
      _isPhotoAdded = true;
      notifyListeners();
    }
  }

  Future<void> pickAndCropImage(bool isFrontImage) async {
    final ImagePickerService imagePickerService = ImagePickerService();

    final pickedFile = await imagePickerService.pickCropImage(
      cropAspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
      imageSource: ImageSource.camera,
    );

    if (pickedFile != null) {
      if (isFrontImage) {
        _cnicFrontImage = pickedFile;
      } else {
        _cnicBackImage = pickedFile;
      }
      checkCNICFormValidity();
    }
  }

  Future<void> pickCnincImageWithSelfie() async {
    final ImagePickerService imagePickerService = ImagePickerService();

    final pickedFile = await imagePickerService.pickCropImage(
      cropAspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
      imageSource: ImageSource.camera,
    );

    if (pickedFile != null) {
      _cnicWithSelfieImage = pickedFile;
    }
    checkCNICFormValidity();
  }

  Future<String> uploadImageToFirebaseStorage(
      XFile? photo, String? path) async {
    if (photo == null) {
      throw Exception("No image selected");
    }
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    final file = File(_profilePhoto!.path);
    final reference = _storage
        .ref()
        .child(_auth.currentUser!.uid)
        .child(path!)
        .child(imageIDName);
    final uploadTask = reference.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> saveUserData() async {
    if (!isFormValidBasic) {
      throw Exception("Form is not valid");
    }
    try {
      startLoading();
      final profilePictureUrl =
          await uploadImageToFirebaseStorage(_profilePhoto, "ProfilePicture");
      final driver = Driver(
        id: _auth.currentUser!.uid,
        profilePicture: profilePictureUrl,
        firstName: firstNameController.text,
        secondName: lastNameController.text,
        phoneNumber: phoneController.text,
        dob: dobController.text,
        email: emailController.text,
        cnicNumber: '', // Add these fields if required
        cnicFrontImage: '',
        cnicBackImage: '',
        driverFaceWithCnic: '',
        drivingLicenseNumber: '',
        drivingLicenseFrontImage: '',
        drivingLicenseBackImage: '',
        vehicleInfo: VehicleInfo(
          type: '',
          brand: '',
          color: '',
          vehiclePicture: '',
          productionYear: '',
          registrationPlateNumber: '',
          registrationCertificateBackImage: '',
          registrationCertificateFrontImage: '',
        ), // Initialize properly if needed
      );

      final userRef =
          _database.ref().child("drivers").child(_auth.currentUser!.uid);
      await userRef.set(driver.toMap());
      stopLoading();
    } catch (e) {
      stopLoading();
      print("An error occurred while saving user data: $e");
    }
  }

  void initFields(AuthenticationProvider authProvider) {
    if (!authProvider.isGoogleSignedIn) {
      phoneController.text = authProvider.phoneNumber;
    }
    if (authProvider.isGoogleSignedIn) {
      emailController.text =
          authProvider.firebaseAuth.currentUser!.email.toString();
      phoneController.text = '';
    }
    checkBasicFormValidity();
  }

  Future<void> saveCNICData() async {
    if (!_isFormValidCninc) {
      throw Exception("Form is not valid");
    }
    try {
      startLoading();

      // Upload CNIC images
      final frontImageUrl =
          await uploadImageToFirebaseStorage(_cnicFrontImage, "Cninc");
      final backImageUrl =
          await uploadImageToFirebaseStorage(_cnicBackImage, "Cninc");

      // Create CNIC data
      final driverData = {
        'id': _auth.currentUser!.uid,
        'cnicNumber': cnicController.text,
        'cnicFrontImage': frontImageUrl,
        'cnicBackImage': backImageUrl,
      };

      // Update driver data in Firebase Realtime Database
      final userRef =
          _database.ref().child("drivers").child(_auth.currentUser!.uid);
      await userRef.update(driverData);

      stopLoading();
    } catch (e) {
      stopLoading();
      print("An error occurred while saving CNIC data: $e");
    }
  }
}

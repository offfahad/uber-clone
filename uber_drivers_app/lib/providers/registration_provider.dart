import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber_drivers_app/methods/common_method.dart';
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
  bool _isFormValidDrivingLicense = false;
  XFile? _drivingLicenseFrontImage;
  XFile? _drivingLicenseBackImage;
  String? _selectedVehicle;
  bool _isVehicleBasicFormValid = false;
  final RegExp licenseRegExp = RegExp(r'^[A-Z]{2}-\d{2}-\d{4}$');
  XFile? _vehicleImage;
  bool _isVehiclePhotoAdded = false;
  XFile? _vehicleRegistrationFrontImage;
  XFile? _vehicleRegistrationBackImage;

  // TextEditingControllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController drivingLicenseController =
      TextEditingController();

  final TextEditingController brandController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController numberPlateController = TextEditingController();
  final TextEditingController productionYearController =
      TextEditingController();

  // Getters
  XFile? get profilePhoto => _profilePhoto;
  bool get isPhotoAdded => _isPhotoAdded;
  bool get isFormValidBasic => _isFormValidBasic;
  bool get isLoading => _isLoading;
  XFile? get cnincFrontImage => _cnicFrontImage;
  XFile? get cnincBackImage => _cnicBackImage;
  bool get isFormValidCninc => _isFormValidCninc;
  bool get isFormValidDrivingLicnese => _isFormValidDrivingLicense;
  XFile? get cnicWithSelfieImage => _cnicWithSelfieImage;
  XFile? get drivingLicenseFrontImage => _drivingLicenseFrontImage;
  XFile? get drivingLicenseBackImage => _drivingLicenseBackImage;
  bool get isVehicleBasicFormValid => _isVehicleBasicFormValid;
  String? get selectedVehicle => _selectedVehicle;
  XFile? get vehicleImage => _vehicleImage;
  bool get isVehiclePhotoAdded => _isVehiclePhotoAdded;
  XFile? get vehicleRegistrationFrontImage => _vehicleRegistrationFrontImage;
  XFile? get vehicleRegistrationBackImage => _vehicleRegistrationBackImage;
  Timer? _debounce;

  CommonMethods commonMethods = CommonMethods();

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
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

  // Check if the form is valid
  void checkDrivingLicenseFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isFormValidDrivingLicense = _drivingLicenseFrontImage != null &&
          _drivingLicenseBackImage != null &&
          drivingLicenseController.text.isNotEmpty &&
          licenseRegExp.hasMatch(drivingLicenseController.text);
      notifyListeners();
    });
  }

  void checkVehicleBasicFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isVehicleBasicFormValid = _selectedVehicle != null &&
          brandController.text.isNotEmpty &&
          colorController.text.isNotEmpty &&
          numberPlateController.text.isNotEmpty &&
          productionYearController.text.isNotEmpty;
      notifyListeners();
    });
  }

  void setSelectedVehicle(String vehicle) {
    _selectedVehicle = vehicle;
    checkVehicleBasicFormValidity();
    notifyListeners();
  }

  // Dispose controllers
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    cnicController.dispose();
    emailController.dispose();
    phoneController.dispose();
    drivingLicenseController.dispose();
    brandController.dispose();
    colorController.dispose();
    numberPlateController.dispose();
    productionYearController.dispose();
    super.dispose();
  }

  Future<void> pickProfileImageFromGallary() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _profilePhoto = image;
      _isPhotoAdded = true;
      notifyListeners();
    }
  }

  Future<void> pickVehicleImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      _vehicleImage = image;
      _isVehiclePhotoAdded = true;
      notifyListeners();
    }
  }

  Future<void> pickAndCropCnincImage(bool isFrontImage) async {
    final ImagePickerService imagePickerService = ImagePickerService();

    final pickedFile = await imagePickerService.pickCropImage(
      cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
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

  Future<void> pickAndCropVehicleRegistrationImages(bool isFrontImage) async {
    final ImagePickerService imagePickerService = ImagePickerService();

    final pickedFile = await imagePickerService.pickCropImage(
      cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 12),
      imageSource: ImageSource.camera,
    );

    if (pickedFile != null) {
      if (isFrontImage) {
        _vehicleRegistrationFrontImage = pickedFile;
      } else {
        _vehicleRegistrationBackImage = pickedFile;
      }
    }
    notifyListeners();
  }

  Future<void> pickAndCropDrivingLicenseImage(bool isFrontImage) async {
    final ImagePickerService imagePickerService = ImagePickerService();

    final pickedFile = await imagePickerService.pickCropImage(
      cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      imageSource: ImageSource.camera,
    );

    if (pickedFile != null) {
      if (isFrontImage) {
        _drivingLicenseFrontImage = pickedFile;
      } else {
        _drivingLicenseBackImage = pickedFile;
      }
      checkCNICFormValidity();
    }
  }

  Future<void> pickCnincImageWithSelfie() async {
    final ImagePickerService imagePickerService = ImagePickerService();

    final pickedFile = await imagePickerService.pickCropImage(
      cropAspectRatio: const CropAspectRatio(ratioX: 20, ratioY: 20),
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

  Future<void> saveUserData(BuildContext context) async {
    if (!isFormValidBasic ||
        !isFormValidCninc ||
        !isFormValidDrivingLicnese ||
        !isVehicleBasicFormValid) {
      commonMethods.displaySnackBar("Fill all the details!", context);
      return;
    }
    try {
      startLoading();
      final profilePictureUrl =
          await uploadImageToFirebaseStorage(_profilePhoto, "ProfilePicture");

      final frontCnincImageUrl =
          await uploadImageToFirebaseStorage(_cnicFrontImage, "Cninc");
      final backCnincImageUrl =
          await uploadImageToFirebaseStorage(_cnicBackImage, "Cninc");
      final faceWithCnincImageUrl = await uploadImageToFirebaseStorage(
          _cnicWithSelfieImage, "SelfieWithCninc");
      final drivingLicenseFrontImageUrl = await uploadImageToFirebaseStorage(
          _drivingLicenseFrontImage, "DrivingLicenseImages");
      final drivingLicenseBackImageUrl = await uploadImageToFirebaseStorage(
          _drivingLicenseBackImage, "DrivingLicenseImages");
      final vehicleImageUrl =
          await uploadImageToFirebaseStorage(_vehicleImage, "VehicleImage");
      final vehicleRegistrationFrontImageUrl =
          await uploadImageToFirebaseStorage(
              _vehicleRegistrationFrontImage, "VehicleRegistrationImages");
      final vehicleRegistrationBackImageUrl =
          await uploadImageToFirebaseStorage(
              _vehicleRegistrationBackImage, "VehicleRegistrationImages");

      final driver = Driver(
        id: _auth.currentUser!.uid,
        profilePicture: profilePictureUrl,
        firstName: firstNameController.text,
        secondName: lastNameController.text,
        phoneNumber: phoneController.text,
        dob: dobController.text,
        email: emailController.text,
        cnicNumber: cnicController.text, // Add these fields if required
        cnicFrontImage: frontCnincImageUrl,
        cnicBackImage: backCnincImageUrl,
        driverFaceWithCnic: faceWithCnincImageUrl,
        drivingLicenseNumber: drivingLicenseController.text,
        drivingLicenseFrontImage: drivingLicenseFrontImageUrl,
        drivingLicenseBackImage: drivingLicenseBackImageUrl,
        blockStatus: "no",
        vehicleInfo: VehicleInfo(
          type: selectedVehicle.toString(),
          brand: brandController.text,
          color: colorController.text,
          vehiclePicture: vehicleImageUrl,
          productionYear: productionYearController.text,
          registrationPlateNumber: numberPlateController.text,
          registrationCertificateBackImage: vehicleRegistrationFrontImageUrl,
          registrationCertificateFrontImage: vehicleRegistrationBackImageUrl,
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

  // Future<void> saveCNICData() async {
  //   if (!_isFormValidCninc) {
  //     throw Exception("Form is not valid");
  //   }
  //   try {
  //     startLoading();

  //     // Upload CNIC images
  //     final frontImageUrl =
  //         await uploadImageToFirebaseStorage(_cnicFrontImage, "Cninc");
  //     final backImageUrl =
  //         await uploadImageToFirebaseStorage(_cnicBackImage, "Cninc");

  //     // Create CNIC data
  //     final driverData = {
  //       'id': _auth.currentUser!.uid,
  //       'cnicNumber': cnicController.text,
  //       'cnicFrontImage': frontImageUrl,
  //       'cnicBackImage': backImageUrl,
  //     };

  //     // Update driver data in Firebase Realtime Database
  //     final userRef =
  //         _database.ref().child("drivers").child(_auth.currentUser!.uid);
  //     await userRef.update(driverData);

  //     stopLoading();
  //   } catch (e) {
  //     stopLoading();
  //     print("An error occurred while saving CNIC data: $e");
  //   }
  // }
}

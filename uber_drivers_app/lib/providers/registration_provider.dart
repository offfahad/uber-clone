import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uber_drivers_app/global/global.dart';
import 'package:uber_drivers_app/methods/common_method.dart';
import 'package:uber_drivers_app/methods/image_picker_service.dart';
import 'package:uber_drivers_app/models/driver.dart';
import 'package:uber_drivers_app/models/vehicleInfo.dart';
import 'package:uber_drivers_app/pages/profile/profile_page.dart';
import 'package:uber_drivers_app/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

class RegistrationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  bool _isFetchLoading = false;
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
  bool _isDataFetched = false;
  bool get isDataFetched => _isDataFetched;
  bool _currentDriverInfo = false;
  double _driverEarnings = 0.0;
  get driverEarnings => _driverEarnings;

  // TextEditingControllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
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
  bool get isFetchLoading => _isFetchLoading;
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

  void startFetchLoading() {
    _isFetchLoading = true;
    notifyListeners();
  }

  void stopFetchLoading() {
    _isFetchLoading = false;
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
          addressController.text.isNotEmpty &&
          dobController.text.isNotEmpty &&
          _profilePhoto != null;
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
        address: addressController.text,
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
        deviceToken: '',
        earnings: '0',
        driverRattings: '0',
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

  Future<void> fetchUserData() async {
    if (_isDataFetched) {
      print("Data already fetched, skipping...");
      return; // Data already fetched, so skip further fetching
    }
    try {
      startFetchLoading();
      // Reference to the user's data in the database
      final userRef =
          _database.ref().child("drivers").child(_auth.currentUser!.uid);

      // Fetch the data from Firebase
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        // Update fields based on the data fetched
        firstNameController.text = data['firstName'] ?? '';
        lastNameController.text = data['secondName'] ?? '';
        phoneController.text = data['phoneNumber'] ?? '';
        addressController.text = data['address'] ?? '';
        dobController.text = data['dob'] ?? '';
        emailController.text = data['email'] ?? '';
        cnicController.text = data['cnicNumber'] ?? '';
        drivingLicenseController.text = data['drivingLicenseNumber'] ?? '';
        _selectedVehicle = data['vehicleInfo']['type'] ?? '';
        brandController.text = data['vehicleInfo']['brand'] ?? '';
        colorController.text = data['vehicleInfo']['color'] ?? '';
        numberPlateController.text =
            data['vehicleInfo']['registrationPlateNumber'] ?? '';
        productionYearController.text =
            data['vehicleInfo']['productionYear'] ?? '';

        // Update XFile instances if URLs exist (assuming download and save locally)
        _profilePhoto = await _fetchImageFromUrl(data['profilePicture']);
        _cnicFrontImage = await _fetchImageFromUrl(data['cnicFrontImage']);
        _cnicBackImage = await _fetchImageFromUrl(data['cnicBackImage']);
        _cnicWithSelfieImage =
            await _fetchImageFromUrl(data['driverFaceWithCnic']);
        _drivingLicenseFrontImage =
            await _fetchImageFromUrl(data['drivingLicenseFrontImage']);
        _drivingLicenseBackImage =
            await _fetchImageFromUrl(data['drivingLicenseBackImage']);
        _vehicleImage =
            await _fetchImageFromUrl(data['vehicleInfo']['vehiclePicture']);
        _vehicleRegistrationFrontImage = await _fetchImageFromUrl(
            data['vehicleInfo']['registrationCertificateFrontImage']);
        _vehicleRegistrationBackImage = await _fetchImageFromUrl(
            data['vehicleInfo']['registrationCertificateBackImage']);
        _isDataFetched = true;
        // Notify listeners to update UI
        stopFetchLoading();
        notifyListeners();
      } else {
        print("No data available for this user.");
        stopFetchLoading();
      }
    } catch (e) {
      print("An error occurred while fetching user data: $e");
      stopFetchLoading();
    }
  }

  Future<XFile?> _fetchImageFromUrl(String url) async {
    try {
      // Fetch the image from the URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Get the temporary directory to store the downloaded image
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Write the image to the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Return the XFile
        return XFile(file.path);
      } else {
        print('Failed to download image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

// Fetch the driver's earnings from Firebase Database
  Future<void> fetchDriverEarnings() async {
    try {
      final userId = _auth.currentUser!.uid;
      DatabaseReference driverRef =
          _database.ref().child("drivers").child(userId);

      // Retrieve the earnings value from Firebase
      final snapshot = await driverRef.child("earnings").get();
      if (snapshot.exists) {
        // Parse the earnings as a double
        double earnings = double.tryParse(snapshot.value.toString()) ?? 0.0;

        // Store the earnings as double
        _driverEarnings = double.parse(
            earnings.toStringAsFixed(2)); // Round to 2 decimal places

        notifyListeners(); // Notify listeners to update the UI
      } else {
        _driverEarnings = 0.0;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching driver's earnings: $e");
    }
  }

  Future<void> retrieveCurrentDriverInfo() async {
    try {
      final driverId = _auth.currentUser!.uid;
      DatabaseReference driverRef =
          _database.ref().child("drivers").child(driverId);
      // Fetch the data from Firebase
      final snapshot = await driverRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        // Update fields based on the data fetched
        driverName = data['firstName'] ?? '';
        driverSecondName = data['secondName'] ?? '';
        driverPhone = data['phoneNumber'] ?? '';
        driverEmail = data['email'] ?? '';
        address = data['address'] ?? '';
        ratting = data['driverRattings'] ?? '';
        driverPhoto = data['profilePicture'] ?? '';
        carModel = data['vehicleInfo']['brand'] ?? '';
        carColor = data['vehicleInfo']['color'] ?? '';
        carNumber = data['vehicleInfo']['registrationPlateNumber'] ?? '';

        // Notify listeners to update UI
        notifyListeners();
      } else {
        print("No data available for this user.");
      }
    } catch (e) {
      print("An error occurred while fetching user data: $e");
    }
  }

  Future<void> updateBasicDriverInfo(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      final newProfilePicture =
          await uploadImageToFirebaseStorage(_profilePhoto, "ProfilePicture");
      // Basic driver data
      final driverData = {
        'firstName': firstNameController.text,
        'secondName': lastNameController.text,
        'email': emailController.text,
        'address': addressController.text,
        'phoneNumber': phoneController.text,
        'dob': dobController.text,
        'profilePicture': newProfilePicture,
        // URL of uploaded profile photo (if exists)
      };
      final userRef =
          _database.ref().child("drivers").child(_auth.currentUser!.uid);
      await userRef.update(driverData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating basic driver info: $e");
      _isLoading = false;
    }
  }

  Future<void> updateCnincInfo(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      final frontCnincImageUrl =
          await uploadImageToFirebaseStorage(_cnicFrontImage, "Cninc");
      final backCnincImageUrl =
          await uploadImageToFirebaseStorage(_cnicBackImage, "Cninc");
      // Basic driver data
      final driverData = {
        'cnicFrontImage': frontCnincImageUrl,
        'cnicBackImage': backCnincImageUrl,
        'cnicNumber': cnicController.text,
        // URL of uploaded profile photo (if exists)
      };
      final userRef =
          _database.ref().child("drivers").child(_auth.currentUser!.uid);
      await userRef.update(driverData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating basic driver info: $e");
      _isLoading = false;
    }
  }

  Future<void> updateSelfieWithCnincInfo(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      final faceWithCnincImageUrl = await uploadImageToFirebaseStorage(
          _cnicWithSelfieImage, "SelfieWithCninc");
      // Basic driver data
      final driverData = {
        'driverFaceWithCnic': faceWithCnincImageUrl,
        // URL of uploaded profile photo (if exists)
      };
      final userRef =
          _database.ref().child("drivers").child(_auth.currentUser!.uid);
      await userRef.update(driverData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating basic driver info: $e");
      _isLoading = false;
    }
  }

  Future<void> updatedriverLicenseInfo(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      final drivingLicenseFrontImageUrl = await uploadImageToFirebaseStorage(
          _drivingLicenseFrontImage, "DrivingLicenseImages");
      final drivingLicenseBackImageUrl = await uploadImageToFirebaseStorage(
          _drivingLicenseBackImage, "DrivingLicenseImages");
      // Basic driver data
      final driverData = {
        'driverLicenseFrontImage': drivingLicenseFrontImageUrl,
        'driverLicenseBackImage': drivingLicenseBackImageUrl,
        'driverLicenseNumber': drivingLicenseController.text,
        // URL of uploaded profile photo (if exists)
      };
      final userRef =
          _database.ref().child("drivers").child(_auth.currentUser!.uid);
      await userRef.update(driverData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating basic driver info: $e");
      _isLoading = false;
    }
  }

  Future<void> updateVehicleBasicInfo(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      // Basic driver data
      final vehicleData = {
        'type': selectedVehicle,
        'brand': brandController.text,
        'color': colorController.text,
        'productionYear': productionYearController.text,
        'registrationPlateNumber': numberPlateController.text,
      };
      final userRef = _database
          .ref()
          .child("drivers")
          .child(_auth.currentUser!.uid)
          .child("vehicleInfo");
      await userRef.update(vehicleData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating basic driver info: $e");
      _isLoading = false;
    }
  }

  Future<void> updateVehicleImage(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      final vehicleImageUrl =
          await uploadImageToFirebaseStorage(_vehicleImage, "VehicleImage");
      // Basic driver data
      final vehicleData = {
        'vehiclePicture': vehicleImageUrl,
      };
      final userRef = _database
          .ref()
          .child("drivers")
          .child(_auth.currentUser!.uid)
          .child("vehicleInfo");
      await userRef.update(vehicleData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating basic driver info: $e");
      _isLoading = false;
    }
  }

  Future<void> updateVehicleRegistraionImages(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      final vehicleRegistrationFrontImageUrl =
          await uploadImageToFirebaseStorage(
              _vehicleRegistrationFrontImage, "VehicleRegistrationImages");
      final vehicleRegistrationBackImageUrl =
          await uploadImageToFirebaseStorage(
              _vehicleRegistrationBackImage, "VehicleRegistrationImages");
      final vehicleData = {
        'registrationCertificateFrontImage': vehicleRegistrationFrontImageUrl,
        'registrationCertificateBackImage': vehicleRegistrationBackImageUrl,
      };
      final userRef = _database
          .ref()
          .child("drivers")
          .child(_auth.currentUser!.uid)
          .child("vehicleInfo");
      await userRef.update(vehicleData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating basic driver info: $e");
      _isLoading = false;
    }
  }
}

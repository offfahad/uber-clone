import 'package:uber_drivers_app/models/vehicleInfo.dart';

class Driver {
  final String profilePicture; // Driver's profile picture
  final String firstName; // First name
  final String secondName; // Second name
  final String phoneNumber;
  final String dob; // Date of birth
  final String email; // Email address
  final String cnicNumber; // CNIC number
  final String cnicFrontImage; // CNIC front image
  final String cnicBackImage; // CNIC back image
  final String driverFaceWithCnic; // Driver's face photo with CNIC ID card
  final String drivingLicenseNumber; // Driving license number
  final String drivingLicenseFrontImage; // Driving license front image
  final String drivingLicenseBackImage; // Driving license back image
  final VehicleInfo vehicleInfo; // Vehicle information

  Driver({
    required this.profilePicture,
    required this.firstName,
    required this.secondName,
    required this.phoneNumber,
    required this.dob,
    required this.email,
    required this.cnicNumber,
    required this.cnicFrontImage,
    required this.cnicBackImage,
    required this.driverFaceWithCnic,
    required this.drivingLicenseNumber,
    required this.drivingLicenseFrontImage,
    required this.drivingLicenseBackImage,
    required this.vehicleInfo,
  });

  // Convert Driver object to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'profilePicture': profilePicture,
      'firstName': firstName,
      'secondName': secondName,
      'phoneNumber': phoneNumber,
      'dob': dob,
      'email': email,
      'cnicNumber': cnicNumber,
      'cnicFrontImage': cnicFrontImage,
      'cnicBackImage': cnicBackImage,
      'driverFaceWithCnic': driverFaceWithCnic,
      'drivingLicenseNumber': drivingLicenseNumber,
      'drivingLicenseFrontImage': drivingLicenseFrontImage,
      'drivingLicenseBackImage': drivingLicenseBackImage,
      'vehicleInfo': vehicleInfo.toMap(), // Nested vehicle info
    };
  }

  // Create Driver object from Map (retrieving from Firebase)
  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      profilePicture: map['profilePicture'],
      firstName: map['firstName'],
      secondName: map['secondName'],
      phoneNumber: map['phoneNumber'],
      dob: map['dob'],
      email: map['email'],
      cnicNumber: map['cnicNumber'],
      cnicFrontImage: map['cnicFrontImage'],
      cnicBackImage: map['cnicBackImage'],
      driverFaceWithCnic: map['driverFaceWithCnic'],
      drivingLicenseNumber: map['drivingLicenseNumber'],
      drivingLicenseFrontImage: map['drivingLicenseFrontImage'],
      drivingLicenseBackImage: map['drivingLicenseBackImage'],
      vehicleInfo: VehicleInfo.fromMap(map['vehicleInfo']),
    );
  }
}

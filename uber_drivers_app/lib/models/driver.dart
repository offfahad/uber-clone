import 'package:uber_drivers_app/models/vehicleInfo.dart';

class Driver {
  final String id;
  final String profilePicture; // Driver's profile picture
  final String firstName; // First name
  final String secondName; // Second name
  final String phoneNumber;
  final String address; // Address
  final String dob; // Date of birth
  final String email; // Email address
  final String cnicNumber; // CNIC number
  final String cnicFrontImage; // CNIC front image
  final String cnicBackImage; // CNIC back image
  final String driverFaceWithCnic; // Driver's face photo with CNIC ID card
  final String drivingLicenseNumber; // Driving license number
  final String drivingLicenseFrontImage; // Driving license front image
  final String drivingLicenseBackImage; // Driving license back image
  final String blockStatus;
  final String deviceToken;
  final String earnings; // Total
  final String driverRattings; //
  final VehicleInfo vehicleInfo; // Vehicle information

  Driver({
    required this.id,
    required this.profilePicture,
    required this.firstName,
    required this.secondName,
    required this.phoneNumber,
    required this.address,
    required this.dob,
    required this.email,
    required this.cnicNumber,
    required this.cnicFrontImage,
    required this.cnicBackImage,
    required this.driverFaceWithCnic,
    required this.drivingLicenseNumber,
    required this.drivingLicenseFrontImage,
    required this.drivingLicenseBackImage,
    required this.blockStatus,
    required this.deviceToken,
    required this.earnings,
    required this.driverRattings,
    required this.vehicleInfo,
  });

  // Convert Driver object to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profilePicture': profilePicture,
      'firstName': firstName,
      'secondName': secondName,
      'phoneNumber': phoneNumber,
      'address': address,
      'dob': dob,
      'email': email,
      'cnicNumber': cnicNumber,
      'cnicFrontImage': cnicFrontImage,
      'cnicBackImage': cnicBackImage,
      'driverFaceWithCnic': driverFaceWithCnic,
      'drivingLicenseNumber': drivingLicenseNumber,
      'drivingLicenseFrontImage': drivingLicenseFrontImage,
      'drivingLicenseBackImage': drivingLicenseBackImage,
      'blockStatus': blockStatus,
      'deviceToken': deviceToken,
      'earnings': earnings,
      'driverRattings': driverRattings, // Driver's rating as a string (to handle decimal values)
      'vehicleInfo': vehicleInfo.toMap(), // Nested vehicle info
    };
  }

  // Create Driver object from Map (retrieving from Firebase)
  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'],
      profilePicture: map['profilePicture'],
      firstName: map['firstName'],
      secondName: map['secondName'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      dob: map['dob'],
      email: map['email'],
      cnicNumber: map['cnicNumber'],
      cnicFrontImage: map['cnicFrontImage'],
      cnicBackImage: map['cnicBackImage'],
      driverFaceWithCnic: map['driverFaceWithCnic'],
      drivingLicenseNumber: map['drivingLicenseNumber'],
      drivingLicenseFrontImage: map['drivingLicenseFrontImage'],
      drivingLicenseBackImage: map['drivingLicenseBackImage'],
      blockStatus: map['blockStatus'],
      deviceToken: map['deviceToken'],
      earnings: map['earnings'],
      driverRattings: map['driverRattings'], // Convert driverRattings back to double
      vehicleInfo: VehicleInfo.fromMap(map['vehicleInfo']),
    );
  }
}

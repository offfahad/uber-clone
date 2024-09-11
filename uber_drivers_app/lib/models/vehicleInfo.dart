class VehicleInfo {
  final String type; // Vehicle type (car, rikshaw, motorbike, etc.)
  final String brand; // Vehicle brand
  final String color; // Vehicle color
  final String registrationPlateNumber; // Registration plate number
  final String vehiclePicture; // Vehicle picture
  final String productionYear; // Vehicle production year
  final String registrationCertificateFrontImage; // Registration certificate front image
  final String registrationCertificateBackImage; // Registration certificate back image

  VehicleInfo({
    required this.type,
    required this.brand,
    required this.color,
    required this.registrationPlateNumber,
    required this.vehiclePicture,
    required this.productionYear,
    required this.registrationCertificateFrontImage,
    required this.registrationCertificateBackImage,
  });

  // Convert VehicleInfo object to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'brand': brand,
      'color': color,
      'registrationPlateNumber': registrationPlateNumber,
      'vehiclePicture': vehiclePicture,
      'productionYear': productionYear,
      'registrationCertificateFrontImage': registrationCertificateFrontImage,
      'registrationCertificateBackImage': registrationCertificateBackImage,
    };
  }

  // Create VehicleInfo object from Map (retrieving from Firebase)
  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      type: map['type'],
      brand: map['brand'],
      color: map['color'],
      registrationPlateNumber: map['registrationPlateNumber'],
      vehiclePicture: map['vehiclePicture'],
      productionYear: map['productionYear'],
      registrationCertificateFrontImage: map['registrationCertificateFrontImage'],
      registrationCertificateBackImage: map['registrationCertificateBackImage'],
    );
  }
}

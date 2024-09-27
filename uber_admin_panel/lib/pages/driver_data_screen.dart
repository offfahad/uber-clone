import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DriverDataScreen extends StatefulWidget {
  final String driverId;

  const DriverDataScreen({super.key, required this.driverId});

  @override
  _DriverDataScreenState createState() => _DriverDataScreenState();
}

class _DriverDataScreenState extends State<DriverDataScreen> {
  @override
  Widget build(BuildContext context) {
    DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child("drivers").child(widget.driverId);
    return StreamBuilder(
      stream: driverRef.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          print("Error: ${snapshotData.error}");
          return const Center(
            child: Text(
              "Error occurred. Try later",
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        }

        if (snapshotData.connectionState == ConnectionState.none) {
          return const Center(
            child: Text(
              "No connection. Please check your internet.",
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        }
        if (!snapshotData.hasData ||
            snapshotData.data?.snapshot.value == null) {
          return const Center(
            child: Text(
              "No data available",
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(dataMap),
                const SizedBox(height: 20),
                _buildCNICSection(dataMap),
                const SizedBox(height: 20),
                _buildLicenseSection(dataMap),
                const SizedBox(height: 20),
                _buildVehicleInfoSection(dataMap),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(Map dataMap) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Name: ${dataMap['firstName']} ${dataMap['secondName']}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (dataMap.containsKey('profilePicture'))
                ClipOval(
                  child: Image.network(
                    dataMap['profilePicture'],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Phone: ${dataMap['phoneNumber']}"),
                  Text("Email: ${dataMap['email']}"),
                  Text("CNIC Number: ${dataMap['cnicNumber']}"),
                  Text("Address: ${dataMap['address']}"),
                  Text("Date of Birth: ${dataMap['dob']}"),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCNICSection(Map dataMap) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CNIC Information:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildImage(dataMap['cnicFrontImage'], "Front CNIC"),
              const SizedBox(width: 10),
              _buildImage(dataMap['cnicBackImage'], "Back CNIC"),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Selfie with CNIC:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildImage(dataMap['driverFaceWithCnic'], "Selfie with CNIC"),
        ],
      ),
    );
  }

  Widget _buildLicenseSection(Map dataMap) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Driving License:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildImage(dataMap['drivingLicenseFrontImage'], "Front License"),
              const SizedBox(width: 10),
              _buildImage(dataMap['drivingLicenseBackImage'], "Back License"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoSection(Map dataMap) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vehicle Information:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("Brand: ${dataMap['vehicleInfo']['brand']}"),
          Text("Color: ${dataMap['vehicleInfo']['color']}"),
          Text("Year: ${dataMap['vehicleInfo']['productionYear']}"),
          Text(
              "Plate Number: ${dataMap['vehicleInfo']['registrationPlateNumber']}"),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildImage(
                  dataMap['vehicleInfo']['registrationCertificateFrontImage'],
                  "Front Certificate"),
              const SizedBox(width: 10),
              _buildImage(
                  dataMap['vehicleInfo']['registrationCertificateBackImage'],
                  "Back Certificate"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url, String label) {
    return Column(
      children: [
        Image.network(
          url,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 3,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

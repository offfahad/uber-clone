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
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromARGB(221, 39, 57, 99),
            centerTitle: true,
            title: const Text(
              "Driver Details",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildProfileSection(dataMap),
                const SizedBox(height: 20),
                Divider(),
                _buildCNICSection(dataMap),
                const SizedBox(height: 20),
                Divider(),
                _buildLicenseSection(dataMap),
                const SizedBox(height: 20),
                Divider(),
                _buildVehicleInfoSection(dataMap),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(Map dataMap) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dataMap.containsKey('profilePicture'))
          ClipOval(
            child: Image.network(
              dataMap['profilePicture'],
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(width: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name: ${dataMap['firstName']} ${dataMap['secondName']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Phone: ${dataMap['phoneNumber']}"),
            Text("Email: ${dataMap['email']}"),
            Text("CNIC Number: ${dataMap['cnicNumber']}"),
            Text("Address: ${dataMap['address']}"),
            Text("Date of Birth: ${dataMap['dob']}"),
          ],
        ),
      ],
    );
  }

  Widget _buildCNICSection(Map dataMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CNIC Information:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildImage(dataMap['cnicFrontImage'], "Front CNIC"),
            _buildImage(dataMap['cnicBackImage'], "Back CNIC"),
            _buildImage(dataMap['driverFaceWithCnic'], "Selfie with CNIC"),
          ],
        ),
      ],
    );
  }

  Widget _buildLicenseSection(Map dataMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Driving License:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text('Driving License Number: ${dataMap['drivingLicenseNumber']}'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildImage(dataMap['drivingLicenseFrontImage'], "Front License"),
            _buildImage(dataMap['drivingLicenseBackImage'], "Back License"),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleInfoSection(Map dataMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vehicle Information:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text("Vehicle Type: ${dataMap['vehicleInfo']['type']}"),
        Text("Brand: ${dataMap['vehicleInfo']['brand']}"),
        Text("Color: ${dataMap['vehicleInfo']['color']}"),
        Text("Year: ${dataMap['vehicleInfo']['productionYear']}"),
        Text(
            "Plate Number: ${dataMap['vehicleInfo']['registrationPlateNumber']}"),
        const SizedBox(height: 10),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildImage(
                dataMap['vehicleInfo']['registrationCertificateFrontImage'],
                "Front Certificate"),
            _buildImage(
                dataMap['vehicleInfo']['registrationCertificateBackImage'],
                "Back Certificate"),
          ],
        ),
      ],
    );
  }

  Widget _buildImage(String url, String label) {
    return Column(
      children: [
        Image.network(
          url,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

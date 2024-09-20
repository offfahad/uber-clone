import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String userPhone = "";
String userEmail = "";
String userID = FirebaseAuth.instance.currentUser!.uid;
const String googleMapKey = "AIzaSyClGLbuireUmfElTaZ2UQWV7bejJKSbXDE";
const String stripeSecretAPIKey = "sk_test_51PQ234P0mKjkBKKZw6dAxgSI4YQjxf9QVIKrZXyLe05y9fAmrxlcOc2RO5Za7yQhI4Utby88PedaaVFv25hrgxys008Pj28E57";
const String stripePublishedKey = "pk_test_51PQ234P0mKjkBKKZdaEzl1I52zd0GB6pxjaIwYfrryNHtx3FO9aYTTEi4HZKWfyj50mBdgzh3YHQRRkC8nVo9V4Z00eS2JtTsn";
const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

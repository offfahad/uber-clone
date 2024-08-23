class AddressModel {
  String? humanReadableAddress;
  double? latitudePosition;
  double? longitudePosition;
  String? placeID;
  String? placeName;

  AddressModel(
      {this.humanReadableAddress,
      this.latitudePosition,
      this.longitudePosition,
      this.placeID,
      this.placeName});
}

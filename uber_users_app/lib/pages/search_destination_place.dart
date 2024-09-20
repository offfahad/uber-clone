import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/main.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/models/prediction_model.dart';
import 'package:uber_users_app/widgets/prediction_place_ui.dart';

class SearchDestinationPlace extends StatefulWidget {
  const SearchDestinationPlace({super.key});

  @override
  State<SearchDestinationPlace> createState() => _SearchDestinationPlaceState();
}

class _SearchDestinationPlaceState extends State<SearchDestinationPlace> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController =
      TextEditingController();

  List<PredictionModel> dropOffPredictionsPlacesList = [];
  searchLocation(String locationName) async {
    if (locationName.length > 1) {
      String apiPlacesUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&key=$googleMapKey&components=country:pk";
      print('API PLACE URL $apiPlacesUrl');

      var responseFromPlacesAPI =
          await CommonMethods.sendRequestToAPI(apiPlacesUrl);

      if (responseFromPlacesAPI == "error") {
        return;
      }

      if (responseFromPlacesAPI["status"] == "OK") {
        var predictionsResultsInJson = responseFromPlacesAPI["predictions"];
        var predictionsList = (predictionsResultsInJson as List)
            .map(
              (eachPlacePrediction) =>
                  PredictionModel.fromJson(eachPlacePrediction),
            )
            .toList();

        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            dropOffPredictionsPlacesList = predictionsList;
          });
          print("predicted places = " + predictionsResultsInJson.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String userAddress = Provider.of<AppInfoClass>(context, listen: false)
            .pickUpLocation!
            .humanReadableAddress ??
        '';

    print('User Pick Up Location ${userAddress}');

    pickUpTextEditingController.text = userAddress;
    mq = MediaQuery.sizeOf(context);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 5,
                
                child: Container(
                  //height: mq.height * 0.25,
                  decoration: const BoxDecoration(
                    //color: Colors.black12,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 24, top: 20, right: 24, bottom: 30),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 6,
                        ),
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                            ),
                            const Center(
                              child: Text(
                                "Set Dropoff Location",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        Row(
                          children: [
                            Image.asset(
                              "assets/images/initial.png",
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: TextField(
                                    controller: pickUpTextEditingController,
                                    decoration: const InputDecoration(
                                      hintText: "Pickup Address",
                                      fillColor: Colors.white60,
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 11, top: 9, bottom: 9),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 11,
                        ),
                        Row(
                          children: [
                            Image.asset(
                              "assets/images/final.png",
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: TextField(
                                    controller: destinationTextEditingController,
                                    onChanged: (value) {
                                      searchLocation(value);
                                    },
                                    decoration: const InputDecoration(
                                      hintText: "Destination Address",
                                      fillColor: Colors.white60,
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 11, top: 9, bottom: 9),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //diplay the prediction results
              (dropOffPredictionsPlacesList.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 5,
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.all(0),
                        
                        
                        itemBuilder: (context, index) {
                          return Card(
                            //color: Colors.white10,
                            elevation: 5,
                            
                            
                            child: PredictionPlaceUI(
                              predictedPlaceData:
                                  dropOffPredictionsPlacesList[index],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                          height: 10,
                        ),
                        itemCount: dropOffPredictionsPlacesList.length,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

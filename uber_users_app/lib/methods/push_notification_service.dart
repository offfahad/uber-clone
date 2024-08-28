import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/global/global_var.dart';

class PushNotificationService {
  static Future<String> getAccessToken() async {
    try {
      final serviceAccountJson = {
        "type": "service_account",
        "project_id": "everyone-2de50",
        "private_key_id": "967652812eaa79d514ec736321a771749dde54d6",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCzCjNzkc73P7dY\nwZbhBTR4wBNFPHUGPeMGNVCUsednCpHV8jGKcCzXW4mKszQhALFzTLpfE/LTuxFl\nP5C8CEdaRCg1YVm/LiUVdC59nlvBX4ZVvWG8clVCnZWGacBwtnFft91uudKn+a5f\nodRQV7uS6nbhgxcrt0HhkoUl0PLWD4WwtazDbLwjCrLqqDO/vjMDS3mTjy6B73DD\nzGmZepxkjSb1YJbtNfs4DyxXG1Yyo/kQWcTiUxDeyFl9I1pkP4rVsdvUng40T323\n2JM98rGEp60hSAOshJavW9qK0KtHe+XSjNYoagCf2+3XxX3UoJpNg2qnUM/HMa9W\nHLJLLPwfAgMBAAECggEAB+SUERe6o+FuCp56MXsCba0AtyWA/otIO16qqet6iUCI\n3lbaLUFgZgbAi69Lxdqwd/tIH2c95hdR9ICMDRC2XeSG+0If6+gztVGVDRpSmYtF\nsk5HhUBrFs/jUXTPCYkEJX/xu0RmOjEtKUUf8CzLSvZFfbqYO71NTQ2htgw98Fwq\n50hfTuDa1+E12AU4iUYe6dYWbEo/FFSddQQA1XFnLVsY6Vu8bWDo4gVcj1RHXSVE\nkhyCp6z2u9yz6weozwI8vEgq2OuoFFYnbF3B0gnJk/ivULRkP74SzCF7njf9wATo\nTHdxXs3HmHLqat4cn58r8OXmrX+DA5VDMR/pe+MSFQKBgQDkrzHQQ8c2lRmLiECb\n0t8yZzYgfiRWp/0UQLyWA3x7hjDOQa1q+4W80mP98EzHhEDxQkUvyF9VCh1/mREU\n9N7QPPiIAwN12/+qGqvbmzdLSv841aNlI6SwHMAItwhLQDrtssPoR+yeRvtQsl+e\n1FAoNG2F19yGTiaNcFj2qr1GBQKBgQDIbPS9CSZlQFFRGQhOeHyh1W0834tMs8T7\n460lhcGz371GAoRzVhgvmx8K1qws8JRKoBJMok656VzaLi8kT4yVGXLjZf2Rp9/3\nitErfhViUX/gYEjuF30DCqz4+UD1AU2cokvQ5TeKlX+Oj1bxDmu+7cGIiQZHz3hB\nxsXC4XgO0wKBgFOpZGf04+SsF3RcnIZlVxJxf/PTMighvQyzwkp/bAMkzKYokPEa\no4q4zawRRYWYdMnOnNEmVPofgTs1HHK2Qu2b4LChqZpsqdPpfgYReuEoxsZcIjLW\nH2HuorKNg5NEJErho5pO9dnRzg9vslvBALI0u/zDRAI+hQwpleJoBGahAoGAHP0d\nXOYg5o4p9MfhGrB0nlenSCGxHTP3LtOcbIvvG1wmHSUqESCHuQL/t2qbVpipai3C\n19C2AE/PfUMm0GKtG7ellVxgE5wrWbt7S4YeA610CHkEs2M0UqdNo2kxyv4YQqp6\nuskcgm/jFjSHR7BlRyVOU7g171cDtsfQPMKtwb8CgYB8a8bQe3kwhWaXVl8CLqbx\nheg9/UxbVggT6FUEpaV2nJ/GsatjnlYPpGOGRFEptd3xaTssfIPUf7/4yu1kXwy8\nfY1PKckgRZNm7j0cbvRqCSW7lHySLrRIojzq1URf5VPQIfeTo6JcTULz4agvMScs\nT8eC2TBK+X8mrZ3EY2JjUw==\n-----END PRIVATE KEY-----\n",
        "client_email":
            "flutteruberclone-fahad@everyone-2de50.iam.gserviceaccount.com",
        "client_id": "105514248289566554622",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/flutteruberclone-fahad%40everyone-2de50.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      };
      List<String> scopes = [
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/firebase.database",
        "https://www.googleapis.com/auth/firebase.messaging"
      ];

      http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );
      client.close();
      return credentials.accessToken.data;
    } catch (e) {
      print("Failed to obtain access token: $e");
      rethrow; // Optionally rethrow the exception
    }
  }

  static sendNotificationToSelectedDriver(
      String deviceToken, BuildContext context, String tripID) async {
        print('device token, ${deviceToken}');
    String dropOffDesitinationAddress =
        Provider.of<AppInfo>(context, listen: false)
            .dropOffLocation!
            .placeName
            .toString();
    String pickUpAddress = Provider.of<AppInfo>(context, listen: false)
        .pickUpLocation!
        .placeName
        .toString();
    print('pickup address is ${pickUpAddress}');
    final String serverKeyTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        "https://fcm.googleapis.com/v1/projects/everyone-2de50/messages:send";
    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': "New Trip Request From $userName",
          'body':
              "PickUp Location: $pickUpAddress \nDropOff Location: $dropOffDesitinationAddress"
        },
        'data': {
          'tripID': tripID,
        }
      }
    };
    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKeyTokenKey'
      },
      body: jsonEncode(message),
    );
    if (response.statusCode == 200) {
      print("Notifcation send successfully. ${response.statusCode}");
    } else {
      print('Failed to send notification, ${response.statusCode}');
    }
  }
}

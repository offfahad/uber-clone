import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:uber_users_app/global/global_var.dart';

class StripePaymentService {
  // Create payment intent
  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var secretKey = stripeSecretAPIKey;
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      print('Payment Intent Body: ${response.body}');
      return jsonDecode(response.body);
    } catch (err) {
      print('Error creating payment intent: ${err.toString()}');
      return null;
    }
  }

  // Display the payment sheet
  Future<void> displayPaymentSheet(
      BuildContext context, String clientSecret) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
      // Payment was successful, send "paid" back
    } on StripeException catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Cancelled")),
      );
      // Payment was cancelled, send "no paid" back
    } catch (e) {
      print("Error displaying payment sheet: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Failed")),
      );
      // Handle any other errors (optionally)
    }
  }

  // Initialize the payment sheet
  Future<void> initPaymentSheet(
      BuildContext context, String clientSecret, String currency) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          googlePay: PaymentSheetGooglePay(
            testEnv: true,
            currencyCode: currency,
            merchantCountryCode: "PK",
          ),
          merchantDisplayName: 'Uber Rider App',
        ),
      );
    } catch (e) {
      print("Error initializing payment sheet: $e");
    }
  }
}

import 'package:flutter/material.dart';
import 'package:uber_users_app/services/stripe_payment_service.dart';

class PaymentDialog extends StatefulWidget {
  final String fareAmount;

  PaymentDialog({
    super.key,
    required this.fareAmount,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  Map<String, dynamic>? paymentIntent;
  final StripePaymentService _paymentService = StripePaymentService();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 21),
            const Text(
              "PAY CASH",
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 21),
            const Divider(height: 1.5, color: Colors.black54, thickness: 1.0),
            const SizedBox(height: 16),
            Text(
              "\Rs ${widget.fareAmount}",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "This is fare amount ( Rs ${widget.fareAmount} ) you have to pay to the driver.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 31),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, "paid");
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("PAY WITH CASH",
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await makePayment();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("PAY WITH CREDIT CARD",
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 41),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, "paid");
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 31),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      // Convert fareAmount to paisa for PKR (multiply by 100)
      String amountInPaisa =
          (double.parse(widget.fareAmount) * 100).toInt().toString();

      // Create payment intent for PKR using the fare amount
      paymentIntent =
          await _paymentService.createPaymentIntent(amountInPaisa, 'PKR');

      if (paymentIntent != null) {
        // Initialize the payment sheet
        await _paymentService.initPaymentSheet(
          context,
          paymentIntent!['client_secret'],
          'PKR',
        );

        // Display the payment sheet
        await _paymentService.displayPaymentSheet(
            context, paymentIntent!['client_secret']);

        // If payment is successful, you can handle it here
        paymentIntent = null;
      }
    } catch (e) {
      print("Exception: $e");
    }
  }
}

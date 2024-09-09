import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import '../methods/common_methods.dart';



class PaymentDialog extends StatefulWidget
{
  String fareAmount;

  PaymentDialog({super.key, required this.fareAmount,});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog>
{
  CommonMethods cMethods = CommonMethods();

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

            const SizedBox(height: 21,),

            const Text(
              "PAY CASH",
              style: TextStyle(
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 21,),

            const Divider(
              height: 1.5,
              color: Colors.black54,
              thickness: 1.0,
            ),

            const SizedBox(height: 16,),

            Text(
              "\Rs ${widget.fareAmount}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "This is fare amount ( Rs ${widget.fareAmount} ) you have to pay to the driver.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black
                ),
              ),
            ),

            const SizedBox(height: 31,),

            ElevatedButton(
              onPressed: ()
              {
                Navigator.pop(context, "paid");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text(
                "PAY CASH",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 41,)

          ],
        ),
      ),
    );
  }
}

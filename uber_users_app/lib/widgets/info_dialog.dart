import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  String? title, description;
  InfoDialog({super.key, this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.grey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 12,
                ),
                Text(
                  title!,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white60),
                ),
                const SizedBox(
                  height: 27,
                ),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(
                  height: 32,
                ),
                SizedBox(
                  width: 202,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK"),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CommonMethods {
  Widget header(int headerFlexValue, String headerTitle) {
    return Expanded(
      flex: headerFlexValue,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
          ),
          color: const Color.fromARGB(221, 39, 57, 99),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            headerTitle,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget data(int headerFlexValue, Widget widget) {
    return Expanded(
      flex: headerFlexValue,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(221, 39, 57, 99),
          ),
          //color: const Color.fromARGB(221, 39, 57, 99),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: widget,
        ),
      ),
    );
  }
}

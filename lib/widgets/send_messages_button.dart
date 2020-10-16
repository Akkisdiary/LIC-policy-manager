import 'package:flutter/material.dart';

import '../models/policy.dart';

class SendMessagesButton extends StatefulWidget {
  final List<Policy> selectedPolicies;

  SendMessagesButton(this.selectedPolicies);
  @override
  _SendMessagesButtonState createState() =>
      _SendMessagesButtonState(selectedPolicies);
}

class _SendMessagesButtonState extends State<SendMessagesButton> {
  final List<Policy> policies;
  _SendMessagesButtonState(this.policies);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        print(policies.length);
        policies.forEach((element) {
          print(element.customerName);
        });
      },
      child: Text('Send'),
      color: Colors.lightBlue[100],
    );
  }
}

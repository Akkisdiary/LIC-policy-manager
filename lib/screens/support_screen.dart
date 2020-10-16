import 'package:flutter/material.dart';

import '../widgets/profile.dart';
import '../widgets/app_drawer.dart';

class SupportScreen extends StatelessWidget {
  static const routeName = '/supportScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Support'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Profile(image: 'assets/images/badri.jpg',
            name: 'Badri Asawa',
            number: '9595342495',
            mail: 'badriaasawa@gmail.com',),
            Profile(image: 'assets/images/gopi.jpg',
            name: 'Gopish Mundada',
            number: '9689939131',
            mail: 'mundadaga@gmail.com',),
            Profile(image: 'assets/images/akki.jpg',
            name: 'Akshay Shegaonkar',
            number: '9595342495',
            mail: 'shegaonkar.akshay2@gmail.com',),
          ],
        ),
      ),
    );
  }
}

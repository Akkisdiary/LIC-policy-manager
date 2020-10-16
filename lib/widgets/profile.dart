import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatelessWidget {
  final String image;
  final String name;
  final String number;
  final String mail;

  Profile({this.image, this.name, this.number,this.mail,});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Center(
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.12,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage(image),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.phone,size: 20,),
                      onPressed: () {
                        launch('tel:+91 $number');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.email,size: 20,),
                      onPressed: () {
                        launch('mailto:$mail');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.message,size: 20,),
                      onPressed: () {
                        launch('whatsapp://send?phone=91$number');
                      },
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

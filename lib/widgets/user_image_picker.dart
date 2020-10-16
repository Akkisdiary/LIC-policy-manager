import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);

  final void Function(File pickedImage) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;

  void _pickImage(ImageSource source) async {
    final pickedImageFile = await ImagePicker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 1080,
    );
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(pickedImageFile);
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _pickImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _pickImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.14,
          backgroundColor: Colors.transparent,
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage)
              : AssetImage(
                  'assets/profile_img.png',
                ),
        ),
        FlatButton.icon(
          textColor: Theme.of(context).primaryColor,
          onPressed: () {
            _showPicker(context);
          },
          icon: Icon(Icons.add_a_photo),
          label: Text('Add Image'),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../services/user_services.dart';
import './support_screen.dart';
import '../models/agent.dart';
import '../widgets/profile_list_item.dart';

class MyAccountScreen extends StatefulWidget {
  static const routeName = '/MyAccountScreen';

  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  File _pickedImage;
  String name;
  bool isEditing = false;
  final _form = GlobalKey<FormState>();

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    try {
      await Provider.of<UserServices>(context)
          .updateProfile(name, _pickedImage);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(error.toString()),
          content: Text(error.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
      return;
    }
  }

  Widget header(Agent agent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15),
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.16,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (_pickedImage != null)
                      ? FileImage(_pickedImage)
                      : (agent.imgUrl != null)
                          ? NetworkImage(
                              agent.imgUrl,
                            )
                          : AssetImage('assets/profile_img.png'),
                ),
              ),
              if (isEditing) ...[
                FlatButton.icon(
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    _showPicker(context);
                  },
                  icon: Icon(Icons.edit),
                  label: const Text('Change Image'),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Form(
                    key: _form,
                    child: TextFormField(
                      initialValue: agent.name,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(labelText: 'Name:'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a name';
                        }
                        return null;
                      },
                      onSaved: (value) => name = value,
                    ),
                  ),
                ),
              ],
              if (!isEditing) ...[
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    agent.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  agent.email,
                  style: TextStyle(fontSize: 16),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  void _pickImage(ImageSource source) async {
    final pickedImageFile = await ImagePicker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 1080,
    );
    setState(() {
      _pickedImage = pickedImageFile;
    });
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: 896, width: 414, allowFontScaling: true);
    UserServices userService = Provider.of<UserServices>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
        leading: isEditing
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _pickedImage = null;
                  setState(() {
                    isEditing = false;
                  });
                })
            : null,
        actions: [
          !isEditing
              ? IconButton(
                  icon: Icon(LineAwesomeIcons.edit),
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  })
              : IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    _saveForm();
                    setState(() {
                      isEditing = false;
                    });
                  })
        ],
      ),
      body: Column(
        children: <Widget>[
          header(userService.agentDetails()),
          Spacer(),
          if (!isEditing)
            ProfileListItem(
              icon: LineAwesomeIcons.question_circle,
              text: 'Help & Support',
              function: () {
                Navigator.of(context).pushNamed(SupportScreen.routeName);
              },
            ),
          if (!isEditing)
            ProfileListItem(
              icon: LineAwesomeIcons.key,
              text: 'Reset password',
              function: () {
                userService.resetPassword().then((v) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(v ? 'Password reset' : 'Error'),
                      content: Text(
                        v
                            ? 'A link to reset your password has been sent to your registered email'
                            : 'Something went wrong.',
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Okay'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
          if (!isEditing)
            ProfileListItem(
              icon: LineAwesomeIcons.alternate_sign_out,
              text: 'Logout',
              hasNavigation: false,
              function: () => userService.signOut(),
            )
        ],
      ),
    );
  }
}

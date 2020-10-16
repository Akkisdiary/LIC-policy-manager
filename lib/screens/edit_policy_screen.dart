import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/policy.dart';
import '../services/policy_services.dart';

class EditPolicyScreen extends StatefulWidget {
  static const routeName = '/EditPolicyScreen';

  @override
  _EditPolicyScreenState createState() => _EditPolicyScreenState();
}

class _EditPolicyScreenState extends State<EditPolicyScreen> {
  var _isLoading = false;
  // var _isSavedOnce = false;
  final _form = GlobalKey<FormState>();
  File _pickedImage;

  Policy _editedPolicy;

  Future<void> _saveForm() async {
    // setState(() {
    //   _isSavedOnce = true;
    // });
    final isValid = _form.currentState.validate();
    if (!isValid) {
      print('invalid');
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    PolicyServices policy = Provider.of<PolicyServices>(context);
    try {
      // print(_editedPolicy.mobNumber);
      await policy.updatePolicy(_editedPolicy, _pickedImage);
    } catch (error) {
      print('ERROR');
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
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void _presentDatePicker(String type) {
    showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      initialDate: _editedPolicy.nomineeDob,
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (type == 'DOB-N') {
        setState(() {
          _editedPolicy.nomineeDob = pickedDate;
        });
      } else {
        print('Date Picker Error');
      }
    });
  }

  String _calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    return age.toString();
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
    _editedPolicy = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Policy'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                _saveForm();
              }),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _form,
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.transparent,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage)
                            : _editedPolicy.imageUrl != null
                                ? NetworkImage(_editedPolicy.imageUrl)
                                : AssetImage(
                                    'assets/profile_img.png',
                                  ),
                      ),
                      FlatButton.icon(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          _showPicker(context);
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Change Image'),
                      ),
                      TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                            labelText: 'Name: ${_editedPolicy.customerName}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              'Date of Birth: ${DateFormat('dd-MM-yyyy').format(_editedPolicy.dob)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Age: ${_calculateAge(_editedPolicy.dob)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Gender:   ${_editedPolicy.gender}',
                              style: const TextStyle(color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                      TextFormField(
                        initialValue: _editedPolicy.mobNumber,
                        decoration:
                            InputDecoration(labelText: 'Mobile Number:'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        validator: (value) {
                          if (value.length == 10) {
                            return null;
                          }
                          return 'Please provide a valid mobile number';
                        },
                        onSaved: (value) {
                          _editedPolicy.mobNumber = value;
                        },
                      ),
                      TextFormField(
                        initialValue: _editedPolicy.email,
                        decoration: InputDecoration(labelText: 'Email:'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value.contains('@') && value.endsWith('.com')) {
                            return null;
                          } else if (value.length == 0) {
                            return null;
                          } else {
                            return 'Please enter a valid email address.';
                          }
                        },
                        onSaved: (value) {
                          if (value.length == 0) {
                            _editedPolicy.email = null;
                          } else {
                            _editedPolicy.email = value;
                          }
                        },
                      ),
                      TextFormField(
                        initialValue: _editedPolicy.address,
                        decoration: InputDecoration(labelText: 'Address:'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        onSaved: (value) {
                          if (value.length == 0) {
                            _editedPolicy.address = null;
                          } else {
                            _editedPolicy.address = value;
                          }
                        },
                      ),
                      TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                            labelText:
                                'Policy Number: ${_editedPolicy.policyNumber}'),
                      ),
                      TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                            labelText:
                                'Sum Assured: ${_editedPolicy.sumAssured}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ListTile(
                          title: Text(
                            'Start Date:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Text(
                            '${DateFormat.yMd().format(_editedPolicy.startDate)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 200,
                            child: TextFormField(
                              enabled: false,
                              decoration: InputDecoration(
                                  labelText:
                                      'Period in years: ${_editedPolicy.period}'),
                            ),
                          ),
                          Text(
                            'Mode: ${_editedPolicy.mode}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                            labelText: 'Premium: ${_editedPolicy.premium}'),
                      ),
                      Divider(),
                      TextFormField(
                        initialValue: _editedPolicy.nomineeName,
                        decoration: InputDecoration(labelText: 'Nominee:'),
                        keyboardType: TextInputType.name,
                        onSaved: (value) {
                          if (value.length == 0) {
                            _editedPolicy.nomineeName = null;
                            _editedPolicy.nomineeDob = null;
                          } else {
                            _editedPolicy.nomineeName = value;
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text('Nominee DOB:'),
                            FlatButton(
                              onPressed: () => _presentDatePicker('DOB-N'),
                              child: Text(
                                _editedPolicy.nomineeDob == null
                                    ? 'Choose Nominee DOB'
                                    : '${DateFormat('dd-MM-yyyy').format(_editedPolicy.nomineeDob)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Spacer(),
                            if (_editedPolicy.nomineeDob != null)
                              Container(
                                height: 50,
                                width: 80,
                                child: Card(
                                  child: Center(
                                    child: Text(
                                      'Age: ${_calculateAge(_editedPolicy.nomineeDob)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

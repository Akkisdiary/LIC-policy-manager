import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/policy.dart';
import '../services/policy_services.dart';

import '../widgets/user_image_picker.dart';

class AddPolicyScreen extends StatefulWidget {
  static const routeName = '/AddPolicyScreen';

  @override
  _AddPolicyScreenState createState() => _AddPolicyScreenState();
}

class _AddPolicyScreenState extends State<AddPolicyScreen> {
  var _isLoading = false;
  var _isSavedOnce = false;
  final _form = GlobalKey<FormState>();
  File _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  var _editedPolicy = Policy();

  Future<void> _saveForm() async {
    setState(() {
      _isSavedOnce = true;
    });
    final isValid = _form.currentState.validate();
    if (!isValid &&
        _editedPolicy.dob == null &&
        _editedPolicy.startDate == null &&
        _editedPolicy.maturityDate == null &&
        _editedPolicy.mode == null &&
        _editedPolicy.gender == null) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<PolicyServices>(context)
          .addNewPolicy(_editedPolicy, _userImageFile);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred'),
          content: Text('Something went wrong, try again later'),
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
      setState(() {
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void _presentDatePicker(String type) {
  DatePicker.showDatePicker(context,
    theme: DatePickerTheme(containerHeight: 210.0,),
    showTitleActions: true,
    minTime: DateTime(1950),
    maxTime: DateTime(2100),
    onConfirm: (pickedDate) {
      if (pickedDate == null) {
        return;
      } else if (type == 'START') {
        setState(() {
          _editedPolicy.startDate = pickedDate;
        });
      } else if (type == 'DOB-C') {
        setState(() {
          _editedPolicy.dob = pickedDate;
        });
      } else if (type == 'DOB-N') {
        setState(() {
          _editedPolicy.nomineeDob = pickedDate;
        });
      } else {
        print('Date Picker Error');
      }
      setState(() {});
      }, 
      currentTime: DateTime.now(),
      locale: LocaleType.en,);
  }

  String _calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Policy'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _form,
                  child: Column(
                    children: <Widget>[
                      UserImagePicker(_pickedImage),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        decoration:
                            InputDecoration(labelText: 'Customer Name:'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedPolicy.customerName = value;
                        },
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Mobile Number:'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        validator: (value) {
                          if (value.length == 10) {
                            return null;
                          } else {
                            return 'Please provide a valid mobile number';
                          }
                        },
                        onSaved: (value) {
                          _editedPolicy.mobNumber = value;
                        },
                      ),
                      TextFormField(
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
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 5),
                        child: Row(
                          children: <Widget>[
                            Text('Date of Birth:'),
                            FlatButton(
                              onPressed: () => _presentDatePicker('DOB-C'),
                              child: Text(
                                _editedPolicy.dob == null
                                    ? 'Choose DOB'
                                    : '${DateFormat('dd-MM-yyyy').format(_editedPolicy.dob)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: (_isSavedOnce &&
                                          _editedPolicy.dob == null)
                                      ? Colors.red
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Spacer(),
                            if (_editedPolicy.dob != null)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(
                                    child: Text(
                                      'Age: ${_calculateAge(_editedPolicy.dob)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Radio(
                            value: 'M',
                            groupValue: _editedPolicy.gender,
                            onChanged: (value) {
                              setState(() {
                                _editedPolicy.gender = value;
                              });
                            },
                          ),
                          const Text('Male'),
                          Radio(
                            value: 'F',
                            groupValue: _editedPolicy.gender,
                            onChanged: (value) {
                              setState(() {
                                _editedPolicy.gender = value;
                              });
                            },
                          ),
                          const Text('Female'),
                          const Spacer(),
                          if (_isSavedOnce && _editedPolicy.gender == null)
                            const Text(
                              '*Required',
                              style: TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Address:'),
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
                      Divider(),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Policy Number:'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a policy number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _editedPolicy.policyNumber = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Sum Assured:'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isNotEmpty) {
                            return null;
                          }
                          return 'Enter an amount';
                        },
                        onChanged: (value) {
                          _editedPolicy.sumAssured = double.parse(value);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ListTile(
                          title: const Text('Start Date:'),
                          trailing: FlatButton(
                            onPressed: () => _presentDatePicker('START'),
                            child: Text(
                              _editedPolicy.startDate == null
                                  ? 'Choose Start Date'
                                  : '${DateFormat.yMd().format(_editedPolicy.startDate)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: (_isSavedOnce &&
                                        _editedPolicy.startDate == null)
                                    ? Colors.red
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Period in years'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Enter a period';
                                } else if (value.contains('.')) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _editedPolicy.period = int.parse(value);
                                });
                              },
                            ),
                          ),
                          DropdownButton<String>(
                            hint: const Text('Mode'),
                            value: _editedPolicy.mode,
                            icon: const Icon(Icons.list),
                            iconSize: 24,
                            elevation: 16,
                            underline: Container(
                              height: 2,
                              color: Colors.blue,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                _editedPolicy.mode = newValue;
                              });
                            },
                            items: <String>[
                              'yearly',
                              'halfyearly',
                              'quarterly',
                              'monthly',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Premium:'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter a premium';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedPolicy.premium = double.parse(value);
                        },
                      ),
                      const Divider(),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nominee:'),
                        keyboardType: TextInputType.name,
                        onSaved: (value) {
                          if (value.length == 0) {
                            _editedPolicy.nomineeName = null;
                          } else {
                            _editedPolicy.nomineeName = value;
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            const Text('Date of Birth:'),
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
                            const Spacer(),
                            if (_editedPolicy.nomineeDob != null)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
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
